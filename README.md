[![Build Status](https://travis-ci.org/titsuki/p6-Random-Choice.svg?branch=master)](https://travis-ci.org/titsuki/p6-Random-Choice)

NAME
====

Random::Choice - A Perl 6 alias method implementation

SYNOPSIS
========

```perl6
use Random::Choice;

say choice(:size(5), :p([0.1, 0.1, 0.1, 0.7])); # (3 3 3 0 1)
say choice(:p([0.1, 0.1, 0.1, 0.7])); # 3
```

DESCRIPTION
===========

Random::Choice is a Perl 6 alias method implementation. Alias method is an efficient algorithm for sampling from a discrete probability distribution.

METHODS
-------

### choice

Defined as:

    multi sub choice(:@p! --> Int) is export
    multi sub choice(Int :$size!, :@p! --> List)

Returns a sample which is an Int value or a List. Where `:@p` is the probabilities associated with each index and `:$size` is the sample size.

FAQ
===

Is `Random::Choice` faster than Mix.roll?
-----------------------------------------

The answer is YES when you roll a large biased dice but NO when a biased dice is small.

Why? There are some possible reasons:

  * `Random::Choice` employs O(N) + O(1) algorithm whereas `Mix.roll` employs O(N) + O(N) algorithm (rakudo 2018.12).

  * `Mix.roll` is directly written in nqp. In general, nqp-powered code is faster than naive-Perl6-powered code when they take small input.

A benchmark result is here (For more info, see `example/bench.p6`):

```bash
$ perl6 example/bench.p6 
Benchmark: 
Timing 1000 iterations of Mix(size=10, @p.elems=10) , Random::Choice(size=10, @p.elems=10)...
Mix(size=10, @p.elems=10) : 0.123 wallclock secs (0.133 usr 0.000 sys 0.133 cpu) @ 8106.224/s (n=1000)
Random::Choice(size=10, @p.elems=10): 0.266 wallclock secs (0.310 usr 0.000 sys 0.310 cpu) @ 3760.148/s (n=1000)
O--------------------------------------O--------O----------------------------O--------------------------------------O
|                                      | Rate   | Mix(size=10, @p.elems=10)  | Random::Choice(size=10, @p.elems=10) |
O======================================O========O============================O======================================O
| Mix(size=10, @p.elems=10)            | 8106/s | --                         | -60%                                 |
| Random::Choice(size=10, @p.elems=10) | 3760/s | 152%                       | --                                   |
O--------------------------------------O--------O----------------------------O--------------------------------------O
Benchmark: 
Timing 1000 iterations of Mix(size=100, @p.elems=100), Random::Choice(size=100, @p.elems=100)...
Mix(size=100, @p.elems=100): 2.268 wallclock secs (2.263 usr 0.004 sys 2.266 cpu) @ 440.899/s (n=1000)
Random::Choice(size=100, @p.elems=100): 1.489 wallclock secs (1.490 usr 0.007 sys 1.497 cpu) @ 671.669/s (n=1000)
O----------------------------------------O-------O-----------------------------O----------------------------------------O
|                                        | Rate  | Mix(size=100, @p.elems=100) | Random::Choice(size=100, @p.elems=100) |
O========================================O=======O=============================O========================================O
| Mix(size=100, @p.elems=100)            | 441/s | --                          | 53%                                    |
| Random::Choice(size=100, @p.elems=100) | 672/s | -35%                        | --                                     |
O----------------------------------------O-------O-----------------------------O----------------------------------------O
Benchmark: 
Timing 1000 iterations of Mix(size=1000, @p.elems=1000), Random::Choice(size=1000, @p.elems=1000)...
Mix(size=1000, @p.elems=1000): 191.405 wallclock secs (191.198 usr 0.084 sys 191.281 cpu) @ 5.225/s (n=1000)
Random::Choice(size=1000, @p.elems=1000): 15.329 wallclock secs (15.306 usr 0.012 sys 15.318 cpu) @ 65.237/s (n=1000)
O------------------------------------------O--------O-------------------------------O------------------------------------------O
|                                          | Rate   | Mix(size=1000, @p.elems=1000) | Random::Choice(size=1000, @p.elems=1000) |
O==========================================O========O===============================O==========================================O
| Mix(size=1000, @p.elems=1000)            | 5.22/s | --                            | 1151%                                    |
| Random::Choice(size=1000, @p.elems=1000) | 65.2/s | -92%                          | --                                       |
O------------------------------------------O--------O-------------------------------O------------------------------------------O
```

AUTHOR
======

titsuki <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2019 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

The algorithm is from:

  * Vose, Michael D. "A linear algorithm for generating random numbers with a given distribution." IEEE Transactions on software engineering 17.9 (1991): 972-975.

