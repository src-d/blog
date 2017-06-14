---
author: abeaumont
date: 2017-06-06
title: "Announcing Babelfish"
draft: true
image: **TODO: Babelfish image (/post/announcing-babelfish/babelfish.jpg)**
description: "Announcing Babelfish, the project we are developing to build
representations of source code."
categories: ["technical"]
---

At source{d} we believe there's a possibility for programs to write code and for
new forms of automatic programming to emerge. Our
[Roadmap](https://blog.sourced.tech/post/our-roadmap/) states the first step in this
direction as: *Build representations of source code, developers and projects.*

Today we are announcing [Babelfish](https://doc.bblf.sh/), the project we are
developing to build these representations of source code.

## What's Babelfish?

Babelfish is a universal code parser. It can parse any file, in any language,
extract an abstract syntax tree (AST) from it, and convert it to a Universal
Abstract Syntax Tree [(UAST)](https://doc.bblf.sh/uast/specification.html)

Well, that's our objective, we are not there just yet, but we have designed an
architecture to achieve exactly that, and we're currently working on it.

## The architecture of Babelfish

**TODO: Architecture image**

As shown in the figure, Babelfish is a client/server system. Clients are source
code analysis tools that rely on the server for actual source code parsing,
written in different programming languages.

The server itself uses language drivers to perform the parsing, which are
divided in two parts, in order to minimise the work of developing a new driver:

- A language code parser, which builds a native AST. This parser can be built
  directly from the target language's compiler tools or libraries.
- An AST normalizer written in Go, that gives the UAST as a result.

The server uses containers to run these drivers through libcontainer. This
frees the user from having to handle dozens of different language ecosystems,
since the server just handles drivers using Docker images.

Have a look at the [documentation](https://doc.bblf.sh/architecture.html) for
further architecture details.

## What can I do with Babelfish today?

Babelfish project is still in an early development stage, but we already have
some components of its architecture working.

We have a working [server](https://github.com/bblfsh/server/), which can accept parsing requests,
launch the corresponding language driver and return a response with the parsed
file.

We have a [dozen language drivers](https://doc.bblf.sh/languages.html) in
various stages of development, with a quite advanced
[python driver](https://github.com/bblfsh/python-driver) and a usable
[java driver](https://github.com/bblfsh/java-driver).

We have a set of [tools](https://github.com/bblfsh/tools) that showcases how
babelfish works and how it can be used to build your own code analysis tools on
top of it.

## How can I contribute

Babelfish is being openly developed. The code is available at
[bblfsh project Github](https://github.com/bblfsh/) and discussions are held at
[source{d} community Slack](https://join.slack.com/sourced-community/shared_invite/MTkwNTM0ODEyODIzLTE0OTYxMzc5NTMtODRhMDYyNzAyYQ)
(#babelfish channel).

If you're interested in the project, you can look further at the
[documentation](https://doc.bblf.sh/), give it a try and report back any issue
you have.

If you find it useful, you are more than welcome to contribute code to any of
its components, or even write a driver for your favourite language! Drop by the
slack channel and tell us about it :)

P.S. [Santiago](https://github.com/smola) will give a talk about Babelfish at
[Curry On](http://curry-on.org/2017/sessions/babelfish-universal-code-parsing-server.html). Don't
miss it if you have the chance to be there!
