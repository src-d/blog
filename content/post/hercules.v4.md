---
author: vadim
date: 2018-08-29
title: "MLonGit: Hercules v4 released"
image: /post/hercules.v4/intro.png
description: "src-d/hercules is an open source project started in late 2016 with the goal to speed up collecting line burndown statistics from Git repositories. It has transformed into a general purpose Git repository mining framework with several cool use cases: ownership through time, file and people embeddings, structural hotness and even comment sentiment estimation. The post presents the latest 'v4' release of Hercules and gives some insights into how Git works."
categories: ["MLonCode", "technical"]
---

This post follows up [the first one from January 2017](../hercules). Please read it
if you wonder why Hercules was named Hercules, what is a line burndown plot and how
everything started.

# v4 features

The main features of the recent release:

1. Hercules is now aware of forks and merges and thus visits all the commits in the history, not just the main linear sequence as before.
2. External plugins.
3. Merging results from multiple repositories together.
4. More "batteries" included: ownership, files, people, structure embeddings, comment sentiment.

### Forks and merges

The difference is the best to show rather than explain:

{{% caption src="/post/hercules.v4/forks_merges.gif" %}}
Prior to v4, Hercules did not process the full commit history and worked with it as a linear sequence.
{{% /caption %}}

This feature yields an improvement of the analysis accuracy. However, nothing
is free, unfortunately: processing all the commits can considerably slow down the analysis.
git/git used to be analyzed in less than 4 minutes - now it is 2 hours 45 minutes.
Of course, git/git is clearly an outlier since it uses branching **a lot**, yet still
it can be reasonable to follow the old behavior sometimes. Therefore `hercules --first-parent` flag exists.

Here is the before/after animation of git/git's burndown:

{{% caption src="/post/hercules.v4/git_git.gif" %}}
Forks and merges result in more alive lines due to side branches.
{{% /caption %}}

### Plugins

It is possible to load and run a plugin on Linux:

```
hercules --plugin /path/to/plugin.so --whatever-analysis-it-defines https://github.com/git/git > result.yml
```

Plugins are loaded before generating the help message, so it is possible to
inspect a plugin:

```
hercules --plugin /path/to/plugin.so --help
```

There is a sample plugin to collect the [code churn](https://github.com/src-d/go-git/graphs/code-frequency) statistics in `contrib/_plugin_example`. If you want to build and run that plugin, execute **on Linux**:

```
cd contrib/_plugin_example
make
hercules --plugin churn_analysis.so --churn https://github.com/your/project > churn.yml
```

It is also possible to generate the skeleton code of a new plugin:

```
hercules generate-plugin -n TestAnalysis -o test_analysis
```

That command writes 4 files: `Makefile`, `test_analysis.go`, `test_analysis.pb.go`, `test_analysis.proto`.
The last two are related to the optimized binary result serialization using Protocol Buffers.

### Merging results

This feature is useful for those who want to join the analysis several Git repositories together.
It works only with the binary result format (Protocol Buffers).

```
hercules combine one.pb two.pb three.pb > joined.pb
```

### Batteries

#### Code ownership

{{% caption src="/post/hercules.v4/ownership.png" %}}
Ownership by lines of code in [tensorflow/tensorflow](https://github.com/tensorflow/tensorflow).
{{% /caption %}}

Code ownership plots how many lines are last edited by each developer through time.
How to reproduce the image:

```
hercules --burndown --burndown-people --pb https://github.com/tensorflow/tensorflow | tee tensorflow.pb | labours.py -m ownership
```

The overall lines count in Tensorflow is around 3 million as can be plotted with `--project`.
It can be seen that roughly ⅓ of the Tensorflow codebase belongs to the [Gardener bot](https://github.com/tensorflower-gardener). That's because much of the real development
does not happen on GitHub but rather internally at Google and the cumulative
merges are performed from time to time. It can also be seen that all the top 20
contributors are from Google.

#### Developers interaction

{{% caption src="/post/hercules.v4/churn_matrix.png" %}}
Mutual edits in [tensorflow/tensorflow](https://github.com/tensorflow/tensorflow).
{{% /caption %}}

This analysis shows what are the proportions of lines added by a developer (rows)
and overwritten by other developers (columns). E.g. the image above shows
that the Gardener bot overwrote nearly everybody. It also shows that
[François Chollet](https://github.com/fchollet) worked on the same code as
[Yifei Feng](https://github.com/yifeif) and Hanna Revinskaya.
How to reproduce the image:

```
hercules --burndown --burndown-people --pb https://github.com/tensorflow/tensorflow | tee tensorflow.pb | labours.py -m churn_matrix
```

#### Files, developers, functions and classes in 3D

If you haven't read [Your Code as a Crime Scene](https://pragprog.com/book/atcrime/your-code-as-a-crime-scene)
by Adam Tornhill, stop reading this post, allocate a few hours and look it through - the book is awesome.
One of the ideas from the book is to investigate which files are _coupled_ - often appear together.
The corresponding analysis in Hercules goes a bit further and puts all the files
into the 3D space with the property that the distance between coupled files is small.

{{% caption src="/post/hercules.v4/couples.png" %}}
Files coupling in [tensorflow/tensorflow](https://github.com/tensorflow/tensorflow). [Click here for an interactive experience.](http://projector.tensorflow.org/?config=http://vmarkovtsev.github.io/projector/tf_files.json)
{{% /caption %}}

Reproduce:
```
hercules --couples --pb https://github.com/tensorflow/tensorflow | labours.py -m couples -o tensorflow
```

We can repeat the same trick with the developers: they are couples if they commit
to the same files. [Interactive example on Tensorflow developers.](http://projector.tensorflow.org/?config=http://vmarkovtsev.github.io/projector/tf_people.json)

Finally, the trick works once again with structural units in the source code. We parse
each file with [Babelfish](https://doc.bblf.sh) and extract anything we wish: functions,
classes, etc. Then we apply the same coupling analysis to them: we know which are changed
in each commit.

By default, the functions are extracted.
```
hercules --shotness --pb https://github.com/tensorflow/tensorflow | labours.py -m shotness -o tensorflow
```

#### Comment sentiment

This is a proof-of-concept for running a Tensorflow model over the source code.
We take [BiDiSentiment](https://github.com/vmarkovtsev/BiDiSentiment) and apply it to comments.
That model is general-purpose and the result is often weird, but it works.
I wrote about it in [the other blog post](../codesent).

Your binary must be compiled with Tensorflow support (the released one is **not**).
```
hercules --sentiment --pb https://github.com/tensorflow/tensorflow | labours.py -m sentiment
```

# v4 architecture

Hercules is built on top of the `Pipeline` which is a Directed Acyclic Graph (DAG) of `PipelineItem`-s.
Each pipeline item has a name and specifies its dependencies and what it provides in return.
For example, a `RenameAnalysis` item detects the renamed and slightly changed files between two commits.
It consumes the list of changes and the list of corresponding blobs. It calculates
a better list of changes with some of the "delete + create" pairs replaced with
single "edit under new name" elements. Yep, Git packfiles do not store this kind
of information (intentionally) and `git` detects renames using heuristics every
time you execute it.

Hercules builds the DAG of pipeline items automatically based on their dependencies
and provided intermediate results. Some items try to improve on the others -
`RenameAnalysis` for example, and Hercules understands that and correctly resolves
the structure: all the rest of the items which depend on that type of analysis are
pointed from the "improved" ones, and the "improved" ones in turn depend on the
"basic" ones. Here is an example of the built pipeline to calculate the burndown
stats:

{{% caption src="/post/hercules.v4/pipeline.png" %}}
Pipeline DAG example.
{{% /caption %}}

Once the pipeline is built, each item changes its state in certain ways.
Here is the most full example of the "leaf" item which does not provide any
intermediate results but rather a final result:

{{% caption src="/post/hercules.v4/item.png" width="half-width" %}}
Item lifecycle.
{{% /caption %}}

Each item is configured - its parameters are adjusted as needed. Returning
to `RenameAnalysis`, we can set the file similarity threshold from 0 to 100 which
influences the aggressiveness of the matching algorithm. Then each item is
initialized. At this stage it validates the configured parameters and resets
the internal state structures. The next stage is the main one: consuming
commits one after another. Git history is usually not linear - instead, it contains
forks and merges with numerous branches. Thus items are forked and merged as needed.
A "fork" of an item clones it the required number of times, and the states of
the clones are combined together during "merges". The internal state of an item
is normally shared and no special arrangements are performed during forks
and merges, but sometimes there appear serious problems and nontrivial solutions
(see the next section). Some branches are no longer used after merges and the
corresponding cloned items are garbage collected.

When the whole history is processed Hercules asks "leaf" pipeline items to
generate the result. Those results are serialized and written to the output stream.
It is also possible to load several serialized results from disk and combine
them together - for example, to obtain the grand view across the company's repositories.

This versatile architecture allows Hercules to efficiently analyze small and big
Git repositories while minimizing the complexity and boilerplate code to add
new analysis types.

# v4 challenges

There were three most difficult technical challenges which had to be solved in v3 and v4:

1. Merging results together.
2. Forks and merges behavior of `PipelineItem`-s.
3. Determine the order in which to process commits, forks, merges and garbage collect branches.

The first two were especially hard to solve for the line burndown analysis. Regarding (1),
the results can be sampled and band-split with different frequencies, so it was
required to resample and interpolate the matrices by day, sum them and then
sample and split into bands again.
[One of the scariest functions I have ever written.](https://github.com/src-d/hercules/blob/99abfb229a880d55462eecd2373433df686f8fcc/leaves/burndown.go#L441).
Regarding (2), it was needed to write the code to merge multiple line interval-marked
files together and organize the work with a partially shared, partially copied state.
Git merge does not necessarily contain two branches: it can be three, four, etc.

{{% caption src="/post/hercules.v4/git_abstract.png" %}}
Abstract from [git/git](https://github.com/git/git) history.
{{% /caption %}}

I did not come up with a solution better than mark the changed line intervals in files
while consuming a merge commit with a special outlier value, then
annotate each line of the each merged file, and copy the only real last edit date
over those marked as outliers. In places of same edits but conflicting dates we
choose the oldest date. In places of merge conflicts we automatically get the date
of the merge commit without special tricks. We should not compare the files
which are not involved in the merge, so we keep track of their hashes, we maintain
them. I also had to rewrite the statistics storage logic which used to be too
"sequential". Overall, fulfilling (2) was a technical nightmare.

Surprisingly, however, most of the efforts went to (3). The first problem was
related to minimizing the number of forks and merges, in particular removing
the no-op fast-forward-like back edges of the DAG.

{{% caption src="/post/hercules.v4/ff.gif" %}}
Example of the removal of a fast-forward DAG edge.
{{% /caption %}}

We [topologically sort](https://en.wikipedia.org/wiki/Topological_sorting)
the nodes of our DAG and traverse it starting from the root.
Each time we suspect that an edge can be removed we traverse backward from the children
until we reach the node we have already visited. If that node is the same as the parent
then indeed we can remove the edge.

The second problem was that the Git history may have more than one root commit so
we need to find the main root and take into account the side effects.
Don't believe me? Here is how [gitk](https://git-scm.com/docs/gitk) was merged inside git/git:

{{% caption src="/post/hercules.v4/gitk.png" %}}
Example of multiple DAG roots: [5569bf9](https://github.com/git/git/commit/5569bf9bbedd63a00780fc5c110e0cfab3aa97b9).
{{% /caption %}}

The third problem was related to how Hercules works: it is able to analyze any
set of commits, not just the whole master. There is no guarantee that the commits
are connected at all, so we have to run the [connected components analysis](https://en.wikipedia.org/wiki/Connected-component_labeling)
first to throw away everything but the main component (which has the biggest number of nodes).

The fourth problem was to schedule the garbage collection - remove the
clones which are no longer needed. We do a DAG traversal and mark the places
where branches were last used, then we insert branch disposals after the resulting
marks.

It was very helpful to debug with [`git bisect`](https://git-scm.com/docs/git-bisect).
Normally people bisect to find regressions; I bisected to find offending commits which broke Hercules.

# You can help!

Hercules can do so many things better! Here is a list of cool features you can work on:

* Count lines with [enry](https://github.com/src-d/enry) and plot charts by language.
* Apply PageRank to the structural edits and find the most impactful developers (aka [Sourcecred](https://github.com/sourcecred/sourcecred)).
* Detect minor commits using machine learning.
* Plot with Go, not with Python.
* Integrate into [GitBase](https://github.com/src-d/gitbase) as a set of User Defined Functions.
* Do something with the awful plot design. [My colleague Maxim has attempted already.](https://github.com/smacker/hercules-web)

> The most exciting time is still ahead.