use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# nan - nan is double
{
  my $x_nan = r->c_double('NaN');
  ok(r->is->double($x_nan));
}

# non - to_string
{
  my $x_nan = r->c_double('NaN');
  is("$x_nan", "[1] NaN\n");
}
