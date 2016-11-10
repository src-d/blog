---
author: vadim
date: 2016-11-08
title: "Reading PySpark pickles locally"
draft: false
image: /post/reading_pyspark_pickles_locally/intro.jpg
description: "How to load Hadoop SequenceFile-s with Python serialized objects without having to install Spark - using src-d/sparkpickle"
---
I've recently had a task to merge all the output from Spark in the Pickle format,
that is, obtained via `spark.rdd.RDD.saveAsPickleFile()`, in my personal environment
and conduct some work with it. Surprisingly, no tools exist to read those files,
however it is relatively easy to do. I started [src-d/sparkpickle](https://github.com/src-d/sparkpickle)
project and this article is about how I created it, with some deep insight into
the binary format of Hadoop's SequenceFile.

First of all, some explanation of the relevant technologies. PySpark has the ability
to store the results in HDFS or any other data persistence backend in the efficient
Python-friendly binary format, [pickle](https://docs.python.org/3/library/pickle.html).
It is the quick and dirty way to store Python objects, without having to define
any schema, do custom serialization and messing with general-purpose formats like
[Parquet](http://spark.apache.org/docs/latest/sql-programming-guide.html#parquet-files).
Hadoop defines the binary format named [SequenceFile](https://wiki.apache.org/hadoop/SequenceFile).
It is the stream of key-value pairs, where keys and values must have the uniform
types, and their class names are stored in the stream header. So basically,
PySpark writes SequenceFile-s with null keys and blob values.

If you want to read those files on your personal computer and not in the Spark
cluster environment, you are in trouble: there is simply no way of doing it. You
have to install Spark, PySpark, connect it to your storage backend, process
the files and finally pickle the result of `collect()`.
That's why I had to write [src-d/sparkpickle](https://github.com/src-d/sparkpickle):
it is a tiny Python package without *any* dependencies which allows you to load
Python objects serialized by PySpark.

saveAsPickleFile() internals
----------------------------
It appeared that PySpark's [saveAsPickleFile()](http://spark.apache.org/docs/latest/api/python/pyspark.html#pyspark.RDD.saveAsPickleFile)
function works rather complicated. You can refer to it's [source code](https://github.com/apache/spark/blob/branch-2.1/python/pyspark/rdd.py#L1450).
It works in multiple steps.

1. Accumulate items in batches. The batch size is configured with the `batchSize` argument.
Each batch is the list of Python objects you return or yield in your PySpark RDD pipeline.
Performed on Python side by [BatchedSerializer](https://github.com/apache/spark/blob/branch-2.1/python/pyspark/serializers.py#L180).
2. Each batch is pickled on Python side by [PickleSerializer](https://github.com/apache/spark/blob/branch-2.1/python/pyspark/serializers.py#L403).
It writes data in frames, each frame is the size of the subsequent data chunk and the chunk itself.
All integers here and later are written in [big-endian](https://en.wikipedia.org/wiki/Endianness#Big-endian) byte order.
3. The resulting byte stream is passed into [saveAsObjectFile](https://github.com/apache/spark/blob/branch-2.1/core/src/main/scala/org/apache/spark/rdd/RDD.scala#L1497)
on Scala/JVM side. The frame lengths are discarded so that the next step proceeds with the original data chunks.
JVM needs prepended lengths because it interoperates with Python workers via sockets and
needs to know the exact amount of data to read beforehand ([see the code](https://github.com/apache/spark/blob/branch-2.1/python/pyspark/worker.py#L167)).
4. Each bytes object received from Python is serialized again using [Java standard serialization](https://docs.oracle.com/javase/7/docs/platform/serialization/spec/protocol.html#10258).
Thus we have serialization inside serialization! ![deeper.jpg](/post/reading_pyspark_pickles_locally/deeper.jpg)
5. `saveAsObjectFile()` writes [SequenceFile](http://grepcode.com/file/repo1.maven.org/maven2/org.apache.hadoop/hadoop-common/2.7.1/org/apache/hadoop/io/SequenceFile.java#SequenceFile)
with keys of type [NullWritable](https://www.safaribooksonline.com/library/view/hadoop-the-definitive/9781449328917/ch04.html#id3961179)
and values of type [BytesWritable](https://www.safaribooksonline.com/library/view/hadoop-the-definitive/9781449328917/ch04.html#id3960971)
(the result of the second serialization).
6. The Hadoop disk backend (HDFS, S3, GCS, local file system, etc.) actually stores the result.

SequenceFile+pickle format
--------------------------
Here is what it looks inside:

![bin](/post/reading_pyspark_pickles_locally/bin.png)

The left column is the offsets for the rows. The actual pickle data always starts
from offset 158. The whole file is divided into "records", each record has a header.
There can be *sync marks* inserted between records, 16 byte each. The first sync mark goes after
the top level header which contains the class names for keys and values. All subsequent
sync marks are prepended with `0xffffffff` (-1 reinterpreted as unsigned).

sparkpickle
-----------
So to read the format described above, we don't really need any Spark or Java interop
in general. The only non-trivial block is the
[Java standard serialization](http://www.javaworld.com/article/2072752/the-java-serialization-algorithm-revealed.html)
for byte arrays. In theory, we could use fixed offsets and do not care about the serialization at all.
In practice, Java serialization may use variable length integer encoding, so it's not always a good idea.
I decided to handle it properly so that I could catch possible corruption errors earlier, before unpickling.
While unpickling is robust, in some cases it may perform unexpected operations if started from the wrong offset.
There is a nice project named [javaobj](https://github.com/tcalmant/python-javaobj) which is
a pure Python implementation for Java standard serialization, it worked out of the box
and matched perfectly.

The usage of the resulting package is very easy and feels the same as working
with `pickle` package directly. E.g.,
```
with open("/path/to/sequence/file", "rb") as f:
    print(sparkpickle.load(f))
```

To quickly dump the contents of the file in terminal, execute
```
python -m sparkpickle /path/to/sequence/file
```

The package was uploaded to the [cheese shop](https://wiki.python.org/moin/CheeseShop),
so is easily installable via `pip install sparkpickle`.

Summary
-------
Saving Python objects in pickle format on Spark appeared to be not very efficient
because of the double serialization and several copies of the same data. Nevertheless,
it is pretty possible to read those files (fast) without having to install Spark thanks to
[sparkpickle](https://github.com/src-d/sparkpickle).
