---
author: campoy
date: 2018-02-27
title: "Why did I join source{d}? - Francesc Campoy"
draft: false
image: /post/why-i-joined-sourced-francesc/banner.png
description: "The first post of a series on why multiple employees joined source{d}. This one is by Francesc Campoy."
categories: ["culture", "why-i-joined"] 
---

On November 1st I left Google and in my
[goodbye note](https://medium.com/@francesc/thanks-and-goodbye-google-friends-3caf770a66dc)
I sneakily said I would "try my luck in a small startup with huge potential".
A month has passed, and the time to explain more has come.
So let me tell you what I'm up to lately.

I am now the VP of Developer Relations at [source{d}](https://sourced.tech).
Maybe you've never heard about it, maybe you've heard a bit, or used some of
their awesome open source libraries such as
[go-git](https://github.com/src-d/go-git),
[kmcuda](https://github.com/src-d/kmcuda),
[go-kallax](https://github.com/src-d/go-kallax), or
[proteus](https://github.com/src-d/proteus).

Before I tell you about what source{d} does, let me give you a bit of
context.

### Source Code as Data

For maintainers of any large codebase, such as open source projects or large
tech companies, it is essential to be able to understand their codebases.
Critical decisions from a business and engineering perspectives are made
based on this information.

A year ago I wrote an article on how one could
[use Bigquery to analyze all of the Go code available on GitHub]((https://medium.com/google-cloud/analyzing-go-code-with-bigquery-485c70c3b451)).

Later on, this kind of analysis started to become a requirement to justify
additions to Go's standard library.

For instance, the
[`time.Until` function was added to Go with this proposal](https://github.com/golang/go/issues/14595) after an analysis of
how many times we could find an equivalent piece of code on GitHub.

![screenshot from the proposal](/post/why-i-joined-sourced-francesc/issue.png)
[comment](https://github.com/golang/go/issues/14595#issuecomment-235651095) on the issue

This approach is powerful, but it definitely has its limitations.

First of all, it limits the analysis we can perform to regular expressions
on source code. Most questions require a deeper understanding of the structure
of source code, such as the abstract syntax tree, or even type information.

Additionally, when I said "all of the repositories on GitHub" this was not completely
accurate, it is a partial dump of all of those repositories, and even if it was complete
many other repositories are not on GitHub: what about the Unix kernel?

### So what does source{d} do?

So what does source{d} do? They ... We! provide a powerful platform to access all of this
data in an easier and more powerful way.

Rather than limiting repositories on GitHub, source{d} is able to analyze any code
repository in the world, including those that are not even on the internet by running
our open source software on your own premise.
We're very proud of the pipeline we're building to ingest every public git repo in the world.

Secondly, we consider that the input to many good analysis should be the abstract syntax
tree of a program rather than the flat suite of bytes that is the source code.
We believe this so much that we've created [Babelfish](https://doc.bblf.sh/), a project that
one day will be able to parse any programming language and generate an abstract syntax
tree in a universal format. We call this format a universal abstract syntax tree or UAST.

Finally, while we love [regular expressions](https://xkcd.com/208/), we believe that Machine Learning will
revolutionize how we analyze programs. There's a never-ending list of use cases that could benefit from ML
over source code: autocompletion (that doesn't require a connection to a 3rd party server),
code linters, architecture analyzers, automated code reviews, and (one day) source code generation
from unit tests or even natural language specifications.

If you're curious, you should go see [our papers](https://arxiv.org/abs/1704.00135) and
[our blog posts](https://blog.sourced.tech/) on these topics.

What's my favorite part of the company? The incredibly incredibly talented team tackling
problems at different layers:

- retrieval: let's fetch all of the code in the world.
- engine: creating a declarative API to access all of that code.
- ML: building and training models that can power complex applications.
- applications: finding the use cases that allows us to prove the power of the platform, while providing as much benefit to the community as possible.

![we want you](/post/why-i-joined-sourced-francesc/wewantyou.jpg)

But the applications team at source{d} is not the only one building applications,
because we're building a platform. We want to empower every developer with access
to the largest code dataset and the most advanced ML tools, so with our tech and your
creativity we can improve how fifty million developers in the world write code.

### So what's coming?

As VP of Developer Relations my job is to strategize how source{d} can empower developers
all around the world to write better code by:

- writing new models that will power amazing tools,
- building tools powered by ML on code, and of course
- using those developer tools to analyze and improve source code.

source{d} is building a platform by *developers* where *developers* can build tools for *developers* [[1]](https://www.youtube.com/watch?v=KMU0tzLwhbE).
So imagine how excited I am to be right in the center of this hurricane of Developer Relations.

### Want to learn more?

Join the [source{d} community slack channel](https://sourced.tech/), follow us on
[twitter](https://twitter.com/sourcedtech), or drop me a line on francesc@sourced.tech.
I'm incredibly excited about the new opportunities that ML on code provide. Together we
can build better tools, for better source code, for eventually a better world.
