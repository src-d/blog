---
author: vadim
date: 2016-11-24
title: "Weighted MinHash on GPU helps to find duplicate GitHub repositories."
draft: false
image: /post/minhashcuda/benders.jpg
description: "We describe how we filtered very similar GitHub repositories using our new open source project MinHashCuda."
categories: ["science", "technical"]
---
The codez: [GitHub](https://github.com/src-d/minhashcuda).

![benders](/post/minhashcuda/benders.jpg)

While doing topic modeling of GitHub repositories, to which we dedicated the recent article
[Topic Modeling of GitHub Repositories](http://blog.sourced.tech/post/github_topic_modeling/),
we gradually realized that our dataset should be filtered to achieve better results.
Particularly, we should throw away "extreme forks", the Large Unidentified
<span style="text-decoration: line-through;">Flying</span> Copy-Pasted
Codebases. The typical example of such LUCPCs are web site engines, e.g.
many people copy Wordpress into their repository and build their open-source blogs.
Numerous github.io sites are the same copy-pasted examples. Folks
like to learn web programming from books or online manuals copy-pasting the
sample boilerplates. We are not saying it is wrong; sometimes it is even inevitable,
sometimes [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
seem a bigger evil in spite of all GitHub's efforts to support them. Such duplicates
are bad for specifically topic modeling since a lot of "garbage" bags are introduced.

We are working with repositories using the bag-of-names model, which treats
each codebase as a sparse vector. The number of dimensions equals to the number
of unique names occurring in all the source code we've got, the values are equal
to the corresponding [TF-IDF](https://en.wikipedia.org/wiki/Tf%E2%80%93idf)-s
(the derivatives from frequencies). Names are extracted using the source highlight
library [pygments](http://pygments.org/), and additionally refined with several tricky heuristics. For example,
consider the following Python snippet:

```python
class WebServer(ServerBase):
  def route(self, path):
    raise NotImplementedError()
```

It is transformed into

```python
{"web": 1, "server": 2, "base": 1, "route": 1, "path": 1}
```

Then we apply frequency filtering, TF-IDF, stemming, etc.

We expect the resulting sparse vectors for duplicate repositories to be
nearly the same. Of course, some files may contain minor edits and we cannot seek
for the exact same bag-of-names; we have to make up something smarter. The problem which
we've just stated is by no means unique: many Natural Language Processing
tasks involve the same challenges. Let's revise the common approach: thresholding
by [Jaccard Similarity](https://en.wikipedia.org/wiki/Jaccard_index).

Theory
------

### MinHash

Imagine that we have two sets (in mathematical sense) - \\(A\\) and \\(B\\). The Jaccard Similarity
Measure reflects the extent to which our two sets are similar to each other.
\\[J=\\frac{\\left|A \\cap B\\right|}{\\left|A \\cup B\\right|}\\]
That is, the power of the set intersection divided by the power of set union. The idea
is to calculate pairwise \\(J\\) matrix for all our samples, treat it as a
mutual similarity graph's [incidence matrix](https://en.wikipedia.org/wiki/Incidence_matrix)
and then pick the [cliques](https://en.wikipedia.org/wiki/Clique) which have each
edges weight above the fixed threshold. There is the problem: we've got too many
samples, more than 10 million and we cannot calculate a 10Mx10M matrix in any
observable future. Luckily for us there is a nice solution to that problem: [MinHash
algorithm](https://en.wikipedia.org/wiki/MinHash).

There are several modifications of MinHash-ing, they are basically equivalent to each other.
Let's consider the easiest one. We randomly permute the elements of the union of all sets,
and enumerate them. We pick the minimum index throughout contained elements for every set.
We repeat this procedure multiple times, and take the average of the indices, \\(h\\).
We call \\(h\\) "MinHash", it is indeed a hash function, but unlike other hashes, it is
[consistent](https://en.wikipedia.org/wiki/Consistent_hashing): similar
items tend to yield near hash values. The difference between two MinHash values
can be proved to approximate the Jaccard Similarity. There is a good blog post
which explains how to apply the MinHash algorithm to find duplicates:
[On removing duplicates from a set of documents](http://stevehanov.ca/blog/index.php?id=144).
Basically, we sort all the hash values and scan them using the window of the size
which is specially tailored for the tolerated level of false-positives.
MinHash has an awesome property: there are always no false-negatives, so
we end up with the same result which we would end up in 10Mx10M brute force.

### Weighted MinHash

Things change when you've got a dictionary instead of a set: the keys are still
unique and values are non-negative "weights" of the corresponding keys. The Jaccard Similarity
between dictionaries \\(A=\\{i: a_ i\\}, i\\in I\\) and \\(B=\\{j: b_ j\\}, j\\in J\\) is defined as
\\[J=\\frac{\\sum_ {k\\in K}\\limits \\min(a_ k, b_ k)}{\\sum_ {k\\in K}\\limits \\max(a_k, b_k)}, K=I\\cup J\\]
where \\(a_k = 0, k\\notin I\\) and \\(b_k = 0, k\\notin J\\). If the weights are
binary, this formula is equivalent to the common Jaccard Similarity definition.

The corresponding hashing method for the Weighted Jaccard Similarity is named
"Weighted MinHash" and described in detail in [Sergey Ioffe's article](http://static.googleusercontent.com/media/research.google.com/en//pubs/archive/36928.pdf).
His proposed algorithm depends on the parameter \\(K\\) which adjusts the
resulting hash length.

* for \\(k\\) in range(\\(K\\)):
  1. Sample \\(r_ k, c_ k ∼ Gamma(2, 1)\\) (their PDF is \\(P( r)=re^{-r}\\)), and
     \\(\\beta_ k ∼ Uniform(0, 1)\\).
  2. Compute
  $$
  \\begin{align}
  t_ k &= \\lfloor \\frac{\\ln S_ k}{r_ k} + \\beta_ k\\rfloor \\\\\\\\
  y_ k &= e^{r_ k(t_ k - \\beta_ k)} \\\\\\\\
  z_ k &= y_ k e^{r_ k} \\\\\\\\
  a_ k &= \\frac{c_ k}{z_ k}
  \\end{align}
  $$
* Find \\(k^\* = \\arg\\!\\min_ k a_ k\\) and return the samples \\((k^\*, t_ {k^\*})\\).

Thus given \\(K\\) and supposing that the integers are 32-bit we obtain the hash
with size \\(8K\\) bytes. [\\(Gamma(2, 1)\\) distribution](https://en.wikipedia.org/wiki/Gamma_distribution)
can be efficiently calculated as \\(r = −\\ln(u_ 1 u_ 2)\\) where \\(u_ 1, u_ 2 ∼ Uniform(0, 1)\\).

Having calculated all the hashes in the dataset, we can then conduct
[local sensitive hashing](https://en.wikipedia.org/wiki/Locality-sensitive_hashing),
an algorithm from [Chapter 3, Mining of Massive Datasets](http://infolab.stanford.edu/~ullman/mmds/ch3.pdf).
Briefly, we define several hash tables, each for it's own subhash, depending on
the target level of false positives. Same elements will appear in the same bucket;
union of the bucket sets across all the hash tables for a specific sample
yields all the similar samples. If we'd like to determine the sets of mutually
similar samples a.k.a. [cliques](https://en.wikipedia.org/wiki/Clique), we should
consider the set intersection instead.

### MinHashCuda

The LSH algorithm is actually pretty fast by design, does not require much memory
and works perfectly, even when implemented in Python ([datasketch](https://github.com/ekzhu/datasketch)),
whereas calculation of the hashes themselves is resource consuming. We've
developed an efficient Weighted MinHash calculation library [MinHashCuda](https://github.com/src-d/minhashcuda).
It allows to offload the heavy-lifting to the GPU(s).

MinHashCuda has two interfaces, C and Python, much like [kmcuda](https://github.com/src-d/kmcuda),
and actually borrowed quite a lot of boilerplate code from kmcuda. I will use the Python API
throughout this section. Suppose that we've got out dataset in the
[compressed sparse row](https://en.wikipedia.org/wiki/Sparse_matrix#Compressed_sparse_row_.28CSR.2C_CRS_or_Yale_format.29)
format, particularly [`scipy.sparse.csr_matrix`](https://docs.scipy.org/doc/scipy-0.18.1/reference/generated/scipy.sparse.csr_matrix.html).
In order to feed it to MinHashCuda, first you must initialize the hasher object:

```python
import libMHCUDA
# m is our scipy.sparse.csr_matrix
# m.shape[-1] is the dimensionality - number of distinct elements in the weighted sets
hasher = libMHCUDA.minhash_cuda_init(m.shape[-1], 128, seed=1, verbosity=1)
```

Internally, it will leverage [cuRAND](http://docs.nvidia.com/cuda/curand/#axzz4QqWj1Cak),
NVIDIA's stock random generation library, to generate \\(r\\), \\(c\\) and \\(\\beta\\).
If the precious GPU memory fits those arrays, then you may move along to the hash
calculation, otherwise some dimensionality reduction is needed. For example,
the Titan X 2016 has 12GB GDDR5X, so the theoretical limit is \\(\\frac{12*10^9}{3\\cdot sizeof(float)} = 10^9\\)
dimensions. Of course, there must be some room for the samples, so practically
the maximum dimensionality is about 500 million.

Next, we calculate the hashes. Depending on whether the whole matrix fits into
the memory, there are two options:

```python
# fits
hashes = libMHCUDA.minhash_cuda_calc(hasher, m)

# does not fit
hashes = []
for i in range(0, m.shape[0], chunk):
  hashes.append(libMHCUDA.minhash_cuda_calc(hasher, m, row_start=i, row_finish=i + chunk))
hashes = numpy.vstack(hashes)
```

In the latter case, we avoid using `m[i:i + chunk]` because it creates the new
matrix and introduces much overhead.

Finally, we free all the allocated resources:

```python
libMHCUDA.minhash_cuda_fini(hasher)
```

### Performance

As usual, CUDA kernel performance dramatically varies depending on the chosen
parallelization scheme, occupancy and the benevolence of the evil overlords.
I had to rewrite it several times until I reached a satisfying result.

The naive method of parallelization would be to assign rows to threads on
the equivalent basis: each thread takes a row, enters the argmin loop and
finally writes the whole hash. There are several problems with this approach:

1. Sparse rows may be severely unbalanced, e.g. one consists of 10 elements and the other has 100000.
CUDA is [SIMT](https://en.wikipedia.org/wiki/Single_instruction,_multiple_threads) and the performance is going to suffer.
2. There is no caching, every iteration includes reading the whole row and reading the corresponding
random values.

The solution to (1) is to split the incoming matrix into row intervals with
roughly the same number of *elements*, not *rows*. (2) is solved by
caching the partial minimum \\(a_ k\\) and \\((k^\*, t_ {k^\*})\\) into the
shared memory, so that the row's elements are read only once. There is no
ability to accurately cache the random values as well because different rows refer to
arbitrary different column indices. Apart from solving (1) and (2), I had the special
pleasure to implement multiple GPUs support.

(1) appeared to be harder than it seems. The point is, (2) sets the limit on the
maximum amount of shared memory per block, so the maximum number of elements
consumed by each thread is upper bounded. We end up with a discrete optimization
problem. It resembles [bin packing](https://en.wikipedia.org/wiki/Bin_packing_problem),
but instead of minimizing the number of bins, it focuses on the overall equal
load and grouping the bins by CUDA blocks. Here is my solution:

![bins](/post/minhashcuda/bins.png)
<p align="center">Balancing the GPU load.</p>

1. Obtain a rough estimate of the number of elements per block, knowing the
shared memory limit and thriving to distribute some fixed number of elements per thread.
It approximates the number of CUDA blocks and the overall number of threads \\(T\\)
since the CUDA block size is constant. This takes a constant time.
2. Sort the rows by the length - \\(O(R\\log R)\\).
3. Greedily distribute the rows to the threads, starting from the biggest and
finishing with the smallest. The row which is loaded the lowest receives the row.
To efficiently implement this, we maintain the
[priority queue](https://en.wikipedia.org/wiki/Priority_queue#Usual_implementation),
getting \\(O(R\\log T)\\) complexity.
4. Sort the threads according to the final load. It takes \\(O(T\\log T)\\).
5. Split the threads sequence by blocks. Step (4) guarantees the minimum possible
imbalance.

The overall complexity is thus \\(O(R(\\log R + \\log T) + T\\log T) = O(R \\log R)\\)
since \\(T ∼ R\\).

I hit the problems with the low [kernel occupancy](http://developer.download.nvidia.com/compute/cuda/CUDA_Occupancy_calculator.xls).
The used number of registers was too high. I managed to dramatically reduce the register pressure applying
[the volatile trick](http://blog.icare3d.org/2010/04/cuda-volatile-trick.html).

### Battle tested

We successfully applied [MinHashCuda](https://github.com/src-d/minhashcuda) to find duplicate repositories on GitHub.
The size of our dataset was initially 13.6 million but later was filtered down to 9.6 million.
To be precise, the matrix was 9624276 x 2422260 with the sparsity 0.00014, which
is roughly equivalent to 9624276 x 340. We ran the hash calculation on two Titan Xs
(Maxwell), it took 40 minutes. According to my estimation, the achieved speed is
600 times faster than the implementation in `datasketch` using 12 CPU
cores with [Intel's MKL](https://en.wikipedia.org/wiki/Math_Kernel_Library).

The result after LSH with a similarity threshold of 0.9 was about 467,000 duplicate groups with 1.66 million repositories.
110,000 repositories appeared to be \*.github.io. Here are the examples:

```
Mange/rtl8192eu-linux-driver
donahue95/rtl8192eu-linux-driver
```

```
dcarbajosa/linuxacademy-chef
jachinh/linuxacademy-chef
flarotag/linuxacademy-chef
qhawk/linuxacademy-chef
paul-e-allen/linuxacademy-chef
```

```
choysama/my-django-first-blog
mihuie/django-first
PubMahesh/my-first-django-app
nickmalhotra/first-django-blog
Jmeggesto/MyFirstDjango
atlwendy/django-first
susancodes/first-django-app
quipper7/DjangoFirstProject
phidang/first-django-blog
```

The complete dataset is published on [data.world](https://data.world/vmarkovtsev/github-duplicate-repositories).

<script async src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_CHTML"></script>
