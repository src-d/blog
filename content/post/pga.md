---
author: vadim
date: 2018-04-10
title: "Public Git Archive"
image: /post/pga/logo.png
description: "We have released a large dataset for MLonCode - Public Git Archive (PGA). It contains 182,000 top-starred repositories on GitHub and takes 3 TB of disk space. The paper which describes it was accepted
to Mining Software Repositories conference. This post tells the PGA's story."
categories: ["science", "technical"]
---

[![logo](/post/pga/logo.svg#left)
Dataset landing](https://github.com/src-d/datasets/PublicGitArchive)

## Usage

TODO: Francesc, you rock here, please give a gig

## Origins

We've wanted to release all the Git repositories we are able to clone since source{d}'s beginning. Back in 2016 we stored millions of Git [packfiles](https://git-scm.com/book/en/v2/Git-Internals-Packfiles) in Google Cloud Storage and the metadata in MongoDB. It worked well for us but that scheme did not allow to share the data. Then we decided to go baremetal in 2017 and started to build our infrastructure from scratch. One of the
important changes was the creation of [Siva](https://github.com/src-d/go-siva) Git repository archive format.
Siva resembles [Tar](https://www.gnu.org/software/tar/) but the index is placed at the end of the file to allow
cheap append operation. We re-invented the concept of a "rooted repository" where all branches from the same root are placed together, and therefore the corresponding packfiles are appended to the same Siva file while we are massively cloning Git repositories. It is not unique - GitHub has a similar approach to storing forks
internally. The main benefit is re-using the Git objects between branches and thus reducing the size on disk.

So when our next-gen retrieval pipeline emerged, we realized that the dataset time has come. It is surely
difficult to open access to the whole Git world (we clone from BitBucket, Savannah, servers in the wild, etc.)
because the size is too big, so we started from putting a threshold to the number of stargazers on GitHub
and picking the most popular projects. This threshold was set to **50** from Vadim's historical default limit in [GitHubStars](https://github.com/vmarkovtsev/githubstars). The plan was to distribute the Siva files
generated from those popular repositories.
Later we realized that having only the Siva files is not enough - people wanted to tighten the stars limit,
filter by main programming language or by license. The idea of an index file appeared where we would place
various metadata, either existing or mined after cloning.

Regading Git repository mining, we attended [Mining Software Repositories](http://2017.msrconf.org) conference in 2017 and loved it. There was an opportunity to organize everything well and submit a paper about our dataset to the "Data Showcase" track. We took action, wrote the paper and lucky for us it was accepted.
source{d}'s first official scientific article.

## Paper

<embed src="https://arxiv.org/pdf/1803.10144" width="600" height="600" alt="PGA paper from ArXiV">

## Cut scenes

The paper was limited to 4 pages, also it's scientific nature did not allow to include much technical details
and describe the experience, so this section tries to compensate.

#### Retrieval

First of all, cloning **all** Git repositories is ~hard~ 🔥HELL🔥. Examples:

* Integration between Gerrit and GitHub produces hundreds of standalone Git references. E.g. [google/angle](https://github.com/google/angle) becomes spread over 6,600 Siva files, each with a tiny single ref coming from
a Gerrit review.
* [Git Bomb](https://github.com/Katee/git-bomb) - an "uncloneable" repository. By the way, we cloned it.
* Some repositories have packfiles in the [old deprecated format]. go-git handles them.(https://github.com/git/git/blob/master/Documentation/technical/pack-format.txt#L39).
* Load balancing is difficult. 90% of the repositories are compact and fly fast, however, the rest 10% occupy 50% of the dataset size and are damn slow to process.
* Analyzing big repositories requires much memory, as much as 128 GB. Thus our pipeline kept exploding again and again and we restarted it with a firm hand.

We had to take into account the removed repositories. Over 3,000 were deleted within few months.
We discovered a few repositories with porno while inspecting the outliers by repository size (no links here, sorry, join our community Slack and direct message).

#### Paper

We used [Overleaf](https://www.overleaf.com/) to write the paper. When we reached the internal review
phase, we pushed it to a private GitHub repository and the rest of the edits happenned in pull requests.
Thus we avoided the "cold start" problem where the first pull request is huge and nightmare to read and collaborate. If we did not have to use TeX, we would use Google Docs instead.

It was hard to squeeze the content into 4 pages. The layout constantly broke, we had to "fix" it with
`\vspace`. Figures tended to appear on a different page from the related text so we forced the placement
and got the "jumping" problem instead. The bibliography was very verbose and we had to "optimize" the records
to make them shorter and consequently fit into one column.

#### Licensing

Upcoming [GDPR law](https://www.eugdpr.org/) in EU enforces strict rules for dealing with private information.
Git repositories contain commits and commits contain people's names, email addresses and timestamps which
allow identification and hence are characterized as private information. We've discovered that while the code
itself may have a free license, that license does not extend to the development history. In other words, it is
theoretically possible to sue for privacy infringement because of the Git metadata distribution or something
similar. GitHub terms of service defend them against this funny threat but nobody made an agreement with third
parties.

I am not a lawyer and the funny paragraph above can be nonsense but one thing is clear: we are not risky
enough to store Git repositories (that is, private information belonging to millions of people) in EU under
GDPR. Therefore PGA resides on our servers in USA.

#### Updates

We discussed the dataset updates many times and still not decided about the details. It is evident to everybody
that we should provide updates, yet the current retrieval process is not automated enough and requires human
intervention. Data Retrieval team is currently rushing the development of [GitBase](https://github.com/src-d/gitquery)
which allows to run [Engine](https://github.com/src-d/engine) jobs over PGA much faster.

<style>
img[src$='#left'] {
	margin: 0 !important;
}
</style>
