# Print as human readable graphics

# Copyright (c) 2011 Kaoru Maeda
# kaoru.maeda@gmail.com

use 5.010;
use strict;
use warnings;

sub main {
  while (<>) {
    next if /#/;
    my @pats = split(/ /, $_);
    my @board = ("______") x 6;
    for my $i (0..3) {
      fill(\@board, $pats[$i], $i+1);
    }
    print join("\n", @board), "\n\n";
  }
}

sub fill {
  my ($board, $pat, $char) = @_;
  my @hx = $pat =~ /(..)/g;
  shift @hx; pop @hx;
  @hx = map { unpack('B8', pack('H2', $_)) } @hx;
  for my $y (0..5) {
    for my $x (0..5) {
      if (substr($hx[$y], $x+1, 1) eq '1') {
	substr($board->[$y], $x, 1) = $char;
      }
    }
  }
}

main unless caller();
1;
