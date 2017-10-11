use Test::More 'no_plan';

use strict;
use warnings;

use Rstats;

my $r = Rstats->new;

# double
{
  my $x1 = $r->double([1, 2, 3]);
}

# add
{
  my $x1 = $r->double([1, 0.5, 0.25]);
  my $x2 = $r->double([1, 0.5, 0.125]);
  
  my $x3 = $r->v2_add($x1, $x2);
}

# sin
{
  my $x1 = $r->double([1.6, 1.6, 1.6]);
  
  my $x2 = $r->v2_sin($x1);
}

ok(1);
