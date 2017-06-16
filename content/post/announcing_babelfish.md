---
author: abeaumont
date: 2017-06-19
title: "Announcing Babelfish"
image: /post/announcing_babelfish/babelfish.png
description: "Announcing Babelfish, the project we are developing to build
representations of source code."
categories: ["technical"]
---

<style>
p.dt {
  margin-top: -16px;
  font-style: italic;
}
</style>

At source{d} we believe there's a possibility for programs to write code, and for
new forms of automatic programming to emerge. Our
[Roadmap](https://blog.sourced.tech/post/our-roadmap/) states the first step in this
direction as: *Build representations of source code, developers and projects.*

Today we are announcing [Babelfish](https://doc.bblf.sh/), the project we are
developing to build these representations of source code.

![Babelfish logo](/post/announcing_babelfish/babelfish.png)

## What's Babelfish?

Babelfish is a universal code parser. It can parse any file, in any language,
extract an abstract syntax tree (AST) from it, and convert it to a Universal
Abstract Syntax Tree [(UAST)](https://doc.bblf.sh/uast/specification.html)

Well, that's our objective, we are not there just yet, but we have designed an
architecture to achieve exactly that, and we're currently working on it.

## The architecture of Babelfish

As shown in the figure, Babelfish is a client/server system. Clients are source
code analysis tools that rely on the server for actual source code parsing,
written in different programming languages.

![architecture-overview](/post/announcing_babelfish/architecture-overview.png)
<p align="center" class="dt">Architecture overview.</p>

The server itself uses language drivers to perform the parsing, which are
divided in two parts, in order to minimise the work of developing a new driver:

- A language code parser, which builds a native AST. This parser can be built
  directly from the target language's compiler tools or libraries.
- An AST normalizer written in Go, that gives the UAST as a result.

The server uses containers to run these drivers through libcontainer. This
frees the user from having to handle dozens of different language ecosystems,
since the server executes drivers using Docker images.

Have a look at the [documentation](https://doc.bblf.sh/architecture.html) for
further architecture details.

## What can I do with Babelfish today?

Babelfish project is still in an early development stage, but we already have
some components of its architecture working.

We have a working [server](https://github.com/bblfsh/server/), which can accept parsing requests,
launch the corresponding language driver, and return a response with the parsed
file.

We have a [dozen language drivers](https://doc.bblf.sh/languages.html) in
various stages of development, with a quite advanced
[python driver](https://github.com/bblfsh/python-driver), and a usable
[java driver](https://github.com/bblfsh/java-driver).

We have a set of [tools](https://github.com/bblfsh/tools) that showcase how
babelfish works, and how it can be used to build your own code analysis tools on
top of it.

If you can try it yourself, you can do so with a small set of commands.
First, make sure you have [Go](https://golang.org/doc/install) installed
and `GOPATH` properly set.

We can then install the tools with the following commands:

```
mkdir -p ${GOPATH}/src/github.com/bblfsh/
cd ${GOPATH}/src/github.com/bblfsh/
git clone https://github.com/bblfsh/tools.git
cd tools
make dependencies
go build
```

This will build the our showcase tools and install them in `${GOPATH}/bin`.

We can get the server running just using docker:

```
docker run --privileged -p 9432:9432 --name bblfsh bblfsh/server
```

And verify that everything is working properly:

```
> ${GOPATH}/bin/bblfsh-tools dummy /usr/lib/python2.7/base64.py
DEBU[0000] executing command
DEBU[0000] reading file /usr/lib/python2.7/base64.py
DEBU[0000] dialing request at localhost:9432
It works! You can now proceed with another tool :)
DEBU[0087] exiting without error
```

Note that this command may take a while,
since the server will have to get the python driver the first time it runs.

Now we can try for example, the cyclomatic complexity sample tool:

```
> ${GOPATH}/bin/bblfsh-tools cyclomatic /usr/lib/python2.7/base64.py
DEBU[0000] executing command
DEBU[0000] reading file /usr/lib/python2.7/base64.py
DEBU[0000] dialing request at localhost:9432
Cyclomatic Complexity =  47
DEBU[0000] exiting without error
```

## How can I contribute?

Babelfish's development is open
and is based on [BIPs](https://doc.bblf.sh/proposals/README.md).
The code is available at
[bblfsh project Github](https://github.com/bblfsh/), and discussions are held at
[source{d} community Slack](https://join.slack.com/sourced-community/shared_invite/MTkwNTM0ODEyODIzLTE0OTYxMzc5NTMtODRhMDYyNzAyYQ)
(#babelfish channel).

If you're interested in the project, you can look further at the
[documentation](https://doc.bblf.sh/), give it a try, and report back any issues
you have.

If you find it useful, you are more than welcome to contribute code to any of
its components, or even to write a driver for your favourite language! Drop by the
slack channel and tell us about it :)

P.S. [Santiago](https://github.com/smola) is giving a talk about Babelfish both at
[Curry On](http://curry-on.org/2017/sessions/babelfish-universal-code-parsing-server.html)
and [Docker meetup](https://www.meetup.com/Docker-meetups/events/240565310/).
Don't miss it if you have the chance to be there!
