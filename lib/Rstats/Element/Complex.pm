package Rstats::Element::Complex;
use Rstats::Element -base;

require Rstats::ElementFunction;

has type => 'complex';
has 're';
has 'im';

sub value {
  my $self = shift;
  return {re => Rstats::ElementFunction::value($self->re), im => Rstats::ElementFunction::value($self->im)}
}

1;
