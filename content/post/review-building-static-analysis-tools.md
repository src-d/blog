---
author: alex
date: 2018-07-26
title: "Paper review: “Lessons from Building Static Analysis Tools at Google”."
image: /post/review-building-static-analysis-tools/lessons.png
description: "Review of a recent scientific paper by Google on experience of building large-scale static analysis tools."
categories: ["science", "technical"]
draft: true
---

A recent paper with empirical research on application of static code analysis tool caught my attention:

{{% tweet 988527557300568065 %}}

It’s been a while since I started reading more papers, following awesome initiatives like [Papers We Love](https://paperswelove.org/)
and [The Morning Paper](https://blog.acolyer.org/) — I always wanted to experiment with publishing notes.
This will be the first attempt.

{{% center %}} … {{% /center %}}

[“Lessons from Building Static Analysis Tools at Google](https://cacm.acm.org/magazines/2018/4/226371-lessons-from-building-static-analysis-tools-at-google/fulltext)”
by Caitlin Sadowski, Edward Aftandilian, [Alex Eagle](undefined), Liam Miller-Cushon, Ciera Jaspan
presents 2 stories: history of failed attempts of integrating  [FindBugs](https://github.com/findbugsproject/findbugs),
a static analysis tool for Java at [Google](http://twitter.com/Google), and lessons learned from the success
story of incorporating extensible analysis framework, [Tricorder](https://research.google.com/pubs/pub43322.html),
to development workflow at Google.

## Source code analysis recap

Before digging deeper into the paper, a bit of the context on what kind of analysis in general is applicable
to programs. There are two main types of program analysis:

* *Static code analysis*, collects all information only from the source code, without running a program
* *Dynamic code analysis*, is based on exectuion of (potentially customized) program over time

This paper talks only about *static code analysis*, which is traditionally further subdivided into two main
flavors:

* *intra-procedural,* when analysis is localized inside a small part of the program like a function/class/file
* *inter-procedural,* that uses broader, whole-program artefacts as input, and conducts more sophisticated
  analysis (call graph, formal logic, context-sensitive analysis, etc)

According to the paper, Google only runs simpler, *intra-procedural* type of analysis — the only one feasible
to run at scale of 2 billion lines of code.

Interesting enough, this is somehow different from the approach taken by Facebook’s project
[Infer](http://fbinfer.com/), which developed a way to scale the particular type of
[more complex](https://code.facebook.com/posts/1537144479682247/finding-inter-procedural-bugs-at-scale-with-infer-static-analyzer/),
*inter-procedural* [separation logic-based](https://en.wikipedia.org/wiki/Separation_logic) compositional
analysis, that paper authors are well aware of.

The reasons why Google is not interested in more complex analysis at this point are explicitly listed in
the paper:

* *Large investment.* Although theoretically better and more complex analysis exists, it will require
  non-trivial engineering effort to scale

* *High upfront cost.* It’s very hard to get the data, even to just estimate the cost-benefit ratio for
  such improvements, to justify research/implementation efforts

* *Work still would be needed to reduce false-positive rates*

* *Finding bugs is easy.* When a codebase is large enough, it will contain practically any imaginable
  code pattern. Many more low-hanging fruits exist using simpler approaches

I find it to be particularly curious, as none of these conditions are set in stone:

* data is hard to get without decrease in productivity of engineers inside the company, due to the way
  false-positives are measured (more on it in the next section)

* what seems not feasible now, may become feasible later with more computation power and e.g.
  in cases when some analyses can be cast as some kind of optimization problems

* and many other projects and companies could benefit from more advanced analysis, where it actually
  is feasible conduct it due to codebases of smaller sizes

Main critique of the practical usefulness of any automated analysis approach is based on the existence
of *false positive results*: issues reported as a defects, that either could not happen or are not
relevant to the recipients of analysis.

Traditionally, in software industry two main types of “analyzers” could be vaguely distinguished and
have proven to be useful:

 * *Style checkers* or [Linters](https://en.wikipedia.org/wiki/Lint_(software))
   (e.g. [CheckStyle](https://github.com/checkstyle/checkstyle), [Pylint](https://www.pylint.org/),
   [Golint](https://github.com/golang/lint), ets)
 * *Bug-finding tools*, that may extend a compiler ([FindBugs](https://github.com/findbugsproject/findbugs),
   [Error-Prone](http://errorprone.info/), [Clang-Tidy](http://clang.llvm.org/extra/clang-tidy),
   [ClangThreadSafety Analysis](https://clang.llvm.org/docs/ThreadSafetyAnalysis.html),
   [Govet](https://golang.org/cmd/vet/), [CheckerFramework](https://checkerframework.org), etc)

Different integration points in the software development process of an organization exist for this kind
of tools where the results can be presented to the developers. They are discussed in the paper in the
chronological order of the BugBot team’s attempts to integrate an existing OSS static analysis tool for
Java — [FindBugs](https://github.com/findbugsproject/findbugs) into the Google’s developer workflow.

## History of integrating FindBugs at Google

### 0. IDE/Editor

Using an editor as a place to show results of analysis was discarded from scratch.

Cons:

* many different editors/IDEs to support, as it’s before the build time

* wrong time — distracting developer who may not be open to the feedback

Interestingly enough, [source{d}](http://sourced.tech/) experimented with this approach as well using some
neural-network-based models [https://github.com/src-d/code-completion](https://github.com/src-d/code-completion)
a while ago and came to the very same conclusions.

Personally, I believe there is a huge room for improvement of code reading/writing experience though,
enhancing or better augmenting developer’s abilities to both [navigate](http://kythe.io/),
[understand](http://moosetechnology.org/) and [create](http://witheve.com/) programs. But indeed, existing
static analysis tools which target defect detection are hardly the right tools for any of these jobs.

### 1. 2006 Bug Dashboard

Then next attempt included serving aggregated analysis results though a separate web dashboard.

Cons:

* outside the developers’ usual workflow

* distinguishing between new and existing static-analysis issues was distracting

This resonates with my personal experience — in 2007 I was a Build Engineer on a big Java project at my first
place of job at a consultancy outlet. The project was large enough and inluded hunderds of engineers of very
different seniority levels writing a lot of code in a new domain. In a desperate attempt to increase the quality
and maintainability of the resulting codebase an internal **“Personalized Quality Dashboard”** service was built.

It consisted of a bunch of static HTML files (that later became a database for a web application) produced as
a part of the nightly build using Maven, wich were then copied and served from a well known URL inside the
company. HTMLs would contain tables of potential software defects, obtained by running multiple existing static
analysis tools — [FindBugs](https://github.com/findbugsproject/findbugs), [PMD](https://pmd.github.io/) and
[CheckStyle](https://github.com/checkstyle/checkstyle). Each defect was attributed to the latest change in the
codebase using “git blame” and “assigned” to a particular engineer who introduced the change.

Adoption of this internal dashboard service, although driven top-down by the management decision, was *very low*
wich is aligned with the paper — needless to say that not many engineers were motivated enough to go to the
separate [http://code-quality.company.com](http://code-quality.company.com) every day only to find that they
are ranked Nth by the amount of potential deffects introduced to the codebase.

Curiously enough, one can see some open source projects like Git going though the similar stage right now e.g.
[https://larsxschneider.github.io/git-scan](https://larsxschneider.github.io/git-scan/) with contributors
introducing language-specific analysis tools to the build profiles and publishing a dashboards with the results.

Despite the challenges in adopting such solutions one can also see companies e.g.
[https://scan.coverity.com](https://scan.coverity.com) — a closed-sourced static analysis
solution for Java, C/C++, C#, JavaScript, Ruby and Python [founded in 2006](https://scan.coverity.com/about)
jointly with U.S. Department of Homeland Security, being gradually adopted by some OSS projects.

Companies building rule-based analysis platforms like [https://lgtm.com](https://lgtm.com) - an offspring of
University of Oxford-based [https://semmle.com](https://semmle.com/) founded in 2007, are following this
adoption path. Their success, in my opinion, can be attributed to the fact that both support “hard” native
languages like [C++](https://lgtm.com/blog/how_lgtm_builds_cplusplus).

### 2. 2009 Filing bugs/Fixit

Next attempt of integration static analysis tools for Java wich is documented in the paper was filing the
results of analysis as bugs in the project bug-tracking system. Then a company-wide dedicated effort was made
in a format of a “Fixit” week, so that all engineers would have time to clean up those issues.

This approach has some advantages:

* it is valid scientific approach as it allows to quantify the results very well: how many of reported
issues were actually fixed by developers

* other researchers use similar approach i.e in early “[Learning Natural Coding Conventions](https://arxiv.org/abs/1402.4182)”
paper by [Miltos Allamanis](undefined) and [https://ml4code.github.io](https://ml4code.github.io/) group

> We demonstrate that coding conventions are important to software teams, by showing that
> 1) empirically, programmers enforce conventions heavily through code review feedback and corrective commits, and
> 2) **patches that were based on NATURALIZE suggestions have been incorporated** into 5 of the most popular
> open source Java projects on GitHub — of the 18 patches that we submitted, 14 were accepted

However for an organization it has a huge disadvantage — it’s laborious and hard to scale. If conducted without
a proper care, results will not only be ignored by developers but can also contribute to an overall
issue-tracker value depreciation of the project.

Despite that, one can see this approach been used by companies in this field i.e
[American Software Safety Reliability Company](http://www.assrc.us), Atlanta-based enterprise that seems to
have deep roots in software verifications and is somehow [supported by DARPA](http://www.qbitlogic.com/darpa-bigcode/),
to achieve the same — test some of their products like [https://www.mycode.ai](https://www.mycode.ai/) solution,
that is planned to deploy across all of the U.S. Department of Defense software development divisions, i.e on
[Git, popular OSS project](https://public-inbox.org/git/CAGm8dMApDdLEzeKU-h16G0NSpnuk9LMTWA29t4MxO1qcNpUvhA@mail.gmail.com/).

### 3. 2011 Code review integration

Here the intuition was that at the code review stage developers are preparing their code to be seen, so they
are more receptive to suggestions and readability and stylistic comments.

This is aligned with the direction that few people at [source{d}](https://medium.com/@sourcedtech) are
[exploring now](https://github.com/campoy/goodgopher/blob/d15a7eccc3bcb2484234732e538fc425d728e972/README.md).
There is also some number of existing solutions in the same field:

* [https://codeclimate.com](https://codeclimate.com/)
* [https://www.codacy.com](https://www.codacy.com/)
* [https://sideci.com](https://sideci.com/)
* [https://houndci.com](https://houndci.com/)
* [https://github.com/haya14busa/reviewdog](https://github.com/haya14busa/reviewdog)

Authors were focused on just presenting the FindBugs results at the internal code review tool as “comments”,
but this attempt did not take off either. Their integration included a few notable features:

* an individual developer could suppress false positives and filter the comments by confidence levels
* it was meant to show only new FindBugs warnings, but sometimes those issues were miscategorized as new

Although code review still seems to be the best time for surfacing analysis results, this attempt failure was
attributed to:

* presence of false positives in FindBugs results made developers lose confidence in the tool as a whole
* customization of the results view per-developer led to an inconsistent view of the analysis outcome

## What worked & lessons learned

As opposed to integrating each particular analysis tool in a different way, an internal “platform” — easily
extensible and with support for many different kinds of program-analysis tools, including static and dynamic
analyses was built, known as a [Tricorder project](https://research.google.com/pubs/pub43322.html).

As it was taking into account all the lessons learned from the history above, it managed to re-gain trust of
the users and proved to be a success inside Google.

Paper contains a number of general lessons like *Developer happiness is key* and *Crowdsource analysis development*
that are nice, but I would rather highlight a few key takeaways instead, that seem to drive the rest of
the technical decisions, responsible for success of a new analysis platform.

There are two main takeaways that drove the overall tooling design:

### 1. Best way to **measure a success of analysis**
> by number of bugs fixed (or prevented), not the number of issues identified

This way of measuring a success have several notable implications:

* If the tool that finds a bug also suggests a fix - it will be much more successful by this metric.
  This by necessity constraints the scope of a possible analysis and a tooling required

* It also means that repairing programs is important. For the discussion on tooling available for code
  transformations see **Technical Details** section below.

Learning such modifications from examples, instead of manual coding by engineers is also a bleeding edge
research topic [https://github.com/KTH/learning4repair](https://github.com/KTH/learning4repair).

### 2. Best way to **present the results of analysis**
> Developers were more likely to fix bugs if presented with analysis results early and as part of their normal workflow

This immediately implies that **reporting issues sooner is better.**

It also leads to the conclusion that the best bet is to integrate checks either ***directly into compilers*** -
familiar tools on whose feedback as errors and warnings developers are already relaying day to day. Or, if
that is not possible, _**code review** is a good time_ for new changes — before they are committed to the
version control system.

Criteria that must hold for ***compile time*** checks:

* 0 false positives

* easy to understand, actionable and easy to fix

* report issues affecting only correctness, rather than style or best practices

Criteria that must hold for ***code review time*** checks:

* <10% false positives

* be understandable, actionable and easy to fix

* have the potential for significant impact on code quality

Last but not least, enabling any new *compile time* check can suddenly brake a developer working on existing
code, which is clearly unacceptable. In order to avoid that, first **a tooling for large-scale code modifications**
must be run over whole codebase, before moving those checks to compile time for the rest of the company.

And those are ClangMR and JavacFlume — projects that are only briefly mentioned in this insightful paper.

*That is it, thank you for reading. We will post more on papers in this field soon.*

{{% center %}} … {{% /center %}}

Now I will take a liberty and cover a few technical details that were not in the scope of the original paper,
but are very related in order to help us see a bigger picture. Those were described in other places by other
employees of the same company.

## Technical details

Based on the internal success-story of C++ with [ClangMR tool](https://research.google.com/pubs/pub41342.html)
for matching/traversing/transforming Abstract Syntax Tree (AST) at scale, a similar tooling was built for Java.

{{% youtube ZpvvmvITOrk %}}

Project [Error-Prone](https://github.com/google/error-prone) is a compiler extension that is able to perform
arbitrary analysis on the *fully typed AST*. One thing to notice is that one can not get such input by using
only a parser even as advanced as [https://doc.bblf.sh](https://doc.bblf.sh/). Running a full build would be
required in order to do things like symbol resolution. In the end, after running a number of checker plugins
Error-Prone outputs a simple text replacements with suggested code fixes.

The project is open source and is well documented in a [number](https://research.google.com/pubs/pub38275.html)
of [papers](https://research.google.com/pubs/pub41876.html). Another closed source tool was built to scale
application of those fixes to the whole codebase, called JavacFlume — which I would guess looks something like
an Apache Spark job that applies patches in some generic format.

Here is an example for how a full pipeline looks for C++

{{% grid %}}
{{% caption src="https://cdn-images-1.medium.com/max/4224/1*KpJ5fj4njR1HTDfzhLCQkg.png" title="ClangMR processing pipeline ilustration"%}}
“Large-Scale Automated Refactoring Using ClangMR” by
[Hyrum Wright](https://research.google.com/pubs/HyrumWright.html), Daniel Jasper, Manuel Klimek, [Chandler Carruth](https://research.google.com/pubs/ChandlerCarruth.html), Zhanyong Wan
{{% /caption %}}
{{% /grid %}}

Although it is not disclosed, an attentive reader might have noticed that **Compilation Index** part of the
pipeline is very similar to a [Compilation Database](https://kythe.io/docs/kythe-compilation-database.html)
in the open source Kythe project.

It might be interesting to take a closer look at the example of an API for AST query and transformation for C++.

### C++ Example
> *rename all calls to Foo::Bar with 1 argument to Foo::Baz, independent of the name of the instance variable,
> or whether it is called directly or by pointer or reference*

{{% grid %}}
{{% grid-cell %}}
![API example: invoke a callback function on call to Foo:Bar](https://cdn-images-1.medium.com/max/2000/1*vOYemTlJ2QZyzXvizSy5Og.png)
{{% /grid-cell %}}
{{% grid-cell %}}
This fragment will invoke a callback function on any occurrence of the call to *Foo:Bar* with single argument.
{{% /grid-cell %}}
{{% /grid %}}

{{% grid %}}
{{% grid-cell %}}
![API example: replace matching text of the function name with the "Baz"](https://cdn-images-1.medium.com/max/2116/1*JiUgO-gimsIi2JpRB9LYeg.png)
{{% /grid-cell %}}
{{% grid-cell %}}
This callback will generate a code transformation: for the matched nodes it will replace the matching text of
the function name with the “Baz”.

Regarding code transformations in Java, **Error-Prone** has a similar low-level [patching API](http://errorprone.info/docs/patching)
that is very close to native AST manipulation API. It was found to have a step learning curve similar to the
Clang, and thus pose a high entry barrier — even an experience engineer would need few weeks before one can be
productive creating fix suggestions or refactorings.
{{% /grid-cell %}}
{{% /grid %}}

That is why a higher level API was built for Java: first as the separate [Refaster](https://research.google.com/pubs/pub41876.html)
project and then [integrated in Error-Prone](http://errorprone.info/docs/refaster) later.

So a usual workflow would look like — after running all the checks and emitting a collection of suggested
fixes, shard diffs to smaller patches, run all the tests over the changes and if they have passed, submit
patches for code review.

{{% center %}} … {{% /center %}}

{{% center %}}
##### Thank you for reading, stay tuned and keep you codebase healthy!
{{% /center %}}
