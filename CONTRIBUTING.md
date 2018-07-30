# Contributing

You will find here the conventions and rules to publish new blog posts and to develop new blog features and enhancements.

Please,
- [open an issue](https://github.com/src-d/blog/issues) to request any new feature or to report a bug.
- [create a new PR](https://github.com/src-d/blog/pulls) to request the review of a new post or feature.


## Table of contents

<!-- TOC -->

- [Propose a new blog post](#propose-a-new-blog-post)
- [Creating a new post](#creating-a-new-post)
    - [Content schema](#content-schema)
    - [Front matter](#front-matter)
    - [Formatting the content](#formatting-the-content)
    - [Links to other source{d} blog posts](#links-to-other-sourced-blog-posts)
    - [Assets](#assets)
    - [Authors](#authors)
- [Preview the blog posts](#preview-the-blog-posts)
    - [Troubleshoot](#troubleshoot)
- [Peer review](#peer-review)
- [How to publish blog posts and deploy the blog](#how-to-publish-blog-posts-and-deploy-the-blog)
- [Publishing and promoting a blog post](#publishing-and-promoting-a-blog-post)

<!-- /TOC -->

## Propose a new blog post

The first step on the process to release a blog post is to reach general agreement on whether the topic
and general structure of the blog post makes sense. This will help you structure your blog post early and
avoid wasting any time by receiving feedback too late.

We use a very similar approach to [src-d/conferences](https://github.com/src-d/conferences), using issues
and PRs as a way to track and approve proposals.

Whenever you have a new idea for a blog post simply create a new issue following the
[post issue template](.github/ISSUE_TEMPLATES/post.md), you can also simply click
[here](https://github.com/src-d/blog/issues/new?template=post.md).

[![propose new blog post](https://svg-badge.appspot.com/badge/PROPOSE%20NEW%20BLOG%20POST/click?color=fea)](https://github.com/src-d/blog/issues/new?template=post.md)

If you'd rather copy paste the content, you can use the content below:

```markdown
Issue Title: [PROPOSAL] Blog post title

* Title:
* Author(s):
* Short description: What is the topic? Any main takeaways?
* Categories:
* Deadlines: are there any deadlines for this? do we need to wait for any other event?

## Table of contents

What are the main sections of the blog post? What will each one explain?

## Management

This section will be filled by @campoy.

* State: (proposed | writing | written | published)
* Scheduled:
* Link to post:

## Social Media

* Wording for tweet:
* Hashtags:
* Subreddits:
```

Once you've created this issue make sure to add the `post` label and assign it to `@campoy`,
he will then review the proposal and give feedback on it until the initial proposal is accepted.
Once the proposal has been accepted, the issue will be labeled with an `accepted` label, or if it's
been rejected or abandoned the issue will be closed.

Once accepted, you can start writing your blog post, creating a new pull request that will `fix` the issue
you created for the proposal. Make sure you add `[WIP]` at the beginning of the title in the PR until you're
ready for review.

## Creating a new post

Posts are stored under [`post` content directory](content/post) as plain text `.md` files.

To create a new blog post:
 1. create a new `.md` file with under `content/post/__POST_FILE_NAME__.md`
    it will be accessible in the the URL `//__BLOG_HOST_NAME__/post/__POST_FILE_NAME__`
 2. for a first time authors, add your name to [authors list](#authors)

The post `.md` files must have the following [schema](#content-schema):


### Content schema

Every blog post content file is stored under the path `content/post/__POST_FILE_NAME__.md`, and has the following schema:

```
---
author: authorKeyName
date: 2006-01-02
title: "Post title"
image: /post/__POST_FILE_NAME__/header-image.png
description: "Short description of the post"
categories: ["science", "technical", "culture"]
draft: true
---

Whatever content in `markdown` format.

```
IMPORTANT: `authorKeyName` must exist in [data/authors.yml](data/authors.yml)

### Front matter

The **front matter** is the first section inside the content file &ndash;enclosed by "`---`" chars&ndash; where the content metadata is defined.<br />(Read more about it in the Hugo docs for the [Front Matter section](https://gohugo.io/content-management/front-matter))

- `author`: Defines the authorship as explained in the [authors section](#authors)
- `date`: Date when you plan to publish the post, `2006-01-02` format. **Do not forget to update it before publishing it.**
- `title`: Post title, as it will appear in the very top of the content
- `image`: Defines the image that will be shown in the [assets section](#assets)
- `description`: Short description of the post. Plain text only; neither HTML nor markdown allowed.
- `categories`: An array of at least one of the following: `science`, `technical`, `culture`. If it is not defined, it will not be served by the json blog api, so it will not appear in the source{d} landing.
- `draft`: This key should not be present in public posts. Read more in the [peer review section](#peer-review)


### Formatting the content

**It is strictly forbidden to use HTML tags and/or custom CSS to format the content of the blog.** These add unnecessary complexity to the blog maintenance and will eventually break in layout changes.

If you want/need special formatting for your content, please read the [shortcodes tutorial](https://blog.sourced.tech/documentation/shortcodes)

If you believe your content **really** requires a feature that is not currently supported by the current shortcodes, please [check the issues and create a feature request](https://github.com/src-d/blog/issues/). The product owner will evaluate feasibility and the benefit to all users before approving implementation.


### Links to other source{d} blog posts

Links from source{d} blog posts to other source{d} blog posts must be always relative to the blog url. That means that these urls will be like:
```
[link text](/post/__POST_FILE_NAME__)
```


### Assets

Given a post content file stored under <br />
`content/post/__POST_FILE_NAME__.md`,<br />
its assets should be stored under :<br />
`static/post/__POST_FILE_NAME__/__ASSET_FILE_NAME_PLUS_EXTENSION__`

That way, the linkable urls would be:<br />
`/post/__POST_FILE_NAME__/__ASSET_FILE_NAME_PLUS_EXTENSION__`

When demos or runnable stuff need resources, these must not be hosted in the blog repository, but externally. To do that, the [`codepen` shortcode](https://blog.sourced.tech/documentation/shortcodes#codepen) should be used.

### Authors

Every post entry must define its authorship; to do so, in the content [Front Matter section](#front-matter) it is needed to define the `author` key. 

The `author` key will be one of the authors defined by the [data/authors.yml](data/authors.yml).

The authors entries follow this schema:
```yaml
authorKeyName:
  name: Author Name and Surname
  thumbnail: https://avatars1.githubusercontent.com/u/__USER_ID__
  bio: "Short bio/description of the author"
  social:
    github: authorUserName
    twitter: authorTwitterHandler
```

If you are writing a blog post and your author entry is not defined under `data/authors.yml`, you should add yourself to that authors data file.

## Preview the blog posts

While you are developing or creating new contents for the blog, and always before publishing a PR, you should validate your changes locally, specially if you're modifying common features or you're using shortcodes.

To locally serve the blog, you need to satisfy the [project requirements](README.md#requirements), and then run from the project root:

```shell
make serve
```
Finally, go to [http://localhost:8484](http://localhost:8484)

### Troubleshoot

In case you have any troubles seeing the preview of the post locally i.e an empty page insted of content, one think you can try is to manually run backend and frontend parts in different terminal session and check more detaild logs:

```
$ make hugo-server
$ yarn run webpack-watcher
```

One common issue is an empty page, if a new author is not yet part of the [authors list](#authors) in [data/authors.yml](data/authors.yml) that results in hugo logs like

```
ERROR 2018/07/25 13:07:10 Error while rendering "page": template: theme/_default/single.html:1:3: executing "theme/_default/single.html" at <partial "skeleton" (...>: error calling partial: template: theme/partials/skeleton.html:7:7: executing "theme/partials/skeleton.html" at <partial (printf "ske...>: error calling partial: template: theme/partials/skeleton-single.html:15:15: executing "theme/partials/skeleton-single.html" at <partial "author" $ct...>: error calling partial: template: theme/partials/author.html:24:36: executing "theme/partials/author.html" at <markdownify>: wrong number of args for markdownify: want 1 got 0
```

## Peer review

New content must be validated via [a PR](https://github.com/src-d/blog/pulls) by [campoy](//github.com/campoy).

To let your peers review any new blog post, it needs to be published as a **"draft"**. Drafts are only accessible at staging environment http://blog-staging.srcd.run

To publish a post as a **draft** in staging, it is needed to set its `draft` [front matter](#front-matter) key to `true`, and merge it into [`src-d:staging` branch](https://github.com/src-d/blog/tree/staging) following the source{d} [Continous Delivery rules for web applications](https://github.com/src-d/guide/blob/master/engineering/continuous-delivery.md)


## How to publish blog posts and deploy the blog

The blog is published automatically following the source{d} [Continous Delivery rules for web applications](https://github.com/src-d/guide/blob/master/engineering/continuous-delivery.md)

For any blog post to be published, it must follow the conventions given by this guide, and the following technical ones regarding the post [front matter](#front-matter):
- `draft` key must be unset (or at least it must be `false`),
- `date` key must be set to before &ndash;or equals to&ndash; the deploy date

## Publishing and promoting a blog post

Once the blog post is ready for publication we'll schedule the publication for a specific time.
This will probably be on a Tuesday at 8am PST, but different options can be negotiated too.

Once the post has been scheduled we use [buffer](https://bufferapp.com) to schedule posts on
Twitter and Linkedin, as well as [Later for Reddit](https://laterforreddit.com/) to post on
Reddit. Once the posts have been published we will use the #devrel and #twitter channels on our
Slack to let all employees know about the posts.

You're always welcome to provide the wording for the social media posts, as well as possible
hashtags and subreddits where you'd like the blog post to appear.

Simply include these in the issue.