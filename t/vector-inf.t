use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# Inf
{
  # Inf - negation repeat
  {
    my $x_inf = r->new_double('Inf');
    my $x_negative_inf = r->negation($x_inf);
    my $x_inf2 = r->negation($x_negative_inf);
    ok($x_inf2->value, 'Inf');
  }
  
  # Inf - to_string, plus
  {
    my $x_inf = r->new_double('Inf');
    is("$x_inf", "[1] Inf\n");
  }

  # Inf - negation
  {
    my $x_inf = r->new_double('Inf');
    my $x_negative_inf = r->negation($x_inf);
    is($x_negative_inf->value, '-Inf');
  }

  # Inf - to_string, minus
  {
    my $x_negative_inf = r->new_double('-Inf');
    is("$x_negative_inf", "[1] -Inf\n");
  }
}

# is_infinite
{
  # is_infinite - Inf, true
  {
    my $x_inf = r->new_double('Inf');
    ok(r->is_infinite($x_inf)->value);
  }
  
  # is_infinite - -Inf, true
  {
    my $x_negative_inf = r->new_double('-Inf');
    ok(r->is_infinite($x_negative_inf)->value);
  }
  
  # is_infinite - Double, false
  {
    my $x_num = r->new_double(1);
    ok(!r->is_infinite($x_num)->value);
  }
}

# is_finite
{
  # is_finite - Inf, false
  {
    my $x_inf = r->new_double('Inf');
    ok(!r->is_finite($x_inf)->value);
  }
  
  # is_finite - -Inf, false
  {
    my $x_negative_inf = r->new_double('-Inf');
    ok(!r->is_finite($x_negative_inf)->value);
  }
  
  # is_finite - Double, true
  {
    my $x_num = r->new_double(1);
    ok(r->is_finite($x_num)->value);
  }
  
  # is_finite - Integer, true
  {
    my $x_num = r->new_integer(1);
    ok(r->is_finite($x_num)->value);
  }
}

