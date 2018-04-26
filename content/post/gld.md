---
author: vadim
date: 2018-04-17
title: "Detecting licenses in code with Go and ML"
image: /post/gld/wthpl.png
description: "Detecting the license of an open source projects is harder than it seems. We have created go-license-detector, a Go library and command line application to solve that task."
categories: ["science", "technical"]
---

While working on [Public Git Archive](https://github.com/src-d/datasets/PublicGitArchive), we
thought that it would be handy to include the license of each project in the index file, so that
people could easily filter "grey" repositories without a clear license. Besides, we were
curious about the licenses distribution. GitHub already detects licenses by leveraging
the Ruby library [benbalter/licensee](https://github.com/benbalter/licensee) and the easy solution was
to query the GitHub API. However, we were not satisfied with
its detection quality: many projects which actually contain the license file in a non-standard
format are missed, and some are misclassified. This is how
[go-license-detector](https://github.com/src-d/go-license-detector) was born.

The goals were defined from the very beginning:

1. Favor false positives over false negatives (target data mining instead of compliance).
2. Perform fast.
3. Detect as many licenses as possible on the [hand-collected dataset of 1,000 top-starred repositories
on GitHub](https://github.com/src-d/go-license-detector/blob/master/licensedb/dataset.zip).
4. Comply with SPDX [licenses list](https://github.com/spdx/license-list-data) and
[detection guidelines](https://spdx.org/spdx-license-list/matching-guidelines).

(1) means that we should rather label a project with a slightly inaccurate license than miss its
license completely. The open source compliance departments will not be satisfied with this choice,
as they need the opposite: the missed projects are manually studied. (2) restricts from using a
scripting language such as Python or Ruby, and we chose Go for our implementation. (3) leads
to technical tricks, hacks and heuristics which result in complex code.
(4) is the only way to obtain the database of 400 different licenses validated by professional
lawyers.

The following table compares the current go-license-detector with GitHub's built-in license detector,
Google's licenseclassifier and Ben Boyter's `lc` on the
[reference 1k dataset](https://github.com/src-d/go-license-detector/blob/master/licensedb/dataset.zip):

|Detector|Detection rate|Time to scan, sec|
|:-------|:----------------------------------------:|:-----------------------------------------|
|[go-license-detector](https://github.com/src-d/go-license-detector)| 99% \\(\\quad(\\frac{897}{902})\\) | 16 |
|[benbalter/licensee](https://github.com/benbalter/licensee)| 75% \\(\\quad(\\frac{673}{902})\\) | 111 |
|[google/licenseclassifier](https://github.com/google/licenseclassifier)| 76% \\(\\quad(\\frac{682}{902})\\) | 907 |
|[boyter/lc](https://github.com/boyter/lc)| 88% \\(\\quad(\\frac{797}{902})\\) | 548 |

The total number of repositories in the dataset is 958, however, only 902 contain any pointer to
the license - we looked through each of them. The rest are mainly "awesome lists" and Chinese projects
and translations of the western books. The latter are specific to Chinese developer community
with ~absent~ different licensing policies. We filed issues for the maintainers to clarify the license
[\[1\]](https://github.com/DrkSephy/es6-cheatsheet/issues/90)
[\[2\]](https://github.com/kdn251/interviews/issues/63)
[\[3\]](https://github.com/markerikson/react-redux-links/issues/87)
[\[4\]](https://github.com/CodeHubApp/CodeHub/issues/441)
[\[5\]](https://github.com/h4cc/awesome-elixir/issues/4400)
[\[6\]](https://github.com/fffaraz/awesome-cpp/issues/449).
We also encountered two licenses which were not included into SPDX and reported them:
[\[1\]](https://github.com/spdx/license-list-XML/issues/611)
[\[2\]](https://github.com/spdx/license-list-XML/issues/612).

#### How we measured time

Hardware: Intel Core i7-7500U (2x2 threads), 2x8GB LPDDR3@1867MHz.

```bash
$ cd $(go env GOPATH)/src/gopkg.in/src-d/go-license-detector.v2/licensedb
$ mkdir dataset && cd dataset
$ unzip ../dataset.zip
$ # src-d/go-license-detector
$ time license-detector * \
  | grep -Pzo '\n[-0-9a-zA-Z]+\n\tno license' | grep -Pa '\tno ' | wc -l
$ # benbalter/licensee
$ time ls -1 | xargs -n1 -P4 licensee \
  | grep -E "^License: Other" | wc -l
$ # google/licenseclassifier
$ time find -type f -print | xargs -n1 -P4 identify_license \
  | cut -d/ -f2 | sort | uniq | wc -l
$ # boyter/lc
$ time lc . \
  | grep -vE 'NOASSERTION|----|Directory' | cut -d" " -f1 | sort | uniq | wc -l
```

## Algorithm

We have implemented license detection based on the `LICENSE` and `README` files for now, and wish to
add fine-grained scanning of source code files in the future (do you want to help us?
work on the [issue](https://github.com/src-d/go-license-detector/issues/24)). Given the
stated license text, we compare it to the texts in the SPDX database and record the match. The naive
way of making the comparisons is to calculate the
[Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance)
between the query and each of the examples. This is not fast at all for two reasons:

1. The complexity is linear to the number of examples.
2. The complexity is linear to the size of the difference. Since we've always gotten very few matches,
the rest of the distances will be slow to calculate.

These two reasons confidently render the naive approach unusable.

The core of go-license-detector's detection mechanism is [Locality Sensitive Hashing](https://en.wikipedia.org/wiki/Locality-sensitive_hashing).
We treat each license as a [TF-IDF-weighted](https://en.wikipedia.org/wiki/Tf%E2%80%93idf)
[bag-of-words](https://en.wikipedia.org/wiki/Bag-of-words_model) - that is, as a set of words where every
word has a weight corresponding to the frequency in the license text (term frequency) and
throughout the whole database (document frequency). This is a proven approach for large scale
similarity detection which we used multiple times in the past. Although 400 items is clearly
not large scale at all, it still makes sense to employ LSH because of the O(1) complexity
guarantee. We saw that it works reasonably well in practice and introduces a small overhead,
around 20MB of memory for the hashes and the vocabulary.

The hashing algorithm which we use is
[Weighted MinHash](http://static.googleusercontent.com/media/research.google.com/en//pubs/archive/36928.pdf)
- again, battle-tested in the past, e.g. in [Apollo](https://github.com/src-d/apollo) or
[bags deduplication](https://blog.sourced.tech/post/minhashcuda/).
After careful tuning of false positives, false negatives, and performance, we decided to set the Jaccard
similarity threshold for our algorithm to 75%, and the hash length to 154 samples.
Since we discard the text structure by treating sequences as sets, we further calculate the Levenshtein
distance to the matched database records in order to determine the precise confidence value.

We look at the `README` file if the analyzed project does not contain a license file. This happens
in more than 7% of the cases in the 1k dataset and 66% in Public Git Archive (182,000 repositories).
There is a fair chance that the license name is mentioned in the `README`, so we apply
[Named Entity Recognition](https://en.wikipedia.org/wiki/Named-entity_recognition)
to find them using the excellent [jdkato/prose](https://github.com/jdkato/prose) NLP library for Go.

Unfortunately, the devil is in the details. There are many unexpected variations for which we had to modify
our initially straight-forward algorithm.

## File names

There are many possible license file names. A few examples:

```nohighlight
LICENSE
license.txt
License.md
lisence.html
lisense.rst
copyright
copying
MIT.txt
gpl-2.0
legal
```

All of them may contain useful information, so we have to design a suitable regular expression for
them, which is currently

```go
var (
	licenseFileNames = []string{
		"li[cs]en[cs]e(s?)",
		"legal",
		"copy(left|right|ing)",
		"unlicense",
		"l?gpl([-_ v]?)(\\d\\.?\\d)?",
		"bsd",
		"mit",
		"apache",
	}
	licenseFileRe = regexp.MustCompile(
		fmt.Sprintf("^(|.*[-_. ])(%s)(|[-_. ].*)$",
			strings.Join(licenseFileNames, "|")))
)
```

There may also be directories which are named like a license file, and we need to look inside.
A few projects contained symbolic links to the actual license texts, and we need to resolve them.
One project even has a license file which consists of the path to a real `LICENSE` file with a custom file name - we treat those as symlinks.

## Rendering and normalization

Many developers like when the licenses are displayed on GitHub nicely formatted, either
put directly in HTML or written using a markup language such as Markdown or ReStructuredText.
Reading those files verbatim is harmful for our matching core and decreases the detection rate
dramatically. Thus we should first render markup to HTML and then extract plain text content from
HTML. go-license-detector currently supports Markdown through
[russross/blackfriday](https://github.com/russross/blackfriday) and ReST through
[hhatto/gorst](https://github.com/hhatto/gorst). HTML tags are stripped with `golang.org/x/net/html`
and a custom HTML entity recognizer.

Having a plain text license, we need to normalize it. SPDX has a list of rules which do not affect
accuracy, and we leverage it. However, our goal is data mining, so we can normalize aggressively.
We designed a three-level normalization pipeline. The first one is SPDX with some other rules
which do not affect the detection accuracy. The second one removes punctuation and lines with
copyright information. We apparently lose some data but our detection is more robust to random
deviations such as dots in the end of the section names or multiple copyright notices in the
header. Finally, the third level removes letter accents (e.g. ñ becomes n, á becomes a, etc.) and
removes all non-alphanumeric characters.

To summarize, this is the evolution of the license file content inside go-license-detector's normalizer.

Original ([home-assistant/home-assistant](https://raw.githubusercontent.com/home-assistant/home-assistant/dev/LICENSE.md)):
{{% code src="/post/gld/norm/1.txt" lang="markdown" height="400" %}}

HTML:
{{% code src="/post/gld/norm/2.txt" lang="html" height="400" %}}

Plain text:
{{% code src="/post/gld/norm/3.txt" lang="nohighlight" height="400" %}}

Normalized-1 - SPDX guidelines:
{{% code src="/post/gld/norm/4.txt" lang="nohighlight" height="400" %}}

Normalized-2 - dots and copyrights removed:
{{% code src="/post/gld/norm/5.txt" lang="nohighlight" height="400" %}}

Normalized-3 - non-alphanumeric symbols removed:
{{% code src="/post/gld/norm/6.txt" lang="nohighlight" height="400" %}}

We use level 3 output for LSH and level 2 output for the Levenshtein distance refinement.

## Merged licenses

There are projects with several license texts in the same file
Some of them are dual-licensed, some mention dependencies. Our core matcher assumes the single
sample by design, and those cases are hard for it to handle.
[google/licenseclassifier](https://github.com/google/licenseclassifier) project gracefully
digests them because it is based on ngram hashing instead, and hence we considered switching to that
algorithm. We did not for the following reasons:

1. The memory consumption is higher, about [200 MB](https://github.com/google/licenseclassifier/blob/master/classifier.go#L188).
2. Non-trivial database preprocessing and lack of high-level documentation.
3. Slower performance on single licenses.
3. It appeared that 95% of the cases could be resolved by simple split heuristics.

After all, we found that since it is very cheap to query a text, we could make a few split assumptions
and process each variant independently. For example, many texts separate licenses
with `===` or `---` decorations. Besides, it is common to place the license name before the body
and we easily find all possible split points. This is still not bulletproff as in license-classifier,
but as was written works reasonably well.

## Pointers

Sometimes, all the efforts fail and we do not discover anything in `LICENSE` files and in `README` files.
There is still hope: we discovered that many projects contain the URL to the official license text
in them. E.g. [awesome lists which have the CC0 badge at the bottom](https://github.com/terryum/awesome-deep-learning-papers),
[Apache banners](https://github.com/dmlc/xgboost/blob/master/LICENSE) or numerous users of
[mit-license.org](https://mit-license.org). 

## Implementation

go-license-detector is a library and a self-contained binary CLI tool.

[Francesc](https://twitter.com/francesc), our VP of Developer Community, took a serious effort
in making the code idiomatic. You may have experienced this: when you are focused on **what** your
code is doing, you often miss **how** the code is looking. I would like to write
a follow-up post which describes which points were improved and what were the
typical issues.

## Offtopic

Since we had to manually look through hundreds of most-starred projects on GitHub, we noticed
a few funny trends. Many Chinese repositories isolated from the other communities,
awesome list expansion and others. Again, I should devote a separate post to those,
they are funny and also help to understand the picture of open source popularity better.

## PGA license survey

We've recently released [Public Git Archive](https://github.com/src-d/datasets/PublicGitArchive) (PGA),
182,000 Git repositories belonging to most popular projects on GitHub. It's index file contains the licenses
detected by go-license-detector. The following pie chart summarizes the license usage in PGA:

{{% caption src="/post/gld/pga-licenses.svg" %}}
Distribution of licenses in Public Git Archive.
{{% /caption %}}

<!-- Render -->
<!--
<svg id="pga-licenses"></svg>
<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/4.13.0/d3.min.js"></script>
<script src="/post/gld/chart.js"></script>
-->

go-license-detector was able to find licenses in 66.6% of the projects (confidence threshold 0.75).
It can be seen that the most widespread license is MIT (no surprise here), Apache is on the second place and GPL on the third. There is a [CSV file with raw numbers](/post/gld/pga-licenses.csv).

## Conclusion

[go-license-detector](https://github.com/src-d/go-license-detector) is a powerful
tool to detect the license of an open source project. It finds considerably
more matches than the others including the one used by GitHub. Detecting licenses
is much fun because of the many details and corner cases. Thanks to go-license-detector
we were able to find licenses in 66% of the most popular 182,000 GitHub repositories.