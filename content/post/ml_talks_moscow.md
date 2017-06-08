---
author: waren
date: 2017-06-07
title: "About our tech talks in Moscow"
image: /post/ml_talks_moscow/back_audience.jpg
description: "On June, 3-2017, we dedicated our regular [source{d} tech talks](http://talks.sourced.tech/) to Machine Learning and we chose to host the event in Moscow. For this conference, we invited speakers from Russia and abroad and gathered about 80 neural network aficionados in an former industrial area of the city. Let's make now a brief follow-up of this day."
categories: ["technical"]
---

<style>
p.dt {
  margin-top: -16px;
  font-style: italic;
}
.twitter-tweet {
  margin-left: auto;
  margin-right: auto;
}
.verbatim {
  font-size: 0.85em;
}
</style>

![picture of the audience during Egor's speech](/post/ml_talks_moscow/audience.jpg)

On June, 3-2017, we dedicated our regular [source{d} tech talks](http://talks.sourced.tech/) to Machine Learning and we chose to host the event in Moscow. For this conference, we invited speakers from Russia and abroad and gathered about 80 neural network aficionados in an former industrial area of the city.

# Day's programme

To begin with, everybody joined together around a hearty welcome breakfast inside [KL10CH](https://www.linkedin.com/company/kl10ch) spaces in th city center.

<img src="/post/ml_talks_moscow/breakfast.jpg" id="b2" alt="Photo during the welcome breakfast">
<style>
#b2 {
  width: 600px;
  height: 300px;
  object-fit: contain;
}
</style>

Then, after everybody woke up slowly, it was time for our CEO, [Eiso Kant](https://twitter.com/eisokant), to launch the main talks series. These lasted 45min each with time for Q&A. Furthermore, 2 lightning talks of 15min occurred between the main ones to address more specific topics.

# Main talks

### Statistical Analysis of Computer Program Text, _Charles Sutton_

**_"Source code is a means of human communication"_**, with this first formula, the professor at University of Edinburgh, Charles Sutton, couldn't better start the day. He next laid out his statistical approach to analyze source code texts. In order to extract from scripts what he called, _implicit knowledge_, he introduced three innovative software engineering tools inspired from machine learning and natural language processing (NLP) techniques :

* **Naturalize**, a probabilistic language model for source code which learns local coding conventions. It suggests renaming or reformatting changes so that your code would become more consistent.
* **HAGGIS, Mining idioms for code** a system that learns local recurring syntactic patterns, which we call idioms, using a nonparametric Bayesian tree substitution grammar (TSG).
* **Probabilistic API Miner (PAM)**, a near parameter-free probabilistic algorithm for mining the most interesting API patterns from a list of API call sequences. It resolves fundamental statistical pathologies like the formation of redundant or spurious sequences.
</br>
</br>

<img src="/post/ml_talks_moscow/charles.jpeg" id="cs" alt="Photo of talking Charles Sutton">
<style>
#cs {
  width: 600px;
  height: 300px;
  object-fit: contain;
}
</style>


### Similarity of GitHub repositories by source code identifiers, _Vadim Markovstev_

<img src="/post/ml_talks_moscow/vadim.jpg" id="vm" alt="Photo of talking Vadim Markovstev">
<style>
#vm {
  width: 500px;
  height: 250px;
  object-fit: contain;
}
</style>

### Probabilistic Programming for Mere Mortals, _Vitaly Khudobakhshov_

In his talk, Vitaly presented an review of an emerging topic which is probabilistic programming. He described programming languages problems where this field of research could offer some solutions.

Then, he started a discussion about how we could implement probabilistic programming language and how we could embed probabilistic programming capabilities into a general purpose programming language.

<img src="/post/ml_talks_moscow/vitaly.jpg" id="vk" alt="Photo of talking Vitaly Khudobakhshov">
<style>
#vk {
  width: 500px;
  height: 250px;
  object-fit: contain;
}
</style>

### Sequence Learning and modern RNNs, _Grigory Sapunov_

Grigory started his talk with a tiny intro into RNN, LSTM and GRU

<img src="/post/ml_talks_moscow/grigory.jpg" id="gs" alt="Photo of talking Grigory Sapunov">
<style>
#gs {
  width: 500px;
  height: 250px;
  object-fit: contain;
}
</style>

### Neural Complete project, _Pascal Van Kooten

[Pascal](https://github.com/kootenpv) ended our "AI on code" day with the perspective of auto-complete. He shared with us his project, called [Neural Complete](https://github.com/kootenpv/neural_complete) which aims at completing our source code through not only word but whole line suggestions.

 This tool based on a generative LSTM neural network is trained by python code on python code. Thus, the main result is a neural network trained to help writing neural network code. Finally, after giving us a demonstration of how it worked, he invited people to train the model on their own code so that it would be more relevant.

<img src="/post/ml_talks_moscow/pascal.jpg" id="cs" alt="Photo of talking Charles Sutton">
<style>
#cs {
  width: 500px;
  height: 250px;
  object-fit: contain;
}
</style>

# Lightning talks

### Embedding the GithHub contribution graph, _Egor Bulychev_

<img src="/post/ml_talks_moscow/egor.jpg" id="eb" alt="Photo of talking Egor Bulychev">
<style>
#eb {
  width: 500px;
  height: 250px;
  object-fit: contain;
}
</style>

### Hercules and His Labours, _Vadim Markovstev_

</br>

</br>

# Time of sharing

At the end of the talks, we spent pleasant time eating and drinking beers together. It was time to share our feelings about the day. The speakers were also available to develop their talks and answer more questions.

<img src="/post/ml_talks_moscow/speakers.jpeg" id="sp" alt="Photo of all speakers of the day">
<style>
#sp {
  width: 800px;
  height: 400px;
  object-fit: contain;
}
</style>

# Acknowledgements

We would like to thank the speakers and the attendees for sharing our passion for Machine Learning on Code.
And on my side, I want to sincerely express my gratitude to all people at [Source{d}](http://sourced.tech/) who made a contribution of any kind in this event in such a beautiful city.

<img src="/post/ml_talks_moscow/basilic.jpeg" id="b" alt="Photo Russian basilic">
<style>
#b {
  width: 800px;
  height: 400px;
  object-fit: contain;
}
</style>
