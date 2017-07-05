---
author: mcarmonaa
date: 2017-07-03
draft: true
title: "enry: detecting your accent"
image: ""
description: "Announcing enry, a faster implementation in Go of github/linguist"
categories: ["technical", "Go"]
---

<style>
p.dt {
  margin-top: -16px;
  font-style: italic;
}
</style>

## enry (⊙.☉)?
If you don't know yet what is *enry* looking at the so descriptive name of "enry", maybe it's because you aren't the kind of person keen on films. Don't worry about it and keep reading.

*[enry](https://github.com/src-d/enry)* is a tool written in Go to perform file language detection. It started as a port of github's project *[linguist](https://github.com/github/linguist)*.

With all the tools that *enry*  provides,  you can know what is the language a file was written, whether this file is used as documentation for a project, is a vendor file or even if it is a binary file.

## Why develop a port?
Some time ago at source{d}, we needed to detect language for every file in every repository to perform analysing job in our previous pipeline. To face this task, we looked at [github's linguist project](https://github.com/github/linguist), a Ruby library that offered what we needed, but not addressed all our requirements thought.

So it raised the need to implement an approach to fit in an environment mostly developed in Go, give a good performance and keep compatibility with its mother project. That's the reason why *enry* was born.

At the beginning, *enry* had only a sub-set of the *linguist* functionality, enough to cover basic needs of the analysis pipeline that we had back then.

As the time passed, *enry* showed it was a  valuable tool that could be used in other projects (e.g.[babelfish](https://github.com/bblfsh)) and it started to incorporate almost all the features *linguist* has.

## How does enry work?
The goal of detecting language from a file is achieved by the functions:
```
func GetLanguage(filename string, content []byte) (language string)
func GetLanguages(filename string, content []byte) []string
```
After calling `GetLanguages`, there could be more than one possible language detected for the file, so `GetLanguages` returns all of them, and `GetLanguage` returns one of them (in fact, the most likely one thanks to the classifier, we'll cover the classifier later).

The detection process must be split into several steps that form a chain or sequence of strategies. These strategies need the file name, content and a list of candidates (a list of possible languages for the file). Strategies are typed functions with the next signature:
```
type Strategy func(filename string, content []byte, candidates []string) (languages []string)
```

Strategies try to guess the language of the file based on these arguments and a specific characteristic. For example, the default strategies enry uses are:
```
var DefaultStrategies = []Strategy{
    GetLanguagesByModeline,
    GetLanguagesByFilename,
    GetLanguagesByShebang,
    GetLanguagesByExtension,
    GetLanguagesByContent,
    GetLanguagesByClassifier,
}
```
You can see how the strategies look for Modeline, Filename, Shebang... characteristics of a file that can be representative of the language it uses. Some strategies need to parse the content and perhaps apply heuristics while others, however,  do their job only with the filename.

The way the strategy chain works is as follows:
* A strategy tries to get the language from a file.
* It can result in zero or more languages detected.
* If there's no language, call the next strategy.
* If there are more than one languages, they are appended to a list of candidates and they are given to the next strategy.
* If there is exactly one language, it is returned as the detected language and the process stops.

 When the detection process falls through all the strategies without getting only one language as an outcome, it reaches the last step: `GetLanguagesByClassifier`. This strategy deserves taking a look at it.

`GetLanguagesByClassifier` internally uses an object of the type:
```
type Classifier interface {
    Classify(content []byte, candidates map[string]float64) (languages []string)
}
```

This interface allows you to implement your own classifier and use it in the following functions:
```
func GetLanguageBySpecificClassifier(content []byte, candidates []string, classifier Classifier) (language string, safe bool)
func GetLanguagesBySpecificClassifier(content []byte, candidates []string, classifier Classifier) (languages []string)
```

*enry*'s default classifier implementation is a [bayesian classifier](https://en.wikipedia.org/wiki/Bayes_classifier) which is like the one *linguist* uses. It assigns scores to the candidates regarding its probability, with the highest score assigned to the most likely candidate.

By the way, strategies have a `GetLanguage-` version too that returns only a language, and boolean to indicate the sureness of this result. You can use this functions independently for whatever you want.

If you want to customise *enry*'s default strategies and classifier to use your own strategies and classifiers, you can do so by assigning them to the following variables:
```
enry.DefaultStrategies = myStrategies
enry.DefaultClassifier = myClassifier
```
From this point on, `GetLanguage` and `GetLanguages` will use your custom implementation.

## How does enry know all about a lot of languages?
*enry* uses the information about languages (filenames, interpreters, extensions... associated with each language) that *linguist* keeps on its project.

Specifically, *enry* uses the following files from *linguist*:
* [languages.yml](https://github.com/github/linguist/blob/master/lib/linguist/languages.yml)
* [heuristics.rb](https://github.com/github/linguist/blob/master/lib/linguist/heuristics.rb)
* [vendor.yml](https://github.com/github/linguist/blob/master/lib/linguist/vendor.yml)
* [documentation.yml](https://github.com/github/linguist/blob/master/lib/linguist/documentation.yml)

These files are parsed to retrieve the necessary information. Then the source files in *enry*  that offer this information to the rest of the project are generated and encapsulated as an internal subpackage [data](https://github.com/src-d/enry/tree/master/data).

The whole process is automated and you only need to run `go generate` from the project's root directory to launch it. It allows *enry* to get updated without complex modifications when *linguist* adds new information.

## Does enry actually have better performance?
*enry*'s language detection has been compared with *linguist*.  In order to do that, linguist's project directory [linguist/samples](https://github.com/github/linguist/tree/master/samples) was used as a set of files to run benchmarks against.

The number of language detections for each file in samples directory and per each time interval in a logarithmic scale has been measured for both tools, getting the following results:
```
enry processed files: 1839
     1us-10us 5.220228%
     10us-100us 67.645459%
     100us-1ms 17.455139%
     1ms-10ms 7.340946%
     10ms-100ms 2.338227%

linguist processed files: 1839
     1us-10us 0.000000%
     10us-100us 4.023926%r

     100us-1ms 50.027189%
     1ms-10ms 42.849375%
     10ms-100ms 3.099511%
```
As you can see, *enry* was able to detect 67% of files in a time between 1us and 10us, while the majority of the files *linguist* processed are shifted to greater time intervals.

Calculating the mean spent time to process a file for both tools, on average *enry* is 211% faster than *linguist*.

## enry CLI
*enry* can be used as a command too
```
$ enry --help
enry, A simple (and faster) implementation of github/linguist
usage: enry <path>
       enry [-json] [-breakdown] <path>
       enry [-json] [-breakdown]
```
, and it's programmed to return a similar output to *linguist*'s output.
```
$ enry
11.11%    Gnuplot
22.22%    Ruby
55.56%    Shell
11.11%    Go
```
The command has flags to get the results broken down by file,
```
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
```
$ enry --json
{"Gnuplot":["plot-histogram.gp"],"Go":["parser/main.go"],"Ruby":["linguist-samples.rb","linguist-total.rb"],"Shell":["parse.sh","plot-histogram.sh","run-benchmark.sh","run-slow-benchmark.sh","run.sh"]}
```

The main difference with linguist's command is that enry doesn't need a git repository in the directory to analyse!

## Wait a moment! What I really want to know is why "enry"?
In the movie [My Fair Lady](https://en.wikipedia.org/wiki/My_Fair_Lady), [Professor Henry Higgins](http://www.imdb.com/character/ch0011719/?ref_=tt_cl_t2) is one of the main characters. Henry is a linguist and at the very beginning of the movie enjoys guessing the nationality of people based on their accent.

`Enry Iggins` is how [Eliza Doolittle](http://www.imdb.com/character/ch0011720/?ref_=tt_cl_t1), [pronounces](https://www.youtube.com/watch?v=pwNKyTktDIE) the name of the Professor during the first half of the movie.
