package Rstats::NA;
use Object::Simple -base;

use overload
  '""' => \&to_string,
  fallback => 1;


sub to_string { 'NA' }

1;
