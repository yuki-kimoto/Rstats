package Rstats::Type::Character;
use Object::Simple -base;

use Carp 'croak';

use overload
  'bool' => \&bool,
  'neg' => \&negation,
  '""' => \&to_string;

has 'value';

sub negation { croak 'argument is not interpretable as logical' }

sub to_string { shift->value . "" }

1;
