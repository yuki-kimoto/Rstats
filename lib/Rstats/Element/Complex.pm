package Rstats::Element::Complex;
use Object::Simple -base;

require Rstats::ElementFunction;

has 're';
has 'im';

sub value {
  my $self = shift;
  return {re => Rstats::ElementFunction::value($self->re), im => Rstats::ElementFunction::value($self->im)}
}

1;
