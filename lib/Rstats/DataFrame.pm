package Rstats::DataFrame;
use Rstats::List -base;

use overload '""' => \&to_string,
  fallback => 1;

use Rstats::Func::DataFrame;

sub get { Rstats::Func::DataFrame::get(@_) }
sub to_string { Rstats::Func::DataFrame::to_string(@_) }

1;

=head1 NAME

Rstats::DataFrame - Data frame

