use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::ElementsFunc;

# reference
{
  my $na = Rstats::ElementsFunc::NA;
  ok($na->is_na);
}

# negation
{
  my $na1 = Rstats::ElementsFunc::NA;
  my $na2 = Rstats::ElementsFunc::negation($na1);
  ok($na2->is_na);
}

# bool
{
  my $na = Rstats::ElementsFunc::NA;
  
  eval { !!$na };
  like($@, qr/bool/);
}

# to_string
{
  my $na = Rstats::ElementsFunc::NA;
  is("$na", 'NA');
}

# is_na
{
  my $na = Rstats::ElementsFunc::NA;
  ok($na->is_na);
}
