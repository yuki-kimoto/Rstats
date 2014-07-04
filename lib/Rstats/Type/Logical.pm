package Rstats::Type::Logical;
use Object::Simple -base;

use Rstats::Util;
use Rstats::Type::Integer;

use overload
  bool => \&bool,
  neg => \&nagation,
  '""' => \&to_string;

has 'value';

sub bool { shift->value }

sub nagation {
  shift->value
    ? Rstats::Type::Integer->new(value => 0)
    : Rstats::Type::Integer->new(value => 1);
}

sub to_string { shift->value ? 'TRUE' : 'FALSE' }

1;
