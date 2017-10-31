---
author: vadim
date: 2017-01-30
title: "GitHub Contributions Graph: Analyzing PageRank & Proving The 6 Handshakes Theory"
image: /post/handshakes_pagerank/armin_ronacher_2.png
description: "Contributions to open source projects form a graph. We prove the theory of 6 handshakes and calculate PageRank centrality measure for every node. The data is open, you can reproduce the results yourself!"
categories: ["science", "technical"]
---

source{d} has recently published a dataset with metadata on 462,000,000 commits:
[data.world](https://data.world/vmarkovtsev/452-m-commits-on-github). It allows
you to build the contributions graph. For example, these are the neighbors
around [Armin Ronacher](https://github.com/mitsuhiko):

![Armin Ronacher's neighbors](/post/handshakes_pagerank/armin_ronacher_2.png)
<p align="center" class="caption">Neighbors around Armin Ronacher, 2 generations -
the repositories he contributed to and their contributors. Armin is
in the center. 8k nodes, 11k edges. The graph was produced with [Gephi](https://gephi.org/).</p>

The fans on the above image are communities around some popular open source projects,
e.g. [rust-lang/rust](https://github.com/rust-lang/rust) on the bottom.

![Armin Ronacher's neighbors](/post/handshakes_pagerank/armin_ronacher_3.png)
<p align="center" class="caption">Neighbors around Armin Ronacher, 3 generations.
Armin is again somewhere in the center. 200k nodes, 300k edges.</p>

These are the neighbors around [Rob Pike](https://en.wikipedia.org/wiki/Rob_Pike):

![Rob Pike's neighbors zoomed](/post/handshakes_pagerank/neighbors_rob_pike_zoom.png)
<p align="center" class="caption">Neighbors around Rob Pike, 3 generations, zoomed center region.
Nodes are highlighted with the heatmap tool to reflect the distance from Rob. Hubs:
upper-left: [golang/go](https://github.com/golang/go)<sup>*</sup>,
upper-right: [onef9day/gowiki](https://gtihub.com/onef9day/gowiki),
lower-left: [cmars/oo](https://github.com/cmars/oo),
lower-right: [cmars/tools](https://github.com/cmars/tools).
</p>

![Rob Pike's children](/post/handshakes_pagerank/children_rob_pike.png)
<p align="center" class="caption">Schematic abstraction of the previous graph. Edge weights
are the number of commits.</p>

Actually, Rob Pike has never contributed to [cmars/oo](https://github.com/cmars/oo) and
[cmars/tools](https://github.com/cmars/tools). The owner of those repos must have used
`git filter-branch` or something similar to forge the history. This is why
it is so hard to distinguish the real contributions in Git world!

#### Adjacency Matrix

The contributions graph is [bipartite](https://en.wikipedia.org/wiki/Bipartite_graph)
and is represented by an extremely sparse adjacency matrix:

![Adjacency matrix](/post/handshakes_pagerank/adj_matrix_optimized.svg)
<p align="center" class="caption">The square adjacency matrix of the contributions graph.
C<sub>ij</sub> is the number of commits done by developer i to repository j;
C<sub>ij</sub> = C<sub>ji</sub>.</p>

I continue mining the October 2016 snapshot, at that time the matrix was about
23 million by 23 million and contained 48 million non-zero elements. Of course,
these numbers are approximate - we depend on our identity matching here. The identity
matching is the way to merge several email addresses into a single personality
and it is not an easy task because we have to make assumptions.
The public dataset has hashes instead of email addresses so it is impossible
to perform the identity matching on that data. You can download the graph
[here](https://drive.google.com/file/d/0B-w8jGUJto0ibVI3QUVBdXJnN1E).
It is a pickled `scipy.sparse.csr_matrix`, the following Python code loads it:

```python
import pickle
with open("graph_blog_post.pickle", "rb") as fin:
    graph, repos = pickle.load(fin)
ndevs = graph.shape[0] - len(repos)
print(repr(graph))
print("Number of developers:", ndevs)
print("Number of repositories:", len(repos))
inv_repos = {r: i + ndevs for i, r in enumerate(repos)}
name = "src-d/go-git"
print("Repository %s has %d contributors, %d commits" % (
    name, len(graph[inv_repos[name]].indices), graph[inv_repos[name]].sum()
))
```
```
<23223056x23223056 sparse matrix of type '<class 'numpy.float32'>'
	with 47866516 stored elements in Compressed Sparse Row format>
Number of developers: 6621684
Number of repositories: 16601372
Repository src-d/go-git has 14 contributors, 169 commits
```

We ship only the second part of the matrix index, the repository name → index mapping.
Please note the following:

1. We were unable to process some large repositories back in October. Particularly,
about 20% of the most highly rated ones. That is, unfortunately, there is no data for
`git/git`, `torvalds/linux`, `rails/rails`, etc.
2. Some secondary repositories were confused with the main ones. E.g. there is no
`golang/go` but rather some random `4ad/go`. That was a bug we're now fixing.
3. Initially we had 18M repos, but filtered 1.5M duplicates not marked as forks;
read [this blog post](/post/minhashcuda/) how.

Let's conduct two funny experiments with our graph:

The Handshake Theory
--------------------
![Big Bang Handshake](/post/handshakes_pagerank/bbth.jpg)

The six handshakes theory, or [Six degrees of separation](https://en.wikipedia.org/wiki/Six_degrees_of_separation),
states that everybody in the world can reach out everybody else using the chain
of sequentially familiar people of the size smaller than or equal to 6.
Supposing that you know all the people who contributed to the same projects
you contributed yourself, we can accept or reject this assumption on GitHub
contributions graph.

The plan will be as follows.

1. Find all the [connected components](https://en.wikipedia.org/wiki/Connected_component_(graph_theory))
of the graph.

2. Pick the core component, or simply "the core". Calculate the size of the
[representative sample](https://en.wikipedia.org/wiki/Sampling_(statistics))
of the pairs of nodes.

3. Calculate the distances between sampled node pairs.

4. Plot the histogram, draw the conclusion.

We need to determine the connected components because it is impossible to
find a path between nodes lying in different components and every shortest
path algorithm has to scan all the nodes before returning the negative result.
We've got 23M dots, remember.

#### Connected components
While our graph is directed, every edge has the corresponding backward edge of
the same weight, so the weak connectivity automatically means strong connectivity.
In other words, we do not need to apply complex algorithms designed to find
the strongly connected components, but rather conduct the series of
[graph traversals](https://en.wikipedia.org/wiki/Graph_traversal).
For example, the following code works:

```python
def RFS(v_start):
    visited = set()
    pending = {v_start}
    while pending:
        v = pending.pop()
        visited.add(v)
        if len(visited) % 500000 == 0:
            print(len(visited))
        for i in range(graph.indptr[v], graph.indptr[v + 1]):
            nv = graph.indices[i]
            if nv not in visited:
                pending.add(nv)
    return visited

unvisited = set(range(graph.shape[0]))
components = []
while unvisited:
    v = unvisited.pop()
    c = RFS(v)
    components.append(c)
    if len(components) % 100000 == 0:
        print(len(components))
    unvisited -= c
print("Number of connected components:", len(components))
clens = list(sorted((len(c) for c in components), reverse=True))
print(clens[:10])
```

The traversal algorithm is neither depth-first nor breadth-first. It is
random-first as Python's `set` is an unordered container. Random-first traversal
is sufficient for our task of visiting every connected vertex once and is faster.
It takes about 5 minutes to execute. The result is:

```
Number of connected components: 3430141
[10200912, 10229, 8456, 2917, 2910, 2614, 2612, 2604, 2576, 2139]
```

We've the clear core with 10M nodes! How many developers are in it?

```python
c0 = components[0]
core_devs = [m for m in c0 if m < ndevs]
print(len(core_devs))
```
```
2153559
```

That is, the "contributional active" GitHub users are 2.2M or 33% or ⅓ of the
whole users we analysed, here we analysed about 73% of all the users
who made at least 1 commit, and the official number of users
[is reported](https://www.quora.com/How-many-users-does-GitHub-have/answer/Mahmoud-Zalt)
to be 20M (including users without any commits). Thus the final ratio is **11%**.

#### Representative sample
We need to determine how many distances between random nodes in the core must
be evaluated to achieve a statistically significant distribution. Let's
find a rough estimate. The number of possible distance pairs between the
core developers is \\(\\frac{N_ {core} (N_ {core} - 1)}{2}\\).

```python
print("Number of possible pairs:", len(core_devs) * (len(core_devs) - 1) / 2)
```
```
Number of possible pairs: 2318907106461
```

Now we should use the special calculator to find out the size of the
representative sample from 2.3 trillion. For example,
[checkmarket.com](https://www.checkmarket.com/sample-size-calculator/). We set
the population size to 2318907106461, the margin of error to 1% and the confidence level
to 95% and see roughly 10,000. Not bad! This is how to sample 10k random
vertices:

```python
samples = numpy.random.choice(core_devs, 10000 * 2, replace=False).reshape((10000, 2))
```

#### Distances calculation
There are many shortest path algorithms out there. I can recall the following three
from scratch:

1. [Floyd–Warshall](https://en.wikipedia.org/wiki/Floyd%E2%80%93Warshall_algorithm)
allows to calculate the distances from everybody to everybody but has a tiny
drawback - it works in O(V<sup>3</sup>) time and eats O(V<sup>2</sup>) memory.
We cannot afford ourselves to store 23M × 23M = 5e14 elements (2 PB) and wait
several years.

2. Good ol' [Dijkstra](https://en.wikipedia.org/wiki/Dijkstra's_algorithm) allows
to find all the shortest distances from one fixed node to all the rest in
O(|E| + |V|log|V|) time and O(|V|) space. It works but it is not efficient on
our graph. The problem is with the "generational explosion", each next
node generation is exponentially larger than the previous one, so Dijkstra's
algorithm ends up with inspecting almost all the nodes every time.

3. [Bidirectional search](https://en.wikipedia.org/wiki/Bidirectional_search)
spreads simultaneous waves from the both nodes and suits our task best since
this algorithm is less sensitive to the "generational explosion".

Here is the code I used. It leverages the `multiprocessing` package to calculate
many shortest paths in parallel.

```python
def path_length(first, second):
    visited_first_set = set()
    visited_second_set = set()
    visited_first_paths = {}
    visited_second_paths = {}
    pending_first = [(first, 0)]    
    pending_second = [(second, 0)]
    pending_first_set = {first}
    pending_second_set = {second}
    pmax = graph.shape[0]
    path = pmax

    # Breadth-first search single step
    def step(visited_set, visited_paths, pending, pending_set):
        v, p = pending.pop(0)
        pending_set.remove(v)
        visited_set.add(v)
        visited_paths[v] = p
        for i in range(graph.indptr[v], graph.indptr[v + 1]):
            nv = graph.indices[i]
            if nv not in visited_set and nv not in pending_set:
                pending.append((nv, p + 1))
                pending_set.add(nv)

    while (path == pmax) and (pending_first or pending_second):
        if pending_first:
            step(visited_first_set, visited_first_paths, pending_first, pending_first_set)
        if pending_second:
            step(visited_second_set, visited_second_paths, pending_second, pending_second_set)
        isect = visited_first_set.intersection(visited_second_set)
        for v in isect:
            p = visited_first_paths[v] + visited_second_paths[v]
            path = min(path, p)
    return path / 2

from multiprocessing import Pool
with Pool() as p:
    paths = p.starmap(path_length, samples)
```

The script took less than 10 minutes to finish on our 32-core machine with 256 gigs of RAM.
Each process takes less than 4GB of RAM which means 32 processes need less than 128GB.

We divide each path by 2 because the nodes corresponding to repositories should
not be taken into account in the shortest path's size calculation.

#### The histogram
![Histogram](/post/handshakes_pagerank/histogram.png)

85% of the core is less than or equal to 6 handshakes from each other. The
average is 4.9, the maximum is 18. The average is close to what Facebook had
in 2011. ∎

GitHub PageRank
---------------
![Google](/post/handshakes_pagerank/Google.png)
As soon as we have the contributions graph, we want to find out whose GitHub is
bigger. The natural way of doing this is to calculate some
[centrality measure](https://en.wikipedia.org/wiki/Centrality). We decided to
study eigenvector centralities which make nodes important if they are referenced
by other important nodes.

![PageRank graph](pagerank_visio_optimized.svg)
<p align="center" class="caption">Armin Ronacher's contributions, simplified PageRank version.</p>

$$
x_ {AR} = \frac{w_ 1 x_ 1 + w_ 2 x_ 2 + w_ 3 x_ 3 + ...}{\\lambda} = \\frac{1}{\\lambda} \\sum w_ i x_ i
$$

\\(w_ i\\) depend on the impact to the project or to the ratio of the developer's
efforts. If our adjacency matrix contained strictly positive elements
(everybody is connected to everybody) then by [Perron–Frobenius theorem](https://en.wikipedia.org/wiki/Perron%E2%80%93Frobenius_theorem)
\\(\\vec{x}\\) is the eigenvector of this matrix which corresponds to the greatest eigenvalue.
Moreover, if the matrix is stochastic, that is, the sum of values in every column
equals to 1, \\(\\lambda=1\\). The greatest eigenvalue and the corresponding
eigenvector can be found by various efficient methods such as
[power iteration](https://en.wikipedia.org/wiki/Power_iteration) or
[Arnoldi iteration](https://en.wikipedia.org/wiki/Arnoldi_iteration).

Unfortunately, this is not applicable to our case: we've got a sparse
matrix with a lot of zeros. Practically speaking, the greatest eigenvalue corresponds
to an eigenvector with negative elements. We need to do something. Luckily,
we are not the only ones who hit this problem. So did Larry and Sergey back in
1998. They studied the similar adjacency matrix of WWW pages. Each element
\\(C_ {ij}\\) is 1 if page i links to page j and 0 otherwise. Larry and Sergey
found the nice trick to make the adjacency matrix well-conditioned and suitable
for * iteration methods which they called PageRank.

There is a good explanation of PageRank in [Stanford's CS246](http://snap.stanford.edu/class/cs246-2013/slides/09-pagerank.pdf).
I am not going to repeat it but rather briefly describe how the trick applies to
our centrality problem using the terms from CS246.

1. We normalize each column to 1: \\(\\displaystyle \\sum_ i{C_ {ij}} = 1\\).
Now the matrix is not symmetric and \\(C_ {ij} \\neq C_ {ji}\\), however, it
becomes stochastic.
2. We multiply all the elements by \\(\\beta\\) and add \\(\\frac{1-\\beta}{N} E\\)
where \\(E\\) is N by N matrix filled with 1 (not the identity matrix!).
\\(\\beta\\) is the so-called dampening or random walk factor and can be set to 0.85.
Our matrix becomes acyclic and irreducible, aka the Google matrix.
3. We run power iteration and find PageRank values for every node.

#### Normalization
The following code performs the L1 normalization.
```python
norms = 1 / numpy.asarray(graph.sum(axis=1)).ravel()
from scipy.sparse import diags
graph_normed = H = graph.dot(diags(norms, format="csc"))
```
Here is what happens:
$$
norms_ i = \\frac{1}{\\sum\\limits_ j C_ {ij}}
$$
 \\
$$
diags = \\left( \\begin{array}{cccc}
norms_ 0 & 0 & ... & 0 \\\\\\
0 & norms_ 1 & ... & 0 \\\\\\
... & ... & \\ddots & ... \\\\\\
0 & 0 & ... & norms_ {N-1} \\end{array} \\right) \\\\\\
$$
 \\
$$
H=\\left( \\begin{array}{cccc}
C_ {0,0} & C_ {0,1} & ... & C_ {0,N-1} \\\\\\
C_ {1,0} & C_ {1,1} & ... & C_ {1,N-1} \\\\\\
... & ... & \\ddots & ... \\\\\\
C_ {N-1,0} & C_ {N-1,1} & ... & C_ {N-1,N-1} \\end{array} \\right)\\times diags=
$$
$$
=\\left( \\begin{array}{cccc}
\\frac{C_ {0,0}}{norms_ 0} & \\frac{C_ {0,1}}{norms_ 1} & ... & \\frac{C_ {0,N-1}}{norms_ {N-1}} \\\\\\
\\frac{C_ {1,0}}{norms_ 0} & \\frac{C_ {1,1}}{norms_ 1} & ... & \\frac{C_ {1,N-1}}{norms_ {N-1}} \\\\\\
... & ... & \\ddots & ... \\\\\\
\\frac{C_ {N-1,0}}{norms_ 0} & \\frac{C_ {N-1,1}}{norms_ 1} & ... & \\frac{C_ {N-1,N-1}}{norms_ {N-1}} \\end{array} \\right)
$$
`scipy.sparse` API makes the diagonal matrix multiplication the only way to normalize the columns.

#### The Google matrix
$$
G = \\beta H + \\frac{1-\\beta}{N}\\left( \\begin{array}{cccc}
1 & 1 & ... & 1 \\\\\\
1 & 1 & ... & 1 \\\\\\
... & ... & \\ddots & ... \\\\\\
1 & 1 & ... & 1 \\end{array} \\right)
$$
We are not going to ever calculate it explicitly because that would involve storing
N × N elements! Instead, we will create a custom power iteration algorithm.

#### Power iteration
The idea of the power iteration method is dead simple: if we want to find
the vector \\(\\vec{x}\\) such that \\(G\\cdot \\vec{x} = \\vec{x}\\) then
we repeat the same matrix multiplication until the convergence:
$$
x_ {i+1} = G\\cdot x_ i
$$
Provided that the matrix is well-conditioned, the convergence is guaranteed.
Here is the code which calculates \\(\\vec{x}\\).
```python
def page_rank(m, beta=0.85, niter=80):
    N = m.shape[0]
    x = numpy.ones(N, dtype=numpy.float32) / N
    for i in range(niter):
        x_next = m.dot(x) * beta
        x_next += (1 - beta) / N  # ***
        xdiff = numpy.linalg.norm(x - x_next, ord=1)
        x = x_next
        print("iter #%d: %f" % (i + 1, xdiff))
        if i % 10 == 0:
            print(x)
    return x

page_rank(graph_normed)
```
`# ***` every edge has the opposite one, so there are no "dead ends". Otherwise,
we would have to replace `beta` with `x_next.sum()`.

`page_rank()` executes fast and the result is returned within a minute.

#### Who is the most important on GitHub?

[Ryan Baumann aka ryanfb](https://github.com/ryanfb)! He is eventually a good
example how to study how GitHub's cache works (spoiler: it invalidates
after some time).

![Unicorn](/post/handshakes_pagerank/unicorn.png)
<p align="center" class="caption">github.com/ryanfb takes several seconds to be generated.</p>

![ryanfb's contributions](/post/handshakes_pagerank/ryanfb.png)
<p align="center" class="caption">Ryan knows what it means to be productive.</p>

I am joking, of course. Although he is on the top, he is actually the living
illustration of the weaknesses PageRank algorithm has. There used to be days
when Ryan created 1,000 repositories and of course he is not a super human -
they were automatically generated. Yet he got *many* incoming links and PageRank
rated him the highest.

![Pepperidge Farm Remembers](/post/handshakes_pagerank/pepperidge.jpg)

The essential move would be to ignore repositories with a single contributor,
and that definitely helps, though other fun effects still reflect the light.
After all, only the ratio of PageRank-s makes sense. For example, after the
mono repository filtering, Armin Ronacher has 8.0e-6, our CTO
[Maximo Cuadros](https://github.com/mcuadros) has 2.6e-6 and I have 1.6e-6.

#### What is the most important on GitHub?

Here is the descending top 200:

<ol id="repo-list">
<li><a href="https://github.com/bmorganatlas2/firstrepo">bmorganatlas2/firstrepo</a></li>
<li><a href="https://github.com/nguyendtu/patchwork">nguyendtu/patchwork</a></li>
<li><a href="https://github.com/bmorganatlas/fusiontest5">bmorganatlas/fusiontest5</a></li>
<li><a href="https://github.com/coeligena/homebrew-customized-copy">coeligena/homebrew-customized-copy</a></li>
<li><a href="https://github.com/KenStanley/reflections">KenStanley/reflections</a></li>
<li><a href="https://github.com/athurg/linux_kernel">athurg/linux_kernel</a></li>
<li><a href="https://github.com/enkidevs/commit">enkidevs/commit</a></li>
<li><a href="https://github.com/gentoo/wikiclone">gentoo/wikiclone</a></li>
<li><a href="https://github.com/karmi/wikipedia_metal_umlaut">karmi/wikipedia_metal_umlaut</a></li>
<li><a href="https://github.com/Homebrew/homebrew-core">Homebrew/homebrew-core</a></li>
<li><a href="https://github.com/renoirb/test">renoirb/test</a></li>
<li><a href="https://github.com/SopraConsulting/CocoapodsSpecs">SopraConsulting/CocoapodsSpecs</a></li>
<li><a href="https://github.com/openSUSE/salt">openSUSE/salt</a></li>
<li><a href="https://github.com/caskroom/homebrew-cask">caskroom/homebrew-cask</a></li>
<li><a href="https://github.com/borisyankov/DefinitelyTyped">borisyankov/DefinitelyTyped</a></li>
<li><a href="https://github.com/neuros/linux-davinci-2.6">neuros/linux-davinci-2.6</a></li>
<li><a href="https://github.com/openstack/openstack">openstack/openstack</a></li>
<li><a href="https://github.com/TheOdinProject/curriculum">TheOdinProject/curriculum</a></li>
<li><a href="https://github.com/NixOS/nixpkgs-channels">NixOS/nixpkgs-channels</a></li>
<li><a href="https://github.com/levaidaniel/sbo">levaidaniel/sbo</a></li>
<li><a href="https://github.com/RobertCNelson/device-tree-rebasing">RobertCNelson/device-tree-rebasing</a></li>
<li><a href="https://github.com/markphip/testing">markphip/testing</a></li>
<li><a href="https://github.com/mutoso-mirrors/linux-historical">mutoso-mirrors/linux-historical</a></li>
<li><a href="https://github.com/Xilinx/u-boot-xlnx">Xilinx/u-boot-xlnx</a></li>
<li><a href="https://github.com/laijs/linux-kernel-ancient-history">laijs/linux-kernel-ancient-history</a></li>
<li><a href="https://github.com/wikimedia/mediawiki-extensions">wikimedia/mediawiki-extensions</a></li>
<li><a href="https://github.com/Ningxiaobao/learngit">Ningxiaobao/learngit</a></li>
<li><a href="https://github.com/FFmpeg/FFmpeg">FFmpeg/FFmpeg</a></li>
<li><a href="https://github.com/rust-lang/rust">rust-lang/rust</a></li>
<li><a href="https://github.com/xwstrom/ffmpeg-3.0.2">xwstrom/ffmpeg-3.0.2</a></li>
<li><a href="https://github.com/tieto/pidgin">tieto/pidgin</a></li>
<li><a href="https://github.com/mesa3d/mesa">mesa3d/mesa</a></li>
<li><a href="https://github.com/drewgreenwell/playscript-mono">drewgreenwell/playscript-mono</a></li>
<li><a href="https://github.com/ThomasGagne/sage-rijndael-gf">ThomasGagne/sage-rijndael-gf</a></li>
<li><a href="https://github.com/chapuni/llvm-project-submodule">chapuni/llvm-project-submodule</a></li>
<li><a href="https://github.com/lwhsu/freebsd-doc_old">lwhsu/freebsd-doc_old</a></li>
<li><a href="https://github.com/palmzeed/git">palmzeed/git</a></li>
<li><a href="https://github.com/yasee/cocos2d-x-custom">yasee/cocos2d-x-custom</a></li>
<li><a href="https://github.com/illumos/illumos-gate">illumos/illumos-gate</a></li>
<li><a href="https://github.com/wbond/package_control_channel">wbond/package_control_channel</a></li>
<li><a href="https://github.com/WeichenXu123/wchen-spark">WeichenXu123/wchen-spark</a></li>
<li><a href="https://github.com/khavnu/VLCLIB">khavnu/VLCLIB</a></li>
<li><a href="https://github.com/OpenDMM/linux">OpenDMM/linux</a></li>
<li><a href="https://github.com/larryhastings/gilectomy">larryhastings/gilectomy</a></li>
<li><a href="https://github.com/KDE/kdelibs">KDE/kdelibs</a></li>
<li><a href="https://github.com/EFForg/https-everywhere">EFForg/https-everywhere</a></li>
<li><a href="https://github.com/PrestaShop/PrestaShop">PrestaShop/PrestaShop</a></li>
<li><a href="https://github.com/John-NY/overo-oe">John-NY/overo-oe</a></li>
<li><a href="https://github.com/webapproot/metasploit">webapproot/metasploit</a></li>
<li><a href="https://github.com/yiichina/yii2">yiichina/yii2</a></li>
<li><a href="https://github.com/zmatsh/Docker">zmatsh/Docker</a></li>
<li><a href="https://github.com/jcenteno1973/sicafam">jcenteno1973/sicafam</a></li>
<li><a href="https://github.com/Digital-Peak-Incubator/tpl_tauristar">Digital-Peak-Incubator/tpl_tauristar</a></li>
<li><a href="https://github.com/shibaniahegde/OpenStack">shibaniahegde/OpenStack</a></li>
<li><a href="https://github.com/aabudari/nova">aabudari/nova</a></li>
<li><a href="https://github.com/futuresimple/ansible-project">futuresimple/ansible-project</a></li>
<li><a href="https://github.com/instructure/canvas-lms">instructure/canvas-lms</a></li>
<li><a href="https://github.com/Shinogasa/django">Shinogasa/django</a></li>
<li><a href="https://github.com/codecombat/codecombat">codecombat/codecombat</a></li>
<li><a href="https://github.com/wireshark/wireshark">wireshark/wireshark</a></li>
<li><a href="https://github.com/dmgerman/git-test-decl">dmgerman/git-test-decl</a></li>
<li><a href="https://github.com/koding/global.hackathon">koding/global.hackathon</a></li>
<li><a href="https://github.com/zurb/foundation">zurb/foundation</a></li>
<li><a href="https://github.com/JCBarahona/edX">JCBarahona/edX</a></li>
<li><a href="https://github.com/paladox/testmw">paladox/testmw</a></li>
<li><a href="https://github.com/woothemes/woocommerce">woothemes/woocommerce</a></li>
<li><a href="https://github.com/ohmnam/spreee">ohmnam/spreee</a></li>
<li><a href="https://github.com/LCTT/TranslateProject">LCTT/TranslateProject</a></li>
<li><a href="https://github.com/patchew-project/qemu">patchew-project/qemu</a></li>
<li><a href="https://github.com/0xbzho/asciinema.org-2015-02">0xbzho/asciinema.org-2015-02</a></li>
<li><a href="https://github.com/tikiorg/sf.net-users">tikiorg/sf.net-users</a></li>
<li><a href="https://github.com/gentoo/gentoo">gentoo/gentoo</a></li>
<li><a href="https://github.com/fanwenyi0529/qemu-fvm">fanwenyi0529/qemu-fvm</a></li>
<li><a href="https://github.com/weissets/happy-navi-osmand">weissets/happy-navi-osmand</a></li>
<li><a href="https://github.com/KDE/kdepim">KDE/kdepim</a></li>
<li><a href="https://github.com/0xbzho/asciinema.org-2015-04">0xbzho/asciinema.org-2015-04</a></li>
<li><a href="https://github.com/duckduckgo/zeroclickinfo-goodies">duckduckgo/zeroclickinfo-goodies</a></li>
<li><a href="https://github.com/julian-gehring/julia">julian-gehring/julia</a></li>
<li><a href="https://github.com/woodsts/buildroot">woodsts/buildroot</a></li>
<li><a href="https://github.com/citation-style-language/styles">citation-style-language/styles</a></li>
<li><a href="https://github.com/aospSX/platform_kernel_msm7x30">aospSX/platform_kernel_msm7x30</a></li>
<li><a href="https://github.com/mjudsp/Tsallis">mjudsp/Tsallis</a></li>
<li><a href="https://github.com/NICHO1212/laravel">NICHO1212/laravel</a></li>
<li><a href="https://github.com/voidlinux/void-packages">voidlinux/void-packages</a></li>
<li><a href="https://github.com/skillcrush/skillcrush-104">skillcrush/skillcrush-104</a></li>
<li><a href="https://github.com/jruby/jruby">jruby/jruby</a></li>
<li><a href="https://github.com/rdunning0823/tophat">rdunning0823/tophat</a></li>
<li><a href="https://github.com/ctekhub/atom-t">ctekhub/atom-t</a></li>
<li><a href="https://github.com/Azure/azure-quickstart-templates">Azure/azure-quickstart-templates</a></li>
<li><a href="https://github.com/linzhangru/ROS">linzhangru/ROS</a></li>
<li><a href="https://github.com/maurossi/llvm">maurossi/llvm</a></li>
<li><a href="https://github.com/forcedotcom/aura">forcedotcom/aura</a></li>
<li><a href="https://github.com/buckett/sakai-gitflow">buckett/sakai-gitflow</a></li>
<li><a href="https://github.com/Tower-KevinLi/Designers-Learn-Git">Tower-KevinLi/Designers-Learn-Git</a></li>
<li><a href="https://github.com/silverstripe/silverstripe-framework">silverstripe/silverstripe-framework</a></li>
<li><a href="https://github.com/PyAr/wiki">PyAr/wiki</a></li>
<li><a href="https://github.com/tonydamage/opendaylight-wiki">tonydamage/opendaylight-wiki</a></li>
<li><a href="https://github.com/android-source/platform_frameworks_native">android-source/platform_frameworks_native</a></li>
<li><a href="https://github.com/lolli42/TYPO3.CMS-Catharsis">lolli42/TYPO3.CMS-Catharsis</a></li>
<li><a href="https://github.com/Roll20/roll20-character-sheets">Roll20/roll20-character-sheets</a></li>
<li><a href="https://github.com/disigma/android_native">disigma/android_native</a></li>
<li><a href="https://github.com/gpcorser/cis255">gpcorser/cis255</a></li>
<li><a href="https://github.com/facebook/hhvm">facebook/hhvm</a></li>
<li><a href="https://github.com/CSMByWater/koha">CSMByWater/koha</a></li>
<li><a href="https://github.com/robfig/plovr">robfig/plovr</a></li>
<li><a href="https://github.com/gitclienttester/gitclienttest">gitclienttester/gitclienttest</a></li>
<li><a href="https://github.com/github-book/first-pr">github-book/first-pr</a></li>
<li><a href="https://github.com/chusopr/kdepim-ktimetracker-akonadi">chusopr/kdepim-ktimetracker-akonadi</a></li>
<li><a href="https://github.com/pydata/pandas">pydata/pandas</a></li>
<li><a href="https://github.com/servo/servo">servo/servo</a></li>
<li><a href="https://github.com/michaKFromParis/sparkslab">michaKFromParis/sparkslab</a></li>
<li><a href="https://github.com/qtproject/qt-creator">qtproject/qt-creator</a></li>
<li><a href="https://github.com/soulteary/Get-D2-2014-Ticket">soulteary/Get-D2-2014-Ticket</a></li>
<li><a href="https://github.com/Kitware/VTK">Kitware/VTK</a></li>
<li><a href="https://github.com/facebook/react-native">facebook/react-native</a></li>
<li><a href="https://github.com/aarontc/kde-workspace">aarontc/kde-workspace</a></li>
<li><a href="https://github.com/jredondo/diaspora-murachi">jredondo/diaspora-murachi</a></li>
<li><a href="https://github.com/Distrotech/evolution">Distrotech/evolution</a></li>
<li><a href="https://github.com/mono/monodevelop">mono/monodevelop</a></li>
<li><a href="https://github.com/dolphin-emu/dolphin">dolphin-emu/dolphin</a></li>
<li><a href="https://github.com/unrealengine47/UnrealEngine4">unrealengine47/UnrealEngine4</a></li>
<li><a href="https://github.com/openSUSE/systemd">openSUSE/systemd</a></li>
<li><a href="https://github.com/alainamedeus/percona-server">alainamedeus/percona-server</a></li>
<li><a href="https://github.com/allyssonsantos/be-mean-modulo-mongodb">allyssonsantos/be-mean-modulo-mongodb</a></li>
<li><a href="https://github.com/alpinelinux/aports">alpinelinux/aports</a></li>
<li><a href="https://github.com/Mittineague/discourse-hacked">Mittineague/discourse-hacked</a></li>
<li><a href="https://github.com/jeremygurr/dcssca">jeremygurr/dcssca</a></li>
<li><a href="https://github.com/mozillazg/pypy">mozillazg/pypy</a></li>
<li><a href="https://github.com/ngoquang2708/android_vendor_sprd_open-source">ngoquang2708/android_vendor_sprd_open-source</a></li>
<li><a href="https://github.com/dart-lang/sdk">dart-lang/sdk</a></li>
<li><a href="https://github.com/Rockbox-Chinese-Community/Rockbox-RCC">Rockbox-Chinese-Community/Rockbox-RCC</a></li>
<li><a href="https://github.com/sudhamisha/vmw-kube">sudhamisha/vmw-kube</a></li>
<li><a href="https://github.com/matplotlib/matplotlib">matplotlib/matplotlib</a></li>
<li><a href="https://github.com/4ad/go">4ad/go</a></li>
<li><a href="https://github.com/intel/theano">intel/theano</a></li>
<li><a href="https://github.com/LucHermitte/ITK">LucHermitte/ITK</a></li>
<li><a href="https://github.com/kontulai/fdsaember">kontulai/fdsaember</a></li>
<li><a href="https://github.com/jonlabroad/OpenHab-1.8.3-InsteonRestApi">jonlabroad/OpenHab-1.8.3-InsteonRestApi</a></li>
<li><a href="https://github.com/sriram1991/anjularJS_usefull">sriram1991/anjularJS_usefull</a></li>
<li><a href="https://github.com/Azure/azure-powershell">Azure/azure-powershell</a></li>
<li><a href="https://github.com/adambard/learnxinyminutes-docs">adambard/learnxinyminutes-docs</a></li>
<li><a href="https://github.com/erikbuck/CS2350">erikbuck/CS2350</a></li>
<li><a href="https://github.com/TheThingsNetwork/wiki">TheThingsNetwork/wiki</a></li>
<li><a href="https://github.com/cbeasley92/hack-summit-hackathon">cbeasley92/hack-summit-hackathon</a></li>
<li><a href="https://github.com/2947721120/adamant-waffle">2947721120/adamant-waffle</a></li>
<li><a href="https://github.com/hashicorp/terraform">hashicorp/terraform</a></li>
<li><a href="https://github.com/librenms/librenms">librenms/librenms</a></li>
<li><a href="https://github.com/Lyude/gtk-">Lyude/gtk-</a></li>
<li><a href="https://github.com/RR1007/Jenkins2">RR1007/Jenkins2</a></li>
<li><a href="https://github.com/Kitware/ParaView">Kitware/ParaView</a></li>
<li><a href="https://github.com/tgm4883/lr-rpi2">tgm4883/lr-rpi2</a></li>
<li><a href="https://github.com/Kasual666/WebGl">Kasual666/WebGl</a></li>
<li><a href="https://github.com/jlouiss/freeCodeCamp">jlouiss/freeCodeCamp</a></li>
<li><a href="https://github.com/danoli3/openFrameworksBFG2">danoli3/openFrameworksBFG2</a></li>
<li><a href="https://github.com/mozilla/spidernode">mozilla/spidernode</a></li>
<li><a href="https://github.com/ansible/ansible-modules-core">ansible/ansible-modules-core</a></li>
<li><a href="https://github.com/scardinius/civicrm-core-api-mailing">scardinius/civicrm-core-api-mailing</a></li>
<li><a href="https://github.com/akka/akka">akka/akka</a></li>
<li><a href="https://github.com/mozilla/releases-comm-central">mozilla/releases-comm-central</a></li>
<li><a href="https://github.com/stewartsmith/bzr">stewartsmith/bzr</a></li>
<li><a href="https://github.com/KrauseFx/fastlane">KrauseFx/fastlane</a></li>
<li><a href="https://github.com/lpathy/hhvm-armjit">lpathy/hhvm-armjit</a></li>
<li><a href="https://github.com/krt16s/fdroiddata">krt16s/fdroiddata</a></li>
<li><a href="https://github.com/mongodb/mongo">mongodb/mongo</a></li>
<li><a href="https://github.com/Yiutto/D3">Yiutto/D3</a></li>
<li><a href="https://github.com/rg3/youtube-dl">rg3/youtube-dl</a></li>
<li><a href="https://github.com/KDE/amarok">KDE/amarok</a></li>
<li><a href="https://github.com/xiaobing007/tachyon">xiaobing007/tachyon</a></li>
<li><a href="https://github.com/HydAu/Camel">HydAu/Camel</a></li>
<li><a href="https://github.com/almania69/Gimp">almania69/Gimp</a></li>
<li><a href="https://github.com/TEAMMATES/repo">TEAMMATES/repo</a></li>
<li><a href="https://github.com/piwik/piwik">piwik/piwik</a></li>
<li><a href="https://github.com/pfsense/pfsense">pfsense/pfsense</a></li>
<li><a href="https://github.com/nadimtuhin/platform4">nadimtuhin/platform4</a></li>
<li><a href="https://github.com/highfidelity/hifi">highfidelity/hifi</a></li>
<li><a href="https://github.com/DarkstarProject/darkstar">DarkstarProject/darkstar</a></li>
<li><a href="https://github.com/nishithshah2211/libvirt">nishithshah2211/libvirt</a></li>
<li><a href="https://github.com/chscodecamp/github">chscodecamp/github</a></li>
<li><a href="https://github.com/naraa/mangos">naraa/mangos</a></li>
<li><a href="https://github.com/mangosR2/mangos3">mangosR2/mangos3</a></li>
<li><a href="https://github.com/mtahmed/poky-clang">mtahmed/poky-clang</a></li>
<li><a href="https://github.com/JuliaLang/METADATA.jl">JuliaLang/METADATA.jl</a></li>
<li><a href="https://github.com/idano/home">idano/home</a></li>
<li><a href="https://github.com/alfathony/codeigniter-restclient">alfathony/codeigniter-restclient</a></li>
<li><a href="https://github.com/duckduckgo/zeroclickinfo-spice">duckduckgo/zeroclickinfo-spice</a></li>
<li><a href="https://github.com/google/closure-compiler">google/closure-compiler</a></li>
<li><a href="https://github.com/karthikjaps/elasticsearch">karthikjaps/elasticsearch</a></li>
<li><a href="https://github.com/dwinurhadia/openstack-doc">dwinurhadia/openstack-doc</a></li>
<li><a href="https://github.com/sciell/ArduPilot">sciell/ArduPilot</a></li>
<li><a href="https://github.com/0xbzho/asciinema.org-2015-01">0xbzho/asciinema.org-2015-01</a></li>
<li><a href="https://github.com/wxWidgets/wxWidgets">wxWidgets/wxWidgets</a></li>
<li><a href="https://github.com/frugalware/kde5">frugalware/kde5</a></li>
<li><a href="https://github.com/ManageIQ/manageiq">ManageIQ/manageiq</a></li>
<li><a href="https://github.com/dyon/skcore">dyon/skcore</a></li>
<li><a href="https://github.com/tmcguire/qt-mobility">tmcguire/qt-mobility</a></li>
<li><a href="https://github.com/KSP-CKAN/NetKAN">KSP-CKAN/NetKAN</a></li>
<li><a href="https://github.com/ShaneDelmore/scala">ShaneDelmore/scala</a></li>
<li><a href="https://github.com/freeminer/freeminer">freeminer/freeminer</a></li>
<li><a href="https://github.com/bartekrychlicki/bisect-kata">bartekrychlicki/bisect-kata</a></li>
<li><a href="https://github.com/cakephp/docs">cakephp/docs</a></li>
</ol>
<style>
#repo-list {
  max-height: 400px;
  overflow-y: auto;
}
#repo-list li {
  margin: 0;
}
</style>

It's a pity we were unable to process some important repos like `torvalds/linux`
back in October, as I noted in the beginning, so they are absent.
[bmorganatlas2/firstrepo](https://github.com/bmorganatlas2/firstrepo) got
to the top due to the failure of the identity matching: we've got the
[clique](https://en.wikipedia.org/wiki/Clique_(graph_theory)) which is PageRank's
Achilles' heel. This is not much of our fault: the guy created 30,000 commits,
each under a different, obviously fake, author. How were we supposed to realize it
without using GitHub API? The same failure happened with [bmorganatlas/fusiontest5](https://github.com/bmorganatlas/fusiontest5)
(besides, it has 10,000+ branches!). Other repositories seem to be legit
and typically have thousands of contributors, hence high PageRank.
We are currently building out a large data pipeline that will increase the
quality of our data and expand it beyond GitHub to almost all git repositories
on the web.

Summary
-------
This post studies the contributions graph which source{d} collected from GitHub
repositories. The October 2016 dataset is open on [data.world](https://data.world/vmarkovtsev/452-m-commits-on-github)
and can be used to build it, however, it can be downloaded fully baked from our
[Google Drive](https://drive.google.com/file/d/0B-w8jGUJto0ibVI3QUVBdXJnN1E). We've
had fun with proving the theory of 6 handshakes between GitHub core developers
and measuring the community members' importance by applying PageRank algorithm.

Update
------

This is what you get if you visualize the Google matrix with [LargeVis](https://github.com/elbamos/largeVis):

[![LargeVis GitHub](/post/handshakes_pagerank/graph_2048.jpg)](/post/handshakes_pagerank/graph_2048.png)

I used `hexbin` from matplotlib:
```python
hexbin(graph[:, 0], graph[:, 1],
       gridsize=2048, bins="log", cmap="inferno")
```

<script async src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS_CHTML"></script>

<style>
p.caption {
  margin-top: -16px;
  font-style: italic;
}
</style>