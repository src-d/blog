# source{d} blog
[![Build Status](https://drone.srcd.host/api/badges/src-d/landing/status.svg)](https://drone.srcd.host/src-d/landing)
[![Docker Repository on Quay](https://quay.io/repository/srcd/blog/status "Docker Repository on Quay")](https://quay.io/repository/srcd/blog)

This is the repository for the [source{d} blog](https://blog.sourced.tech), which generates styled static HTML from markdown files.

If you came here to learn how to set up the blog in your computer, to write/preview/deploy a new blog post, you should check:
- [Blog setup requirements](#requirements) and [Build](#build)
- [How to contribute](#contributing)


# Requirements

You need to have [Yarn installed](https://yarnpkg.com/en/docs/install) to build the js and css assets. It also lets you locally serve the blog to test and validate it while you are developing.

You can ensure if it is available in your machine running:
```shell
yarn --version; # prints your Yarn version
```

The blog also uses:
- [Hugo](http://gohugo.io): to build the static html from the markdown content files; it is automatically downloaded and installed at building time.
- [Caddy](https://caddyserver.com): to serve the static files in production; it is provided by the caddy docker image

# Build

You need to satisfy the [project requirements](#requirements), and then run from the project root:

```shell
make build;
```

It will generate all the static files that will be served by the Caddy server from the docker image. In case you only want to preview the blog, you can read the [Preview the blog](#preview-the-blog) section

# Preview the blog

To locally serve the blog, you need to satisfy the [project requirements](#requirements), and then run from the project root:

```shell
make serve;
```
Finally, go to [http://localhost:8484](http://localhost:8484)

# Contributing

If you want to contribute to this project, or to write or edit a blog post, you will find more info in the [contribution guidelines](CONTRIBUTING.md).


# License

Copyright (c) 2015 Máximo Cuadros, see [LICENSE](LICENSE)