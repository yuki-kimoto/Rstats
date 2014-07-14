package Rstats::Element::Logical;
use Object::Simple -base;

use overload 'bool' => sub { shift->value },
  fallback => 1;

has 'value';

1;
