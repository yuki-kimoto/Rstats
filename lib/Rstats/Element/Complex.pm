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

1;
