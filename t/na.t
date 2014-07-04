use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::Type::NA;
use Rstats::Logical;

# singleton
{
  my $na = Rstats::Util::na;
  is(ref $na, 'Rstats::Type::NA');
}

# to_string
{
  my $na = Rstats::Util::na;
  is("$na", 'NA');
}

# is_na
{
  my $na = Rstats::Util::na;
  ok(Rstats::Type::NA->is_na($na));
}

# operator
{
  # operator - +
  {
    my $na = Rstats::Util::na;
    my $ret = $na + 1;
    is(ref $ret, 'Rstats::Type::NA');
  }

  # operator - -
  {
    my $na = Rstats::Util::na;
    my $ret = $na - 1;
    is(ref $ret, 'Rstats::Type::NA');
  }

  # operator - *
  {
    my $na = Rstats::Util::na;
    my $ret = $na * 1;
    is(ref $ret, 'Rstats::Type::NA');
  }

  # operator - /
  {
    my $na = Rstats::Util::na;
    my $ret = $na / 1;
    is(ref $ret, 'Rstats::Type::NA');
  }

  # operator - **
  {
    my $na = Rstats::Util::na;
    my $ret = $na ** 1;
    is(ref $ret, 'Rstats::Type::NA');
  }

  # operator - %
  {
    my $na = Rstats::Util::na;
    my $ret = $na % 1;
    is(ref $ret, 'Rstats::Type::NA');
  }

  # operator - negation
  {
    my $na = Rstats::Util::na;
    my $ret = -$na;
    is(ref $ret, 'Rstats::Type::NA');
  }

  # operator - <
  {
    my $na = Rstats::Util::na;
    my $ret = $na < 1;
    is(ref $ret, 'Rstats::Type::NA');
  }

  # operator - <=
  {
    my $na = Rstats::Util::na;
    my $ret = $na <= 1;
    is(ref $ret, 'Rstats::Type::NA');
  }

  # operator - >
  {
    my $na = Rstats::Util::na;
    my $ret = $na > 1;
    is(ref $ret, 'Rstats::Type::NA');
  }

  # operator - >=
  {
    my $na = Rstats::Util::na;
    my $ret = $na >= 1;
    is(ref $ret, 'Rstats::Type::NA');
  }

  # operator - ==
  {
    my $na = Rstats::Util::na;
    my $ret = $na == 1;
    is(ref $ret, 'Rstats::Type::NA');
  }

  # operator - !=
  {
    my $na = Rstats::Util::na;
    my $ret = $na != 1;
    is(ref $ret, 'Rstats::Type::NA');
  }
}
