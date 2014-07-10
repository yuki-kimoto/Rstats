package Rstats::Lite;
use strict;
use warnings;

use Rstats;

sub import {
  my $self = shift;
  
  my $class = caller;
  
  my $r = Rstats->new;
  
  my @methods = qw/c C array matrix i TRUE FALSE NA NaN Inf/;
  
  no strict 'refs';
  for my $method (@methods) {
    *{"${class}::$method"} = sub { $r->$method(@_) }
  }
  *{"${class}::r"} = sub { $r };
}

1;
