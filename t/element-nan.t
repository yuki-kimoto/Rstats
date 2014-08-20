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
  ok(Rstats::ElementFunction::is_double($nan));
}

# negation
{
  my $nan1 = Rstats::ElementFunction::NaN;
  my $nan2 = Rstats::ElementFunction::negation($nan1);
  ok(Rstats::ElementFunction::is_nan($nan2));
}

# non - boolean
{
  my $nan = Rstats::ElementFunction::NaN;
  eval { Rstats::ElementFunction::bool($nan) };
  like($@, qr/logical/);
}

# non - to_string
{
  my $nan = Rstats::ElementFunction::NaN;
  is(Rstats::ElementFunction::to_string($nan), 'NaN');
}

