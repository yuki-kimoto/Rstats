use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::ElementsFunc;
use Rstats;


# element
{
  # element - new_NA
  {
    my $e1 = Rstats::ElementsFunc::new_NA();
    ok($e1->is_na);
    ok(!defined $e1->value);
  }

  # element - is_finite
  {
    # element - is_finite - double
    {
      my $e1 = Rstats::ElementsFunc::new_double(1.2);
      ok($e1->is_finite);
    }
    
    # element - is_finite - integer
    {
      my $e1 = Rstats::ElementsFunc::new_integer(3);
      ok($e1->is_finite);
    }

    # element - is_finite - NaN
    {
      my $e1 = Rstats::ElementsFunc::new_NaN();
      is($e1->type, 'double');
      ok(!$e1->is_finite);
    }

    # element - is_finite - Inf
    {
      my $e1 = Rstats::ElementsFunc::new_Inf();
      ok(!$e1->is_finite);
    }

    # element - is_finite - -Inf
    {
      my $e1 = Rstats::ElementsFunc::new_negativeInf();
      ok(!$e1->is_finite);
    }
  }
  
  # element - character_xs
  {
    my $e1 = Rstats::ElementsFunc::new_character("foo");
    is($e1->type, 'character');
    is($e1->cv, "foo");
  }

  # element - Inf_xs
  {
    my $e1 = Rstats::ElementsFunc::new_Inf();
    is($e1->type, 'double');
    ok($e1->is_infinite);
    ok($e1->dv > 0);
  }
  
  # element - negativeInf_xs
  {
    my $e1 = Rstats::ElementsFunc::new_negativeInf();
    is($e1->type, 'double');
    ok($e1->is_infinite);
    ok($e1->dv < 0);
  }

  # element - NaN_xs
  {
    my $e1 = Rstats::ElementsFunc::new_NaN();
    is($e1->type, 'double');
    ok($e1->is_nan);
  }
  
  # element - double_xs
  {
    my $e1 = Rstats::ElementsFunc::new_double(2.5);
    is($e1->type, 'double');
    is($e1->dv, 2.5);
  }

  # element - integer_xs
  {
    my $e1 = Rstats::ElementsFunc::new_integer(2);
    is($e1->type, 'integer');
    is($e1->iv, 2);
  }

  # element - logical_xs
  {
    my $e1 = Rstats::ElementsFunc::new_logical(1);
    is($e1->type, 'logical');
    is($e1->iv, 1);
  }
  
  # element - complex_xs
  {
    my $e1 = Rstats::ElementsFunc::new_complex(1.5, 2.5);
    is($e1->type, 'complex');
    is($e1->re, 1.5);
    is($e1->im, 2.5);
  }
}
