---
author: romain
date: 2018-09-15
title: "Deduplicating files in Public Git Archive"
image: /post/deduplicating_pga_with_apollo/smile2.png
description: "We describe how we ran Apollo on PGA, in order to find communities of duplicate files."
categories: ["science", "technical"]
draft: true
---


We [announced](../announcing-pga) at the beginning of this summer the release of
`Public Git Archive`, a dataset containing 3TB of files from GitHub's most 
starred repositories. Now, we'll describe how we tried to deduplicate 
it using our research project for code deduplication, [src-d/apollo](https://github.com/src-d/apollo).
Before diving into how we did it, let's quickly look at why. To the best of our 
knowledge, the only efforts to detect code clones at massive scale have been 
from the authors of [DéjàVu](http://mondego.ics.uci.edu/projects/dejavu/), who 
leveraged a huge corpus of over 428 million files in 4 languages to create a 
map of code clones on GitHub. To do so, they relied on syntactical features 
i.e. identifiers (`my_list`, `your_list`, ...) and literals (`if`, `for`, ...), 
to compute file similarity. PGA has fewer files in the HEAD revision, and we did 
not want to give our readers a *DéjàVu* by repeating the same analysis. So we aimed 
at something  different: not only the detection of copy-paste between files, but also 
involuntary rewriting of the same abstractions. Thus we extracted and used semantic features 
from [UASTs](https://docs.sourced.tech/babelfish/uast/uast-specification).

## Moon shot 
 
Apollo's pipeline is a 4 step process: extract from each file [bags of features](http://www.cs.unc.edu/~lazebnik/spring09/lec18_bag_of_features.pdf)
and apply TFIDF to keep only the most relevant, hash them to get a pairwise similarity 
graph of all the files, detect it's connected components, and then do community 
analysis on each component. At the time we started working on this project, the 
head commits of `PGA` consisted of 67.8 million files, spread across 181,481 projects. 
In order for us to be able to extract semantic features from the files, we had 
to limit ourselves to those written in a language with a functioning [bblfsh driver](https://docs.sourced.tech/babelfish/languages)
in oerder to parse the AST of the files and convert them in UASTs. This meant restricting
ourselves to ~21% of files, those written in `Python`, `Java`, `JavaScript`, `Ruby`
or `Go`. Nevertheless this still meant using 14.1 million files of our corpus, 
from which we'd extract the following features:

- **identifiers**, a feature being a variable or function name;
- **literals**, a feature being a syntactical element of the language;
- **graphlets**, a feature being composed of a UAST node and it's children;
- **children**, a feature being composed of the node's type and it's [quantized](https://en.wikipedia.org/wiki/Quantization_(signal_processing)) 
number of children nodes;
- **uast2seq**, a feature being a sequence of UAST nodes extracted using DFS;
- **node2vec**, a feature being a sequence of UAST nodes produced through random walks.

## Houston, we've got a problem

Sadly, it turned out that trying to do this made our cluster crash many, *many* 
times. We faced a number of issues:

- using Spark with data that was stored in [Siva files](https://github.com/src-d/go-siva)
led to massive amount of temporary data when extracting features on the worker 
pods, which were then killed without notice by the kubernetes cluster manager,
- while converting the data to the distributable Parquet format to avoid this, 
data skew in the corpus due to [fun repos](https://github.com/Katee/git-bomb) made
individual tasks insanely long,
- once the conversion was done, our cluster crashed *again*, because applying 
TFIDF on 1TB of data cached on disk made Spark spend more time on garbage collection 
then actual work,
- and finally, after we found a way to apply TFIDF on smaller loads, bblfsh turned 
out to not being able to parse am important amount of the files,

And that's not even taking into account the continuous refactoring and bug detection
in `src-d/ml`, `src-d/engine`, `src-d/apollo` that any growing repository must face
and to which we had to adapt.

Nevertheless, after months of effort, we finally were able to overcome this first step
and extract 6,194,874 distinct features from 7,869,917 millions files, out of 102,114
projects. Now, the sparsity of this huge matrix being .00017, the average number
of features per file turned out to be 1102. Unsurprisingly, over half of our corpus 
ended up consisting of JavaScript and Java files, more or less keeping the same 
proportions that can be found in the whole of `PGA`, as we were able to get 45 % 
to 67 % of files for each language.

   | Python | Java | Javascript | Ruby | Go |
---|--------|------|------------|------|----|
File count in PGA|1,673,172|4,021,258|5,549,381|909,935|1,962,502|
% of PGA files|2.47 %|5.93 %|8.18 %|1.34 %|2.89 %|
Processed files count|1,021,687|1,848,084|3,066,721|628,081|1,305,344|
% of processable files|61.06 %|45.95 %|55.26 %|69.02 %|66.51 %|


![image](/post/deduplicating_pga_with_apollo/languages.jpg)


Looking more into the feature side, we found over 65% of distinct features were 
`literals`, due the fact that these features were distinct for each language, and 
apparently were relevant enough for most of them to be retained. Similarly, 
due to the quantization the number of distinct `children` features turned out 
minuscule compared to the rest. As can be seen below these variations did not impact
much the average number of features per file, which seemed relatively stable for 
all languages. Interestingly, the features holding in our view the most semantic 
information, `uast2seq` and `node2vec`, were on average the ones with the highest 
count of the 6 features:


   | identifiers | literals | graphlets | children | uast2seq | node2vec |
---|-------------|----------|-----------|----------|----------|----------|
Percentage of all features|9.93 %|65.7 %|11.84 %|0.02 %|10.49 %|2.02 %|
Average count cross-language|60.41|37.59|116.23|37.37|336.30|459.77|
Average count for Python files| 60.71|36.20|134.55|51.90|432.73|591.61|
Average count for Java files|56.94|5.17|94.11|39.02|266.93|489.04|
Average count for Javascript files|58.21|57.11|139.24|32.77|387.57|449.16|
Average count for Ruby files|37.78|13.97|48.80|23.36|151.13|193.24|
Average count for Go files|80.89|49.41|110.96|41.23|326.09|467.81|


## Landing

We then went one to run the rest of the apollo pipeline, with much less difficulties
then we'd encountered previously. Thanks to [MinhashCuda](https://github.com/src-d/minhashcuda)
the hashing took less then a day to run. For more details on why that was the case 
we highly recommend the read of this previously released [article](minhashcuda.md),
as it also describes in depth the rest of the `apollo` deduplication process.

We decided to use two similarity thresholds for the hashing process, a stricter 95 % 
and 80 %, the same the *DéjàVu* authors had used with `SourcersCC`. This gave us 
the following results after the pairwise similarity graph was split in connected
components (CCs):

|   | 80 % threshold | 95 % threshold |
|---|----------------|----------------|
|Cliques count|7,482,339|7,732,877|
|CCs count|3,473,933|6,483,934|
|Count for CCs of 1 file|3,000,759 (38.13 % of files)|6,211,433 (78.93 %  of files)|
|Count for CCs of over 1 file|473,174 (61.87 % of files)|1,496,749 (21.07 % of files)|
|Average file count per CC of over 1 file |10.29|6.09|
|Maximum file count across all CCs |223,309|6,839|

Now, *how do we interpret these results* ? Well, it seems that in the subset of 
PGA we analyzed, it is probable that there are very few exact clones. If that 
had been the case, the number of cliques, i.e. of groups of files hashing to the 
exact same hashes, would have been much lower - and the decrease much more then 
350k between the two thresholds. Even though the histograms below show that for 
both thresholds most of the connected components have a small number of file, as 
their number decreases exponentially with the number of files, the amount of 
duplication this entails in GitHub's most starred repositories is astonishing.

![nb of files per cc](/post/deduplicating_pga_with_apollo/hist.jpg)

Even though we'd applied all our pipeline on all files, without separating by language,
it turned out virtually no CC had files of more then one language, exceptions being
very large CCs for the second threshold. Consequently we thought it would make sense
to look at each language separately, as we expected to see some variations, depending
on the kind of language. While `Java`,  `Ruby` and `Python` seemingly had similar 
levels of duplication, the results for `JavaScript` and especially `Go` were in
a whole other league, as together they made up for 50% of CCs of non single files 
for the 80% threshold, and 80% for the 95% threshold. Considering the corpus size 
of `JavaScript` files relative to the others, and also the kind of language it was, 
we expected it to dominate as it did, however the amount of duplication we found 
for `Go` was incredibly high, especially for the 95% threshold. 

![cc_per_languages](/post/deduplicating_pga_with_apollo/cc_per_languages.jpg)


   | Java | Ruby | Python | Javascript | Go |
---|--------|------|------------|------|----|
% of files in CCs of over 1 file (80 %) |40.5%|47.4%|53.7%|70.1%|88%|
% of files in CCs of over 1 file  (95 %) | 2.3% | 7.1%| 8.9% | 25.5% | 53.4% |
Average file count per CC of over 1 file (80 %) | 5.56 | 6.78 | 9.66 | 12.11 | 18.85 |
Average file count per CC of over 1 file (95 %) | 2.85 | 3.63 | 4.21 | 5.61 | 8.33 |


Of course, to check that the CCs truly consisted of similar files we would have 
to review each of them, a daunting task, as we currently have no accurate way of 
estimating their quality. However one metric that we thought would give us some 
sense of the validity of our results was the average ratio of distinct filenames 
per files in CCs, as one could imagine that files named the same way would likely 
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

![drop](/post/deduplicating_pga_with_apollo/drop.jpg)

The final step of Apollo was [community detection](https://arxiv.org/abs/1608.00163),
which would give us a sense of the number of non-similar files in our corpus. We 
decided to use igraph's implementation of the Walktrap algorithm to detect communities 
in the CCs. While this might not be the most suitable, as said previously we do
not have a way to know which would be, and according to the [literature](https://www.nature.com/articles/srep30750) 
it seemed to be a good compromise between speed and efficiency. We had two possibilities 
to create the graphs on which to community detection would be applied:


- include artificial vertices representing the buckets, in which case files would
only be connected to the buckets they hashed to, and similar buckets would be connected 
to each other;
- or replace those buckets with edges, directly connecting files if they hashed 
to the same bucket.

While the second method would have been ideal, it scaled quadratically with the number 
of buckets, whereas the first scaled linearly, hence we chose the first. This meant
we took the risk of creating communities of only artificial vertices, which we had 
to weed out. We then decided to calculate a pseudo *percentage of non-duplicate files*, 
the ratio of the sum of individual CCs and communities, and of the total number of files.
Of course, taking this at face value would be awesome if correct, but in practise 
very unreasonable. One can easily find flaws in our work, as we indicated earlier
we have close to no way to evaluate it, let alone optimise it, should have eran the
pipeline on separate languages instead of mixing them up ... Nevertheless, we do 
think it is close to representing the reality, at least for our dataset, which is 
why we included it. 

**For the 80 % threshold, we don't have communities for the 4 largest CCs - none
of the community detection we tried have ended: ** 

First CC: 261643 files, of all 5 languages  
Second CC: 123807 files, all JS
Third CC: 174916 files, all Java
Fourth CC: 233095 files, all Go

This means % should be higher, depending how much communities there are.

   | 80 % threshold | 95 % threshold |
---|----------------|----------------|
Number of communities|1,270,529|671,936|
% of non-duplicate files cross-language|54%|87 %|
% of non-duplicate Java files | 76 %|99 %|
% of non-duplicate Ruby files |73 %|97 %|
% of non-duplicate Python files |63 %|96 %|
% of non-duplicate JavaScript files |47 %|85 %|
% of non-duplicate Go files |24 %|65 %|

Finally, we used [Gephy](https://gephi.org/) to visualize some of the connected 
components and detected communities. It turns out the first method was more 
representative of the similarities Apollo detected between two files, however depending 
on the number of hashtables, i.e. of the chosen similarity threshold, it could result 
in graphs with more artificial nodes then real ones. Consequently we decided to use 
the first method for the 95% threshold, which had only 3 hashtables, and the second 
method for the 80% threshold, *which had 9* (we ran the community detection a second 
time on the CCs we chose). Given the number of connected components we could not 
showcase them all, so we decided to select a few we felt were representative of
 our results... 

*We systematically colored the buckets in black for the first method.*

### D.R.Y. Gophers

![drop](/post/deduplicating_pga_with_apollo/text_parser_go.png)

file count | buckets count | edges count | distinct filenames count | projects count | communities count | threshold |
-----------|---------------|-------------|--------------------------|----------------|-------------------|-----------|
422 | 371 | 1266 | 1 (`text_parser.go`) | 327 | 4 |  95 % | 

We thought we'd start off with a relatively small graph. As we mentioned earlier, 
there seems to be a lot of ... borrowing in the Go community - and this is just 
one of the 79k connected component with only **one** distinct Go filename (*without* 
filename deduplication).

### Similar files

![jq](/post/deduplicating_pga_with_apollo/jquery.png)


file count | buckets count | edges count | distinct filenames count | projects count | communities count | threshold |
-----------|---------------|-------------|--------------------------|----------------|-------------------|-----------|
1532 | 644 | 4596 | 238  | 796 | 37|  95 % | 


Now, not only did we notice that CCs tended to group up files with similar feilenames,
we also noticed that for some specific filenames there were multiple CCs grouping files
with a variation of that filename. For example, we found 14 CCs were the most common
filename was some variation of `jquery.js`, or some variation like `jquery-1.7.1.min.js`.
These CCs usually had some of the smaller number of communities for their size, as could
be predicted - however they only clustered by filename to a limited extent.

### Large projects 

![azure](/post/deduplicating_pga_with_apollo/azure.png)


file count | edges count | distinct filenames count | projects count | communities count | threshold |
-----------|-------------|--------------------------|----------------|-------------------|-----------|
4803 | 468,180 | 2954  | 3 | 96|  80 % | 


This CC is the first obtained for the second threshold, hence the first plotted 
with the second method - and as you can see the number of edges relative to the number
of vertices has exploded. The reason we chose this CC is because it represents 
another trend we saw appear, namely CCs with many files from a very restrained number of 
projects. In this case, the CC is composed of `Python` files almost exclusively 
stemming from `WindowsAzure`'s SDK for Python, with 23 files located in 2 other 
Azure projects (the CLI and the IoT SDK). To be fair, we went take a look at the main
project, and given it's structure we were not surprised there would be al lot of 
duplication ...

### Coding conventions

![ads](/post/deduplicating_pga_with_apollo/googleads.png)


file count | edges count | distinct filenames count | projects count | communities count | threshold |
-----------|-------------|--------------------------|----------------|-------------------|-----------|
6116 | 272,016 | 3964  | 563 | 251|  80 % | 


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
(6 % of files), grouped up with one of eBay's [developer program projects](https://github.com/eBayDeveloper/eBay_APICall_CodeSamples)
(also 6 %). Finally, the orange community is mostly made up of files from [YaviJava](https://github.com/yavijava/yavijava)
(4.5 % of files), the other communities being of a wide range of projects (among 
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
