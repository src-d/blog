# source{d} blog
[![Build Status](https://drone.srcd.host/api/badges/src-d/landing/status.svg)](https://drone.srcd.host/src-d/landing)
[![Docker Repository on Quay](https://quay.io/repository/srcd/blog/status "Docker Repository on Quay")](https://quay.io/repository/srcd/blog)

This is our [blog](https://blog.sourced.tech) source.

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

You need to satisfy the [project requirements](#requirements), and then to run:

```shell
make build;
```

# Contributing

If you want to contribute to this project, you will find more info in the [CONTRIBUTING.md](CONTRIBUTING.md)

# License

Copyright (c) 2015 Máximo Cuadros, see [LICENSE](LICENSE)