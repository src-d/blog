---
author: vadim
date: 2018-11-20
title: "The Public Git Archive Story"
image: /post/pga_history/logo.png
description: "We have recently released a large dataset for MLonCode - Public Git Archive (PGA). It contains 182,000 top-starred repositories on GitHub and takes 3 TB on disk.  This post tells the story how PGA emerged: why, how, and what's next."
categories: ["science", "technical"]
---

## What is Public Git Archive?

Public Git Archive is the result of months of efforts curating a dataset suitable
for training Machine Learning on Source Code (aka MLonCode) models.
It contains 182,000 top-starred repositories on GitHub and takes 3 TB on disk.
The repositories were cloned in February-March 2018.
Check out the [announcement post](https://blog.sourced.tech/post/announcing-pga/) for more information.
You should check out [Engine](https://github.com/src-d/engine) which allows
to run SQL queries on top the PGA and do other cool things.

## Origins

We've wanted to release all the Git repositories we are able to clone since the beginning of source{d}. Back in 2016 we stored millions of Git [packfiles](https://git-scm.com/book/en/v2/Git-Internals-Packfiles) in Google Cloud Storage and the metadata in MongoDB. It worked well for us but that scheme did not allow to share the data. Then we decided to go bare metal in 2017 and started to build our infrastructure from scratch. One of the
important changes was the creation of the [Siva](https://github.com/src-d/go-siva) Git repository archive format.
Siva resembles [Tar](https://www.gnu.org/software/tar/) but the index is placed at the end of the file to allow
cheap append operations. We re-invented the concept of a "rooted repository" where all branches from the same root are placed together, and therefore the corresponding packfiles are appended to the same Siva file while we are massively cloning Git repositories. It is not unique - GitHub has a similar approach to storing forks
internally. The main benefit is reusing the Git objects between branches and thus reducing the size on disk.

So when our next-gen retrieval pipeline emerged, we realized that the dataset time has come. It is surely
difficult to open access to the whole Git world (we clone from BitBucket, Savannah, servers in the wild, etc.)
because the size is too big, so we started from putting a threshold to the number of stargazers on GitHub
and picking the most popular projects. This threshold was set to **50** from Vadim's
historical default limit in [GitHubStars](https://github.com/vmarkovtsev/githubstars).
The plan was to distribute the Siva files generated from those popular repositories.
Later we realized that having only the Siva files is not enough - people wanted to tighten the stars limit,
filter by main programming language or by license. The idea of an index file appeared where we would place
various metadata, either existing or mined after cloning.

Cloning Git repositories is hard as 🔥HELL🔥:

* Integration between Gerrit and GitHub produces hundreds of standalone Git references. E.g. [google/angle](https://github.com/google/angle) becomes spread over 6,600 Siva files, each with a tiny single ref coming from
a Gerrit review.
* [Git Bomb](https://github.com/Katee/git-bomb) - an "uncloneable" repository. By the way, we cloned it.
* Some repositories have packfiles in the [old deprecated format](https://github.com/git/git/blob/master/Documentation/technical/pack-format.txt#L39). go-git handles them.
* Load balancing is difficult. 90% of the repositories are compact and fly fast, however, the remaining 10% take up 50% of the total size of the dataset and are really lengthy to process.
* Analyzing big repositories requires much memory, as much as 128 GB. Thus our pipeline kept exploding again and again and we restarted it with a firm hand.

We had to take into account the removed repositories. Over 3,000 were deleted within few months.
We discovered a few repositories with porn while inspecting the outliers by repository size (no links here, sorry, join our community Slack and direct message).

Overall, our Data Retrieval team did a fantastic job. It was great to see how
the numerous open source libraries they developed played together to deliver the dataset.

## Paper

As for the mining of Git repositories, we attended
[Mining Software Repositories](http://2017.msrconf.org) (MSR) conference in 2017
and loved it. There was an opportunity to submit a paper about our dataset
to the "Data Showcase" track on [MSR'18](http://2018.msrconf.org).
We took action, wrote the paper and luckily for us it was accepted.

<embed src="https://arxiv.org/pdf/1803.10144" width="600" height="600" alt="PGA paper from ArXiV">

{{% caption src="/post/pga_history/presentation.jpg" %}}
Vadim is presenting Public Git Archive on MSR'18/ICSE'18.
{{% /caption %}}

We used [Overleaf](https://www.overleaf.com/) to write the paper.
## Poster

We presented the poster about PGA on [MSR'18](http://2018.msrconf.org) poster session.
It was created in Adobe Illustrator and Inkscape.

<embed src="/post/pga_history/pga_poster.pdf" width="600" height="600" alt="PGA poster for MSR'18">

{{% caption src="/post/pga_history/poster.jpg" %}}
Conference attendees looking at the PGA poster on MSR'18/ICSE'18.
{{% /caption %}}

## Future

We plan to release the next version of PGA later this year or early next year.
It is included into our [Q4 OKRs](https://github.com/src-d/okrs/tree/2018Q4#release-a-new-version-of-pga-infraapps).
Stay tuned.

Do you want to learn more about PGA? [Visit the PGA page on GitHub](https://github.com/src-d/datasets), [join our community on Slack](https://sourced.tech/community/#talk) and [sign up for our newsletter](http://go.sourced.tech/newsletter).
