jsoo-todo-mvc
-------------

## Overview

This repository contains a few experiments in building [todo-mvc][] apps written in OCaml using [js_of_ocaml][]. As with all experiments there needs to be a "why"? There are quite a few projects I hope to build in the near future with a lot of data and UI components and of course, I want to build them in OCaml. Before choosing a library for doing that I wanted to experiment with them in a simple application. I'm not particularly interested in performance or size of output at this stage but more in the pleasure of working with them. So that leave the final caveat -- if I have used the libraries in a non-idiomatic fashion... let me know.

The different libraries used are: [bonsai][], [brr-lwd][] and [jsoo-react][]. Note, there is already a [plain jsoo]() implementation and a [brr + note]() implementation. I have [dabbled with functional reactive programming]() and, for now, it just isn't for me.

## Quick Primer on Js_of_ocaml

## Applications

### Bonsai

### Brr-lwd

### Jsoo-react

### Bonus round: Flora

A combination of the underlying incremental computation library [OCurrent]() and [Brr](). This little experiment was mainly to get an idea of what's going on in [bonsai][] and [brr-lwd][] since they use a similar, incremental computation approach to building reactive user interfaces.


[bonsai]: https://github.com/janestreet/bonsai
[todo-mvc]: