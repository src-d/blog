# Contributing

You will find here the conventions and rules to publish new blog posts.


## Propose a new blog post

The first step on the process to release a blog post is to reach general agreement on whether the topic
and general structure of the blog post makes sense. This will help you structure your blog post early and
avoid wasting any time by receiving feedback too late.

Whenever you have a new idea for a blog post simply create a new issue with this link:

[![propose new blog post](https://svg-badge.appspot.com/badge/PROPOSE%20NEW%20BLOG%20POST/click?color=fea)](https://github.com/src-d/blog/issues/new?template=new-blog-post.md)

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


## Peer review

New content must be validated via [a PR](https://github.com/src-d/blog/pulls) by [campoy](//github.com/campoy).

To let your peers review any new blog post, it needs to be published as a **"draft"**. Drafts are only accessible at staging environment http://blog-staging.srcd.run

To publish a post as a **draft** in staging, it is needed to set its `draft` [front matter](#front-matter) key to `true`, and merge it into [`src-d:staging` branch](https://github.com/src-d/blog/tree/staging) following the source{d} [Continous Delivery rules for web applications](https://github.com/src-d/guide/blob/master/engineering/continuous-delivery.md)



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
