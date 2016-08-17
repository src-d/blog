---
author: vadim
date: 2016-08-15
title: "Setting up Google Cloud Dataproc with Jupyter and Python 3 stack"
draft: false
image: /post/dataproc_jupyter/intro.png
description: "How-to article devoted to setting up Dataproc, Jupyter and Python 3 data science stack"
---
Modern big data world is hard to imagine without [Hadoop](http://hadoop.apache.org/).
It made a small revolution in how analysts deal with large amount of emerging data
(before Hadoop, it used to be a torture). [Spark](https://spark.apache.org/) is
"Hadoop 2.0", it much improves on the original MapReduce engine.

[Google Cloud Dataproc](https://cloud.google.com/dataproc/) is a nice solution
to work with managed Spark stack. Inside, it is a set of VMs one of which is master
node and the rest are workers. You can SSH to any VM in the cluster if you
want to fix/try/change something. There are two things which make Dataproc
different from the usual Compute Engine:

1. Each node runs a set of Google's systemd services to manage Hadoop/Spark.
2. Cloud Console shows nice UI where you can inspect or launch the jobs.

Data scientists which use Python as the primary language like Spark because it has
[PySpark](https://spark.apache.org/docs/latest/programming-guide.html). PySpark
allows running Spark jobs written in Python using
[sensible API](http://spark.apache.org/docs/latest/api/python/pyspark.html).
Technically, it is a Python package which talks to the Spark's master node.

[Jupyter](http://jupyter.org/) is a widely known language-agnostic project
which allows almost WYSIWUG coding in web browser or terminal. Traditional
scientists and engineers would say that it was inspired by
[Matlab](http://www.mathworks.com/products/matlab/?requestedDomain=www.mathworks.com)
and alike. While this is true, Matlab inspired the whole scientific Python stack,
notably [numpy](https://docs.scipy.org/doc/numpy-dev/user/numpy-for-matlab-users.html)
and [matplotlib](http://matplotlib.org/). Jupyter is relatively young; it grew
from [IPython](https://ipython.org/) and originally was tied to Python language.
Actually, some people still mess Jupyter with IPython and the official website
has the special clarification about the statuses of those two projects.

So a natural idea about how to use Dataproc for a pythonista is to
run Jupyter Notebook and work with Spark using PySpark. This longread
elaborates on how to deploy modern Jupyter over Python 3 to Dataproc and efficiently
use it. Particularly, we present [JGSCM](https://github.com/src-d/jgscm), an adapter
between Jupyter virtual file system and Google Cloud Storage. And before you ask:
this is kind of trickier than in the
[official how-to](https://cloud.google.com/dataproc/tutorials/jupyter-notebook)
and not the same as [Cloud Datalab](https://cloud.google.com/datalab).

Jupyter, Python 3, Dataproc: take any two
-----------------------------------------
There is no need to introduce anybody to Python. The fun is to write about
the battle between Python 2 and Python 3. A long time ago (in 2008) there was
[Python 2.6](https://www.python.org/download/releases/2.6/). In the same year,
core developers released the next, not backward-compatible version which they named
[Python 3k](https://www.python.org/download/releases/3.0/). Basically, it threw
away some legacy constraints, unified API, did brilliant job with refactoring strings
([some argue](http://lucumr.pocoo.org/2014/1/5/unicode-in-2-and-3/)) and did other
useful and cool things which would be impossible to do otherwise. Due to it's
backward-incompatible nature, Python 3 could not be adopted fast, and the two
versions continued to exist and develop together. Finally, 2.x branch stopped
at 2.7 bugfixes (latest is [2.7.12](https://www.python.org/downloads/release/python-2712/))
and 3.x branch won. Yet still many developers use 2.x for various reasons and
their number gradually decrease.

Of course, starting a new project in Python 2.7 in 2016 is a mistake (if
you do not have special [requirements](https://caniusepython3.com/)). Yet still
we sometimes read modern articles about doing something in language which is 8
years old by it's nature. One example is the [official Jupyter in Dataproc](https://cloud.google.com/dataproc/tutorials/jupyter-notebook)
how-to from Google. Since there is no better option, let's use that as a baseline
and try to replace Python 2 with Python 3.

Creating Dataproc cluster
-------------------------
While it is possible to create Dataproc clusters through command line, web UI
feels more comfortable for a new user. You should go to Google Cloud Platform Console,
then enter Dataproc in Products & services (top-left ≡). There is a button to
create a new cluster on the top.

The interesting part is specifying the custom cluster initialization script.
It is an ordinary Bash script which is run under root user on master and each of
the workers during cluster creation. To supply it, click "Preemptible workers,
bucket, network, version, initialization, & access options":

![Dataproc1](/post/dataproc_jupyter/dataproc1.png)

and then enter the path to the initialization script in Google Cloud Storage
(yes, it must be uploaded to GCS, to web links):

![Dataproc2](/post/dataproc_jupyter/dataproc2.png)

If you'd like to deploy Jupyter and Python 3 stack (numpy, sklearn, etc.) use
source{d}'s own script which is publicly available as gs://srcd-dataproc/jupyter.sh
(duplicated in GitHub [gist](https://gist.github.com/vmarkovtsev/e56fe77562037460585d4de690040da8)).

jupyter.sh
----------
The first thing we must figure out in the initialization script is who we are:
a master or a worker. This is done by calling
```
/usr/share/google/get_metadata_value attributes/dataproc-role
```
`/usr/share/google/get_metadata_value` is actually a shell script which executes
```
curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/dataproc-role" -H "Metadata-Flavor: Google"
```
The header is important; without it you'll get 403 Forbidden.

Dataproc currently runs on Debian 8.4, which is similar to Ubuntu 16.04 (well,
actually we should say the opposite). We have `apt-get` to install system packages
and we have `systemd` to manage system services.

### Workers

Setting up workers is easy: we install Python 3 and the related packages,
then upgrade pip to the latest version available and install [sklearn](http://scikit-learn.org/stable/),
[pandas](http://pandas.pydata.org/) and friends. One can install them from system
packages, but they develop rapidly and the latest version is usually the greatest.
Additionally, we install [gcloud-python](https://github.com/GoogleCloudPlatform/gcloud-python) -
Google Cloud API high level (there also exists a low level) wrapper for Python.

Either master or workers must be prepared for Python 3. We add needed environment
variables into various Spark configuration files:
```
echo "export PYSPARK_PYTHON=python3" | tee -a  /etc/profile.d/spark_config.sh  /etc/*bashrc /usr/lib/spark/conf/spark-env.sh
echo "export PYTHONHASHSEED=0" | tee -a /etc/profile.d/spark_config.sh /etc/*bashrc /usr/lib/spark/conf/spark-env.sh
echo "spark.executorEnv.PYTHONHASHSEED=0" >> /etc/spark/conf/spark-defaults.conf
```
Those mostly do with Python 3's [hash randomization](https://docs.python.org/3.3/using/cmdline.html#cmdoption-R),
which is good for security but bad for computation repeatability and stability.

### Master

Master node requires quite a few extra steps. First, we must configure Spark
to use `python3` instead of the default `python` executable which is 2.7.
There exists a GitHub [gist](https://gist.github.com/cerisier/118c06d1a0147d1fb898218b57ba82a3/)
which does all the work for us. Looks like it closes the discussion at
[GoogleCloudPlatform/dataproc-initialization-actions](https://github.com/GoogleCloudPlatform/dataproc-initialization-actions/issues/25).

Next, we install the latest IPython and Jupyter with pip. Those two evolve pretty
fast. IPython 5 for example adds autocompletion with dropdown lists to command
line Python sessions as well as dynamic coloring:

![IPython](/post/dataproc_jupyter/ipython.png)

Technically, Jupyter is an umbrella package which depends on `notebook` and many
others. Some common packages are shared between IPython and Jupyter. It uses
[Tornado](https://github.com/tornadoweb/tornado) as the web server engine.

Next, we create an additional IPython profile codename "pyspark" with
```
ipython profile create pyspark
```
IPython has "profiles" which are sets of various session settings. One can execute
arbitrary Python code on notebook startup, for example. The latter is exactly our
case: we need to initialize PySpark's context. Thus we create the file
`~/.ipython/profile_pyspark/startup/00-pyspark-setup.py` with the following:
```python
import os
import sys

spark_home = "/usr/lib/spark/"
os.environ["SPARK_HOME"] = spark_home
os.environ["PYSPARK_PYTHON"] = "python3"
sys.path.insert(0, os.path.join(spark_home, "python"))
with open(os.path.join(spark_home, "python/pyspark/shell.py")) as src:
    exec(src.read())
```
This is similar to what `source` does in Bash: we read Python code from
Spark distribution and execute it inplace. The file contents from above
are inserted using [heredoc](https://en.wikipedia.org/wiki/Here_document).

Then we must link the created IPython profile to new Jupyter kernel type.
Jupyter kernel is an instance of notebook which is running. Notebooks may
be in different languages, environments, etc. When you launch a new kernel,
you choose the desired kernel type from the list:

![new kernel](/post/dataproc_jupyter/new_kernel.png)

The list can be printed in terminal using `jupyter nbextension list`.
Kernel types are registered with JSON files in special kernelspec format.
We create `/usr/local/share/jupyter/kernels/pyspark/kernel.json` with
```json
{
 "display_name": "PySpark 3",
 "language": "python3",
 "env": {"PYTHONHASHSEED": "0"},
 "argv": [
  "/usr/bin/python3",
  "-m",
  "IPython.kernel",
  "--profile=pyspark",
  "-f",
  "{connection_file}"
 ]
}
```
IPython profile is changed from "default" to "pyspark" for that kernel type.
PYTHONHASHSEED is set to 0 to disable [hash randomization](https://docs.python.org/3.3/using/cmdline.html#cmdoption-R).

The last step we seem to miss is running Jupyter as a system service. We create
[systemd](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
service file at `/lib/systemd/system`.
```ini
[Unit]
Description=Jupyter Notebook
After=hadoop-yarn-resourcemanager.service

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/root
StandardOutput=/var/log/jupyter.log
StandardError=/var/log/jupyter.log
ExecStart=/usr/bin/python3 /usr/local/bin/jupyter notebook --no-browser --ip=* --port=8123
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
```
We launch Jupyter after YARN service starts (Hadoop resource manager) so that
there will be no boot race conditions. Logs are written to `/var/log/jupyter.log`.
If Jupyter process dies, it will be automatically restarted in 1 second (the
number of restart attempts is constrained). Jupyter listens on all network
interfaces on port 8123. You can change it 80 for convenience so that you will
not have to specify port number in web browser.

Finally, we add Jupyter service to autorun and start it
```sh
systemctl daemon-reload
systemctl enable jupyter
service jupyter start
```
Accessing Jupyter at Dataproc
-----------------------------
Now we are going to open Jupyter in our web browser to see it in action.
The problem is, Dataproc is not exposed to the outer Internet (and shouldn't)
so we are unable to access our master node at port 8123. The solution is to
open SSH session with [SOCKS proxy](https://en.wikipedia.org/wiki/SOCKS) port
forwarding using [Google Cloud SDK](https://cloud.google.com/sdk/).

```sh
gcloud init
gcloud compute ssh --ssh-flag="-D" --ssh-flag="10000" "<your Dataproc cluster name>-m"
```

Option -D activates proxy mode in [OpenSSH](http://www.openssh.com/) which is likely
your SSH client. 10000 sets the proxy port. "-m" suffix to host name is necessary
because master node host name is formed from the whole cluster name by adding "-m".

To open the Jupyter UI through the proxy in a Chromium-based browser, execute
```
chromium-browser "http://<your Dataproc cluster name>-m:8123" --proxy-server="socks5://localhost:10000" --host-resolver-rules="MAP * 0.0.0.0 , EXCLUDE localhost" --user-data-dir=/tmp/ --incognito
```
(replace chromium-browser with chrome, etc.)
If you are using Firefox you can set the proxy address and profile in any of
it's proxy management extensions, e.g. [FoxyProxy](https://getfoxyproxy.org/).

When the author of this article tried to setup Chromium with any proxy
management extension, he hit several issues. The first is that Chromium
prefetches DNS lookups off the proxy so one has to disable this optimization

![chromium](/post/dataproc_jupyter/chromium.png)

The second is [the problem with AdBlock](https://github.com/jupyter/notebook/issues/297).
Disabling AdBlock selectively on <your Dataproc cluster name>-m does not help,
you have to disable it completely. Thus in the snippet above we launch the browser
in incognito mode so that extensions are ignored.

Persistent notebooks
--------------------
This is where the aforementioned how-to stops. Unfortunately, it forgets to mention
one very critical thing. Jupyter stores notebooks in the master node's file system.
Master's disk is not persistent in the way that if it's VM is reset or shut down,
the file systems loses all the changes. This means that your notebooks will be
lost as soon as you reset or shutdown the master node. The author of this article
realized it very quickly, having left some kernel getting the listing from a
GCS bucket with 10M files for several hours and then having tried to return back
after the connection teardown. Either because of the lack of free memory (listing
takes about 1GB and master had 16GB so this seems unlikely) or something else,
master node stopped responding over SSH and hanged, so it had to be reset.

A natural way to make Jupyter notebooks persistent is to store them in GCS together
with the data. As a bonus, they become very easy to share. Unfortunately,
no ready to use solutions exist. Datalab puts focus on visuals and [leaves
notebooks in the local file system](https://cloud.google.com/datalab/docs/how-to/manage-notebooks).
There exists a [project](https://github.com/jupyter/jupyter-drive)
which keeps notebooks in Google Drive but it's not quite what we want. With
a brave spirit, source{d} started to work on GCS adapter for Jupyter on our own.

It appeared much easier than expected at first. Modern versions of Jupyter
provide a neat way to write backends for the virtual file system. One has
to derive from [ContentsManager](http://jupyter-notebook.readthedocs.io/en/latest/extending/contents.html),
implement it's abstract methods, and derive from Checkpoints with
GenericCheckpointsMixin and implement their abstract methods. Besides, we had to
write our own test suite because tests for ContentsManager implicitly
expect FileContentsManager. The result is [src-d/jgscm](https://github.com/src-d/jgscm).

![jupyter](/post/dataproc_jupyter/jupyter.png)

JGSCM is already included in `jupyter.sh` The tricky part is to fake the timestamp
at `~/.jupyter/migrated` before Jupyter's first run so that it does not completely
remove the configuration directory.

Google Cloud Storage Challenges
-------------------------------
From one side, GCS is superior to HDFS, e.g. it allows "any" number of files
in the same bucket in contrast to [6.4M in HDFS](http://stackoverflow.com/a/34516904/69708).
We've tested it with 10M so far. Of course, this constraint is easily bypassed
by making a prefix tree file structure, but not having to do it is pretty convenient.
Another goody is automatic MIME type reporting.

From the other side, there are only files ("blobs"), no directories. If the name
of the blob contains slashes "/", each segment is treated as a directory
in Storage Browser. If the name ends with a slash, the blob considered to be
an empty directory, but it's not really. To prove it, you may create a blob
with trailing slash and then upload some data to it. You'll succeed and you'll
fail to download this data in Storage Browser because it displays such blobs
as directories!

As with HDFS, you cannot easily mount GCS bucket.
[gcsfuse](https://cloud.google.com/storage/docs/gcs-fuse) works (exotically) but
not backed up officially.

Summary
-------
Jupyter, Python 3 and Dataproc can rock together. We created the [custom
initialization script](https://gist.github.com/vmarkovtsev/e56fe77562037460585d4de690040da8)
and improved the integration with Google Cloud with our [JGSCM](https://github.com/src-d/jgscm).