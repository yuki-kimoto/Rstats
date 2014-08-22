package Rstats::Element::Logical;
use Rstats::Element -base;

use overload 'bool' => sub { shift->{value} },
  fallback => 1;

has type => 'logical';

sub value {
  my $self = shift;
  
  if ($self->{value}) {
    return '__TRUE__';
  }
  else {
    return '__FALSE__';
  }
}

sub is_logical { Rstats::ElementFunction::TRUE }

sub is_finite { Rstats::ElementFunction::TRUE }

1;
