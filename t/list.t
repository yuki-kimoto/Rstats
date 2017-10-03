use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::Class;

my $r = Rstats::Class->new;

# typeof
{
  my $x1 = $r->list(1, 2);
  my $x2 = r->typeof($x1);
  ok(r->is->character($x2));
  is_deeply($x2->values, ['list']);
}

# $r->list
{
  # $r->list - get, multiple, names
  {
    my $x1 = $r->list(1, 2, 3);
    r->names($x1, c_("n1", "n2", "n3"));
    my $l2 = $x1->get(c_("n1", "n3"));
    ok(r->is->list($l2));
    is_deeply($l2->getin(1)->values, [1]);
    is_deeply($l2->getin(2)->values, [3]);
  }

  # $r->list - get
  {
    my $x1 = $r->list(1, 2, 3);
    my $l2 = $x1->get(1);
    ok(r->is->list($l2));
    is_deeply($l2->getin(1)->values, [1]);
  }
  
  # $r->list - as_list, input is array
  {
    my $x1 = c_("a", "b");
    my $x2 = r->as->list($x1);
    ok(r->is->list($x2));
    is_deeply($x2->getin(1)->values, ["a", "b"]);
  }

  # $r->list - basic
  {
    my $x1 = $r->list(c_(1, 2, 3), $r->list("Hello", c_(T_, F_, F_)));
    is_deeply($x1->list->[0]->values, [1, 2, 3]);
    is_deeply($x1->list->[1]->list->[0]->values, ["Hello"]);
    is_deeply(
      $x1->list->[1]->list->[1]->values,
      [1, 0, 0]
    );
  }

  # $r->list - argument is not array
  {
    my $x1 = $r->list(1, 2, 3);
    is_deeply($x1->list->[0]->values, [1]);
    is_deeply($x1->list->[1]->values, [2]);
    is_deeply($x1->list->[2]->values, [3]);
  }
    
  # $r->list - to_string
  {
    my $x1 = $r->list(c_(1, 2, 3), $r->list("Hello", c_(T_, F_, F_)));
    my $str = $x1->to_string;
    my $expected = <<"EOS";
[[1]]
[1] 1 2 3

[[2]]
[[2]][[1]]
[1] "Hello"

[[2]][[2]]
[1] TRUE FALSE FALSE

EOS
    is($str, $expected);
  }

  # $r->list - length
  {
    my $x1 = $r->list("a", "b");
    is_deeply(r->length($x1)->values, [2]);
  }

  # $r->list - as_list, input is $r->list
  {
    my $x1 = $r->list("a", "b");
    my $l2 = r->as->list($x1);
    is($x1, $l2);
  }

  # $r->list - getin
  {
    my $x1 = $r->list("a", "b", $r->list("c", "d", $r->list("e")));
    my $x2 = $x1->getin(1);
    is_deeply($x2->values, ["a"]);
    
    my $x3 = $x1->getin(3)->getin(2);
    is_deeply($x3->values, ["d"]);

    my $x4 = $x1->getin(3)->getin(3)->getin(1);
    is_deeply($x4->values, ["e"]);
  }

  # $r->list - getin,name
  {
    my $x1 = $r->list("a", "b", $r->list("c", "d", $r->list("e")));
    r->names($x1, c_("n1", "n2", "n3"));
    my $x2 = $x1->getin("n1");
    is_deeply($x2->values, ["a"]);

    my $x3 = $x1->getin("n3")->getin(3)->getin(1);
    is_deeply($x3->values, ["e"]);
  }
  
  # $r->list - get, multiple
  {
    my $x1 = $r->list(1, 2, 3);
    my $l2 = $x1->get(c_(1, 3));
    ok(r->is->list($l2));
    is_deeply($l2->getin(1)->values, [1]);
    is_deeply($l2->getin(2)->values, [3]);
  }
}

# ncol
{
  my $x1 = $r->list(1, 2, 3);
  my $x2 = r->ncol($x1);
  ok(r->is->null($x2));
}

# nrow
{
  my $x1 = $r->list(1, 2, 3);
  my $x2 = r->nrow($x1);
  ok(r->is->null($x2));
}

# set
{
  # set - NULL, dimnames
  {
    my $x1 = $r->list(c_(1, 2, 3), c_(4, 5, 6), c_(7, 8, 9));
    r->dimnames($x1, $r->list(c_("r1", "r2", "r3"), c_("c1", "c2", "c3")));
    $x1->at(2)->set(NULL);
    is_deeply($x1->getin(1)->values, [1, 2, 3]);
    is_deeply($x1->getin(2)->values, [7, 8, 9]);
    is_deeply(r->dimnames($x1)->getin(1)->values, ["r1", "r2", "r3"]);
    is_deeply(r->dimnames($x1)->getin(2)->values, ["c1", "c3"]);
  }
  
  # set - NULL, names
  {
    my $x1 = $r->list(c_(1, 2, 3), c_(4, 5, 6), c_(7, 8, 9));
    r->names($x1, c_("c1", "c2", "c3"));
    $x1->at(2)->set(NULL);
    is_deeply($x1->getin(1)->values, [1, 2, 3]);
    is_deeply($x1->getin(2)->values, [7, 8, 9]);
    is_deeply(r->names($x1)->values, ["c1", "c3"]);
  }
  
  # set - basic
  {
    my $x1 = $r->list(1, 2, 3);
    $x1->at(2)->set(5);
    is_deeply($x1->getin(1)->values, [1]);
    is_deeply($x1->getin(2)->values, [5]);
    is_deeply($x1->getin(3)->values, [3]);
  }

  # set - name
  {
    my $x1 = $r->list(1, 2, 3);
    r->names($x1, c_("n1", "n2", "n3"));
    $x1->at("n2")->set(5);
    is_deeply($x1->getin(1)->values, [1]);
    is_deeply($x1->getin(2)->values, [5]);
    is_deeply($x1->getin(3)->values, [3]);
  }
  
  # set - two index
  {
    my $x1 = $r->list(1, $r->list(2, 3));
    $x1->getin(2)->at(2)->set(5);
    is_deeply($x1->getin(1)->values, [1]);
    is_deeply($x1->getin(2)->getin(1)->values, [2]);
    is_deeply($x1->getin(2)->getin(2)->values, [5]);
  }

  # set - tree index
  {
    my $x1 = $r->list(1, $r->list(2, 3, $r->list(4)));
    $x1->getin(2)->getin(3)->at(1)->set(5);
    is_deeply($x1->getin(2)->getin(3)->getin(1)->values, [5]);
  }
}

