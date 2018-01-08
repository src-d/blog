---
author: campoy
date: 2018-01-09
title: "Announcing the latest go-git!"
image: /post/go-git-v4/go-git.png
description: "After a year of intense work, we're happy to announce the latest and best release of go-git ever. go-git v4 includes many new features, making it the most used and feature complete git library written in Go, and in use on production at companies like source{d} and keybase."
categories: ["git", "announcement", "OSS", "technical"]
---

After a bit over a year of intense work, we're happy to announce the
latest and best release of [go-git](https://github.com/src-d/go-git) yet!
`go-git v4` includes many new features, making it the most used and feature
complete git library written in Go.

## what's new?

A year and almost 800 commits have passed since `go-git v3.2.0` was released,
our 55 amazing contributors have really been very busy. But all of this effort
was worth it and it definitely shows.

Many (really [many](https://github.com/src-d/go-git/releases/tag/v4.0.0-rc1))
new features have been added to `go-git`. `go-git` has gone from providing
just some useful features to all the common used git functionalities.
It is now a real alternative to shelling out `git`!

### moving to Apache v2

We always listen to the OSS community, and many voices were asking for a new
license. As of today we're moving `go-git` to
[Apache License, Version 2](https://www.apache.org/licenses/LICENSE-2.0).

We hope this will help those wondering whether `go-git` was the good solution
to their problems!

### we have a logo, and it's adorable!

Following the tradition of many other Go projects, we've adopted the gopher as
our mascot, and integrate it with the git logo into this amazing creation!

![go-git logo](/post/go-git-v4/go-git-banner.png)

Big shout-out to our designer [Ricardo Baeta](https://github.com/ricardobaeta)
for the amazing art.

## go-git in production

We obviously use `go-git` at source{d} for projects like [borges](https://github.com/src-d/borges)
and [hercules](https://github.com/src-d/hercules) but we're by far not the only ones.

Projects like [klone](https://github.com/kris-nova/klone) by the amazing
[Kris Nova](https://twitter.com/Kris__Nova), ours friends at
[pachyderm](https://github.com/pachyderm/pachyderm), and even the
[zoekt](https://github.com/google/zoekt) project by Google use `go-git`.

Last but definitely not least, one of the `go-git` users I'm almost sure
you've heard about are [keybase](https://keybase.io).
They [recently announced](https://keybase.io/blog/encrypted-git-for-everyone)
the support for fully encrypted git repositories.
Some might have missed their shout-out to the "excellent `go-git` project" (we didn't).

### and you?

Are you also using `go-git` in production or considering it?

Let us know! We'd love to hear about you.
Join the `go-git` community on Slack using the form below.

## thanks

We want to take this opportunity to thank each and every single one of our [contributors](https://github.com/src-d/go-git/graphs/contributors).
A special shout-ot goes to [Jeremy Stribling](https://github.com/strib) and [Ori Rawlings](https://github.com/orirawlings) who made this release possible.

You all are the real GitHub stars of this project.