# Remove duplication wrt rotation and mirror

# Copyright (c) 2011 Kaoru Maeda
# kaoru.maeda@gmail.com

use 5.010;
use strict;
use warnings;

use lib '.';
use Mino;

sub main {
  uniq();
}

sub stringify {
  join(' ', sort map { $_->binarify() } @_);
}

sub uniq {
  my $found = {};
 ANSWER:
  while (<>) {
    next if /#/;
    my @minos = map { Mino->new()->parse_binary($_) } /(\S+)/g;
    my $str = stringify(@minos);
    if ($found->{$str}) {
      next ANSWER;
    }

    my @new = @minos;
    for my $r (1..4) {
      @new = map { $_->rotate() } @new;
      for my $fx (1..2) {
	@new = map { $_->flipx() } @new;
	for my $f45 (1..2) {
	  @new = map { $_->flip45() } @new;
	  my $new = stringify(@new);
	  if ($found->{$new}) {
	    # print STDERR "Dup: $new from $_";
	    next ANSWER;
	  }
	}
      }
    }

    # ok, it's unique
    $found->{$str} = $_;
    print $_;
  }
}

main() unless caller;
1;
