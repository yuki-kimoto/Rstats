use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::ElementsFunc;

# logical
{
  # logical - bool, TRUE
  {
    my $true = Rstats::ElementsFunc::TRUE;
    ok($true);
  }
  
  # logical - bool, FALSE
  {
    my $false = Rstats::ElementsFunc::FALSE;
    ok(!$false);
  }
  
  # negation, true
  {
    my $true = Rstats::ElementsFunc::TRUE;
    my $num = Rstats::ElementsFunc::negation($true);
    ok($num->is_integer);
    is($num->value, -1);
  }

  # negation, false
  {
    my $false = Rstats::ElementsFunc::FALSE;
    my $num = Rstats::ElementsFunc::negation($false);
    ok($num->is_integer);
    is($num->value, 0);
  }
  
  # to_string, true
  {
    my $true = Rstats::ElementsFunc::TRUE;
    is("$true", 'TRUE');
  }
  
  # to_string, false
  {
    my $false = Rstats::ElementsFunc::FALSE;
    is("$false", "FALSE");
  }
}

