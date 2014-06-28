package Rstats::NA;
use Object::Simple -base;

use overload
  '""' => \&to_string,
  fallback => 1;

my $NA = Rstats::NA->new;

sub NA { $NA }

sub to_string { 'NA' }

1;
