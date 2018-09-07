---
author: romain
date: 2018-09-15
title: "Deduplicating files in Public Git Archive"
image: /post/deduplicating_pga_with_apollo/smile.png
description: "We describe how we ran apollo on PGA, in order to find communities of duplicate files."
categories: ["science", "technical"]
draft: true
---


We [announced](../announcing-pga) the release of `Public Git Archive`,
a dataset with 3TB of Git data from the most starred repositories on GitHub, this summer.
Now it's time to tell how we tried to deduplicate files in the latest revision
of the repositories in PGA using our research project for code deduplication, [src-d/apollo](https://github.com/src-d/apollo). Before diving deep, let's quickly see why we created it.
To the best of our knowledge, the only efforts to detect code clones at massive scale have been 
by the authors of [DéjàVu project](http://mondego.ics.uci.edu/projects/dejavu/) by Lopes et.al., who 
leveraged a huge corpus of over 428 million files in 4 languages to map code clones on GitHub. They relied on syntactic features, i.e. identifiers (`my_list`, `your_list`, ...) and literals (`if`, `for`, ...), 
to compute the similarity between a pair of files. PGA has fewer files in the latest (HEAD) revision - 54 million, and we did not want to give our readers a *DéjàVu* by repeating the same analysis. So we aimed 
at something  different: not only copy-paste between files, but also 
the involuntary rewrites of the same abstractions. Thus we extracted and used semantic features 
from [Unified Abstract Syntax Trees](https://docs.sourced.tech/babelfish/uast/uast-specification).

## Moon shot 
 
apollo's deduplication pipeline is a 3-step process:

1. Extract [bags of features](http://www.cs.unc.edu/~lazebnik/spring09/lec18_bag_of_features.pdf) from each file and apply [TF-IDF](https://en.wikipedia.org/wiki/Tf%E2%80%93idf) to keep only the most relevant items (feature extraction step).
2. Hash those bags and produce the global pairwise similarity graph of the files
(Locality Sensitive Hashing](https://en.wikipedia.org/wiki/Locality-sensitive_hashing) step).
3. Detect the connected components in that graph and run community detection analysis on each component
(community detection step).

HEAD commits in `PGA` contain 54.5 million files spread across 181,481 projects. 
In order to extract semantic features from the files, we had 
to limit ourselves to the programming languages with a functional [Babelfish driver](https://docs.sourced.tech/babelfish/languages). This meant ≈26% of files,
those written in Python, Java, JavaScript, Ruby or Go.
Nevertheless, there were still 14.1 million files in our corpus. We extracted
the following features:

- **identifiers**, such as variable or function names.
- **literals**, e.g. integer or string constant values.
- **graphlets**, a feature being composed of the types of UAST node and it's children.
- **children**, a feature being composed of the node's type and it's [quantized](https://en.wikipedia.org/wiki/Quantization_(signal_processing)) 
number of children nodes.
- **uast2seq** - a sequence of UAST node types extracted with depth-first tree traversal of limited length.
- **node2vec** - a sequence of UAST node types produced from random walks in the tree.

The latter two features are not explicitly defined since they depend on several
hyperparameters: maximum length of a feature, maximum number of random walks, etc.
We used the maximum length to 3 and 4 for tree traversals and
to 2 and 3 for random walks (the output is combined).
The maximum number of random walks was 2 and the number of random steps was 10.
Those values hold a trade-off between the vocabulary size and the representativeness.

## Houston, we have a problem

Sadly, it turned out that extracting those features crashed our cluster many, *many* 
times. We faced several issues:

- Running Spark on [Siva files](https://github.com/src-d/go-siva)
through [jgit-spark-connector](https://github.com/src-d/jgit-spark-connector)
led to massive amount of temporary data during feature extraction on the worker 
pods of Kubernetes, which were further killed without notice by the cluster manager,
- While converting the data to [Parquet](http://parquet.apache.org/) format to avoid this, 
the workload imbalance due to [funny repos](https://github.com/Katee/git-bomb) made
individual tasks last insanely long.
- Once the conversion was done, applying TF-IDF to 1TB of cached data on disk
led Spark to spend more time on garbage collection then on the actual work.
- Finally, after we found a way to apply TF-IDF with manual batching (sic!),
Babelfish failed to parse a considerable amount of the files.

And that does not even take into account the continuous refactoring and bug detection
in `src-d/ml`, `src-d/jgit-spark-connector`, `src-d/apollo` that any young project
faces. We had to adapt rapidly to changes upstream.

Nevertheless, after months of big data war, we managed to overcome the challenges
and extract 6,194,874 distinct features from 7,869,917 million files, out of 102,114
projects. The sparsity of that huge matrix was 0.00017, the average number
of features per file was 1102. Not surprisingly, more than half of the processed files 
consisted of JavaScript and Java, roughly the same 
proportion as in the whole PGA. Overall, we were able to parse 45% to 67%
of files in each language.

|                       |  Python   |    Java   | Javascript |  Ruby   |    Go     |
|-----------------------|-----------|-----------|------------|---------|-----------|
| Files in PGA          | 1,673,172 | 4,021,258 | 5,549,381  | 909,935 | 1,962,502 |
| % of all PGA          | 2.47      | 5.93      | 8.18       | 1.34    | 2.89      |
| Processed             | 1,021,687 | 1,848,084 | 3,066,721  | 628,081 | 1,305,344 |
| Ratio processed/PGA, %| 61.06     | 45.95     | 55.26      | 69.02   | 66.51     |

{{% caption src="/post/deduplicating_pga_with_apollo/languages.png" %}}
Percent of files in each language in our corpus.
{{% /caption %}}

We observed that over 65% of distinct features were **literals** due high variance,
and apparently were relevant enough for most of the files to be retained. Similarly, 
due to the quantization, the number of distinct **children** features was 
minuscule compared to the rest.

|                 | identifiers | literals | graphlets | children | uast2seq | node2vec |
|-----------------|-------------|----------|-----------|----------|----------|----------|
| Ratio to all, % | 9.93        | 65.70    | 11.84     | 0.02     | 10.49    | 2.02     |

The average number of features per file seemed
roughly stable for all the considered languages. Features with the most semantic 
information, `uast2seq` and `node2vec`, had the highest count on average.
Note: their numbers depend on the chosen hyperparameters, see the previous section.

|              | identifiers | literals | graphlets | children | uast2seq | node2vec |
|--------------|-------------|----------|-----------|----------|----------|----------|
| Python       | 60.71       | 36.20    | 134.55    | 51.90    | 432.73   | 591.61   |
| Java         | 56.94       |  5.17    |  94.11    | 39.02    | 266.93   | 489.04   |
| Javascript   | 58.21       | 57.11    | 139.24    | 32.77    | 387.57   | 449.16   |
| Ruby         | 37.78       | 13.97    |  48.80    | 23.36    | 151.13   | 193.24   |
| Go           | 80.89       | 49.41    | 110.96    | 41.23    | 326.09   | 467.81   |
| All languages| 60.41       | 37.59    | 116.23    | 37.37    | 336.30   | 459.77   |

## Maneuvering

The rest of the apollo pipeline ran much smoother. Thanks to [MinhashCuda](https://github.com/src-d/minhashcuda)
the hashing stage took less then a day to finish. Our previous [blog post](../minhashcuda)
can provide more details about MinhashCuda. It particularly describes the
Locality Sensitive Hashing procedure in depth - the same that we employ for the deduplication.
In a few words, we scan the buckets of the hash tables and treat the files
in the same bucket as similar and those files form a clique.
Hence the computational complexity is linear.
See also [ekzhu/datasketch](https://ekzhu.github.io/datasketch/lsh.html).

We decided to use two similarity thresholds for the hashing process, a stricter 95% 
and looser 80%, the same the *DéjàVu* authors had used in `SourcersCC`. They yielded
the following results after the pairwise similarity graph was split into connected
components (CCs):

|                                      |       80% threshold        |         95% threshold        |
|--------------------------------------|----------------------------|------------------------------|
|Cliques count                         | 7,482,339                  | 7,732,877                    |
|CCs count                             | 3,473,933                  | 6,483,934                    |
|Count for CCs with 1 file             | 3,000,759 (38.13% of files)| 6,211,433 (78.93%  of files) |
|Count for CCs with >1 file            | 473,174 (61.87% of files)  | 1,496,749 (21.07% of files)  |
|Avg. files number per CC with >1 file | 10.29                      | 6.09                         |
|Maximum files number across all CCs   | 223,309                    | 6,839                        |

How do we interpret these results? If there were few exact clones, the number
of cliques would have been much lower, and the difference in those numbers
for the two thresholds would have been more than 3%.
Even though the histograms below show that the majority of the connected components
have a small number of files (distributed exponentially), the amount of 
duplication that entails in GitHub's most starred repositories is astonishing.

{{% caption src="/post/deduplicating_pga_with_apollo/hist.png" %}}
Log-log histograms of the number of distinct file names in CCs, at the 80% threshold (left)
and the 95% threshold (right).
{{% /caption %}}

Even though we did not differentiate files by programming language,
almost no CCs had multi-language files. The only exception is
very large CCs at 95% threshold. Java, Ruby and Python had similar 
levels of duplication. JavaScript duplication
dominated over the others, however, Go was also incredibly high. 
The latter two were definitely in the higher league, responsible together for 50%
of the CCs at 80% threshold and 80% CCs at 95% threshold. The likely
explanation to this is the established practice of embedding third-party
dependencies into the source tree.

{{% caption src="/post/deduplicating_pga_with_apollo/cc_per_languages.png" %}}
Percent of CCs of size bigger than 1 for each programming language, at 80%
(left) and 95% (right) thresholds.
{{% /caption %}}

|   | Java | Ruby | Python | Javascript | Go |
|---|--------|------|------------|------|----|
| % of files in CCs of size bigger than 1 (80%) |40.5%|47.4%|53.7%|70.1%|88%|
| % of files in CCs of size bigger than 1 (95%) | 2.3% | 7.1%| 8.9% | 25.5% | 53.4% |
| Average file count per CC of size bigger than 1 (80%) | 5.56 | 6.78 | 9.66 | 12.11 | 18.85 |
| Average file count per CC of size bigger than 1 (95%) | 2.85 | 3.63 | 4.21 | 5.61 | 8.33 |

We decided to calculate the ratio of the number of unique files and the total
number of files. The unique number is calculated by subtracting the sum of the
sizes of the connected components from the total.
That's our very rough estimation of the uniqueness in PGA.

|              | unique at 80%, %  |  unique at 95%, %  |
|--------------|-------------------|--------------------|
| Java         | 76                | 99                 |
| Ruby         | 73                | 97                 |
| Python       | 63                | 96                 |
| JavaScript   | 47                | 85                 |
| Go           | 24                | 65                 |
| All languages| 54                | 87                 |

## Landing

The final step of the apollo pipeline is the [community detection](https://arxiv.org/abs/1608.00163),
which gives us the sense of the number of non-similar files in our corpus.
Consider the [word ladder game](https://en.wikipedia.org/wiki/Word_ladder)
invented by Lewis Carroll which justifies coding for food:

```
CODE -> COLE -> COLD -> FOLD -> FOOD
```

The same way CCs with many files suffer from the "bridges" between densely
connected clusters of files. Community detection solves this problem nicely
assigning files to several clusters with different degree of confidence.
We decided to use the [igraph](http://igraph.org/python/)'s implementation of
the [Walktrap algorithm](https://www.nature.com/articles/srep30750)
since it runs reasonably fast and the quality is reasonably good on our data.
We had two ways to build the graphs on which to run the community detection:

- Include the artificial vertices which represent the buckets, files are
star-connected to the buckets they were hashed to.
- Directly connect each pair of files if they were hashed to the same bucket.

While the second method is ideal, it scales quadratically with the number 
of files in a bucket, whereas the first one scales linearly. Depending
on the chosen similarity threshold, the first method produces graphs with more
artificial nodes then the real ones. Therefore we go with
the first method at the 95% threshold (3 LSH tables) and with the second 
method at the 80% threshold (9 LSH tables, 3x more buckets).

At the 80% threshold, we could not detect communities in the following large CCs
because none of the algorithms which we tried ended within one day:

- 261,643 files, of all 5 languages  
- 123,807 files, all JavaScript
- 174,916 files, all Java
- 233,095 files, all Go

We detected 1,270,529 communities at 80% threshold and 671,936 at 95% threshold.

This post continues with the visualizations of some of the connected
components and the detected communities using [Gephy](https://gephi.org/).

## Soil probes

Of course, we would have to review each of the found groups of similar files
to ensure that they make sense, which we cannot do for two reasons:
there are too many files and the duplication criteria are subjective.

We manually labelled 2,000 pairs of Java files as almost the same, similar or
different using [🐈 src-d/code-annotation](https://github.com/src-d/code-annotation)
tool kindly developed by our Applications team. We sampled them in a special way
to cover all possible labels, the labeling process was tricky and funny and we will
certainly describe it in our next blog post. We further ran hyperparameter
optimization with [hyperopt](https://github.com/hyperopt/hyperopt) to determine
the feature weights, the optimal threshold and the rest of the variables.
But the found hyperparameters emulate the similarity criteria of our Machine Learning team
and are not necessary the best for everybody. They are also specific to 
~verbose and boring~ Java.

There is one metric however which is likely to be correlated with the similarity:
the average ratio of distinct filenames in the detected communities.
We believe that files named the same way probably do the same thing.
If you measure that ratio with brute force, you are going to face much noise which
ruins the whole idea. File names like `concatstring.js` and 
`concatstrings.js` or `syntax-update-20.rb` and `syntax-update-10.rb` should
not be considered distinct. So we applied [FuzzyWuzzy](https://github.com/seatgeek/fuzzywuzzy)
to the sets of file names per community using the minimum ratio parameter equal to 80.
The average ratio of distinct file names per group appeared to be below 0.1,
which is a clear indicator that our pipeline is indeed sensible.

{{% caption src="/post/deduplicating_pga_with_apollo/drop.png" %}}
Average ratio of distinct file names per file in communities depending on 
the minimum number of files, at the 80% (left)and the 95% (right) thresholds.  
{{% /caption %}}

### Embedded dependencies

{{% caption src="/post/deduplicating_pga_with_apollo/text_parser_go.png" %}}
Graph of the connected component with `text_parser.go` files described below, colored by community.
Buckets are colored in black, their size depends of the number of edges.
{{% /caption %}}

| files count | buckets count | edges count | distinct filenames count | projects count | communities count | threshold |
|-----------|---------------|-------------|--------------------------|----------------|-------------------|-----------|
| 422 | 371 | 1266 | 1 | 327 | 4 |  95% | 

This is just one of the 79,000 connected components with a single distinct Go file name
even without FuzzyWuzzy reduction. Quick investigation revealed that they probably
come from vendoring different versions of [protobuf](https://github.com/golang/protobuf).

**I see only two communities!!! - Vadim.**

### Versioning

{{% caption src="/post/deduplicating_pga_with_apollo/jquery.png" %}}
Graph of the connected component with jQuery files described below, colored by community.
Buckets are colored in black, their size depends of the number of edges.
{{% /caption %}}

| files count | buckets count | edges count | distinct filenames count | projects count | communities count | threshold |
|-----------|---------------|-------------|--------------------------|----------------|-------------------|-----------|
| 1532 | 644 | 4596 | 238  | 796 | 37|  95% | 


Not only did we notice that CCs tended to group files with matching names,
we also noticed that there were multiple CCs with variations of the same file name.
For example, we found 14 CCs with different blends of `jquery.js`, e.g. `jquery-1.7.1.min.js`.
Those CCs typically had a small number of communities for their size, however,
they clustered by file name to very limited extent.

### Are file names so important?

{{% caption src="/post/deduplicating_pga_with_apollo/filename_1.png" %}}
Graph of the connected component with Ruby files described below, colored by community.
Edges are colored depending on the vertices they link to.
{{% /caption %}}
{{% caption src="/post/deduplicating_pga_with_apollo/filename_2.png" %}}
Graph of the connected component with Ruby files described below,
colored by file name (see the legend). 
Files with rare (less than 1%) names are colored with grey.
{{% /caption %}}

| files count | edges count | distinct filenames count | projects count | communities count | threshold |
|-------------|-------------|--------------------------|----------------|-------------------|-----------|
| 2344        | 869,611     | 584                      | 1058           | 4                 |  80%      | 

This CC does not contain artificial vertices - buckets - because as we wrote in section "Landing"
the "all to all" graph builder method is used for the 80% threshold. The number of edges
relative to the number of vertices has exploded. In order to show that apollo didn't group
only identical files, the groups of vertices which share the same FuzzyWuzzy
file name are indicated on the graph. While vertices with the same name
often hashed to the same buckets, some didn't even end up in the same community.
Furthermore, communities tend to group files with distinct names, e.g. look at
the two largest communities in the graph.

### Large projects 

{{% caption src="/post/deduplicating_pga_with_apollo/azure.png" %}}
Graph of the connected component with Python files described below, colored by community.
Edges are colored depending on the vertices they link to.
{{% /caption %}}

| files count | edges count | distinct filenames count | projects count | communities count | threshold |
|-------------|-------------|--------------------------|----------------|-------------------|-----------|
| 4803        | 468,180     | 2954                     | 3              | 96                |  80%      | 

This illustrates another feature - CCs with many files from few projects.
Here the CC is composed of Python files stemming from
[Microsoft Azure SDK for Python](https://github.com/Azure/azure-sdk-for-python), 
with 23 files located in 2 other Azure projects (the CLI and the IoT SDK). 
Given the repetitive structure of the SDK, no surprise.

### Coding conventions

{{% caption src="/post/deduplicating_pga_with_apollo/google.png" %}}
Graph of the connected component with Java files described below, colored by community.
Edges are  colored depending on the vertices they link to.
{{% /caption %}}

| files count | edges count | distinct filenames count | projects count | communities count | threshold |
|-------------|-------------|--------------------------|----------------|-------------------|-----------|
| 6116        | 272,016     | 3964                     | 563            | 251               |  80%      | 


This is one of the 4 CCs which count together for 42% of all of the 
Java files in [GoogleAds java-lib](https://github.com/googleads/googleads-java-lib).
While the other three CCs generally correspond to the single project, our is more
diverse. However, the files are still clustered by project and by company.
The red community is made of the GoogleAds files (32% of all files),  
the light blue is from [AWS Java SDK](https://github.com/aws/aws-sdk-java)
and the yellow to the upper right is [AWS Android SDK](https://github.com/aws/aws-sdk-java) 
(the latter two are 23% of all files).
Green files are from [Plutext docx4j](https://github.com/plutext/docx4j) 
(6% of all files), mixed with [eBay's developer program projects](https://github.com/eBayDeveloper/eBay_APICall_CodeSamples)
(also 6%). The orange community is devoted to [YaviJava](https://github.com/yavijava/yavijava)
(4.5%), and the others represent a wide range of projects from Facebook, Paypal, Apache, etc.
There must be something deep in common for those codebases and   

## Data

All the data used to prepare this blog post is open and available for download.
Depending on whether you wish to repeat all the steps or run different
hashing or just look at the groups of similar files, you should download the
corresponding parts.

- the bags of features (~60GB), due to Scipy limitations on sparse matrices we had 
to split the bags into 3 separate parts: 1, 2, 3 [add links]
- the [connected components](https://github.com/src-d/apollo/blob/master/doc/model/cc.md)
(511MB at the 95% threshold and 627MB at the 80% threshold):
95% , 80% [add links]
- the [communities](https://github.com/src-d/apollo/blob/master/doc/model/cmd.md)
obtained with the walktrap algorithm (390MB at the 95% threshold and ?MB for the 
80% threshold): 95% , 80% [add links]
