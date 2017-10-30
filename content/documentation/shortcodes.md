---
author: dpordomingo
date: 2017-10-01
title: "Having a maintainable layout"
draft: false
image: /post/shortcodes/header.png
description: "Use shortcodes instead of custom HTML code"
categories: ["documentation"]
---

Since we're trying to have a maintainable blog, with a robust layout that should be easily redesigned, we decided to forbid HTML code inside the blog posts. 

If you want/need special formatting for your content, you can use [shortcodes](https://gohugo.io/content-management/shortcodes) to use our predefined layouts.

The shortcodes are simple snippets &ndash;that can be placed inside the content files&ndash; that Hugo will render using a predefined template. Hugo comes with some builtin shortcodes, but not all of them are supported by our blog. The full list of available shortcodes is below this introduction.

You can combine most of the shortcodes to mix its effects.

If you feel you really need a new layout (because none of the existent ones, or none of its combinations suits you), please ask for it opening a [new issue](https://github.com/src-d/blog/issues) to analize that special case.

# source{d} custom shortcodes

## Scroll-panel

If your content is too long to be shown all at once, you can use the `scroll-panel` shortcode to create an scrollable container with fixed height.

``````
{{%/* scroll-panel height="120" %}}
```js
// many lines code goes here
```
{{% /scroll-panel */%}}
``````

The minimum height for an `scroll-panel` containing a block of source code should be 120px to obtain a proper visualization.

_example_:
{{% scroll-panel height="120" %}}
```js
console.log("code1")
console.log("code2")
console.log("code3")
console.log("code4")
console.log("code5")
console.log("code6")
console.log("code7")
```
{{% /scroll-panel %}}
## Center

If you want to center a content you should use the `center` shortcode.

```
{{%/* center %}}
This content will be centerd
{{% /center */%}}
```

_example_:
{{% center %}}
This content will be centerd
{{% /center %}}

## Caption

Whenever you need to use an image in your post, you should consider the `caption` shortcode to provide valuable information to the user; think in the screen readers.

For the caption of the image, it can be used html, markdown and other shortcodes

```
{{%/* caption src="//url-to-the-omage" title="title of image" %}}
caption of the image
{{% /caption */%}}
```

_example_:
{{% caption src="http://www.elreferente.es/source/paginas/slider/sourced-ronda-6millones.jpg" title="title of image" %}}
caption of the image
{{% /caption %}}

## Extra width content

The `grid` shortcode creates an extra-width container where you can place your stuff like images, videos, tables...
```
{{%/* grid */%}}
This container has extra-width
{{%/* /grid */%}}
```

_example_:
{{% grid %}}
Ut non consectetur dolor pariatur pariatur ullamco. Voluptate esse id id aute nisi eu et anim labore fugiat id laboris et. Ad magna dolore consequat veniam sit nisi consequat officia sit magna dolore adipisicing. Do ullamco in occaecat et occaecat. Dolor consequat et laboris et ut tempor esse et exercitation cupidatat. Do officia cillum amet sunt. Veniam irure mollit officia fugiat.
{{% /grid %}}

An special case of the content that can be placed inside of a `grid` shortcode is the following one: [Grid of 2 elements](#grid-of-2-elements)

## Grid of 2 elements

The `grid-cell` shortcode must be used inside a `grid` one. It will create a "two columns layout" inside an "extra-width container"

Inside each `grid-cell` you can introduce text, markdown or other shortcodes. 

```
{{%/* grid */%}}
{{%/* grid-cell */%}}
SOMETHING LEFT
{{%/* /grid-cell */%}}
{{%/* grid-cell */%}}
SOMETHING RIGHT
{{%/* /grid-cell */%}}
{{%/* /grid */%}}
```

_example_:
{{% grid %}}
{{% grid-cell %}}
table:

| 0 | 1 | 1 | 1 | 1 | 1 |
|:-:|:-:|:-:|:-:|:-:|:-:
| 1 | 0 | 4 | 3 | 3 | 3 |
| 1 | 4 | 0 | 3 | 3 | 3 |
| 1 | 3 | 3 | 0 | 3 | 3 |
{{% /grid-cell %}}
{{% grid-cell %}}
```js
const fillTable = (table) => {
    for (let i = 0; i < 4; i++) {
        const row = document.createElement('tr');
        for (let j = 0; j < 6; j++) {
            const cell = getRandomCell();
            row.appendChild(cell);
        }
        table.appendChild(row);
    }
}
```
{{% /grid-cell %}}
{{% /grid %}}

## Anchor

You can use an `anchor` shortcode to create a reference anywhere, and link to it from any other place of your post (or even outside the post)

```
{{%/* anchor "anchor-name" */%}}
```

Then, to link to that anchor you only need to write a normal link like `[text of the link](#anchor-name)`

_example_:

[text of the link](#anchor-name)

{{% anchor "anchor-name" %}}
The `anchor` no visual representation, it's just an _"anchor"_ ;)

## codepen

Whenever it is needed to display something runnable like a demo, an example or a proof of concept, it should be used inside an embedded `codepen` snippet.

The shourcecode of the snippet should be under codepen source{d} account, although it can be hosted under your account while the PR is being reviewed.

```
{{%/* codepen slug="SLUG" title="TITLE" height="400" */%}}
```

The parameters that the `codepen` shortcode accepts are:

- `slug` (_required_) the slug of the pen. Usually the last part of its URL
  (for a sourced pen, the url looks like codepen.io/sourced/pen/slug).
- `height` (_optional_, defaults to 573) height of the codepen.
- `title`(_optional_, defaults to sourced) a title for the codepen.
- `user` (_optional_, defaults to sourced) the user in codepen. After the PR is merged into master, it must be the default one.

_example_:
{{% codepen slug="ayEKKj" title="lapjv" %}}

# Provided by Hugo itself

The following shortcodes are provided by Hugo itself

## Gist

```
{{%/* gist username gist_id */%}}
```

Display a Gist (even an IPython Notebook)

If the gist if too height, you can use a `scroll-panel` shortcode to wrap it inside a scollable window.

_example_:
{{% scroll-panel height="300" %}}
{{% gist vmarkovtsev e56fe77562037460585d4de690040da8 %}}
{{% /scroll-panel %}}

## Tweet

```
{{%/* tweet TWEET-ID */%}}
```

_example_:
{{% tweet 915638447049728007 %}}

## YouTube video

```
{{%/* youtube YOUTUBE-ID */%}}
```

_example_:
{{% youtube 5b1sVbQXyG0 %}}
