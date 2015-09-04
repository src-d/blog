+++
title = "Creating your own site"
slug = "creating-your-own-site"
menu = "main"
+++

### Setting the repository
The best way to archive this is forking the [`autohugo`](https://github.com/mcuadros/autohugo) repository. This repository will host your [Markdown](https://es.wikipedia.org/wiki/Markdown) files and the hugo config file.

### Setting CircleCI
CircleCI takes care of the branch `gh-pages`, deploying the new version of the HTML every time you make a push to your repository in the [Github Pages](https://pages.github.com/) branch.

1. Login on [CircleCI](https://circleci.com/) using you Github account.
2. Register you repository at CircleCI clicking on [`Add Projects`](https://circleci.com/add-projects) and choosing your repository.

3. Now you need to allow to CircleCI to make pushes to your `gh-pages` branch, so just go to CircleCI, in `Project Settings` > `Checkout keys` click on the big green button `Authorize w/ Github`, then a new button with emerge called `Create and add your/repository deploy key` click on it also, this will create a token write access, allowing to CircleCI write on your repository.


### Configuring Hugo
Hugo is a static website engine, transforms your Markdown files into beautiful websites.

1. Configure a theme for your new site, you can choose one at [`hugoThemes`](https://github.com/spf13/hugoThemes/) repository, set the theme's repository URL (with the `http://` prefix) at the file `circle.yml`.

2. Put the your content at the directory `content`, read more about the scaffolding at the [`content section`](https://gohugo.io/content/organization/) in the hugo documentation.

3. Configure the `config.yaml` this file containts the hugo configuration, there you can config for example the site name.

If you are not familiar with the `hugo` scaffolding and confiration take a look to the hugo [`documentation`](https://gohugo.io/overview/introduction/)

### Publishing the site
This is the easiest part, thanks to [Github Pages](https://pages.github.com/) all the content in the `gh-pages` branch from you repository is available via HTTP at:

 **http://\<username>.github.io/\<repository>**.

Since now every time you make a push to your repository with new content, the HTML will be generated and uploaded to the `gh-pages` thanks to `CircleCI`

> The Markdown files on content as well as the `config.yaml` are examples, feel free to change any you want.
