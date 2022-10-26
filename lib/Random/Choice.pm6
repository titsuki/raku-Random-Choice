use v6.c;
use nqp;
unit module Random::Choice:ver<0.0.9>:auth<zef:titsuki>;

my class AliasTable {

    has num @.prob;
    has int @.alias;
    has int $.n;

    submethod BUILD(:@p) {
        $!n = +@p;
        my num $total = Num(@p.sum);
        my num @np = @p.map(-> $x { nqp::mul_n(nqp::div_n(Num($x),$total), $!n) });
        my (@large, @small);
        for ^@np -> $i {
            if @np[$i] < 1 {
                @small.push: (@np[$i], $i);
            } else {
                @large.push: (@np[$i], $i);
            }
        }

        while @large and @small {
            my ($pl, $l) = @small.shift;
            my ($pg, $g) = @large.shift;
            @!prob[$l] = $pl;
            @!alias[$l] = $g;
            $pg := $pg + $pl - 1e0;
            if $pg < 1 {
                @small.push: ($pg, $g);
            } else {
                @large.push: ($pg, $g);
            }
        }

        while @large {
            my ($pg, $g) = @large.shift;
            @!prob[$g] = 1e0;
        }

        while @small {
            my ($pl, $l) = @small.shift;
            @!prob[$l] = 1e0;
        }
    }
}

multi sub choice(:@p! --> Int) is export {
    my AliasTable $table .= new(:@p);

    my Int $i = (^$table.n).roll;
    if $table.prob[$i] > rand {
        return $i;
    } else {
        return $table.alias[$i];
    }
}

multi sub choice(Int :$size!, :@p! --> List) {
    my AliasTable $table .= new(:@p);

    gather for ^$size {
        my Int $i = (^$table.n).roll;
        if $table.prob[$i] > rand {
            take $i;
        } else {
            take $table.alias[$i];
        }
    }.List
}

=begin pod

=head1 NAME

Random::Choice - A Raku alias method implementation

=head1 SYNOPSIS

=begin code :lang<perl6>

use Random::Choice;
    
say choice(:size(8), :p([0.1, 0.1, 0.1, 0.7])); # (3 1 0 3 3 3 3 3)
say choice(:p([0.1, 0.1, 0.1, 0.7])); # 3

=end code

=head1 DESCRIPTION

Random::Choice is a Raku alias method implementation. Alias method is an efficient algorithm for sampling from a discrete probability distribution.

=head2 METHODS

=head3 choice

Defined as:

    multi sub choice(:@p! --> Int) is export
    multi sub choice(Int :$size!, :@p! --> List)

Returns a sample which is an Int value or a List.
Where C<:@p> is the probabilities associated with each index and C<:$size> is the sample size.

=head1 FAQ

=head2 Is C<Random::Choice> faster than Mix.roll?

The answer is YES when you roll a large biased dice or try to roll a dice many times; but NO when a biased dice is small or try to roll a dice few times.

Why? There are some possible reasons:

=item C<Random::Choice> employs O(N) + O(1) algorithm whereas C<Mix.roll> employs O(N) + O(N) algorithm (rakudo 2018.12).
=item C<Mix.roll> is directly written in nqp. In general, nqp-powered code is faster than naive-Raku-powered code when they take small input.
=item Both algorithms take O(N) initialization cost; however, the actual cost of C<Mix.roll> is slightly less than C<Random::Choice>.

A benchmark result is here (For more info, see C<example/bench.p6>):

=head3 A Benchmark Result

=begin para

<img src="./example/bench.svg" alt="benchmark result">

=end para

=head3 The Comparison Table on the Benchmark

=begin code :lang<bash>

$ perl6 example/bench.p6 
Benchmark: 
Timing 1000 iterations of Mix(size=10, @p.elems=10) , Random::Choice(size=10, @p.elems=10)...
Mix(size=10, @p.elems=10) : 0.076 wallclock secs (0.086 usr 0.003 sys 0.089 cpu) @ 13154.606/s (n=1000)
Random::Choice(size=10, @p.elems=10): 0.122 wallclock secs (0.137 usr 0.008 sys 0.145 cpu) @ 8210.383/s (n=1000)
O--------------------------------------O---------O----------------------------O--------------------------------------O
|                                      | Rate    | Mix(size=10, @p.elems=10)  | Random::Choice(size=10, @p.elems=10) |
O======================================O=========O============================O======================================O
| Mix(size=10, @p.elems=10)            | 13155/s | --                         | -42%                                 |
| Random::Choice(size=10, @p.elems=10) | 8210/s  | 73%                        | --                                   |
O--------------------------------------O---------O----------------------------O--------------------------------------O
Benchmark: 
Timing 1000 iterations of Mix(size=1000, @p.elems=10) , Random::Choice(size=1000, @p.elems=10)...
Mix(size=1000, @p.elems=10) : 1.879 wallclock secs (1.892 usr 0.000 sys 1.892 cpu) @ 532.130/s (n=1000)
Random::Choice(size=1000, @p.elems=10): 0.097 wallclock secs (0.099 usr 0.002 sys 0.101 cpu) @ 10361.621/s (n=1000)
O----------------------------------------O---------O------------------------------O----------------------------------------O
|                                        | Rate    | Mix(size=1000, @p.elems=10)  | Random::Choice(size=1000, @p.elems=10) |
O========================================O=========O==============================O========================================O
| Mix(size=1000, @p.elems=10)            | 532/s   | --                           | 2141%                                  |
| Random::Choice(size=1000, @p.elems=10) | 10362/s | -96%                         | --                                     |
O----------------------------------------O---------O------------------------------O----------------------------------------O
Benchmark: 
Timing 1000 iterations of Mix(size=10, @p.elems=1000) , Random::Choice(size=10, @p.elems=1000)...
Mix(size=10, @p.elems=1000) : 2.576 wallclock secs (2.560 usr 0.020 sys 2.580 cpu) @ 388.182/s (n=1000)
Random::Choice(size=10, @p.elems=1000): 6.010 wallclock secs (6.015 usr 0.032 sys 6.047 cpu) @ 166.398/s (n=1000)
O----------------------------------------O-------O------------------------------O----------------------------------------O
|                                        | Rate  | Mix(size=10, @p.elems=1000)  | Random::Choice(size=10, @p.elems=1000) |
O========================================O=======O==============================O========================================O
| Mix(size=10, @p.elems=1000)            | 388/s | --                           | -57%                                   |
| Random::Choice(size=10, @p.elems=1000) | 166/s | 134%                         | --                                     |
O----------------------------------------O-------O------------------------------O----------------------------------------O
Benchmark: 
Timing 1000 iterations of Mix(size=100, @p.elems=100), Random::Choice(size=100, @p.elems=100)...
Mix(size=100, @p.elems=100): 1.505 wallclock secs (1.511 usr 0.000 sys 1.511 cpu) @ 664.420/s (n=1000)
Random::Choice(size=100, @p.elems=100): 0.619 wallclock secs (0.624 usr 0.000 sys 0.624 cpu) @ 1616.535/s (n=1000)
O----------------------------------------O--------O-----------------------------O----------------------------------------O
|                                        | Rate   | Mix(size=100, @p.elems=100) | Random::Choice(size=100, @p.elems=100) |
O========================================O========O=============================O========================================O
| Mix(size=100, @p.elems=100)            | 664/s  | --                          | 146%                                   |
| Random::Choice(size=100, @p.elems=100) | 1617/s | -59%                        | --                                     |
O----------------------------------------O--------O-----------------------------O----------------------------------------O
Benchmark: 
Timing 1000 iterations of Mix(size=1000, @p.elems=1000), Random::Choice(size=1000, @p.elems=1000)...
Mix(size=1000, @p.elems=1000): 135.720 wallclock secs (135.946 usr 0.288 sys 136.234 cpu) @ 7.368/s (n=1000)
Random::Choice(size=1000, @p.elems=1000): 6.022 wallclock secs (6.031 usr 0.028 sys 6.058 cpu) @ 166.058/s (n=1000)
O------------------------------------------O--------O-------------------------------O------------------------------------------O
|                                          | Rate   | Mix(size=1000, @p.elems=1000) | Random::Choice(size=1000, @p.elems=1000) |
O==========================================O========O===============================O==========================================O
| Mix(size=1000, @p.elems=1000)            | 7.37/s | --                            | 2158%                                    |
| Random::Choice(size=1000, @p.elems=1000) | 166/s  | -96%                          | --                                       |
O------------------------------------------O--------O-------------------------------O------------------------------------------O

=end code

=head3 The Environment on the Benchmark

=item C<CPU> Ryzen7 5800X (8core)
=item C<OS> Debian11 bullseye

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2019 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

The algorithm is from:

=item Vose, Michael D. "A linear algorithm for generating random numbers with a given distribution." IEEE Transactions on software engineering 17.9 (1991): 972-975.

=end pod
