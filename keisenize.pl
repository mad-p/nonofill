# Rule character representation of solution
# Copyright (c) 2011 Kaoru Maeda
# kaoru.maeda@gmail.com

use strict;
use warnings;
use utf8;
use open qw(:utf8 :std);

my @Rules = split(//, "\x{3000}××┗×┃┏┣×┛━┻┓┫┳╋");

$/ ='';

while (<>) {
    next if /#/;
    $_ = convert($_);
} continue {
    print $_;
}

sub convert {
    my $src = shift;

    # split board into lines
    my @lines = split(/\n/, $src);

    # fill border with spaces
    my $cols = length($lines[0]);
    my $rows = @lines;
    for (@lines) {
	$_ = [ ' ', split(//, $_), ' ' ];
    }
    my $empty = [(' ') x ($cols + 2)];
    push(@lines, $empty);
    unshift(@lines, $empty); # we can reuse $empty because @lines is r/o

    my @result;

    for my $y (0..$rows) {
	for my $x (0..$cols) {
	    my $border = 0;
	    $lines[$y  ][$x  ] ne $lines[$y  ][$x+1] and $border |= 1;
	    $lines[$y  ][$x+1] ne $lines[$y+1][$x+1] and $border |= 2;
	    $lines[$y+1][$x+1] ne $lines[$y+1][$x  ] and $border |= 4;
	    $lines[$y+1][$x  ] ne $lines[$y  ][$x  ] and $border |= 8;
	    $result[$y][$x] = $Rules[$border];
	}
    }

    # put original board at the right of the result
    for my $y (0..$rows-1) {
	push(@{$result[$y]}, '    ', @{$lines[$y+1]});
    }

    for (@result) {
	$_ = join('', @$_);
    }

    join("\n", @result) . "\n\n";
}
