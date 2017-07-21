# source{d} blog  [![Build Status](https://travis-ci.org/src-d/blog.svg?branch=master)](https://travis-ci.org/src-d/blog)

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
