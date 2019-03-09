use Bench;

my $bench = Bench.new;
my $repeat-times = 1000;

my $rc-code = -> $size, @p {
sub {
    use Random::Choice;
    choice(:$size, :@p);
}
};

sub choice(:$size where * ≥ 1 = 1, :@p where abs(1 - .sum) < 1e-3) {
    @p.pairs.Mix.roll($size)
}

sub generate-p(Int $n --> List) {
    my @p;
    for ^$n {
        @p.push: rand;
    }

    my $sum = @p.sum;
    @p.map(* / $sum).List
}

my $mix-code = -> $size, @p {
sub {
    choice(:$size, :@p);
}
};


{
    my @p = generate-p(10);
    $bench.cmpthese($repeat-times, %(
                        'Random::Choice' => $rc-code(10, @p),
                        'Mix' => $mix-code(10, @p)
                    ));
}

{
    my @p = generate-p(100);
    $bench.cmpthese($repeat-times, %(
                        'Random::Choice' => $rc-code(100, @p),
                        'Mix' => $mix-code(100, @p)
                    ));
}

{
    my @p = generate-p(1000);
    $bench.cmpthese($repeat-times, %(
                        'Random::Choice' => $rc-code(1000, @p),
                        'Mix' => $mix-code(1000, @p)
                    ));
}
