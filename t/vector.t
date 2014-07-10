use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# names
{
  my $v1 = c(1, 2, 3, 4);
  r->names($v1 => c('a', 'b', 'c', 'd'));
  my $v2 = $v1->get(c('b', 'd'));
  is_deeply($v2->values, [2, 4]);
}

# to_string
{
  my $v = c(1, 2, 3);
  r->names($v => c('a', 'b', 'c'));
  is("$v", "a b c\n[1] 1 2 3\n");
}
