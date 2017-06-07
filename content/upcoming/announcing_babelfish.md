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

At source{d} we believe there's a possibility for programs to write their own
code and we are exploring that possibility. Our
[Roadmap](https://blog.sourced.tech/post/our-roadmap/) states the first step in this
direction as: *Build representations of source code, developers and projects.*

Today we are announcing Babelfish, the project we are developing to build this
representations of source code.

## What's Babelfish?

Babelfish is a universal code parser. It can parse any file, in any language,
extract an abstract syntax tree (AST) from it, and convert it to a Universal
Abstract Syntax Tree [(UAST)](https://doc.bblf.sh/uast/specification.html)

Well, that's our objective, we are not there just yet. We have designed an
architecture we're currently working on to achieve that.

## The architecture of Babelfish

**TODO: Architecture image**

As shown in the figure, Babelfish is a client/server application. A client is a
language analysis tool that wants to perform some analysis on a source code. It
connects to the server handle source code parsing by using the needed language
driver containers.

Language drivers are divided in two parts, in order to minimise the work of
developing a new driver:

- A language code parser, which builds a native AST. This parser can be built
  directly from target language's compiler tools or libraries.
- An AST normalizer written in Go, that gives the UAST as a result.

You can look at the [documentation](https://doc.bblf.sh/architecture.html) for
further architecture details.

## What can I do with Babelfish today?

Babelfish project is still in an early development stage, but we already have
some components of its architecture working.

We have a working [server](https://github.com/bblfsh/server/), which can accept parsing requests,
launch the corresponding language driver and return a response with the parsed
file.

We have a dozen language drivers in various stages of development, with a quite
advanced [python driver](https://github.com/bblfsh/python-driver) and a usable
[java driver](https://github.com/bblfsh/java-driver).

We have a set of [tools](https://github.com/bblfsh/tools) that showcase how
babelfish works and how it can be used to build your own code analysis tools on
top of it.

## How can I contribute

Babelfish is being openly developed. The code is available at
[bblfsh project Github](https://github.com/bblfsh/), discussions are held at
[source{d} community Slack](https://join.slack.com/sourced-community/shared_invite/MTkwNTM0ODEyODIzLTE0OTYxMzc5NTMtODRhMDYyNzAyYQ)
(#babelfish channel).

If you're interested in the project, you can look further at the
[documentation](https://doc.bblf.sh/), give it a try, report back any issue you
have.

If you find it useful you're more than welcome to contribute code any of its
components, or even write a driver to your favourite language! Drop by the slack
channel and tell us about it :)

P.S. [Santiago](https://github.com/smola) will give a talk about Babelfish at
[Curry On](http://curry-on.org/2017/sessions/babelfish-universal-code-parsing-server.html). Don't
miss it if you have the chance to be there!
