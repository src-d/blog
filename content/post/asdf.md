---
author: vadim
date: 2018-11-26
title: "Why we chose Advanced Scientific Data Format for ML models"
image: /post/asdf/logo.png
description: "What ASDF is, why it is awesome, why you should probably use it, and how. Why we adopted ASDF in source{d} ML projects."
categories: ["technical"]
---

There is a project we are developing at source{d} named [Modelforge](https://github.com/src-d/modelforge).
Its goal is to abstract the serialization and the retrieval of the machine learning
models from the users. That is, it solves the following two major problems
every ML engineer hits:

1. What to save a trained model and load it back.
2. How to reference and distribute trained models.

Let's not go offtopic with discussing (2) - there are many funny subproblems there
which deserve a dedicated blog post about Modelforge. Instead, the focus will be on
serialization. The Python crowd is used to solve (1) with
[`pickle`](https://docs.python.org/3/library/pickle.html) - the built-in
serialization module. It works nicely while these three conditions hold:

1. The origin of the files is trusted and secure.
2. The interoperability with other languages is not needed.
3. The serialized objects are not big.

As some know very well, `pickle` contains a full-featured virtual machine inside,
which is interpreted to recreate the serialized Python objects. The advantage
is that we can serialize any object, except for few rare types
like mutexes or executable code. The implied drawbacks are substantial though:
we should not load a pickle from unreliable source because it is vulnerable
to remote code execution attacks; the loader must implement a virtual machine,
which is hard with other programming languages; the memory consumption
during serialization and deserialization can grow far beyond the original object size.
The latter is important for machine learning and data science in particular:
the objects can grow very big, say, bigger than a few hundred megabytes and
pickling them is very slow and memory consuming.
We witnessed 2 and even 3 times bigger memory consumption during
`pickle`-ing which led to fun situations when one has successfully computed
the resulting data, but the whole effort goes to waste when
there is not enough RAM for the pickling process to take place.

So when we started Modelforge, we searched for the best serialization format
which is **not** `pickle`.

{{% caption src="/post/asdf/pickle_rick.png" %}}
"I am a pickle, I get out of serializing huge tensors."
{{% /caption %}}

## Life beyond `pickle`

Our best-shot requirements were:

1. Binary format. It is impossible to efficiently save a huge dense tensor in JSON or YAML.
2. At the same time, it would be nice to be able to save any JSON-like metadata without pain.
3. The schema should be optional. Formats that require an extra schema file in
a separate file make introspection harder while requiring ML researchers to
maintain an extra piece of code. Pythonistas expect introspection, so for
an idiomatic Python library this is essential.
4. The typical data size may span over tens of gigabytes. Compared to gigabytes,
the overhead of including a schema looks irrelevant indeed, hence the files
become self-descriptive and the schema turns into a validation perk.
This requirement rules out Protocol Buffers completely, because each PB file
is always fully loaded into memory in all the existing implementations.
The same requirement excludes popular binary serialization formats which target
messaging and RPC and are not optimized for large messages with few items.
1. Python should be a first-class citizen. numpy arrays should be serializable
without any additional code.
6. Yet the format should not require Python. The user-facing applications at source{d}
are written in Go and otherwise it will be hard to integrate.
7. On-the-fly compression. NLP models often contain strings which can require much
space while being perfectly compressible. Integers can be compressed too since
we sometimes don't know their range beforehand and use 32 bits while only 16 are
really needed.

[HDF5](https://support.hdfgroup.org/HDF5/) was the closest to those. It is binary,
there is no schema, it supports big tensors, Python bindings are mature and
well-integrated, there are bindings for other languages. HDF5 is used in e.g. [Keras](https://github.com/keras-team/keras).
However, it is not ideal in terms of performance and lacks some modern features.
Read ["Moving away from HDF5"](https://cyrille.rossant.net/moving-away-hdf5/).

We previously had some positive experience with SQLite + SQLAlchemy on top,
but of course that variant does not stand big data blobs (4).
There is a common workaround for (4): it is possible to store huge tensors as external files.
This implies concatenating all the blocks together before uploading and splitting
them back after downloading, e.g. as a TAR or a ZIP without compression.
Those meta-archives are typically used as a temporary transfer medium
(e.g., [TensorFlow Hub](https://www.tensorflow.org/hub/hosting)).  
In turn, this means the higher usage complexity, the doubled requirement for free disk size,
the increased vulnerability to data corruptions and the explosion on the number
of open file descriptors.

No more intrigue: we discovered ASDF.

## ASDF

[Advanced Scientific Data Format](https://github.com/spacetelescope/asdf) (ASDF)
is a next generation serialization format for scientific data. This means that
it focuses on storing sparse and dense tensors in an efficient way.
The ASDF project started by [Michael Droettboom](https://github.com/mdboom) (Matplotlib; astropy)
at SpaceTelescope Institute in 2014. ASDF is not implementation-driven, and it is based on
the well-defined [standard](https://asdf-standard.readthedocs.io/en/latest/).
However, there is only one maintained software library written in Python.
While historically ASDF targeted astronomers, it is actually abstracted away
from any scientific domain and is completely versatile. ASDF features:

* Transparent, automatic, on-the-fly compression and decompression with zlib, bzip2 or lz4.
* YAML header with binary blocks appended to the tail. All the perks of using YAML are preserved.
* Uncompressed tensors can be [memory mapped](https://en.wikipedia.org/wiki/Memory-mapped_file) so that the operating memory consumption is very low with tiny performance penalty for sequential read and write. A killer feature if your tensors are big.
* Data structure can be validated with YAML schemas.
* Python and numpy arrays are first-class citizens.
* The tagging mechanism allows to extend for new binary data types easily. Though it is rarely needed in practice.
* The schema is there but is completely optional.

## Code examples

By default, ASDF reads tensors from disk lazily upon the first reference.
Thus the opening of an ASDF file is very fast, and it is easy to quickly introspect.
The contents are always a Python `dict` and they are placed into the `tree` attribute.

```python
import asdf

with asdf.open("file.asdf") as f:
    print(f.tree)
```

Let's create a new ASDF file and see what's inside.

```python
import io

import asdf
import numpy

tensor = numpy.ones(10, dtype="int32")
buffer = io.BytesIO()
asdf.AsdfFile(tree={
    "tensor1": tensor,
    "tensor2": tensor,
    "meta": "data",
    "int": 100
}).write_to(buffer)
print(buffer.getvalue().decode("utf-8", errors="backslashreplace"))
```

We should see

```
#ASDF 1.0.0
#ASDF_STANDARD 1.2.0
%YAML 1.1
%TAG ! tag:stsci.edu:asdf/
--- !core/asdf-1.1.0
asdf_library: !core/software-1.0.0 {author: Space Telescope Science Institute, homepage: 'http://github.com/spacetelescope/asdf',
  name: asdf, version: 2.1.0}
history:
  extensions:
  - !core/extension_metadata-1.0.0
    extension_class: asdf.extension.BuiltinExtension
    software: {name: asdf, version: 2.1.0}
int: 100
meta: data
tensor1: !core/ndarray-1.0.0
  source: 0
  datatype: int32
  byteorder: little
  shape: [10]
tensor2: !core/ndarray-1.0.0
  source: 0
  datatype: int32
  byteorder: little
  shape: [10]
...
\xd3BLK0(((\x9dZ\x82\xde\xf2_\x8f\x83<B\xaa\xa4g\xde#ASDF BLOCK INDEX
%YAML 1.1
--- [615]
...
```

Tree items which are not binary - "meta" and "int" - have been written inline in YAML.
ASDF has been intelligent enough to serialize only one copy of the array.
It is placed at the end of the file and forms a "block". `!core/ndarray-1.0.0`
is a tag name which identifies the built-in tensor data type. "source" field
references the block containing the array elements.

It's also very cool that the block offset indexes table is placed at the bottom
of the file, so that it is possible to append without rewriting the whole file.

Let's try with compression now.

```python
import io

import asdf
import numpy

tensor = numpy.zeros(1000000, dtype="int32")
buffer = io.BytesIO()
asdf.AsdfFile(tree={
    "tensor": tensor,
}).write_to(buffer, all_array_compression="zlib")
print(buffer.getvalue().decode("utf-8", errors="backslashreplace"))
```

The zlib algorithm is very efficient at compressing zeros, so the result is expected and awesome:

```
#ASDF 1.0.0
#ASDF_STANDARD 1.2.0
%YAML 1.1
%TAG ! tag:stsci.edu:asdf/
--- !core/asdf-1.1.0
asdf_library: !core/software-1.0.0 {author: Space Telescope Science Institute, homepage: 'http://github.com/spacetelescope/asdf',
  name: asdf, version: 2.1.0}
history:
  extensions:
  - !core/extension_metadata-1.0.0
    extension_class: asdf.extension.BuiltinExtension
    software: {name: asdf, version: 2.1.0}
tensor: !core/ndarray-1.0.0
  source: 0
  datatype: int32
  byteorder: little
  shape: [1000000]
...
 \xf7Om\xf0n::=	\x90\xb7A\xf9\x84\xe3\xbb@\x8d\x92\xfaI\xf9\xc46x\x9c\xed\xc1
            \x93#ASDF BLOCK INDEX
%YAML 1.1
--- [506]
...
```

## Summary

[ASDF](https://github.com/spacetelescope/asdf) is a relatively new hybrid YAML+binary blocks format.
It is implemented for Python only at the moment, and I really hope that
the community will help with covering other programming languages (Go please!).
ASDF is very nice for storing scientific data such as tensors and suits
machine learning models serialization well. source{d} successfully uses it in
[Modelforge](https://github.com/src-d/modelforge) -
a framework to serialize and distribute MLonCode models.

Don't want to miss the next blog post about how source{d} ML team does R&D?
Subscribe to [our newsletter](http://go.sourced.tech/newsletter), follow
[@sourcedtech](https://twitter.com/sourcedtech) on Twitter and don't forget
about our [Paper Reading Club](https://github.com/src-d/reading-club).
Oh, and we are organizing the
[MLonCode developer room at FOSDEM'2019](https://medium.com/sourcedtech/ml-on-code-devroom-cfp-fosdem-2019-4f867f128e21#a948)
- the call for proposals is open!
