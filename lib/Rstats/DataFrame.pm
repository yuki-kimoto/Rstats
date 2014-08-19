package Rstats::DataFrame;
use Rstats::List -base;

use List::Util ();
use Carp 'croak';
use Rstats::ArrayUtil;

has 'columns';

1;
