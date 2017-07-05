---
author: waren
date: 2017-07-03
title: "Analyzing GitHub, how developers change programming languages over time"
draft: false
image: /post/language_migrations/background.png
description: "This post is inspired by ''The eigenvector of why we moved from language X to language Y'', by Erik Bernhardsson. Based on GitHub repositories, we build our own transition matrix after solving the flow optimization problem. The results are reflecting the history of programming language competition in the open source world."
categories: ["science", "technical"]
---
<style>
p.caption {
  margin-top: -16px;
  font-style: italic;
}
img.fig {
  width: 600px;
}
.grid2x {
  display: flex;
  width: 1000px;
  overflow: visible;
  margin-left: -200px;
}
.grid2x pre {
  text-align: center;
}
.grid2x-cell {
  width: 50%;
}
@media (max-width: 1000px) {
  .grid2x {
    width: 100%;
    margin-left: 0;
  }
  .grid2x > div {
    width: 50%;
  }
  .grid2x pre {
    font-size: 0.75em;
  }
}
</style>

Never have you been struggling with an nth obscure project, thinking : "_I could do the job with this language but why not switch to another one which would be more enjoyable to work with_" ? In his awesome blog post : [The eigenvector of "Why we moved from language X to language Y"](https://erikbern.com/2017/03/15/the-eigenvector-of-why-we-moved-from-language-x-to-language-y.html), [Erik Bernhardsson](https://github.com/erikbern/eigenstuff) generated an N*N contingency table of all Google queries questioning about changing languages. However, when I read it, I can't help wondering what the proportion of people who effectively switched is. Thus, it becomes engaging to deepen this idea and see how the popularity of languages moves among GitHub users.

## Dataset available

Thanks to our data retrieval pipeline, source{d} opened the dataset that contains the yearly number of bytes coded by each GitHub user in each programming language. In a few figures, it is:

* 4.5 Million GitHub users
* 393 different languages
* 10 TB of source code all in all

I invite you to take a look at [Vadim Markovtsev](https://github.com/vmarkovtsev?tab=repositories)'s blog post : [Spaces or Tabs](https://blog.sourced.tech/post/tab_vs_spaces/), if you want details about which repositories and languages were considered,

To have a better insight into what's going on, I find it nice to visualize developer's history of languages using a kind of [Gantt diagram](https://en.wikipedia.org/wiki/Gantt_chart).

<img src="/post/language_migrations/3710313.png" class="fig">
<p align="center" class="caption">Language history of GitHub user n°X</p>

First of all, note that the colorbar on the right stands for the proportion of source code in each language. We can already deduce several things from this diagram:

* The user's favorite language is **Scala** and he is stuck to it.

* He tried **Go**, but did not really get along with.

* He ran an important project in **Java** but he'd rather code in Scala. Using Java might have been a constraint to complete a single project.

Of course, it would be nonsense to conclude from this diagram that the guy moved from **Java** to **Markdown**, in 2014. More generally, as it is absurd to betray a programming language in favor of a markup one, we want to avoid any comparison between two languages that don't have the same purpose. That's why, throughout the rest of the post, we focus on the sample of 22 main programming languages.

## Quantization

You will surely agree that **"Hello world"** GitHub repositories do not really count in switching to another language. So, we decide to quantize the contributions of our dataset in order to reduce the noise. For this reason, we represent the distribution of GitHub contributions per size in the following bar plot.

<img src="/post/language_migrations/contributions.png" class="fig">
<p align="center" class="caption">Distribution of GitHub contributions by size</p>

As we can see, it has a very long tail and most of the contributions are tiny ones. Then to approximate the distribution, we apply the [kernel density estimation](http://scikit-learn.org/stable/auto_examples/neighbors/plot_kde_1d.html#sphx-glr-auto-examples-neighbors-plot-kde-1d-py), which is the orange curve in the last figure. Finally, we get the quantization by dividing the area under the curve into 10 equal parts. The first group is set to 0 and the others follow linearly.

Now after filtering and quantizing our dataset, we can proceed with building our own transition matrix.

## Minimum-cost flow problem

For every GitHub user, we aggregate annual vectors ; we will call them reactors where each of the 393 elements stands for the amount of bytes coded in the corresponding language and year. After the normalization, these reactors resemble histograms which we need to compare with each other.

An elegant approach which is effective both in coding and computational time, is to use [`PyEMD`](https://pypi.python.org/pypi/pyemd) : a Python wrapper for the [Earth Mover's Distance](https://en.wikipedia.org/wiki/Earth_mover's_distance) which is Numpy friendly. This measure -- better than the euclidean distance for histogram comparison -- is particularly beneficial because it is based on [Linear Programming](https://en.wikipedia.org/wiki/Linear_programming) (LP). Indeed, it can be seen as the solution of the following [transportation problem](http://www.me.utexas.edu/~jensen/models/network/net8.html), where \\(~\\sum_ {i=1}^N s_ i = \\sum_ {j=1}^N d_ j = 1\\)

<img src="/post/language_migrations/emd.png" class="fig">
<p align="center" class="caption">Transportation Problem with supplies and demands</p>

We can see that for every pair of years, the numbers of bytes are either considered as "supplies" or "demands". Besides, since \\(~\\sum_ {i=1}^N s_ i = \\sum_ {j=1}^N d_ j = 1\\),
it becomes a [cost-minimization flow problem](https://en.wikipedia.org/wiki/Minimum-cost_flow_problem). It's formulated below.

\\begin{equation}
\\arg \\min \\sum_ {i=1}^N \\sum_ {j=1}^N x_ {ij}
\\end{equation}
\\begin{equation}\\label{non-negative}
x_ {ij} \\geq 0,
\\end{equation}
\\begin{equation}\\label{sum1}
\\sum_ {j=1}^N x_ {ij} = s_ i,
\\end{equation}
\\begin{equation}\\label{sum2}
\\sum_ {i=1}^N x_ {ij} = d_ j,
\\end{equation}
\\begin{equation}\\label{emd}
\\sum_ {i=1}^N \\sum_ {j=1}^N x_ {ij} = 1
\\end{equation}

Let's go a little aside here. First, "costs" of the edges are set equal to 1 in order for us to be unbiased. Second, to reduce our problem to the classical [flow minimization formulation](https://en.wikipedia.org/wiki/Minimum-cost_flow_problem), we have to add an artificial source and sink on both sides of our [bipartite graph](https://en.wikipedia.org/wiki/Bipartite_graph) to ensure flow conservation. However, this is not a critical point; the last slides [Stanford's CS97SI](https://web.stanford.edu/class/cs97si/08-network-flow-problems.pdf) describe that transformation.

## Transition Matrix

Here is the core code to compute the transition matrix of a specific GitHub user and between two corresponding consecutive years. The main function we use is [`emd_with_flow`](https://pypi.python.org/pypi/pyemd) which is provided by the [`PyEMD`](https://pypi.python.org/pypi/pyemd) package.

```Python
def get_transition_matrix_emd(user, year):

    # lang2keep is the list of the 22 programming languages we kept
    # stairvalue() is the step function that comes from quantization

    # Build user's reactors for year and year+1
    reactors = zeros((len(lang2keep),2), order='f')

    for ind, code_in_lang in enumerate(dataset[user]):
        lang = code_in_lang[0]

        if lang in lang2keep:
            for y, qtt_coded_year in code_in_lang[1]:
                if y == year:
                    reactors[lang2keep.index(lang),0] = stairvalue(qtt_coded_year)

                elif y == year+1:
                    reactors[lang2keep.index(lang),1] = stairvalue(qtt_coded_year)

    if (sum(reactors[:,0]) == 0) or (sum(reactors[:,1]) == 0):
        # no transition to consider
        P = zeros((len(lang2keep), len(lang2keep)))
        return P

    else:
        # Normalization of reactors
        for i in [0, 1]:
            reactors[:,i] = [j/sum(reactors[:,i]) for j in reactors[:,i]]

    # compute the Earth Mover's distance between the 2 reactors thanks to the emd_with_flow function
    distance = np.ones((len(lang2keep), len(lang2keep)))
    dist, P = emd_with_flow(reactors[:,0], reactors[:,1], distance)
    P = np.asarray(P)

    return P
```
<p align="center" class="caption">Function to compute a transition matrix in Python</p>

Finally, after summing the flow matrices over users - and over the last 16 years (we will consider the latter assumption below), we obtain the resulting transition matrix. Let's now compare it to the contingency table Erik compiled from Google queries. The following figures were plotted using [Erik's script](https://github.com/erikbern/eigenstuff/blob/master/analyze.py).

<div class="grid2x">
<div class="grid2x-cell">
<div>
<img src="/post/language_migrations/sum_matrix_wdiag_22lang.svg">
<p align="center" class="dt"><pre><code class="hljs python">source{d}'s flow transition matrix</code></pre></p>
</div>
</div>
<div  class="grid2x-cell">
<div>
<img src="/post/language_migrations/erik_red.png">
<p align="center" class="dt"><pre><code class="hljs python">Erik's contingency table</code></pre></p>
</div>
</div>
</div>

Comparing to Erik's table we've got the elements on the main diagonal of the transition matrix. We will see later how to take an advantage of it. However, although the dataset we used is different, we notice many relevant similarities and perceive the same kind of language profile.

## GitHub "LanguageRank"

Since we have our flow matrix, we want to know which languages are the most and the least popular. It is possible to calculate [centrality measures](https://en.wikipedia.org/wiki/Centrality) on the represented graph, e.g. the eigenvector centrality. Indeed these measures convey the relative popularity of languages in the sense that people coding in a language would more or less likely switch to another one. We will take this approach - calculate the eigenvector centrality. If you need further explanations, I invite you to read Vadim's PageRank analysis in his blog post about the [GitHub Contributions Graph](https://blog.sourced.tech/post/handshakes_pagerank/).

1. Our flow matrix contains strictly positive elements, which is the sufficient condition to make it [irreducible](https://en.wikipedia.org/wiki/Irreducibility_(mathematics)) ; there is always a way to reach all other languages from any given one. Thus, according to [Perron–Frobenius theorem](https://en.wikipedia.org/wiki/Perron%E2%80%93Frobenius_theorem), we are looking for the greatest eigenvalue and the corresponding eigenvector.

2. To find that dominant eigenvector, we can use the [Power Iteration](https://en.wikipedia.org/wiki/Power_iteration) algorithm. Nevertheless, in addition to be irreducible, the matrix needs to be stochastic and aperiodic.

3. Our flow matrix becomes [stochastic](https://en.wikipedia.org/wiki/Stochastic_matrix) when removing the main diagonal and normalizing the rows. The greatest eigenvalue is now equal to 1.

4. Finally, to make our matrix [aperiodic](https://en.wikipedia.org/wiki/Markov_chain) and well conditioned, there is a famous trick introduced by Larry and Sergey in 1998. It is well explained in [Stanford’s CS246](http://snap.stanford.edu/class/cs246-2013/slides/09-pagerank.pdf) but to make it short, it mainly consists of updating our flow matrix with the following formula:

$$
P = \\beta P + \\frac{1-\\beta}{N}\\left( \\begin{array}{cccc}
1 & 1 & ... & 1 \\\\\\
1 & 1 & ... & 1 \\\\\\
... & ... & \\ddots & ... \\\\\\
1 & 1 & ... & 1 \\end{array} \\right)
$$

where,

* \\(\\beta~\\) is called random walk factor and set to 0.85
* N   is the number of languages

### Power Iteration

This way, our well conditioned flow matrix contains an approximation of the probabilities of switching between languages, and we are now entitled to proceed with the power iteration. This algorithm consists of the following matrix multiplication until convergence to the dominant eigenvector:
$$
x_ {i+1} = P\\cdot x_ i
$$

Below, we will find the code that returns the wanted dominant eigenvector.

```Python
def power_iteration(A, nb_iterations=100, beta=0.85):
    u = np.random.rand(len(lang2keep))
    u = np.reshape(u, (len(lang2keep), 1))
    A = A * beta + ((1 - beta) / len(lang2keep)) * np.ones((len(lang2keep), len(lang2keep)))

    for _ in range(nb_iterations):
        u_next = np.dot(A,u)
        u_next_norm = sum(u_next)
        u = u_next / u_next_norm

    return u

 power_iteration(transition_matrix)
```
<p align="center" class="caption">Power Iteration algorithm, Python.</p>


### Most popular languages on GitHub

At last! Here is the reward : the stationary distribution of our [Markov chain](https://en.wikipedia.org/wiki/Markov_chain). This probability distribution is independent of the initial distribution. It gives information about the stability of the process of random languages switching. Thus, no matter how popular languages are at the present time, the hypothetical future stationary state stays the same. Here is the popularity ranking of our 22 languages used on GitHub:

<style>
table {
    font-family: arial, sans-serif;
    border-collapse: collapse;
}
td, th {
    text-align: left;
    padding: 8px;
    word-wrap: break-word;
}
th {
    background: #eee;
}
tr:nth-child(even) {
    background-color: #dddddd;
}
.wrap {
    margin-top:-30px;
}
.wrap table {
    table-layout: fixed;
}
.inner_table {
    margin-top:-48px;
    height: 400px;
    overflow-y: auto;
    margin-bottom:30px;
}
</style>

<div class="wrap">
    <table class="head">
      <table>
    <tr>
      <th>Rank</th>
      <th>Language</th>
      <th>Popularity, %</th>
      <th>Source code, %</th>
    </tr>
    </table>
    <div class="inner_table">
    <table>
    <tr>
      <td>1.</td>
      <td>Python</td>
      <td>16.1</td>
      <td>11.3</td>
    </tr>
    <tr>
      <td>2.</td>
      <td>Java</td>
      <td>15.3</td>
      <td>16.6</td>
    </tr>
  <tr>
    <td>3.</td>
    <td>C</td>
    <td>9.2</td>
    <td>17.2</td>
  </tr>
  <tr>
    <td>4.</td>
    <td>C++</td>
    <td>9.1</td>
    <td>12.6</td>
  </tr>
  <tr>
    <td>5.</td>
    <td>PHP</td>
    <td>8.5</td>
    <td>24.4</td>
  </tr>
  <tr>
    <td>6.</td>
    <td>Ruby</td>
    <td>8.3</td>
    <td>2.6</td>
  </tr>
  <tr>
    <td>7.</td>
    <td>C#</td>
    <td>6.1</td>
    <td>6.5</td>
  </tr>
  <tr>
    <td>8.</td>
    <td>Objective-C</td>
    <td>4.0</td>
    <td>3.3</td>
  </tr>
  <tr>
    <td>9.</td>
    <td>Go</td>
    <td>3.2</td>
    <td>0.7</td>
  </tr>
  <tr>
    <td>10.</td>
    <td>Swift</td>
    <td>2.6</td>
    <td>0.3</td>
  </tr>
  <tr>
    <td>11.</td>
    <td>Scala</td>
    <td>2.2</td>
    <td>0.3</td>
  </tr>
  <tr>
    <td>12.</td>
    <td>Perl</td>
    <td>2.0</td>
    <td>0.9</td>
  </tr>
  <tr>
    <td>13.</td>
    <td>R</td>
    <td>1.8</td>
    <td>0.3</td>
  </tr>
  <tr>
    <td>14.</td>
    <td>Haskell</td>
    <td>1.8</td>
    <td>0.2</td>
  </tr>
  <tr>
    <td>15.</td>
    <td>Lua</td>
    <td>1.7</td>
    <td>0.7</td>
  </tr>
  <tr>
    <td>16.</td>
    <td>Matlab</td>
    <td>1.7</td>
    <td>0.5</td>
  </tr>
  <tr>
    <td>17.</td>
    <td>Clojure</td>
    <td>1.5</td>
    <td>0.2</td>
  </tr>
  <tr>
    <td>18.</td>
    <td>Rust</td>
    <td>1.2</td>
    <td>0.1</td>
  </tr>
  <tr>
    <td>19.</td>
    <td>Erlang</td>
    <td>1.0</td>
    <td>0.1</td>
  </tr>
  <tr>
    <td>20.</td>
    <td>Visual Basic</td>
    <td>1.0</td>
    <td>0.3</td>
  </tr>
  <tr>
    <td>21.</td>
    <td>Fortran</td>
    <td>0.9</td>
    <td>0.3</td>
  </tr>
  <tr>
    <td>22.</td>
    <td>Pascal</td>
    <td>0.8</td>
    <td>0.6</td>
  </tr>
</table>
</div>
</div>

<p align="center" class="caption">Popularity of languages according to
<a href="https://en.wikipedia.org/wiki/Centrality">centrality measure</a> on GitHub</p>

**Python** (16.1 %) appears to be the most attractive language, followed closely by **Java** (15.3 %). However, it's especially interesting since only 11.3 % of all source code written on GitHub, among these 22 languages is **Python**.

In Erik's ranking, **Go** was the big winner with 16.4 %. Since Erik based his approach on Google queries, it seems that the buzz around Go which makes people wonder explicitly in blogs if they should move to this language, takes a bit of time to become apparent in terms of projects effectively written in **Go** on GitHub.

Furthermore **C** (9.2 %) is doing well like in Erik's grading with 14.3 %, though it is due to the amount of projects coded in **C** on GitHub.

Although there are ten times more lines of code on GitHub in **PHP** than in **Ruby**, we have the same probability to switch for those two.

**Go** (3.2 %) appears on the 9th position which is largely honorable given the small proportion (0.9 %) of **Go** projects which are written on GitHub. The same proportion of projects are in **Perl** for example, but this language doesn't really awake passion (2 % popularity).

### What about sticking to a language ?

If we keep the main diagonal of our transition matrix before applying the power iteration, we obtain slightly different results. It mainly decreases top languages popularity while raising the smaller ones'. Indeed, it seems logical to believe that developers who invest their time in mastering a language on the fringe of the others tend to stick to them unlike the popular ones.

In the rest of the post, we will consider our first representation of the dominant eigenvector.

### Back to the transition matrix

What if we sort our transition matrix so that the most popular languages appear at the bottom, and compare it to Erik's.

<div class="grid2x">
<div class="grid2x-cell">
<div>
<img src="/post/language_migrations/sum_matrix_22lang_eig.svg">
<p align="center" class="dt"><pre><code class="hljs python">source{d}'s sorted transition matrix</code></pre></p>
</div>
</div>
<div class="grid2x-cell">
<div>
<img src="/post/language_migrations/erik_green.png">
<p align="center" class="dt"><pre><code class="hljs python">Erik's sorted transition matrix</code></pre></p>
</div>
</div>
</div>

* Developers coding in one of the 5 most popular languages (**Java**, **C**, **C++**, **PHP**, **Ruby**) are most likely to switch to **Python** with approx. 22% chance on the average.

* Besides, according to Erik's matrix, we switch from **Ojective-C** to **Swift** and back with a greater probability - 24% and 19% accordingly.

* Similarly, a **Visual Basic** developer has more chance (24%) to move to **C#** while Erik's is almost confident in that transition with 92%.

* Users of **Clojure**, **C#** and, above all, **Scala** would rather switch to **Java** with respectively 22, 29 and 40% chance.

* People using numerical and statistical environments such as **Fortran** (36 %), **Matlab** (33 %) or **R** (40 %) are most likely to switch to **Python** in contrast to Erik's matrix which predicts **C** as their future language.

* One common point I found with Erik's results about **Go** is that it belongs to people who gave up studying **Rust**.

## Over the last 16 years

As we mentioned earlier before summing the transition matrices over time, we now consider specific years and determine how these yearly matrices look like. Do they express the same find of language profile ? How has it been evolving since the early 2000's ? Here is a sample of 4 matrices from various timeline intervals:

<div class="grid2x">
<div>
<div>
<img src="/post/language_migrations/P_2005.svg">
<p align="center" class="dt"><pre><code class="hljs python">2005 - 2006</code></pre></p>
</div>
<div>
<img src="/post/language_migrations/P_2011.svg">
<p align="center" class="dt"><pre><code class="hljs python">2011 - 2012</code></pre></p>
</div>
</div>
<div>
<div>
<img src="/post/language_migrations/P_2008.svg">
<p align="center" class="dt"><pre><code class="hljs python">2008 - 2009</code></pre></p>
</div>
<div>
<img src="/post/language_migrations/P_2015.svg">
<p align="center" class="dt"><pre><code class="hljs python">2015 - 2016</code></pre></p>
</div>
</div>
</div>

<p align="center" class="caption">Temporal evolution of transition matrices</p>

In the end, the evolution of these matrices over time seems to be affine, and we observe the same language profile every year. Thus, to highlight the time-line of this language profile, we apply the power iteration to each matrix. Earlier, we averaged the stationary distribution over the last 16 years but now we look at its chronological sequence. The resulting series of the dominant eigenvectors is presented below on the stack area plot.

<img src="/post/language_migrations/eigenvect_stack_22lang.png" class="fig">
<p align="center" class="caption">Stationary distribution of languages over the last 16 years</p>

The thickness of each band corresponds to the value in the dominant eigenvector. The bands are sorted by the averaged popularity which we calculated before.

* The first two languages, **Python** and **Java** have the same profile. They have been taking the place of **C** for 15 years. Indeed, the aggregation of these first 3 layers gives a straight one.

* The attractiveness of **C++** dropped prominently in 2008 in favor of languages like **Ruby**. Nevertheless, it has been sustaining its popularity ever since this period.

* I definitely support Erik's conclusion that **Perl** is dying.

* **Apple** presented **Swift** on [WWDC'2014](https://developer.apple.com/videos/play/wwdc2014/402/) and it was supposed to replace **Obj-C**. So **Obj-C** adoption should start to decrease after that event, but the sum of both languages should remain the same. Looking at the figure, this hypothesis turns out to be right.

* **Ruby** appears to have had 6 years of glory starting from 2007. It might be explained with the launch of the web framework, [Ruby on Rails](https://en.wikipedia.org/wiki/Ruby_on_Rails) (RoR), which reached a milestone when Apple announced that it would ship it with [Mac OS X v10.5 "Leopard"] (https://en.wikipedia.org/wiki/Mac_OS_X_Leopard) - released in October.

* Regarding **Go**, the popularity stays relatively low. However, the dynamics is clearly positive.

## Notebook

I used the following [Jupyter](http://jupyter.org/) notebook to prepare the post:

<script src="https://gist.github.com/warenlg/fc906334857bf66941165edfe8f76b4c.js"></script>

## Conclusion

It would be more relevant to see Erik's contingency table as a kind of the second derivative of the language distribution problem while our flow transitions are like the first derivative. That is, first you google, then you try to write an OSS project, and finally the languages distribution changes.

## Acknowledgements

I want to thank my tutor at source{d}, [Vadim Markovtsev](https://twitter.com/tmarkhor), for his guidance all along this study, as well as people working with us for their patience in giving me valuable insights.

<script async src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS_CHTML"></script>
<script async type="text/x-mathjax-config">
MathJax.Hub.Config({
  TeX: { equationNumbers: { autoNumber: "AMS" } }
});
</script>
