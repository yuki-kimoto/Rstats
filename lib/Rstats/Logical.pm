package Rstats::Logical;
use Object::Simple -base;

use overload
  bool => \&bool,
  '""' => \&to_string,
  fallback => 1;

has 'logical';

sub bool {
  my $self = shift;
  
  return $self->logical ? 1 : 0;
}

sub to_string {
  my $self = shift;
  
  return $self->logical ? 'TRUE' : 'FALSE';
}

1;
