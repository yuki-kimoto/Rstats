package Rstats::Element::Complex;
use Rstats::Element -base;

require Rstats::ElementFunction;

has type => 'complex';
has 're';
has 'im';

sub value {
  my $self = shift;
  
  return {
    re => $self->re->value,
    im => $self->im->value
  };
}

sub is_complex { Rstats::ElementFunction::TRUE }

sub is_infinite {
  my $self = shift;
  return $self->re->is_infinite || $self->im->is_infinite;
}

sub is_finite {
  my $self = shift;
  
  return !$self->is_infinite;
}

1;
