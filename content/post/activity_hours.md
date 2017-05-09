---
author: vadim
date: 2017-05-04
title: "Daily commit activity on GitHub"
draft: false
image: /post/activity_hours/intro.png
description: "This post was inspired by <a href=\"https://stackoverflow.blog/2017/04/19/programming-languages-used-late-night/\">What programming languages are used late at night?</a> by StackOverflow. We take our <a href=\"https://data.world/vmarkovtsev/452-m-commits-on-github\">commits dataset</a>, combine it with <a href=\"\">repositories' languages dataset</a> and plot circular histograms for PST/PDT zones with Python."
categories: ["science", "technical"]
---

<style>
p.dt {
  margin-top: -16px;
  font-style: italic;
}
.twitter-tweet {
  margin-left: auto;
  margin-right: auto;
}
.verbatim {
  font-size: 0.85em;
}
</style>

I recently stumbled upon an interesting and straightforward data exploration made by David Robinson from StackOverflow: [What programming languages are used late at night?](https://stackoverflow.blog/2017/04/19/programming-languages-used-late-night/). Among other fun facts about the programming crowd, he discovered that Haskell is different from mainstream language, the SO questions' frequency grows much stronger in the evenings compared to other languages. It is intriguing to compare these observations with how people actually code on GitHub, and besides, our CEO [Eiso Kant](https://twitter.com/eisokant) is fond of Haskell enough to let me check, he-he. So I decided to use my [Open Source Friday](https://github.com/src-d/guide/blob/master/open-source/open_source_fridays.md) to work on this post.

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">Languages hourly popularity on <a href="https://twitter.com/StackOverflow">@StackOverflow</a> <a href="https://t.co/ZwIqk9dhur">https://t.co/ZwIqk9dhur</a><br>Probably will research on GitHub this <a href="https://twitter.com/hashtag/OpenSourceFriday?src=hash">#OpenSourceFriday</a></p>&mdash; Markovtsev Vadim (@tmarkhor) <a href="https://twitter.com/tmarkhor/status/855317847299334144">April 21, 2017</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

### What we will use

source{d} opens as much code and data as we can. In this particular case, we are going to use two public datasets that we published on data.world originating from our prev-gen data retrieval pipeline:

* [452M commits on GitHub](https://data.world/vmarkovtsev/452-m-commits-on-github)
* [GitHub repositories - languages distribution](https://data.world/source-d/github-repositories-languages-distribution)

They are not feature complete, especially the second one, but should be sufficient for our purposes.

Besides the data sets, we need the computing resources to digest the datasets. I am using Google Cloud and will show how to apply [Dataproc](https://cloud.google.com/dataproc/).

### Loading the data in Dataproc

The first thing we shall do is to launch the smallest Dataproc cluster. I have a post about [how to setup a working PySpark in Jupyter](https://blog.sourced.tech/post/dataproc_jupyter/), it covers the basic stuff. The initialization script [evolved](https://storage.googleapis.com/srcd-dataproc/minimal.sh) since then.

![dataproc1](/post/activity_hours/dataproc1.png)
<p align="center" class="dt">We create a 2-node, 8-core Dataproc cluster.</p>

![dataproc2](/post/activity_hours/dataproc2.png)
<p align="center" class="dt">Custom initialization script.</p>

We specify `gs://srcd-dataproc/minimal.sh` as the initialization script here. It should be accessible by everybody.
It normally takes less than 5 minutes to get the cluster running and fully operational. The master and worker nodes will be prepared to our requirements. Particularly, the master node will have:

* Unofficial [Google Drive CLI](https://github.com/odeke-em/drive) to fetch the datasets.
* `pandas`, `dateutil`, `pytz`, `matplotlib` to work and with them and plot the visuals.
* Jupyter Notebook integrated with Spark.

The next step is to download the datasets. data.world has a size limit which prevents from uploading files bigger than 50MB, so we decided to upload ours to Google Drive for ease of use.

<pre class="verbatim">
$ sudo su
$ cd
$ drive init
$ drive pull -id 0B-w8jGUJto0iMUk4dDRFOUtrV28
$ drive pull -id 0B-w8jGUJto0iS1pZR1NGSlNZcDQ
</pre>

`0B-w8jGUJto0iMUk4dDRFOUtrV28` and `0B-w8jGUJto0iS1pZR1NGSlNZcDQ` are Google Drive identifiers of the datasets, [452M commits on GitHub](https://drive.google.com/drive/folders/0B-w8jGUJto0iMUk4dDRFOUtrV28) and [GitHub repositories - languages distribution](https://drive.google.com/drive/folders/0B-w8jGUJto0iS1pZR1NGSlNZcDQ). It takes about 8 minutes to pull them (35 gigs).

![gdrive](/post/activity_hours/gdrive.png)
<p align="center" class="dt"><a href="https://github.com/odeke-em/drive">odeke-em/drive</a> at work.</p>

Now we need to upload the files to either HDFS or Google Cloud Storage. I prefer the latter because it is persistent whereas HDFS disappears when the cluster is deleted ([GCP documentation](https://cloud.google.com/dataproc/docs/resources/faq#data_access_availability))

<pre class="verbatim">
$ gsutil -m cp -r GitHubCommits gs://my-gcs-bucket
</pre>

We are using the `-m` switch here for concurrent upload streams - they speed up the process dramatically. More information about [gsutil](https://cloud.google.com/storage/docs/gsutil).

When this command finishes, we are ready for executing a PySpark job to analyze the data.

### Extracting the commits' frequency

Open `http://data-science-m:8123/` (again, read [the previous post](https://blog.sourced.tech/post/dataproc_jupyter/) how), you should see the list of your buckets thanks to [src-d/jgscm](https://github.com/src-d/jgscm) Jupyter backend. Enter the one you wish to store the notebooks and start a new "PySpark 3".

[452M commits on GitHub](https://data.world/vmarkovtsev/452-m-commits-on-github) has the following format:

```json
{
  "r": "repository name",
  "c": [{
    "h": "git hash",
    "a": "author's email hash",
    "t": "date and time commit was created",
    "m": "commit message"
  }, ...]
}
```

The above is prettified json but in the file it is a single line. We would like to aggregate commits by repository, then by weekday and finally by hour. For example,

<div id="pre-spark"></div>

```python
(('apache/spark', 0, 0), 68)
(('apache/spark', 0, 1), 22)
(('apache/spark', 0, 10), 225)
(('apache/spark', 0, 11), 297)
(('apache/spark', 0, 12), 270)
(('apache/spark', 0, 13), 296)
(('apache/spark', 0, 14), 278)
(('apache/spark', 0, 15), 259)
(('apache/spark', 0, 16), 323)
(('apache/spark', 0, 17), 273)
(('apache/spark', 0, 18), 248)
(('apache/spark', 0, 19), 180)
(('apache/spark', 0, 2), 10)
(('apache/spark', 0, 20), 164)
(('apache/spark', 0, 21), 204)
(('apache/spark', 0, 22), 230)
(('apache/spark', 0, 23), 242)
(('apache/spark', 0, 3), 3)
(('apache/spark', 0, 4), 12)
(('apache/spark', 0, 5), 5)
(('apache/spark', 0, 6), 10)
(('apache/spark', 0, 7), 5)
(('apache/spark', 0, 8), 45)
(('apache/spark', 0, 9), 97)
(('apache/spark', 1, 0), 182)
(('apache/spark', 1, 1), 71)
(('apache/spark', 1, 10), 297)
(('apache/spark', 1, 11), 330)
(('apache/spark', 1, 12), 279)
(('apache/spark', 1, 13), 303)
(('apache/spark', 1, 14), 348)
(('apache/spark', 1, 15), 310)
(('apache/spark', 1, 16), 305)
(('apache/spark', 1, 17), 252)
(('apache/spark', 1, 18), 241)
(('apache/spark', 1, 19), 176)
(('apache/spark', 1, 2), 42)
(('apache/spark', 1, 20), 129)
(('apache/spark', 1, 21), 177)
(('apache/spark', 1, 22), 272)
(('apache/spark', 1, 23), 244)
(('apache/spark', 1, 3), 10)
(('apache/spark', 1, 4), 3)
(('apache/spark', 1, 5), 7)
(('apache/spark', 1, 6), 9)
(('apache/spark', 1, 7), 24)
(('apache/spark', 1, 8), 54)
(('apache/spark', 1, 9), 170)
(('apache/spark', 2, 0), 142)
(('apache/spark', 2, 1), 71)
(('apache/spark', 2, 10), 302)
(('apache/spark', 2, 11), 330)
(('apache/spark', 2, 12), 261)
(('apache/spark', 2, 13), 292)
(('apache/spark', 2, 14), 303)
(('apache/spark', 2, 15), 338)
(('apache/spark', 2, 16), 330)
(('apache/spark', 2, 17), 250)
(('apache/spark', 2, 18), 192)
(('apache/spark', 2, 19), 154)
(('apache/spark', 2, 2), 20)
(('apache/spark', 2, 20), 115)
(('apache/spark', 2, 21), 185)
(('apache/spark', 2, 22), 216)
(('apache/spark', 2, 23), 213)
(('apache/spark', 2, 3), 4)
(('apache/spark', 2, 4), 24)
(('apache/spark', 2, 6), 4)
(('apache/spark', 2, 7), 19)
(('apache/spark', 2, 8), 51)
(('apache/spark', 2, 9), 132)
(('apache/spark', 3, 0), 115)
(('apache/spark', 3, 1), 67)
(('apache/spark', 3, 10), 262)
(('apache/spark', 3, 11), 272)
(('apache/spark', 3, 12), 246)
(('apache/spark', 3, 13), 254)
(('apache/spark', 3, 14), 314)
(('apache/spark', 3, 15), 304)
(('apache/spark', 3, 16), 280)
(('apache/spark', 3, 17), 299)
(('apache/spark', 3, 18), 218)
(('apache/spark', 3, 19), 164)
(('apache/spark', 3, 2), 13)
(('apache/spark', 3, 20), 144)
(('apache/spark', 3, 21), 171)
(('apache/spark', 3, 22), 267)
(('apache/spark', 3, 23), 192)
(('apache/spark', 3, 3), 4)
(('apache/spark', 3, 4), 2)
(('apache/spark', 3, 5), 5)
(('apache/spark', 3, 6), 6)
(('apache/spark', 3, 7), 14)
(('apache/spark', 3, 8), 41)
(('apache/spark', 3, 9), 128)
(('apache/spark', 4, 0), 134)
(('apache/spark', 4, 1), 58)
(('apache/spark', 4, 10), 191)
(('apache/spark', 4, 11), 299)
(('apache/spark', 4, 12), 232)
(('apache/spark', 4, 13), 274)
(('apache/spark', 4, 14), 256)
(('apache/spark', 4, 15), 312)
(('apache/spark', 4, 16), 169)
(('apache/spark', 4, 17), 179)
(('apache/spark', 4, 18), 123)
(('apache/spark', 4, 19), 92)
(('apache/spark', 4, 2), 12)
(('apache/spark', 4, 20), 119)
(('apache/spark', 4, 21), 109)
(('apache/spark', 4, 22), 155)
(('apache/spark', 4, 23), 137)
(('apache/spark', 4, 3), 4)
(('apache/spark', 4, 4), 11)
(('apache/spark', 4, 5), 9)
(('apache/spark', 4, 6), 4)
(('apache/spark', 4, 7), 8)
(('apache/spark', 4, 8), 47)
(('apache/spark', 4, 9), 104)
(('apache/spark', 5, 0), 113)
(('apache/spark', 5, 1), 43)
(('apache/spark', 5, 10), 52)
(('apache/spark', 5, 11), 88)
(('apache/spark', 5, 12), 107)
(('apache/spark', 5, 13), 112)
(('apache/spark', 5, 14), 104)
(('apache/spark', 5, 15), 117)
(('apache/spark', 5, 16), 145)
(('apache/spark', 5, 17), 87)
(('apache/spark', 5, 18), 81)
(('apache/spark', 5, 19), 56)
(('apache/spark', 5, 2), 13)
(('apache/spark', 5, 20), 60)
(('apache/spark', 5, 21), 114)
(('apache/spark', 5, 22), 92)
(('apache/spark', 5, 23), 121)
(('apache/spark', 5, 3), 3)
(('apache/spark', 5, 4), 6)
(('apache/spark', 5, 5), 4)
(('apache/spark', 5, 6), 5)
(('apache/spark', 5, 7), 7)
(('apache/spark', 5, 8), 29)
(('apache/spark', 5, 9), 24)
(('apache/spark', 6, 0), 65)
(('apache/spark', 6, 1), 36)
(('apache/spark', 6, 10), 71)
(('apache/spark', 6, 11), 104)
(('apache/spark', 6, 12), 71)
(('apache/spark', 6, 13), 86)
(('apache/spark', 6, 14), 98)
(('apache/spark', 6, 15), 100)
(('apache/spark', 6, 16), 129)
(('apache/spark', 6, 17), 120)
(('apache/spark', 6, 18), 89)
(('apache/spark', 6, 19), 101)
(('apache/spark', 6, 2), 15)
(('apache/spark', 6, 20), 102)
(('apache/spark', 6, 21), 127)
(('apache/spark', 6, 22), 122)
(('apache/spark', 6, 23), 104)
(('apache/spark', 6, 3), 5)
(('apache/spark', 6, 4), 1)
(('apache/spark', 6, 5), 3)
(('apache/spark', 6, 7), 6)
(('apache/spark', 6, 8), 13)
(('apache/spark', 6, 9), 39)
```

<style>
#pre-spark + pre {
  max-height: 400px;
  overflow-y: auto;
}
</style>

The tricky part is, of course, dealing with time. People commit with invalid timezones quite often. Besides, we do not want to mix users living in different countries... and we've only got "t"-s like

<pre class="verbatim">
2015-02-14 23:37:53 -0800 -0800
</pre>

I am sure you can do better, but I decided to cut corners and analyze on the [PST](https://en.wikipedia.org/wiki/UTC%E2%88%9208:00) timezone; Silicon Valley and friends ;).

![timezones](/post/activity_hours/timezones.png)
<p align="center" class="dt">World's timezones taken from <a href="https://en.wikipedia.org/wiki/Time_zone">Wikipedia</a>.</p>

There is still an issue I need to deal with though: PST turns into PDT and back, and we need to keep track of the time offset in each part of the year. Anyway, here is the complete code:

```python
import json
from datetime import timedelta
from dateutil.parser import parse as dateutil_parse
import pytz

def aggregate_commits(line):
    try:
        repo = json.loads(line)
        commits = repo["c"]
    except:
        return
    pacific = pytz.timezone("US/Pacific")
    for commit in commits:
        try:
            dttext = commit["t"]
            dttext = dttext[:dttext.rfind(" ")]
            dt = dateutil_parse(dttext)
            if dt.tzinfo is None:
                continue
            dst = dt.astimezone(pacific).dst()
            offset = -(dt.utcoffset().days * 24 * 3600 +
                       dt.utcoffset().seconds) // 3600
        except:
            continue
        if (dst and offset == 7) or (not dst and offset == 8):
            yield (repo["r"], dt.weekday(), dt.hour), 1

from operator import add
sc.textFile("gs://my-gcs-bucket/*.lzo", minPartitions=1000) \
    .repartition(1000).flatMap(aggregate_commits).reduceByKey(add) \
    .repartition(1).saveAsTextFile("gs://my-gcs-bucket/pst_stats")
```

Before running it, you would probably like to dynamically resize your Dataproc cluster.

![resizing Dataproc](/post/activity_hours/resize.png)
<p align="center" class="dt">My favourite Dataproc feature - dynamic cluster resizing using the cheap preemptible nodes.</p>

The job normally takes about 20 minutes on a 32-node 4-core configuration. When it finishes, we must copy results locally to work with them:

<pre class="verbatim">
# gsutil cp gs://my-gcs-bucket/pst_stats/part-00000 pst_stats.txt
</pre>

For those of you who are lazy or don't want to spend on the computational resources, I uploaded that file to [Google Drive](https://drive.google.com/file/d/0B-w8jGUJto0iRl9UWHpiOXQ3LWc).

### Combining the two datasets

Of course, the best way to deal with the languages distribution in commits is to inspect diff-s individually, however, source{d}'s next generation pipeline is in the process of being built. Instead, we will consider all commits to the same repository equal and carry the constant language proportions belonging to that repository. Let's load the second dataset:

```python
import pandas
repos = pandas.read_csv(
    "GitHubRepoLanguages/repos_languages.csv.gz",
    index_col="repository", engine="c", na_filter=False,
    memory_map=True)
```

This operation takes a while, around 6 minutes. If you've inflated the cluster in the previous section, you can now safely shrink it to the minimal volume - we are no longer using Spark.

The following code parses the `pst_stats.txt` file which was generated before and calculates the resulting commit frequency distribution for every language:

```python
result = numpy.zeros((7, 24, len(repos.columns)))
with open("pst_stats.txt") as fin:
    for line in fin:
        # input example: (('apache/spark', 6, 9), 39)\n
        line = line.split(" ")
        repo = line[0][3:line[0].rfind("'")]
        try:
            langs = repos.loc[repo]
        except KeyError:
            continue
        weekday = int(line[1][:-1])
        hour = int(line[2][:-2])
        count = int(line[3][:-2])
        result[weekday, hour] += count * langs
```

We could simply `eval(line)` in the snippet above but it is always much slower compared to manual parsing. The `result` variable stores the commit frequencies we desire. They are aggregated by weekday and then by hour. E.g. `result[0, 12]` is the vector which shows how many commits were made in each language on Monday between 12am and 1pm (European locale everywhere).

### Plotting

And now the fun part. We will plot `result` in the form of a circular histogram to reflect the daily cycle.

```python
# works best with %pylab inline

def hplot_polar(lang, size=150, normalize=False):
    ilang = repos.columns.get_loc(lang)
    rcParams["figure.figsize"] = (9, 9)
    theta = linspace(0, 2 * pi, 24, endpoint=False)
    norm = result[:5, :, ilang].sum()
    radii = size * result[:5, :, ilang].sum(axis=0) / norm
    width = 2 * pi / 24
    ax = subplot(111, polar=True)
    bar(theta, radii, width=width, bottom=8, edgecolor="black",
        alpha=0.5, label="Workdays")
    if normalize:
        norm = result[5:, :, ilang].sum()
    else:
        norm *= 2 / 5
    radii = size * result[5:, :, ilang].sum(axis=0) / norm
    bar(theta, radii, width=width, bottom=8, edgecolor="black",
        alpha=0.5, label="Weekends")
    xticks(theta - pi / 24, arange(24), fontsize=16)
    yticks([])
    legend(bbox_to_anchor=(1.11, 1.08), prop={"size": 16})
    gca().set_axisbelow(True)
    gca().set_theta_offset(pi / 2 - pi / 24)
    gca().set_theta_direction(-1)
    gca().add_artist(Circle(
        (0, 0), 7.9, fill=True, color="white",
        transform=gca().transData._b))
    text(0, 0, "%s commits\non GitHub\nin PST/PDT\nby hour%s" %
               (lang, "\n(normalized)" if normalize else ""),
         ha="center", va="center", size=20)
```

There are several tricks here that I apply:

* Splitting the plot into two separate histograms, for workdays and weekends: `[:5]` and `[5:]`.
* Using [polar axes in matplotlib](https://matplotlib.org/2.0.0/examples/pylab_examples/polar_demo.html), with θ offset and inverted direction to emulate a "clockface".
* `bar` plot with `bottom` set makes the bars start from the inner circle instead of the center.
* `Circle` artist hides the axes in the inner circle so that the text is drawn clear.
* We can additionally specify `normalize=True` to see the relative difference in frequency distributions.

<div class="grid2x">
<div>
<div>
<img src="/post/activity_hours/go.png">
<p align="center" class="dt"><pre><code class="hljs python">hplot_polar("Go")</code></pre></p>
</div>
<div>
<img src="/post/activity_hours/haskell.png">
<p align="center" class="dt"><pre><code class="hljs python">hplot_polar("Haskell")</code></pre></p>
</div>
<div>
<img src="/post/activity_hours/d.png">
<p align="center" class="dt"><pre><code class="hljs python">hplot_polar("D")</code></pre></p>
</div>
<div>
<img src="/post/activity_hours/elm.png">
<p align="center" class="dt"><pre><code class="hljs python">hplot_polar("Elm")</code></pre></p>
</div>
<div>
<img src="/post/activity_hours/rust.png">
<p align="center" class="dt"><pre><code class="hljs python">hplot_polar("Rust")</code></pre></p>
</div>
</div>
<div>
<div>
<img src="/post/activity_hours/go_norm.png">
<p align="center" class="dt"><pre><code class="hljs python">hplot_polar("Go", normalize=True)</code></pre></p>
</div>
<div>
<img src="/post/activity_hours/java.png">
<p align="center" class="dt"><pre><code class="hljs python">hplot_polar("Java")</code></pre></p>
</div>
<div>
<img src="/post/activity_hours/python.png">
<p align="center" class="dt"><pre><code class="hljs python">hplot_polar("Python")</code></pre></p>
</div>
<div>
<img src="/post/activity_hours/js.png">
<p align="center" class="dt"><pre><code class="hljs python">hplot_polar("JavaScript")</code></pre></p>
</div>
<div>
<img src="/post/activity_hours/php.png">
<p align="center" class="dt"><pre><code class="hljs python">hplot_polar("PHP")</code></pre></p>
</div>
</div>
</div>

<style>
.grid2x {
  display: flex;
  width: 1000px;
  overflow: visible;
  margin-left: -200px;
}
.grid2x pre {
  text-align: center;
}
@media (max-width: 1000px) {
  .grid2x {
    width: 100%;
    margin-left: 0;
  }
  .grid2x > div {
    width: 50%;
  }
  .grid2x pre {
    font-size: 0.75em;
  }
}
</style>

### Conclusions

We see that the programming languages can be divided into two highly distinguishable groups. 

The first is "weekend languages" (on the left), in which we see new, emerging species as well as die-hards like Haskell. That group has nearly the same contribution activity throughout the whole week and no "lunch time" productivity fall. The larger the `(weekends - weekdays)` difference, the more emerging is the language, e.g. Elm and D. 

So why do Haskell programmers ask relatively more questions on StackOverflow in the evening? We can see from the coding habit that Haskelistas become very active after 8 pm, almost the same level as on the general "productivity peak" at 3 pm.

The second group is mainstream, well established languages (on the right). We see the clear pitfall at lunch time, between 12 am and 2 pm, which is the evidence that those languages are used for work and not as a hobby. Besides, the weekend activity of those languages has very similar gaussian distribution as in the first group. One interesting observataion is that PHP programmers seem to code **a lot** in the night, sharp deadlines or a big involvement?

There is a productivity peak between 2 pm and 5 pm for all the languages, when the commit frequency is the highest. This is the industry's golden time. Managers should never distract coders during this interval.


### Acknowledgements

I would like to thank our infrastructure engineer, Sonia Meruelo, for the valuable ideas.
