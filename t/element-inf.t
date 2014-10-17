use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::ElementFunc;

# Inf
{
  # Inf - negation
  {
    my $inf = Rstats::ElementFunc::Inf;
    my $negative_inf = Rstats::ElementFunc::negation($inf);
    ok($negative_inf->is_negative_infinite);
  }

  # Inf - negation repeat
  {
    my $inf = Rstats::ElementFunc::Inf;
    my $negative_inf = Rstats::ElementFunc::negation($inf);
    my $inf2 = Rstats::ElementFunc::negation($negative_inf);
    ok($inf2->is_positive_infinite);
  }
  
  # Inf - to_string, plus
  {
    my $inf = Rstats::ElementFunc::Inf;
    is("$inf", 'Inf');
  }

  # Inf - to_string, minus
  {
    my $negative_inf = Rstats::ElementFunc::negativeInf;
    is("$negative_inf", '-Inf');
  }
}

# is_infinite
{
  # is_infinite - Inf, true
  {
    my $inf = Rstats::ElementFunc::Inf;
    ok($inf->is_infinite);
  }
  
  # is_infinite - -Inf, true
  {
    my $negative_inf = Rstats::ElementFunc::negativeInf;
    ok($negative_inf->is_infinite);
  }
  
  # is_infinite - Double, false
  {
    my $num = Rstats::ElementFunc::new_double(1);
    ok(!$num->is_infinite);
  }
}

# is_finite
{
  # is_finite - Inf, false
  {
    my $inf = Rstats::ElementFunc::Inf;
    ok(!$inf->is_finite);
  }
  
  # is_finite - -Inf, false
  {
    my $negative_inf = Rstats::ElementFunc::negativeInf;
    ok(!$negative_inf->is_finite);
  }
  
  # is_finite - Double, true
  {
    my $num = Rstats::ElementFunc::new_double(1);
    ok($num->is_finite);
  }
  
  # is_finite - Integer, true
  {
    my $num = Rstats::ElementFunc::new_integer(1);
    ok($num->is_finite);
  }
}

