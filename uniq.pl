# Remove duplication wrt rotation and mirror

# Copyright (c) 2011 Kaoru Maeda
# kaoru.maeda@gmail.com

use 5.010;
use strict;
use warnings;

use lib '.';
use Omino;

sub main {
  uniq();
}

sub stringify {
  join(' ', sort map { $_->binarify() } @_);
}

sub uniq {
  my $found = {};
 SOLUTION:
  while (<>) {
    (print), next if /#/;
    my @minos = map { Omino->new()->parse_binary($_) } /(\S+)/g;
    my $str = stringify(@minos);
    if ($found->{$str}) {
      next SOLUTION;
    }

    my @new = @minos;
    my $repl = $str;
    for my $r (1..4) {
      @new = map { $_->rotate() } @new;
      for my $fx (1..2) {
	@new = map { $_->flipx() } @new;
	my $new = stringify(@new);
	if ($found->{$new}) {
	  # print STDERR "Dup: $new from $_";
	  next SOLUTION;
	}
	$new lt $repl and $repl = $new;
      }
    }

    # ok, it's unique
    $found->{$str} = $repl;
    say $repl;
  }
}

main() unless caller;
1;
