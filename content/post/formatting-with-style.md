---
author: m09
date: 2019-01-30
title: "Formatting. With Style."
image: /post/formatting-with-style/handwriting.jpg
description: "Formatting code using existing styles."
categories: ["technical", "MLonCode"]
draft: true
---

Ensuring that a codebase is consistent in style is both hard and
costly, yet it is extremely important for maintainability and to
reduce technical debt. Why is it hard and costly?  There are many
contributing factors but the main ones are certainly:

- teams might not have set up a linting process early enough or at all
- people handling the codebase might be changing on a regular basis
- linters do not cover everything. Besides, they can be hard to set up
  to their full power or can be too opinionated. Also, they generally
  tend to only point out problems whereas we aim to provide
  suggestions to fix them.

To help new or current team members to code in a consistent way, we
need to model existing style and use it to lint new code. At
source{d}, we call that breakfast. Let's go!

## Lookout

This problem is one of the many pain points we are currently tackling
with [Lookout](https://github.com/src-d/lookout), our brand new and
awesome assisted code review framework.

The purpose of Lookout is to bring assisted code review to anyone in
an easy-to-setup, easy-to-use, easy-to-extend fashion. To achieve
that, Lookout watches Github repos and triggers a set of analyzers
when new code is sent for review or pushed. Those analyzers are very
easy to define (they are based on the gRPC tool suite).

{{% caption src="/post/formatting-with-style/lookout-arch.png" %}}
Lookout architecture.
{{% /caption %}}

In our case, when new code is pushed, we want to learn from the
codebase to model its style as precisely as possible. When new code is
sent for review, we analyze it to detect problems with style and
suggest their fixes as code review comments. Particularly, we leverage
[GitHub Suggested
Changes](https://blog.github.com/2018-11-01-suggested-changes-update/).

{{% caption src="/post/formatting-with-style/suggestion.png" %}}
GitHub review comment from Format Analyzer that fixes a style mistake.
{{% /caption %}}

## Format Analyzer: unsupervised Learning

Let's now dive into the Machine Learning side of things. For our first
approach, we defined a set of requirements that we wanted to satisfy:

- a single repository as a training set
- an interpretable output (to be accountable and establish trust with
  our users —a key point of Machine Learning in production)
- a correctable model: if the users are not happy with some
  suggestions of the model, it should be possible to correct its
  suggestions

To satisfy all those needs with a single approach, we turned to good
old battle-tested machine learning methods: language models and
decision trees.

For now, the Format Analyzer runs on javascript code. We plan to
extend the set of supported languages in the following months. The
[code](https://github.com/src-d/style-analyzer) of the Format Analyzer
is available on GitHub.

### Language models

In order to define the style of a repository, we turned to the
well-known Natural Language Processing subjects: language models. A
language model tries to find out which word most likely follows given
the sequence of previous words in a sentence. In our case, we'll use
them to find out which next token is the most likely given the
previous tokens in some code.

Consider this example where we try to find out what `_` could be:

    if a_

Given the previous tokens `if`, ` ` and `a`, what would be the most
likely next token `_`? There is not a single correct answer but rather
a probability distribution over possible tokens. We can learn, for
example:

    p(" ") = 0.4
    p(":") = 0.6

`p(" ")` would model the cases where the `if` condition is complex
(`if a and len(some_list) > 5:`) and `p(":")` would model the cases
where the `if` condition is already complete (`if a:`).

A language model is simply the set of such probability distributions
computed for all interesting inputs (all interesting sequences of
previous tokens).

This model is rather simple and has a big advantage: it doesn't
require any labeled training data. That means that the engineers who
will use the model won't have to spend time giving examples of correct
style and bad style: we'll learn them without any intervention!

To give more power to our language models, we do not restrict what we
base our predictions on to preceding tokens but we also inspect the
words that follow the token that we are predicting. Still, the idea is
very close to a vanilla language model.

Before diving into the specifics of the models we used, let's
elaborate on this point and review how we create the window over
tokens to consider and how we model the elements in those windows.

### Feature Extraction

The backbone of our features is the source{d} Engine language agnostic
parsing , [Babelfish](https://docs.sourced.tech/babelfish) (as often
in the Machine Learning team at source{d}). It allows us to extract
Abstract Syntax Trees (ASTs) that are universal (UASTs), i.e. language
agnostic.

The advantage of using UASTs over the sequence of tokens is that we
leverage the structural information: are we in a function? In a
boolean expression? Is this a lambda expression? We can answer all
those questions easily with UASTs, while our models would need to work
extra-hard to understand the structure by itself from token sequences.

Once we have the UAST for a given file, we investigate neighbor tokens
within a fixed size window around each formatting element we want to
predict. We focus on the following formatting tokens: spaces,
tabulations, newlines, and single and double quotes. The shape of the
default window is:

- 5 tokens to the left
- 5 tokens to the right
- 2 nodes up the parent hierarchy


{{% caption src="/post/formatting-with-style/features.png" %}}
Example of the window around a character `'`, in dark green. They grey elements are
used as input for the model.
{{% /caption %}}

This approach mixes sequential information with structural
information, therefore giving our models a wide array of tools to work
with.

For all those elements, we extract features such as:

- [Babelfish role](https://docs.sourced.tech/babelfish/uast/roles)
  (ie: FUNCTION, LITERAL, ADD, etc)
- length of the token
- offset difference
- and many more

### Decision Trees

In short, decision trees group the examples seen in the training
dataset into different leaves. The leaves are created in a way that
tries to minimize the diversity of the examples in each leaf.

The [Wikipedia page on decision tree
learning](https://en.wikipedia.org/wiki/Decision_tree_learning)
provides a more detailed introduction to the learning algorithm.

### From tree to rules

Trees are already somewhat of a whitebox model: they can be drawn and
people can inspect them to understand why a decision was made. Still,
we wanted to improve a bit on this interpretability.

We transform individual branches of the trees into rules, by simple
concatenation of the conditions in the nodes encountered along a given
branch.

Let's consider the [classical example of the survivors on the
Titanic](https://www.kaggle.com/c/titanic), for the following tree:

       age > 18
          /\
         /  \
     sex=M   A
       /\
      D  A

We would create three rules:

- `if age > 18 and sex is M, sample is classified D`
- `if age > 18 and sex is not M, sample is classified A`
- `if age <= 18, sample is classified A`

This way we can only display one rule (or a few rules) and still
understand, at least partially, why the model made a decision.

### Evaluation

We created a few artificial datasets to make sure that we could detect
rogue style and propose meaningful fixes. Some of those datasets used
manually inserted mistakes while the others were created using simple
automatic transformations.

## Future plans: meta learning

Still, as Machine Learning engineers, we are always eager to use data
if it is available. For this reason we're working on the second
iteration of our format analyzer, which works in two distinct steps:
first it learns to model style on many repositories, then it is
applied to a given codebase.

To be clear though, our goal is still __not__ to model _global style
practices_. For this reason, we don't want to use the standard
supervised learning approaches but investigate meta-learning
instead. Meta-learning can be described as the set of techniques that
allow _learning how to learn_.

The plan is as follows:

1. Learn how to learn to model style in a given repository by
   leveraging all the repositories which are relevant. This phase is
   the most time-consuming. To train an efficient, general model that
   can learn how to model style in a repo with minimal effort we
   exploit the idea of an _embedding_ to model style, with a twist:
   the embedding is the only place where the model can store
   information about the style of a repository and hence __has__ to
   condense __all the style information__.

2. Apply this knowledge to model a particular repository. Since the
   style embedding is the only place where our model can encode style
   information about a repository, we can use techniques that are
   well-known in both Natural Language Processing and Computer Vision
   communities to find the embedding that most closely models the
   style.

And that's all: since all of the style information belongs to one
single place, we've nothing else to do.

### Possibilities

Meta learning enables lots of new applications. Among the most
exciting ones we could cite:

- apply a specific style to your repository (Google's, another team's, etc)
- find existing styles with documented guidelines that most closely match an
  unknown style
- perform style analysis at a fine granularity (directory granularity
  instead of project granularity). This is made possible by the
  reduced need for data during the second step

## To be continued!

We are making early steps towards the second approach. Let's wish
Format Analyzer a bright future that will allow engineers across the
world to focus on problems more exciting than maintaining the proper
code formatting.

Make sure to browse examples of Format Analyzer output in our [demo
repository](https://github.com/lookout-demo/node)!

Don't want to miss the next blog post about how source{d} ML team does
R&D? Subscribe to [our newsletter](http://go.sourced.tech/newsletter),
follow [@sourcedtech](https://twitter.com/sourcedtech) on Twitter and
don't forget about our [Paper Reading
Club](https://github.com/src-d/reading-club). Oh, and we are
organizing the [MLonCode developer room at
FOSDEM'2019](https://medium.com/sourcedtech/ml-on-code-devroom-cfp-fosdem-2019-4f867f128e21#a948) -
please come and say hello!
