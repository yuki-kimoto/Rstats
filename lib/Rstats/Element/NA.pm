package Rstats::Element::NA;
use Rstats::Element -base;

use overload 'bool' => sub { 0 },
  fallback => 1;

has type => 'na';

1;
