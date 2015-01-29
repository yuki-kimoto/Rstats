package Rstats::Func::Vector;

use strict;
use warnings;
use Carp 'croak', 'carp';

require Rstats;
use Rstats::Vector;

sub new_vector {
  my $type = shift;
  
  if ($type eq 'character') {
    return new_character(@_);
  }
  elsif ($type eq 'complex') {
    return new_complex(@_);
  }
  elsif ($type eq 'double') {
    return new_double(@_);
  }
  elsif ($type eq 'integer') {
    return new_integer(@_);
  }
  elsif ($type eq 'logical') {
    return new_logical(@_);
  }
  else {
    croak("Invalid type $type is passed(new_vector)");
  }
}

1;
=head1 NAME

Rstats::Func::Vector - Vector functions

1;
