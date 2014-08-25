use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::EFunc;
use Scalar::Util 'refaddr';

# reference
{
  my $na = Rstats::EFunc::NA;
  ok($na->is_na);
}

# singleton
{
  my $na1 = Rstats::EFunc::NA;
  my $na2 = Rstats::EFunc::NA;
  is(refaddr $na1, refaddr $na2);
}

# negation
{
  my $na1 = Rstats::EFunc::NA;
  my $na2 = Rstats::EFunc::negation($na1);
  ok($na2->is_na);
}

# bool
{
  my $na = Rstats::EFunc::NA;
  
  eval { !!$na };
  like($@, qr/bool/);
}

# to_string
{
  my $na = Rstats::EFunc::NA;
  is("$na", 'NA');
}

# is_na
{
  my $na = Rstats::EFunc::NA;
  ok($na->is_na);
}
