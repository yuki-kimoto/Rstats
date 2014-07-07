package Rstats::Type::Integer;
use Object::Simple -base;

use Carp 'croak';

use overload
  'bool' => \&bool,
  'neg' => \&negation,
  '""' => \&to_string;

has 'value';

sub negation { -shift->value }

sub to_string { shift->value . "" }

1;

