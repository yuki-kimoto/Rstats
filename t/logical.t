use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::Util;
use Scalar::Util 'refaddr';

# logical
{
  # logical - singleton, true
  {
    my $true1 = Rstats::Util::true;
    my $true2 = Rstats::Util::true;
    is(refaddr $true1, refaddr $true2);
  }
  
  # logical - singleton, false
  {
    my $false1 = Rstats::Util::false;
    my $false2 = Rstats::Util::false;
    is(refaddr $false1, refaddr $false2);
  }
  
  # logical - bool, TRUE
  {
    my $true = Rstats::Util::true;
    ok($true);
  }
  
  # logical - bool, FALSE
  {
    my $false = Rstats::Util::false;
    ok(!$false);
  }
  
  # negation, true
  {
    my $true = Rstats::Util::true;
    my $num = -$true;
    ok(Rstats::Util::is_integer($num));
    is($num->value, 0);
  }

  # negation, false
  {
    my $false = Rstats::Util::false;
    my $num = -$false;
    ok(Rstats::Util::is_integer($num));
    is($num->value, 1);
  }
  
  # to_string, true
  {
    my $true = Rstats::Util::true;
    is("$true", 'TRUE');
  }
  
  # to_string, false
  {
    my $false = Rstats::Util::false;
    is("$false", "FALSE");
  }
}

