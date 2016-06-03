--- 
author: vadim
date: 2016-06-03
title: "Never mess with LD_LIBRARY_PATH to run your CUDA app again" 
draft: true 
image: /post/cuda_ldconfig/intro.png
description: "Simple and easy way to install CUDA and CUDNN system-wide." 
--- 

If you are using [CUDA](https://en.wikipedia.org/wiki/CUDA) on Linux then
the following must be familiar:
```
~/.bashrc

...

export LD_LIBRARY_PATH=/usr/local/cuda-7.5/lib64

# or even smarter

export LD_LIBRARY_PATH=/usr/local/cuda-7.5/lib64:$LD_LIBRARY_PATH
```
This solves the problem with CUDA libraries search path and allows to
actually run CUDA-powered programs. Every time you execute a program, the
dynamic linker (GNU ld) reads the imported symbols table from the
executable container (ELF) and has a hard time trying to load them from
shared libraries available in the system (\*.so). If it fails then the program
will not start running. ELF carries the list of library names which should
contain the imports, so that the loader does not end up with probing
*every* library out there. You can view that dependency list using `ldd`
command:
```
$ ldd /bin/ls
	linux-vdso.so.1 =>  (0x00007ffd27ffb000)
	libselinux.so.1 => /lib/x86_64-linux-gnu/libselinux.so.1 (0x00007f4823fa8000)
	libacl.so.1 => /lib/x86_64-linux-gnu/libacl.so.1 (0x00007f4823da0000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f48239db000)
	libpcre.so.3 => /lib/x86_64-linux-gnu/libpcre.so.3 (0x00007f482379d000)
	libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f4823599000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f48241cb000)
	libattr.so.1 => /lib/x86_64-linux-gnu/libattr.so.1 (0x00007f4823394000)
```
Shared libraries are searched in several paths. Some of them are stored
in ELF itself, some of them are not. In the latter case, common library
search paths are scanned. They usually include "/lib", "/usr/lib", etc.
The current list of library search paths can be printed with
```
$ ld --verbose | grep SEARCH_DIR | sed -E 's/("\); |"\);|)(SEARCH_DIR\("=?|$)/\n/g' | head -n -1 | tail -n +2
/usr/x86_64-linux-gnu/lib64
/usr/local/lib/x86_64-linux-gnu
/usr/local/lib64
/lib/x86_64-linux-gnu
/lib64
/usr/lib/x86_64-linux-gnu
/usr/lib64
/usr/local/lib
/lib
/usr/lib
```
GNU dynamic loader supports hacking into library loading and searching
procedures. LD_PRELOAD, for example, forces `ld` to load the given libraries
before normally loading any others. LD_LIBRARY_PATH extends the list
of library search paths.

Sometimes, libraries are installed into some non-standard directories,
as with CUDA. If the target binaries were not built with explicit
mentioning those directories so that they crawl into ELF library search
paths (-L option of gcc), then you are in trouble. Every time you attempt
to run such program, the dependent libraries are not found and you fail.
That is why usually people apply hacks with LD_LIBRARY_PATH then.

Is there any other solution? Yes.

An interesting question is, how `ld` knows about the list of common library
search paths. It shouldn't be hardcoded, right? Sure. This is when
`ldconfig` comes out. It builds the special configuration file, usually
`/etc/ld.so.cache`, which is picked up by the dynamic loader every time
a program needs to start. `ldconfig` reads the paths from the configuration
file, `/etc/ld.so.conf`, which usually includes files from `/etc/ld.so.conf.d`.
```
$ ls /etc/ld.so.conf.d
fakeroot-x86_64-linux-gnu.conf  libc.conf              x86_64-linux-gnu_EGL.conf  zz_i386-biarch-compat.conf
i386-linux-gnu_GL.conf          x86_64-linux-gnu.conf  x86_64-linux-gnu_GL.conf
```
Now the solution is clear: let's create a new configuration file for
`ldconfig`, say, `/etc/ld.so.conf.d/cuda.conf`, with the path from LD_LIBRARY_PATH:
```
/usr/local/cuda-7.5/targets/x86_64-linux/lib
```
Then run `sudo ldconfig` and voila!

Amazingly few people know about this, and even
[CUDA FAQ](http://www.cs.colostate.edu/~info/cuda-faq.html)
suggest augmenting LD_LIBRARY_PATH instead - bummer. Of course,
CUDA users should not experience troubles at all and CUDA maintainers
should definitely include `/etc/ld.so.conf.d/cuda.conf` into the
distribution package. Alternatively, end-user CUDA applications should be
compiled with `-L /usr/local/cuda-7.5/lib64` since 99% folks do not
change the default installation root (hey, Tensorflow!).
