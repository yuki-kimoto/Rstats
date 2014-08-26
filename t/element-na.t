use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::ElementFunc;
use Scalar::Util 'refaddr';

# reference
{
  my $na = Rstats::ElementFunc::NA;
  ok($na->is_na);
}

# singleton
{
  my $na1 = Rstats::ElementFunc::NA;
  my $na2 = Rstats::ElementFunc::NA;
  is(refaddr $na1, refaddr $na2);
}

# negation
{
  my $na1 = Rstats::ElementFunc::NA;
  my $na2 = Rstats::ElementFunc::negation($na1);
  ok($na2->is_na);
}

# bool
{
  my $na = Rstats::ElementFunc::NA;
  
  eval { !!$na };
  like($@, qr/bool/);
}

# to_string
{
  my $na = Rstats::ElementFunc::NA;
  is("$na", 'NA');
}

# is_na
{
  my $na = Rstats::ElementFunc::NA;
  ok($na->is_na);
}
