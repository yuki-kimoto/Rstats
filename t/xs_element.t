use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::ElementFunc;

# element
{
  # element - double
  {
    my $e1 = Rstats::ElementFunc::double_xs(2);
    ok(1);
  }
}

