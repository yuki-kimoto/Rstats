package Rstats::NaN;
use Object::Simple -base;

use overload
  '""' => \&to_string,
  fallback => 1;


sub to_string { 'NaN' }

1;
