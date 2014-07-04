package Rstats::Type::NA;
use Object::Simple -base;

use Carp 'croak';
require Rstats::Util;

use overload
  'bool' => \&bool,
  'neg' => \&nagation,
  '""' => \&to_string;

sub bool { croak "Error in bool context (a) { : missing value where TRUE/FALSE needed" }

sub nagation { Rstats::Util::na() }

sub to_string { 'NA' }

1;
