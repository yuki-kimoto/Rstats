package Rstats::Element::Complex;
use Object::Simple -base;

require Rstats::Util;

has 're';
has 'im';

sub value {
  my $self = shift;
  return {re => Rstats::Util::value($self->re), im => Rstats::Util::value($self->im)}
}

1;
