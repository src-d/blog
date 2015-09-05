+++
title = "Working with autohugo"
slug = "working-with-autohugo"
menu = "main"
+++

**autohugo** is made with [make](https://es.wikipedia.org/wiki/Make) and a couple of environment variables. In this document you can understand how it works.

## The environment variables
- `HUGO_VERSION`: defines the **hugo** version to be used.
- `HUGO_THEME`: URL of the git repository (with the `https://` prefix) of the theme, you can choose one from [`hugoThemes`](https://github.com/spf13/hugoThemes/) or [create](https://gohugo.io/themes/creation/) your one.
- `GIT_COMMITTER_NAME` and `GIT_COMMITTER_EMAIL`: the name and the email to be used in the commit to `gh-pages`.

> Not edit the Makefile itself, please us environment variable at the `circle.yml` for change the configuration.

> ProTip: You can pass the environment variables to make without setting is globally: ```HUGO_THEME=http://github.com/mcuadros/hyde make server```

## The Makefile
- `make dependencies`: installs `hugo` on a local folder, by default `.hugo`. Also download the configured theme at the `themes` folder.
- `make build`: generates the website calling `hugo` command.
- `make server`: runs a web server at the url `http://localhost:1313/`, this command is very useful when you are creating new command, refreshing the site every time a file is changed.
- `make publish`: this command deletes the branch `gh-pages` from you repository and creates a new one with the content of the `public` folder. *This command only can be called on the CircleCI environment*

> You need `make` installed in order to work with **autohugo**.
