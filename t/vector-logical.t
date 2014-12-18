use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::VectorFunc;

# logical
{
  # logical - bool, TRUE
  {
    my $true = Rstats::VectorFunc::TRUE;
    ok($true);
  }
  
  # logical - bool, FALSE
  {
    my $false = Rstats::VectorFunc::FALSE;
    ok(!$false->value);
  }
  
  # negation, true
  {
    my $true = Rstats::VectorFunc::TRUE;
    my $num = Rstats::VectorFunc::negation($true);
    ok($num->is_integer);
    is($num->value, -1);
  }

  # negation, false
  {
    my $false = Rstats::VectorFunc::FALSE;
    my $num = Rstats::VectorFunc::negation($false);
    ok($num->is_integer);
    is($num->value, 0);
  }
  
  # to_string, true
  {
    my $true = Rstats::VectorFunc::TRUE;
    is("$true", 'TRUE');
  }
  
  # to_string, false
  {
    my $false = Rstats::VectorFunc::FALSE;
    is("$false", "FALSE");
  }
}

