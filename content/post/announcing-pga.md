---
author: campoy
date: 2018-06-05
title: "Announcing Public Git Archive"
image: /post/announcing-pga/pga.png
description: "Announcing Public Git Archive, the largest git repositories dataset in the world."
categories: ["technical", "MLonCode"]
---

Last week we had the honor of participating at [MSR'18](https://2018.msrconf.org/),
where two of the members of our team, [Vadim Markovtsev](https://twitter.com/vadimlearning)
and [Waren Long](https://twitter.com/warenlg), presented the
[research paper](https://arxiv.org/abs/1803.10144) they wrote on our latest dataset:
`Public Git Archive`.

`Public Git Archive` is the result of months of effort curating a dataset suitable for
training Machine Learning on Source Code (aka MLonCode) models.

## Dataset Contents

The dataset contains 3TB of repositories from GitHub ready to download.
This includes all of the contents (git metadata and file contents) for all of the repositories
on GitHub with 50 or more stars.
The list of repositories was obtained from [the GHTorrent project](http://ghtorrent.org/),
which provides information about GitHub repositories but unfortunately doesn't include the file contents.

### Rooted Repositories

To avoid unnecessary repeated files we unified all of the repositories by merging all of the
git trees which contained a common root, according to their commit hashes.
There is still file repetition when two or more repositories contain copies of a single file,
but have no common root.

The figure below shows visually two repositories being merged into a single one, or rooted.

![rooted repositories](/post/announcing-pga/rooted-repos.png)

Just to give you an idea of the size of the dataset, let's compare it to previous
datasets:

 _  |  Qualitas Corpus  |  Sourcerer  |  GitHub Java Corpus  |  Public Git Archive  |
---|-------------------|-------------|----------------------|----------------------|
N projects | 111 | 19,233 | 14,807 | 182,014 |
Year of release | 2013 | 2014 | 2013 | 2018 |
Languages | 1 (Java) | 1 (Java) | 1 (Java) | 455 |
Repeatable | No | No | No | Yes |
N files | 177k | 1.9M | 1.5M | 54.5M (HEAD) |
Lines of Code | 37M | 320M | 352M | 15,941M (HEAD) |
Storage Size | 1.3GB | 19GB | 14GB | 3.0TB |

And since an image is worth a thousand tables, here you can see the size of Public Git Archive
compared to other datasets. _Note that the scale is logarithmic!_

![size of datasets](/post/announcing-pga/size.png)

Similarly, the number of lines of code show the size of Public Git Archive.

![lines of code of datasets](/post/announcing-pga/loc.png)

## Public Git Archive Schema

Public Git Archive provides an index file with information that can be used to select which parts
of the dataset one might want to download. This includes:

- repository URL,
- name of the [siva](https://github.com/src-d/siva) with the repository contents
- number of total files, lines of code, and bytes,
- number of total commits and commits in the HEAD path to the root,
- list of languages detect in the repository with [enry](https://github.com/src-d/enry),
- license detected in the repository with [go-license-detector](https://github.com/src-d/go-license-detector).

You can find the [documented schema](https://pga.sourced.tech/) of the dataset on GitHub.

## Download it now!

You can download [the index file](http://pga.sourced.tech/csv/latest.csv.gz), find the `siva`
files corresponding to the repositories of your interested, and download one by one.

To make this task easier we've also released a tool that we call `pga`. `pga` is able to filter
and download sections of the datasets with an easy command line interface.
You can download it from [the releases page at github.com/src-d/datasets](https://github.com/src-d/datasets/releases).
Alternatively, if you already have Go installed on your machine, you can simply run
`go get github.com/src-d/datasets/PublicGitArchive/pga`.

Once installed listing all of the repositories in the dataset is as simple as running `pga list`.
To list only repositories that contained some Java:

```bash
▶️ pga list -l java
https://github.com/karlisson/1001
https://github.com/thiagolocatelli/android-uitableview
https://github.com/JakeWharton/Android-ViewPagerIndicator
...
```

, or to show only the repositories under the `src-d` organization:

```bash
▶️ pga list -u /src-d/
https://github.com/src-d/beanstool
https://github.com/src-d/kmcuda
https://github.com/src-d/hercules
...
```

To download the data, rather than just listing the repositories, replace `list` with `get`.

Finally, you can also use `pga` to present the index in different formats, such as `CSV` or `JSON`:

This can be useful when a more complex filter of the index is necessary.
For instance, if you wanted to download all of the source{d} repositories with Apache v2 licenses,
you can run the following command:

```bash
▶️ pga list -u /src-d/ -f json | grep "Apache-2.0" | jq -r ".sivaFilenames[]" | pga get -i
downloading siva files by name from stdin
filter flags will be ignored
 0 / 5 [------------------------------------------------------]   0.00%
```

We first list all of the source{d} repositories as JSON, grep those using Apache v2 licenses,
then use [jq](https://stedolan.github.io/jq/) to extract the corresponding filenames, and download them with `pga get -i`.

## License

`Public Git Dataset` is available under the
[Open Database License (ODBL)](https://opendatacommons.org/licenses/odbl/),
but we'd love to hear if you decide to use it. You can get in touch with us via email to
devrel@sourced.tech or joining our Slack community following the instructions below.
