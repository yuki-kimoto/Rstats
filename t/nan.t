use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::NaN;
use Rstats::Logical;
use Rstats::NA;
use Rstats;

my $r = Rstats->new;

# NaN
{
  my $nan = Rstats::NaN->NaN;
  is(ref $nan, 'Rstats::NaN');
}

# to_string
{
  my $nan = Rstats::NaN->NaN;
  is($nan, 'NaN');
}

# is_na
{
  my $nan = Rstats::NaN->NaN;
  
}

# numeric operator 
{
  # numeric operator - +
  {
    my $nan = Rstats::NaN->NaN;
    my $ret = $nan + 1;
    is(ref $ret, 'Rstats::NaN');
  }

  # numeric operator - -
  {
    my $nan = Rstats::NaN->NaN;
    my $ret = $nan - 1;
    is(ref $ret, 'Rstats::NaN');
  }

  # numeric operator - *
  {
    my $nan = Rstats::NaN->NaN;
    my $ret = $nan * 1;
    is(ref $ret, 'Rstats::NaN');
  }

  # numeric operator - /
  {
    my $nan = Rstats::NaN->NaN;
    my $ret = $nan / 1;
    is(ref $ret, 'Rstats::NaN');
  }

  # numeric operator - **
  {
    my $nan = Rstats::NaN->NaN;
    my $ret = $nan ** 1;
    is(ref $ret, 'Rstats::NaN');
  }

  # numeric operator - %
  {
    my $nan = Rstats::NaN->NaN;
    my $ret = $nan % 1;
    is(ref $ret, 'Rstats::NaN');
  }

  # numeric operator - negation
  {
    my $nan = Rstats::NaN->NaN;
    my $ret = -$nan;
    is(ref $ret, 'Rstats::NaN');
  }
}

# comparison operator
{
  # comparison operator - <, number
  {
    my $nan = Rstats::NaN->NaN;
    my $ret = $nan < 1;
    is(ref $ret, 'Rstats::NA');
  }

  # comparison operator - <, complex
  {
    my $nan = Rstats::NaN->NaN;
    my $ret = $nan < $r->complex(1,1);
    is(ref $ret, 'Rstats::NA');
  }

  # comparison operator - ==, character
  {
    my $nan = Rstats::NaN->NaN;
    my $ret = $nan == 'a';
    is($ret, $r->FALSE);
  }

  # comparison operator - ==, character
  {
    my $nan = Rstats::NaN->NaN;
    my $ret = $nan == 'NaN';
    is($ret, $r->TRUE);
  }
  
  # comparison operator - <=
  {
    my $nan = Rstats::NaN->NaN;
    my $ret = $nan <= 1;
    is(ref $ret, 'Rstats::NA');
  }

  # comparison operator - >
  {
    my $nan = Rstats::NaN->NaN;
    my $ret = $nan > 1;
    is(ref $ret, 'Rstats::NA');
  }

  # comparison operator - >=
  {
    my $nan = Rstats::NaN->NaN;
    my $ret = $nan >= 1;
    is(ref $ret, 'Rstats::NA');
  }

  # comparison operator - ==
  {
    my $nan = Rstats::NaN->NaN;
    my $ret = $nan == 1;
    is(ref $ret, 'Rstats::NA');
  }

  # comparison operator - !=
  {
    my $nan = Rstats::NaN->NaN;
    my $ret = $nan != 1;
    is(ref $ret, 'Rstats::NA');
  }
}
