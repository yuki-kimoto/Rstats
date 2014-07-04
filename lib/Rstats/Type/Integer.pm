package Rstats::Type::Integer;
use Object::Simple -base;

use Carp 'croak';

use overload
  'bool' => \&bool,
  'neg' => \&negation,
  '""' => \&to_string;

has 'value';

sub bool { croak 'argument is not interpretable as logical' }

sub negation { -shift->value }

sub to_string { shift->value . "" }

1;

