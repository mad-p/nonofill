# Flip and rotate nonominos, excluding those larger than 6x6
# Copyright (c) 2011 Kaoru Maeda
# kaoru.maeda@gmail.com

use 5.010;
use strict;
use warnings;
use lib '.';

use Mino;

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

main() unless caller;
1;
