use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# gl
{
  # gl - n, k, length
  {
    my $f1 = r->gl(2, 2, 10);
    ok($f1->is_factor);
    is_deeply($f1->values, [1, 1, 2, 2, 1, 1, 2, 2, 1, 1]);
  }
  
  # gl - n, k ,length, no fit length
  {
    my $f1 = r->gl(3, 3, 10);
    ok($f1->is_factor);
    is_deeply($f1->values, [1, 1, 1, 2, 2, 2, 3, 3, 3, 1]);
  }

  # gl - n, k
  {
    my $f1 = r->gl(3, 3);
    ok($f1->is_factor);
    is_deeply($f1->values, [1, 1, 1, 2, 2, 2, 3, 3, 3]);
    is_deeply($f1->levels->values, ["1", "2", "3"]);
  }
  
  # gl - labels
  {
    my $f1 = r->gl(3, 3, {labels => c("a", "b", "c")});
    ok($f1->is_factor);
    is_deeply($f1->values, [1, 1, 1, 2, 2, 2, 3, 3, 3]);
    is_deeply($f1->levels->values, ["a", "b", "c"]);
  }

  # gl - ordered
  {
    my $f1 = r->gl(3, 3, {ordered => TRUE});
    ok($f1->is_factor);
    ok($f1->is_ordered);
    is_deeply($f1->values, [1, 1, 1, 2, 2, 2, 3, 3, 3]);
    is_deeply($f1->levels->values, ["1", "2", "3"]);
  }
}

# ordered
{
  # ordered - basic
  {
    my $f1 = ordered(c("a", "b", "c", "a", "b", "c"));
    ok($f1->is_ordered);
    ok($f1->is_integer);
    ok($f1->is_factor);
    is_deeply($f1->values, [1, 2, 3, 1, 2 ,3]);
    is_deeply($f1->levels->values, ["a", "b", "c"]);
  }
  # ordered - option
  {
    my $f1 = ordered(c("a", "b", "c", "a", "b", "c"), {levels => c("a", "b", "c")});
    ok($f1->is_ordered);
    ok($f1->is_integer);
    ok($f1->is_factor);
    is_deeply($f1->values, [1, 2, 3, 1, 2 ,3]);
    is_deeply($f1->levels->values, ["a", "b", "c"]);
  }
}

# factor
{
  # factor - as.numeric(levels(f))[f] 
  {
    my $f1 = factor(c(2, 3, 4, 2, 3, 4));
    my $f1_levels = $f1->levels;
    my $a1_levels = $f1_levels->as_numeric;
    my $a2 = $a1_levels->get($f1);
    ok($a2->is_numeric);
    is_deeply($a2->values, [2, 3, 4, 2, 3, 4]);
  }
  
  # factor - labels
  {
    my $f1 = factor(c("a", "b", "c", "a", "b", "c"));
    my $a1 = $f1->labels;
    ok($a1->is_character);
    is_deeply($a1->values, ["a", "b", "c", "a", "b", "c"]);
  }
  
  # factor - as_character
  {
    my $f1 = factor(c("a", "b", "c", "a", "b", "c"));
    my $a1 = $f1->as_character;
    ok($a1->is_character);
    is_deeply($a1->values, ["a", "b", "c", "a", "b", "c"]);
  }
  
  # factor - as_logical
  {
    my $f1 = factor(c("a", "b", "c"));
    my $a1 = $f1->as_logical;
    ok($a1->is_logical);
    is_deeply($a1->values, [1, 1, 1]);
  }
  
  # factor - as_complex
  {
    my $f1 = factor(c("a", "b", "c"));
    my $a1 = $f1->as_complex;
    ok($a1->is_complex);
    is_deeply($a1->values, [{re => 1, im =>  0}, {re => 2, im => 0}, {re => 3, im => 0}]);
  }
  
  # factor - as_double
  {
    my $f1 = factor(c("a", "b", "c"));
    my $a1 = $f1->as_double;
    ok($a1->is_double);
    is_deeply($a1->values, [1, 2, 3]);
  }
  
  # factor - as_integer
  {
    my $f1 = factor(c("a", "b", "c"));
    my $a1 = $f1->as_integer;
    ok($a1->is_integer);
    is_deeply($a1->values, [1, 2, 3]);
  }

  # factor - as_factor, double
  {
    my $a1 = c(2, 3, 4);
    my $f1 = factor($a1);
    ok($f1->is_factor);
    is_deeply($f1->values, [1, 2, 3]);
    is_deeply($f1->levels->values, ["2", "3", "4"]);
  }
  
  # factor - as_factor, character
  {
    my $a1 = c("a", "b", "c");
    my $f1 = factor($a1);
    ok($f1->is_factor);
    is_deeply($f1->values, [1, 2, 3]);
    is_deeply($f1->levels->values, ["a", "b", "c"]);
  }

  # factor - ordered
  {
    my $f1 = factor(c("a", "b", "c", "a", "b", "c"), {ordered => TRUE});
    ok($f1->is_ordered);
  }

  # factor - ordered, default, FALSE
  {
    my $f1 = factor(c("a", "b", "c", "a", "b", "c"));
    ok(!$f1->is_ordered);
  }

  # factor - exclude
  {
    my $f1 = factor(c("a", "b", "c", "a", "b", "c"), {exclude => "c"});
    is_deeply($f1->values, [1, 2, undef, 1, 2, undef]);
  }
  
  # factor - labels
  {
    my $f1 = factor(c("a", "b", "c", "a", "b", "c"), {levels => c("a", "b", "c"), labels => c(1, 2, 3)});
    my $expected = <<'EOS';
[1] 1 2 3 1 2 3
Levels: 1 2 3
EOS
    is("$f1", $expected);
  }

  # factor - labels, one element
  {
    my $f1 = factor(c("a", "b", "c", "a", "b", "c"), {levels => c("a", "b", "c"), labels => "a"});
    my $expected = <<'EOS';
[1] a1 a2 a3 a1 a2 a3
Levels: a1 a2 a3
EOS
    is("$f1", $expected);
  }
  
  # factor - to_string
  {
    my $f1 = factor(c("a", "b", "c", "a", "b", "c"), {levels => c("a", "b")});
    my $expected = <<'EOS';
[1] a b <NA> a b <NA>
Levels: a b
EOS
    is("$f1", $expected);
  }

  # factor - to_string, ordered
  {
    my $f1 = factor(c("a", "b", "c", "a", "b", "c"), {ordered => TRUE});
    my $expected = <<'EOS';
[1] a b c a b c
Levels: a < b < c
EOS
    is("$f1", $expected);
  }
  
  # factor - levels
  {
    my $f1 = factor(c("a", "b", "c", "a", "b", "c"), {levels => c("a", "b")});
    is_deeply($f1->values, [1, 2, undef, 1, 2 ,undef]);
    is_deeply($f1->levels->values, ["a", "b"]);
  }
  
  # factor - basic
  {
    my $f1 = factor(c("a", "b", "c", "a", "b", "c"));
    ok($f1->is_integer);
    ok($f1->is_factor);
    is_deeply($f1->values, [1, 2, 3, 1, 2 ,3]);
    is_deeply($f1->levels->values, ["a", "b", "c"]);
  }
}

