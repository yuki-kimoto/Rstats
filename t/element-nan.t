use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::API;

# nan - singleton
{
  my $nan1 = Rstats::API::NaN;
  my $nan2 = Rstats::API::NaN;
  is($nan1, $nan2);
}

# nan - nan is double
{
  my $nan = Rstats::API::NaN;
  ok($nan->is_double);
}

# negation
{
  my $nan1 = Rstats::API::NaN;
  my $nan2 = Rstats::API::negation($nan1);
  ok($nan2->is_nan);
}

# non - boolean
{
  my $nan = Rstats::API::NaN;
  eval { !!$nan };
  like($@, qr/logical/);
}

# non - to_string
{
  my $nan = Rstats::API::NaN;
  is("$nan", 'NaN');
}

