---
author: eiso
date: 2016-12-12
title: "Our Master Plan"
draft: false
image: 
description: "Since early on in the history of neural networks this has raised the question, if 
systems can be self-learning, can they also be self-adapting. Can they program themselves?"
categories: ["culture"] 
---
The starting point of source{d} has always been analyzing source code, from day 1 we believed
that by understanding what a developer is coding, we could understand the developer. 
The further we went down the rabbit hole ([wikipedia definition](https://en.wikipedia.org/wiki/Down_the_Rabbit_Hole)) 
we learned that building an understanding of source code has bigger implications...

In the last few years [neural networks](https://en.wikipedia.org/wiki/Artificial_neural_network) 
have made a comeback ([link](#)); systems that can be self-learning and trained instead of programmed. 
Since early on in the history of neural networks this has raised the question, if systems can be 
self-learning, can they also be self-adapting. Can they program themselves? Over the last 4 decades there 
has been a wealth of research in this area ([list of research papers](#)) but we're still in the early days. 
Computer Science since the invention of what we know to be a digital computer is a young field 
compared to the other sciences.

At source{d} we believe that neural networks have opened the possibility for programs to self-adapt 
their code and for new forms of ([automatic programming](https://en.wikipedia.org/wiki/Automatic_programming))
to emerge.

At source{d} we believe programming is an act of creativity, similar to painting or writing (read our 
[manifesto](http://sourced.tech/manifesto/)) and to treat it purely as a field of 
[symbolic computation](https://en.wikipedia.org/wiki/Symbolic_computation) would be missing the creative 
expression you observe in code. 

Currently there are an estimated 50 million people in the world who know a programming language and 
21 million professional software developers. To observe if a self-learning system can be built that 
understands and one day, writes source code, we want to build technology that is useful for developers 
and whose accuracy can be judged by developers. 

We've formulated this as several challenges we believe need to be sequentially conquered:

### Challenge #1: Cluster the world's source code, developers and projects based on their similarity 
By building representations for source code, developers and projects we aim to capture style, semantics, 
syntax and other sets of features that allow us to understand how we as humans program. 

As a byproduct of achieving this we believe this will allow developers to find projects & 
teams to work with based on code. We believe it's important to build the platform that allows this 
(read our [manifesto](http://sourced.tech/manifesto/)) and should provide a feedback 
loop to our technology.

### Challenge #2: Build Artificial Intelligence that does real-time assisted programming
Training a neural network to emulate the work of human developers means you have to have build an 
understanding of the different ways a piece of code can be written. 

If you consider a simple piece of code written by a developer: a function that has well defined 
inputs and outputs and no side-effects, and you imagine how a machine might be able to write this. 
One of the ways is a program that is trained to write all possible programs that generate the expected 
outputs for the defined inputs. This universe of all possible programs grows larger the more complex 
the function is. Then we could compute every function and understand its performance by evaluating 
its execution time and space used (memory/disk) and choose the most optimal one. 

If you think about how a developer writes this same simple program, you start seeing the notion of 
intuition and experience. All of this experience is captured in the trillions of lines of code that have
already been written by developers, however as programs stop being so simple the definition of the right 
code blurs. Performance is no longer the only notion that defines the right program. This is why it's 
important to tackle Challenge #1 before #2.

The practical application is technology that can suggest you code, rewrite your code, change your 
codes style, optimize code and applications we haven't yet thought off. 

### Challenge #3: Achieve AI that is self-programming and adapting to its environment
