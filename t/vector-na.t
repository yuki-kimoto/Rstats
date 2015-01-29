use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::Func::Vector;

# reference
{
  my $na = Rstats::Func::Vector::new_logical(undef);
  ok($na->is_na);
}

# negation
{
  my $na1 = Rstats::Func::Vector::new_logical(undef);
  my $na2 = Rstats::Func::Vector::negation($na1);
  ok($na2->is_na);
}

# to_string
{
  my $na = Rstats::Func::Vector::new_logical(undef);
  is("$na", 'NA');
}

# is_na
{
  my $na = Rstats::Func::Vector::new_logical(undef);
  ok($na->is_na);
}
