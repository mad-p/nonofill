use 5.010;
use strict;
use warnings;

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

sub minos {
    $| = 1;
    my $seed = Mino->new();
    $seed->[0] = Point->new(0,0);
    my $minos = { $seed->stringify() => $seed };
    for my $dim (1..8) {
	say "Dimension: $dim";
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

package Point;
sub new {
    my $class = shift;
    bless [@_], $class;
}

sub dup {
    my $self = shift;
    Point->new($self->[0], $self->[1]);
}

sub cmp($$) {
    $_[0][1] <=> $_[1][1] || $_[0][0] <=> $_[1][0];
}

sub stringify {
    "{" . join(",", @{$_[0]}) . "}";
}

package Mino;
use List::Util qw(min max);

sub new {
    my $class = shift;
    bless [], $class;
}

sub dup {
    my $self = shift;
    my $new = Mino->new();
    for my $i (0..$#$self) {
	$new->[$i] = $self->[$i]->dup();
    }
    $new;
}

sub stringify {
    "{" . join(",", map {$_->stringify()} @{$_[0]}) . "}";
}

sub normalize {
    my $self = shift;
    my @sorted = sort Point::cmp @$self;
    for my $i (1..$#sorted) {
	$sorted[$i][0] -= $sorted[0][0];
	$sorted[$i][1] -= $sorted[0][1];
    }
    $sorted[0][0] = $sorted[0][1] = 0;
    @$self = @sorted;
    $self;
}

sub bbox {
    my $self = shift;
    my $minx = min(map { $_->[0] } @$self);
    my $miny = min(map { $_->[1] } @$self);
    my $maxx = max(map { $_->[0] } @$self);
    my $maxy = max(map { $_->[1] } @$self);
    ($minx, $miny, $maxx, $maxy);
}

sub includes {
    my ($self, $point) = @_;
    for (@$self) {
	return 1 if $point->[0] == $_->[0] && $point->[1] == $_->[1];
    }
    return 0;
}

sub rotate {
    my $self = shift->dup();
    for my $i (0..$#$self) {
	@{$self->[$i]} = (-$self->[$i][1], $self->[$i][0]);
    }
    $self;
}

sub flipx {
    my $self = shift->dup();
    for my $i (0..$#$self) {
	@{$self->[$i]} = (-$self->[$i][0], $self->[$i][1]);
    }
    $self;
}

sub flip45 {
    my $self = shift->dup();
    for my $i (0..$#$self) {
	@{$self->[$i]} = ($self->[$i][1], $self->[$i][0]);
    }
    $self;
}

sub print {
    my $self = shift;
    my $char = $_[0] // 'x';    
    my ($minx, $miny, $maxx, $maxy) = $self->bbox();
    my $line = ("_" x ($maxx - $minx + 1));
    my @canvas = ($line) x ($maxy - $miny + 1);
    for (@$self) {
	substr($canvas[$_->[1]-$miny], $_->[0]-$minx, 1) = $char;
    }
    join("\n", @canvas);
}

package main;
main() unless caller;
1;
