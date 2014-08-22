use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::ElementFunction;

# nan - singleton
{
  my $nan1 = Rstats::ElementFunction::NaN;
  my $nan2 = Rstats::ElementFunction::NaN;
  is($nan1, $nan2);
}

# nan - nan is double
{
  my $nan = Rstats::ElementFunction::NaN;
  ok($nan->is_double);
}

# negation
{
  my $nan1 = Rstats::ElementFunction::NaN;
  my $nan2 = Rstats::ElementFunction::negation($nan1);
  ok($nan2->is_nan);
}

# non - boolean
{
  my $nan = Rstats::ElementFunction::NaN;
  eval { !!$nan };
  like($@, qr/logical/);
}

# non - to_string
{
  my $nan = Rstats::ElementFunction::NaN;
  is("$nan", 'NaN');
}

