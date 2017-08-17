---
author: vadim
date: 2017-03-14
title: "Jonker-Volgenant Algorithm + t-SNE = Super Powers"
draft: false
image: /post/lapjv/mapping.png
description: "t-SNE is an awesome tool to visualize high dimensional data in 2D or 3D. What if we want to turn the \"cloud of points\" into a regular image? This issue can be formulated as a Linear Assignment problem and solved efficiently and precisely with Jonker-Volgenant algorithm. To put it short: just look at the image in the beginning of this post."
categories: ["science", "technical"]
---

#### Before

![MNIST t-SNE before](/post/lapjv/mnist_before.png)

#### After

![MNIST t-SNE after](/post/lapjv/mnist_after.png)

Intrigued? Then... first things first!

## t-SNE

[t-SNE](https://lvdmaaten.github.io/tsne/) is the very popular algorithm to extremely
reduce the dimensionality of your data in order to visually present it. It is
capable of mapping hundreds of dimensions to just 2 while preserving important
data relationships, that is, when closer samples in the original space are closer
in the reduced space. t-SNE works quite well for small and moderately sized
real-world datasets and does not require much tuning of its hyperparameters.
In other words, if you've got less than 100,000 points, you will apply that magic
black box thing and get a beautiful scatter plot in return.

Here is a classic example from computer vision. There is a well known dataset
named ["MNIST"](http://yann.lecun.com/exdb/mnist/) by Yann LeCun (one of the inventors
of [Backpropagation](https://en.wikipedia.org/wiki/Backpropagation) method of
training neural networks - the core of modern deep learning) et. al. It is often
used as the default dataset for evaluating machine learning ideas and is widely
employed in academia. MNIST is 70,000 greyscale images of size 28x28.
Each is the scan of a handwritten digit \\(\\in[0, 9]\\). There is a way to obtain an
["infinite"](http://leon.bottou.org/projects/infimnist) MNIST dataset but I shouldn't
diverge.

Thus each MNIST sample contains \\(28\\cdot 28=784\\) features and can be represented
by a 784-dimensional vector. Vectors are linear and we lose the locality
relationships between individual pixels in this interpretation but it is still
helpful. If you try to imagine how our dataset looks like in 784D, you will go
nuts unless you are a trained mathematician. Ordinary humans can consume
visual information only in 3D, 2D or 1D. We may implicitly add another dimension,
time, but usually nobody says that a computer display is 3D just because it changes
the picture with 100Hz frequency. Thus it would be nice to have a way to *map*
samples in 784 dimensions to 2. Sounds impossible? It is, in the general case.
This is where [Dirichlet's box principle](https://en.wikipedia.org/wiki/Pigeonhole_principle)
works: you are doomed to have collisions, whatever mapping algorithm you choose.

{{% caption title="Shadowmatic" src="/post/lapjv/shadowmatic.jpg" %}}
3D -> 2D projection illusion in [Shadowmatic](http://www.shadowmatic.com)
{{% /caption %}}

Luckily, the following two assumptions stand:

1. The original high-dimensional space is *sparse*, that is, samples are most likely
not distributed uniformly in it.

2. We do not have to find the exact mapping, especially given the fact that it
does not exist. We can rather solve a different problem which has a guaranteed
precise solution which approximates what we would like to see. This resembles how
JPEG compression works: we never get the pixel-to-pixel identical result, but
the image looks *very* similar to its origin.

The question is, what is the best approximate problem in (2). Unfortunately,
there is no "best". The quality of dimensionality reduction is
subjective and depends on your ultimate goal. The root of the confusion is the
same as in determining the perfect clustering: it depends.

{{% caption src="/post/lapjv/sklearn.png" title="Clustering algorithms" %}}
Different clustering algorithms from [sklearn](http://scikit-learn.org/stable/auto_examples/cluster/plot_cluster_comparison.html)
{{% /caption %}}

t-SNE is one of a series of possible dimensionality reduction algorithms which are
called embedding algorithms. The core idea is to preserve the similarity relations
as much as possible. Play with it yourself:

{{% codepen slug="ayEKKj" title="lapjv" %}}

{{% center %}}
Adapted from [How to Use t-SNE Effectively](http://distill.pub/2016/misread-tsne)
{{% /center %}}

Those are artificial examples - cool but not enough. The majority of real-world
datasets resemble a cloud with local clusters. For example, MNIST looks like this:

{{% caption src="/post/lapjv/mnist_tsne.png" title="mnist_tsne" %}}
MNIST after applying t-SNE
{{% /caption %}}

We can clearly see how similar digits tend to attract each other.

## Linear Programming

Now let us make a steep turn and review what is [Linear Programming](https://en.wikipedia.org/wiki/Linear_programming) (LP).
Sorry but it's not a new design pattern, a Javascript framework or a startup. It is math:
\\begin{equation}
\\arg \\min {\\vec{c}\\cdot\\vec{x}}
\\end{equation}
\\begin{equation}
A \\cdot \\vec{x} \\leq \\vec{b}
\\end{equation}
\\begin{equation}
\\vec{x} \\geq 0
\\end{equation}
We minimize the scalar product of \\(\\vec{c}\\) and \\(\\vec{x}\\) given the set
of linear inequations depending of \\(\\vec{x}\\) and the requirement that all
its coordinates are not negative. LP is a well-studied topic in convex optimization
theory, it is known to have [weakly-polynomial](https://en.wikipedia.org/wiki/Time_complexity#Strongly_and_weakly_polynomial_time)
solutions which typically run in \\(O(n^3)\\) time where \\(n\\) is the number of variables
(problem's dimensionality). There often are approximate algorithms which run in linear time.
Those algorithms deal with matrix multiplications and can be parallelized efficiently.
A programmer's heaven!

Amazingly many problems can be tracked down to LP. For example, let's take the
[transportation problem](http://www.me.utexas.edu/~jensen/models/network/net8.html).

{{% caption src="/post/lapjv/transportation_problem.svg" title="Transportation problem" %}}
Transportation Problem: supplies and demands.
{{% /caption %}}

There is a number of different supplies and demands, which may be not equal.
Every demand needs a fixed amount of supplies. Every supply is limited and is connected
with some of the demands. The core of the problem is that every edge \\(S_ i D_ j\\)
has it's own "cost" \\(c_ {ij}\\) so we need to find the supply scheme which minimizes the
sum of those costs. Formally,
\\begin{equation}
\\arg \\min \\sum_ {i=1}^S \\sum_ {j=1}^D x_ {ij}c_ {ij}
\\end{equation}
\\begin{equation}\\label{non-negative}
x_ {ij} \\geq 0,
\\end{equation}
\\begin{equation}\\label{sum1}
\\sum_ {j=1}^D x_ {ij} \\leq w_ {S_ i},
\\end{equation}
\\begin{equation}\\label{sum2}
\\sum_ {i=1}^S x_ {ij} \\leq w_ {D_ j},
\\end{equation}
\\begin{equation}\\label{emd}
\\sum_ {i=1}^S \\sum_ {j=1}^D x_ {ij} = \\min \\left( \\sum_ {i=1}^S w_ {S_ i}, \\sum_ {j=1}^D w_ {D_ j} \\right).
\\end{equation}
The last condition means that either we run out of supplies or there is no more demand.
If \\(\\sum_ {i=1}^S w_ {S_ i} = \\sum_ {j=1}^D w_ {D_ j}\\), \\ref{emd} can be
normalized and simplified as
$$
\\sum_ {i=1}^S \\sum_ {j=1}^D x_ {ij} = \\sum_ {i=1}^S w_ {S_ i} = \\sum_ {j=1}^D w_ {D_ j} = 1.
$$
Now if we replace "supplies" and "demands" with "dirt",
\\(\\min \\sum\\limits_ {i=1}^S \\sum\\limits_ {j=1}^D x_ {ij}c_ {ij}\\) gives us
[Earth Mover's Distance](https://en.wikipedia.org/wiki/Earth_mover's_distance):
the minimal volume of work required to carry dirt from one pile distribution to
another. Next time you dig holes in the ground, you know what to do...

{{% caption src="/post/lapjv/emd.png" title="Earth Mover's Distance" %}}
Earth Mover's Distance
{{% /caption %}}

If we replace "supplies" and "demands" with "histograms", we get the most popular
way to compare images in pre-deep learning era
([example paper](https://www.cs.cmu.edu/~efros/courses/LBMV07/Papers/rubner-jcviu-00.pdf)).
It is better than naive L2 because it captures the spatial difference additionally
to the magnitudal one.

{{% caption title="EMD" src="/post/lapjv/histogram.png" %}}
Earth Mover's Distance is better than Euclidean distance for histogram comparison.
{{% /caption %}}

If we replace "supplies" and "demands" with "words", we get
[Word Mover's Distance](http://jmlr.org/proceedings/papers/v37/kusnerb15.pdf),
a good way of comparing meanings of two sentences given word embeddings from
[word2vec](https://en.wikipedia.org/wiki/Word2vec).

{{% caption src="/post/lapjv/wmd.png" title="Word Mover's Distance" %}}
Word Mover's Distance
{{% /caption %}}

If we relax the conditions \\ref{non-negative}-\\ref{emd} by throwing away \\ref{emd},
set \\(w_ {S_ i} = w_ {D_ i} = 1\\) and turn inequalities \\ref{sum1} and \\ref{sum2}
into equations by adding the symmetric negated inequalities, we get the
[Linear Assignment Problem](https://en.wikipedia.org/wiki/Assignment_problem) (LAP):
\\begin{equation}
\\arg \\min \\sum_ {i=1}^S \\sum_ {j=1}^D x_ {ij}c_ {ij}
\\end{equation}
\\begin{equation}\\label{lap-non-negative}
x_ {ij} \\geq 0,
\\end{equation}
\\begin{equation}\\label{lap-sum1}
\\sum_ {j=1}^D x_ {ij} = 1,
\\end{equation}
\\begin{equation}\\label{lap-sum2}
\\sum_ {i=1}^S x_ {ij} = 1.
\\end{equation}
Unlike in Transportation Problem, it can be proved that \\(x_ {ij}\\in\\{0, 1\\}\\) -
the solution is always binary. In other words, either the whole supply goes to
some demand, or nothing.

## t-SNE LAP
As we saw in the first section, t-SNE (or any other embedding) produces a
scatter plot. While it is perfectly suitable for dataset exploration tasks,
sometimes we need to map every sample in the original scatter plot to a node
in the regular grid. E.g. source{d} needs this mapping to... you will see why soon.

{{% caption src="/post/lapjv/grid.png" title="Regular grid" %}}
The Regular Grid
{{% /caption %}}

We can draw MNIST digits instead of dots after t-SNE, this is how it looks like:

{{% caption title="MNIST t-SNE before" src="/post/lapjv/mnist_before.png" %}}
MNIST digits after t-SNE.
{{% /caption %}}

Not very clear. This where LAP arises: we could define the cost matrix as the
pairwise euclidean distances between t-SNE samples and grid nodes, set the
grid square equal to the dataset size \\(||S||=||D||\\) and eventually solve our
problem. But how? No algorithms were presented so far.

#### Jonker-Volgenant algorithm

It turns out that there are tons of general-purpose linear optimization
algorithms, starting from the [simplex method](https://en.wikipedia.org/wiki/Simplex_algorithm)
and ending with very sophisticated solvers. Algorithms which are specialized
for the specific conditions usually converge remarkably faster, though they
may have some limitations.

[Hungarian algorithm](https://en.wikipedia.org/wiki/Hungarian_algorithm) is one
of those specialized solvers invented in 1950-s. It's complexity is \\(O(n^3)\\).
It is rather simple to understand and to implement, thus the popular choice
in a lot of projects. For example, it has recently become the part of
[scipy](https://docs.scipy.org/doc/scipy-0.18.1/reference/generated/scipy.optimize.linear_sum_assignment.html).
Unfortunately, it performs slow on bigger problem sizes; scipy's variant
is particularly **very** slow. I waited an hour for it to finish on 2500 MNIST
samples and yet Python was still digesting the victim.

[Jonker-Volgenant algorithm](https://link.springer.com/article/10.1007/BF02278710)
is an improved approach developed in 1987. It's core is still the shortest
augmenting path traversal and it's complexity is still cubic, but it uses some
smart heuristics and tricks to dramatically reduce the computational load.
The performance of many other LAP algorithms including JV was extensively
studied in [2000's Discrete Applied Mathematics paper](http://www.sciencedirect.com/science/article/pii/S0166218X99001729).
The conclusion was that:

>JV has a good and stable average performance for all the (problem - Vadim) classes,
and it is the best algorithm for the uniform random ... and for the single-depot class.

There is a caveat with the JV algorithm though. It is loosely tolerant
to the difference between any pair of cost elements in the cost matrix. For example,
if there are two very close costs appearing in the same graph where we search
for the shortest path using Dijkstra's algorithm, it can potentially loop
forever. If you take a closer look at Dijkstra's algorithm, you will eventually
discover that when it reaches the floating point precision limit, terrible
things may happen. The common workaround is to multiply the cost matrix by
some big number.

![hold yourselves](/post/lapjv/meme.jpg)

Anyway, the most exciting thing about JV for a lazy engineer like me
is that there is an existing Python 2 package
which wraps the [ancient](http://www.magiclogic.com/assignment.html) JV C implementation:
[pyLAPJV](https://github.com/hrldcpr/pyLAPJV). That C code was written
by [Roy Jonker](https://www.linkedin.com/in/roy-jonker-9a183310/) in 1996 for
MagicLogic Optimization Inc. - he is the company's president. If you read this, Roy,
please share your paper under CC-BY-something, everybody wants to read it!
Besides from being abandonware, pyLAPJV has a minor problem with the output which
I resolved in [PR #2](https://github.com/hrldcpr/pyLAPJV/pull/2).
The C code is reliable, but it does not leverage any threads or SIMD instructions.
Of course, we saw that JV is sequential in it's nature and cannot be easily
parallelized, however, I managed to speed it up 2x after optimizing the
hottest block - augmenting row reduction - with [AVX2](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions).
The result is the new Python 3 package [src-d/lapjv](https://github.com/src-d/lapjv)
which we open sourced under MIT license.

Augmenting row reduction phase at its core is finding the minimum
and the second minimum array elements. Sounds easy as it is, the unoptimized
C version takes about 20 lines of code.
AVX version is 4 times bigger: we record minimums in each lane of the
SIMD vector, perform [blending](https://software.intel.com/en-us/node/524074) and
cast other dark SIMD magic spells I learned while I was writing Samsung's
[libSoundFeatureExtraction](https://github.com/Samsung/veles.sound_feature_extraction/blob/master/TRANSFORMS.md).

```C++
template <typename idx, typename cost>
__attribute__((always_inline)) inline
std::tuple<cost, cost, idx, idx> find_umins(
    idx dim, idx i, const cost *assigncost, const cost *v) {
  cost umin = assigncost[i * dim] - v[0];
  idx j1 = 0;
  idx j2 = -1;
  cost usubmin = std::numeric_limits<cost>::max();
  for (idx j = 1; j < dim; j++) {
    cost h = assigncost[i * dim + j] - v[j];
    if (h < usubmin) {
      if (h >= umin) {
        usubmin = h;
        j2 = j;
      } else {
        usubmin = umin;
        umin = h;
        j2 = j1;
        j1 = j;
      }
    }
  }
  return std::make_tuple(umin, usubmin, j1, j2);
}
```
{{% center %}}
Finding two consecutive minimums, plain C++.
{{% /center %}}

{{% codescroll height="450" %}}
```C++
template <typename idx>
__attribute__((always_inline)) inline
std::tuple<float, float, idx, idx> find_umins(
    idx dim, idx i, const float *assigncost, const float *v) {
  __m256i idxvec = _mm256_setr_epi32(0, 1, 2, 3, 4, 5, 6, 7);
  __m256i j1vec = _mm256_set1_epi32(-1), j2vec = _mm256_set1_epi32(-1);
  __m256 uminvec = _mm256_set1_ps(std::numeric_limits<float>::max()),
         usubminvec = _mm256_set1_ps(std::numeric_limits<float>::max());
  for (idx j = 0; j < dim - 7; j += 8) {
    __m256 acvec = _mm256_loadu_ps(assigncost + i * dim + j);
    __m256 vvec = _mm256_loadu_ps(v + j);
    __m256 h = _mm256_sub_ps(acvec, vvec);
    __m256 cmp = _mm256_cmp_ps(h, uminvec, _CMP_LE_OQ);
    usubminvec = _mm256_blendv_ps(usubminvec, uminvec, cmp);
    j2vec = _mm256_blendv_epi8(
        j2vec, j1vec, reinterpret_cast<__m256i>(cmp));
    uminvec = _mm256_blendv_ps(uminvec, h, cmp);
    j1vec = _mm256_blendv_epi8(
        j1vec, idxvec, reinterpret_cast<__m256i>(cmp));
    cmp = _mm256_andnot_ps(cmp, _mm256_cmp_ps(h, usubminvec, _CMP_LT_OQ));
    usubminvec = _mm256_blendv_ps(usubminvec, h, cmp);
    j2vec = _mm256_blendv_epi8(
        j2vec, idxvec, reinterpret_cast<__m256i>(cmp));
    idxvec = _mm256_add_epi32(idxvec, _mm256_set1_epi32(8));
  }
  float uminmem[8], usubminmem[8];
  int32_t j1mem[8], j2mem[8];
  _mm256_storeu_ps(uminmem, uminvec);
  _mm256_storeu_ps(usubminmem, usubminvec);
  _mm256_storeu_si256(reinterpret_cast<__m256i*>(j1mem), j1vec);
  _mm256_storeu_si256(reinterpret_cast<__m256i*>(j2mem), j2vec);

  idx j1 = -1, j2 = -1;
  float umin = std::numeric_limits<float>::max(),
        usubmin = std::numeric_limits<float>::max();
  for (int vi = 0; vi < 8; vi++) {
    float h = uminmem[vi];
    if (h < usubmin) {
      idx jnew = j1mem[vi];
      if (h >= umin) {
        usubmin = h;
        j2 = jnew;
      } else {
        usubmin = umin;
        umin = h;
        j2 = j1;
        j1 = jnew;
      }
    }
  }
  for (int vi = 0; vi < 8; vi++) {
    float h = usubminmem[vi];
    if (h < usubmin) {
      usubmin = h;
      j2 = j2mem[vi];
    }
  }
  for (idx j = dim & 0xFFFFFFF8u; j < dim; j++) {
    float h = assigncost[i * dim + j] - v[j];
    if (h < usubmin) {
      if (h >= umin) {
        usubmin = h;
        j2 = j;
      } else {
        usubmin = umin;
        umin = h;
        j2 = j1;
        j1 = j;
      }
    }
  }
  return std::make_tuple(umin, usubmin, j1, j2);
}
```
{{% /codescroll %}}

{{% center %}}
Finding two consecutive minimums, optimized code with AVX2 intrinsics.
{{% /center %}}

lapjv maps 2500 MNIST samples in 5 seconds on my laptop and finally we see the
precious result:

{{% caption src="/post/lapjv/mapping.png" title="mapping" %}}
Linear Assignment Problem solution for MNIST after t-SNE.
{{% /caption %}}

#### Notebook

I used the following [Jupyter](http://jupyter.org/) notebook
([link](https://gist.github.com/vmarkovtsev/74e3a973b19113047fdb6b252d741b42))
to prepare this post:

{{% gist vmarkovtsev "74e3a973b19113047fdb6b252d741b42" %}}

## Conclusion

There is an efficient way to map t-SNE-embedded samples to the regular grid.
It is based on solving the Linear Assignment problem using Jonker-Volgenant
algorithm implemented in [src-d/lapjv](https://github.com/src-d/lapjv). This
algorithm scales up to 10,000 samples.

