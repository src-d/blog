---
author: vadim
date: 2016-10-21
title: "Adding LZO support to Dataproc"
draft: false
image: /post/dataproc_lzo/intro.png
description: "How to leverage splittable LZO compression in Dataproc"
categories: ["science", "technical"]
---
[LZO](https://en.wikipedia.org/wiki/Lempel%E2%80%93Ziv%E2%80%93Oberhumer) is a nice
general-purpose data compression algorithm which provides blazing fast decompression.
It is especially good because LZO archives can be indexed and become
[splittable](http://stackoverflow.com/questions/34208051/when-are-files-splittable).
source{d} uses LZO to store the dataset of [names occurring in the source code](http://blog.sourced.tech/post/github_topic_modeling/)
in GitHub repositories, reducing the amount of data by a factor of 2.

Spark does not support LZO codec out of the box because its implementation
is GPL licensed and conflicts with Apache. Google's [Dataproc](https://cloud.google.com/dataproc/),
being the managed Spark cluster cloud solution, <span style="text-decoration: line-through;">obviously neither supports LZO out of the box</span>
see the update, finally it does. However, Twitter has developed
[hadoop-lzo](https://github.com/twitter/hadoop-lzo), the pluggable LZO support
for the Hadoop and Spark ecosystems, and it can be very easily added to Dataproc thanks
to [custom initialization scripts](https://cloud.google.com/dataproc/docs/concepts/init-actions).
Let me quickly describe how.

The initialization script should contain the following actions for the master node:
```
# Install CLI LZO archiver
apt-get install -y lzop

# Download hadoop-lzo jar from Twitter's Maven repository
wget http://maven.twttr.com/com/hadoop/gplcompression/hadoop-lzo/0.4.20/hadoop-lzo-0.4.20.jar -O /usr/lib/hadoop/lib/hadoop-lzo-0.4.20.jar

# Prepare core-site.xml for appending
sed -ie 's/<\/configuration>//' /etc/hadoop/conf/core-site.xml

# Register LZO codec; we have to enumerate all the standard ones as well
echo "  <property>
    <name>io.compression.codecs</name>
    <value>org.apache.hadoop.io.compress.GzipCodec, org.apache.hadoop.io.compress.DefaultCodec, org.apache.hadoop.io.compress.BZip2Codec, com.hadoop.compression.lzo.LzoCodec, com.hadoop.compression.lzo.LzopCodec
    </value>
  </property>
  <property>
    <name>io.compression.codec.lzo.class</name>
    <value>com.hadoop.compression.lzo.LzoCodec</value>
  </property>
</configuration>" >> /etc/hadoop/conf/core-site.xml
```
And that's it! Existing LZO files in Google Cloud Storage can be indexed with
```
hadoop jar /usr/lib/hadoop/lib/hadoop-lzo-0.4.20.jar com.hadoop.compression.lzo.LzoIndexer gs://bucket/subpath_or_file
```

Update
------
Dataproc actually added the support for LZO on [01.09.2016](https://cloud.google.com/dataproc/docs/release-notes/service#september_1_2016).
It ships hadoop-lzo 0.4.19 in /usr/lib/hadoop/lib/, but *there is still the need to edit the
configuration file*.
