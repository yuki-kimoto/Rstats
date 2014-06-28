package Rstats::NaN;
use Object::Simple -base;

use overload
  '""' => \&to_string,
  fallback => 1;

my $NaN = Rstats::NaN->new;

sub NaN { $NaN }

sub to_string { 'NaN' }

1;
