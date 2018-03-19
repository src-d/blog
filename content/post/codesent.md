---
author: vadim
date: 2018-03-20
title: "Measuring code sentiment in a Git repository"
image: /post/codesent/logo.png
description: "This is the transcript of our MLonCode talk on GopherCon Russia. The idea is to combine the technologies we've developed to solve a toy problem: find funny comments."
categories: ["science", "technical"]
---

## Preamble

[GopherCon](https://github.com/gophercon) has happened annually in the US since 2014. Go is clearly
gaining momentum, so this year we've got two similar conferences in Europe inspired by
the original GopherCon: [GopherCon Iceland](https://gophercon.is/) in June and
[GopherCon Russia](https://www.gophercon-russia.ru/en) in March. Francesc, our VP of developer relations,
[is conducting a workshop](https://gophercon.is/#speakers) in Iceland, while Vadim, the lead of ML
team, [spoke](https://www.gophercon-russia.ru/en#rec46832568) in Russia. Below is the edited
Vadim's talk transcript. There are also [slides](http://vmarkovtsev.github.io/gophercon-2018-moscow/)
available.

## Measuring code sentiment in a Git repository

Hi, my name is Vadim and I am working at source{d} and solving Machine Learning on Source Code
(MLonCode) problems. I have recently stumbled upon this
[well-known question on StackOverflow](https://stackoverflow.com/questions/184618/what-is-the-best-comment-in-source-code-you-have-ever-encountered)
again:

{{% caption src="/post/codesent/so.png" %}}
StackOverflow question about the best comments.
{{% /caption %}}

I keep laughing every time I read the answers, it's a real pity this question is closed. So I thought
that I could use the open source projects we've developed at source{d} to mine such comments in
open source repositories. Most of the listed examples are sarcastic and belong to dark humour,
and I decided to employ [sentiment analysis](https://en.wikipedia.org/wiki/Sentiment_analysis)
as the NLP domain which is relatively well-studied and there exist big datasets for free download.
This is what we are going to do:

* Run through commits in a Git repository
* For each changed file, find new comments
* Classify each comment as positive, neutral or negative
* Plot sentiment throughout the project's lifetime
* Look at the funny discoveries

We are going to use the following technologies:

* [src-d/go-git](https://github.com/src-d/go-git) to read Git repositories
* [src-d/hercules](https://github.com/src-d/hercules) to analyze the commit tree
* [Babelfish](https://doc.bblf.sh) to extract the comments
* [vmarkovtsev/BiDiSentiment](https://github.com/vmarkovtsev/BiDiSentiment) to perform sentiment analysis (runs on Tensorflow)
* Python to train the ML model and Go to apply it.

I will describe each one in detail now. Let's start with go-git.

{{% caption src="/post/codesent/go-git.png" %}}
go-git logo by Ricardo Baeta.
{{% /caption %}}

We started it back in 2015 as an "internal open source" project to fulfill our tasks of source code
retrieval and analysis. This is an example of the typical software project workflow at source{d}
today: we go open source from day 0 and see what happens next. This time go-git became a huge success
with more than 2400 stars and several companies already using it in production. Although it lacks
some of the [features](https://github.com/src-d/go-git/blob/master/COMPATIBILITY.md) of "big brothers",
it is performant and highly extensible. Finally, the maintainers are experienced code maniacs and
go-git is a good example of idiomatic and clean Go.

Hercules [appeared](https://blog.sourced.tech/post/hercules/) in December 2016 as an attempt
to speed up Erik Bernhardsson's [Git-of-Theseus](https://erikbern.com/2016/12/05/the-half-life-of-code.html)
by reimplementing it in Go and go-git. Indeed, it is an order of magnitude faster now.

{{% caption src="/post/codesent/linux.png" %}}
Line burndown of the Linux kernel - each band is one year and the thickness shows the ratio of lines
which are not overwritten yet.
{{% /caption %}}

Then I added code ownership...

{{% caption src="/post/codesent/emberjs_people.png" %}}
Line ownership in Ember.js. Notice how one of devs appeared and conquered a half of the project.
{{% /caption %}}

...line overwrite matrix...

{{% caption src="/post/codesent/wireshark_churn_matrix_black.png" %}}
"Code wars" in Wireshark: XY cell's intensity is proportional to the number of times developer X's
lines were overwritten with developer Y's.
{{% /caption %}}

...and even structural coupling.

{{% caption src="/post/codesent/jinja_black.png" %}}
Structural clusters in Jinja2. Each dot is a function and each pair is closer proportionally to
the number of times those two functions appeared in the same commit.
{{% /caption %}}

Under the cover, Hercules contains the DAG resolution engine which frees users from manually
designing the analysis pipeline. It also leverages `pkg/plugin` to allow external extensions.

We pass over to comment extraction. The most straightforward way to extract comments is to
take a syntax highlighter with a bunch of regular expression rules. We will get into trouble once
we want to distinguish docstrings from regular comments, so we need to parse the code fairly.
At the same time, we wish to be language agnostic, so a universal parser is required.
Systems like ANTLR4 define their own grammar description metalanguage and maintain the parsers
written in it. They should work fast - everything runs in a single process, however, the efforts
to maintain the parsers are dramatic. Imagine that you target hundreds of languages, there are
going to be bugs, there are going to be new versions and there are going to be new languages.

That's why we chose the alternative way with Babelfish. We take the existing parsers (each language
should have at least one), wrap their environments into containers which we manage directly with
libcontainer and attach to an RPC server. The problem here is that those "native" parse artifacts,
Abstract Syntax Trees, are in different formats which we need to normalize so that we can work with
them using the same code. We maintain the drivers - compact projects to transform the native AST
to the generalized AST which we called the Universal Abstract Syntax Tree (UAST).
Thus we do not avoid the burden of maintenance completely. You must agree that writing tree
transformers is much easier than writing parsers from scratch. RPC allows us to scale horizontally
within broad limits but performs worse on small tasks.

UAST nodes are classified to the fixed set of roles, such as identifiers, literals, classes, functions
and so on. Particularly, there is the Comment role which we are going to filter. Have a look at this
code:

```go
import (
	"gopkg.in/bblfsh/client-go.v2"
	"gopkg.in/bblfsh/client-go.v2/tools"
)
client, _ := bblfsh.NewClient("0.0.0.0:9432")
resp, _ := client.NewParseRequest().Content("...").Do()
nodes, err := tools.Filter(resp.UAST, "//*[@roleComment]")
// nodes[0].Token
```

As you see, barely 3 lines of code, error handling excluded, allow you to extract all the
comments from a source code string. The cool thing is UAST pretending to be XML and running XPath
quieries on it.

I need to say a few words about Tensorflow before explaining the comments classification model.

{{% caption src="/post/codesent/tf_black.svg" %}}
Tensorflow graph scheme.
{{% /caption %}}

The core of Tensorflow is the computational graph. It contains two types of nodes: tensors and operations.
"Tensor" sounds a bit scientific; it is actually just a array with numbers. So buffers are specified
as the input, they can represent the state of the graph which can mutate and there are output ones
which we read in the end. Operations transform tensors according to the control flow rules.

{{% caption src="https://www.tensorflow.org/images/tensors_flowing.gif" %}}
Tensor flow. Taken from the official web site.
{{% /caption %}}

The rest is the layers of abstraction on top of the graph to simplify the typical ML solutions:
neural networks, graph routines, visualization, etc. The key point is: Tensorflow abstracts the
graph execution from the actual hardware where it executes. Tensors may be big and operations on them
benefit from various accelerators such as GPUs, and Tensorflow allows to pin each operation to the
supported execution device.

Each ML model goes through the training phase, either supervised or not. The graph state tensors change
while the model is trained. Here is the intended way to train and use a typical neural network:

1. Debug the model locally: make sure it converges and there are no implementation faults. We debug on [e-GPUs](https://egpu.io/) at source{d}.
2. Train the model on as much data as you have on a GPU cluster
3. Optionally apply a metaparameter optimization algorithm to reach the best metrics in (2)
4. Export the trained graph in "GraphDef" format (Protocol Buffers)
5. Distribute it in an embedded or a pluggable fashion - that is, inside the application binary or separately
6. Apply it ("infer") with any programming language

In our case, I used Python API to Tensorflow on a dedicated machine with 4 GPUs running two experiments
in parallel for training and Go API and plain CPU for inference. It is impossible to train Tensorflow
models using the current Go bindings, but even if it was possible, I would still not do that. From my
experience, scripting languages are superior for doing research where you rewrite code every now and then
and need the full expressiveness and flexibility to achieve the result as soon as possible.
At the same time Go fits the inference scenario well: we put everything into the single executable
without dependencies and it just works. Everybody who deployed models in Python should understand
the pain.

Have you heard about [neugram](https://neugram.io/), a scripting language on top of Go runtime?
It was created by David Crawshaw, the author of `pkg/plugin`. Neugram is still in it's early ages
and has childhood problems, but I really like it. Who knows, maybe one day we will train Tensorflow
models using neugram - I anticipate this.

The following Go code runs a Tensorflow graph:

```go
modelBytes, _ := assets.Asset("model.pb")
graph := tf.NewGraph()
graph.Import(modelBytes, "")
input := graph.Operation("input").Output(0)
output := graph.Operation("output").Output(0)
sess, _ := tf.NewSession(graph, &tf.SessionOptions{})
feed, _ := tf.NewTensor([][]float32{})
result, _ := sess.Run(
    map[tf.Output]*tf.Tensor{input: input1},
    []tf.Output{output}, nil)
```

We embed the model using [go-bindata](https://github.com/jteeuwen/go-bindata), import the graph and
discover input and output tensors. The new session is launched and we execute the resolved dependency
tree to reach the output given the input. Sessions are required to allocate the hardware resources
and manage the environment. Technically, they are bridges to the underlying Tensorflow runtime
written in C++ as a standalone library, in case with Go this bridge is implemented with CGo.

{{% caption src="/post/codesent/gophers.png" %}}
vmarkovtsev/BiDiSentiment logo.
{{% /caption %}}

It's left to reveal the comment sentiment classification model. I named it "BiDiSentiment" and
this is it's logo. BiDiSentiment is a general-purpose sentiment model, it is not specifically designed
for comments.

{{% caption src="/post/codesent/arch_black.png" %}}
BiDiSentiment architecture.
{{% /caption %}}

The model is by far not the state-of-the-art but it works reasonably well. It consists of two
stacked recurrent branches, each branch has two LSTM layers. Both read text byte by byte, the first
from left to right and the second in the opposite direction. Once all the text is read, their
outputs are concatenated and the dense layer put on top. The result is two numbers: the estimated
probabilities of the negative and the positive sentiment. Obviously, their sum is 1.

Since the recurrent branches are independent, we can pin them to different GPUs which speeds up
the training by 50%.

{{% caption src="/post/codesent/arch_device_black.png" %}}
BiDiSentiment training device allocation.
{{% /caption %}}

The biggest labelled dataset that I found was 1.5 million tweets so I trained on it. As a bonus,
the text sizes are bound to 140 (now 280) characters which perfectly suits the maximum recurrent memory
depth. Here is the plot of the accuracy (number of correctly predicted sentiments divided by the overall
size) through time.

{{% caption src="/post/codesent/validation_black.png" %}}
BiDiSentiment accuracy on validation.
{{% /caption %}}

We split the data into two parts: the part on which we train and the part on which we evaluate aka
validation. This is needed to avoid overfitting - when the model adapts to the training examples
too much and loses generalization ability. The validation accuracy is plotted here. We see that
our model overfits after 5 epochs - that is, runs across the whole training set. This is a typical
situation in recurrent neural networks. I should have used overfit reduction techniques,
e.g. dropout, but I did not have time. So we pick the graph state on epoch 5 and export it.

Let's see how BiDiSentiment performs on some answers to that StackOverflow questions.

```
go get -v gopkg.in/vmarkovtsev/BiDiSentiment.v1/...

echo "When I wrote this, only God and I understood \
what I was doing. Now, God only knows" | $GOPATH/bin/sentiment
```

Output (negative probability): 0.8803515 - the sentiment is clearly negative.

```
echo "sometimes I believe compiler ignores \
all my comments" | $GOPATH/bin/sentiment
```

Output: 0.88705057. Again negative.

```
echo "drunk, fix later" | $GOPATH/bin/sentiment
```

Output: 0.08034721. Positive.

Let's sum everything up and describe how we run source code comment sentiment analysis:

1. Install and run [bblfshd](https://doc.bblf.sh/user/getting-started.html#running-with-docker-recommended)
2. Install [hercules](https://github.com/src-d/hercules/releases)
3. Install [libtensorflow](https://www.tensorflow.org/install/install_go)

Then we analyze any Git repository like this:

```
hercules --sentiment https://github.com/golang/go
```

We emulate the neutral sentiment class as the middle between positiveness and
negativeness and exclude them from further analysis. The results are shown on the table.

| Project               | Positive | Negative | Effective |
|-----------------------|----------|----------|-----------|
| [pygame/pygame](https://github.com/pygame/pygame)         | 93.4     | 98.2     | -4.8      |
| [pallets/flask](https://github.com/pallets/flask)         | 23.6     | 31.9     | -8.3      |
| [django/django](https://github.com/django/django)         | 462.1    | 536.1    | -74.0     |
| [golang/go](https://github.com/golang/go)             | 402.1    | 507.3    | -105.2    |
| [kubernetes/kubernetes](https://github.com/kubernetes/kubernetes) | 186.1    | 91.6     | 94.5      |
| [keras-team/keras](https://github.com/keras-team/keras)      | 104.8    | 71.1     | 33.7      |

The columns represent the sum of all the positive and negative sentiments together with the final
sentiment value. Some of the projects appeared to be negative and some positive. We'll see why
later, and now let's look at the promised sentiment plot through time.

{{% caption src="/post/codesent/golang-sentiment-black.png" %}}
golang/go sentiment through time.
{{% /caption %}}

Can we conclude anything useful from this? Unfortunately, no, there are no clear trends or
periods. It is too many different comments. Maybe we will have more luck with monorepos, that is
those with a single main contributor. For now, it is more fun to inspect the most negative and positive
examples of comments on Golang source code. Negative:

```go
// It is low-level, old, and unused by Go's current HTTP stack

// not clear why this shouldn't work

// overflow causes something awful

// quiet expected TLS handshake error remote error: bad certificate
```
Source: [1](https://github.com/golang/go/blob/master/src/net/http/httputil/persist.go#L33),
[2](https://github.com/golang/go/blob/32aa0d9198a1b147eb2c756c0d5628b3399f9898/test/bugs/bug046.go#L11),
[3](https://github.com/golang/go/blob/master/src/runtime/vlrt.go#L95),
[4](https://github.com/golang/go/blob/master/src/os/exec/exec_test.go#L568).

Positive:

```go
// Special case, useful in debugging

// Implementation: Parallel summing of adjacent bits. See Hackers Delight, Chap. 5: Counting Bits.

// TODO(austin): This could be a really awesome string method

// TODO(bradfitz): this might be 0, once escape analysis is better
```

Source: [1](https://github.com/golang/go/blob/master/src/bytes/buffer.go#L63),
[2](https://github.com/golang/go/blob/master/src/math/bits/bits.go#L135),
[3](https://github.com/golang/go/blob/46e392e01c630dee41a67e01223b538aae9dc9b5/usr/austin/ogle/vars.go#L42),
[4](https://github.com/golang/go/blob/84ef97b59c89b7d9fdc04a1a8a438cd3257bf521/src/pkg/strconv/strconv_test.go#L21).

The last one is actually written by Brad who talked a few minutes ago hehe. In this case the model
must have caught word "better".

Finally, here are the positive comments in Keras, the deep learning framework I used to train
BiDiSentiment model:

```python
# With TensorFlow, we can infer the output shape directly

# Make sure there is exactly one 1 in a row

# get sorted list of layer depths

# Theano has a built-in optimization for logsumexp so we can just write the expression directly
```

I have looked at other classification result and can conclude the following. First, the model
was trained on data of one nature (tweets) and applied to data of different nature (comments).
Thus it often exaggerates comment sentiment. Second, it behaves differently on two project types.
The first type is projects which contain many details, many conditions, many checks and
handle many edge cases. For example, language compilers (Go) or web servers (Django). BiDiSentiment
classifies them as negative: the text tells how **not** to fail.
The second type is projects which explain what is happening, which environment features they use
to do better or explain much domain terminology. For example, k8s has tons of devops comments
and Keras describes deep learning recipes. BiDiSentiment treats them as positive: they teach or
explain why they are cool. I must say that deep learning seems to be the modern alchemy
([discussion](https://medium.com/@Synced/lecun-vs-rahimi-has-machine-learning-become-alchemy-21cb1557920d))
so Keras has a big positive sentiment, hehe.

## Conclusion

* It is easy to analyse Git repositories with Go.
* Go is handy for inference-in-a-box with Tensorflow.
* We need a dedicated dataset for comment sentiment. At the same time, labelling 1 million comments
is at least challenging.
* Naive sentiment alignment depends on the project type.

Here is the list of papers from
[Mining Software Repositories](http://www.msrconf.org/) conference which go deeper into the topic:

* [Classifying code comments in Java open-source software systems](https://dl.acm.org/citation.cfm?id=3104217)
* [Analyzing developer sentiment in commit logs](https://dl.acm.org/citation.cfm?id=2903501)
* [Sentiment analysis of commit comments in GitHub: an empirical study](https://dl.acm.org/citation.cfm?id=2597118)
* [Sentiment analysis of Travis CI builds](https://dl.acm.org/citation.cfm?id=3104245)

That's all. Please use #MLonCode hashtag on Twitter if you tweet about this. Thank you.
