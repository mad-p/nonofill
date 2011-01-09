# Remove duplication wrt rotation and mirror

# Copyright (c) 2011 Kaoru Maeda
# kaoru.maeda@gmail.com

use 5.010;
use strict;
use warnings;

sub unique {
  local ($/) = '';
  my $found = {};
  my $uniq = {};
 BOARD:
  while (<>) {
    my $b = Board->new($_)->normalize();
    next if $found->{$b->stringify()};
    my $unique = 1;
    for my $rot (1..4) {
      my $new = $b->rotate();
      for my $flx (1..2) {
	$new = $new->flipx();
	for my $fl45 (1..2) {
	  $new = $new->flip45()->normalize();
	  if ($uniq->{$new->stringify()}) {
	    $unique = 0;
	  }
	  $found->{$new->stringify()} //= $new;
	}
      }
    }
    if ($unique) {
      $uniq->{$b->stringify()} = $b;
    }
  }

  output($found, "answers.txt");
  output($uniq,  "unique_answers.txt");
}

sub output {
  my ($boards, $file) = @_;
  open my $out, ">", $file;
  say {$out} scalar(keys(%$boards)), " answers";
  my @b = values %$boards;
  @b = (map { $_->[0] }
	sort { $a->[1] cmp $b->[1] }
	map { [$_, $_->stringify()] } @b);
  for my $b (@b) {
    say {$out} $b->stringify(), "\n";
  }
  close $out;
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
  unless (length($pat) == 4 &&
	  $pat =~ /1/ && $pat =~ /2/ &&
	  $pat =~ /3/ && $pat =~ /4/) {
      die "trying to permute with $pat";
  }
  my $str = $self->stringify();
  eval "\$str =~ tr/$pat/1234/";
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
sub normalize {
  my $self = shift;
  my $tl = $self->[0][0];
  my $tr = $self->[0][5];
  my $bl = $self->[5][0];
  my $br = $self->[5][5];
  if ($tl == $bl) {
      return $self->flip45()->normalize();
  }
  if ($tl == $tr) {
    $tr = $self->[2][5];
    $bl = $self->[3][0];
  }
  $self = $self->permute($tl . $tr . $br . $bl);
  for my $l (@$self) {
      if ($l !~ /^[14][14][14]/) {
	  return $self;
      }
  }
  return $self->flip45()->normalize();
}

package main;
main() unless caller;
1;
