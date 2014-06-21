use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

my $r = Rstats->new;

# 3-dimention test
{
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    is_deeply($a1->values, [1 .. 24]);
    is_deeply($r->dim($a1)->values, [4, 3, 2]);
  }
  
  {
    my $a1 = $r->array('1:24', {dim => [4, 3, 2]});
    is_deeply($a1->values, [1 .. 24]);
    is_deeply($r->dim($a1)->values, [4, 3, 2]);
  }
}
