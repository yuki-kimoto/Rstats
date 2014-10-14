use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::ElementFunc;

# element
{
  # element - double_xs
  {
    my $e1 = Rstats::ElementFunc::double_xs(2.5);
    is($e1->type, 'double');
    is($e1->dv, 2.5);
  }

  # element - integer_xs
  {
    my $e1 = Rstats::ElementFunc::integer_xs(2);
    is($e1->type, 'integer');
    is($e1->iv, 2);
  }
}

