use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::VectorFunc;
use Rstats;

my $x1 = c(1, 2, 3);
1;


# element
{
  # element - new_na
  {
    my $e1 = Rstats::VectorFunc::new_na();
    ok($e1->is_na);
    ok(!defined $e1->value);
  }

  # element - is_finite
  {
    # element - is_finite - double
    {
      my $e1 = Rstats::VectorFunc::new_double(1.2);
      ok($e1->is_finite);
    }
    
    # element - is_finite - integer
    {
      my $e1 = Rstats::VectorFunc::new_integer(3);
      ok($e1->is_finite);
    }

    # element - is_finite - NaN
    {
      my $e1 = Rstats::VectorFunc::new_nan();
      is($e1->type, 'double');
      ok(!$e1->is_finite);
    }

    # element - is_finite - Inf
    {
      my $e1 = Rstats::VectorFunc::new_inf();
      ok(!$e1->is_finite);
    }

    # element - is_finite - -Inf
    {
      my $e1 = Rstats::VectorFunc::new_negative_inf();
      ok(!$e1->is_finite);
    }
  }
  
  # element - character_xs
  {
    my $e1 = Rstats::VectorFunc::new_character("foo");
    is($e1->type, 'character');
    is($e1->value, "foo");
  }

  # element - Inf_xs
  {
    my $e1 = Rstats::VectorFunc::new_inf();
    is($e1->type, 'double');
    ok($e1->is_infinite);
    ok($e1->value > 0);
  }
  
  # element - negativeInf_xs
  {
    my $e1 = Rstats::VectorFunc::new_negative_inf();
    is($e1->type, 'double');
    ok($e1->is_infinite);
    ok($e1->value < 0);
  }

  # element - NaN_xs
  {
    my $e1 = Rstats::VectorFunc::new_nan();
    is($e1->type, 'double');
    ok($e1->is_nan);
  }
  
  # element - double_xs
  {
    my $e1 = Rstats::VectorFunc::new_double(2.5);
    is($e1->type, 'double');
    is($e1->value, 2.5);
  }

  # element - integer_xs
  {
    my $e1 = Rstats::VectorFunc::new_integer(2);
    is($e1->type, 'integer');
    is($e1->value, 2);
  }

  # element - logical_xs
  {
    my $e1 = Rstats::VectorFunc::new_logical(1);
    is($e1->type, 'logical');
    is($e1->value, 1);
  }
  
  # element - complex_xs
  {
    my $e1 = Rstats::VectorFunc::new_complex(1.5, 2.5);
    is($e1->type, 'complex');
    is($e1->value->{re}, 1.5);
    is($e1->value->{im}, 2.5);
  }
}
