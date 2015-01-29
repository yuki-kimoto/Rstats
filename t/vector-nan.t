use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::VectorFunc;

# nan - nan is double
{
  my $nan = Rstats::VectorFunc::new_double('NaN');
  ok($nan->is_double);
}

# negation
{
  my $nan1 = Rstats::VectorFunc::new_double('NaN');
  my $nan2 = Rstats::VectorFunc::negation($nan1);
  ok($nan2->is_nan->value);
}

# non - to_string
{
  my $nan = Rstats::VectorFunc::new_double('NaN');
  is("$nan", 'NaN');
}

