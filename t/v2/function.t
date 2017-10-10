use Test::More 'no_plan';

use strict;
use warnings;

use Rstats;

my $r = Rstats->new;

# double
{
  my $x1 = $r->double([1, 2, 3]);
}

# sin
{
  my $x1 = $r->double([1.6, 1.6, 1.6]);
  
  $r->v2_sin($x1 => $x1);
}

ok(1);
