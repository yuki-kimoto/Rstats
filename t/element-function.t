use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::Util;

ok(1);

# sqrt
{
  my $e1 = Rstats::Util::double(4);
  my $e2 = Rstats::Util::sqrt($e1);
  is($e2->value, 2);
}
