package Rstats::Element::Logical;
use Rstats::Element -base;

use overload 'bool' => sub { shift->{value} },
  fallback => 1;

has type => 'logical';

1;
