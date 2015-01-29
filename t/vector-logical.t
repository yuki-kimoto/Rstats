use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::Func::Vector;

# logical
{
  # logical - bool, TRUE
  {
    my $true = Rstats::Func::Vector::new_logical(1);
    ok($true);
  }
  
  # logical - bool, FALSE
  {
    my $false = Rstats::Func::Vector::new_logical(0);
    ok(!$false->value);
  }
  
  # negation, true
  {
    my $true = Rstats::Func::Vector::new_logical(1);
    my $num = Rstats::Func::Vector::negation($true);
    ok($num->is_integer);
    is($num->value, -1);
  }

  # negation, false
  {
    my $false = Rstats::Func::Vector::new_logical(0);
    my $num = Rstats::Func::Vector::negation($false);
    ok($num->is_integer);
    is($num->value, 0);
  }
  
  # to_string, true
  {
    my $true = Rstats::Func::Vector::new_logical(1);
    is("$true", 'TRUE');
  }
  
  # to_string, false
  {
    my $false = Rstats::Func::Vector::new_logical(0);
    is("$false", "FALSE");
  }
}

