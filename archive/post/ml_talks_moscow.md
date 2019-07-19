---
author: waren
date: 2017-06-07
title: "source{d} tech talks, Moscow 2017"
image: /post/ml_talks_moscow/back_audience.jpg
description: "On June, 3-2017, source{d} dedicated their regular source{d} tech talks to Machine Learning and we chose to host the event in Moscow, Russia. For this conference, we invited speakers from Russia and abroad and gathered about 80 neural network aficionados in a former industrial area of the city. Let's make now a brief follow-up of this day."
categories: ["technical"]
---

On June, 3-2017, source{d} dedicated their regular [source{d} tech talks](http://talks.sourced.tech/) to Machine Learning and we chose to host the event in Moscow, Russia. For this conference, we invited [speakers](http://talks.sourced.tech/machine-learning-2017/speakers/) from Russia and abroad and gathered about 80 neural network aficionados in a former industrial area of the city.

![picture of the audience during Egor's speech](/post/ml_talks_moscow/audience.jpg)

## Day's programme

To begin with, everybody joined together around a hearty welcome breakfast inside [KL10CH](http://kl10.ch/) spaces in the city center.

![Photo during the welcome breakfast](/post/ml_talks_moscow/breakfast.jpg)

Then, after everybody woke up slowly, it was time for our CEO, [Eiso Kant](https://twitter.com/eisokant), to launch the main talks series. These lasted 45min each, with time for Q&A. Furthermore, 2 lightning talks of 15min occurred between the main ones, to address more specific and smaller topics.

## Main talks

### Statistical Analysis of Computer Program Text, _Charles Sutton_

**_"Source code is a means of human communication"_**, with this first formula, the professor at University of Edinburgh, [Charles Sutton](https://twitter.com/randomlywalking), couldn't better start the day. He next laid out his statistical approach to analyze source code texts. In order to extract from scripts what he called, _implicit knowledge_, he introduced three innovative software engineering tools inspired from machine learning and natural language processing (NLP) techniques:

* [Naturalize](http://groups.inf.ed.ac.uk/naturalize/), a probabilistic language model for source code which learns local coding conventions. It suggests renaming or reformatting changes so that your code would become more consistent.
* [HAGGIS, Mining idioms for code](https://github.com/mast-group/itemset-mining) a system that learns local recurring syntactic patterns, which we call idioms, using a nonparametric Bayesian tree substitution grammar (TSG).
* [Probabilistic API Miner (PAM)](https://github.com/mast-group/api-mining), a near parameter-free probabilistic algorithm for mining the most interesting API patterns from a list of API call sequences. It resolves fundamental statistical pathologies like the formation of redundant or spurious sequences.

{{% youtube BU_Zr29nwWI %}}

### Similarity of GitHub repositories by source code identifiers, _Vadim Markovstev_

Vadim, our lead of machine learning, went *va banque* and disclosed all the recent work he has done. The talk was a teaser for the upcoming source{d}'s ML Python stack: he presented all the technical details how it is possible to find similar GitHub repositories by their contents. Particularly, Vadim found the way to embed source code identifiers (previously used in topic modeling, see the [paper](https://arxiv.org/abs/1704.00135)) very similar to word2vec. Those embeddings can be trained at scale using [Swivel](https://github.com/vmarkovtsev/models/tree/master/swivel), a better alternative to [GloVe](https://nlp.stanford.edu/projects/glove/), and [src-d/swivel-spark-prep](https://github.com/src-d/swivel-spark-prep). Finally, similar repositories are searched using [src-d/wmd-relax](https://github.com/src-d/wmd-relax) - an optimized calculator of [Word Mover's Distance](http://www.cs.cornell.edu/~kilian/papers/wmd_metric.pdf).

{{% youtube v8Jy3xbpCqw %}}

### Probabilistic Programming for Mere Mortals, _Vitaly Khudobakhshov_

In his talk, [Vitaly](https://twitter.com/khudobakhshov) presented a review of an emerging topic at the juncture between cognitive sciences and [Artificial General Intelligence (AGI)](https://en.wikipedia.org/wiki/Artificial_general_intelligence). That's the huge controversy about what language is the most efficient to solve a particular problem that raised Vitaly's interest in [Probabilistic Programming (PP)](http://probabilistic-programming.org/wiki/Home). To make it simple, a [Probabilistic Programming Language (PPL)](https://en.wikipedia.org/wiki/Probabilistic_programming_language) is an ordinary programming language considered as a set of tools to help us understand the program's statistical behavior. This field of research has been particularly useful in designing programs like cognitive architectures, which use a wide range of programming techniques, or in minor issues like pattern matching and knowledge representation. Vitaly believed that PP with partial evaluation might be effectively applied to AGI problems.

![Photo of talking Vitaly Khudobakhshov](/post/ml_talks_moscow/vitaly.jpg)

Although PPL programs are close to ordinary software implementations, whose goal is to run the program and get some kind of output, the one of PP is analysis rather than execution. The main obstacle in using PP in large problems is the efficient implementation of inference. Some techniques like [genetic programming](https://en.wikipedia.org/wiki/Genetic_programming) and [simulated annealing](https://en.wikipedia.org/wiki/Simulated_annealing) techniques have yielded good results.

Finally, as a satisfying PPL, Vitaly gave us insights of [Church](http://projects.csail.mit.edu/church/wiki/Church)  which is a derivative of the programming language [Scheme](http://groups.csail.mit.edu/mac/projects/scheme/) with probabilistic semantics programming language, and whose syntax is simple and extensible.

### Sequence Learning and modern RNNs, _Grigory Sapunov_

[Grigory](https://www.researchgate.net/profile/Grigory_Sapunov) started his talk with a tiny, but not superfluous intro into RNN, [LSTM](http://colah.github.io/posts/2015-08-Understanding-LSTMs/) and GRU, along with their bidirectional and n-directional generalizations. Next, Grigory presented two interesting LSTM generalization : [tree-LSTM](https://arxiv.org/abs/1507.01526) and [Grid LSTM](https://arxiv.org/abs/1507.01526). The fist tree-structure outperforms the previous systems on predicting the semantic relatedness of two sentences and sentiment classification while the second network of LSTM provides a unified way of using LSTM for both deep and sequential computation.

Relying on these preliminary notions, he tackled issues about representation learning. The first idea was to find a model that pays attention to the word ordering unlike [word2vec](https://code.google.com/archive/p/word2vec/) based on the "bag of words" model. Secondly, he showed us how to match different modalities simultaneously thanks to [multi-modal learning](http://arxiv.org/abs/1411.2539) with striking examples like:

* [Text generation by image](http://arxiv.org/abs/1411.4555)
* [Image generation by text](https://arxiv.org/abs/1612.03242)
* [Code generation by image](https://arxiv.org/abs/1705.07962)

In a last paragraph, Grigory approached the [Connectionist Temporal Classification (CTC)](https://github.com/baidu-research/warp-ctc) technique, as well as the [Encoder-Decoder](https://github.com/farizrahman4u/seq2seq) architecture to train sequence-to-sequence neural network models.

{{% youtube ExtbPH2f3K4 %}}

### Neural Complete project, _Pascal Van Kooten_

[Pascal](https://github.com/kootenpv) ended our "AI on code" day with the perspective of auto-complete. He shared with us his project, called [Neural Complete](https://github.com/kootenpv/neural_complete) which aims at completing our source code through not only word but whole line suggestions.

 This tool based on a generative LSTM neural network is trained by python code on python code. Thus, the main result is a neural network trained to help writing neural network code. Finally, after giving us a demonstration of how it worked, he invited people to train the model on their own code so that it would be more relevant.

 {{% youtube YF20zzovlVA %}}

## Lightning talks

### Embedding the GithHub contribution graph, _Egor Bulychev_

Egor is a senior ML engineer at source{d}. He disclosed an unusual approach to embedding GitHub social graph nodes, compared it to [node2vec](https://github.com/aditya-grover/node2vec) and applied it to finding similar GitHub repositories. Since the nature of the similarity is completely different from Vadim's content analysis, the examples showed alternative results. One of the funniest Egor's findings was the proof that system administrators like to drink beer more than coders and they [tend to contribute to repositories related to beer](https://egorbu.github.io/techtalks-2017-moscow/#23).

{{% youtube mYYkngb0TR4 %}}

### Hercules and His Labours, _Vadim Markovstev_

Vadim went on stage for the second time and demonstrated the supremacy of [src-d/hercules](https://github.com/src-d/hercules), a super fast command line tool to mine the development history of Git repositories. Hercules uses [src-d/go-git](https://github.com/src-d/go-git), our advanced and nearly feature complete Git client and server implementation in pure Go. Provided by the whole repository is stored in-memory and the original incremental blame algorithm, Hercules processed the whole Linux kernel repository in just two hours. We encourage everybody to try Hercules on their own projects!

{{% youtube 2_oBJCnOFSI %}}

## After-work-drinks

At the end of the talks, we spent pleasant time eating and drinking beers together. It was time to share our feelings about the day. The speakers were also available to develop their talks and answer more questions.

![Photo of all speakers of the day](/post/ml_talks_moscow/speakers.jpg)

The [Moscow source{d} tech talks](http://talks.sourced.tech/machine-learning-2017/) ended here. Now the team is already preparing our next [Frontend talks](http://talks.sourced.tech/front-2017/) in Madrid on the 24th of June 2017. You can get your free tickets on [Eventbrite](https://www.eventbrite.com/e/sourced-tech-talks-frontend-registration-33889725080?utm_content=buffer5e852&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer).

## Acknowledgements

source{d} would like to thank the [speakers](http://talks.sourced.tech/machine-learning-2017/speakers/) and the attendees for sharing our passion for Machine Learning on Code and for their kind feedback on our [post event survey](https://sourced.typeform.com/report/PFqEvm/BKWi). If you feel interested in any of our projects, do not hesitate to join our [source{d} community slack](https://sourced-community.slack.com/messages/C5CQY9486/). You can also take a look at our [job opportunities](//sourced.tech/careers/) ; source{d} is always looking for new talents.

To conclude on a more personal side, I want to sincerely express my gratitude to all people at [source{d}](//sourced.tech/) who made a contribution of any kind in the success of this event in such a beautiful city.

![Photo of Russian basilic](/post/ml_talks_moscow/basilic.jpg)
