package Rstats::Inf;
use Object::Simple -base;

use overload
  '""' => \&to_string,
  fallback => 1;


sub to_string { 'Inf' }

1;