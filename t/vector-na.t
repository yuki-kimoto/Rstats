use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::VectorFunc;

# reference
{
  my $na = Rstats::VectorFunc::new_logical(undef);
  ok($na->is_na);
}

# negation
{
  my $na1 = Rstats::VectorFunc::new_logical(undef);
  my $na2 = Rstats::VectorFunc::negation($na1);
  ok($na2->is_na);
}

# to_string
{
  my $na = Rstats::VectorFunc::new_logical(undef);
  is("$na", 'NA');
}

# is_na
{
  my $na = Rstats::VectorFunc::new_logical(undef);
  ok($na->is_na);
}
