use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::Func::Vector;

# nan - nan is double
{
  my $nan = Rstats::Func::Vector::new_double('NaN');
  ok($nan->is_double);
}

# negation
{
  my $nan1 = Rstats::Func::Vector::new_double('NaN');
  my $nan2 = Rstats::Func::Vector::negation($nan1);
  ok($nan2->is_nan->value);
}

# non - to_string
{
  my $nan = Rstats::Func::Vector::new_double('NaN');
  is("$nan", 'NaN');
}

