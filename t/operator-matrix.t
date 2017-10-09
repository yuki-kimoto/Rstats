use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats;

my $r = Rstats->new;

# inner product
{
  # inner product - inner product
  {
    my $x1 = $r->array($r->c(1, 2, 3), $r->c(1, 3));
    my $x2 = $r->array($r->c(4, 5, 6), $r->c(3, 1));
    my $x3 = $r->inner_product($x1, $x2);
    is_deeply($x3->values, [32]);
    is_deeply($r->dim($x3)->values, [1, 1]);
  }
}
