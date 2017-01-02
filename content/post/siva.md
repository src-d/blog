---
author: smola
date: 2017-01-03
title: "śiva: Why We Created Yet Another Archive Format"
draft: true
image: /post/siva/cat_box_cropped.gif
description: "When analyzing all the source code from all VCS repositories, storage becomes a major problem. śiva, our archive format, is part of the solution."
categories: ["go", "git", "technical"]
---

## Motivation

At source{d} we fetch, store and analyze millions of git repositories.
Today we are covering ~16M and our goal is to cover all of them, as well as keep
up with the rapid growth of code hosted online.

Now, what is in a git repository? For a full explanation, you should read
[Pro Git book, Chapter 10](https://git-scm.com/book/en/v2/Git-Internals-Plumbing-and-Porcelain),
but for our purposes, there are only a few relevant pieces:

 * `config` file with repository-specific git configuration.
 * `objects/pack` directory containing, at least, one [packfile](https://git-scm.com/book/en/v2/Git-Internals-Packfiles)
 and its index file.
 * `HEAD` file with the HEAD reference.
 * (optional) `refs` directory containing [references](https://git-scm.com/book/en/v2/Git-Internals-Git-References).
 * (optional) `packed-refs` file with [packed references](https://git-scm.com/docs/git-pack-refs).

For each repository, we store, at least, 5 files (config, 1 packfile,
1 packfile index, HEAD reference and a master reference). This grows, at least,
by two (1 incremental packfile and its index) every time with update a repository.

For a fresh fetch of our current ~16M repository, that adds up to 80M files and
32M more for each update. That is without considering the high monthly growth of
repository number itself.

We store all of this in a distributed file system. Currently Google Cloud
Storage and we are evaluating HDFS for our bare metal migration. Either way,
whenever we need to update or analyze a repository, we need to read most of the
repository files. Neither GCS or HDFS are low-latency systems, so the latency of
each file fetch from the distributed file system dominates the time to fetch a
repository to a computing node.

At this point, it was clear to us that we need to archive repositories. That way,
when processing a repository, we would need to fetch a single file from the
distributed file system.

## Our Ideal Archive Format

So we started evaluating different archiving formats to use. That should be easy!
There are the features we are looking for:

1. **No compression.** Most data is contained in packfiles, which are already
  compressed.
2. **Seekable.** We need random access to arbitrary positions of the archived
   files.
3. **Indexed.** Fast access to specific files.
4. **Cheap Add.** With every update, we need to add two files
  to the archive, so ideally, we should be able to add these files to the archive
  without completely rewriting it.
5. **Concatenable.** Ideally, it should be possible to add new files to the archive
  with a single append operation. We could use [GCS compose](https://cloud.google.com/storage/docs/composite-objects)
  or HDFS append.

Here is a table with a comparison of different archive formats with respect our
requirements.
 
| Format | No compression | Seekable | Indexed | Cheap Add | Concatenable |
| ------ | -------------- | -------- | ------- | --------- | ------------ |
| [zip](https://en.wikipedia.org/wiki/Zip_(file_format)) | ✔ | ✔[^zipseek] | ✔ | ✔ | ✘ |
| [tar](https://www.freebsd.org/cgi/man.cgi?query=tar&sektion=5) | ✔ | ✔ | ✘ | ✔ | ✔[^tarconcat] | 
| [cpio](https://www.freebsd.org/cgi/man.cgi?query=cpio&sektion=5) | ✔ | ✔ | ✘ | ✔ | ✘[^cpioconcat] |
| [7z](http://www.7-zip.org/7z.html) | ✔ | ✔[^7zseek] | ✔ | ✔ | ✘ |

Our first thought was we could extend or abuse some features in an existing
format to make it more suitable for us.

## tar

Being tar the most widely used archiving format in UNIX-like systems, we decided
to give it a chance.

Let's have a look at the tar file structure, in a simplified way:

![tar file structure](/post/siva/tar.png)

A tar archive is essentially a sequence of files. Each file contains a header, padding
(files are stored in blocks of 512 bytes) and file content. The end of file is
 marked with, at least, two zeroed blocks.

It is possible to concatenate multiple tar archives. We just need to ignore the
zeroed blocks that are used as EOF markers:
 
![tar file structure](/post/siva/tar_concat.png)
 
This is supported by GNU tar and FreeBSD tar with a command line switch, but it
is not widely supported in other tar implementations, which just ignore everything
after the first EOF block.

There is no index that can be used for random access to tar contents. This is
natural since tar (*t*ape *ar*chive) was designed to write and read sequentially
on tape drives. Given the ubiquity of the tar format, many people have added
indexing to tar, either by using a separate file (e.g.
[tarindexer](https://github.com/devsnd/tarindexer)) or embedding the index in
the tar file itself (e.g. [rat](https://github.com/mcuadros/go-rat)). The later
approach enables us to use the embedded index while preserving compatibility
with standard tar tooling, since standard tar will ignore data after the EOF mark.
The result would be as follows:

![tar file structure](/post/siva/tar_index.png)

We can combine both indexing and concatenation. The result would be something
like this:

![tar file structure](/post/siva/tar_concat_index.png)

Our conclusion is that we could use the tar format with some tricks to fulfill
all our needs, and still be compatible with GNU tar or FreeBSD tar. It would
have the following drawbacks:

1. Adding indexing and concatenation support would mean writing a custom tar
   implementation is needed for every language that we use.
2. It is not space efficient: metadata is duplicated both in the index and headers,
   plus the useless padding. This is not a big issue for us, but if we are going
   to write our own tar implementations, we would rather avoid cruft and legacy.

## zip

Zip seems to come pretty close to our requirements. Let's see its structure:

![tar file structure](/post/siva/zip.png)

In principle, this is close to our tar+index format. However, concatenation is
not possible at all without modifying the format in a completely incompatible
way.

As an additional drawback, we are not aware of any implementation that provides
random access to uncompressed files in a zip archive.

## Other formats

No other format got as close as zip and tar. For us, cpio was essentially tar
with less extension possibilities. 7z apparently did not fit either and we did
not explore the possibility of extending it, since it is unnecessarily complex
for our purposes and implementations in multiple languages are scarce.
[RAR](http://www.rarlab.com/) was discarded since it's a proprietary format and
there are no full open source implementations.

And then there is a [myriad of more obscure archiving formats](https://en.wikipedia.org/wiki/List_of_archive_formats)
(e.g. [mar](https://wiki.mozilla.org/Software_Update:MAR#Mozilla_ARchive),
[zpaq](https://github.com/zpaq/zpaq)), most of which lack adequate documentation
or multiple implementations. We decided that doing the full research to find an
adequate format was not going to pay off, since we would need to write our own
implementations in multiple languages anyway.

## Enter śiva

Here it is! The format that has all the features we wanted: [śiva](https://github.com/src-d/go-siva)
(**s**eekable **i**ndexed **b**lock **a**rchiver). It fulfills all our
requirements in an efficient way with minimal storage overhead.

A śiva file is a collection of one or more blocks. Each block can contain zero
or more files. There is nothing more than a collection of blocks,
no global header or footer. That means it is possible to concatenate two śiva
files and the result is a valid śiva file.

Inside each block, the content of all files comes first. Files are simply
concatenated without any kind of separator or metadata. After all file contents,
there is an index entry for each file and finally the index footer.

![śiva storage layout](/post/siva/siva.png)

When reading a śiva file, implementations must start by reading the index
footer of the last block. The full index can be built by jumping backwards from
index footer to index footer.

If an entry is repeated, the later occurrence has precedence, so it is possible
to perform a logical overwrite. There is also the possibility of adding an index
entry marking a file as logically deleted. The combination of logical overwrites
and deleted facilitate implementing file system abstractions on top of śiva files.

The format has some interesting properties that we have not explored yet, but
are possible to implement without any modification to the format:

* Appending a block with a consolidated index for the whole file, so that the
  reader does not need to jump over all block footers to get the full index.
* Add a file to an existing block, overwriting the index. That is, the same
  add strategy that zip or tar use.
* Padding both entries and blocks, to align with blocks of the underlying file
  system.

The reference implementation of śiva is written in Go. [Its API](https://godoc.org/gopkg.in/src-d/go-siva.v1)
is similar to the standard Go archive/tar API. It has ~450 LOC, significantly less
than the standard Go tar (~1300 LOC) and zip (1000 LOC). So it is easy to understand
and maintain.

You can also check the [format specification](https://github.com/src-d/go-siva/blob/master/SPEC.md)
for a detailed description of the format.

[^tarconcat]:  tar command line tools require additional options to be able to
               read a concatenated tar file (e.g.
               [--ignore-zeros in GNU tar](https://www.gnu.org/software/tar/manual/tar.html#SEC75)).
[^zipseek]:    It is possible to seek inside uncompressed files in a zip
               archive. However, it is not supported in common zip implementations.
[^cpioconcat]: You might use some tricks to
               [extract concatenated cpio archives](http://superuser.com/questions/559255/how-to-extract-concatenated-cpio-archive).
[^7zseek]:    It is possible to seek inside uncompressed files in a 7z archive.
               However, it is not supported in common 7z implementations.