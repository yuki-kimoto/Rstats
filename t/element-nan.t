use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::ElementsFunc;

# nan - nan is double
{
  my $nan = Rstats::ElementsFunc::NaN;
  ok($nan->is_double);
}

# negation
{
  my $nan1 = Rstats::ElementsFunc::NaN;
  my $nan2 = Rstats::ElementsFunc::negation($nan1);
  ok($nan2->is_nan);
}

# non - boolean
{
  my $nan = Rstats::ElementsFunc::NaN;
  eval { !!$nan };
  like($@, qr/logical/);
}

# non - to_string
{
  my $nan = Rstats::ElementsFunc::NaN;
  is("$nan", 'NaN');
}

