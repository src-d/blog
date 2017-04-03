---
author: vadim
date: 2017-03-31
title: "Using Docker & CoreOS For GPU Based Deep Learning"
draft: false
image: /post/docker_coreos_gpu_deep_learning/intro.png
description: "A GPGPU computing environment can be set up nicely inside a Docker container using CoreOS. Our way to setup deep learning is efficient and brings benefits to devops and data scientists."
---
<style>
p.dt {
  margin-top: -16px;
  font-style: italic;
}
</style>

Having confidence in your research and development environment is essential if you want to
solve challenging problems. This post shows how to setup containers for deep learning,
have `numpy` accelerated and finally speculates about hosting in the cloud vs. on-premise.

To give you a bit of background, at source{d}, the ML team is running constant experiments with Python scripts and Jupyter notebooks which extensively use CUDA + NVIDIA GPUs. For example: 

- Training a deep neural network to write source code with Keras/Tensorflow
- Applying [minhashcuda](https://github.com/src-d/minhashcuda) to a large [bag-of-words dataset](https://data.world/vmarkovtsev/github-duplicate-repositories)
- Clustering all developers in the world with [kmcuda](https://github.com/src-d/kmcuda).

We decided to share some of our learnings and configuration files. 

### R&D in containers

![What do we want](/post/docker_coreos_gpu_deep_learning/what_do_we_want.png)
<p align="center" class="dt">People want reproducible data science environment.</p>

Typically, deep learning researchers run their stuff using [Ubuntu](https://ubuntu.com) 
as the host OS. If you want to scale or reproduce your work with the standard Ubuntu setup, you are left with these three options:

1. Clone the disks, grab exactly the same hardware configuration, deploy the copy.
Complete hell if your environment evolves every day (it does).
2. Use some configuration management system and pay a considerable amount
of human resources to maintain the configs. Complete hell if you have a complex
setup of new machines (latest CUDA? Of course.).
3. Fix the global environment, restrict to change it and become drawn in
`virtualenv`-s. This leads to environmental anarchy which I personally witnessed
in large companies. Complete hell if the system administrator's latency is greater
than 0 (it always is) and the team uses native extensions (it does).

There is a modern, reliable way to solve the reproducibility problem: use
containers, Luke. We can run something Spartan like [CoreOS](https://coreos.com/)
as the host OS and give researchers access to containers with their beloved
Ubuntu. The containers are not persistent, and there is no need in messing with
`virtualenv` at all - instead, everybody can safely torture the OS in the container
any way they want. All the instances of the container are the same initially,
contain the same proper compiled and configured libraries, same tools and same
access to the persistent disk storage. As a bonus, it becomes super easy to
deploy the developed machine learning models using the same containers they were
created in.

### NVIDIA CUDA in containers

However, one needs to solve some technical issues to follow this path. The first
step and most important one is passing CUDA devices inside the container.
There is a solution from NVIDIA: [nvidia-docker](https://github.com/NVIDIA/nvidia-docker).
In our opinion it is not the right approach. The drawbacks are:

1. Having to use `nvidia-docker` instead of the standard `docker`. We claim that
everything can be set up properly without introducing a separate tool and running
an additional service.
2. It requires a NVIDIA driver installation in the host OS. CoreOS does not allow
you to do that. Remember, CoreOS does not have a compiler, kernel headers, etc. or a 
package manager. CoreOS is basically just a systemd with bash, coreutils and
Docker. Its intended usage is doing everything in the containers (and we love this!).

Our solution is different. We take an intermediate container, compile and
install the DKMS driver there, `modprobe` it. Shut down the container. Since
the kernel is shared, the devices remain alive. We launch the
payload containers with the needed userspace and mapped NVIDIA devices afterwards.

This is the `Dockerfile` for the intermediate container named `src-d/nvidia-driver`:

```
FROM ubuntu:16.04
MAINTAINER source{d} 

ENV DRIVER_VERSION 367.57

RUN apt-get -y update \
    && apt-get -y install wget git bc make dpkg-dev libssl-dev module-init-tools \
    && apt-get autoremove \
    && apt-get clean

# kernel modules
RUN  mkdir -p /usr/src/kernels \
    && cd /usr/src/kernels \
    && git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git --single-branch --depth 1 --branch v`uname -r | sed -e "s/-.*//" | sed -e "s/\.[0]*$//"`  linux \
    && cd linux \
    && git checkout -b stable v`uname -r | sed -e "s/-.*//" | sed -e "s/\.[0]*$//"` \
    && zcat /proc/config.gz > .config \
    && make modules_prepare \
    && sed -i -e "s/`uname -r | sed -e "s/-.*//" | sed -e "s/\.[0]??*$//"`/`uname -r`/" include/generated/utsrelease.h # In case a '+' was added

# NVIDIA driver
RUN mkdir -p /opt/nvidia && cd /opt/nvidia/ \
    && wget http://us.download.nvidia.com/XFree86/Linux-x86_64/${DRIVER_VERSION}/NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run -O /opt/nvidia/driver.run \ 
    && chmod +x /opt/nvidia/driver.run \
    && /opt/nvidia/driver.run -a -x --ui=none

ENV NVIDIA_INSTALLER /opt/nvidia/NVIDIA-Linux-x86_64-${DRIVER_VERSION}/nvidia-installer
CMD ${NVIDIA_INSTALLER} -q -a -n -s --kernel-source-path=/usr/src/kernels/linux/ \
    && modprobe nvidia \
    && modprobe nvidia-uvm


# ONBUILD, we install the NVIDIA driver and the cuda libraries 
ONBUILD ENV CUDA_VERSION 8.0.44

ONBUILD RUN /opt/nvidia/driver.run --silent --no-kernel-module --no-unified-memory --no-opengl-files
ONBUILD RUN wget --no-check-certificate http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_${CUDA_VERSION}-1_amd64.deb \
    && dpkg -i cuda-repo-ubuntu1604_${CUDA_VERSION}-1_amd64.deb \
    && apt-get -y update \
    && apt-get -y install --no-install-suggests --no-install-recommends \
        cuda-command-line-tools-8.0 \
        cuda-nvgraph-dev-8.0 \
        cuda-cusparse-dev-8.0 \ 
        cuda-cublas-dev-8.0 \
        cuda-curand-dev-8.0 \
        cuda-cufft-dev-8.0 \
        cuda-cusolver-dev-8.0 \
    && sed -i 's#"$#:/usr/local/cuda-8.0/bin"#' /etc/environment \
    && rm cuda-repo-ubuntu1604_${CUDA_VERSION}-1_amd64.deb \
    && cd /usr/local/cuda-8.0 && ln -s . cuda \
    && wget http://developer.download.nvidia.com/compute/redist/cudnn/v5.1/cudnn-8.0-linux-x64-v5.1.tgz \
    && tar -xf cudnn-8.0-linux-x64-v5.1.tgz \
    && rm cudnn-8.0-linux-x64-v5.1.tgz
    
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/cuda-8.0/bin
```

We are using the [ONBUILD](https://docs.docker.com/engine/reference/builder/#onbuild)
trigger here to lazily update the child containers. As you see, some versions
are hardcoded which is unfortunate. This is the payload `Dockerfile` aka `src-d/science` 
for one of our R&D machines (full file later in the post):

```
FROM src-d/nvidia-driver
...
```

Our hardware setup has two GPUs which were inserted in the proper slots to enable peer to
peer memory exchange. We initially hit a nasty bug with [Intel IOMMU](https://www.kernel.org/doc/Documentation/Intel-IOMMU.txt).
Particularly, when we invoked `cudaMemcpyPeer()`, it hanged and `dmesg` showed

```
[16193.612535] DMAR: DRHD: handling fault status reg 602
[16193.617662] DMAR: [DMA Write] Request device [82:00.0] fault addr 387fc000c000 [fault reason 05] PTE Write access is not set
[16193.661857] DMAR: DRHD: handling fault status reg 702
[16193.666976] DMAR: [DMA Write] Request device [82:00.0] fault addr f8139000 [fault reason 05] PTE Write access is not set
```

The container ran with `--privileged --security-opt seccomp=unconfined` so the problem
was not with the permissions. We applied the workaround described in the
[bug report](https://bugzilla.kernel.org/show_bug.cgi?id=188271): add
`intel_iommu=igfx_off` to the kernel boot arguments. It solved the problem and peer-to-peer
GPU memory access started to work.

Finally, this is how we run the container:

```
docker run --rm -it -v/data:/data --device /dev/nvidiactl --device /dev/nvidia0 --device /dev/nvidia1 --device /dev/nvidia-uvm --privileged src-d/science bash
```

### numpy with MKL and cuBLAS

We are using Python for our research. It is critical for us to achieve the best
performance of `numpy` and `scipy` packages. The following `Dockerfile` explains
how we compile `numpy` and `scipy` to link them to [BLAS](https://en.wikipedia.org/wiki/Basic_Linear_Algebra_Subprograms)
implementation in [Intel Math Kernel Library](https://software.intel.com/en-us/intel-mkl)
(free for commercial usage) and dynamically override MKL with
[nvBLAS](http://docs.nvidia.com/cuda/nvblas/#axzz4cp61zlk9) to get CUDA-accelerated BLAS.
nvBLAS is not a complete BLAS implementation so we have to fallback to MKL.

```
FROM src-d/nvidia-driver
MAINTAINER source{d}

RUN echo "deb http://ppa.launchpad.net/maarten-fonville/ppa/ubuntu yakkety main" > /etc/apt/sources.list.d/maarten-fonville-ubuntu-ppa-xenial.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 4DEA8909DC6A13A3 \
    && apt-get update \
    && apt-get -y install build-essential pkg-config cython3 \
        python3-dev libjpeg-turbo8-dev libpng-dev libfreetype6-dev libxft-dev \
	libprotobuf-dev libfftw3-dev libsnappy-dev libgit2-dev zlib1g-dev python3-cffi \
	mercurial curl cpio gfortran nano lzop libcairo2 gdb lldb \
    && apt-get clean

# install pip3
RUN curl https://bootstrap.pypa.io/get-pip.py | python3

# install mkl
# 
# silent.cfg documentation:
# https://software.intel.com/en-us/articles/intel-mkl-111-install-guide
ADD etc/silent.cfg /opt/intel/
ADD etc/mkl.lic /opt/intel/licenses
# curl -O http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/9662/l_mkl_2017.0.098.tgz
ADD mkl/l_mkl_2017.0.098.tgz .
RUN l_mkl_2017.0.098/install.sh --silent /opt/intel/silent.cfg \
    && rm -rf l_mkl_2017.0.098* \
    && printf '/opt/intel/mkl/lib/intel64_lin\n/opt/intel/lib/intel64_lin' >> /etc/ld.so.conf.d/mkl.conf \
    && ldconfig


# install numpy, scipy and others
ADD etc/numpy-site.cfg /root/.numpy-site.cfg
ENV NPY_NUM_BUILD_JOBS 16
RUN pip3 -v install numpy scipy --no-binary numpy --no-binary scipy

RUN pip3 install https://storage.googleapis.com/tensorflow_sourced/tensorflow-1.0.1-cp35-cp35m-linux_x86_64.whl \
    && pip3 install requests pymongo sklearn pandas nltk ipython jupyter seaborn matplotlib networkx datasketch \
                    cuda4py libMHCUDA libKMCUDA fbpca keras h5py lapjv flask cairocffi Pillow-SIMD \
    && python3 -c "import matplotlib; matplotlib.use('Agg'); import matplotlib.pyplot" \
    && mkdir /root/.jupyter/ && echo 'c.NotebookApp.token = ""' > /root/.jupyter/jupyter_notebook_config.py
    
# setup nvBLAS
ADD etc/nvblas.conf /
ENV NVBLAS_CONFIG_FILE /nvblas.conf
ENV LD_PRELOAD /usr/local/cuda-8.0/targets/x86_64-linux/lib/libnvblas.so
 
CMD ipython3
```

`etc/silent.cfg`:

```
ACCEPT_EULA=accept
CONTINUE_WITH_OPTIONAL_ERROR=yes
PSET_INSTALL_DIR=/opt/intel
CONTINUE_WITH_INSTALLDIR_OVERWRITE=yes
PSET_MODE=install
ACTIVATION_TYPE=trial_lic
PHONEHOME_SEND_USAGE_DATA=no
ARCH_SELECTED=INTEL64
COMPONENTS=ALL
```

`etc/numpy-site.cfg`:

```
[ALL]
extra_compile_args = -O3 -fopenmp -flto -march=native -ftree-vectorize
extra_link_args = -O3 -fopenmp -flto -march=native -ftree-vectorize

[fftw]
libraries = fftw3

[mkl]
library_dirs = /opt/intel/mkl/lib/intel64_lin
include_dirs = /opt/intel/mkl/include
mkl_libs = mkl_rt
lapack_libs = mkl_lapack95_lp64
```

`etc/nvblas.conf`:

```
NVBLAS_LOGFILE /tmp/nvblas.log
NVBLAS_CPU_BLAS_LIB libmkl_rt.so
NVBLAS_GPU_LIST ALL
NVBLAS_TILE_DIM 2048
NVBLAS_AUTOPIN_MEM_ENABLED
```

We run `ldconfig` to install MKL system wide without the need for hacking
`LD_LIBRARY_PATH`. However, we do need to hack `LD_PRELOAD` to insert nvBLAS
before MKL is loaded.

There are some additional perks:

* We are installing our custom optimized Tensorflow build. It does **not** grunt like that:

```
W tensorflow/core/platform/cpu_feature_guard.cc:45] The TensorFlow library wasn't compiled to use SSE3 instructions, but these are available on your machine and could speed up CPU computations.
W tensorflow/core/platform/cpu_feature_guard.cc:45] The TensorFlow library wasn't compiled to use SSE4.1 instructions, but these are available on your machine and could speed up CPU computations.
W tensorflow/core/platform/cpu_feature_guard.cc:45] The TensorFlow library wasn't compiled to use SSE4.2 instructions, but these are available on your machine and could speed up CPU computations.
W tensorflow/core/platform/cpu_feature_guard.cc:45] The TensorFlow library wasn't compiled to use AVX instructions, but these are available on your machine and could speed up CPU computations.
W tensorflow/core/platform/cpu_feature_guard.cc:45] The TensorFlow library wasn't compiled to use AVX2 instructions, but these are available on your machine and could speed up CPU computations.
W tensorflow/core/platform/cpu_feature_guard.cc:45] The TensorFlow library wasn't compiled to use FMA instructions, but these are available on your machine and could speed up CPU computations.
```

* We are installing some packages which we developed ourselves: [kmcuda](https://github.com/src-d/kmcuda),
[minhashcuda](https://github.com/src-d/minhashcuda), [lapjv](https://github.com/src-d/lapjv). You may
read about them in our blog.
* We are running Jupyter as the systemd service and disable the token security since
this machine is not exposed to the internet.

The `Dockerfile` from above is the result of incremental improvements in
`src-d/science` container over the last 6 months. It builds in less than
15 minutes and gives a machine learning engineer <s>an unlimited power</s> and perfect control
of the environment.

### Gotchas

There is a number of gotchas for the users without any prior experience with
CoreOS + containers. I am putting the actual slides from the presentation to
illustrate.

![wasted1](/post/docker_coreos_gpu_deep_learning/wasted1.png)

![wasted2](/post/docker_coreos_gpu_deep_learning/wasted2.png)

### Cloud or on-premise?

The answer to this question depends on the use case and may change from time
to time depending also on cloud prices. Every option has it's pros and cons:
Cloud based hosting simplifies devops, is easier to monitor and more flexible. Your own hardware
with GPU cards is more expensive at the beginning, but quickly pays off -
according to our calculations, within one year. Anyway, here are two excellent
links which can help you to make the decision:

* [Which GPU(s) to Get for Deep Learning: My Experience and Advice for Using GPUs in Deep Learning](http://timdettmers.com/2017/03/19/which-gpu-for-deep-learning/)
* [Computer Build for Deep Learning Applications](http://www.slideshare.net/PetteriTeikariPhD/deep-learning-workstation)

Back in October 2016 our choice was to install custom hardware and we haven't regretted it yet.

[!["science-3" GPU tower](/post/docker_coreos_gpu_deep_learning/science-3-1920.jpg)](/post/docker_coreos_gpu_deep_learning/science-3.jpg)
<p align="center" class="dt">"science-3" GPU tower at source{d}. We use it for deep learning and other experiments.</p>

### Acknowledgements

NVIDIA dockerization was bravely performed by our VP of Engineering, Maximo Cuadros. I learned
a lot from him about containers. Next time you see Maximo on our
[tech talks](http://talks.sourced.tech/), ask for some wisdom!
