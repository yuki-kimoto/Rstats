package Rstats::Element::Double;
use Rstats::Element -base;

use Carp 'croak';
require Rstats::ElementFunction;

has type => 'double';
has 'flag';

1;
