package Rstats::DataFrame;
use Rstats::List -base;

use Rstats::DataFrameFunc;

sub get { Rstats::DataFrameFunc::get(undef(), @_) }

1;

=head1 NAME

Rstats::DataFrame - Data frame

