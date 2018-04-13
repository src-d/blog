---
author: alcortesm
date: 2016-02-15
title: "Levenshtein distance, LCS, diff and blame"
image: /post/meetup-blame/intro.jpg
description: "Papers we love Madrid Meetup: Levenshtein distance, LCS, diff and blame."
categories: ["technical"]
---

There are some interesting [meetups](http://www.meetup.com) going on in Madrid,
and as part of the engineering team at **source{d}**, we often attend and
organize some of them; it is a nice way to blow off some steam after work,
learn some cool new things and meet quite interesting people.

A few weeks ago, at a [Papers we love
Madrid](http://www.meetup.com/Papers-We-Love-Madrid/) meetup, I had the chance
to give a talk about how `git blame` works.*


Blaming a file in git is an operation that identifies who modified each of the
lines in a file, along with the modification date and other details.  This
comes in handy when you want to know which member of your team wrote a particular piece of
code or who is to blame for a bug }:-).

For example, let's blame `src/bufio/bufio.go` from the standard Go Distribution:

```nohighlight
$ git blame src/bufio/bufio.go
[...]
64776da4 src/pkg/bufio/bufio.go (Rob Pike          2011-12-13 15:07:17 -0800  40) const minReadBufferSize = 16
4ffc7992 src/pkg/bufio/bufio.go (Rui Ueyama        2014-03-24 11:48:34 -0700  41) const maxConsecutiveEmptyReads = 100
[...]
```

According to this `git blame` output, it seems that the declaration of the
constant `minReadBufferSize` was last modified (or created) by Rob Pike in 2011
while the last version of `maxConsecutiveEmptyReads` is attributed to Rui Ueyama in
2014.

The current `git blame` implementation is a highly optimized and quite
powerful piece of code, but its core functionality is easy to understand
once you grasp a few concepts:

1. Levenshtein Distance
2. Longest Common Subsequence Problem
3. Diff
4. Tracking Lines Across File Revisions

The goal of the talk was to understand these concepts and some of their more
naive implementations.  This blog post is not going to be a full transcription
of my talk, but allow me to tease you with a brief introduction to these
interesting topics:

## 1. Levenshtein Distance

The Levenshtein distance is a popular measure of how (dis)similar two strings
are.  More precisely, it is the minimum number of _edits_ you have to perform on
one of them to turn it into the other, where by edits I mean: adding, removing
or changing a single character.

As expected, the Levenshtein distance of two identical strings is 0:

```Go
a := "pain"
Levenshtein(a, a) // is 0
```

For strings that differ only in one _edit_, the Levenshtein distance should be
1:

```Go
a := "pain"
b := "plain"
Levenshtein(a, b)  // is 1, just insert 'l' at a[1]

c := "pan"
Levenshtein(a, c)  // is 1, just remove 'i' from a[2]

d := "pawn"
Levenshtein(a, d)  // is 1, just change 'i' to 'w'
```

When the strings differ in more than one _edit_, calculating the
Levenshtein distance is no longer trivial since there are many different
combinations of edits that will allow you to turn one string into another,
and only some of them will have the minimum number of edits:

```Go
e := "Lost"
f := "plot"
Levenshtein(e, f)  // is 3, here is one possible
                   //       combination of edits:
                   //   - change 'L' at e[0] to 'p'
                   //   - insert 'l' at e[1]
                   //   - remove 's' from e[3]
```

Calculating the Levenshtein distance of two strings is a fun and interesting
[programming workout](https://www.youtube.com/watch?v=wXQLil_SGCI). In the case
that you get stuck on it, you will find a recursive solution, as well as a dynamic
programming one, in the [slides from my
talk](https://drive.google.com/file/d/0B05KyBUlYY2TV2N6X2x6ZWhBXzQ/view?usp=sharing).

## 2. Longest Common Subsequence Problem

The Longest Common Subsequence Problem (LCS for shorts), is a classic computer
science problem, consisting in finding the longest subsequence common to all
sequences in a given set.

For example, the LCS of the strings `"pain"` and `"plans"` is `"pan"`, as it
has all the characters common to both strings, without messing up the character
ordering.

Solving this problem for longer strings is not trivial, though:

```Go
a := "AAACCGTGAGTTATTCGTTCTAGAA"
b := "CACCCCTAAGGTACCTTTGGTTC"
LCS(a, b) // is "ACCTGGTTTTGTTC" or "ACCTAGTATTGTTC" ...
```

Knowing the LCS of two strings is equivalent to knowing the actual set of
edits you need to perform to turn one into the other. You will find an
intuitive explanation of this important equivalence in the [slides from the
talk](https://drive.google.com/file/d/0B05KyBUlYY2TV2N6X2x6ZWhBXzQ/view?usp=sharing).

## 3. Diff

The Diff Algorithm is the basis of `git blame` and a venerable piece of
code that has been laying around since 1970.

Given two files, the `diff` command will return the _line edits_ you have to
perform to one of them, to turn it into the other. For example: given the files
`a.txt` and `b.txt`...

```nohighlight
$ cat a.txt
aaa
aaaaa
aa

$ cat b.txt
bb
bbb
aaa
AAAAA
```

The `diff` of both files would be:

```nohighlight
$ diff a.txt b.txt
0a1,2
> bb
> bbb
2,3c4
< aaaaa
< aa
---
> AAAAA
```

As you probably already know, this means:

- `0a1,2`: add at line 0 (at the beginning) of file `a.txt`, the lines 1 and 2 from file `b.txt`.

- `2,3c4`: substitute lines 2 and 3 of file `a.txt` with line number 4 of file `b.txt`.

The current version of `diff` is highly optimized, but, at its core, it
can be easily understood as some hashing (turning lines into _equivalent
characters_), and an LCS solver.  You will find more details about this in the
[slides from the talk](https://drive.google.com/file/d/0B05KyBUlYY2TV2N6X2x6ZWhBXzQ/view?usp=sharing).

## 4. Tracking Lines Across File Revisions

At the core of the `git blame` algorithm is the problem of tracking lines
across file revisions; knowing at which revision each particular line
was added or modified.

This problem is usually solved by creating a graph where:

- vertexes represent each line of a file, for all revisions of the file

- edges represent the same line across diferent revisions of the file

In the [slides from the talk](https://drive.google.com/file/d/0B05KyBUlYY2TV2N6X2x6ZWhBXzQ/view?usp=sharing) you can find examples of
forward and backward versions of a graph traversal algorithm to solve the
blaming problem, from the 2006 paper [Mining Version Archives for Co-changed
Lines](https://users.soe.ucsc.edu/~ejw/papers/MSR26s-zimmermann.pdf)
(Zimmermann et al.).

*We would like to thank [ShuttleCloud](https://www.shuttlecloud.com/) for
hosting and organizing the event (and for the beers!).
