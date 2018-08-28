---
author: alex
date: 2018-07-26
title: "Paper review: “Lessons from Building Static Analysis Tools at Google”."
image: /post/review-building-static-analysis-tools/lessons.png
description: "Review of a recent scientific paper by Google on the experience of building large-scale static analysis tools."
categories: ["science", "technical"]
draft: true
---

A recent paper with empirical research on the application of static code analysis tools caught my attention:

{{% tweet 988527557300568065 %}}

It’s been a while since I started reading more papers, following awesome initiatives like [Papers We Love](https://paperswelove.org/)
and [The Morning Paper](https://blog.acolyer.org/) — I always wanted to experiment with publishing notes.
This will be the first attempt.

{{% center %}} … {{% /center %}}

[“Lessons from Building Static Analysis Tools at Google](https://cacm.acm.org/magazines/2018/4/226371-lessons-from-building-static-analysis-tools-at-google/fulltext)”
by Caitlin Sadowski, Edward Aftandilian, [Alex Eagle](https://twitter.com/jakeherringbone), Liam Miller-Cushon, Ciera Jaspan
presents 2 stories: the history of failed attempts at integrating  [FindBugs](https://github.com/findbugsproject/findbugs),
a static analysis tool for Java at [Google](http://twitter.com/Google), and lessons learned from the success
story of incorporating extensible analysis framework, [Tricorder](https://research.google.com/pubs/pub43322.html),
to development workflow at Google.

## Source code analysis recap

Before digging deeper into the paper, a bit of the context on what kind of analysis, in general, is applicable
to programs. There are two main types of program analysis:

* *static code analysis*, collects all information only from the source code, without running a program
* *dynamic code analysis*, is based on execution of (potentially customized) program over time

This paper talks only about *static code analysis*, which is traditionally further subdivided into two main
flavors:

* *intra-procedural,* when an analysis is localized inside a small part of the program like a function/class/file
* *inter-procedural,* that uses broader, whole-program artifacts as input, and conducts more sophisticated
  analysis (call graph, formal logic, context-sensitive analysis, etc)

According to the paper, Google only runs simpler, *intra-procedural* type of analysis — the only one feasible
to run at the scale of 2 billion lines of code.

Interestingly enough, this is somehow different from the approach taken by Facebook’s project
[Infer](http://fbinfer.com/), which developed a way to scale the particular type of
[more complex](https://code.facebook.com/posts/1537144479682247/finding-inter-procedural-bugs-at-scale-with-infer-static-analyzer/),
*inter-procedural* [separation logic-based](https://en.wikipedia.org/wiki/Separation_logic) compositional
analysis, that paper authors are well aware of.

The reasons why Google is not interested in more complex analysis at this point are explicitly listed in
the paper:

* *Large investment.* Although theoretically better and more complex analysis exists, it will require
  the non-trivial engineering effort to scale

* *High upfront cost.* It’s very hard to get the data, even to just estimate the cost-benefit ratio for
  such improvements, to justify research/implementation efforts

* *Work still would be needed to reduce false-positive rates*

* *Finding bugs is easy.* When a codebase is large enough, it will contain practically any imaginable
  code pattern. Many more low-hanging fruits exist using simpler approaches

I find it to be particularly curious, as none of these conditions are set in stone:

* data is hard to get without a decrease in productivity of engineers inside the company, due to the way
  false-positives are measured (more on it in the next section)

* what seems not feasible now, may become feasible later with more computation power and e.g.
  in cases when some analyses can be cast as some kind of optimization problems

* and many other projects and companies could benefit from a more advanced analysis, where it actually
  is feasible to conduct it due to codebases of smaller sizes

The main critique of the practical usefulness of any automated analysis approach is based on the existence
of *false positive results*: issues reported as defects, that either could not happen or are not
relevant to the recipients of analysis.

Traditionally, in the software industry two main types of “analyzers” could be vaguely distinguished and
have proven to be useful:

 * *style checkers* or [Linters](https://en.wikipedia.org/wiki/Lint_(software))
   (e.g. [CheckStyle](https://github.com/checkstyle/checkstyle), [Pylint](https://www.pylint.org/),
   [Golint](https://github.com/golang/lint), ets)
 * *bug-finding tools*, that may extend a compiler ([FindBugs](https://github.com/findbugsproject/findbugs),
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

* wrong time — distracting a developer who may not be open to the feedback

Interestingly enough, [source{d}](http://sourced.tech/) experimented with this approach as well using some
neural-network-based models [https://github.com/src-d/code-completion](https://github.com/src-d/code-completion)
a while ago and came to the very same conclusions.

Personally, I believe there is a huge room for improvement of code reading/writing experience though,
enhancing or better augmenting developers' abilities to both navigate ([kythe](http://kythe.io/)),
understand ([Moose](http://moosetechnology.org/)) and create ([Eve]](http://witheve.com/)) programs. But indeed, existing
static analysis tools which target defect detection are hardly the right tools for any of these jobs.

### 1. 2006 Bug Dashboard

Then next attempt included serving aggregated analysis results through a separate web dashboard.

Cons:

* outside the developers’ usual workflow

* distinguishing between new and existing static-analysis issues was distracting

This resonates with my personal experience — in 2007 I was a Build Engineer on a big Java project at my first
place of job at a consultancy outlet. The project was large enough and included hundreds of engineers of very
different seniority levels writing a lot of code in a new domain. In a desperate attempt to increase the quality
and maintainability of the resulting codebase an internal **“Personalized Quality Dashboard”** service was built.

It consisted of a bunch of static HTML files (that later became a database for a web application) produced as
a part of the nightly build using Maven, which were then copied and served from a well-known URL inside the
company. HTMLs would contain tables of potential software defects, obtained by running multiple existing static
analysis tools — [FindBugs](https://github.com/findbugsproject/findbugs), [PMD](https://pmd.github.io/) and
[CheckStyle](https://github.com/checkstyle/checkstyle). Each defect was attributed to the latest change in the
codebase using “git blame” and “assigned” to a particular engineer who introduced the change.

Adoption of this internal dashboard service, although driven top-down by the management decision, was *very low*
which is aligned with the paper — needless to say, that not many engineers were motivated enough to go to the
separate `(https://code-quality.company.com)` every day only to find that they
are ranked Nth by the number of potential defects introduced to the codebase.

Curiously enough, one can see some open source projects like Git going through the similar stage right now e.g.
[https://larsxschneider.github.io/git-scan](https://larsxschneider.github.io/git-scan/) with contributors
introducing language-specific analysis tools to the build profiles and publishing dashboards with the results.

Despite the challenges in adopting such solutions one can also see companies such as
[https://scan.coverity.com](https://scan.coverity.com) — a closed-sourced static analysis
solution for Java, C/C++, C#, JavaScript, Ruby and Python [founded in 2006](https://scan.coverity.com/about)
jointly with U.S. Department of Homeland Security, being gradually adopted by some OSS projects.

Companies building rule-based analysis platforms like [https://lgtm.com](https://lgtm.com) - an offspring of
University of Oxford-based [https://semmle.com](https://semmle.com/) founded in 2007, are following this
adoption path. Their success, in my opinion, can be attributed to the fact that both support “hard” native
languages like [C++](https://lgtm.com/blog/how_lgtm_builds_cplusplus).

### 2. 2009 Filing bugs/Fixit

The next attempt at integrating a static analysis tool for Java documented in the paper was filing
the results of the analysis as bugs in the project bug-tracking system. Then a company-wide dedicated effort was made
in a format of a “Fixit” week so that all engineers would have time to clean up those issues.

This approach has some advantages:

* it is valid scientific approach as it allows to quantify the results very well: how many of reported
issues were actually fixed by developers

* other researchers use similar approach i.e in early “[Learning Natural Coding Conventions](https://arxiv.org/abs/1402.4182)”
paper by [Miltos Allamanis](https://miltos.allamanis.com/) and [https://ml4code.github.io](https://ml4code.github.io/) group

> We demonstrate that coding conventions are important to software teams, by showing that
> 1) empirically, programmers enforce conventions heavily through code review feedback and corrective commits, and
> 2) **patches that were based on NATURALIZE suggestions have been incorporated** into 5 of the most popular
> open source Java projects on GitHub — of the 18 patches that we submitted, 14 were accepted

However for an organization, it has a huge disadvantage — it’s laborious and hard to scale. If conducted without
proper care, results will not only be ignored by developers but can also contribute to an overall
issue-tracker value depreciation of the project.

Despite that, one can see this approach being used by companies in this field e.g.
[American Software Safety Reliability Company](http://www.assrc.us), an Atlanta-based enterprise that seems to
have deep roots in software verifications and is [supported by DARPA](http://www.qbitlogic.com/darpa-bigcode/),
to achieve the same — test some of their products like [https://www.mycode.ai](https://www.mycode.ai/) solution,
that is planned to deploy across all of the U.S. Department of Defense software development divisions, i.e on
[Git, popular OSS project](https://public-inbox.org/git/CAGm8dMApDdLEzeKU-h16G0NSpnuk9LMTWA29t4MxO1qcNpUvhA@mail.gmail.com/).

### 3. 2011 Code review integration

Here the intuition was that at the code review stage developers are preparing their code to be seen, so they
are more receptive to suggestions and readability and stylistic comments.

This is aligned with the direction that a few people at [source{d}](https://medium.com/sourcedtech) are
[exploring now](https://github.com/campoy/goodgopher/blob/d15a7eccc3bcb2484234732e538fc425d728e972/README.md).
There is also a number of existing solutions in the same field:

* [https://codeclimate.com](https://codeclimate.com/)
* [https://www.codacy.com](https://www.codacy.com/)
* [https://sideci.com](https://sideci.com/)
* [https://houndci.com](https://houndci.com/)
* [https://github.com/haya14busa/reviewdog](https://github.com/haya14busa/reviewdog)

Authors were focused on just presenting the FindBugs results at the internal code review tool as “comments”,
but this attempt did not take off either. Their integration included a few notable features:

* an individual developer could suppress false positives and filter the comments by confidence levels
* it was meant to show only new FindBugs warnings, but sometimes those issues were miscategorized as new

Although code review still seems to be the best time for surfacing analysis results, this attempt's failure was
attributed to:

* the presence of false positives in FindBugs results, that made developers lose confidence in the tool as a whole
* the ability to customize of the results view per-developer, that led to an inconsistent view of the analysis outcome

## What worked & lessons learned

As opposed to integrating each particular analysis tool in a different way, an internal “platform” — easily
extensible and with support for many different kinds of program-analysis tools, including static and dynamic
analyses was built, known as the [Tricorder project](https://research.google.com/pubs/pub43322.html).

As it was taking into account all the lessons learned from the history above, it managed to regain the trust of
the users and proved to be a success inside Google.

The paper contains a number of general lessons like *Developer happiness is key* and *Crowdsource analysis development*
that are nice, but I would rather highlight a few key takeaways instead, that seem to drive the rest of
the technical decisions, responsible for the success of a new analysis platform.

There are two main takeaways that drove the overall tooling design:

### 1. Best way to **measure a success of analysis**
> by number of bugs fixed (or prevented), not the number of issues identified

This way of measuring a success has several notable implications:

* if the tool that finds a bug also suggests a fix - it will be much more successful by this metric.
  This by necessity constraints the scope of any possible analysis and the tooling required.

* it also means that repairing programs is important. For the discussion on tooling available for code
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

Last but not least, enabling any new *compile time* check can suddenly interrupt a developer working on existing
code, which is clearly unacceptable. In order to avoid that, first **a tooling for large-scale code modifications**
must be run over the whole codebase, before moving those checks to compile time for the rest of the company.

And those are ClangMR and JavacFlume — projects that are only briefly mentioned in this insightful paper.

*That is it, thank you for reading. We will post more on papers in this field soon.*
