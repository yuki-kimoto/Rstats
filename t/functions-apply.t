use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# apply
{
  my $x = matrix(C('1:8'), {ncol => 4});
  ok(1);
}

