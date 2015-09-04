**auto-hugo** is a *tool/tutorial* of how build auto-deployable static websites using
[hugo](https://gohugo.io/), the [Github Pages](https://pages.github.com/) and
[cicleci](https://circleci.com/) platform.

```foo
Base
```

x) Register you repository at circleci clicking on [`Add Projects`](https://circleci.com/add-projects) and choosing your repository.

x) Now you need to allow to circleci to make pushes to your `gh-pages` branch, so just go to clicleci and in `Project Settings` > `Checkout keys` click on the big green button `Authorize w/ Github`, then a new button with emerge called `Create and add your/repository deploy key` click on it also, this will give write access to circleci
