use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::NaN;
use Rstats::Logical;
use Rstats::Type::NA;
use Rstats;

my $r = Rstats->new;

# NaN
{
  my $nan = Rstats::Util::nan;
  is(ref $nan, 'Rstats::NaN');
}

# to_string
{
  my $nan = Rstats::Util::nan;
  is($nan, 'NaN');
}

# is_na
{
  my $nan = Rstats::Util::nan;
  
}

# numeric operator 
{
  # numeric operator - +
  {
    my $nan = Rstats::Util::nan;
    my $ret = $nan + 1;
    is(ref $ret, 'Rstats::NaN');
  }

  # numeric operator - -
  {
    my $nan = Rstats::Util::nan;
    my $ret = $nan - 1;
    is(ref $ret, 'Rstats::NaN');
  }

  # numeric operator - *
  {
    my $nan = Rstats::Util::nan;
    my $ret = $nan * 1;
    is(ref $ret, 'Rstats::NaN');
  }

  # numeric operator - /
  {
    my $nan = Rstats::Util::nan;
    my $ret = $nan / 1;
    is(ref $ret, 'Rstats::NaN');
  }

  # numeric operator - **
  {
    my $nan = Rstats::Util::nan;
    my $ret = $nan ** 1;
    is(ref $ret, 'Rstats::NaN');
  }

  # numeric operator - %
  {
    my $nan = Rstats::Util::nan;
    my $ret = $nan % 1;
    is(ref $ret, 'Rstats::NaN');
  }

  # numeric operator - negation
  {
    my $nan = Rstats::Util::nan;
    my $ret = -$nan;
    is(ref $ret, 'Rstats::NaN');
  }
}

# comparison operator
{
  # comparison operator - <, number
  {
    my $nan = Rstats::Util::nan;
    my $ret = $nan < 1;
    is(ref $ret, 'Rstats::Type::NA');
  }

  # comparison operator - <, complex
  {
    my $nan = Rstats::Util::nan;
    my $ret = $nan < $r->complex(1,1);
    is(ref $ret, 'Rstats::Type::NA');
  }

  # comparison operator - ==, character
  {
    my $nan = Rstats::Util::nan;
    my $ret = $nan == 'a';
    is($ret, $r->FALSE);
  }

  # comparison operator - ==, character
  {
    my $nan = Rstats::Util::nan;
    my $ret = $nan == 'NaN';
    is($ret, $r->TRUE);
  }
  
  # comparison operator - <=
  {
    my $nan = Rstats::Util::nan;
    my $ret = $nan <= 1;
    is(ref $ret, 'Rstats::Type::NA');
  }

  # comparison operator - >
  {
    my $nan = Rstats::Util::nan;
    my $ret = $nan > 1;
    is(ref $ret, 'Rstats::Type::NA');
  }

  # comparison operator - >=
  {
    my $nan = Rstats::Util::nan;
    my $ret = $nan >= 1;
    is(ref $ret, 'Rstats::Type::NA');
  }

  # comparison operator - ==
  {
    my $nan = Rstats::Util::nan;
    my $ret = $nan == 1;
    is(ref $ret, 'Rstats::Type::NA');
  }

  # comparison operator - !=
  {
    my $nan = Rstats::Util::nan;
    my $ret = $nan != 1;
    is(ref $ret, 'Rstats::Type::NA');
  }
}
