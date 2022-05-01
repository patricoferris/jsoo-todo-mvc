jsoo-todo-mvc
-------------

## Overview

This repository contains a few experiments in building [todo-mvc][] apps written in OCaml using [js_of_ocaml][]. As with all experiments there needs to be a "why"? There are quite a few projects I hope to build in the near future with a lot of data and UI components and of course, I want to build them in OCaml. Before choosing a library for doing that I wanted to experiment with them in a simple application. I'm not particularly interested in performance or size of output at this stage but more in the pleasure of working with them. If I have used the libraries in a non-idiomatic fashion... let me know/please open an issue or PR.

The different libraries used are: [bonsai][], [brr-lwd][] and [jsoo-react][]. Note, there is already a [plain jsoo]() implementation and a [brr + note]() implementation. I have [dabbled with functional reactive programming]() and, for now, it just isn't for me.

## Quick Primer on Js_of_ocaml

## Applications

### Bonsai

Bonsai is a library by [Janestreet](https://www.janestreet.com/) for building dynamic web applications. It is used internally by Janestreet and also in their open-source [memtrace_viewer](https://github.com/janestreet/memtrace_viewer).  

### Brr-lwd

Brr-lwd is the newest of the libraries being experimented with. It is also the only library that has no Javascript dependencies whatsoever. It uses the "light weight document" ([lwd][]) library for building incremental computations.

### Jsoo-react

### Bonus round: Flora

A combination of the underlying incremental computation library [OCurrent]() and [Brr](). This little experiment was mainly to get an idea of what's going on in [bonsai][] and [brr-lwd][] since they use a similar, incremental computation approach to building reactive user interfaces.


[bonsai]: https://github.com/janestreet/bonsai
[todo-mvc]:
[lwd]: https://github.com/let-def/lwd