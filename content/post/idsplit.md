---
author: vadim
date: 2018-11-05
title: "Splitting Millions of Source Code Identifiers with Deep Learning"
image: /post/id2vec/intro.png
description: "Machine Learning team at source{d} wrote another paper this spring which was presented on ML4P workshop in Oxford. It compares different ML models to split source code identifiers into integral parts, e.g. 'foobar' is split into 'foo' and 'bar'. This post summarizes our paper."
categories: ["science", "technical"]
---

## Problem

If you grab our [Public Git Archive](../announcing-pga) dataset with almost
180,000 Git repositories, take the latest revision of each and extract all
the identifiers from them (e.g. variable, function, class names),
you will end up with something close to 60 million unique strings. They
include "FooBar", "foo_bar", and "foobar"-like concatentations of the integral
identifiers or "atoms" as we sometimes call them. We've solved some problems
which require the number of distinct atoms to be as small as possible for 
performance and quality considerations; those problems include
[topic modeling of GitHub repositories](../github_topic_modeling),
[identifier embeddings](../id2vec) and even the recent
[study of files duplication on GitHub](../deduplicating_pga_with_apollo).
Thus we decided to focus on reducing that number through careful splitting of
the initial concatentations. The result was 64% ⚛ vocabulary reduction.

[Link to the PDF of the paper.](https://arxiv.org/pdf/1805.11651)

> Fun fact. After the paper was presented on [ML4P](https://ml4p.org/),
there was a suggestion to eliminate our problem by reducing the dataset size. 👍

The task is not so simple as it seems. For sure, the underscore and case change
heuristics work, however, they are not enough. "Progressbar" should be split into
"progress" and "bar" while "ProgressbarControl" should split into
"progressbar" and "control", because the usage contexts are quite different.
Around 7% of the identifiers in our dataset are not splittable by heuristics,
and further 15% contain at least one splittable part after applying heuristics.
That is more than 10 million affected strings.

## Solution

Machine Learning team is going to make machines learn, so we studied several
ML models to solve the splitting task. Before jumping to the juicy ML stuff,
we need to define our training dataset, which seems to be absent at first glance.
However, it is possible to turn our dataset of extracted identifiers into
(X, Y) by trusting the heuristics. Indeed, we can take the identifiers
that are splittable by case change, underscore, etc. and pretend that the
outcome is the ground truth split points. That gives us about 50 million traning
examples for free.

Of course, as was already said above, some of the heuritical splits are not enough,
so our ML models are going to be trained on noisy labels. However, we can overcome
this limitation by bootstrapping the dataset and training several generations
of the same model - in other words, refining the training examples at each iteration
by applying the current model to them. We did not research that, unfortunately.

One last remark: we are going to evaluate the models by measuring their
[precision and recall](https://en.wikipedia.org/wiki/Precision_and_recall).
Precision equals to how many split points we predicted correctly divided by the
total number of predictions. Recall equals to how many split points we predicted
correctly divided by the total number of ground truth splits. They are both
important and indicate the bias towards spammy, noisy predictions which cover
everything or conservative, confident ones which trigger on few samples.

Here are the models which we evaluated.

#### Maximum likelihood character-level, unsmoothed

This is a quick and dirty baseline implemented in
[CharStatModel](https://github.com/vmarkovtsev/CharStatModel) repository. We
record all possible sequences of characters in form of a tree
and decide whether to split based on the tree branch with the dominating weight
for a given prefix or suffix. There are several weak points of that approach:
it consumes much memory, it is always biased towards good precision or good recall,
it is quite short-sighted.

#### Dynamic programming

Accepting the hypothesis that the atoms of the string are independent from one
another, we can model the probability of a sequence of words using frequencies
computed on a corpus. That corpus can be our training dataset or anything else.
We explored the former and additionally the Wikipedia corpus. There can be also
different assumptions about the probability distribution (prior), e.g.
training posterior or [Ziph](https://en.wikipedia.org/wiki/Zipf%27s_law).
We tried three models with those combinations.
Our implementation was based on Derek Anderson's
[wordninja](https://github.com/keredson/wordninja).

#### Gradient boosted decision trees

We train gradient boosted trees to predict a split point from the given
character window to the string. We feed character indexes as features.
Our implementation was [XGBoost](https://github.com/dmlc/xgboost).

#### Deep learning

So we described three deep learning models in the paper: character-level CNN,
GRU and LSTM. Reccurent networks are bidirectional and contain two layers.
We didn't explore the addition of attention mechanism - it should improve
the achieved evaluation metric values.

{{% caption src="/post/idsplit/bilstm.png" title="BiLSTM" %}}
The architecture of the BiLSTM network to split identifiers.
{{% /caption %}}

We used [Keras](https://github.com/keras-team/keras) with TensorFlow backend to
train on a machine with 4 GPUs, it took 14 hours.

## Models evaluation results

{{% caption src="/post/idsplit/output.png" title="Evaluation results" %}}
Achieved quality for all the trained models.
{{% /caption %}}

The winner was the BiLSTM network which had 0.95 precision and 0.96 recall.
We applied it to the initial dataset with identifiers and observed a nice
atom vocabulary decrease from 2.6 million to 1 million. The code is still being
incorporated into the [sourced-ml](https://github.com/src-d/ml) framework,
and we are always happy to receive help with the development. Our research has
been also used in the upcoming identifier typo corrector which we are actively
building.

[Link to the PDF of the paper.](https://arxiv.org/pdf/1805.11651)
