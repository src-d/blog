---
author: dripolles
date: 2015-10-19
title: Notes on the Deep Learning Summit London 2015
image: /post/deep_learning_summit/intro.png
description: "Finding the most appropriate developers for a job offer is a very tough task, as proven by the plethora of tech recruiters that seem to be constantly shooting in the dark or outright lost."
---

![Logo](/post/deep_learning_summit/intro.png)

Finding the most appropriate developers for a job offer is a very tough task, as proven by the plethora of tech recruiters that seem to be constantly shooting in the dark or outright lost. At [source{d}](http://sourced.tech), we try to apply a "work smarter, not harder" mentality to this problem, by using automated processes to help us find the better matches without having to manually comb through thousands of profiles. It seems quite obvious that [deep learning](https://en.wikipedia.org/wiki/Deep_learning) can be a great aid to those processes, and that's why some of us took a flight to London to attend the [Deep Learning Summit 2015](https://www.re-work.co/events/deep-learning-london-2015).

We went there as total novices in the area, so we were expecting to absorb as much knowledge as possible from the experts gathering there. I guess that's why I came back home with lots of notes, sources to read and unanswered questions. To sum it all up: it was great!

The amount of different topics and the quality of the talks was such that I’m actually having a hard time deciding what to write about. There was a good mix between more academic, bleeding edge research and down to earth commercial applications, with a lot of topics falling in the middle ground. I'll talk about some of them, chosen by the perfectly unbiased criteria of being found cool by me.

I was personally amazed by the research done in [perpetual learning](http://arxiv.org/abs/1509.00913), closely related to [generative models](http://www.cifar.ca/j%C3%B6rg-bornschein). The main idea is that two deep neural networks act as a "memorize & learn" duo, so one is trained to recognize patterns (abstraction) and the other is trained to generate more examples to train the first (synthesis). This way, they can improve each other in some kind of automatic feedback loop, and do not depend on having so much training data. Of course, this is all very new and preliminary, but the concept is really interesting, so we'll see where it goes.

Also, still at a very academic level, I was pleasantly surprised by the prevalence of [word2vec](https://en.wikipedia.org/wiki/Word2vec). For those uninitiated, it's a method to transform words into vectors of numbers that carry semantic meaning and can be manipulated arithmetically. In my limited knowledge, I had already seen it mentioned often as a very powerful tool for language analysis, so at least it was something that made me feel that we are on the right track. What was more interesting was how that concept is being extended or built upon to achieve even harder goals.

For example, [Prof. Lior Wolf](http://www.cs.tau.ac.il/~wolf/) gave a very interesting talk about using deep learning to automatically link images to sentences that describe them. To achieve that, and starting from word2vec, he explained how to use [Fisher vectors (PDF warning)](http://www.cs.tau.ac.il/~wolf/papers/Klein_Associating_Neural_Word_2015_CVPR_paper.pdf) to improve the models; accidentally, he made me take note that I _really_ need to dust off my algebra, but that's another story.

Another pleasant surprise  was how [Miriam Redi](https://labs.yahoo.com/researchers/redi) is using deep learning to measure the aesthetic quality of images. Teaching computers [what is beautiful](https://labs.yahoo.com/publications/6737/beauty-capturing-faces-rating-quality-digital-portraits) and using that to help humans produce better art, or just find hidden gems in an ocean of socially shared images is, in my opinion, a very noble use of technology. I must also mention Appu Shaji from [EyeEm](https://www.eyeem.com/community), a product centered around this idea of computational aesthetics.

I've just written a lot about image processing, but deep learning has also proven to be a very powerful tool in manipulating natural language. Currently, the most interesting advancements seem to move towards understanding context, intent, and adapting to very different users (from accents to cultural differences). Some speakers that touched on these topics were Paul Murphy from [Clarify](http://clarify.io/) and Marius Cobzarenco from [re:infer](https://reinfer.io/).

The commercial applications were quite abundant and varied; from [apps that help you be happier and healthier](http://biobeats.com/) by giving personal advice to [cameras that count bycicles](http://www.kleintech.net/). Of course, there's [finding a job that you'll love](http://sourced.tech), too.

I could go on and on about all the amazing speakers and the vast knowledge that was shared at this conference, but I want to finish by reflecting on a quote from the [Weave.ai](http://www.weave.ai/) talk: _fifty percent of AI is UI_. This technology is so magic that sometimes it's scary, and it's our job to learn to present it as friendly and accessible as possible. Getting everyone comfortable with the things that computers will be capable of doing is going to be a daunting task. I hope we can rise to the challenge.
