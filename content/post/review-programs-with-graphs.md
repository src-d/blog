---
author: alex
date: 2018-10-02
title: "Paper review: “Learning to Represent Programs with Graphs”"
image: /post/review-programs-with-graphs/paper-figure-2.jpg
description: "A review of the recent ML-on-Code paper from Microsoft Research."
categories: ["science", "technical"]
---

ML on Code is a rapidly developing field, both in academia and industry, that [source{d}](http://sourced.tech/)
was set out to systematically explore throughout the last years. So far the results published by our
Data Retrieval, Machine Learning, and Infrastructure teams who collect and store [millions of Git repositories](/post/github_stats)
were based on large-scale applications of advanced NLP techniques such as: [Identifiers Embedding](https://blog.sourced.tech/post/id2vec/),
[Topic Modeling](https://arxiv.org/abs/1704.00135) and sequence model for [Identifier Splitting](https://arxiv.org/abs/1805.11651).
Current research avenues, driven by the applications for assisted code review, include models using
more structured representations of the source code, based on [Universal Abstract Syntax Trees](https://doc.bblf.sh/uast/uast-specification.html) and graphs.

That is why the second paper that is covered here will be on recent advances in program representations suitable
for Machine Learning that go beyond syntax and traditional NLP techniques.

## Source Code as a Graph

[“Learning to Represent Programs with Graphs”](https://arxiv.org/abs/1711.00740) — a paper from
[“Deep Program Understanding” group](https://www.microsoft.com/en-us/research/project/program/)
at Microsoft Research was presented at [ICLR 2018](https://iclr.cc/archive/www/doku.php%3Fid=iclr2018:main.html) earlier this year.

{{% tweet 958128393027047424 %}}

 This work is particularly interesting example of research for a few reasons:

* has an interesting background, rooted in physics research,
* explores structured, graph-based representations,
* includes but goes beyond purely syntactic features,
* model has official open source implementation (open science!),
* and this knowledge was actually applied in industry, to build a real product

We’ll summarize briefly the paper itself in the next sections, but first some background on the main Machine
Learning model used in the paper — **“Gated Graph Neural Networks”**. 🕵

### History: chemistry -> message passing -> ML on Code

In the official [model's repository README](https://github.com/Microsoft/gated-graph-neural-network-samples#gated-graph-neural-networks)
 the authors share that the inspiration for this work comes from another field of ML research: Quantum Chemistry.

Interestingly enough, in a few recent talks, Jeff Dean while talking about most exciting advances in ML applications
mentions Quantum Chemistry as well:

* [TWiML & AI](https://medium.com/@twimlai) podcast episode [“Systems and Software for Machine Learning at Scale”](https://twimlai.com/twiml-talk-124-systems-software-machine-learning-scale-jeff-dean/)

* [Matroid](https://www.matroid.com/) conference [Scaled Machine Learning](http://scaledml.org/) talk [“Systems and Machine Learning”](https://www.matroid.com/scaledml/2018/jeff.pdf)

{{% caption src="/post/review-programs-with-graphs/model-properies-prediction.png" title="ML application in quantum physics" %}}
ML application in quantum physics. Source: Jeff Dean [slides](https://www.matroid.com/scaledml/2018/jeff.pdf)
{{% /caption %}}

The fundamental idea is well-understood — given a [Schrödinger equation](https://en.wikipedia.org/wiki/Schr%C3%B6dinger_equation),
one can get information about the state of a single particle, thus solving it for composition would allow to
model properties of more complex structures, including molecules and in general, solid state matter. But
solving the many-body Schrödinger equation requires huge computational efforts.

Instead, a [Nobel prize winning](https://www.nobelprize.org/nobel_prizes/chemistry/laureates/1998/) modeling
approach called [Density Functional Theory](https://en.wikipedia.org/wiki/Density_functional_theory) or DFT can be
applied, reducing the problem of many-body interacting system to a series of single-body problems and although still
slow, it is highly valuable for many tasks in physics, chemistry and material science. Many approximation methods
have been developed to make this more feasible by getting estimates instead of exact answers.

### Neural Networks for predicting properties of molecules

Many DFT calculation [software simulators](https://en.wikipedia.org/wiki/List_of_quantum_chemistry_and_solid-state_physics_software) already exist, but are slow and still computationally intensive.
In 2014 those simulators were used to build a [reference dataset — QM9](http://quantum-machine.org/datasets/), suitable for appling supervised learning algorithms.

So in 2017, several researchers at the Google Brain Residence program spent time applying Neural Networks for predicting properties of molecules on that dataset:

* a new “featurization” method was proposed, for looking at molecular structure as a graph: atoms as nodes and bonds as edges

* a new variation of the [Gated Graph Neural Network](https://arxiv.org/abs/1511.05493) architecture was proposed, particularly suited for summarizing properties of such graphs

Every such graph representing a molecule could be treated as a “computational graph”, thus the usual Neural Network
training techniques could be applied to build node embeddings and given such a model the desired properties of
the molecule could be learned in a supervised fashion, as a function of the whole graph.

{{% caption src="/post/review-programs-with-graphs/mpnn-aprox-dft.png" title="MPNN illustration from the paper 'Neural Message Passing for Quantum Chemistry'" %}}
MPNN illustration from ["Neural Message Passing for Quantum Chemistry"](https://arxiv.org/abs/1704.01212)
{{% /caption %}}

The blog post titled  [“Predicting properties of molecules”](https://research.googleblog.com/2017/04/predicting-properties-of-molecules-with.html) by Google Research
dives deeper into details, but this work, in particular, has several valuable meta-lessons to teach on conducting a
novel research in applied Machine Learning:

* a single, shared benchmark QM9 was used (based on DFT, previous simulation approach),

* a systematic assessment of existing machine learning methods on the QM9 benchmark was conducted, and a new featurization
 method was proposed in the first paper [“Machine learning prediction errors better than DFT accuracy”](https://arxiv.org/abs/1702.05532),

* a general model family of “Message Passing Neural Networks” (MPNNs), with a particular model that improves results
 by the factor of ~4 was proposed in the second paper on [“Neural Message Passing for Quantum Chemistry”](https://arxiv.org/abs/1704.01212),

* research was not only a leaderboard-driven - a high-level interpretation/hypothesis was also provided: models that can leverage inherent symmetries in data will tend to generalize better


## Paper highlights

Now back to [“Learning to Represent Programs with Graphs”](https://arxiv.org/abs/1711.00740)

A new “featurization” of code was proposed: a “program graph”, or a single unified graph containing AST + data
flow + types information.

**model architecture**: GG-NN ([code](https://github.com/Microsoft/gated-graph-neural-network-samples))

**data**: 2.9m LoC, 29 big projects ([data](https://msropendata.com/datasets/a8a6aa9d-521b-420b-a281-9807000d2b92))

**evaluation on tasks**:

  * new task proposed: *VarMissuse*, benchmarked agains BiRNN baseline
  * old task used *VarName*, benchmarked against [previous models](https://miltos.allamanis.com/publications/2015suggesting/)

**results**:

  * 32.9% accuracy on the *VarNaming*
  * 85.5% accuracy on the *VarMisuse* task
  * [real](https://github.com/dotnet/roslyn/pull/23437) [bugs](https://github.com/ravendb/ravendb/pull/4138) in OSS projects fixed

**constraints:** statically typed languages, C# (only a subset, buildable with [dotnet/roslyn](https://github.com/dotnet/roslyn))

## A Brief summary

### **Graph construction**

A “program graph” with syntax information, data-flow information, and type information was introduced.

{{% caption src="/post/review-programs-with-graphs/graph-edges-construction.png" title="Graph structure illustration from paper 'Learning to Represent Programs with Graphs' " %}}
Graph structure illustration from ['Learning to Represent Programs with Graphs'](https://arxiv.org/abs/1711.00740)
{{% /caption %}}

The program graph consists of an syntactic information from AST plus semantic information about data and control flows, using 10 different types of edges (contributes proportionally to runtime complexity):

* *Child/NextToken* — edges to model AST on tokens

* *LastRead/LastWrite/ComputedFrom* — edges for variables. Model control flow/data flows

* *LastLexicalUse* — chain uses of the same variable

* *GuardedBy/GuardedByNegation* — enclosing guard expression that uses this variable

* *FormalArgName* — connect method call arguments to it’s name/type declaration

* *ReturnsTo* — links *return* tokens to name/type in method declaration


### **Model details: GG-NN**

The concrete architecture used was *[Gated Graph Sequence Neural Networks* or *GG-NN*:

* original paper, introducing this model ["Gated Graph Sequence Neural Networks"](https://arxiv.org/abs/1511.05493)

* official implementation in Torch [github.com/yujiali/ggnn](https://github.com/yujiali/ggnn)

Below is a very brief recap of GG-NN, a recurrent network from a family of “Message Passing Neural Networks”.

*Input*: a graph, *Output*: a sequence. Proposed implementation uses GRU, unrolls the recurrence for a fixed number
of steps and use truncated backpropagation through time in order to compute gradients.

The idea is:

* an input graph can be treated as “computation graph”

{{% caption src="/post/review-programs-with-graphs/gg-nn.png" title="Graph structure illustration from tutorial 'Representation Learning on Networks', WWW 2018" %}}
source: tutorial ['Representation Learning on Networks'](http://snap.stanford.edu/proj/embeddings-www), WWW 2018.
{{% /caption %}}

* messages between nodes, as a way of “summarizing” the neighborhood for every node

* node embeddings thus can be learned, by propagating messages between connected nodes

* propagation happens step by step: the first step propagate information from direct neighbors, the second step from
  nodes 2 steps away, etc

* as NNs can be deep, to make training stable and avoid exploding/vanishing gradients use same ideas as in RNN:
  at every step, combine previous state + new input. Initial step concatenated embeddings of “node label” + “node type”.


Initial node state: *node name embedding*

{{% caption src="/post/review-programs-with-graphs/iclr-2018-post-node-embeddings.png" title="Node representation illustration" %}}
source: [ICLR 2018 poster](https://twitter.com/mmjb86/status/990717350197444609) by MSR
{{% /caption %}}

* average embeddings of the sub-tokens, split by *CamelCase* and *snake_case*
* concatenated with *type embedding*
* pass through a linear layer



The authors have also published a reference implementation of the GG-NN model in TensorFlow.

[**Microsoft/gated-graph-neural-network-samples** - Sample Code for Gated Graph Neural Networks](https://github.com/Microsoft/gated-graph-neural-network-samples)

To dive deeper into this method as well as other graph-based learning methods, we recommend checking Stanford’s
[SNAP tutorial on Representation learning on graphs](http://snap.stanford.edu/proj/embeddings-www/).

## Tasks

For each of 2 tasks used in this paper a slightly different “program graph” and GG-NN model architecture was proposed.

### *VarNaming*

{{% caption src="/post/review-programs-with-graphs/varnaming-task-iclr-2018-poster.png" title="Code, ilustrating VarNaming task" %}}
source: poster at ICLR 2018
{{% /caption %}}

*VarNaming* generates a sequence of identifier sub-tokens, as a function of the whole graph.

That is what authors call an example of “graph2seq architecture”:

* 8 time steps propagating GG-NN for each var occurrence, starting from the “initial state” described above

* average of all variable occurrences is input to one-layer GRU, trained with max likelihood, that outputs final
name as a sequence of sub-tokens

Accuracy for predicting the exact name and the F1 score for predicting its subtokens is reported.

### *VarMisuse*

{{% caption src="/post/review-programs-with-graphs/varnaming-task-iclr-2018-poster.png" title="Code, ilustrating VarMisuse task" %}}
source: poster at ICLR 2018
{{% /caption %}}

*VarMisuse* is “fill-in box” for variable name: predict which one of the existing variables can be used in a
given slot.

A single variable is “blanked out” from the graph by adding a *synthetic node.* The model is asked to predict the
originally used variable, out of the all known vars used.

This task is different from the seemingly close “code completion” task, as it deals only with variables and in
“mostly complete” programs.

Training for this task is a bit more involved:

* compute *context representation* for each slot, where we want to predict the used variable: insert a new node
corresponding to a “hole”, connect it to the remaining graph using all applicable edges that do not depend on the
chosen variable at the slot (everything but *LastUse*, *LastWrite*, *LastLexicalUse*, and *GuardedBy*)

* then compute *usage representation* of each candidate variable at the target slot: insert a *candidate node*
and connect it by inserting the *LastUse*, *LastWrite* and *LastLexicalUse* edges that would be used if the
variable were to be used at this slot

* use initial node representations, concatenated with an extra bit that is set to one for the candidate nodes

* 8 time-steps propagating GG-NN, to get *context* and usage *representation* as the final states of those nodes

* a linear layer that uses the concatenation of *context* and *usage* representations

* train using a max-margin objective

## Implementation insights

Few practical insides that were discovered, while building a model in TensorFlow include:

* use of SparseTensors for representing adjacency list, in order to batch efficiently
* represent batch-of-graphs as a one single graph \w disconnected components, in order to benefit from GPU
  parallelization

Summary, as a poster on ICLR 2018 conference by paper authors

{{% tweet 990717350197444609 %}}

**CODE**: MSR open sourced [a generic GG-NN implementation on TensorFlow](https://github.com/Microsoft/gated-graph-neural-network-samples)
with example usage “on a simpler task”, so it does not include functions for building the “program graphs” for
any of the two tasks above.

**DATA**: MSR has recently also published [a dataset of graphs](https://msropendata.com/datasets/a8a6aa9d-521b-420b-a281-9807000d2b92)
from the parsed source code used for this paper.

**EXPOSITION**: MSR members and original paper authors also did a really nice explanatory blog post, in particular
on a graph construction part at [Microsoft Research Blog](https://www.microsoft.com/en-us/research/blog/learning-source-code).

## Results

One thing that makes this research particularly interesting, is to see how a new, revamped
[Microsoft + Open Source](https://open.microsoft.com/) as a company managed to:

* conduct, publish and share the data and some code for an interesting research

* “productionaize” it as [InteliCode plugin](https://go.microsoft.com/fwlink/?linkid=872707) for Visual Studio

* [announce resulting product](https://blogs.msdn.microsoft.com/visualstudio/2018/05/07/introducing-visual-studio-intellicode/),
as a part of it’s [Build conference](https://www.microsoft.com/en-us/build), which seems to be getting lots of
interesting talks in recent years

Here is an example of one of the gems from previous Build conference: [**Thinking for Programmers**](https://channel9.msdn.com/Events/Build/2014/3-642) where Leslie Lamport, inventor of Paxos and developer of LaTeX introduces techniques and tools that help programmers think.

{{% center %}} … {{% /center %}}

For Microsoft, this is not the first attempt to add AI features to its market-leading code editor product: i.e
there is another VS extension called [Developer Assistant](https://marketplace.visualstudio.com/items?itemName=VisualStudioPlatformTeam.DeveloperAssistant)
from 2016. But this work, to the best of our knowledge, looks like a first one when such features are grounded
in a published scientific research.

{{% tweet 993874082193203200 %}}

Here it is 🍾🍾🍾 for the more companies to follow this path of building products!

------------

By the way, a good work does not need to happen only at the big companies:
[source{d}](https://twitter.com/sourcedtech) is a startup that has also published 3 academic papers over the
last year in ML-on-Code field:

 * [Topic modeling of public repositories at scale using names in source code](https://arxiv.org/abs/1704.00135)
 * [Public Git Archive: a Big Code dataset for all](https://arxiv.org/abs/1803.10144)
 * [Splitting source code identifiers using Bidirectional LSTM Recurrent Neural Network](https://arxiv.org/abs/1805.11651)

If you are interested in working on cutting-edge ML research and putting its results to production as an application
for assisted code reviews — please come join us, [source{d} is hiring](https://sourced.tech/careers/)!
