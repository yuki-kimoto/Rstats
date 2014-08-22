package Rstats::Element::NA;
use Rstats::Element -base;

use overload 'bool' => sub { 0 },
  fallback => 1;

has type => 'na';

sub value { undef }

sub is_infinite {
  my $self = shift;
  return $self->is_positive_infinite || $self->is_negative_infinite;
}

sub is_positive_infinite {
  my $self = shift;
  
  return $self->type eq 'double' && $self->flag eq 'inf';
}

sub is_negative_infinite {
  my $self = shift;
  
  return $self->type eq 'double' && $self->flag eq '-inf';
}

sub is_finite {
  my $self = shift;
  
  return $self->is_integer || ($self->is_double && defined $self->{value});
}

sub is_na { Rstats::ElementFunction::TRUE }

1;
