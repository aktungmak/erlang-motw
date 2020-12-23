# erlang-motw
---
A weekly exposé of Erlang modules

## What's all this?

In the spirit of the great [Python Module of the Week](https://pymotw.com/3/) series,
this is a tour of the modules in the erlang ecosystem, starting with the `stdlib`
application.

The aim is to provide an overview of the functions provided, with examples that can be
run and used directly. To that end, each section is an actual erlang source module that
can be run, à la [literate programming](https://www-cs-faculty.stanford.edu/~knuth/lp.html).

The examples are taken from OTP and popular erlang open source projects, and references
to the original source are included for further reading.

Each section also contains `eunit` tests that can be run to ensure that all the examples
are correct.

Feel free to open issues or submit pull requests if you find any mistakes!

## Part 1: [stdlib](http://erlang.org/doc/man/STDLIB_app.html)
- [array](emotw_array.erl)
- [base64](emotw_base64.erl)
