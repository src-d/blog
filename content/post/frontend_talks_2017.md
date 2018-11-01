---
author: erizocosmico
date: 2017-08-08
title: "source{d} tech talks, frontend series"
image: /post/frontend-talks/header-pic.jpg
description: "Once every few months, source{d} organizes small conferences around very specific topics. On June 24th, the topic was frontend and the talks were hosted in our Madrid office. Almost 50 people joined us for a day full of things to learn about frontend technologies."
categories: ["technical", "frontend"]
---

![Schedule with our logo](/post/frontend-talks/header-full.jpg)

Once every few months, source{d} organizes small conferences around a very specific topics. On June 24th, the topic was frontend and the talks were hosted in our Madrid office. Almost 50 people joined us for a day full of things to learn about frontend technologies.

The topics of the talks were very diverse, from animations with Ember to multi-threaded web to React styling to accessibility. Since frontend is such a wide area in programming, we aimed to provide talks belonging to many different topics, and it seems that we succeeded.

## Conferences are no fun on an empty stomach

First things first, we started the day with a warm and friendly welcome breakfast for all the attendees and speakers where people could talk and get to know each other, as well as the speakers, before the talks.

## Opening speech

After everyone was in their seat, [Margarida Garcia](https://twitter.com/margaridagsl) gave the opening talk and greeted everyone in the room. She talked a bit about what we do here at source{d} and explained what the source{d} tech talks are about and why these and other initiatives we hold to bring together a strong community are so important to us.

## Talks

We had a total of 5 long talks and a lightning. Despite a last minute cancellation from one of the speakers, we managed to host a total of 4 speakers in the morning session and the other 2 in the afternoon one.
We had a couple of breaks between each talk to allow everyone to restore energies and had a larger one at lunch.
All main talks lasted 45 minutes, 30 for the talk and 15 for the questions and answers while the lightning talk lasted for 15 minutes.

## Morning session

### The multithreaded web: a tale of workers, _Ramón Guijarro_

In the first morning talk, [Ramón Guijarro](https://twitter.com/soyguijarro), a frontend developer at Tuenti, talked about how to develop multi-threaded applications in the web using workers.

Ramón started his talk by mentioning how the release of the iPhone and App Store motivated a change in user expectations. So we've had to move from web pages to web apps to meet those user expectations on the web.

Users expect their apps to have smooth animations and have a fast response, which can be achieved by optimizing the JavaScript code to run at 60fps through either splitting big time consuming tasks into chunks or moving them to another thread to stop blocking the UI.

Users also expect their apps to work offline and sync in the background, as well as to have a very deep system integration: push notifications, geolocation, etc. All that can be achieved using service workers.

{{% youtube yo25lpqKc-E %}}

### Web accessibility. How to make a frontend for everyone?, _Juanjo Montiel_

In the second morning talk, [Juanjo Montiel](https://twitter.com/kastwey), a software engineer at Pasiona, talked about web accessibility and showed us the difficulties that visually impaired people face when browsing the web.

He started his talk by asking us all to raise our hands if we agreed with one of his statements. This quickly showed us all one of the challenges that visually impaired people face. Such issues, as he pointed out, can be solved with accessible technology, such as a mobile app for voting instead of just raising our hands.
Like in the previous example, visually impaired people experience troubles browsing the web and using a computer but Juanjo explained how to make our websites accessible to make it easier for them.

Visually impaired people use programs called screen readers that scan everything in the computer's display and tell it to the person. But that works well only if the web page is accessible!

With just a few guidelines we can make our web pages accessible too:

* Provide a good structure, visually impaired people lack the visual position information.
* Make good use of title elements (`h1`, `h2`, ...), list elements, link elements, ...
* Label all the images that provide information to the reader with the `alt` attribute. Those images that are decorative should have the `alt` attribute but it must be empty.
* Use labels for your form controls and fieldsets to group your radio buttons.
* Don't use divs for everything if you can, use buttons, links, selects, etc. But if you can't, use the `role` aria attribute.
* Always provide an alternative to drag and drop.

And many more that you can find out watching the full talk.

{{% youtube EZ8KSgzUdb0 %}}

### Animate the Web with Ember.js, _Jessica Jordan_

The last long talk of the morning session was about how to make animations in the web using Ember.js, by [Jessica Jordan](https://twitter.com/jjordan_dev), software engineer at simplabs.

First, she told us about animations through the recent history until the times of Macromedia Flash and the appearance of the open standards we use today for animations on the web: HTML5, JS and CSS3.

The first option for web animations is using the HTML5 `canvas` element to draw and animate. She also explained how to do that with Ember components.
This has a few advantages like not needing DOM operations, having a good performance and being a powerful way for the developer to animate things, but it's too complicated for creators and hard for accessibility.

Then, as an alternative, we can use the WebAnimations API, which is still not supported in all browsers (but we can workaround that with a polyfill). It will be an easy experience for people already familiar with CSS3 keyframes since they are very similar. Besides, she explained how to put all that into an Ember component, as with the `canvas` HTML5 element.
Even though it has worse performance compared to HTML5 canvas, the WebAnimations API makes it possible to build accessible animations and are easier for the creator.

{{% youtube n-z7En2O9mQ %}}

### Communication is the key to a healthy relationship: the love story of Elm and JavaScript, _Miguel Molina_

We had the last talk just before lunch, a lightning talk about how to communicate between Elm and JavaScript by [Miguel Molina](https://twitter.com/erizocosmico) (yours truly), fullstack developer at source{d}.

In this talk, several methods to communicate between Elm and JavaScript were explored after a brief introduction of what is Elm and why Elm and not another compile-to-JS languages.

Three methods of interoperability were discussed:
* Native modules, which are hard to write, inconvienient for the package writer and not documented on purpose.
* Ports, which are the recommended way of communicating elm and JavaScript using unidirectional inbound and outbound channels to pass messages.
* Flags, which is a way to pass some initialization values or configuration from JavaScript to Elm.

{{% youtube PjkABl96NcM %}}

## Afternoon session

### Decorating JavaScript, _Sergio Arbeo_

We had the first long talk of the afternoon having filled our bellies with delicious food. It explained what decorators are and what they are used for in JavaScript, by [Sergio Arbeo](https://twitter.com/serabe), lead platform engineer at source{d}.

In this talk, Sergio explained that decorators have been worked on since March, 2015 by Yehuda Katz and they are (and have been) in stage-2 for 11 months, so the spec is probably not going to suffer many more changes until it gets to stage 3 and can be implemented by browsers.

A decorator is a new syntax to declaratively modify the shape of class declarations, either the class itself or its members using functions.
There are two types of decorators:

* A class decorator, which is a function that receives the class constructor, the parent class and the descriptors of its members and returns nothing.
* A member decorator, which is a function that receives a member descriptor and returns the modified member descriptor.

The syntax is very conservative, that is, you cannot use any arbitrary JavaScript expression, it must be identifiers joined with dots and optionally ending with a function call with optional arguments, e.g. `@foo.bar.baz(arg1, arg2)`.

Sergio explained in detail how to implement decorators and what might be their use cases.

{{% youtube EUHmOoJn9SM %}}

### Flexible styling for highly reusable React components, _Javi Velasco_

The last talk of the day was about how to create highly flexible and highly reusable components in React using styled-components, by [Javi Velasco](https://twitter.com/javivelasco), frontend engineer at Audiense.

Javi started by saying that for a component to be fully customizable, it needs to allow the following three kinds of customization:

* *Theming:*enable the change of the color scheme and so on. It's highly predictable and can be extracted easily for the user to change.
* *Style customization:*unpredictable changes the user might want to make to the styles. They are impossible to guess beforehand because the needs of every user vary. It's implemented by overriding styles.
* *Render customization:*allow changing how the component is rendered while preserving the same logic. It's also impossible to predict and make everything customizable with a declarative API.

To implement all these customizations in a React component, he explored the usage of CSS-in-JS, a technique that has been talked about a lot lately in the JavaScript community. Specifically, styled-components.

* Theming is achieved by passing props to the component or using `<ThemeProvider>` of styled-components and then interpolating these properties in the style definition of the component.
* Style customization is achieved by passing the styles you want to change for every primitive in the component and then they are interpolated in the style definition, so you can override any style the component has.
* Render customization is achieved using factories of components that receive custom primitives to use instead of the ones used by default in the component, which is neat because we can reuse the logic while swapping React and React-Native primitives and it all just works.

{{% youtube 8kOkyQoCYMQ %}}

## After-party drinks

After a long day of talks, attendees and speakers were able to relax and chat over some beers (and other non-alcoholic beverages, of course), including our home-brewed [Fork Knox session ipa](https://github.com/src-d/homebrew/blob/master/recipes/fork-knox-session-ipa.md).

![Our Fork Knox session IPA](/post/frontend-talks/fork-knox.jpg)

## Acknowledgements

source{d} would like to thank very much the speakers for such great talks and the attendees for being there and sharing with us their love and passion for the web and frontend technologies.

Also, we'd like to thank everyone who worked hard behind the scenes to make this event as awesome as it was.

