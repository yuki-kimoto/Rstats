use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

my $r = Rstats->new;

# matrix
{
  {
    my $m1 = $r->matrix('1:12', 3, 4);
    is_deeply($m1->values, [1 .. 12]);
    is_deeply($r->dim($m1)->values, [3, 4]);
    ok($m1->is_matrix);
  }
}
