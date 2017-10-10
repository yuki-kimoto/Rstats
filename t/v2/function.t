use Test::More 'no_plan';

use strict;
use warnings;

use Rstats;

my $r = Rstats->new;

# double
{
  my $x1 = $r->double([1, 2, 3]);
}

ok(1);
