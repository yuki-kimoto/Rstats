package Rstats::Type::Double;
use Object::Simple -base;

use Carp 'croak';
require Rstats::Util;

has 'value';
has 'flag';

1;
