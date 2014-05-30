use Test::More 'no_plan';
use strict;
use warnings;

use Data::R;

# Vector
{
  # add
  {
    my $r = Data::R->new;
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $r->c([2, 3, 4]);
    my $v3 = $v1 + $v2;
    is_deeply($v3->values, [3, 5, 7]);
  }
}
