use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::ElementFunc;
use Scalar::Util 'refaddr';

# logical
{
  # logical - singleton, true
  {
    my $true1 = Rstats::ElementFunc::TRUE;
    my $true2 = Rstats::ElementFunc::TRUE;
    is(refaddr $true1, refaddr $true2);
  }
  
  # logical - singleton, false
  {
    my $false1 = Rstats::ElementFunc::FALSE;
    my $false2 = Rstats::ElementFunc::FALSE;
    is(refaddr $false1, refaddr $false2);
  }
  
  # logical - bool, TRUE
  {
    my $true = Rstats::ElementFunc::TRUE;
    ok($true);
  }
  
  # logical - bool, FALSE
  {
    my $false = Rstats::ElementFunc::FALSE;
    ok(!$false);
  }
  
  # negation, true
  {
    my $true = Rstats::ElementFunc::TRUE;
    my $num = Rstats::ElementFunc::negation($true);
    ok($num->is_integer);
    is($num->value, -1);
  }

  # negation, false
  {
    my $false = Rstats::ElementFunc::FALSE;
    my $num = Rstats::ElementFunc::negation($false);
    ok($num->is_integer);
    is($num->value, 0);
  }
  
  # to_string, true
  {
    my $true = Rstats::ElementFunc::TRUE;
    is("$true", 'TRUE');
  }
  
  # to_string, false
  {
    my $false = Rstats::ElementFunc::FALSE;
    is("$false", "FALSE");
  }
}

