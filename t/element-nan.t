use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::EFunc;

# nan - singleton
{
  my $nan1 = Rstats::EFunc::NaN;
  my $nan2 = Rstats::EFunc::NaN;
  is($nan1, $nan2);
}

# nan - nan is double
{
  my $nan = Rstats::EFunc::NaN;
  ok($nan->is_double);
}

# negation
{
  my $nan1 = Rstats::EFunc::NaN;
  my $nan2 = Rstats::EFunc::negation($nan1);
  ok($nan2->is_nan);
}

# non - boolean
{
  my $nan = Rstats::EFunc::NaN;
  eval { !!$nan };
  like($@, qr/logical/);
}

# non - to_string
{
  my $nan = Rstats::EFunc::NaN;
  is("$nan", 'NaN');
}

