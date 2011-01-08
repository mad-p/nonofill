# Flip and rotate nonominos, excluding those larger than 6x6
# Copyright (c) 2011 Kaoru Maeda
# kaoru.maeda@gmail.com

use 5.010;
use strict;
use warnings;

sub fliprot {
  my ($mino, $out, $no) = @_;
  my ($minx, $miny, $maxx, $maxy) = $mino->bbox();
  my $width  = $maxx - $minx + 1;
  my $height = $maxy - $miny + 1;
  return if $width > 6 || $height > 6;

  my $found = {};
  my $test = $mino;
  for my $rot (1..4) {
    $test = $test->rotate();
    for my $flx (1..2) {
      $test = $test->flipx();
      for my $fl45 (1..2) {
	$test = $test->flip45()->normalize();
	$found->{$test->stringify()} //= $test;
      }
    }
  }

  say {$out} "/* No: $no: $_ */";
  for my $m (values %$found) {
    my ($minx, $miny, $maxx, $maxy) = $m->bbox();
    my $width  = $maxx - $minx + 1;
    my $height = $maxy - $miny + 1;
    say {$out} "{ ", $m->binarify(), ", $width, $height },";
  }
  say {$out} "{0,0,0},\n";
}

sub filter {
  open my $out, ">", "nonopat.h";
  open my $in, "<", "nonomino.h";
  my $no = 0;
  while (<$in>) {
    chomp;
    my $mino = Mino->new()->parse($_);
    ++$no;
    fliprot($mino, $out, $no);
  }
  close $in;
  close $out;
}

sub main {
  filter();
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

sub parse {
  my ($self, $str) = @_;
  @$self = $str =~ /(-?\d+)/g;
  $self;
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
  ;

sub parse {
  my ($self, $str) = @_;
  @$self = map { Point->new(0,0)->parse($_) } $str =~ /(-?\d+,-?\d+)/g;
  $self;
}

sub binarify {
  my $self = shift;
  my @str = split(/\n/, $self->print());
  @str = map { tr/_x/01/; sprintf("%02x", eval "0b" . substr("0" . $_ . "000000000", 0, 8)) } @str;
  @str = (@str, ("00")x6);
  splice(@str, 6);
  join('', "0x00", @str, "00ull");
}

package main;
main() unless caller;
1;
