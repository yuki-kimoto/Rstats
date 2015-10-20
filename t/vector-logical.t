use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# logical
{
  # logical - bool, TRUE
  {
    my $x_true = r->c_logical(1);
    ok($x_true);
  }
  
  # logical - bool, FALSE
  {
    my $x_false = r->c_logical(0);
    ok(!$x_false->value);
  }
  
  # to_string, true
  {
    my $x_true = r->c_logical(1);
    is("$x_true", "[1] TRUE\n");
  }
  
  # to_string, false
  {
    my $x_false = r->c_logical(0);
    is("$x_false", "[1] FALSE\n");
  }
}

