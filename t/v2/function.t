use Test::More 'no_plan';

use strict;
use warnings;

use Rstats::V2;

my $r = Rstats::V2->new;

# $r->c([1, 2, 3])
{
  my $x1 = $r->c([0.5, 0.025, 0.0125]);
  
}

ok(1);
