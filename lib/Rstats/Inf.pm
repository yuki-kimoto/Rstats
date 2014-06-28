package Rstats::Inf;
use Object::Simple -base;

use overload
  '""' => \&to_string,
  fallback => 1;

my $Inf = Rstats::Inf->new;

sub Inf { $Inf }

sub to_string { 'Inf' }

1;