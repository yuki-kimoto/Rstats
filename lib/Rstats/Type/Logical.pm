package Rstats::Type::Logical;
use Object::Simple -base;

use Rstats::Util;

use overload
  bool => sub { shift->value },
  neg => sub { shift->value ? Rstats::Util::false : Rstats::Util::true }
  '""' => \&to_string;

has 'value';

sub bool { shift->value }

sub nagation { shift->value ? Rstats::Util::false : Rstats::Util::true }

sub to_string { shift->value ? 'TRUE' : 'FALSE' }

1;
