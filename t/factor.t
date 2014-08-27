use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# factor
{
  # factor - basic
  {
    my $f1 = factor(c("a", "b", "c", "a", "b", "c"));
    ok($f1->is_integer);
    is_deeply($f1->values, [0, 1, 2, 0, 1 ,2]);
    is_deeply($f1->levels->values, ["a", "b", "c"]);
  }
}

