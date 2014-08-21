package Rstats::Element::Logical;
use Rstats::Element -base;

use overload 'bool' => sub { shift->{iv} },
  fallback => 1;

has type => 'logical';

1;
