package Rstats::DataFrame;
use Rstats::List -base;

use overload '""' => \&to_string,
  fallback => 1;

use Rstats::DataFrameFunc;

sub get { Rstats::DataFrameFunc::get(undef(), @_) }
sub to_string { Rstats::DataFrameFunc::to_string(undef(), @_) }

1;

=head1 NAME

Rstats::DataFrame - Data frame

