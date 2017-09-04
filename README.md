# source{d} blog
[![Build Status](https://drone.srcd.host/api/badges/src-d/landing/status.svg)](https://drone.srcd.host/src-d/landing)
[![Docker Repository on Quay](https://quay.io/repository/srcd/blog/status "Docker Repository on Quay")](https://quay.io/repository/srcd/blog)

This is our [blog](https://blog.sourced.tech) source. It uses fancy technologies, such as:
- [Hugo](http://gohugo.io/)
- [Caddy](https://caddyserver.com/)

## Available shortcodes

### Code scroll

If your code is too long you can make it have a fixed height and be scrollable.

```
{{% codescroll height="500" %}}
\`\`\`js
my fancy code
\`\`\`
{{% /codescroll %}}
```

### Center

Center the text

```
{{% center %}}
some text
{{% /center %}}
```

### Caption

Renders an image with caption

```
{{% caption src="url to image" title="title of image" %}}
caption of the image, html and md allowed
{{% /caption %}}
```

### YouTube video

Display a YouTube video

```
{{% youtube VIDEO_ID %}}
```

### Gist

Display a Gist (even an IPython Notebook)

```
{{% gist username gist_id %}}
```

### Grid of 2 elements

```
{{% grid %}}
{{% grid-cell %}}
SOMETHING LEFT
{{% /grid-cell %}}

{{% grid-cell %}}
SOMETHING RIGHT
{{% /grid-cell %}}
{{% /grid %}}
```

### Tweet

Renders a tweet

```
{{% tweet TWEET_ID %}}
```

### Anchor

Anchor you can link to with `[foo](#anchor)`:

```
{{% anchor "anchor" %}}
```

### codepen

An embedded codepen. Whenever possible, use the sourced account.

```
{{% codepen slug="aaaaaa" title="My post example" %}}
```

Available options are:

- `height` (_optional_, defaults to 573) height of the codepen.
- `slug` (_required_) the slug of the pen. Usually the last part of its URL
  (for a sourced pen, the url looks like codepen.io/sourced/pen/slug).
- `user` (_optional_, defaults to sourced) the user in codepen.
- `title`(_optional_, defaults to sourced) a title for the codepen.
