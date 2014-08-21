use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::ElementFunction;
use Scalar::Util 'refaddr';

# reference
{
  my $na = Rstats::ElementFunction::NA;
  ok($na->is_na);
}

# singleton
{
  my $na1 = Rstats::ElementFunction::NA;
  my $na2 = Rstats::ElementFunction::NA;
  is(refaddr $na1, refaddr $na2);
}

# negation
{
  my $na1 = Rstats::ElementFunction::NA;
  my $na2 = Rstats::ElementFunction::negation($na1);
  ok($na2->is_na);
}

# bool
{
  my $na = Rstats::ElementFunction::NA;
  
  eval { !!$na };
  like($@, qr/bool/);
}

# to_string
{
  my $na = Rstats::ElementFunction::NA;
  is("$na", 'NA');
}

# is_na
{
  my $na = Rstats::ElementFunction::NA;
  ok($na->is_na);
}
