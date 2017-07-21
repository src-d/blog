---
author: waren
date: 2017-07-12
title: "Analyzing GitHub, how developers change programming languages over time"
draft: false
image: /post/language_migrations/background.png
description: "This post is inspired by ''The eigenvector of why we moved from language X to language Y'', by Erik Bernhardsson. Based on GitHub repositories, we build our own transition matrix after solving the flow optimization problem. The results are reflecting the history of programming language competition in the open source world."
categories: ["science", "technical"]
---

Have you ever been struggling with an nth obscure project, thinking : "_I could do the job with this language but why not switch to another one which would be more enjoyable to work with_" ? In his awesome blog post : [The eigenvector of "Why we moved from language X to language Y"](https://erikbern.com/2017/03/15/the-eigenvector-of-why-we-moved-from-language-x-to-language-y.html), [Erik Bernhardsson](https://github.com/erikbern/eigenstuff) generated an N*N contingency table of all Google queries related to changing languages. However, when I read it, I couldn't help wondering what the proportion of people who effectively switched is. Thus, it has become engaging to deepen this idea and see how the popularity of languages changes among GitHub users.

## Dataset available

Thanks to our data retrieval pipeline, source{d} opened the dataset that contains the yearly numbers of bytes coded by each GitHub user in each programming language. In a few figures, it is:

* 4.5 Million GitHub users
* 393 different languages
* 10 TB of source code in total

I invite you to take a look at [Vadim Markovtsev](https://github.com/vmarkovtsev?tab=repositories)'s blog post : [Spaces or Tabs](https://blog.sourced.tech/post/tab_vs_spaces/), if you want details about which repositories and languages were considered.

To have a better understanding of what's going on, I find it nice to visualize developer's language usage history with a kind of [Gantt diagram](https://en.wikipedia.org/wiki/Gantt_chart).

{{% caption src="/post/language_migrations/3710313.png" title="Language usage historu of GitHub user #x" %}}
Language usage history of GitHub user n°X
{{% /caption %}}

Note that the colors represent proportions of source code in each language. We can already deduce several things from this diagram:

* The user's favorite language is **Scala** and they are stuck to it.

* They tried **Go**, but did not really get along with it.

* They ran an important project in **Java** but they'd rather code in Scala. Using Java might have been a constraint to complete a single project.

Of course, it would be wrong to conclude from this diagram that the guy moved from **Java** to **Markdown**, in 2014. More generally, since it is absurd to give up a programming language in favor of a markup one, we want to avoid any comparison between the languages that don't have the same purpose. That's why we focus on the sample of 25 main programming languages throughout the rest of the post.

## We did not include Javascript because ...

The first reason is that 40% of Github users we analyzed had JS in their profiles, and the proposed transition model becomes useless. The second is, citing Erik, "(a) if you are doing it on the frontend, you are kind of stuck with it anyway, so there’s no moving involved (except if you do crazy stuff like transpiling, but that’s really not super common) (b) everyone refers to Javascript on the backend as 'Node'". Our data retrieval pipeline could not distinguish regular JS from Node and thus we had to exclude it completely.

## Quantization

You will surely agree that **"Hello world"** GitHub repositories do not really count as switching to another language. So, we decide to quantize the contributions in our dataset in order to reduce the noise. For this reason, we represent the distribution of GitHub contributions per byte size in the following bar plot.

{{% caption src="/post/language_migrations/contributions.png" title="Distribution of GitHub contributions by size" %}}
Distribution of GitHub contributions by size
{{% /caption %}}

As we can see, it has a very long tail and most of the contributions are tiny ones. To approximate the distribution, we apply [kernel density estimation](http://scikit-learn.org/stable/auto_examples/neighbors/plot_kde_1d.html#sphx-glr-auto-examples-neighbors-plot-kde-1d-py), which is the orange curve in the last figure. Finally, we get the quantization by dividing the area under the curve into 10 equal parts. The groups are numbered starting with 0.

Now after filtering and quantizing our dataset, we can proceed with building our own transition matrix.

## Minimum-cost flow problem

For every GitHub user, we aggregate annual vectors ; we will call them reactors where each of the 393 elements stands for the number of bytes coded in the corresponding language that year. After normalization these reactors resemble histograms which we need to compare with each other.

An elegant approach to this problem, which is effective both in coding and computational time, is offered in [`PyEMD`](https://pypi.python.org/pypi/pyemd): a Python wrapper for the [Earth Mover's Distance](https://en.wikipedia.org/wiki/Earth_mover's_distance) which is Numpy friendly. This distance measure -- better than the euclidean distance for histogram comparison -- is particularly interesting because it is based on [Linear Programming](https://en.wikipedia.org/wiki/Linear_programming) (LP). Indeed, it can be seen as the solution of the following [transportation problem](http://www.me.utexas.edu/~jensen/models/network/net8.html), where \\(~\\sum_ {i=1}^N s_ i = \\sum_ {j=1}^N d_ j = 1\\)

{{% caption src="/post/language_migrations/emd.png" title="Transportation Problem with supplies and demands" %}}
Transportation Problem with supplies and demands
{{% /caption %}}

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

Let's go a little aside here. First, "costs" of the edges are set equal to 1 in order for us to be unbiased. Second, to reduce our problem to the classical [flow minimization formulation](https://en.wikipedia.org/wiki/Minimum-cost_flow_problem), we have to add an artificial source and sink on both sides of our [bipartite graph](https://en.wikipedia.org/wiki/Bipartite_graph) to ensure flow conservation. This is not a critical point; the last slides [Stanford's CS97SI](https://web.stanford.edu/class/cs97si/08-network-flow-problems.pdf) describe that transformation.

## Transition Matrix

Here is the core code to compute the transition matrix between two consecutive years for a specific GitHub user. The main function we use is [`emd_with_flow`](https://pypi.python.org/pypi/pyemd) which is provided by the [`PyEMD`](https://pypi.python.org/pypi/pyemd) package.

```Python
def get_transition_matrix_emd(user, year):

    # lang2keep is the list of the 25 programming languages we kept
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
{{% center %}}
Function to compute a transition matrix in Python
{{% /center %}}

Finally, after summing the flow matrices over users and over the last 16 years (we will consider yearly transitions below), we obtain the resulting transition matrix. Let's now compare it to the contingency table compiled by Erik from Google queries. The following figures were plotted using [Erik's script](https://github.com/erikbern/eigenstuff/blob/master/analyze.py).

{{% grid %}}
{{% grid-cell %}}
{{% caption src="/post/language_migrations/sum_matrix_25lang.svg" %}}
source{d}'s flow transition matrix
{{% /caption %}}
{{% /grid-cell %}}

{{% grid-cell %}}
{{% caption src="/post/language_migrations/erik_red.png" %}}
Erik's contingency table
{{% /caption %}}
{{% /grid-cell %}}
{{% /grid %}}

Compared to Erik's table we've got some elements on the main diagonal of our transition matrix. We will see later how to take an advantage of it. However, although the dataset we used is different, we notice many relevant similarities and perceive the same kind of language profile.

## GitHub "LanguageRank"

Since we have our flow matrix, we want to know which languages are the most and the least popular. It is possible to calculate [centrality measures](https://en.wikipedia.org/wiki/Centrality) on the represented graph, e.g. the eigenvector centrality. Indeed, these measures convey the relative popularity of languages in the sense of how likely people coding in one language would switch to another. We will take the approach of calculating the eigenvector centrality. If you need further explanations, I invite you to read Vadim's PageRank analysis in his blog post about the [GitHub Contributions Graph](https://blog.sourced.tech/post/handshakes_pagerank/).

1. Our flow matrix contains strictly positive elements, which is a sufficient condition to make it [irreducible](https://en.wikipedia.org/wiki/Irreducibility_(mathematics)) ; there is always a way to reach all other languages from any given one. Thus, according to [Perron–Frobenius theorem](https://en.wikipedia.org/wiki/Perron%E2%80%93Frobenius_theorem), we are looking for the greatest eigenvalue and its corresponding eigenvector.

2. We can use the [Power Iteration](https://en.wikipedia.org/wiki/Power_iteration) algorithm to find the dominant eigenvector. Nevertheless, in addition to be irreducible, the matrix needs to be stochastic and aperiodic.

3. Our flow matrix becomes [stochastic](https://en.wikipedia.org/wiki/Stochastic_matrix) when removing the main diagonal and normalizing the rows. The greatest eigenvalue is now equal to 1.

4. Finally, to make our matrix [aperiodic](https://en.wikipedia.org/wiki/Markov_chain) and well conditioned, there is a famous trick introduced by Larry and Sergey in 1998. It is well explained in [Stanford’s CS246](http://snap.stanford.edu/class/cs246-2013/slides/09-pagerank.pdf) but to make it short, it mainly consists of updating our flow matrix using the following formula:

$$
P = \\beta P + \\frac{1-\\beta}{N}\\left( \\begin{array}{cccc}
1 & 1 & ... & 1 \\\\\\
1 & 1 & ... & 1 \\\\\\
... & ... & \\ddots & ... \\\\\\
1 & 1 & ... & 1 \\end{array} \\right)
$$

where,

* \\(\\beta~\\) is called random walk factor and is set to 0.85
* N   is the number of languages

### Power Iteration

After these steps our well conditioned flow matrix contains an approximation of the probabilities of switching between languages, and we can proceed with the power iteration. This algorithm consists of the following matrix multiplication until convergence to the dominant eigenvector:
$$
x_ {i+1} = P\\cdot x_ i
$$

Below, you will find the code that returns the wanted dominant eigenvector.

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
{{% center %}}
Power Iteration algorithm, Python.
{{% /center %}}


### Most popular languages on GitHub

At last! Here is the reward: the stationary distribution of our [Markov chain](https://en.wikipedia.org/wiki/Markov_chain). This probability distribution is independent of the initial distribution. It gives information about the stability of the process of random switching between languages. Thus, no matter how popular the languages are at the present time, the hypothetical future stationary state stays the same. Here is the popularity ranking of our 25 languages used on GitHub:

<table>
<thead>
    <tr>
      <th>Rank</th>
      <th>Language</th>
      <th>Popularity, %</th>
      <th>Source code, %</th>
    </tr>
    </thead>
    <tbody>
    <tr>
      <td>1.</td>
      <td>Python</td>
      <td>16</td>
      <td>11.2</td>
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
    <td>9.1</td>
    <td>17.1</td>
  </tr>
  <tr>
    <td>4.</td>
    <td>C++</td>
    <td>9</td>
    <td>12.6</td>
  </tr>
  <tr>
    <td>5.</td>
    <td>PHP</td>
    <td>8.3</td>
    <td>24.3</td>
  </tr>
  <tr>
    <td>6.</td>
    <td>Ruby</td>
    <td>8.1</td>
    <td>2.6</td>
  </tr>
  <tr>
    <td>7.</td>
    <td>C#</td>
    <td>6</td>
    <td>6.5</td>
  </tr>
  <tr>
    <td>8.</td>
    <td>Objective-C</td>
    <td>3.9</td>
    <td>3.2</td>
  </tr>
  <tr>
    <td>9.</td>
    <td>Go</td>
    <td>3.1</td>
    <td>0.7</td>
  </tr>
  <tr>
    <td>10.</td>
    <td>Swift</td>
    <td>2.5</td>
    <td>0.4</td>
  </tr>
  <tr>
    <td>11.</td>
    <td>Scala</td>
    <td>2.2</td>
    <td>0.4</td>
  </tr>
  <tr>
    <td>12.</td>
    <td>Perl</td>
    <td>1.9</td>
    <td>0.9</td>
  </tr>
  <tr>
    <td>13.</td>
    <td>Haskell</td>
    <td>1.7</td>
    <td>0.2</td>
  </tr>
  <tr>
    <td>14.</td>
    <td>R</td>
    <td>1.7</td>
    <td>0.4</td>
  </tr>
  <tr>
    <td>15.</td>
    <td>Lua</td>
    <td>1.6</td>
    <td>0.7</td>
  </tr>
  <tr>
    <td>16.</td>
    <td>Matlab</td>
    <td>1.6</td>
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
    <td>0.9</td>
    <td>0.4</td>
  </tr>
  <tr>
    <td>21.</td>
    <td>Common Lisp</td>
    <td>0.8</td>
    <td>0.2</td>
  </tr>
  <tr>
    <td>22.</td>
    <td>Fortran</td>
    <td>0.8</td>
    <td>0.3</td>
  </tr>
  <tr>
    <td>23.</td>
    <td>Kotlin</td>
    <td>0.8</td>
    <td>0.02</td>
  </tr>
  <tr>
    <td>24.</td>
    <td>Pascal</td>
    <td>0.7</td>
    <td>0.5</td>
  </tr>
  <tr>
    <td>25.</td>
    <td>Cobol</td>
    <td>0.6</td>
    <td>0.01</td>
  </tr>
  </tbody>
</table>

{{% center %}}
Popularity of languages according to
<a href="https://en.wikipedia.org/wiki/Centrality">centrality measure</a> on GitHub
{{% /center %}}

**Python** (16 %) appears to be the most attractive language, followed closely by **Java** (15.3 %). It's especially interesting since only 11.2 % of all source code on GitHub is written in **Python**.

In Erik's ranking, **Go** was the big winner with 16.4 %. Since Erik based his approach on Google queries, it seems that the buzz around Go, which makes people wonder explicitly in blogs if they should move to this language, takes a bit of time to produce projects effectively written in **Go** on GitHub.

Furthermore, **C** (9.1 %) is doing well according to Erik's grading of 14.3 %, though it is due to the amount of projects coded in **C** on GitHub.

Although there are ten times more lines of code on GitHub in **PHP** than in **Ruby**, they have the same stationary distribution.

**Go** (3.1 %) appears on the 9th position which is largely honorable given the small proportion (0.7 %) of **Go** projects which are hosted on GitHub. For example the same proportion of projects are written in **Perl**, but this language doesn't really stir up passion (1.9 % popularity).

### What about sticking to a language ?

If we keep the main diagonal of our transition matrix before applying the power iteration, we obtain slightly different results. It mainly decreases top languages popularity while raising the smaller ones'. Indeed, it seems reasonable to believe that developers who invest their time in mastering languages on the fringe of the others tend to stick to them unlike with the popular ones.

In the rest of the post we will consider our first representation of the dominant eigenvector.

### Back to the transition matrix

Erik's transition matrix is sorted so that the most popular languages appear at the bottom. We sort ours in the same order to compare them:

{{% grid %}}
{{% grid-cell %}}
{{% caption src="/post/language_migrations/sum_matrix_wdiag_25lang_eig.svg" %}}
source{d}'s sorted transition matrix, Erik's order
{{% /caption %}}
{{% /grid-cell %}}

{{% grid-cell %}}
{{% caption src="/post/language_migrations/erik_green.png" %}}
Erik's sorted transition matrix
{{% /caption %}}
{{% /grid-cell %}}
{{% /grid %}}

This is our matrix independently sorted:

{{% caption src="/post/language_migrations/sum_matrix_22lang_eig.svg" %}}
source{d}'s sorted transition matrix, original order
{{% /caption %}}

* Developers coding in one of the 5 most popular languages (**Java**, **C**, **C++**, **PHP**, **Ruby**) are most likely to switch to **Python** with approx. 24% chance on average.

* Besides, according to Erik's matrix, people switch from **Ojective-C** to **Swift** and back with greater probabilities - 24% and 19% accordingly.

* Similarly, a **Visual Basic** developer has more chance (24%) to move to **C#** while Erik's is almost sure in this transition with 92% chance.

* Users of **Clojure**, **C#** and, above all, **Scala** would rather switch to **Java** with respectively 21, 29 and 39% chance.

* People using numerical and statistical environments such as **Fortran** (36 %), **Matlab** (33 %) or **R** (40 %) are most likely to switch to **Python** in contrast to Erik's matrix which predicts **C** as their future language.

* One common point I found with Erik's results about **Go** is that it attracts people who gave up studying **Rust**.

## Over the last 16 years

As we mentioned earlier, before summing the transition matrices over time, we now consider specific years and examine how these yearly matrices look like. Do they express the same language profiles? How has it been evolving since the early 2000's? Here is a sample of 4 matrices from various timeline intervals:

{{% grid %}}
{{% grid-cell %}}
{{% caption src="/post/language_migrations/P_2005.svg" %}}
2005 - 2006
{{% /caption %}}
{{% /grid-cell %}}

{{% grid-cell %}}
{{% caption src="/post/language_migrations/P_2011.svg" %}}
2011 - 2012
{{% /caption %}}
{{% /grid-cell %}}
{{% /grid %}}

{{% grid %}}
{{% grid-cell %}}
{{% caption src="/post/language_migrations/P_2008.svg" %}}
2008 - 2009
{{% /caption %}}
{{% /grid-cell %}}

{{% grid-cell %}}
{{% caption src="/post/language_migrations/P_2015.svg" %}}
2015 - 2016
{{% /caption %}}
{{% /grid-cell %}}
{{% /grid %}}

{{% center %}}
Temporal evolution of transition matrices
{{% /center %}}

In the end, the evolution of these matrices over time seems to be affine, and we observe the same language profile every year. Thus, to highlight the time-line of this language profile, we apply the power iteration to each matrix. Earlier, we averaged the stationary distribution over the last 16 years but now we look at its chronological sequence. The resulting series of the dominant eigenvectors is presented below on the stack area plot.

{{% caption src="/post/language_migrations/eigenvect_stack_22lang.png" %}}
Stationary distribution of languages over the last 16 years
{{% /caption %}}

The thickness of each band corresponds to the value in the dominant eigenvector. The bands are sorted by the averaged popularity which we calculated before.

* The first two languages, **Python** and **Java** have the same profile. They have been taking the place of **C** for 15 years. Indeed, the aggregation of these first 3 layers gives a straight one.

* The attractiveness of **C++** dropped prominently in 2008 when languages like **Java** or **Ruby** started growing rapidly. Nevertheless, it has been sustaining its popularity ever since this period.

* I definitely support Erik's conclusion that **Perl** is dying.

* **Apple** presented **Swift** on [WWDC'2014](https://developer.apple.com/videos/play/wwdc2014/402/) and it was supposed to replace **Obj-C**. So **Obj-C** adoption should start to decrease after that event, but the sum of both languages should remain the same. Looking at the figure, this hypothesis turns out to be right.

* **Ruby** appears to have had 6 years of glory starting from 2007. It might be explained with the launch of the web framework, [Ruby on Rails](https://en.wikipedia.org/wiki/Ruby_on_Rails) (RoR), which reached a milestone when Apple announced that it would ship it with [Mac OS X v10.5 "Leopard"] (https://en.wikipedia.org/wiki/Mac_OS_X_Leopard) - released in October.

* Regarding **Go**, the popularity stays relatively low. However, the dynamics is clearly positive.

## Update 1

I read some concerns about the language verbosity bias after publishing the post. They are fair: the global quantization scheme may give an advantage to verbose languages like **Java** in difference to condensed ones like **Haskell**. I quantized each of the languages independently and re-run the rest of the analysis. As you can see in the table below, nothing really changed; **Ruby** and **C++** exchanged the position, but their ranks are really close to each other. The final history plot looks exactly the same.

<table>
      <thead>
    <tr>
      <th>Rank</th>
      <th>Language</th>
      <th>Popularity, %</th>
      <th>Moves</th>
    </tr>
    </thead>
    <tbody>
    <tr>
      <td>1.</td>
      <td>Python</td>
      <td>16.2</td>
      <td>+ 0.2</td>
    </tr>
    <tr>
      <td>2.</td>
      <td>Java</td>
      <td>14.6</td>
      <td>- 0.7</td>
    </tr>
  <tr>
    <td>3.</td>
    <td>C</td>
    <td>9.7</td>
    <td>+ 0.6</td>
  </tr>
  <tr>
    <td>4.</td>
    <td>Ruby</td>
    <td>8.5</td>
    <td>+ 0.4</td>
  </tr>
  <tr>
    <td>5.</td>
    <td>PHP</td>
    <td>8.4</td>
    <td>+ 0.1</td>
  </tr>
  <tr>
    <td>6.</td>
    <td>C++</td>
    <td>8.4</td>
    <td>- 0.6</td>
  </tr>
  <tr>
    <td>7.</td>
    <td>C#</td>
    <td>5.5</td>
    <td>- 0.5</td>
  </tr>
  <tr>
    <td>8.</td>
    <td>Objective-C</td>
    <td>3.6</td>
    <td>- 0.3</td>
  </tr>
  <tr>
    <td>9.</td>
    <td>Go</td>
    <td>3.3</td>
    <td>+ 0.2</td>
  </tr>
  <tr>
    <td>10.</td>
    <td>Swift</td>
    <td>2.5</td>
    <td> - </td>
  </tr>
  <tr>
    <td>11.</td>
    <td>Scala</td>
    <td>2.3</td>
    <td>+ 0.1</td>
  </tr>
  <tr>
    <td>12.</td>
    <td>Perl</td>
    <td>2.1</td>
    <td>+ 0.2</td>
  </tr>
  <tr>
    <td>13.</td>
    <td>Haskell</td>
    <td>1.8</td>
    <td>+ 0.1</td>
  </tr>
  <tr>
    <td>14.</td>
    <td>R</td>
    <td>1.7</td>
    <td> - </td>
  </tr>
  <tr>
    <td>15.</td>
    <td>Lua</td>
    <td>1.7</td>
    <td>+ 0.1</td>
  </tr>
  <tr>
    <td>16.</td>
    <td>Matlab</td>
    <td>1.5</td>
    <td>- 0.1</td>
  </tr>
  <tr>
    <td>17.</td>
    <td>Clojure</td>
    <td>1.6</td>
    <td>+ 0.1</td>
  </tr>
  <tr>
    <td>18.</td>
    <td>Rust</td>
    <td>1.2</td>
    <td> - </td>
  </tr>
  <tr>
    <td>19.</td>
    <td>Erlang</td>
    <td>1.1</td>
    <td>+ 0.1</td>
  </tr>
  <tr>
    <td>20.</td>
    <td>Visual Basic</td>
    <td>0.9</td>
    <td> - </td>
  </tr>
  <tr>
    <td>21.</td>
    <td>Common Lisp</td>
    <td>0.8</td>
    <td> - </td>
  </tr>
  <tr>
    <td>22.</td>
    <td>Fortran</td>
    <td>0.7</td>
    <td>- 0.1</td>
  </tr>
  <tr>
    <td>23.</td>
    <td>Kotlin</td>
    <td>0.8</td>
    <td> - </td>
  </tr>
  <tr>
    <td>24.</td>
    <td>Pascal</td>
    <td>0.7</td>
    <td> - </td>
  </tr>
  <tr>
    <td>25.</td>
    <td>Cobol</td>
    <td>0.6</td>
    <td> - </td>
  </tr>
</tbody>
</table>

## Update 2

I have added the missing three languages : **Cobol**, **Kotlin**, and **Common Lisp**.

## Notebook

I used the following [Jupyter](http://jupyter.org/) notebook to prepare the post:

{{% gist warenlg "fc906334857bf66941165edfe8f76b4c" %}}

## Conclusion

It would be more appropriate to see Erik's contingency table as a kind of the second derivative of the languages distribution problem while our flow transitions are like the first derivative. That is, first you google, then you try to write an OSS project, and finally the languages distribution changes.

## Acknowledgements

I want to thank my tutor at source{d}, [Vadim Markovtsev](https://twitter.com/tmarkhor), for his guidance all along this study, as well as people working with us for their patience in giving me valuable insights.

<script async src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS_CHTML"></script>
<script async type="text/x-mathjax-config">
MathJax.Hub.Config({
  TeX: { equationNumbers: { autoNumber: "AMS" } }
});
</script>
