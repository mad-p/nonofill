use 5.010;
use strict;
use warnings;

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

package Omino;
use List::Util qw(min max);

sub new {
  my $class = shift;
  bless [], $class;
}

sub dup {
  my $self = shift;
  my $new = Omino->new();
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
    @{$self->[$i]} = (5-$self->[$i][1], $self->[$i][0]);
  }
  $self;
}

sub flipx {
  my $self = shift->dup();
  for my $i (0..$#$self) {
    @{$self->[$i]} = (5-$self->[$i][0], $self->[$i][1]);
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
  my ($minx, $miny, $maxx, $maxy) = $self->bbox();
  if ($minx < 0 || $miny < 0 || $maxx > 5 || $maxy > 5) {
    die "binarify out of range";
  }
  my @hx = ("00000000") x 6;
  for my $p (@$self) {
    substr($hx[$p->[1]], $p->[0]+1, 1) = '1';
  }
  join('', "0x00", (map { unpack('H2', pack('B8', $_)) } @hx), "00ull");
}

sub parse_binary {
  my ($self, $str) = @_;
  $str =~ s/^0x//;
  $str =~ s/ull$//;
  my @hx = $str =~ /(..)/g;
  shift @hx; pop @hx;
  @hx = map { unpack('B8', pack('H2', $_)) } @hx;
  my $i = 0;
  for my $y (0..5) {
    for my $x (0..5) {
      if (substr($hx[$y], $x+1, 1) eq '1') {
	$self->[$i++] = Point->new($x, $y);
      }
    }
  }
  $self;
}

sub test {
  my $pat = '0x0000000c04047c00ull';
  my $m = Omino->new();
  $m->parse_binary($pat);
  say $m->print();
  say $m->binarify();
  say $pat eq $m->binarify() ? "Ok 1" : "NG 1";
  my $r = $m->rotate();
  say $r->print();
  say $r->binarify();
}

test() unless caller;

1;
