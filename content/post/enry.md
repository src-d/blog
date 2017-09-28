---
author: mcarmonaa
date: 2017-09-28
draft: false
title: "enry: detecting languages"
image: "/post/enry/henry.png"
description: "Announcing enry, a faster implementation of github/linguist in Go for programming language detection"
categories: ["technical"]
---

## enry (⊙.☉)?

If you don't know yet what enry is, despite the name being so descriptive, it's probably because you aren't the kind of person keen on films. Don't worry about it and keep reading.

*[enry](https://github.com/src-d/enry)* is a tool written in Go to perform programming language detection in files. It started as a port of *[github's project linguist](https://github.com/github/linguist)*.

For example, given the file `hello.m`:

```Objective-C
#import <Foundation/Foundation.h>

int main (int argc, const char * argv[]) {
        NSLog (@"Hello, World!");
        return 0;
}

```

*enry* will return "Objective-C" rather than "Matlab":

```bash
$ enry hello.m
hello.m: 7 lines (5 sloc)
  type:      Text
  mime_type: text/x-objectivec
  language:  Objective-C

```

*enry* enables you to find out what language a file was written in, whether that file is used as documentation for a project, if it is a vendor file or even if it is binary.

## Why develop a port?

Some time ago, source{d} needed to detect the language of every file in every repository to perform analysis job in our previous pipeline. We looked at [github's linguist project](https://github.com/github/linguist) to handle that task. It is a Ruby library that offered what we needed, but didn't address all our requirements though.

We realised at that point that it was worth to implement an approach which integrated with the Go development environment, performed sufficiently fast and at the same time was compatible with the mother project. This is how *enry* was born.

*enry* had only a sub-set of the *linguist* functionality in the beginning. It was enough to cover basic needs of the analysis pipeline that we had back then.

As time passed, *enry* showed it was a  valuable tool that could be used in other projects (e.g. [babelfish](https://github.com/bblfsh)) and it incorporated almost all the features *linguist* has.

## How does enry work?

The following two functions classify the language of a file:

```go
func GetLanguage(filename string, content []byte) (language string)
func GetLanguages(filename string, content []byte) []string
```

There could be more than one possible language detected for the file after calling `GetLanguages`, so it returns all of them. `GetLanguage` returns only one of them which is the most probable. The ranking is described below.

The detection process is split into several steps that form a chain or sequence of strategies. These strategies need the file name, its contents and the list of candidates (the list of possible languages for the file). Strategies are typed functions with the special signature:

```go
type Strategy func(filename string, content []byte, candidates []string) (languages []string)
```

Strategies try to guess the language of a file based on these arguments and a specific characteristic. For example, the default strategies enry uses are:

```go
var DefaultStrategies = []Strategy{
    GetLanguagesByModeline,
    GetLanguagesByFilename,
    GetLanguagesByShebang,
    GetLanguagesByExtension,
    GetLanguagesByContent,
    GetLanguagesByClassifier,
}
```

You can see how the strategies look for `Modeline`, `Filename`, `Shebang`... characteristics of a file that can be representative of the language. Some strategies need to parse the content and perhaps apply heuristics while others do their job only with the filename.

The strategy chain works as follows:

* A strategy tries to get the language from a file.
* It can result in zero or more languages detected.
* If there's no language, call the next strategy.
* If there is more than one language, they are appended to the list of candidates and they are passed to the next strategy.
* If there is exactly one language, it is returned as the detected language and the process stops.

 When the detection process falls through all the strategies and the outcome is ambiguous, it makes the last step: `GetLanguagesByClassifier`. This strategy deserves having a look.

`GetLanguagesByClassifier` internally uses the object of type:

```go
type Classifier interface {
    Classify(content []byte, candidates map[string]float64) (languages []string)
}
```

This interface allows you to implement your own classifier and use it in the following functions:

```go
func GetLanguageBySpecificClassifier(content []byte, candidates []string, classifier Classifier) (language string, safe bool)
func GetLanguagesBySpecificClassifier(content []byte, candidates []string, classifier Classifier) (languages []string)
```

*enry*'s default classifier implementation is a [bayesian classifier](https://en.wikipedia.org/wiki/Bayes_classifier) which matches *linguist's*. It assigns scores to the candidates regarding their probabilities (scanning the keywords and calculating the cumulative frequencies), with the highest score assigned to the most likely candidate.

By the way, strategies have the `GetLanguage-` version too that returns only the language and the boolean to indicate the confidence in the result. The returned boolean value is set either to true, if there is only one possible language detected or to false otherwise.

You can use these functions independently for whatever you want.

If you want to customise *enry*'s default strategies and classifier to use your own strategies and classifiers, you can do so by assigning them to the following variables:

```go
enry.DefaultStrategies = myStrategies
enry.DefaultClassifier = myClassifier
```

From that point on, `GetLanguage` and `GetLanguages` will use your custom implementation.

## How does enry know all about a lot of languages?

*enry* uses the information about languages (filenames, interpreters, extensions... associated with each language) that *linguist* keeps in the code base.

Specifically, *enry* uses the following files from *linguist*:

* [languages.yml](https://github.com/github/linguist/blob/master/lib/linguist/languages.yml)
* [heuristics.rb](https://github.com/github/linguist/blob/master/lib/linguist/heuristics.rb)
* [vendor.yml](https://github.com/github/linguist/blob/master/lib/linguist/vendor.yml)
* [documentation.yml](https://github.com/github/linguist/blob/master/lib/linguist/documentation.yml)

These files are parsed to retrieve the necessary information. Then the source files in *enry* that offer this information to the rest of the project are generated and encapsulated as the [internal subpackage data](https://github.com/src-d/enry/tree/master/data).

The whole process is automated and you only need to run `go generate` from the project's root directory to launch it. It allows *enry* to get updated without complex modifications when *linguist* adds new information.

## Does enry actually have better performance?

*enry*'s language detection has been compared with *linguist*.  In order to do that, [linguist's project directory linguist/samples](https://github.com/github/linguist/tree/master/samples) was used as the set of files to run benchmarks against.

The number of language detections for each file in samples directory and per each time interval in the logarithmic scale has been measured for both tools, yielding the following results:

```
enry processed files: 1839
     1us-10us 5.220228%
     10us-100us 67.645459%
     100us-1ms 17.455139%
     1ms-10ms 7.340946%
     10ms-100ms 2.338227%

linguist processed files: 1839
     1us-10us 0.000000%
     10us-100us 4.023926%
     100us-1ms 50.027189%
     1ms-10ms 42.849375%
     10ms-100ms 3.099511%
```

![histogram](/post/enry/distribution.png)

As you can see, *enry* was able to detect 72% of files in a time between 1us and 100us, while the majority of the files *linguist* processed are shifted to greater time intervals.

Calculating the mean spent time to process a file with both tools, on average *enry* is 211% faster than *linguist*.

Considering that *enry* follows the same algorithms that *linguist* does, it looks like the performance improvement is provided by the chosen language to develop them.

However, it should be noted that in a few cases *enry* could turn slower than linguist. This is due to Golang's regexp being slower than Ruby's, which uses [oniguruma](https://github.com/kkos/oniguruma) library, written in C.

Profiling `GetLanguage` function against all the files in [linguist/samples](https://github.com/github/linguist/tree/master/samples) you can see how most of the time is spent by `regexp`:

```bash
$ go tool pprof -top cpu.out
201.21s of 212.68s total (94.61%)
Dropped 202 nodes (cum <= 1.06s)
      flat  flat%   sum%        cum   cum%
    60.88s 28.63% 28.63%     66.07s 31.07%  regexp.(*machine).add
    26.82s 12.61% 41.24%     55.12s 25.92%  regexp.(*machine).tryBacktrack
    23.18s 10.90% 52.13%     38.56s 18.13%  regexp.(*machine).step
    15.93s  7.49% 59.62%    122.55s 57.62%  regexp.(*machine).match
    10.38s  4.88% 64.51%     10.38s  4.88%  regexp.(*bitState).push
     9.59s  4.51% 69.01%      9.59s  4.51%  regexp/syntax.EmptyOpContext
     8.93s  4.20% 73.21%      9.75s  4.58%  regexp/syntax.(*Inst).MatchRunePos
     7.81s  3.67% 76.89%      7.81s  3.67%  runtime.memclrNoHeapPointers
     7.51s  3.53% 80.42%      7.57s  3.56%  regexp.(*inputBytes).step
     6.28s  2.95% 83.37%      6.28s  2.95%  runtime.memmove
     3.87s  1.82% 85.19%     68.40s 32.16%  regexp.(*machine).backtrack
     3.78s  1.78% 86.97%      3.78s  1.78%  runtime.duffcopy
     2.53s  1.19% 88.16%     12.28s  5.77%  regexp/syntax.(*Inst).MatchRune
...
```

## enry CLI

*enry* can be used as a command too

```bash
$ enry --help
enry, A simple (and faster) implementation of github/linguist
usage: enry <path>
              enry <path> [--json] [--breakdown]
              enry [--json] [--breakdown]
```

, and it's programmed to return the output similar to *linguist*'s output.

```bash
$ enry
11.11%    Gnuplot
22.22%    Ruby
55.56%    Shell
11.11%    Go
```

The command has flags to get the results broken down by file,

```bash
$ enry --breakdown
11.11%    Gnuplot
22.22%    Ruby
55.56%    Shell
11.11%    Go

Gnuplot
plot-histogram.gp

Ruby
linguist-samples.rb
linguist-total.rb

Shell
parse.sh
plot-histogram.sh
run-benchmark.sh
run-slow-benchmark.sh
run.sh

Go
parser/main.go
```

and to show it in JSON format,

```bash
$ enry --json
{"Gnuplot":["plot-histogram.gp"],"Go":["parser/main.go"],"Ruby":["linguist-samples.rb","linguist-total.rb"],"Shell":["parse.sh","plot-histogram.sh","run-benchmark.sh","run-slow-benchmark.sh","run.sh"]}
```

The main difference with linguist's command is that *enry* doesn't need a git repository in the current working directory to analyse the files!

## enry Java

[Java bindings](https://github.com/src-d/enry/tree/master/java) are provided too, so you can also use it from Java code!

## What I really want to know is where "enry" comes from!

In the movie [My Fair Lady](https://en.wikipedia.org/wiki/My_Fair_Lady), [Professor Henry Higgins](http://www.imdb.com/character/ch0011719/?ref_=tt_cl_t2) is one of the main characters in the movie. Henry is a linguist and enjoys guessing the neighborhood where people live based on their accent in the very beginning of the movie.

`Enry Iggins` is how [Eliza Doolittle](http://www.imdb.com/character/ch0011720/?ref_=tt_cl_t1), [pronounces the name of the Professor during the first half of the movie](https://www.youtube.com/watch?v=pwNKyTktDIE).
