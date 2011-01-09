# Generate all 1285 nonominos

# Copyright (c) 2011 Kaoru Maeda
# kaoru.maeda@gmail.com

use 5.010;
use strict;
use warnings;

use lib '.';
use Mino;

my @dirs = ([-1,0],[1,0],[0,-1],[0,1]);

sub generate {
    my ($dim, $minos) = @_;
    my $found = {};
    for my $m (values %$minos) {
	for my $i (0..$dim-1) {
	    my $pivot = $m->[$i];
	  NEW_MINO:
	    for my $d (@dirs) {
		my $p = Point->new($pivot->[0]+$d->[0],$pivot->[1]+$d->[1]);
		next if $m->includes($p);
		my $new = $m->dup();
		$new->[$dim] = $p;
		$new->normalize();
		next NEW_MINO if $found->{$new->stringify()};
		my $test = $new;
		for my $rot (1..4) {
		    $test = $test->rotate();
		    for my $flx (1..2) {
			$test = $test->flipx();
			for my $fl45 (1..2) {
			    $test = $test->flip45()->normalize();
			    $found->{$test->stringify()} and next NEW_MINO;
			}
		    }
		}
		$found->{$new->stringify()} = $new;
	    }
	}
    }
    $found;
}

my @polyominos = ('', qw(monomino domino tromino tetromino pentomino
 			 hexomino heptomino octomino nonomino));

sub minos {
    $| = 1;
    my $seed = Mino->new();
    $seed->[0] = Point->new(0,0);
    my $minos = { $seed->stringify() => $seed };
    for my $dim (1..8) {
	say "Generating ", $polyominos[$dim+1];
	$minos = generate($dim, $minos);
    }
    open my $i, ">", "nonomino.h";
    for my $m (values %$minos) {
	print {$i} $m->stringify(), "\n";
    }
    close $i;
}

sub main {
    minos();
}

main() unless caller;
1;
