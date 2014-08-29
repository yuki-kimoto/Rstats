use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# factor
{

  # factor - exclude
  {
    my $f1 = factor(c("a", "b", "c", "a", "b", "c"), {exclude => "c"});
    is_deeply($f1->values, [0, 1, undef, 0, 1, undef]);
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
  
  # factor - levels
  {
    my $f1 = factor(c("a", "b", "c", "a", "b", "c"), {levels => c("a", "b")});
    is_deeply($f1->values, [0, 1, undef, 0, 1 ,undef]);
    is_deeply($f1->levels->values, ["a", "b"]);
  }
  
  # factor - basic
  {
    my $f1 = factor(c("a", "b", "c", "a", "b", "c"));
    ok($f1->is_integer);
    is_deeply($f1->values, [0, 1, 2, 0, 1 ,2]);
    is_deeply($f1->levels->values, ["a", "b", "c"]);
  }
}

