use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# set
{
  # set - basic
  {
    my $x1 = factor(c("a1", "a2", "a3", "a1", "a2", "a3"));
    $x1->at(c(3, 6))->set(c("a2", "a1"));
    is_deeply($x1->values, [1, 2, 2, 1, 2, 1]);
    is_deeply($x1->levels->values, ["a1", "a2", "a3"]);
  }
}

# get
{
  # get - drop
  {
    my $x1 = factor(c("a1", "a2", "a3", "a1", "a2", "a3"));
    my $x2 = $x1->get(c(4, 6), {drop => TRUE});
    ok($x2->is_factor);
    is_deeply($x2->values, [1, 2]);
    is_deeply($x2->levels->values, ["a1", "a3"]);
  }
  
  # get - factor
  {
    my $x1 = factor(c("a1", "a2", "a3", "a1", "a2", "a3"));
    my $x2 = $x1->get(c(4, 6));
    ok($x2->is_factor);
    is_deeply($x2->values, [1, 3]);
    is_deeply($x2->levels->values, ["a1", "a2", "a3"]);
  }
  
  # get - ordered
  {
    my $x1 = ordered(c("a1", "a2", "a3", "a1", "a2", "a3"));
    my $x2 = $x1->get(c(4, 6));
    ok($x2->is_factor);
    ok($x2->is_ordered);
    is_deeply($x2->values, [1, 3]);
    is_deeply($x2->levels->values, ["a1", "a2", "a3"]);
  }
}

# nlevels
{
  # nlevels - set values
  {
    my $x1 = factor(c("a1", "a2", "a1", "a2"));
    is_deeply($x1->nlevels->values, [2]);
  }
  
  # nlevels - function
  {
    my $x1 = factor(c("a1", "a2", "a1", "a2"));
    is_deeply(r->nlevels($x1)->values, [2]);
  }
}

# levels
{
  # levels - set values
  {
    my $x1 = factor(c("a1", "a2", "a1", "a2"));
    $x1->levels(c("A1", "A2"));
    is_deeply($x1->levels->values, ["A1", "A2"]);
  }
  
  # levels - function
  {
    my $x1 = factor(c("a1", "a2", "a1", "a2"));
    r->levels($x1, (c("A1", "A2")));
    is_deeply($x1->levels->values, ["A1", "A2"]);
  }
}

# interaction
{
  # interaction - drop
  {
    my $x1 = factor(c("a1", "a2", "a1", "a2"));
    my $x2 = factor(c("b1", "b2"));
    my $x3 = r->interaction($x1, $x2, {drop => TRUE});
    ok($x3->is_factor);
    is_deeply($x3->values, [1, 2, 1, 2]);
    is_deeply($x3->levels->values, ["a1.b1", "a2.b2"]);
  }
  
  # interaction - sep
  {
    my $x1 = factor(c("a1", "a2", "a1", "a2"));
    my $x2 = factor(c("b1", "b2"));
    my $x3 = r->interaction($x1, $x2, {sep => ":"});
    ok($x3->is_factor);
    is_deeply($x3->values, [1, 4, 1, 4]);
    is_deeply($x3->levels->values, ["a1:b1", "a1:b2", "a2:b1", "a2:b2"]);
  }
  
  # interaction - tree elements
  {
    my $x1 = factor(c("a1", "a2", "a3"));
    my $x2 = factor(c("b1", "b2"));
    my $x3 = factor(c("c1"));
    my $x4 = r->interaction($x1, $x2, $x3);
    ok($x4->is_factor);
    is_deeply($x4->values, [1, 4, 5]);
    is_deeply($x4->levels->values, [
      "a1.b1.c1",
      "a1.b2.c1",
      "a2.b1.c1",
      "a2.b2.c1",
      "a3.b1.c1",
      "a3.b2.c1"
    ]);
  }

  # interaction - basic 2
  {
    my $x1 = factor(c("a1", "a2", "a3"));
    my $x2 = factor(c("b1", "b2"));
    my $x3 = r->interaction($x1, $x2);
    ok($x3->is_factor);
    is_deeply($x3->values, [1, 4, 5]);
    is_deeply($x3->levels->values, ["a1.b1", "a1.b2", "a2.b1", "a2.b2", "a3.b1", "a3.b2"]);
  }
  
  # interaction - basic
  {
    my $x1 = factor(c("a1", "a2", "a1", "a2"));
    my $x2 = factor(c("b1", "b2"));
    my $x3 = r->interaction($x1, $x2);
    ok($x3->is_factor);
    is_deeply($x3->values, [1, 4, 1, 4]);
    is_deeply($x3->levels->values, ["a1.b1", "a1.b2", "a2.b1", "a2.b2"]);
  }
}

# gl
{
  # gl - n, k, length
  {
    my $x1 = r->gl(2, 2, 10);
    ok($x1->is_factor);
    is_deeply($x1->values, [1, 1, 2, 2, 1, 1, 2, 2, 1, 1]);
  }
  
  # gl - n, k ,length, no fit length
  {
    my $x1 = r->gl(3, 3, 10);
    ok($x1->is_factor);
    is_deeply($x1->values, [1, 1, 1, 2, 2, 2, 3, 3, 3, 1]);
  }

  # gl - n, k
  {
    my $x1 = r->gl(3, 3);
    ok($x1->is_factor);
    is_deeply($x1->values, [1, 1, 1, 2, 2, 2, 3, 3, 3]);
    is_deeply($x1->levels->values, ["1", "2", "3"]);
  }
  
  # gl - labels
  {
    my $x1 = r->gl(3, 3, {labels => c("a", "b", "c")});
    ok($x1->is_factor);
    is_deeply($x1->values, [1, 1, 1, 2, 2, 2, 3, 3, 3]);
    is_deeply($x1->levels->values, ["a", "b", "c"]);
  }

  # gl - ordered
  {
    my $x1 = r->gl(3, 3, {ordered => TRUE});
    ok($x1->is_factor);
    ok($x1->is_ordered);
    is_deeply($x1->values, [1, 1, 1, 2, 2, 2, 3, 3, 3]);
    is_deeply($x1->levels->values, ["1", "2", "3"]);
  }
}

# ordered
{
  # ordered - basic
  {
    my $x1 = ordered(c("a", "b", "c", "a", "b", "c"));
    ok($x1->is_ordered);
    ok($x1->is_integer);
    ok($x1->is_factor);
    is_deeply($x1->values, [1, 2, 3, 1, 2 ,3]);
    is_deeply($x1->levels->values, ["a", "b", "c"]);
  }
  # ordered - option
  {
    my $x1 = ordered(c("a", "b", "c", "a", "b", "c"), {levels => c("a", "b", "c")});
    ok($x1->is_ordered);
    ok($x1->is_integer);
    ok($x1->is_factor);
    is_deeply($x1->values, [1, 2, 3, 1, 2 ,3]);
    is_deeply($x1->levels->values, ["a", "b", "c"]);
  }
}

# factor
{
  # factor - one element
  {
    my $x1 = factor(c("a"));
    is_deeply($x1->values, [1]);
    is_deeply($x1->levels->values, ["a"]);
  }
  
  # factor - as.numeric(levels(f))[f] 
  {
    my $x1 = factor(c(2, 3, 4, 2, 3, 4));
    my $x1_levels = $x1->levels;
    my $x2_levels = $x1_levels->as_numeric;
    my $x3 = $x2_levels->get($x1);
    ok($x3->is_numeric);
    is_deeply($x3->values, [2, 3, 4, 2, 3, 4]);
  }
  
  # factor - labels
  {
    my $x1 = factor(c("a", "b", "c", "a", "b", "c"));
    my $x2 = $x1->labels;
    ok($x2->is_character);
    is_deeply($x2->values, ["a", "b", "c", "a", "b", "c"]);
  }
  
  # factor - as_character
  {
    my $x1 = factor(c("a", "b", "c", "a", "b", "c"));
    my $x2 = $x1->as_character;
    ok($x2->is_character);
    is_deeply($x2->values, ["a", "b", "c", "a", "b", "c"]);
  }
  
  # factor - as_logical
  {
    my $x1 = factor(c("a", "b", "c"));
    my $x2 = $x1->as_logical;
    ok($x2->is_logical);
    is_deeply($x2->values, [1, 1, 1]);
  }
  
  # factor - as_complex
  {
    my $x1 = factor(c("a", "b", "c"));
    my $x2 = $x1->as_complex;
    ok($x2->is_complex);
    is_deeply($x2->values, [{re => 1, im =>  0}, {re => 2, im => 0}, {re => 3, im => 0}]);
  }
  
  # factor - as_double
  {
    my $x1 = factor(c("a", "b", "c"));
    my $x2 = $x1->as_double;
    ok($x2->is_double);
    is_deeply($x2->values, [1, 2, 3]);
  }
  
  # factor - as_integer
  {
    my $x1 = factor(c("a", "b", "c"));
    my $x2 = $x1->as_integer;
    ok($x2->is_integer);
    is_deeply($x2->values, [1, 2, 3]);
  }

  # factor - as_factor, double
  {
    my $x1 = c(2, 3, 4);
    my $x2 = factor($x1);
    ok($x2->is_factor);
    is_deeply($x2->values, [1, 2, 3]);
    is_deeply($x2->levels->values, ["2", "3", "4"]);
  }
  
  # factor - as_factor, character
  {
    my $x1 = c("a", "b", "c");
    my $x2 = factor($x1);
    ok($x2->is_factor);
    is_deeply($x2->values, [1, 2, 3]);
    is_deeply($x2->levels->values, ["a", "b", "c"]);
  }

  # factor - ordered
  {
    my $x1 = factor(c("a", "b", "c", "a", "b", "c"), {ordered => TRUE});
    ok($x1->is_ordered);
  }

  # factor - ordered, default, FALSE
  {
    my $x1 = factor(c("a", "b", "c", "a", "b", "c"));
    ok(!$x1->is_ordered);
  }

  # factor - exclude
  {
    my $x1 = factor(c("a", "b", "c", "a", "b", "c"), {exclude => "c"});
    is_deeply($x1->values, [1, 2, undef, 1, 2, undef]);
  }
  
  # factor - labels
  {
    my $x1 = factor(c("a", "b", "c", "a", "b", "c"), {levels => c("a", "b", "c"), labels => c(1, 2, 3)});
    my $expected = <<'EOS';
[1] 1 2 3 1 2 3
Levels: 1 2 3
EOS
    is("$x1", $expected);
  }

  # factor - labels, one element
  {
    my $x1 = factor(c("a", "b", "c", "a", "b", "c"), {levels => c("a", "b", "c"), labels => "a"});
    my $expected = <<'EOS';
[1] a1 a2 a3 a1 a2 a3
Levels: a1 a2 a3
EOS
    is("$x1", $expected);
  }
  
  # factor - to_string
  {
    my $x1 = factor(c("a", "b", "c", "a", "b", "c"), {levels => c("a", "b")});
    my $expected = <<'EOS';
[1] a b <NA> a b <NA>
Levels: a b
EOS
    is("$x1", $expected);
  }

  # factor - to_string, ordered
  {
    my $x1 = factor(c("a", "b", "c", "a", "b", "c"), {ordered => TRUE});
    my $expected = <<'EOS';
[1] a b c a b c
Levels: a < b < c
EOS
    is("$x1", $expected);
  }
  
  # factor - levels
  {
    my $x1 = factor(c("a", "b", "c", "a", "b", "c"), {levels => c("a", "b")});
    is_deeply($x1->values, [1, 2, undef, 1, 2 ,undef]);
    is_deeply($x1->levels->values, ["a", "b"]);
  }
  
  # factor - basic
  {
    my $x1 = factor(c("a", "b", "c", "a", "b", "c"));
    ok($x1->is_integer);
    ok($x1->is_factor);
    is_deeply($x1->values, [1, 2, 3, 1, 2 ,3]);
    is_deeply($x1->levels->values, ["a", "b", "c"]);
  }
}
