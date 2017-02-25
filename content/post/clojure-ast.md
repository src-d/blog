---
author: erizocosmico
date: 2017-02-25
title: "The many roads towards a Clojure AST"
draft: false
description: "Extracting the AST of a Clojure program is super easy, you could think. It is a lisp, after all. We will be explaining our journey trying to extract the AST of Clojure programs using the `clojure.tools.analyzer` and how it was not as trivial as we thought."
categories: ["ast", "clojure", "technical"]
---

## A little bit of context

At source{d} we are starting a new ambitious project, called [bblfsh](https://github.com/bblfsh), a service to be able to parse and extract ASTs from any programming language. As a part of that project, we were developing the `clojure-driver`, which is in charge of parsing and extracting an AST from Clojure source code files.

## A little bit of research

After a little bit of researching, we came across what we knew it was going to be the best approach for our goals: `clojure.tools.analyzer`. This library can be used to, given a form, extract its AST.

## The journey

So, the first thing to do is actually try to get the AST of some very simple program, in the REPL, for example.

```clojure
user> (require '[clojure.tools.analyzer.jvm :as ana.jvm])
nil
user> (ana.jvm/analyze 1)
{:op        :const,
 :env       {:context :ctx/expr, :locals {}, :ns user},
 :form      1,
 :top-level true,
 :val       1,
 :type      :number,
 :literal?  true,
 :id        0,
 :tag       long,
 :o-tag     long}
```

**Note:** we are using here `clojure.tools.analyzer.jvm`, which is an implementation of `clojure.tools.analyzer` with specific things for the JVM. There is also `clojure.tools.analyzer.js` for ClojureScript.

There is a very important thing to notice here. We passed `1` as an argument to `analyze`, not a string, not a file. 

That's the first rock in our road, we need to actually pass forms to `analyze`, which means we have to actually read a source file and convert it to a form.
It's ok, Clojure provides functions to do exactly that.

Our first attempt at do this was very naive, just using `read-string`. Unfortunately, a Clojure program can have more than one form in it and `read-string` only reads one form from the string.
That is ok too, we can resort to `read` and a reader.

```clojure
(with-open [r (java.io.PushbackReader. (java.io.StringReader. src))]
  (binding [*read-eval* false]
    (loop [form (read r false :end)
           forms []]
      (if (= :end form)
          forms
          (recur (read r false :end)
                 (concat forms [form])))))))
```

A funny thing you might not think is that `read` does not only read a form. It evaluates it, which is a very interesting thing to do when you are reading untrusted sources. Lucky for us, we can set `*read-eval*` to `false` and avoid executing the form as it reads it.

We have our vector of forms now, it's just a matter of analyzing them, right?

```clojure
(mapv ana.jvm/analyze forms)
```

This should do the trick, right? Well, it does not.
Why? Because it checks namespaces and if variables exist in that context or not just like it would do when you execute the code. Remember that every form is analyzed independently, and your `ns` form containing all the requires and imports is not present on the next form.

So we need to analyze every single form in isolation removing these checks.

Because these things are checked in different passes after actually getting the AST, we need to call directly the `clojure.tools.analyzer` `analyze` function which requires us to do some work defining some dynamic variables.

I actually got that idea by looking at [the package tests](https://github.com/clojure/tools.analyzer/blob/master/src/test/clojure/clojure/tools/analyzer/core_test.clj#L54-L63).

```clojure
(def empty-env {:context :ctx/statement
                :locals {}
                :ns 'user})

;; clojure.core needs to have no mappings! or we'll get errors
(def env (atom {:namespaces {'user {:mappings {}
                                    :aliases {}
                                    :ns 'user}
                             'clojure.core {:mappings {}
                                            :aliases {}
                                            :ns 'clojure.core}}}))

(defn parse-ast
  [form]
  (binding [ana/macroexpand-1 ana.jvm/macroexpand-1
            ana/create-var   (fn [sym env]
                               (doto (intern (:ns env) sym)
                                 (reset-meta! (meta sym))))
            ana/parse        ana.jvm/parse
            ana/var?         var?]
    (with-env env
      (ana/analyze form empty-env))))
```

So we call `analyze` with our custom parameters but use the functions for macro expansion and parsing from `clojure.tools.analyzer.jvm`. Easy, right?

Well, we are not there yet. If your code uses macros you'll find them, obviously, expanded. But that's not a very nice AST representation. At least, it was not a very good one for us. So, instead of using the `macroexpand-1` function from the jvm analyzer, we use our own that doesn't actually do anything.

```clojure
(defn macroexpand-noexpand [form env] form)
```

Ok, now we're done, right? No we are not. If the code you're testing this with contains a `recur` form you will get an error because you can only `recur` from a tail position. What happens here is that macros are not expanded and, obviously, `loop` is a macro.

We take a look at the code of the analyzer to see that it actually has a [`recur` parser where this behaviour is specifically checked](https://crossclj.info/ns/org.clojure/tools.analyzer/0.6.9/clojure.tools.analyzer.html#_parse-recur).

What can we do now? Roll our own parse function with our own `recur` parser that omits these checks.

```clojure
(defn parse-recur
  "Parse recur is the same parse function as the one in clojure.tools.analyzer
  but it does not validate it."
  [[_ & exprs :as form] env]
  (let [exprs (mapv (ana/analyze-in-env (ctx env :ctx/expr)) exprs)]
    {:op          :recur
     :env         env
     :form        form
     :exprs       exprs
     :children    [:exprs]}))

(defn parse-forms
  [form env]
  ((case (first form)
     monitor-enter        ana.jvm/parse-monitor-enter
     monitor-exit         ana.jvm/parse-monitor-exit
     clojure.core/import* ana.jvm/parse-import*
     reify*               ana.jvm/parse-reify*
     deftype*             ana.jvm/parse-deftype*
     case*                ana.jvm/parse-case*
     do                   ana/parse-do
     if                   ana/parse-if
     new                  ana/parse-new
     quote                ana/parse-quote
     set!                 ana/parse-set!
     try                  ana/parse-try
     throw                ana/parse-throw
     def                  ana/parse-def
     .                    ana/parse-dot
     let*                 ana/parse-let*
     letfn*               ana/parse-letfn*
     loop*                ana/parse-loop*
     recur                parse-recur
     fn*                  ana/parse-fn*
     var                  ana/parse-var
     #_:else              ana/parse-invoke)
   form env))
```

Now, if we glue it all toghether, we will get our AST for all the forms analyzed in isolation. Then, the AST of the program would be the list of the ASTs of all its forms.     

You can take a look at the complete implementation of the bblfsh clojure driver [here](https://github.com/erizocosmico/clojure-driver/tree/feature/clj-parser).

## Conclusion

Getting the AST of Clojure, being a lisp, seemed like it would be a very easy thing. In practice not only it was not easy at all, it required a lot of investigation, reading the source code of `clojure.tools.analyzer` and trial and error.
On the bright side, we learned a lot from this journey and, why not say it, it was lots of fun.
