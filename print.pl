# Print as human readable graphics

# Copyright (c) 2011 Kaoru Maeda
# kaoru.maeda@gmail.com

use 5.010;
use strict;
use warnings;

use lib '.';
use Omino;

sub main {
  my $count = 0;
  my $found = {};
  while (<>) {
    if (/#/) {
      output($found);
      $found = {};
      next;
    }
    my @pats = split(/ /, $_);
    my @board = ("______") x 6;
    for my $i (0..3) {
      fill(\@board, $pats[$i], $i+1);
    }
    $found->{$_} = \@board;
    $count++;
  }
  say "# total $count solutions";
  say STDERR "# total $count solutions";
}

sub output {
  my $found = shift;
  my @pats = sort keys %$found;
  my ($mino) = $pats[0] =~ /(\S+)/;
  $mino = Omino->new()->parse_binary($mino);
  my @mino = split(/\n/, $mino->print());

  say "# ", scalar(@pats), " solutions with:";
  for my $p (@mino) {
    say "# $p";
  }
  say '';

  for my $p (@pats) {
    my $lines = $found->{$p};
    print join("\n", @$lines), "\n\n";
  }
}

sub fill {
  my ($board, $pat, $char) = @_;
  $pat =~ s/^0x//;
  $pat =~ s/ull$//;
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
