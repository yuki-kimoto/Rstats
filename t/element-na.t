use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::API;
use Scalar::Util 'refaddr';

# reference
{
  my $na = Rstats::API::NA;
  ok($na->is_na);
}

# singleton
{
  my $na1 = Rstats::API::NA;
  my $na2 = Rstats::API::NA;
  is(refaddr $na1, refaddr $na2);
}

# negation
{
  my $na1 = Rstats::API::NA;
  my $na2 = Rstats::API::negation($na1);
  ok($na2->is_na);
}

# bool
{
  my $na = Rstats::API::NA;
  
  eval { !!$na };
  like($@, qr/bool/);
}

# to_string
{
  my $na = Rstats::API::NA;
  is("$na", 'NA');
}

# is_na
{
  my $na = Rstats::API::NA;
  ok($na->is_na);
}
