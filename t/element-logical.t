use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::API;
use Scalar::Util 'refaddr';

# logical
{
  # logical - singleton, true
  {
    my $true1 = Rstats::API::TRUE;
    my $true2 = Rstats::API::TRUE;
    is(refaddr $true1, refaddr $true2);
  }
  
  # logical - singleton, false
  {
    my $false1 = Rstats::API::FALSE;
    my $false2 = Rstats::API::FALSE;
    is(refaddr $false1, refaddr $false2);
  }
  
  # logical - bool, TRUE
  {
    my $true = Rstats::API::TRUE;
    ok($true);
  }
  
  # logical - bool, FALSE
  {
    my $false = Rstats::API::FALSE;
    ok(!$false);
  }
  
  # negation, true
  {
    my $true = Rstats::API::TRUE;
    my $num = Rstats::API::negation($true);
    ok($num->is_integer);
    is($num->value, -1);
  }

  # negation, false
  {
    my $false = Rstats::API::FALSE;
    my $num = Rstats::API::negation($false);
    ok($num->is_integer);
    is($num->value, 0);
  }
  
  # to_string, true
  {
    my $true = Rstats::API::TRUE;
    is("$true", 'TRUE');
  }
  
  # to_string, false
  {
    my $false = Rstats::API::FALSE;
    is("$false", "FALSE");
  }
}

