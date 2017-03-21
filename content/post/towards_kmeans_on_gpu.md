---
author: vadim
date: 2016-07-26
title: Towards Yinyang K-means on GPU
image: /post/towards_kmeans_on_gpu/intro.png
description: "K-means is a nice and simple clustering algorithm. It can be effectively implemented using NVIDIA CUDA technology and we elaborate on how."
categories: ["science", "technical"]
---
<style>
p.caption {
  margin-top: -16px;
  font-style: italic;
}
</style>

The codez: [GitHub](https://github.com/src-d/kmcuda).

[Next article about kmcuda v4.](http://blog.sourced.tech/post/kmcuda4/)

We developed an efficient K-means implementation using [NVIDIA CUDA](...)
technology and this article is devoted to the internals of that project.
The motivation is simple: we need to cluster a big number of entities
in high-dimensional space into many clusters as an attempt to simplify
the data and prepare it for other, more sophisticaed clustering algorithms
such as [t-SNE](https://lvdmaaten.github.io/tsne/). We named this project kmcuda,
it offers C and Python3 APIs. kmcuda was successfully applied to problems
with 4M samples, 40k clusters and 480 dimensions.

Theory
------

Machine learning includes different subfields, one of which is called unsupervised
learning. This subject focuses on organizing the data without any
hints from the outside, e.g. labels. It takes some common criteria of
what is a good data organization based on mathematical assumptions.
Usually, data is organized into finite amount of clusters, that is, groups.
So a clustering algorithm takes data and quality metrics on input and
produces the mapping between each data sample and the corresponding suggested
cluster identifier.

There are quite a few clustering concepts out there, see [sklearn](http://scikit-learn.org/stable/modules/clustering.html)
for example. Perhaps the most simple and thus widespread concept
is [K-means](https://en.wikipedia.org/wiki/K-means_clustering). The idea is as
follows: we fix the desired number of clusters and search for the best
centroids (cluster centers). "Best" means that the sum of the distances
from each cluster member to the corresponding centroid is minimal. There
exists an easy to implement algorithm named by it's inventor,
Lloyd, which is guaranteed to converge in L2 metric - when
the distance is calculated as the square root of the sum of squared differences
between each dimension coordinate, in other words, Euclidian. Lloyd's approach is often
confused with K-means problem statement itself, but really it is just one
of the ways to solve it, the first historically appeared.

Lloyd algorithm is iterative and is made of the repetition of these two
steps:

1. Assign each data sample to the cluster to which the distance in minimal among others.
2. Calculate each cluster's centroid by averaging all the samples assigned to it.

Though as was written before this algorithm is guaranteed to finish,
usually we set the tolerance value as the maximum ratio of reassignments
upon reaching which we can early stop. The ratio of reassignments is the
number of samples which changed the owning cluster on step 1 divided by
the overall number of samples. The tolerance is introduced because a
typical dependency of reassignments ratio from passed iterations number looks
like this:

![kmeans iterations](/post/towards_kmeans_on_gpu/kmeans.png)
<p align="center" class="caption">K-Means convergence plot.</p>

It would take a looong time to wait until the algorithm converges to 0
and such flawless clustering is usually not needed in real life. The
tolerance should be set according to the amount of noise in the data,
though no specific formula exist.

Another important consideration of Lloyd's algorithm is the choice of
initial centroids. Indeed, we have to know the proto-clusters at the very
beginning on step 1 in order to assign samples. A naive way to solve this
problem is to randomly choose samples to be centroids, but it does not
work well in practice. For example, imagine that we have to put 100 points into 2 groups,
99 are near (0, 0) and the last one is (1, 1). The K-means solution is,
of course, clusters with centers (0, 0) and (1, 1), but Lloyd's algorithm
will never converge to it if we choose initial centroids in the cloud
of points near (0, 0). The probability of randomly choosing the point (1, 1)
as the initial cluster center is 1/100 + 99/100 * 1/99 ~ 1/50, a pretty low
chance.

An other way to pick initial centroids is [K-means++](https://en.wikipedia.org/wiki/K-means%2B%2B).
The idea is to still randomly choose samples, but with the probability which is not uniform:
it is proportional to the distance from each sample to the nearest centroid.
Thus, in our previous case, the probability of picking (1, 1) becomes
1/100 + 99/100 * √<span style="text-decoration: overline;">2</span> / (√<span style="text-decoration: overline;">2</span> + N*ε), where ε is
the average distance from the other 99 points to (0, 0). We see that
if ε is very small, the second summand becomes close to 1 and
we almost always get the right initial centroids. From the theoretical side,
K-means++ refinement is proven to make Lloyd's process to reach the solution
not worse than O(log k).

![kmeans++](/post/towards_kmeans_on_gpu/pp.png)
<p align="center" class="caption">We need a good K-Means seeding here.</p>

The problem with Lloyd's algorithm, however, is that when the reassignments
ratio drops, we start to do a lot of redundant work recalculating distances
corresponding to samples which are not going to change the cluster.
Since step 1 is much more time consuming than step 2, it becomes critical.

Several solutions have been proposed, and [Yinyang](https://www.microsoft.com/en-us/research/publication/yinyang-k-means-a-drop-in-replacement-of-the-classic-k-means-with-consistent-speedup/)
algorithm is one of them. It was developed at Microsoft Research. The authors compared
it to the other algorithms and observed a substantial performance boost.
There are several ideas incorporated into Yinyang; basically, we
introduce metaclusters and track centroid drifts in each. An exciting
property of Yinyang is that it yields exactly the same results that
would be achieved by ordinary Lloyd. The price of the shown performance
increase is the memory overhead. The overhead size vs. performance is a
tradeoff, and in real world scenarios if you allow too little extra memory,
Yinyang becomes slower than Lloyd.

Practice
--------

NVIDIA CUDA is an architecture sometimes called SIMT: it involves
a huge number of concurrently executing hardware threads (say, 3000),
but with the important constraint: each group of threads (say, 32) must
execute the same instruction at the same time. In other words, it's
like running multiple threads each executing SIMD operations. Of course,
this is a simplification but it should give the general idea.

The power exposed by GPU hardware is impressive: the performance is 10
times higher compared to CPU and the memory bandwidth is 5 times thicker.
These are the graphs taken from [CUDA C Programming Guide](http://docs.nvidia.com/cuda/cuda-c-programming-guide).

![flops](/post/towards_kmeans_on_gpu/flops.png)
<p align="center" class="caption">Performance over time, 2014.</p>

![memory](/post/towards_kmeans_on_gpu/mem.png)
<p align="center" class="caption">RAM speed/bandwidth over time, 2014.</p>

A typical engineering problem is to be able to cleverly ride that beast
and allow it to show it's incredible glory. SIMT is not suited for many
algorithms out there, so if you apply them in a brute-force manner,
you will get a slowdown compared to a CPU, not a speedup. One would notice
that 10x boost in memory speed is not proportional to 100x boost in the
number of threads, so you are likely to end up with a performance bottleneck
in the memory access.

So, let's concern Lloyd's algorithm first. It maps to CUDA pretty well:
each thread maps to a data sample and calculates the distances to each
of the centroids. Since step 2 is not so time consuming, we omit it's
description for now.

Here is the pseudocode:
```python
sample = thread_logical_index()
min_distance = FLT_MAX
owner = None
for cluster in clusters:
  distance = calculate_distance(sample, cluster)
  if distance < min_distance:
    min_distance = distance
    owner = cluster
assign(sample, owner)
```

Let's define the benchmark which we will use to evaluate the performance.
We take 300000 points in 408 dimensions and try to group them into
5000 clusters with 1% tolerance. We set the initialization method
to naive random and fix the pseudorandom generator's seed.
Given Titan X card, the implementation described above finishes in about
48 minutes. State-of-the-art CPU implementation "tyrand lizard king"
(see the comparison [below](#comparison)) finishes in 31 minutes.

We can do better. The key to boosting CUDA performance is, of course,
leveraging the software memory cache called "shared memory". Every block
of CUDA threads (can be adjusted, from 32 to 1024 by step 32) may have
up to 48 KiB of shared memory, which is accessible by every thread in that
block (but not the others). The speed of that cache is huge, by several orders
faster than accessing the ordinary GPU memory (called "global memory").
Let's think of how we can use shared memory here. One consideration that
we must take into account is that we don't want to impose any severe
constraints on the number of clusters or the number of dimensions, like
others do in prior works. Turns out that the only way is to load several
clusters into the shared memory, calculate the distances to them and
synchronize threads.

```python
sample = thread_logical_index()
min_distance = FLT_MAX
owner = None
for cluster_offset in range(0, clusters_number, chunk_size):
  clusters_buffer = load_clusters(cluster_offset, chunk_size)
  for cluster in clusters_buffer:
    distance = calculate_distance(sample, cluster)
    if distance < min_distance:
      min_distance = distance
      owner = cluster
assign(sample, owner)
```

This optimization works really good, dropping the run time to 20 minutes.

We still can do better. Every person who tried hard to optimize a native
function knows about the standard technique called loop unrolling.
Loop unrolling increases the compiled code size but avoids branching
which badly influences the performance because of the pipeline stall.
We are not going to go deep with the details since it
requires understanding the superscalar CPU architecture, so anyway, this is
what happens:

```python
# before
for i in range(0, 100500):
  do_work(i)

# after
for i in range(0, 100500, 4):
  do_work(i)
  do_work(i + 1)
  do_work(i + 2)
  do_work(i + 3)
```

Thus we streamline the control flow and reduce the number of comparisons,
given that the loop is long enough.

The optimization from above is very easy to apply in CUDA code: we just have to
write `#pragma unroll(xxx)` above the cycle and the magic happens during the
compilation. It is cool because we don't have to write the ugly code ourselves!
The tricky part is to pick up the best "xxx". Too small values do not impact that much
and too big values increase [register pressure](https://en.wikipedia.org/wiki/Instruction_set#REGISTER-PRESSURE).
In our case, 4 appeared to be optimal. Now the run time drops to 17 minutes.

We can do better! The thing is that there are different memory access patterns
supported by NVIDIA GPU. If we optimize the memory access for readonly,
constant and sequential transactions, we can gain in speed, because in our case
much depends on the memory. There is a way to do it: we must declare
each hardware pointer as `const __restrict__`. This will allow the compiler
to do more aggressive optimizations since we guarantee no [pointer coalescing]
and actually sets memory transactions to go through the constant access channel,
which is normally used by GPU textures. And now we finish in 13 minutes.

We can do better! Though the following should be logically done before loop unrolling,
historically it was done later. The idea is to decompose the L2 distance
calculation: ∥a - b∥<sub>2</sub> = √<span style="text-decoration: overline;">a</span><sup>2</sup><span style="text-decoration: overline;"> + b</span><sup>2</sup><span style="text-decoration: overline;"> - 2ab</span>.
We can calculate the scalar product between sample and itself and between
centroid and itself beforehand, thus leaving only one operation in the loop
instead of two.
```python
ssqr = dot(sample, sample)
for centroid in centroids:
    csqr = dot(centroid, centroid)  # done only once during shared loading
    dist = 0
    for f in range(number_of_dimensions):
        dist += sample[i] * centroid[i]
    dist = sqrt(ssqr + csqr - 2 * dist)
```
What's good is that multiplication and addition is compiled to a single
[fused multiply-add operation](https://en.wikipedia.org/wiki/Multiply%E2%80%93accumulate_operation).
Finally, we finish in 12 minutes. Not 7 as one might expect because our
bottleneck is the memory throughput.

We still can do better! There is one last powerful optimization: tuning the
block sizes, that is, the topology of the calculations. The maximum block
size is 1024 and it is optimal in case of zero shared memory usage and
no internal thread synchronization. All the previous run times were given with
that block size. But our most time consuming kernels
(that is, functions which run on GPU in CUDA terminology) use shared memory
and thus need to synchronize. Setting smaller block size for them allows
for better hardware load balancing: while some threads wait on the synchronization
barrier in one warp, they may do useful work in the other.
The best block size is normally found by experiment and equals to either
256 or 512. This brings dramatic performance improvement: down to
7 minutes and 16 seconds.

Can we do better?.. Yes we can, but not with vanilla Lloyd at this time.
Yinyang code uses much of Lloyd tweaks we suggested before, and finally
we reach the run time of 4:38. The difference between
the promised 10x improvement in the paper and the observed 1.5x has to be explained.
Because of the SIMT nature, if different threads in the same group (warp)
go by different code paths after a conditional clause, the overall run time
of the warp will be the sum of the run times of each different path.
Thus, the extensive branching inside Yinyang does not result in much
performance boost. The other reason is that we still have to run Lloyd-like
iterations from time to time in order to make Yinyang iterations perform well
and the former are slow because of extensive memory writes.

There is a way to further speed up Lloyd a little though, if we properly
align the lanes in our samples and centroids arrays. It is best to make
the number of dimensions to be dividable by 32 (512 alignment) as it
optimizes the memory bandwidth usage. Since it can be done by
padding sample coordinate vectors with zeros, we omit this optimization.
Besides, we want to fit as much data as possible because GPU memory
size is limited, and the alignment can increase it considerably.

An important notice about Yinyang is that if you have much more data than in
the benchmark, you will not be able to use it at all and have to fallback
to Lloyd unconditionally.

Final note: some of the code should run on host and OpenMP 4 (SIMD and multithreading)
is used in the corresponding places.

Development
-----------
The project is being developed in [CLion IDE](https://www.jetbrains.com/clion/).
Although it does not directly support CUDA, it is still very nice, offering
very good CMake build system integration. CMake has
[FindCUDA](https://cmake.org/cmake/help/v3.0/module/FindCUDA.html) tools
so that making a CUDA-powered project is easy.

We used good-ol' [valgrind](http://valgrind.org/) to validate host code
and `cuda-memcheck` for the GPU code. Debugging CUDA programs has become
convenient these days with the help of `cuda-gdb`. It is basically
a custom build of [gdb](https://www.gnu.org/software/gdb/) which allows
for all the usual debugging stuff as if GPU was CPU with the corresponding
number of threads. Profiling is done with `nvvp` - NVIDIA Visual Profiler.

The tests are implemented in Python and currently run manually and not included
into the project. One of the test images is shown in this article's header.

Comparison
----------
CPU: Intel Xeon E5-1650 v3 (supports AVX2, 6+6 threads).

GPU: NVIDIA Titan X (12GB, 3000 cores).

MEM: Samsung M393A2G40DB0-CPB (DDR4, 128GB).

OS: Ubuntu 16.04 x86-64.

|name             |time   |memory|
|:----------------|------:|-----:|
|[sklearn KMeans](http://scikit-learn.org/stable/modules/generated/sklearn.cluster.KMeans.html)|>3h<sup>*</sup>|4GB|
|[KMeansRex](https://github.com/michaelchughes/KMeansRex)|31m|25GB|
|kmcuda Lloyd|7m16s|1GB|
|kmcuda Yinyang|4m38s|6GB|

<sup>*</sup>We didn't wait more and stopped.
Points of improvement
---------------------

1. Further Yinyang optimization (e.g., clever sorting).
2. <s>fp16</s> - done.
3. <s>Multi-GPU</s> - done.
4. <s>Angular distance metric (aka Spherical K-Means)</s> - done.

Conclusion
----------
The developed K-means implementation is very fast on moderate data sizes
and fast on bigger sizes. Besides, it is memory efficient.
Optimizing CUDA programs is hard but fun, and
the used techniques are common and not so complicated. Yinyang algorithm is cool,
though seems to not perfectly fit into the GPU architecture. We hope that Yinyang
can be further optimized to fully demonstrate it's potential.
