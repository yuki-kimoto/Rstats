use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::ElementFunc;

# element
{
  # element - is_finite
  {
    # element - is_finite - double
    {
      my $e1 = Rstats::ElementFunc::double_xs(1.2);
      ok($e1->is_finite);
    }
    
    # element - is_finite - integer
    {
      my $e1 = Rstats::ElementFunc::integer_xs(3);
      ok($e1->is_finite);
    }

    # element - is_finite - NaN
    {
      my $e1 = Rstats::ElementFunc::NaN_xs();
      is($e1->type, 'double');
      ok(!$e1->is_finite);
    }

    # element - is_finite - Inf
    {
      my $e1 = Rstats::ElementFunc::Inf_xs();
      ok(!$e1->is_finite);
    }

    # element - is_finite - -Inf
    {
      my $e1 = Rstats::ElementFunc::negativeInf_xs();
      ok(!$e1->is_finite);
    }
  }
  
  # element - Inf_xs
  {
    my $e1 = Rstats::ElementFunc::Inf_xs();
    is($e1->type, 'double');
    ok($e1->is_infinite);
    ok($e1->dv > 0);
  }
  
  # element - negativeInf_xs
  {
    my $e1 = Rstats::ElementFunc::negativeInf_xs();
    is($e1->type, 'double');
    ok($e1->is_infinite);
    ok($e1->dv < 0);
  }
  
  # element - NaN_xs
  {
    my $e1 = Rstats::ElementFunc::NaN_xs();
    is($e1->type, 'double');
    ok($e1->is_nan);
  }

  # element - NaN_xs
  {
    my $e1 = Rstats::ElementFunc::NaN_xs();
    is($e1->type, 'double');
    ok($e1->is_nan);
  }
  
  # element - NaN_xs
  {
    my $e1 = Rstats::ElementFunc::NaN_xs();
    is($e1->type, 'double');
    ok($e1->is_nan);
  }
  
  # element - double_xs
  {
    my $e1 = Rstats::ElementFunc::double_xs(2.5);
    is($e1->type, 'double');
    is($e1->dv, 2.5);
  }

  # element - integer_xs
  {
    my $e1 = Rstats::ElementFunc::integer_xs(2);
    is($e1->type, 'integer');
    is($e1->iv, 2);
  }

  # element - logical_xs
  {
    my $e1 = Rstats::ElementFunc::logical_xs(1);
    is($e1->type, 'logical');
    is($e1->iv, 1);
  }
  
  # element - complex_xs
  {
    my $e1 = Rstats::ElementFunc::complex_xs(1.5, 2.5);
    is($e1->type, 'complex');
    is($e1->re, 1.5);
    is($e1->im, 2.5);
  }

  # element - character_xs
  {
    my $e1 = Rstats::ElementFunc::character_xs("foo");
    is($e1->type, 'character');
    is($e1->cv, "foo");
  }
}
