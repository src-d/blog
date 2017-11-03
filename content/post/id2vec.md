---
author: vadim
date: 2017-10-09
title: "Source Code Identifier Embeddings"
image: /post/id2vec/intro.png
description: "'Embed and conquer', they say. Everything which has a context can be embedded. word2vec, node2vec, product2vec... id2vec! We take source code identifiers, introduce the context as the scope in the Abstract Syntax Tree, and find out that 'send' is to 'receive' as 'push' is to 'pop'."
categories: ["science", "technical"]
draft: true
---

This post is related to a talk we gave in Moscow in June at our Machine Learning on Source Code (MLoSC) conference and research we did at the beginning of this year:
[presentation](http://vmarkovtsev.github.io/techtalks-2017-moscow/) and
[video](https://youtu.be/v8Jy3xbpCqw?list=PL5Ld68ole7j3iQFUSB3fR9122dHCUWXsy).

Let's start with revising what "embeddings" are, then proceed with describing approaches to word2vec, then explain how this technique can be transferred from NLP to MLoSC, present some examples of the results and finish with instructions on how to reproduce this work.

## Embeddings

Suppose that we work with elements from an abstract N-dimensional space. In other words, each element
is a series of numbers, the length of that series is N - that is, a vector of length N.

```python
element = [0, 0, 1, 1, 0, 0, 0, 1]  # 8 dimensions
```

Let's suppose that we are given M such elements. In general, one can think about embeddings as a way
to represent each of the elements in a lower-dimensional space, such that the important properties
in the original space are preserved. The latter condition is essential: otherwise we could
enumerate all our vectors and thus put them into 1D - [effective, but useless](http://knowyourmeme.com/memes/roll-safe).

The important property to be preserved is often defined as the relative distances between the
elements. At the same time, we often speak about embeddings in the context of an ambiguous feature
space, such as images, audio, or natural language texts. Images are series of pixels,
audio are series of sound pressure measurements and texts are series of encoded letters. Such interpretation
of the feature space is sufficient to perceive them and to establish the relationships, but not enough
to solve Machine Learning problems.

For example, let's take photos of cats and dogs. Given just arrays of pixels, we cannot easily
tell what is present on the images, however, imagine that we are given a black box which outputs
the following:

{{% text size="large" font="monospaced" %}}
{{% table "fixedLayout" %}}

| Photo                                                | Embedding |
|:----------------------------------------------------:|:---------:|
| ![one cat](/post/id2vec/cat_1_240.jpg)               |   [1, 0]  |
| ![one dog](/post/id2vec/dog_1_240.jpg)               |   [0, 1]  |
| ![five cats](/post/id2vec/cat_5_240.jpg)             |   [5, 0]  |
| ![four dogs](/post/id2vec/dog_4_240.jpg)             |   [0, 4]  |
| ![one cat and one dog](/post/id2vec/cat_dog_240.jpg) |   [1, 1]  |

{{% /table %}}
{{% /text %}}

Apart from the easy classification, we are now able to easily estimate the semantic difference between the images:

{{% text size="large" font="monospaced" %}}
{{% table "noCellHighlighting" "noHeader" "condensed" %}}

|                                          |     |                                        |     |                                        |
|:----------------------------------------:|:---:|:--------------------------------------:|:---:|:--------------------------------------:|
| ![one cat](/post/id2vec/cat_dog_240.jpg) |  -  | ![one dog](/post/id2vec/dog_1_240.jpg) |  =  | ![one cat](/post/id2vec/cat_1_240.jpg) |
| [1, 1]                                   |     | [0, 1]                                 |     | [1, 0]                               |

{{% /table %}}
{{% /text %}}

The semantic distance is \\(||(1, 0)||_2 = 1\\). It is evident that the result of such subtraction is just a single cat.

{{% text size="large" font="monospaced" %}}
{{% table "noCellHighlighting" "noHeader" "condensed" %}}

|                                        |     |                                        |     |                                          |
|:--------------------------------------:|:---:|:--------------------------------------:|:---:|:----------------------------------------:|
| ![one cat](/post/id2vec/cat_1_240.jpg) |  -  | ![one dog](/post/id2vec/dog_1_240.jpg) |  =  | ![monster](/post/id2vec/monster_240.jpg) |
|  [1, 0]                                |     |  [0, 1]                                |     |  [1, -1]                                 |

{{% /table %}}
{{% /text %}}

The semantic distance be \\(||(1, -1)||_2 = \\sqrt{2}\\). If we had a two-way
black box, e.g. a deep neural network trained to classify our photos, we could generate an image
from `[1, -1]` and most likely got a terrible alien monster.

{{% text size="large" font="monospaced" %}}
{{% table "noCellHighlighting" "noHeader" "condensed" %}}

|                                          |     |                                        |     |                                        |
|:----------------------------------------:|:---:|:--------------------------------------:|:---:|:--------------------------------------:|
| ![five cats](/post/id2vec/cat_5_240.jpg) |  -  | ![one cat](/post/id2vec/cat_1_240.jpg) |  =  | ![monster](/post/id2vec/cat_4_240.jpg) |
|  [5, 0]                                  |     |  [1, 0]                                |     |  [4, 0]                                |

{{% /table %}}
{{% /text %}}

The semantic distance is 4 which is greater than \\(\\sqrt{2}\\). Depending on the problem we solve,
this may or may not be normal. Our result is four cats.

Is that the only way we can embed cats and dogs? Of course not. The following embeddings have
**exactly** the same distance properties as the first ones:

```python
[ 0.707, -0.707]
[ 0.707,  0.707]
[ 3.536, -3.536]
[ 2.828,  2.828]
[ 1.414,  0    ]
```

They were generated by rotating the initial [basis](https://en.wikipedia.org/wiki/Basis_(linear_algebra)) by 45°.
In practice, it is quite hard to obtain embeddings which are interpretable by themselves, so the
only way to see if they make sense is to visualize many of them, e.g. using [t-SNE](../lapjv/).

## word2vec

Now consider a text written in a natural language. Roughly, it consists of sentences and sentences
consist of words. Our task is to embed all the words in a natural language, so that related words
appear near each other. For example, "president" and "politics" are related, so the distance
between those should be less than between "president" and "carrot".

The problem boils down to factorizing the co-occurrence matrix. This matrix is square and symmetric,
cell `[i, j]` is equal to how many times word i appeared in *the same context* as word j.
The definition of the context is a subject of feature engineering. Usually it is a sliding window
of a fixed length scanning over the whole text after throwing away any garbage and normalization.
Example:

```markdown
It’s incredible. Widescreen video like you’ve never seen on a portable device,
160 pixels per inch, gorgeous screen quality.
```

becomes

```
incredible widescreen video like never seen portable device pixels inch gorgeous
screen quality
```

We set window size 5 and produce 9 contexts:

```
incredible widescreen video like never
widescreen video like never seen
video like never seen portable
like never seen portable device
never seen portable device pixels
seen portable device pixels inch
portable device pixels inch gorgeous
device pixels inch gorgeous screen
pixels inch gorgeous screen quality
```

Each context adds 1 for every pair of words belonging to it. Our co-occurrence matrix looks like this:

{{% caption src="/post/id2vec/coocc.png" title="co-occurrence matrix" %}}
Binary co-occurrence matrix generated from the phrase about 160 dpi.
{{% /caption %}}

Having calculated the co-occurrence matrix C, we are going to seek for the dense vector
representation of length D for each word w so that the scalar product gives the approximation of
the [pointwise mutual information](https://en.wikipedia.org/wiki/Pointwise_mutual_information):

$$
w _i \\cdot w _j = w _j \\cdot w _i = \\sum _{d=1} ^D w _{id} w _{jd} = \\log\\frac{C _{ij} \\sum C}{\\sum _{k = 1} ^N C _{ik} \\sum _{k = 1} ^N C _{jk}}
$$

Here \\(\\sum C\\) is the sum over all elements in the matrix. Practically, we maximize
the scalar product of words which occur together and minimize it otherwise.

There are several algorithms to calculate such embeddings. The most most popular one,
which is referred to as just "word2vec", trains a neural network to either predict
all words in a context from the single element (skipgram) or the only missing word from a context
(CBOW). It implies a number of passes over the whole text called epochs and thus scales linearly
with the input size. It represents an *implicit* co-occurrence matrix factorization approach
and works best until your data size is less than, say, 100GB.
Regarding the concrete implementations, we like [FastText](https://github.com/facebookresearch/fastText).

Fewer people heard about [GloVe](https://nlp.stanford.edu/projects/glove/) - *explicit* co-occurrence
matrix factorization algorithm. It solves the problem when you have a really big input which does
not allow to scale the network's training linearly. Instead, the network is trained on the
matrix itself. Consequently, it scales quadratically with the vocabulary size. We can effectively
parallelize the co-occurrence matrix calculation on large datasets so this property is very attractive.

Even fewer people heard about [Swivel](http://arxiv.org/abs/1602.02215), which resembles GloVe and
has the same principal scalability properties. We are fans of Swivel because of its pragmatic
decisions and high performance Tensorflow implementation to which we contributed and subsequently also 
[forked](https://github.com/src-d/tensorflow-swivel) to maximize performance.

Having trained the embeddings, we are able to visualize words' relationships. Here is an example
of what you can get with embedding the words in the transcript of [the famous presentation by Steve Jobs in 2007](https://www.youtube.com/watch?v=vN4U5FqrOdQ):

{{% caption src="/post/id2vec/incredible.png" title="incredible" %}}
TensorBoard - words related to "incredible" according to Steve Jobs' presentation.
{{% /caption %}}

There is funny and interesting property of word embeddings: we can do vector arithmetic and evaluate
associations. The classic one is "king" is to "queen" as "man" is to "woman":

$$
w _{king} - w _{man} + w _{woman} \\sim w _{queen}
$$

Here \\(~\\) operation means the result of finding the nearest neighbor to the calculated vector.

## id2vec

The idea behind word2vec is universal and does not depend on any special features of the input data.
Anything which can be represented as a co-occurrence matrix can be embedded, either if that matrix
is implicit or explicit. In fact, [Starspace](https://github.com/facebookresearch/Starspace) from Facebook Research is built entirely on this observation. They mention the following problems in the readme:

* Learning word, sentence or document level embeddings.
* Information retrieval: ranking of sets of entities/documents or objects, e.g. ranking web documents.
* Text classification, or any other labeling task.
* Metric/similarity learning, e.g. learning sentence or document similarity.
* Content-based or Collaborative filtering-based Recommendation, e.g. recommending music or videos.
* Embedding graphs, e.g. multi-relational graphs such as Freebase.

I have recently found out that it applies to [frequent itemsets problem](http://infolab.stanford.edu/~ullman/mmds/ch6.pdf) and
[Association rule learning](https://en.wikipedia.org/wiki/Association_rule_learning) in general.
That is, if you've got products which are bought in baskets, then products are items and baskets
are contexts. Vector arithmetic allows you to sum "onion" and "potatoes" vectors and search for
the nearest neighbors, finding the "burger" vector. So the idea is very powerful.

source{d} works with extremely large amounts of source code. We've designed a topic modeling pipeline ([paper](https://arxiv.org/abs/1704.00135),
[application](https://github.com/src-d/dev-similarity))
based on the idea that source code identifiers carry valuable information.
The identifiers always occur together in some context, we usually call it a scope.
Consider [this example](https://github.com/django/django/blob/2c69824e5ab5ddf4b9964c4cf9f9e16ff3bb7929/django/apps/registry.py#L59):

```python
01  def populate(self, installed_apps=None):
02      if self.ready:
03          return
04      with self._lock:
05          if self.ready:
06              return
07          if self.loading:
08              raise RuntimeError("populate() isn't reentrant")
09          self.loading = True
10          for entry in installed_apps:
11              if isinstance(entry, AppConfig):
12                  app_config = entry
13              else:
14                  app_config = AppConfig.create(entry)
15              if app_config.label in self.app_configs:
16                  raise ImproperlyConfigured(
17                      "Application labels aren't unique, "
18                      "duplicates: %s" % app_config.label)
```
Here are our identifier scopes:

* Lines 01-18 - function scope
* Lines 02-03 - `if self.ready`
* Lines 04-18 - `with self._lock`
* Lines 05-06 - `if self.ready`
* Lines 07-08 - `if self.loading`
* Lines 10-18 - `for entry in installed_apps`
* Lines 11-14 - `if isinstance(entry, AppConfig)`
* Lines 15-18 - `if app_config.label in self.app_configs`

We extract subtokens (splitted and stemmed) from every identifier in every scope and increment
the corresponding elements in the co-occurrence matrix in an "all to all" fashion.
Duplicates are discarded, that is, only unique elements are taken. The result is:

{{% grid %}}
{{% scroll-panel %}}
{{% center %}}
{{% text size="small" %}}
{{% table "condensed" "fixedLayout" %}}

| populat | instal | apps | ready | lock | load | runtim | error | entry | app | config | create | label | improp | configur |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 0 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| 1 | 0 | 4 | 3 | 3 | 3 | 3 | 3 | 4 | 4 | 4 | 4 | 4 | 4 | 4 |
| 1 | 4 | 0 | 3 | 3 | 3 | 3 | 3 | 4 | 4 | 4 | 4 | 4 | 4 | 4 |
| 1 | 3 | 3 | 0 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 |
| 1 | 3 | 3 | 3 | 0 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 |
| 1 | 3 | 3 | 3 | 3 | 0 | 4 | 4 | 3 | 3 | 3 | 3 | 3 | 3 | 3 |
| 1 | 3 | 3 | 3 | 3 | 4 | 0 | 4 | 3 | 3 | 3 | 3 | 3 | 3 | 3 |
| 1 | 3 | 3 | 3 | 3 | 4 | 4 | 0 | 3 | 3 | 3 | 3 | 3 | 3 | 3 |
| 1 | 4 | 4 | 3 | 3 | 3 | 3 | 3 | 0 | 5 | 5 | 5 | 4 | 4 | 4 |
| 1 | 4 | 4 | 3 | 3 | 3 | 3 | 3 | 5 | 0 | 6 | 6 | 5 | 5 | 5 |
| 1 | 4 | 4 | 3 | 3 | 3 | 3 | 3 | 5 | 6 | 0 | 6 | 5 | 5 | 5 |
| 1 | 4 | 4 | 3 | 3 | 3 | 3 | 3 | 5 | 6 | 6 | 0 | 5 | 5 | 5 |
| 1 | 4 | 4 | 3 | 3 | 3 | 3 | 3 | 4 | 5 | 5 | 5 | 0 | 5 | 5 |
| 1 | 4 | 4 | 3 | 3 | 3 | 3 | 3 | 4 | 5 | 5 | 5 | 5 | 0 | 5 |
| 1 | 4 | 4 | 3 | 3 | 3 | 3 | 3 | 4 | 5 | 5 | 5 | 5 | 5 | 0 |

{{% /table %}}
{{% /text %}}
{{% /center %}}
{{% /scroll-panel %}}
{{% /grid %}}

The biggest co-occurrence value is between "app" and "config" - 6 contexts.

The described scheme can be distributed and run on top of Spark or any other solution. Our Data Retrieval engineer, 
Alex has a working proof of concept [swivel-spark-prep](https://github.com/src-d/swivel-spark-prep).
Thus our identifier embedding approach is the explicit factorization. We apply Swivel subsequently, it takes less than 6 hours to train using 4 NVIDIA 1080Ti grade GPUs on a 1 million x 1 million matrix produced from ⪆100k most starred repositories on GitHub.

## Results

#### Metasyntactic variables

[Metasyntactic variables](https://en.wikipedia.org/wiki/Metasyntactic_variable) are variable names
which are used as dummy placeholders, e.g. when you demonstrate a coding concept. Most well known
are probably "foo" and "bar". Here are some selected tokens nearest to "foo":

```
bound, wibble, quux, overloadargs, baz, testing
mfoo, ifoo, dfoo, myfoo, dofoo, afoo
```

and "bar":

```
jprogress, cescroll, rid, jstool, panel, sherlock, drawing
pbar, mbars, mybar, mpbar, abar, tobar, bar
```

And yeah! "bar" is to "foo" as "baz" is to "qux" - we've got the proof now.

#### Kings and queens

* "boy" is to "king" as "girl" is to "queen".
However, replacing "boy" with "man" and "girl" with "woman" does not prove this association.
I explain it with the fact that "man" is a typical acronym from "manual" and lost it's specificity.

* "bug" - "test" + "expect" = "suppress". Pretty much what we all do with `try: ... except: pass`. 

* "query" is to "database" as "tune" is to "settings".

* "send" is to "receive" as "push" is to "pop".

The latter two improve upon the common GloVe embeddings tremendously:

* "query" is to "database" as "tune" is to "databank", "tuned", "searchable_database", "registry", "soundtrack".

* "send" is to "receive" as "push" is to "pushing", "garner", "earn", "get", "attain".

#### Synonyms

Tokens nearest to "english":

```
dutch
italian
danish
german
finnish
russian
swedish
french
nglish
```

"send":

```
receive
sending
dosend
ssend
recv
sent
onsend
```

["fizzbuzz"](https://en.wikipedia.org/wiki/Fizz_buzz) is near to "divisible" and "isevenly".

#### Languages

Tokens nearest to "negatif", a mixture of German, Turkish, Greek and probably others:

```
negatif
karakter
iinde
erli
varsay
olmayan
veya
sistem
yoksay
fazla
lemi
ilem
girdi
adresleme
kesin
hatas
enek
daha
nilai
geersiz
```

"caracter", Spanish:

```
raiz
inteiro
tamanho
arquivo
obrigatorio
grupo
valor
xmlnf
atual
configura
codigo
esquema
inut
sticas
este
nome
motivo
verifica
estado'
```

Conclusion: identifiers in a language different from English tend to appear near each other.

#### Misprints

Turns out we can use embeddings to correct the typical coding misprints by looking at few nearest neighbors:

* recieve -> receive
* [grey -> gray](https://arstechnica.com/information-technology/2015/10/tomato-versus-ff6347-the-tragicomic-history-of-css-color-names)
* calback, callbak -> callback

#### Places

Nearest to "verde", islands:
```
verde
pitcairn
tahiti
hainan
oland
bonaire
turks
caicos
cape
hawaii
aruba
burundi
burkina
mullins
faso
cayman
carrizo
kabini
barts
bissau
```

"moscow":

```
micex
melbourne
pacific
norfolk
york
hongkong
asia
sydney
beijing
america
guam
europe
africa
eastern
niue
london
kong
atlantic
amsterdam
```

#### Companies

"google":

```
protobuf
uninterpreted
idgoogle
googleapis
upbdefs
horrorho
adsense
doubleclicksearch
bigquery
appengine
storagetransfer
urlshortener
googleapi
inappproduct
gwtorm
iocloseables
apis
bicycling
iogrpc'
```

bicycling! We all know about

{{% caption src="/post/id2vec/google_bicycle.jpg" width="half-width" /%}}

but why on earth did somebody name an entity in code like this?

"apple" yields numerous frameworks and technologies, nothing interesting. "microsoft":

```
idmicrosoft
bespelled
intellisense
catypes
bedisposable
becased
caavoid
tomicrosoft
caliterals
managemenet
iopackaging
caidentifiers
caparameter
idjustification
linq
fsteam
contoso
caconsider
caresource
```

managemenet? A [misprint](https://github.com/search?q=managemenet&type=Code&utf8=%E2%9C%93)?

#### Disclosure

These examples are not chosen randomly. Not everything that
one can imagine is magically reflected in the embeddings.

## Reproduce
We are in the process of cloning all Git repositories in the world and building the [engine](https://github.com/src-d/spark-api) to access and analyse them. We've built [ast2vec](https://github.com/src-d/ast2vec) and many other libraries and packages to do MLoSC on top.
Meanwhile, it is possible to grab the obsolete embeddings and play with them. They are the same as
we use in [vecino-reference](https://github.com/src-d/vecino/blob/master/reference/nearest_repos.ipynb),
the proof of concept notebook which finds similar GitHub repositories. They were built without
the AST co-occurrence scheme, the sequential sliding window was used instead. The vocabulary
size is 500,000. The source code used is >100,000 most starred repositories on GitHub cloned in October 2016 - that is, one year ago.

{{% gist vmarkovtsev "cc50b5c2de17e574f59dfe706a39a290" %}}

If you really wish to train your own identifier embeddings right here, right now, contact us and we
will figure out how to give you terabytes of data. Otherwise it is best to wait a few months
until we launch our datasets initiative. Alternatively join our Slack community and we're always happy to discuss generating data sets for you. 

#### Related research

[Exploring API Embedding for API Usages and Applications](http://home.eng.iastate.edu/~trong/projects/jv2cs/)

## Conclusion

It is possible to construct embeddings of identifiers in source code at scale, efficiently.
The input co-occurence matrix can be generated with the proposed algorithm based on AST traversal.
They capture funny relations specific to software engineering as well as some general associations.
The legacy model built with the previous generation processing pipeline on more than 100,000 most starred repositories cloned in October 2016 is available to download and evaluate.
