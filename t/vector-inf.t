use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::Func::Vector;

# Inf
{
  # Inf - negation repeat
  {
    my $inf = Rstats::Func::Vector::new_double('Inf');
    my $negative_inf = Rstats::Func::Vector::negation($inf);
    my $inf2 = Rstats::Func::Vector::negation($negative_inf);
    ok($inf2->value, 'Inf');
  }
  
  # Inf - to_string, plus
  {
    my $inf = Rstats::Func::Vector::new_double('Inf');
    is("$inf", 'Inf');
  }

  # Inf - negation
  {
    my $inf = Rstats::Func::Vector::new_double('Inf');
    my $negative_inf = Rstats::Func::Vector::negation($inf);
    is($negative_inf->value, '-Inf');
  }

  # Inf - to_string, minus
  {
    my $negative_inf = Rstats::Func::Vector::new_double('-Inf');
    is("$negative_inf", '-Inf');
  }
}

# is_infinite
{
  # is_infinite - Inf, true
  {
    my $inf = Rstats::Func::Vector::new_double('Inf');
    ok($inf->is_infinite->value);
  }
  
  # is_infinite - -Inf, true
  {
    my $negative_inf = Rstats::Func::Vector::new_double('-Inf');
    ok($negative_inf->is_infinite->value);
  }
  
  # is_infinite - Double, false
  {
    my $num = Rstats::Func::Vector::new_double(1);
    ok(!$num->is_infinite->value);
  }
}

# is_finite
{
  # is_finite - Inf, false
  {
    my $inf = Rstats::Func::Vector::new_double('Inf');
    ok(!$inf->is_finite->value);
  }
  
  # is_finite - -Inf, false
  {
    my $negative_inf = Rstats::Func::Vector::new_double('-Inf');
    ok(!$negative_inf->is_finite->value);
  }
  
  # is_finite - Double, true
  {
    my $num = Rstats::Func::Vector::new_double(1);
    ok($num->is_finite->value);
  }
  
  # is_finite - Integer, true
  {
    my $num = Rstats::Func::Vector::new_integer(1);
    ok($num->is_finite->value);
  }
}

