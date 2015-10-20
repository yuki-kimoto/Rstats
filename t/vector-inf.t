use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# is_infinite
{
  # is_infinite - Double, false
  {
    my $x_num = r->c_double(1);
    ok(!r->is->infinite($x_num)->value);
  }

  # is_infinite - Inf, true
  {
    my $x_inf = r->c_double('Inf');
    ok(r->is->infinite($x_inf)->value);
  }
  
  # is_infinite - -Inf, true
  {
    my $x_negative_inf = r->c_double('-Inf');
    ok(r->is->infinite($x_negative_inf)->value);
  }
}

# is_finite
{
  # is_finite - Inf, false
  {
    my $x_inf = r->c_double('Inf');
    ok(!r->is->finite($x_inf)->value);
  }
  
  # is_finite - -Inf, false
  {
    my $x_negative_inf = r->c_double('-Inf');
    ok(!r->is->finite($x_negative_inf)->value);
  }
  
  # is_finite - Double, true
  {
    my $x_num = r->c_double(1);
    ok(r->is->finite($x_num)->value);
  }
  
  # is_finite - Integer, true
  {
    my $x_num = r->c_integer(1);
    ok(r->is->finite($x_num)->value);
  }
}

