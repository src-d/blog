---
author: vadim
date: 2016-11-23
title: "kmcuda (K-Means on GPU) version 4 is released"
image: /post/kmcuda4/nvprof.png
description: "Our kmcuda v4 is released, featuring multi-gpu, float16, Spherical K-Means and improved precision."
categories: ["science", "technical"]
---
<style>
p.caption {
  margin-top: -16px;
  font-style: italic;
}
</style>

Some time ago, I wrote an article about [src-d/kmcuda](https://github.com/src-d/kmcuda)
named [Towards Yinyang K-means on GPU](http://blog.sourced.tech/post/towards_kmeans_on_gpu/).
Last weekend we released version 4 of that library. Here is the brief list of
changes:

1. K-Means iterations can run in parallel on several GPU cards, so
the elapsed time reduces proportional to the number of GPUs.
2. Type of the input samples can be [16-bit floating point](https://en.wikipedia.org/wiki/Half-precision_floating-point_format) (fp16),
so the maximum size of clustered data doubles.
3. Distance between points can be calculated with the [angular metric](https://en.wikipedia.org/wiki/Cosine_similarity#Angular_distance_and_similarity),
thus the clustering algorithm becomes a variant of [Spherical K-Means](http://www.google.com/search?q=spherical+k-means).
4. The precision of the calculation of distances was improved at the expense
of some small computational overhead thanks to [Kahan summation](https://en.wikipedia.org/wiki/Kahan_summation_algorithm).
5. Zero-copy device input and output, that is, taking samples from GPU
memory and writing the results to the preallocated GPU memory.
6. Build was much improved: selection of the CUDA device architecture, optional components,
continuous integration, [PyPi manylinux wheels](https://github.com/pypa/manylinux).
7. Extensive test suite was developed.

I will go into details about each of the points.

### Multi-GPU

![nvprof](/post/kmcuda4/nvprof.png)
<p align="center" class="caption">nvprof on kmcuda4.</p>

Clustering on several GPUs at the same time is not straightforward,
because you cannot simply split the samples into equal parts and
feed them in parallel. The calculation of the centroids requires having
all the data in the same place. While there can be workarounds for
storing the whole dataset in memory, I chose a quicker to implement
and more performant solution.

Let me recap how the Lloyd's algorithm works:

1. We calculate the distances between the samples and the centroids,
pick the centroid with the minimum distance for every sample (assignment stage).
2. We update the centroids by averaging all the samples assigned to each
(centroids stage).

The current multi-gpu scheme is as follows:

1. We cut the samples into as many intervals as GPUs are available.
Each GPU works with one interval, calculates the distances and
writes the local assignments.
2. GPUs transfer the assignments to each other in an all to all manner.
3. We cut the centroids into the same number of intervals as the number of
GPUs. Each GPU works with one interval and updates the local centroids.
4. GPUs transfer the centroids to each other in an all to all manner.

Steps 2 and 4 require efficient peer to peer communication, and indeed
I am using `cudaMemcpyPeer()`. This approach works well with 2 or 4 GPUs,
but it may produce too much comunication traffic with a bigger number.
In the future (when I start using 8-GPU installments ;)) I will use NVIDIA's
awesome [nccl](https://github.com/NVIDIA/nccl) library.

Conceptually, nothing changes, and the same parallelization pattern is
applied to the Yinyang refinement. The devil is in the implementation details,
as usual.

Enabling peer to peer accees takes quadratic complexity since the
`cudaDeviceEnablePeerAccess()` function must be called for every pair
of GPUs, even for the same pair but reversed. This is surely not an issue
but still fun.

You have to call `cudaSetDevice()` before any other CUDA API call or you
may end up with the wrong device. This is not cool at all and I think
the weakest part of the whole CUDA runtime API. Setting the device number for
every API function would be much better, and it would cure all the
thread safety issues which are currently solved in an ugly manner by the thread local
context.

You shouldn't mix kernel calls with peer to peer memory exchanges,
because `cudaMemcpyPeerAsync()` requires **both** device pipelines
to become ready. In other words, the following will serialize the computation:

```c
for each device {
  kernel<<<...>>>(...);
  for all other devices {
    // wrong - will block other device's stream
    cudaMemcpyPeerAsync(this device, other device);
  }
}
```

But this will work:

```c
for each device {
  kernel<<<...>>>(...);
}
// all pipelines are loaded now
for each device {
  for all other devices {
    cudaMemcpyPeerAsync(this device, other device);
  }
}
```

I wrapped all the repeating boilerplate code in macros. While I am DRY
now, I clearly stepped into a macro hell. Here is an example. An innocent
line which allocates ccounts (centroid assignments counters
written on stage 1 and read on stage 2)...

```
CUMALLOC(device_ccounts, clusters_size);
```

...is actually...

```c++
do {
  do {
    for (int dev : devs) {
      cudaSetDevice(dev);
      do {
        void* __ptr;
        do {
          auto __res = cudaMalloc(
              &__ptr,
              (clusters_size) *
                  sizeof(std::remove_reference<decltype(
                             device_ccounts)>::type::value_type::element_type));
          if (__res != 0) {
            do {
              if (verbosity > 1) {
                printf("%s\n",
                       "cudaMalloc( &__ptr, (clusters_size) * "
                       "sizeof(std::remove_reference<decltype(device_ccounts)>:"
                       ":type::value_type ::element_type))");
              }
            } while (false);
            do {
              if (verbosity > 0) {
                printf("%s:%d -> %s\n", "_file_name_", 301,
                       cudaGetErrorString(__res));
              }
            } while (false);
            do {
              if (verbosity > 0) {
                printf(
                    "failed to allocate %zu bytes for "
                    "device_ccounts"
                    "\n",
                    static_cast<size_t>(clusters_size));
              }
            } while (false);
            return kmcudaMemoryAllocationFailure;
          }
        } while (false);
        (device_ccounts)
            .emplace_back(
                reinterpret_cast<std::remove_reference<decltype(
                    device_ccounts)>::type::value_type::element_type*>(__ptr));
      } while (false);
    }
  } while (false);
} while (false)
```

And this is only one tiny example. I deeply regret what I have done.
However, I don't see any other ways to stay DRY. Perhaps I should have been WET after all.

### fp16

NVIDIA's [Pascal](https://en.wikipedia.org/wiki/Pascal_(microarchitecture)) architecture allows calculations with the half2
data type - two 16-bit floats packed into a 32-bit struct.

![half and half2](https://devblogs.nvidia.com/wp-content/uploads/2015/07/fp16_format-624x146.png)
<p align="center" class="caption">half and half2 floating point binary formats.</p>

All the operations on half and half2 types exist in the form of
[compiler intrinsics](https://en.wikipedia.org/wiki/Intrinsic_function).
For example, if you want to sum two half2 values, the following code
will not be compiled:

```c++
__device__ half2 foo(half2 a, half2 b) {
  return a + b;
}
```

but this will work:

```c++
__device__ half2 foo(half2 a, half2 b) {
  return __hadd2(a. b);
}
```

In theory, I should write nice C++ classes which wrap half2 and offer
overloaded operators, but in practice, there are problems:

* They will devastate the performance of the Debug build.
* They will simplify only the limited number of operations: +, - and *
(division in CUDA is a bad idea - one normally caches the reciprocal
and uses it later).

So my decision was to wrap the intrinsics into plain functions with
[inlining](https://en.wikipedia.org/wiki/Inline_expansion) forced via
`__forceinline__`. Thus the calculation code remains the same for both
data types, whereas all the fast math is applied properly and there is
no need for `--use-fast-math` flag for `nvcc`. I mean, for example,
taking the square root from a 32-bit float is performed using
`__fsqrt_rn` intrinsic and not the normal `sqrt` function. The latter
is translated to the former only if [fast math](http://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html#options-for-steering-gpu-code-generation)
is enabled, but the precision may degrade. The fast math switch activates some other
trade-off optimizations which are not desirable to have in our code.

Although the functions are inlined, they still increased the
[register pressure](https://en.wikipedia.org/wiki/Instruction_set#REGISTER-PRESSURE)
for some reason, that is, some kernels demanded more registers than they did before.
While it is not bad for the kernels, the occupancy of which is bounded with the
shared memory usage, it harms others. I successfully battled with the
pressure using the [volatile trick](http://blog.icare3d.org/2010/04/cuda-volatile-trick.html):
if you declare some often used variables as `volatile`, you force them
to stick to the same registers and not be inlined. Yet I don't feel
that I have squeezed everything from that microoptimization, for example,
Yinyang local filter is eating 40 registers whatever I try to alter.

### Spherical K-Means

![sphere](/post/kmcuda4/sphere.png)

Sometimes, the L2 distance metric is not the best one in which to do
clustering. L2, or simply Euclidean, is the square root of the sum of squares:
$$
\Delta_ 2(\\vec{x}, \\vec{y}) = \\sqrt{\\sum_ i\\limits x_ i^2}
$$
It takes into account the angle between \\(\\vec{x}\\) and \\(\\vec{y}\\),
as well as their magnitude. Angular distance equals to the
angle between two vectors and effectively discards the
information about the magnitude which may be useful for NLP datasets.
It is often referred to as the "cosine distance": given the formula for
the scalar product between two vectors \\(\\vec{x}\\cdot\\vec{y}=|\\vec{x}||\\vec{y}|\\cos\\alpha\\),
the angular distance can be easily calculated:
$$
\Delta_ {angle}(\\vec{x}, \\vec{y}) = \\arccos{\\frac{\\vec{x}\\cdot\\vec{y}}{|\\vec{x}||\\vec{y}|}}
$$
If we fix the lengths of all the vectors to 1, it becomes even shorter:
$$
\Delta_ {angle}(\\vec{x}, \\vec{y}) = \\arccos{\\vec{x}\\cdot\\vec{y}}
$$

Using this distance metric in K-Means leads us to the variant of
Spherical K-Means. There are two modifications relative to the
conventional Lloyd algorithm:

1. Distance is \\(\Delta_ {angle}\\).
2. Centroids must be renormed to 1 after each iteration (hence "spherical").

Both of these modification do not contradict with Yinyang refinement since
it is based solely on the triangle inequality.

The implementation of the angular distance leveraged templates support in
CUDA code again. I added the second template parameter (well, actually
made it the first) and extracted the common routines into `__device__ __forceinline__`
functions. I had to use "traits"-like structures because C++ does not
support partial template function specialization. Besides, I hit
the overflow issue with fp16 during the renorming procedure: it involves
the summation of the squares and the result quickly goes beyond the
maximum limit for 16-bit floats (\\(2^{16}\\)). I had to rollback
to converting from fp16 to fp32 and doing all the operations with
increased precision in that case. I didn't have such issues with L2
because the sum of the squared sample elements is always much smaller;
e.g. 256-dimension vector's squared L2 norm with the average element magnitude
of 10 is \\(256 * 10^2 = 25600 < 2^{16}\\). Yet still I would recommend
to norm the dataset by subtracting the mean and dividing by the dispersion
when clustering with fp16 and L2.

The kernel invocation code becomes pure
hell because I had to give birth to this dreaded template switch:

```c++
#define KERNEL_SWITCH(f, ...) do { switch (metric) { \
  case kmcudaDistanceMetricL2: \
    if (!fp16x2) { \
        using F = float; \
        f<kmcudaDistanceMetricL2, float>__VA_ARGS__; \
    } else { \
        using F = half2; \
        f<kmcudaDistanceMetricL2, half2>__VA_ARGS__; \
    } \
    break; \
  case kmcudaDistanceMetricCosine: \
    if (!fp16x2) { \
        using F = float; \
        f<kmcudaDistanceMetricCosine, float>__VA_ARGS__; \
    } else { \
        using F = half2; \
        f<kmcudaDistanceMetricCosine, half2>__VA_ARGS__; \
    } \
    break; \
} } while(false)
```
```
KERNEL_SWITCH(kmeans_assign_lloyd, <<<sgrid, sblock, shmem_size>>>(
    length,
    reinterpret_cast<const F*>(samples[devi].get() + offset * h_features_size),
    reinterpret_cast<const F*>((*centroids)[devi].get()),
    (*assignments_prev)[devi].get() + offset,
    (*assignments)[devi].get() + offset));
```

From a user's perspective, the C API adds `metric` enumerated parameters
and the Python API adds `metric` string parameters.

### Kahan summation

![kahan](/post/kmcuda4/kahan.png)

K-Means (Lloyd) algorithm includes the calculation of the distances
between two points. Whichever metric is used, it includes the summation
of some values across all the dimensions. While the number of dimenions
is low, everything's fine, however, the precision of the summation
quickly drops as it increases. The cause is the classical loss of
floating point precision in the addition operation: if you try
to sum 32-bit float \\(2^{20}\\) with \\(2^{-20}\\), the result will be still
\\(2^{10}\\) since the
[mantissa](https://en.wikipedia.org/wiki/Floating_point#Internal_representation)
is saturated. At the time I started the project it wasn't much of an issue
with 32-bit floats, but became obvious when I added 16-bit floats.

Practically, the loss of precision leads to worse clustering and more
iterations. To deal with that problem, where possible I decided to use
Kahan summation with both 32- and 16-bit floats. While it may have slightly degraded
the performance, the results became more stable and mathematically correct.

Kahan summation is well described on
[Wikipedia](https://en.wikipedia.org/wiki/Kahan_summation_algorithm). It
is awesome because it requires only \\(O(1)\\) space, particularly,
one additional variable to store the current error correction value.
Besides, it didn't increase the register pressure in the kernels at all.

### Zero-copy

![zero](/post/kmcuda4/zero.png)

The input samples can now be taken from the GPU memory. In that case,
resulting centroids and cluster are supposed to be allocated on the same GPU
and written using CUDA memcpy. This feature is activated by `device_ptrs`
parameter in C API. If it is negative (the default), the usual behavior
is retained. Otherwise, it specifies the device number on which samples
array is allocated. I had a special kind of fun debugging `device_ptrs`
with multiple GPUs, but everything should work fine now.

In the case of the Python API, you can pass a tuple with the CUDA pointer,
the device number and the shape instead of the normal numpy array to
`samples` argument. Optionally, that tuple may be extended with
preallocated centroids and assignments pointers. Normally, Python users
do not work with the CUDA API directly (see how the tests extract raw pointers
from pyCUDA or cuda4py arrays).

### Build

![travis](/post/kmcuda4/travis.png)
<p align="center" class="caption">Part of a TravisCI log.</p>

Some time ago, the library was compiled for only the hardcoded CUDA device
architecture 5.2 (Titan X, Maxwell). However, 16-bit float pairs / half2 type are
not supported by 5.2, they first appeared in 6.0. So I had to add the
ability to choose the target architecture by defining `CUDA_ARCH`:

```
cmake -DCUDA_ARCH=52 ...
```

It should match the set of possible values of `nvcc`'s argument `-arch sm_*`.

Next, I made the compilation of the Python wrapper optional, since I believe
that not everybody needs it. It is still compiled by default, but can be
turned off by defining `DISABLE_PYTHON`.

kmcuda extensively uses [C++11](https://en.wikipedia.org/wiki/C%2B%2B11)
either in the host or the device code, so `nvcc` should be passed the
corresponding flag. `cmake` propagates the host compiler's options to `nvcc`,
but C++11 activation used to be discarded until cmake version 3.3.
Thanks to NVIDIA's [contribution to cmake](https://github.com/Kitware/CMake/commit/99abebdea01b9ef73e091db5594553f7b1694a1b),
it's been repaired since then. I had to apply some workaround for older cmake-s
because TravisCI features outdated Ubuntu 14.04 LTS with an ancient cmake.

Speaking about Travis, yes, I added continuous integration which checks
whether the library is successfully built. There is no possibility to
run tests because they require a CUDA device.

Finally, I hit the problem with uploading Python [wheels](http://pythonwheels.com/)
aimed at Linux to the [cheese shop](https://wiki.python.org/moin/CheeseShop).
Linux wheels are simply not allowed to upload because they are usually
very sensitive to the environment. Thankfully, there is a nice
project [auditwheel](https://github.com/pypa/auditwheel) which can patch
the binaries to be less demanding, it works great and produces "manylinux"
wheels. Those patched wheels may be successfully uploaded using
[twine](https://pypi.python.org/pypi/twine). btw. I opened an
[issue in Tensorflow](https://github.com/tensorflow/tensorflow/issues/5033)
with a similar improvement suggestion.

### Tests

![tests](/post/kmcuda4/tests.png)
<p align="center" class="caption">Running kmcuda4 tests.</p>

Since the very beginning, kmcuda has had the Python3 wrapper. The tests
have been written in Python, which gives several advantages:

1. Python wrapper code is automatically tested, too.
2. No need to compile tests during the build.
3. Tests development is much more flexible and easier.

There are 18 tests at the moment. 5 of them are devoted to fp16 and thus
are skipped if the library is compiled for the 5.2 architecture or older. This is
provided by the addition of `libKMCUDA.supports_fp16` Bool variable.

Sometimes tiny changes in the source code lead to a slight divergence
in the clustering results, which is not always good. The divergence may
occur on, say, 10-th iteration and lead to 16 iterations instead of 15 overall.
There must be a reliable way to validate the clustering process. Since
the C API or Python API do not provide any introspection into it, the only
solution is to record logs, that is, standard output on the biggest
verbosity level, and parse them.

Intercepting stdout in Python is usually easy, one monkey-patches
`sys.stdout`. However, that works with normal Python scripts only - it
has nothing to with the real system streams. I had to write
`StdoutListener` which temporarily redirects the real stdout file stream:

```python
class StdoutListener(object):
    def __init__(self):
        self._file = None
        self._stdout = ""
        self._stdout_fd_backup = None

    def __enter__(self):
        self._file = tempfile.TemporaryFile()
        self._stdout_fd_backup = os.dup(sys.stdout.fileno())
        os.dup2(self._file.fileno(), sys.stdout.fileno())

    def __exit__(self, exc_type, exc_val, exc_tb):
        os.dup2(self._stdout_fd_backup, sys.stdout.fileno())
        self._file.seek(0)
        self._stdout = self._file.read().decode("utf-8")
        self._file.close()
        self._file = None
        os.close(self._stdout_fd_backup)
        self._stdout_fd_backup = None
        print(self._stdout)

    def __str__(self):
        return self._stdout
```

The intended usage of this class is as follows:

```python
stdout = StdoutListener()
with stdout:
    # do some stuff
captured = str(stdout)
```

Internally, it makes the classic dup/dup2 redirection:

1. Open a temporary file.
2. Clone stdout to some backup file descriptor.
3. Redirect stdout to the opened temporary file.
4. Do some work which prints to stdout, all output goes to the temporary file.
5. Restore stdout from the backup so that the subsequent output goes to the terminal again.
6. Read the contents of the temporary file and close it.

The second cause of the divergence in test results is the random generator.
That was foreseen from the very beginning, so I always set the random
generator's seed before running every test to achieve 100% reproducibility.

### Summary
As you see, the new kmcuda has a lot of cool features which have already
been tested in our production environment. Try it out!
It's only been tested on Linux but feel free to port it to other platforms.
Besides, it only supports Python3 and I have no plans to port it to Python2,
sorry.

If you've got a new Pascal GPU like Titan X 2016, installing the library
is as simple as `pip3 install libKMCUDA`. If your GPU's architecture is older,
you have to build it from source - please refer to
[README.md](https://github.com/src-d/kmcuda/blob/develop/README.md).

<script async src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS_CHTML"></script>
