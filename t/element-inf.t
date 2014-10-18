use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::ElementsFunc;

# Inf
{
  # Inf - negation
  {
    my $inf = Rstats::ElementsFunc::Inf;
    my $negative_inf = Rstats::ElementsFunc::negation($inf);
    ok($negative_inf->is_negative_infinite);
  }

  # Inf - negation repeat
  {
    my $inf = Rstats::ElementsFunc::Inf;
    my $negative_inf = Rstats::ElementsFunc::negation($inf);
    my $inf2 = Rstats::ElementsFunc::negation($negative_inf);
    ok($inf2->is_positive_infinite);
  }
  
  # Inf - to_string, plus
  {
    my $inf = Rstats::ElementsFunc::Inf;
    is("$inf", 'Inf');
  }

  # Inf - to_string, minus
  {
    my $negative_inf = Rstats::ElementsFunc::negativeInf;
    is("$negative_inf", '-Inf');
  }
}

# is_infinite
{
  # is_infinite - Inf, true
  {
    my $inf = Rstats::ElementsFunc::Inf;
    ok($inf->is_infinite);
  }
  
  # is_infinite - -Inf, true
  {
    my $negative_inf = Rstats::ElementsFunc::negativeInf;
    ok($negative_inf->is_infinite);
  }
  
  # is_infinite - Double, false
  {
    my $num = Rstats::ElementsFunc::new_double(1);
    ok(!$num->is_infinite);
  }
}

# is_finite
{
  # is_finite - Inf, false
  {
    my $inf = Rstats::ElementsFunc::Inf;
    ok(!$inf->is_finite);
  }
  
  # is_finite - -Inf, false
  {
    my $negative_inf = Rstats::ElementsFunc::negativeInf;
    ok(!$negative_inf->is_finite);
  }
  
  # is_finite - Double, true
  {
    my $num = Rstats::ElementsFunc::new_double(1);
    ok($num->is_finite);
  }
  
  # is_finite - Integer, true
  {
    my $num = Rstats::ElementsFunc::new_integer(1);
    ok($num->is_finite);
  }
}

