use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# list
{
  # list - basic
  {
    my $l1 = list(c(1, 2, 3), list("Hello", c(T, F, F)));
    is_deeply($l1->elements->[0]->values, [1, 2, 3]);
    is_deeply($l1->elements->[1]->elements->[0]->values, ["Hello"]);
    is_deeply(
      $l1->elements->[1]->elements->[1]->elements,
      [Rstats::Util::TRUE, Rstats::Util::FALSE, Rstats::Util::FALSE]
    );
  }

  # list - argument is not array
  {
    my $l1 = list(1, 2, 3);
    is_deeply($l1->elements->[0]->values, [1]);
    is_deeply($l1->elements->[1]->values, [2]);
    is_deeply($l1->elements->[2]->values, [3]);
  }
    
  # list - to_string
  {
    my $l1 = list(c(1, 2, 3), list("Hello", c(T, F, F)));
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
    my $l1 = list("a", "b");
    is_deeply(r->length($l1)->values, [2]);
  }

  # list - as_list, input is list
  {
    my $l1 = list("a", "b");
    my $l2 = r->as_list($l1);
    is($l1, $l2);
  }
  
  # list - as_list, input is array
  {
    my $a1 = c("a", "b");
    my $l1 = r->as_list($a1);
    ok(r->is_list($l1));
    is_deeply($a1->values, ["a", "b"]);
  }

  # list - get
  {
    my $l1 = list("a", "b", list("c", "d", list("e")));
    my $a1 = $l1->get(1);
    is_deeply($a1->values, ["a"]);
    
    my $a2 = $l1->get(3, 2);
    is_deeply($a2->values, ["d"]);

    my $a3 = $l1->get(3, 3, 1);
    is_deeply($a3->values, ["e"]);
  }

  # list - get_list
  {
    my $l1 = list(1, 2, 3);
    my $l2 = $l1->get_list(1);
    ok(r->is_list($l2));
    is_deeply($l2->get(1)->values, [1]);
  }

  # list - get_list, multiple
  {
    my $l1 = list(1, 2, 3);
    my $l2 = $l1->get_list(c(1, 3));
    ok(r->is_list($l2));
    is_deeply($l2->get(1)->values, [1]);
    is_deeply($l2->get(2)->values, [3]);
  }

  # list - get_list, multiple
  {
    my $l1 = list(1, 2, 3);
    my $l2 = $l1->get_list(c(1, 3));
    ok(r->is_list($l2));
    is_deeply($l2->get(1)->values, [1]);
    is_deeply($l2->get(2)->values, [3]);
  }
  
  # list - set
  {
    my $l1 = list(1, 2, 3);
    $l1->at(2);
    $l1->set(5);
    is_deeply($l1->get(1)->values, [1]);
    is_deeply($l1->get(2)->values, [5]);
    is_deeply($l1->get(3)->values, [3]);
  }

  # list - set, two index
  {
    my $l1 = list(1, list(2, 3));
    $l1->at(2, 2);
    $l1->set(5);
    is_deeply($l1->get(1)->values, [1]);
    is_deeply($l1->get(2, 1)->values, [2]);
    is_deeply($l1->get(2, 2)->values, [5]);
  }

  # list - set, tree index
  {
    my $l1 = list(1, list(2, 3, list(4)));
    $l1->at(2, 3, 1);
    $l1->set(5);
    is_deeply($l1->get(2, 3, 1)->values, [5]);
  }
}