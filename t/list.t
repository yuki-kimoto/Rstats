use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# list
{
  # list - basic
  {
    my $l1 = r->list(c(1, 2, 3), r->list("Hello", c(T, F, F)));
    is_deeply($l1->elements->[0]->values, [1, 2, 3]);
    is_deeply($l1->elements->[1]->elements->[0]->values, ["Hello"]);
    is_deeply(
      $l1->elements->[1]->elements->[1]->elements,
      [Rstats::Util::TRUE, Rstats::Util::FALSE, Rstats::Util::FALSE]
    );
  }
  
  # list - to_string
  {
    my $l1 = r->list(c(1, 2, 3), r->list("Hello", c(T, F, F)));
    my $str = $l1->to_string;
    my $expected = <<"EOS";
[[1]]
[1] 1 2 3

[[2]]
[[2]][[1]]
[1] Hello

[[2]][[2]]
[1] TRUE FALSE FALSE

EOS
    is($str, $expected);
  }

  # list - length
  {
    my $l1 = r->list("a", "b");
    is_deeply(r->length($l1)->values, [2]);
  }
}
