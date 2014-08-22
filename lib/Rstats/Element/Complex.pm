package Rstats::Element::Complex;
use Rstats::Element -base;

require Rstats::ElementFunction;

has type => 'complex';
has 're';
has 'im';

1;
