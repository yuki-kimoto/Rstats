use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::VectorFunc;

# nan - nan is double
{
  my $nan = Rstats::VectorFunc::NaN;
  ok($nan->is_double);
}

# negation
{
  my $nan1 = Rstats::VectorFunc::NaN;
  my $nan2 = Rstats::VectorFunc::negation($nan1);
  ok($nan2->is_nan);
}

# non - boolean
{
  my $nan = Rstats::VectorFunc::NaN;
  eval { !!$nan };
  like($@, qr/logical/);
}

# non - to_string
{
  my $nan = Rstats::VectorFunc::NaN;
  is("$nan", 'NaN');
}

