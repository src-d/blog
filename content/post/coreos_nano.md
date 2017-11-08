---
author: vadim
date: 2016-11-17
title: "Native GNU nano text editor in CoreOS."
image: /post/coreos_nano/nano_intro.png
description: "CoreOS ships with Vim as the only text editor by default. The following is how to compile GNU nano text editor for CoreOS as a first-class citizen."
categories: ["technical"] 
---

Sometimes, you want to edit text files inside CoreOS. Either you have to use the Vim
editor which is shipped by default or use a container, e.g. Toolbox. I am not a fan
Vim and feel that using a container to launch a text editor for temporal edits
is overkill. I am used to [GNU nano](https://www.nano-editor.org/) and I would like
to use it instead of Vim. Since there is no package manager in CoreOS (and it
shouldn't have one of course), one has to either copy the `nano` binary from a donor container
or compile it from scratch. The binary is linked dynamically in all Linux distributions,
so launching it in CoreOS fails with "library not found" errors. Let's face it:
`nano` must be compiled in order to work with all the features.

![nano](/post/coreos_nano/nano.png)

I am used to Ubuntu, so I will cook `nano` in it's environment. The following supposes
that you have access to the CoreOS command line prompt.

#### Prepare the system
```
# Override toolbox from Fedora to Ubuntu
echo "TOOLBOX_DOCKER_IMAGE=ubuntu" > ~/.toolboxrc
toolbox

# The next commands are issued inside the container
apt build-dep nano
apt install libmagic-dev libgpm-dev wget
wget https://www.nano-editor.org/dist/v2.7/nano-2.7.1.tar.gz
tar -xf nano-2.7.1.tar.gz
cd nano-2.7.1
```
`build-dep` should install the C compiler and all the build dependencies, however,
two extra libraries must be installed: [libmagic](https://github.com/file/file)
enables `nano` to select the syntax highlight scheme based on the edited file's
contents (by the way, `file` command in Linux is based on the same library) and
libgpm is one of the opaque dependencies of [libncurses](https://www.gnu.org/software/ncurses/).
libncurses in turn is the library to create console user interfaces. Basically, every program
which has a console UI uses it: `vim`, `mc`, `less` and `more` and even web browsers like `w3m`.
Usually it is accompanied with [libreadline](https://cnswww.cns.cwru.edu/php/chet/readline/rltop.html),
an essential abstraction layer to work with the terminal prompt, it is used by
Bash, Vim, Python REPL, etc. By the way, every time you press Ctrl-R in the terminal, you use libreadline.

#### Building
```
mkdir build && cd build
# The tricky part
../configure --enable-utf8 --prefix=/opt CFLAGS="-flto -O2 -march=native" LDFLAGS="-static" LIBS="-ltinfo -lgpm -lz"
make -j$(getconf _NPROCESSORS_ONLN)
mkdir install && make install DESTDIR=$(pwd)/install
```

The point is, we **must** compile `nano` statically linked, because CoreOS's `/etc/ldconfig`
library paths are all readonly (e.g., /opt/lib could be a
good candidate but is not listed). `nano`'s dependency libraries are indeed not
present in CoreOS and there is no way to add them nicely (`LD_LIBRARY_PATH`,
`LD_PRELOAD` are hacks which should be avoided). If `nano` was written in Go,
there would be no problem since the Go compiler always links programs statically.
Unfortunately, we have to deal with C.

`nano` is traditional GNU software which is built using
[autotools](https://en.wikipedia.org/wiki/GNU_Build_System) and
[make](https://en.wikipedia.org/wiki/Make_(software)). The build is performed
in three steps:

0. Generate the `configure` script. Usually, maintainers ship it inside the source tarball.
1. Run `configure` script to create the makefiles, check the environment, etc.
2. Run `make` - compile everything.
3. Run `make install` to put the built files into the desired location. Sometimes, libraries get relinked to match the destination directory.

GCC offers a `-static` flag which we can inject via LDFLAGS during the configuration step.
However, it will fail then. The problem is in dependencies: for example,
ncurses depends on libtinfo and it is not linked automatically. The described
situation is total hell in case of large programs with plenty of dependencies.
We are lucky that we've got the tiny `nano`!
```
ldd $(which nano)
    linux-vdso.so.1 (0x00007ffdc091c000)
    libmagic.so.1 => /lib64/libmagic.so.1 (0x00007f6ebe62a000)
    libncursesw.so.6 => /lib64/libncursesw.so.6 (0x00007f6ebe3f1000)
    libtinfo.so.6 => /lib64/libtinfo.so.6 (0x00007f6ebe1c4000)
    libc.so.6 => /lib64/libc.so.6 (0x00007f6ebde01000)
    libz.so.1 => /lib64/libz.so.1 (0x00007f6ebdbeb000)
    libdl.so.2 => /lib64/libdl.so.2 (0x00007f6ebd9e6000)
    /lib64/ld-linux-x86-64.so.2 (0x00005597ae3f0000)
```
The dependencies can be added manually and this is what I did with setting LIBS.
libc and libdl are not needed to append - they are system stuff.

Finally, CFLAGS activates [link time optimization](https://en.wikipedia.org/wiki/Interprocedural_optimization)
which is a must-have if you link statically, sets optimization level and allows
the compiler to optimize for the current hardware.

#### Installing
```
mkdir /media/root/opt/{bin,share,etc}
cp install/opt/bin/nano /media/root/opt/bin
cp -r install/opt/share/nano /media/root/opt/share
echo "include /opt/share/nano/*.nanorc" > /media/root/opt/etc/nanorc
```
Here we are using the fact that CoreOS lists `/opt/bin` in `PATH` and effectively
allows adding your custom binaries. Additionally, we write the nanorc configuration
to activate syntax highlight rules.

That's it!
```
nano --version
 GNU nano, version 2.7.1
 (C) 1999..2016 Free Software Foundation, Inc.
 (C) 2014..2016 the contributors to nano
 Email: nano@nano-editor.org	Web: https://nano-editor.org/
 Compiled options: --enable-utf8
```
[Binary download link.](https://drive.google.com/open?id=0B-w8jGUJto0iNzVBakZ3UUxLZGs)

#### Now seriously
As we saw, it is possible to statically link C/C++ programs in pretty much the
same way Go does it. In Go, you execute `go get` and you are done. In C, you
have to be a good system programmer and to spend an hour struggling with the compiler.
My next text editor will be written in Go for sure... or Vim.
