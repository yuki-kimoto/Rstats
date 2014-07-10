package Rstats;
use strict;
use warnings;

our $VERSION = '0.01';

use Rstats::Class;

sub import {
  my $self = shift;
  
  my $class = caller;
  
  my $r = Rstats::Class->new;
  
  my @methods = qw/c C array matrix i TRUE FALSE NA NaN Inf/;
  
  no strict 'refs';
  for my $method (@methods) {
    *{"${class}::$method"} = sub { $r->$method(@_) }
  }
  *{"${class}::r"} = sub { $r };
}

1;

=head1 NAME

Rstats::Class - Rstats class interface

=head1 SYNOPSYS
  
  use Rstats;
  
  my $r = Rstats::Class->new;
  
  # Vector
  my $v1 = c(1, 2, 3);
  my $v2 = c(3, 4, 5);
  
  my $v3 = $v1 + v2;
  print $v3;
  
  # Sequence
  my $v1 = C('1:3');

  # Matrix
  my $m1 = matrix(C('1:12'), 4, 3);
  
  # Array
  my $a1 = array(C(1:24), c(4, 3, 2));

  # Complex
  my $z1 = 1 + 2 * i;
  my $z2 = 3 + 4 * i;
  my $z3 = $z1 * $z2;
  
  # Special value
  my $true = TRUE;
  my $false = FALSE;
  my $na = NA;
  my $nan = Nan;
  my $inf = Inf;
  
  # Other method is called from r
  my $a1 = r->sum(c(1, 2, 3));
