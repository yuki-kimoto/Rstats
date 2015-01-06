use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::ArrayFunc;

# logical
{
  # logical - bool, TRUE
  {
    my $true = Rstats::ArrayFunc::new_logical(1);
    ok($true);
  }
  
  # logical - bool, FALSE
  {
    my $false = Rstats::ArrayFunc::new_logical(0);
    ok(!$false->value);
  }
  
  # negation, true
  {
    my $true = Rstats::ArrayFunc::new_logical(1);
    my $num = Rstats::ArrayFunc::negation($true);
    ok($num->is_integer);
    is($num->value, -1);
  }

  # negation, false
  {
    my $false = Rstats::ArrayFunc::new_logical(0);
    my $num = Rstats::ArrayFunc::negation($false);
    ok($num->is_integer);
    is($num->value, 0);
  }
  
  # to_string, true
  {
    my $true = Rstats::ArrayFunc::new_logical(1);
    is("$true", 'TRUE');
  }
  
  # to_string, false
  {
    my $false = Rstats::ArrayFunc::new_logical(0);
    is("$false", "FALSE");
  }
}

