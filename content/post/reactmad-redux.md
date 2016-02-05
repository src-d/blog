---
author: mvader
date: 2016-02-05
title: "First ReactMad meetup: Time travelling with React and Redux"
image: /post/reactmad-redux/back.jpg
description: "An introduction to Redux and its time traveling capabilities for debugging."
---
![View from the back of the room](/post/reactmad-redux/back.jpg)

Last month we did the first Meetup of the ReactMad, the Madrid React user group. The topic was _"Time travelling with React and Redux"_.

The talk was structured in four parts:

* **Introduction to Redux** where the basic concepts of Redux were explained.
* **Integrate Redux with React** using the `react-redux` npm package and how to manage the separation of concerns in the components.
* **Setup the Redux Dev Tools** to be able to use time travel in debugging.
* **Example** of a very basic twitter timeline built with these technologies, including a demonstration of how the time travelling works with them.

## Introduction to Redux

The first part of the talk was about the three principles of Redux and its three kind of components.

The three basic principles Redux is built upon are

* There is a single source if truth (all the state in one tree object inside a single store).
* State is always read-only.
* Mutations are written as pure functions.

Then we went one by one, describing and showing examples of the three types of components you can have in a Redux application

* **Actions** that are just plain javascript object describing that something happened. We also mentioned the _action creator pattern_ in redux to reduce boilerplate.
* **Reducers** which are where all the logic of the state happens. They are pure functions that given a previous status and an action they return a new status after applying the mentioned action.
* **Store** is where all the state is contained. It has the methods to subscribe to the state, get it and dispatch an action to it. Remember that because of the principle of _single source of truth_ we can **only have one store**.

Surprisingly, that is pretty much all you have to know about Redux because it has a really minimal and well designed API that **makes developing very readable and testable code a delightful experience**.

## Integrate Redux with React

**Integrating Redux with React is a very easy task**. Redux is not coupled to any framework, which means you can use it with any framework you want. With React is even easier because we have the `react-redux` npm package that provides a simple way of integrating both libraries.

`react-redux` has two functions that will make our life easier

* `Provider`, a component that must wrap your root component in order to pass the store down to all the component hierarchy.
* `connect`, which connects a component and subscribes it to updates made to a part —or the whole— state.

When working with React and Redux you have to think very well the separation of concerns in your application. Having a lot of components connected to the state may decrease the performance of the app. It's even very redundant because the data is in another place. For that, we can divide our components in two types:

* **Smart components** that are connected to the state and hold the logic. By holding all the logic here is easier to debug and test.
* **Dumb components** that only render whatever data their parent passed to them and execute actions also passed to them. That way, we have components that are like pure functions, easily testable and logic-less.

## Redux DevTools

With just a few additions **we can integrate the redux-devtools and add a panel with the stream of states and actions that happened through time**. This panel gives us the ability to go back and forth in time through that stream. All we have to do is enhance the store with a middleware and render the debug panel in our app using functions and components from the `redux-devtools` npm package.

## The event

Though there weren't a lot of assistants, they said they found the topic very interesting and a lot of very good questions were asked in the Q&A part.
We hope everyone that assisted to the talk found it interesting and they can use the knowledge shared in it to build awesome apps.

[You can find the slides as well as the source code of the example here](https://github.com/mvader/reactmad-redux-example).

![The audience](/post/reactmad-redux/audience.jpeg)

