---
author: vadim
date: 2018-11-10
title: "Advanced Scientific Data Format"
image: /post/asdf/logo.png
description: "What is ASDF, why it is awesome, why you should and how to use it. ASDF in source{d} projects."
categories: ["technical"]
---

[Advanced Scientific Data Format](https://github.com/spacetelescope/asdf) (ASDF)
is a next generation serialization format for scientific data. This means that
it focuses on storing sparse and dense tensors in an efficient way.
ASDF project started by [Michael Droettboom](https://github.com/mdboom) (Matplotlib; astropy)
at SpaceTelescope Institute in 2014. ASDF is not implementation-driven, it is based on
the well-defined [standard](https://asdf-standard.readthedocs.io/en/latest/).
However, there is only one maintained software library written in Python.
While historically ASDF targetted astronomers, it is actually abstracted away
from any scientific domain and is completely versatile.

Why another format? Currently, the most popular scientific serialization
format is [HDF5](https://support.hdfgroup.org/HDF5/). HDF5 was described many years
ago and is somewhat morally outdated has problems with performance which were
described in ["Moving away from HDF5"](https://cyrille.rossant.net/moving-away-hdf5/).
So ASDF tries to take a fresh look on scientific data and account the typical
modern usage patterns.

## Features

* Transparent, automatic, on-the-fly compression and decompression with zlib, bzip2 or lz4.
* YAML header with binary blocks appended to the tail. All the perks of using YAML are preserved.
* Uncompressed tensors can be [memory mapped](https://en.wikipedia.org/wiki/Memory-mapped_file) so that the operating memory consumption is very low with tiny performance penalty for sequential read and write. Killer feature if the tensors are big.
* Data structure can be validated with YAML schemas.
* Python and numpy arrays are first-class citizens.
* The tags mechanism allows to extend for new binary data types easily. Though it is rarely needed in practice.

## Code examples

## ASDF at source{d}