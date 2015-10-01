use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# logical
{
  # logical - bool, TRUE
  {
    my $x_true = r->new_logical(1);
    ok($x_true);
  }
  
  # logical - bool, FALSE
  {
    my $x_false = r->new_logical(0);
    ok(!$x_false->value);
  }
  
  # negation, true
  {
    my $x_true = r->new_logical(1);
    my $x_num = r->negation($x_true);
    ok(r->is->integer($x_num));
    is($x_num->value, -1);
  }

  # negation, false
  {
    my $x_false = r->new_logical(0);
    my $x_num = r->negation($x_false);
    ok(r->is->integer($x_num));
    is($x_num->value, 0);
  }
  
  # to_string, true
  {
    my $x_true = r->new_logical(1);
    is("$x_true", "[1] TRUE\n");
  }
  
  # to_string, false
  {
    my $x_false = r->new_logical(0);
    is("$x_false", "[1] FALSE\n");
  }
}

