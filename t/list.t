use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# list
{
  # list - basic
  my $l1 = r->list(c(1, 2, 3), r->list("Hello", c(T, F, F)));
  is_deeply($l1->elements->[0]->values, [1, 2, 3]);
  is_deeply($l1->elements->[1]->elements->[0]->values, ["Hello"]);
  is_deeply(
    $l1->elements->[1]->elements->[1]->elements,
    [Rstats::Util::TRUE, Rstats::Util::FALSE, Rstats::Util::FALSE]
  );
  
}
