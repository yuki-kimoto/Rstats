use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::ElementFunc;

# nan - nan is double
{
  my $nan = Rstats::ElementFunc::NaN;
  ok($nan->is_double);
}

# negation
{
  my $nan1 = Rstats::ElementFunc::NaN;
  my $nan2 = Rstats::ElementFunc::negation($nan1);
  ok($nan2->is_nan);
}

# non - boolean
{
  my $nan = Rstats::ElementFunc::NaN;
  eval { !!$nan };
  like($@, qr/logical/);
}

# non - to_string
{
  my $nan = Rstats::ElementFunc::NaN;
  is("$nan", 'NaN');
}

