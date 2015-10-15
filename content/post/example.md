---
draft: true
author: mcuadros
date: 2014-09-28
title: Example post
description: "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Earum similique, ipsum officia amet blanditiis provident ratione nihil ipsam dolorem repellat."
---


## Meta-data
At the beginning of every document you must to provide a header of metadata, the header is defined using the [YAML](https://es.wikipedia.org/wiki/YAML) syntax.

This is a example of a header:
```
---
author: mcuadros
date: 2014-09-28
title: Title of the post
description: This text is showd at the list of post on the home!!!
---
```

> The *author* should be defined on the `config.yaml`.






## Blocks of code

```
smoothScroll.init({
    speed: 800,
    easing: 'easeInOutCubic',
    updateURL: false,
    offset: 125,
});
```

> Don´t use ```lang notation, the language is autodetected
