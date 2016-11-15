---
author: vadim
date: 2016-11-14
title: "Hands on with the most starred GitHub repositories."
draft: false
image: /post/github_stars/star.png
description: "Playing with most popular repositories' metadata."
---
Recently I started to collect all the available metadata (name,
number of stars, forks, watchers, etc.) from the most popular GitHub repositories.
I chose the "number of stargazers" as a measure of popularity. This metric
is by no means perfect, but at least should have a strong positive correlation.
<details>
<summary style="cursor: pointer;">How I quickly grabbed all repositories with ≥50 stars (over 120k) using a <span style="text-decoration: line-through;">crappy</span> script.</summary>

Seems easy, but the GitHub API limits make it nontrivial. Let me remind you:

1. Registered users may not issue more than 30 API requests per minute,
5,000 per hour. This is unpleasant but we can live with this, since only the
retrieval speed is reduced.
2. Search API is limited to 1000 results. This is much worse than (1), because
it limits the volume of data we can fetch even we have infinite time.

If we go to the GitHub web search and set the query to
[stars:>=50](https://github.com/search?utf8=%E2%9C%93&q=stars%3A%3E%3D50&ref=simplesearch),
we will get more than 124,000 results. Apparently, we cannot fetch
all of them in a single step and have to hack this. I've always loved to hack,
so I created [vmarkovtsev/GitHubStars](https://github.com/vmarkovtsev/GitHubStars).
It is a quick and dirty Python script which fetches Search API results
in batches. It works in two stages:

1. Probe GitHub Search API results for specific star intervals.
2. Fetch those intervals one by one.

For example, we probe the number of repositories returned from the query
`stars:50..60` and get 17,870 results. Too much (we've have a 1k limit, remember).
OK, then we probe `stars:50..55` and get 10,566. Still too much. We continue
to bisect the interval until we eventually converge to `stars:50..50`
with 1,885. That number is bigger than 1000; does it mean we are unable
to fetch all repositories rated with 50 stars? The answer is no, if we
apply a trick which I call "updated dual-order".

The idea is to sort the response by the last updated date of the repository
(Search API allows setting different sort keys). We make 2 requests,
the first with ascending order and the second with descending. We take
1000 from the first and the last 885 from the second. Thus we extend the
maximum number of query results to 2k.

The outcome of the first stage is the list of the star intervals we are
able to consume as a whole, each yielding less than 2000 items.
Probes are made with the page size equal to 1 and are very fast. The second
stage alters the page size to 100 (the maximum allowed) and extracts the data.
Here is how to launch the script:

```
python3 github_stars.py -i <api token> -o repos.json
```

It takes about 2 hours to finish with my somewhat slow home internet connection.
We scheduled to record the stars snapshots every week in our production environment.
</details>

This is the log log histogram of the repository-star relation:

![hist.png](/post/github_stars/hist.png)

X axis is the logarithm of the number of stars \\(\\log S\\), Y axis is the logarithm
of the repositories density \\(\\log\\frac{dR}{dS}\\). If we want
to answer the question, how many repositories are starred between \\(S_ {min}\\)
ans \\(S_ {max}\\), the answer will be \\(\\int_ {S_ {min}}^{S_ {max}} \\limits \\frac{dR}{dS} dS\\).
Logarithms are used because the derivative vanishes very quickly as \\(S\\) grows.
It is clearly seen that the repositories density drops exponentially as the
number of stargazers increases. Let's prove the distribution is actually
[log-normal](https://en.wikipedia.org/wiki/Log-normal_distribution).

![statistics time](/post/github_stars/stats_time.png)

We will use the awesome [powerlaw](https://github.com/jeffalstott/powerlaw)
package to plot the estimated [PDF](https://en.wikipedia.org/wiki/Probability_density_function)
and the log-normal fit.

```python
import pickle, numpy, powerlaw
# Load the repositories metadata from GitHubStars
with open("repos.pickle", "rb") as fin:
    repos = pickle.load(fin)
# Extract the series of star numbers
stars = numpy.array([r.stargazers_count for r in repos])
# Fit into all possible discrete distributions with a single awesome line
# There is no data before 50; the distribution becomes unstable after 1000
fit = powerlaw.Fit(stars, xmin=50, xmax=1000, discrete=True)
# Plot the projected and fitted probability distributions
fit.plot_pdf()
fit.power_law.plot_pdf(linestyle="--")
```

![fit](/post/github_stars/fit.png)

We see that the fit is good. It's parameters are: μ=-15.31, σ=5.23.
We crop the observed interval by 1000,
it contains 93% of all the analysed repositories and does not include very high rated
noisy samples (as seen on the histogram or on full PDF). Those noisy samples
are unstably, randomly distributed and are not fittable.
Let's compare the log-normal hypothesis with the
[power-law](https://en.wikipedia.org/wiki/Power_law#Power-law_probability_distributions)
and [exponential](https://en.wikipedia.org/wiki/Exponential_distribution) ones.

```python
>>> fit.distribution_compare("lognormal", "exponential", normalized_ratio=True)
(74.347790532408624, 0.0)
>>> fit.distribution_compare("lognormal", "power_law", normalized_ratio=True)
(1.8897939959930001, 0.058785516870108641)
```

These are the handy loglikelihood trials built into powerlaw,
[link to the documentation](http://pythonhosted.org/powerlaw/index.html?highlight=distribution_compare#powerlaw.Fit.distribution_compare).
It can be seen that with a 100% confidence the log-normal fit is better than exponential
and with 94% confidence better than the power-law.

All right, what about the number of forks? Every registered GitHub user can fork
a repository to his or her personal account, incrementing the corresponding counter of the origin,
and GitHub API reports those counters' values.
Their distribution appears quite different:

![forks_hist](/post/github_stars/forks_hist.png)

However, it fits well to log-normal within the interval \[30, 5000\] forks:

![forks_fit](/post/github_stars/forks_fit.png)

Please note: we are plotting in the log-log domain, so the imaginary plateau
on the histogram is not the "real" one.

What about the number of open issues?

![issues_hist](/post/github_stars/issues_hist.png)

Fit in \[10, 600\]:

![issues_fit](/post/github_stars/issues_fit.png)

Thus the majority of the top rated repositories has a small number of open
issues, particularly 80% have less than 18.

The three mentioned metrics appear to have the same distribution kind.
Are they actually correlated? A quick shot with
[pandas](http://pandas.pydata.org/pandas-docs/version/0.18.1/visualization.html#scatter-matrix-plot)
reveals it:

```python
dataset = numpy.empty((len(repos), 3), dtype=float32)
dataset[:, 0] = [log(r.stargazers_count) for r in repos]
dataset[:, 1] = [log(r.forks_count + 1) for r in repos]
dataset[:, 2] = [log(r.open_issues_count + 1) for r in repos]
import pandas
df = pandas.DataFrame(dataset, columns=["Stars", "Forks", "Open issues"])
axes = pandas.tools.plotting.scatter_matrix(df, alpha=0.2)
```

![scatter](/post/github_stars/scatter.png)

So the answer is yes, all three are positively correlated. To be precise, here is
the correlation matrix:

|      |      |      |
|------|------|------|
| 1.00 | 0.72 | 0.45 |
| 0.72 | 1.00 | 0.50 |
| 0.45 | 0.50 | 1.00 |

Bonus
-----
It appeared that some highly rated repositories became ghosts, that is, are empty.

|                                                             |                                                                     |
|-------------------------------------------------------------|---------------------------------------------------------------------|
|[openrasta/openrasta](https://github.com/openrasta/openrasta)|[Habraruby/Ruby-Problems](https://github.com/Habraruby/Ruby-Problems)|
|[flyth/ts3soundbot](https://github.com/flyth/ts3soundbot)|[StephanSchmidt/SimpleKanban](https://github.com/StephanSchmidt/SimpleKanban)|
|[blend2d/b2d](https://github.com/blend2d/b2d)|[core/wsgicore](https://github.com/core/wsgicore)|
|[mlpoll/machinematch](https://github.com/mlpoll/machinematch)|[paulirish/devtools-addons](https://github.com/paulirish/devtools-addons)|
|[lukelove/AppceleratorRecord](https://github.com/lukelove/AppceleratorRecord)|[TheKnightsWhoSayNi/info](https://github.com/TheKnightsWhoSayNi/info)|
|[MozOpenHard/CHIRIMEN](https://github.com/MozOpenHard/CHIRIMEN)|[go-gitea/gitea_old](https://github.com/go-gitea/gitea_old)|
|[realworldocaml/book](https://github.com/realworldocaml/book)|[core/httpcore](https://github.com/core/httpcore)|
|[DNS-P2P/DNS-P2P](https://github.com/DNS-P2P/DNS-P2P)|[leoluk/thinkpad-stuff](https://github.com/leoluk/thinkpad-stuff)|
|[lipeiwei-szu/ONE-API](https://github.com/lipeiwei-szu/ONE-API)|[Tencent/behaviac](https://github.com/Tencent/behaviac)|

And there are at least two repositories which are empty by design, either serving
as a wiki or as an issue tracker: [koush/support-wiki](https://github.com/koush/support-wiki)
and [WarEmu/WarBugs](https://github.com/WarEmu/WarBugs).

<script async src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_CHTML"></script>
