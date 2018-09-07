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
those written in `Python`, `Java`, `JavaScript`, `Ruby` or `Go`.
Nevertheless, there were still 14.1 million files in our corpus. We extracted
the following features:

- **identifiers**, such as variable or function names.
- **literals**, e.g. integer or string constant values.
- **graphlets**, a feature being composed of the types of UAST node and it's children.
- **children**, a feature being composed of the node's type and it's [quantized](https://en.wikipedia.org/wiki/Quantization_(signal_processing)) 
number of children nodes.
- **uast2seq** - a sequence of UAST node types extracted with depth-first tree traversal of limited length.
- **node2vec** - a sequence of UAST node types produced from random walks in the tree.

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

   | Python | Java | Javascript | Ruby | Go |
---|--------|------|------------|------|----|
PGA files number|1,673,172|4,021,258|5,549,381|909,935|1,962,502|
% of PGA files|2.47|5.93|8.18|1.34|2.89|
processed files number|1,021,687|1,848,084|3,066,721|628,081|1,305,344|
processed %|61.06|45.95|55.26|69.02|66.51|

{{% caption src="/post/deduplicating_pga_with_apollo/languages.png" %}}
Percentage of files in each language in our corpus.
{{% /caption %}}

We discovered that over 65% of distinct features were **literals** due high variance,
and apparently were relevant enough for most of the files to be retained. Similarly, 
due to the quantization, the number of distinct **children** features was 
minuscule compared to the rest. The average number of features per file seemed
roughly stable for all the considered languages. The features with the most semantic 
information, `uast2seq` and `node2vec`, had the highest count on average:


   | identifiers | literals | graphlets | children | uast2seq | node2vec |
---|-------------|----------|-----------|----------|----------|----------|
Percentage of all features|9.93|65.7|11.84|0.02|10.49|2.02|
Average count cross-language|60.41|37.59|116.23|37.37|336.30|459.77|
Average count for Python files| 60.71|36.20|134.55|51.90|432.73|591.61|
Average count for Java files|56.94|5.17|94.11|39.02|266.93|489.04|
Average count for Javascript files|58.21|57.11|139.24|32.77|387.57|449.16|
Average count for Ruby files|37.78|13.97|48.80|23.36|151.13|193.24|
Average count for Go files|80.89|49.41|110.96|41.23|326.09|467.81|

## Maneuvering

The rest of the apollo pipeline ran much smoother. Thanks to [MinhashCuda](https://github.com/src-d/minhashcuda)
the hashing took less then a day to finish. More details about MinhashCuda
are in our previous [blog post](../minhashcuda). That post describes the
Locality Sensitive Hashing procedure in depth - the same as in our deduplication
process. We basically scan the buckets of the hash tables and treat the files
in the same bucket as similar and those files form a clique.
Hence the computational complexity is linear.
See also [ekzhu/datasketch](https://ekzhu.github.io/datasketch/lsh.html).

We decided to use two similarity thresholds for the hashing process, a stricter 95% 
and looser 80%, the same the *DéjàVu* authors had used in `SourcersCC`. They yielded
the following results after the pairwise similarity graph was split into connected
components (CCs):

|   | 80% threshold | 95% threshold |
|---|----------------|----------------|
|Cliques count|7,482,339|7,732,877|
|CCs count|3,473,933|6,483,934|
|Count for CCs of 1 file|3,000,759 (38.13% of files)|6,211,433 (78.93%  of files)|
|Count for CCs of over 1 file|473,174 (61.87% of files)|1,496,749 (21.07% of files)|
|Average file count per CC of over 1 file |10.29|6.09|
|Maximum file count across all CCs |223,309|6,839|

How do we interpret these results? If there were few exact clones, the number
of cliques would have been much lower, and the difference in those numbers
for the two thresholds would have been more than 3%.
Even though the histograms below show that the majority of the connected components
have a small number of files (distributed exponentially), the amount of 
duplication that entails in GitHub's most starred repositories is astonishing.

{{% caption src="/post/deduplicating_pga_with_apollo/hist.png" %}}
Log-log histograms of the number of distinct file names in CCs, for the 80% threshold (left)
and the 95% threshold (right).
{{% /caption %}}

Even though we did not differentiate files by programming language,
almost no CCs had multi-language files. The only exception is
very large CCs at 95% threshold. `Java`, `Ruby` and `Python` had similar 
levels of duplication. `JavaScript` duplication
dominated over the others, however, `Go` was also incredibly high. 
The latter two were definitely in the higher league, responsible together for 50%
of the CCs at 80% threshold and 80% CCs at 95% threshold.

{{% caption src="/post/deduplicating_pga_with_apollo/cc_per_languages.png" %}}
Percentage of CCs of size bigger than 1 for each programming language, at 80%
(left) and 95% (right) thresholds.
{{% /caption %}}

   | Java | Ruby | Python | Javascript | Go |
---|--------|------|------------|------|----|
% of files in CCs of size bigger than 1 (80%) |40.5%|47.4%|53.7%|70.1%|88%|
% of files in CCs of size bigger than 1 (95%) | 2.3% | 7.1%| 8.9% | 25.5% | 53.4% |
Average file count per CC of size bigger than 1 (80%) | 5.56 | 6.78 | 9.66 | 12.11 | 18.85 |
Average file count per CC of size bigger than 1 (95%) | 2.85 | 3.63 | 4.21 | 5.61 | 8.33 |

We decided to calculate the ratio of the sum of sizes of CCs and of the total
number of files. That's our very rough estimation of the duplication in PGA.

>>> TODO: turn this into what we have just written: non-duplicate -> duplicate by subtracting from 100%

   | 80% threshold | 95% threshold |
---|----------------|----------------|
% of non-duplicate files, all languages|54%|87%|
% of non-duplicate Java files | 76%|99%|
% of non-duplicate Ruby files |73%|97%|
% of non-duplicate Python files |63%|96%|
% of non-duplicate JavaScript files |47%|85%|
% of non-duplicate Go files |24%|65%|

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
of files in a bucket, whereas the first scales linearly. We chose the first
method because some buckets contained thousands of files.

At 80% threshold, we could not detect communities in the following large CCs
because none of the algorithms which we tried have ended:

- 261,643 files, of all 5 languages  
- 123,807 files, all JavaScript
- 174,916 files, all Java
- 233,095 files, all Go

There appeared to be 1,270,529 communities at 80% threshold and 671,936 at
95% threshold.

We used [Gephy](https://gephi.org/) to visualize some of the connected 
components and the detected communities. It turns out the
**first method - what first method? - Vadim** was more 
representative of the similarities apollo detected between two files, however depending 
on the number of hashtables, i.e. of the chosen similarity threshold, it could result 
in graphs with more artificial nodes then real ones. Consequently we decided to use 
the first method for the 95% threshold, which had only 3 hashtables, and the second 
method for the 80% threshold, *which had 9* (we ran the community detection a second 
time on the CCs we chose). Given the number of connected components we could not 
showcase them all, so we decided to select a few we felt were representative of
 our results... 

## Soil probes

Of course, we would have to review each of the groups of similar files we found
to ensure that they make sense, which we cannot do for two reasons:
there are too many files and the duplication criteria are subjective.

>>> Notice about labelling the pairs of files and that we will write another
>>> post about hyperoptimization. Also that it is time consuming for each language
>>> and we used the weights from optimization for Java (or not).

There is one metric however which is correlated: the average ratio of distinct filenames 
in CCs. One could imagine that files named the same way would likely 
aim at doing the same thing, and be similar. At first however, that seemed to not 
be the case as we saw a lot of noise when looking at the ratio of distinct filenames 
per files in CCs. We quickly understood why: filenames like `concatstring.js` and 
`concatstrings.js`, or `syntax-update-20.ru` and `syntax-update-10.ru` were considered 
distinct, even though the files were most likely similar. To circumvent this, we 
used [FuzzyWuzzy](https://github.com/seatgeek/fuzzywuzzy) to deduplicate the sets 
of filenames, using a minimum ratio of 80. We found that past a certain size, the 
average ratio of distinct filenames per file stagnated below 0.1, given us a clear 
indication that the connected components indeed contained files with similar filenames, 
without having been able to infer it from anything else but their features.

{{% caption src="/post/deduplicating_pga_with_apollo/drop.png" %}}
Average ratio of distinct filenames per file in CCs (of over 1 files) depending on 
the minimum number of files, for the 80% threshold (left) and the 95% threshold (right)  
{{% /caption %}}

### D.R.Y. Gophers

{{% caption src="/post/deduplicating_pga_with_apollo/text_parser_go.png" %}}
Graph of the CC of Go files described below, colored by community. Buckets are colored in black,
their size depends of their edge count.
{{% /caption %}}

file count | buckets count | edges count | distinct filenames count | projects count | communities count | threshold |
-----------|---------------|-------------|--------------------------|----------------|-------------------|-----------|
422 | 371 | 1266 | 1 (`text_parser.go`) | 327 | 4 |  95% | 

We thought we'd start off with a relatively small graph. As we mentioned earlier, 
there seems to be a lot of ... borrowing in the Go community - and this is just 
one of the 79k connected component with only **one** distinct Go filename (*without* 
filename deduplication).

### Versioning

{{% caption src="/post/deduplicating_pga_with_apollo/jquery.png" %}}
Graph of the CC of JavaScript files described below, colored by community. Buckets are colored in black,
their size depends of their edge count.
{{% /caption %}}

file count | buckets count | edges count | distinct filenames count | projects count | communities count | threshold |
-----------|---------------|-------------|--------------------------|----------------|-------------------|-----------|
1532 | 644 | 4596 | 238  | 796 | 37|  95% | 


Now, not only did we notice that CCs tended to group up files with nearly the exact same 
filename, we also noticed that for some specific filenames there were multiple CCs grouping files
with a variation of that filename. For example, we found 14 CCs were the most common
filename was some variation of `jquery.js`, like `jquery-1.7.1.min.js`. These CCs 
usually had some of the smaller number of communities for their size, as could 
be predicted - however they only clustered by filename to a limited extent.

### Grouping by filename ?

{{% caption src="/post/deduplicating_pga_with_apollo/filename_1.png" %}}
Graph of the CC of Ruby files described below, colored by community. Edges are 
colored depending on the vertices they link, possibly a mix of two.
{{% /caption %}}
{{% caption src="/post/deduplicating_pga_with_apollo/filename_2.png" %}}
Graph of the CC of Ruby files described below, colored by filename (see legend). 
Files with names appearing in less then 1% of vertices are colored in grey. Edges are 
colored as above.
{{% /caption %}}

file count | edges count | distinct filenames count | projects count | communities count | threshold |
-----------|-------------|--------------------------|----------------|-------------------|-----------|
2344 | 869,611 | 584  | 1058 | 4 |  80% | 

This CC is the first obtained for the second threshold, thus plotted without artificial
vertices - and as you can see the number of edges relative to the number
of vertices has exploded. In order to show that `apollo` didn't only group seemingly
copy-paste files, we not only plotted the communities, but also the groups of vertices 
sharing a filename. As you can see, while vertices sharing a name seem to have
hashed more often to the same buckets, that was not necessarily the case, and
for some they didn't even end up in the same community. Furthermore, communities
tend to group up files with distinct filename ore often then not, e.g. the two 
largest communities in the graph.
 
*To see the fourth community, squint hard at the last node on the right, you'll see it's
green not blue ...* 

### Large projects 

{{% caption src="/post/deduplicating_pga_with_apollo/azure.png" %}}
Graph of the CC of Python files described below, colored by community. Edges are 
colored depending on the vertices they link, possibly a mix of two.
{{% /caption %}}

file count | edges count | distinct filenames count | projects count | communities count | threshold |
-----------|-------------|--------------------------|----------------|-------------------|-----------|
4803 | 468,180 | 2954  | 3 | 96|  80% | 


This next CC represents another trend we saw appear, namely CCs with many files 
from a very restrained number of projects. In this case, it is composed of 
`Python` files almost exclusively stemming from `WindowsAzure`'s SDK for Python, 
with 23 files located in 2 other Azure projects (the CLI and the IoT SDK). To be fair, 
we went take a look at the main project, and given it's structure we were not surprised 
there would be al lot of duplication ...

### Coding conventions

{{% caption src="/post/deduplicating_pga_with_apollo/googleads.png" %}}
Graph of the CC of Java files described below, colored by community. Edges are 
colored depending on the vertices they link, possibly a mix of two.
{{% /caption %}}

file count | edges count | distinct filenames count | projects count | communities count | threshold |
-----------|-------------|--------------------------|----------------|-------------------|-----------|
6116 | 272,016 | 3964  | 563 | 251|  80% | 


Perhaps another answer might be that coding conventions used in big projects, i.e. by 
important tech firms, might have prompted these levels of duplication.
Case and point, this CC, one of 4 which put together grouped about 42% of all of the 
Java files in GoogleAds' [java-lib project](https://github.com/googleads/googleads-java-lib).
Now, while in 2 of the CCs we had a situation like the previous one, and in the third
about 60% of files were also from this project, this CC was a bit different as it 
was much more diverse. *However*, it turned out that files still clustered by projects
- and companies. The red community is made of the GoogleAds files (32% of this CC's files),  
the light blue files are from AWS's [Java SDK project](https://github.com/aws/aws-sdk-java), 
and right above in yellow files from their [Android SDK project](https://github.com/aws/aws-sdk-java) 
(together 23% of files). In green there are files from Plutext's [docx4j project](https://github.com/plutext/docx4j) 
(6% of files), grouped up with one of eBay's [developer program projects](https://github.com/eBayDeveloper/eBay_APICall_CodeSamples)
(also 6%). Finally, the orange community is mostly made up of files from [YaviJava](https://github.com/yavijava/yavijava)
(4.5% of files), the other communities being of a wide range of projects (among 
which we spotted Facebook, Paypal, Apache ...). Could it be that the amount developers
hopping from one big tech firm to another cause some sort of convergence of coding
conventions ?  


We published the our data using [modelforge](https://github.com/src-d/modelforge/)
`Models`, for those wishing to experiment with apollo - or just use them as features
for some other project:

- the bags of features (~60GB), due to Scipy limitations on sparse matrices we had 
to split the bags in 3 separate parts: 1, 2 ,3 [add links]
- the [connected components](https://github.com/src-d/apollo/blob/master/doc/model/cc.md)
(511MB for the 95% threshold and 627MB for the 80% threshold):
95% , 80% [add links]
- the [communities](https://github.com/src-d/apollo/blob/master/doc/model/cmd.md)
obtained with the walktrap algorithm (390MB for the 95% threshold and ?MB for the 
80% threshold): 95% , 80% [add links]
