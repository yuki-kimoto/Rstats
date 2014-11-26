use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::VectorFunc;

# reference
{
  my $na = Rstats::VectorFunc::NA;
  ok($na->is_na);
}

# negation
{
  my $na1 = Rstats::VectorFunc::NA;
  my $na2 = Rstats::VectorFunc::negation($na1);
  ok($na2->is_na);
}

# bool
{
  my $na = Rstats::VectorFunc::NA;
  
  eval { !!$na };
  like($@, qr/bool/);
}

# to_string
{
  my $na = Rstats::VectorFunc::NA;
  is("$na", 'NA');
}

# is_na
{
  my $na = Rstats::VectorFunc::NA;
  ok($na->is_na);
}
