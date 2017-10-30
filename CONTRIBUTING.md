# Contributing

Please,
- [open an issue](https://github.com/src-d/blog/issues) to request any new feature or to report a bug.
- [create a new PR](https://github.com/src-d/blog/pulls) to request the review of a new post or feature.

## Preview the blog posts

You need to satisfy the [project requirements](README.md#requirements), and then to run:

```shell
make serve;
```
and then, go to [http://localhost:8484](http://localhost:8484)

## Content schema

```
---
author: authorKeyName
date: 2006-01-02
title: "Post title"
draft: false
image: /post/__POST_FILE_NAME__/header-image.png
description: "Short description of the post"
categories: ["science", "technical", "culture"]
---

Whatever content in `markdown` format.

```

### Front matter

The **front matter** is the section inside the content file where it is defined the content metadata.
[Front Matter section](https://gohugo.io/content-management/front-matter)

- `author`: defines the authorship as explained in the [authors section](#authors)
- `date`: Creation date in `2006-01-02` format. Do not forget to update it before merging the PR!!
- `title`: Post title, as it will appear in the very top of the content
- `draft`: It must be always `false` (unless you know what you're doing)
- `image`: Defines the content listing image as explained in the [assets section](#assets)
- `description`: Short description of the post
- `categories`: An array of at least one of the following: `science`, `technical`, `culture`. If it is not defined, it will not be served by the json blog api, so it will not appear in the source{d} landing.

## Create new contents

Create a new post under `post` content directory

In case you want to share any "draft" with your mates during the PR review phase, store it under the `upcoming` directory. You should NEVER publicly share the "upcoming" url. Ensure the content is under the `post` directory before merging the PR and publishing the new content.

## Formatting the content

It is not allowed to use HTML tags to format the content of the blog.

If you want/need special formatting for your content, please read the [shortcodes tutorial](https://blog.sourced.tech/documentation/shortcodes)

## Assets

>>>>>> `/post/__POST_FILE_NAME__/header-image.png`

## Authors

Every post entry must define its authorship; to do so, in the content [Front Matter section](#front-matter) it is needed to define the `author` key. 

The `author` key will be one of the authors defined by [the hugo config](config.yaml), at the `authors` section..

The authors entries in the `authors` section follows this schema:
```yaml
authorKeyName:
  name: Author Name and Surname
  thumbnail: https://avatars1.githubusercontent.com/u/__USER_ID__
  bio: "Short bio/description of the author"
  social:
    github: authorUserName
    twitter: authorTwitterHandler
```

## How to publish blog posts and deploy the blog

Validate every new contents with a PR, that will be validated by, at least:
- [vmarkovtsev](//github.com/vmarkovtsev) the content,
- [platform](https://github.com/orgs/src-d/teams/platform/members) the layout.

The blog is published automatically following the source{d} [Continous Delivery rules for web applications](https://github.com/src-d/guide/blob/master/engineering/continuous-delivery.md)
