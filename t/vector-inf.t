use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::ArrayFunc;

# Inf
{
  # Inf - negation repeat
  {
    my $inf = Rstats::ArrayFunc::new_double('Inf');
    my $negative_inf = Rstats::ArrayFunc::negation($inf);
    my $inf2 = Rstats::ArrayFunc::negation($negative_inf);
    ok($inf2->value, 'Inf');
  }
  
  # Inf - to_string, plus
  {
    my $inf = Rstats::ArrayFunc::new_double('Inf');
    is("$inf", 'Inf');
  }

  # Inf - negation
  {
    my $inf = Rstats::ArrayFunc::new_double('Inf');
    my $negative_inf = Rstats::ArrayFunc::negation($inf);
    is($negative_inf->value, '-Inf');
  }

  # Inf - to_string, minus
  {
    my $negative_inf = Rstats::ArrayFunc::new_double('-Inf');
    is("$negative_inf", '-Inf');
  }
}

# is_infinite
{
  # is_infinite - Inf, true
  {
    my $inf = Rstats::ArrayFunc::new_double('Inf');
    ok($inf->is_infinite->value);
  }
  
  # is_infinite - -Inf, true
  {
    my $negative_inf = Rstats::ArrayFunc::new_double('-Inf');
    ok($negative_inf->is_infinite->value);
  }
  
  # is_infinite - Double, false
  {
    my $num = Rstats::ArrayFunc::new_double(1);
    ok(!$num->is_infinite->value);
  }
}

# is_finite
{
  # is_finite - Inf, false
  {
    my $inf = Rstats::ArrayFunc::new_double('Inf');
    ok(!$inf->is_finite->value);
  }
  
  # is_finite - -Inf, false
  {
    my $negative_inf = Rstats::ArrayFunc::new_double('-Inf');
    ok(!$negative_inf->is_finite->value);
  }
  
  # is_finite - Double, true
  {
    my $num = Rstats::ArrayFunc::new_double(1);
    ok($num->is_finite->value);
  }
  
  # is_finite - Integer, true
  {
    my $num = Rstats::ArrayFunc::new_integer(1);
    ok($num->is_finite->value);
  }
}

