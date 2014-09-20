use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# apply
{
  # apply - margin 1
  my $x1 = matrix(C('1:6'), 2, 3);
  my $x2 = r->apply($x1, 1, 'sum');
  is_deeply($x2->values, [9, 12]);
  is_deeply($x2->dim->values, []);
}

