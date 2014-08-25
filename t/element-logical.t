use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::EFunc;
use Scalar::Util 'refaddr';

# logical
{
  # logical - singleton, true
  {
    my $true1 = Rstats::EFunc::TRUE;
    my $true2 = Rstats::EFunc::TRUE;
    is(refaddr $true1, refaddr $true2);
  }
  
  # logical - singleton, false
  {
    my $false1 = Rstats::EFunc::FALSE;
    my $false2 = Rstats::EFunc::FALSE;
    is(refaddr $false1, refaddr $false2);
  }
  
  # logical - bool, TRUE
  {
    my $true = Rstats::EFunc::TRUE;
    ok($true);
  }
  
  # logical - bool, FALSE
  {
    my $false = Rstats::EFunc::FALSE;
    ok(!$false);
  }
  
  # negation, true
  {
    my $true = Rstats::EFunc::TRUE;
    my $num = Rstats::EFunc::negation($true);
    ok($num->is_integer);
    is($num->value, -1);
  }

  # negation, false
  {
    my $false = Rstats::EFunc::FALSE;
    my $num = Rstats::EFunc::negation($false);
    ok($num->is_integer);
    is($num->value, 0);
  }
  
  # to_string, true
  {
    my $true = Rstats::EFunc::TRUE;
    is("$true", 'TRUE');
  }
  
  # to_string, false
  {
    my $false = Rstats::EFunc::FALSE;
    is("$false", "FALSE");
  }
}

