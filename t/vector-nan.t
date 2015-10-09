use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# nan - nan is double
{
  my $x_nan = r->c_double('NaN');
  ok(r->is->double($x_nan));
}

# negation
{
  my $x_nan1 = r->c_double('NaN');
  my $x_nan2 = r->negation($x_nan1);
  ok(r->is->nan($x_nan2)->value);
}

# non - to_string
{
  my $x_nan = r->c_double('NaN');
  is("$x_nan", "[1] NaN\n");
}

