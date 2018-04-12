---
author: campoy
date: 2018-04-10
title: "Calling C functions from BigQuery with Web Assembly"
draft: false
image: /post/c-on-bigquery/banner.png
description: "As part of our experimentations at source{d}, we decided to try and run a C library on BigQuery. Learn this blog post to see how web assembly came to the rescue, and what other improvements we had to apply to achieve decent performance."
categories: ["culture", "technical", "why-i-joined"] 
---

![BigQuery + C = ❤️](/post/c-on-bigquery/banner.png)

Have you ever used [BigQuery](https://cloud.google.com/bigquery/)?
If you have never used it you're missing out on one of my favorite products of Google Cloud Platform.
It has the power to query terabytes of data in seconds while exposing a familar SQL API.

At source{d} we have terabytes of data, so wouldn't it be cool if we could simply store our datasets on BigQuery
and let anyone easily analyze those?
Well, that's a great idea, but it turns out that our datasets become extra useful when you start analyzing
[Universal Abstract Syntax Trees (UASTs)](https://doc.bblf.sh/uast/specification.html) rather than lines of code.

No problem, you say. Let's store those UASTs and use our querying library [libuast](https://github.com/bblfsh/libuast)
to extract the relevant pieces of those trees. But how could you even do that?
`libuast` is written in `C`, and rewriting to ... `SQL`? That's out of the question!

## BigQuery User Defined Functions

BigQuery supports SQL, and as such, it supports [User Defined Functions (UDFs)](https://cloud.google.com/bigquery/docs/reference/standard-sql/user-defined-functions).
UDFs allow you to define new functions in languages other than SQL, one of them is Javascript.
From the BigQuery console you can click on the `UDF` button and you will see the following screen:

![UDF editor](/post/c-on-bigquery/udf-editor.png)

As you can see, you can write some Javascript in here and use it from your SQL statement.
Let's try to write a simple function that adds two numbers is Javascript. That's what Javascript was created for, right?

This is using Legacy SQL, we'll see later why Standard SQL would make it much harder for us.

{{% code src="/post/c-on-bigquery/udf.js" lang="javascript" %}}
{{% code src="/post/c-on-bigquery/udf.sql" lang="sql" %}}

This is cool, but can we do it over multiple values?

{{% code src="/post/c-on-bigquery/udf-mult.js" lang="javascript" %}}
{{% code src="/post/c-on-bigquery/udf-mult.sql" lang="sql" %}}

Great, so we can basically write any Javascript and have it executed as part of our SQL queries.
Unfortunately for us, the library that I would like to call (libuast) is actually written in C!

How to solve this conundrum? Enter wasm.

## Web Assembly

Web Assembly (a.k.a wasm) is a relatively new technology that proposes an assembly language for the web.
Javascript can be compiled to this assembly, but many other languages, such as C, Rust, and hopefully soon Go,
can also be compiled to highly efficient web assembly code.

Could we maybe compile our C libraries to wasm and then load them from Javascript?
Well, it's technically possible and that's how much I need to give it a try.

### Compiling C

Compiling C programs is an incredibly interesting topic.
Lots can be said, but I will keep it to the basics and talk about what objects are,
how to build them, and how to link them either statically or dynamically.

If you already know all of this feel free to skip this part and move directly to how
to compile C to wasm.

{{% code src="/post/c-on-bigquery/sum.c" lang="c" %}}

We can compile this piece file into a library.

```bash
> clang -c sum.c
> file sum.o
sum.o: Mach-O 64-bit object x86_64
```

In order to compile I wrote a `main` function that predeclares `sum` and calls it.

{{% code src="/post/c-on-bigquery/main.c" lang="javascript" %}}

When we compile and execute this program the output is the answer to everything.

```bash
> clang -o main main.c sum.o
> ./main
42
```

When we compile it in this way we are letting the C linker unify the `sum` declared in
`main.c` and realize that it is the same as the one defined in `sum.c`.
This is static linking, but we could also do something similar with dynamic linking,
letting the binary find and identify `sum` at runtime.

{{% code src="/post/c-on-bigquery/dynamic.c" lang="c" %}}

```bash
> clang sum.o -shared -o sum.so
> file sum.so
sum.so: Mach-O 64-bit dynamically linked shared library x86_64
> clang -o dynamic dynamic.c
> ./dynamic
```

Try it yourself, what happens if you delete `sum.o` and run `main`?
What if you delete `sum.so` and run `dynamic`?

### Compiling C to wasm

Now that we understand how to dynamically load and execute shared objects,
let's talk about wasm.
In wasm we are going to generate a shared object from `sum.c`, but one that
rather than being destined to be read by C it is for wasm.

The easiest way I've seen to use `emcc` (also known as [emscripten](http://emscripten.org)) is with
the Docker image docker `apiaryio/emcc`.
If you want to learn more detail on how to use the tool I recommend this [Google Codelab on Web Assembly](https://codelabs.developers.google.com/codelabs/web-assembly-intro).

But for now let's just use it! If you run this command from the directory containing `sum.c`
you will create two new files [sum.js](/post/c-on-bigquery/sum.js) and [sum.wasm](/post/c-on-bigquery/sum.wasm).

```bash
> docker run --rm -v $(pwd):/src apiaryio/emcc emcc -s WASM=1 -s ONLY_MY
_CODE=1 -s EXPORTED_FUNCTIONS="['_sum']" -o sum.js sum.c
```

`sum.js` contains code to load the object in `sum.wasm`, but we will not use that really.
The one we care about is `sum.wasm`.

Let's now write a `main.js` that loads the `wasm` file and uses its `sum` function.

{{% code src="/post/c-on-bigquery/main.js" lang="javascript" %}}

The code might seem complex, but if you ignore all the code before the call to `fs.readFile`
you'll see that we load `sum.wasm`, extract the function `sum`, and simply call it.
This is quite similar to what we did with C in the previous section.

### So ... does this work on BigQuery?

Being able to call C functions from Javascript is obviously cool.
But that doesn't necessarily solve our problem if `WebAssembly` can't be used on BigQuery!

On my first try, I simply check to see if `WebAssembly` was even defined in the environment.

{{% code src="/post/c-on-bigquery/check.js" lang="javascript" %}}
{{% code src="/post/c-on-bigquery/check.sql" lang="sql" %}}

Not sure why I need to define an input to `checkAssembly`, but if I don't I get an error.
When I execute this query the result is `true`. Success, `WebAssembly` is available!


### Uploading sum.wasm

How could I upload `sum.wasm` to BigQuery?
Rather than trying to see whether I can upload the file somewhere (probably Google Cloud Storage), or whether I can fetch it from a remote URL, I decided that the easiest way
was to simply embed the bytes of `sum.asm` into the Javascript code.

How? Well, first of all I wrote a little Go program that generates a Javascript declaration containing the bytes in `sum.wasm`.

{{% code src="/post/c-on-bigquery/main.go" lang="go" %}}

Now I can run the program and use the result inside of our `main.js`.

```bash
$ go run main.go < sum.wasm
const bytes = new Uint8Array([0, 97, 115, 109, 1, 0, 0, 0, 1, 139, 128, 128, 128, 0, 2, 96, 1, 127, ...
```

{{% code src="/post/c-on-bigquery/embed.js" lang="javascript" %}}

```bash
> node embed.js
42
```

Amazing! So ... let's run it on BigQuery!

In our UDF editor we're going to adapt the program we just wrote, so it becomes a function BigQuery can call.

{{% code src="/post/c-on-bigquery/final.js" lang="javascript" %}}

And our query will simply add two numbers:

{{% code src="/post/c-on-bigquery/final.sql" lang="SQL" %}}

We run it and the result is `42`!

![final screenshot](/post/c-on-bigquery/final.png)

This query processed 0 bytes and ... took 3.7 seconds?

At this point it was time to celebrate / brag / complain!

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">OMG I just ran a function written in C on <a href="https://twitter.com/hashtag/BigQuery?src=hash&amp;ref_src=twsrc%5Etfw">#BigQuery</a> by using <a href="https://twitter.com/hashtag/webassembly?src=hash&amp;ref_src=twsrc%5Etfw">#webassembly</a> 🔥🔥🔥<br><br>The only problem? It takes 3 seconds to simply double a number 😩<br>cc <a href="https://twitter.com/felipehoffa?ref_src=twsrc%5Etfw">@felipehoffa</a><br><br>gist: <a href="https://t.co/O8IaNrEggj">https://t.co/O8IaNrEggj</a> <a href="https://t.co/gB0bH5tfII">pic.twitter.com/gB0bH5tfII</a></p>&mdash; Francesc (@francesc) <a href="https://twitter.com/francesc/status/951935862467514368?ref_src=twsrc%5Etfw">January 12, 2018</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

### Making it go faster

BigQuery is not necessarily fast when you take into account its latency, but it's incredibly
fast when you measure its throughput!

Taking that into account [Felipe Hoffa](https://twitter.com/felipehoffa), Developer Advocate for Google Cloud Platform and
a long time friend of mine, helped me make my code much *much* faster.

And guess what, he wrote about it! So now it's time for you to go read
[BigQuery beyond SQL and JS: Running C and Rust code at scale](https://medium.com/@hoffa/bigquery-beyond-sql-and-js-running-c-and-rust-code-at-scale-33021763ee1f).