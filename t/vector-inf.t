use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::VectorFunc;

# Inf
{
  # Inf - negation
  {
    my $inf = Rstats::VectorFunc::Inf;
    my $negative_inf = Rstats::VectorFunc::negation($inf);
    ok($negative_inf->is_negative_infinite->value);
  }

  # Inf - negation repeat
  {
    my $inf = Rstats::VectorFunc::Inf;
    my $negative_inf = Rstats::VectorFunc::negation($inf);
    my $inf2 = Rstats::VectorFunc::negation($negative_inf);
    ok($inf2->is_positive_infinite->value);
  }
  
  # Inf - to_string, plus
  {
    my $inf = Rstats::VectorFunc::Inf;
    is("$inf", 'Inf');
  }

  # Inf - to_string, minus
  {
    my $negative_inf = Rstats::VectorFunc::negativeInf;
    is("$negative_inf", '-Inf');
  }
}

# is_infinite
{
  # is_infinite - Inf, true
  {
    my $inf = Rstats::VectorFunc::Inf;
    ok($inf->is_infinite->value);
  }
  
  # is_infinite - -Inf, true
  {
    my $negative_inf = Rstats::VectorFunc::negativeInf;
    ok($negative_inf->is_infinite->value);
  }
  
  # is_infinite - Double, false
  {
    my $num = Rstats::VectorFunc::new_double(1);
    ok(!$num->is_infinite->value);
  }
}

# is_finite
{
  # is_finite - Inf, false
  {
    my $inf = Rstats::VectorFunc::Inf;
    ok(!$inf->is_finite->value);
  }
  
  # is_finite - -Inf, false
  {
    my $negative_inf = Rstats::VectorFunc::negativeInf;
    ok(!$negative_inf->is_finite->value);
  }
  
  # is_finite - Double, true
  {
    my $num = Rstats::VectorFunc::new_double(1);
    ok($num->is_finite->value);
  }
  
  # is_finite - Integer, true
  {
    my $num = Rstats::VectorFunc::new_integer(1);
    ok($num->is_finite->value);
  }
}

