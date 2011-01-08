# Remove duplication wrt rotation and mirror

# Copyright (c) 2011 Kaoru Maeda
# kaoru.maeda@gmail.com

use 5.010;
use strict;
use warnings;

my @perm4 = qw(1234 1243 1324 1342 1423 1432
	       2134 2143 2314 2341 2413 2431
	       3124 3142 3214 3241 3412 3421
	       4123 4132 4213 4231 4312 4321);

sub unique {
  local ($/) = '';
  my $found = {};
 BOARD:
  while (<>) {
    my $b = Board->new($_);
    next if $found->{$b->stringify()};
    for my $perm (@perm4) {
      my $new = $b->permute($perm);
      for my $rot (1..4) {
	$new = $new->rotate();
	for my $flx (1..2) {
	  $new = $new->flipx();
	  for my $fl45 (1..2) {
	    $new = $new->flip45();
	    if ($found->{$new->stringify()}) {
	      next BOARD;
	    }
	  }
	}
      }
    }
    $found->{$b->stringify()} = $b;
  }
  say scalar(keys(%$found)), " answers";

  for my $b (values %$found) {
    say $b->stringify(), "\n";
  }
}

sub main {
  unique();
}

package Board;
use constant EMPTY => "111111\n" x 6;
sub new {
  my ($class, $str) = @_;
  my @lines = split(/\n/, $str // EMPTY);
  splice(@lines, 6) if @lines > 6;
  @lines = map { [split(//, substr($_ . "111111", 0, 6))] } @lines;
  bless \@lines, $class;
}
sub stringify { join("\n", map {join('', @$_)} @{$_[0]}) }
sub dup {
  my $self = shift;
  my $new = Board->new('');
  @$new = @$self;
  $new;
}
sub permute {
  my ($self, $pat) = @_;
  my $str = $self->stringify();
  eval "\$str =~ tr/1234/$pat/";
  Board->new($str);
}
sub rotate {
  my $self = shift;
  my $new = Board->new('');
  for my $x (0..5) {
    for my $y (0..5) {
      $new->[$y][$x] = $self->[5-$x][$y];
    }
  }
  $new;
}
sub flipx {
  my $self = shift;
  my $new = Board->new('');
  for my $x (0..5) {
    for my $y (0..5) {
      $new->[$y][$x] = $self->[$y][5-$x];
    }
  }
  $new;
}
sub flip45 {
  my $self = shift;
  my $new = Board->new('');
  for my $x (0..5) {
    for my $y (0..5) {
      $new->[$y][$x] = $self->[$x][$y];
    }
  }
  $new;
}

package main;
main() unless caller;
1;
