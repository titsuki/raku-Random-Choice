use v6;
use Chart::Gnuplot;
use Chart::Gnuplot::Subset;

my (@mix, @ran);
for "{$*PROGRAM.parent}/bench-result-for-plot.txt".IO.lines {
    my ($method, $size, $p-elems, $picks-per-sec) = .split(" ");
    given $method {
        when "mix" { @mix.push: [($size, $p-elems).join("/"), $picks-per-sec] }
        when "ran" { @ran.push: [($size, $p-elems).join("/"), $picks-per-sec] }
    }
}

my AnyTicsTic @tics = (@mix>>.[0]).pairs.map(-> (:key($pos), :value($criteria)) { %(:label($criteria), :pos($pos)) });

my %mix = %(:vertices(@mix), :using([2]), :style("histogram"), :title("Mix.roll"), :fill("solid 1.0"));
my %ran = %(:vertices(@ran), :using([2]), :style("histogram"), :title("Random::Choice"), :fill("solid 1.0"));

my $gnu = Chart::Gnuplot.new(:terminal("svg"), :filename("{$*PROGRAM.parent}/bench.svg"));
$gnu.command("set style fill pattern border -1");
$gnu.command("set style histogram clustered");
$gnu.legend(:right);
$gnu.xtics(:tics(@tics));
$gnu.ylabel(:label("picks/sec"));
$gnu.xlabel(:label("sample/population size"));
$gnu.plot(|%mix);
$gnu.plot(|%ran);
$gnu.dispose;
