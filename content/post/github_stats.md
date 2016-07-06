--- 
author: vadim
date: 2016-07-06
title: "Fun with GitHub repositories statistics." 
draft: false 
image: /post/github_stats/go.png
description: "Lots of histograms plotted for GitHub data collected by source{d}." 
---

It's always fun to play with a dataset few people has ever played with.
source{d} knows much about each GitHub developer, including the number of
bytes written in each programming language. So a trivial takeoff will be to
use this information to have a better understanding of the industry.

First of all, all software developers are humans (yet), and some of them
make open source contributions, which is a natural process. Therefore one
may expect the distribution of the overall number of bytes written by
each GitHub user to be [log-normal](https://en.wikipedia.org/wiki/Log-normal_distribution).
Well, it's not:

![overall](/post/github_stats/overall.png)

There are much more developers that wrote less code than average than
those who wrote more code than average. 
Yet if we look at each language individually, the picture becomes log-normal:

![C](/post/github_stats/c.png)

![Java](/post/github_stats/java.png)

![Python](/post/github_stats/python.png)

The more code is written in a language, apparently the more the peak
shifts to the right. For example, Go's peak is 9.22 while C's is 9.81.

![Go](/post/github_stats/go.png)

If a language goes out of the mainstream, the left slope becomes steep and
the right one flat:

![Cobol](/post/github_stats/cobol.png)

![Pascal](/post/github_stats/pascal.png)

Interestingly, some common languages are irregular:

![Javascript](/post/github_stats/js.png)

![Ruby](/post/github_stats/ruby.png)

It turns out that Javascript developer density stays the same in a broad interval
400 - 400000 bytes. The gap between numbers of casual and productive
rubyists is as high as 2x.

If we look at repository sizes, they are log-normal too:

![Java](/post/github_stats/repo_java.png)

![Python](/post/github_stats/repo_python.png)

These distributions demonstrate the fact that Python is less verbose than
Java: linear mean repository size is 30% smaller for the former.

Let's look at the number of contributors per repository:

![Contributors - log(number of repos)](/post/github_stats/contrib_number.png)

Clearly most of GitHub repos are used solely by their owners. But the
picture changes if we consider the overall sum of bytes instead of
repositories number:

![Contributors - log(bytes)](/post/github_stats/contrib_bytes.png)

Thus, most of the code is written in repositories with 2 contributors.

Finally, let's look at commit stats. The distribution is not log-normal,
the number of commits falls by a polynomial law. Here are the first 10:

![Commits - 10](/post/github_stats/commits_10.png)

And the rest in the log scale:

![Commits - log](/post/github_stats/commits_log.png)

So there is no such thing as a most common commits number, apart from 0 and 1.
Besides, it appears that the number of commits poorly correlates with the
amount of code written, otherwise we would get a log-normal distribution.

While all this analysis is fun, it's even more fun to repeat it after
some time, e.g. in a year. Watching how the state evolves will allow to
predict trends in software development and open source community.