use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::NA;
use Rstats::Logical;

# singleton
{
  my $na = Rstats::NA->NA;
  is(ref $na, 'Rstats::NA');
}

# to_string
{
  my $na = Rstats::NA->NA;
  is("$na", 'NA');
}

# is_na
{
  my $na = Rstats::NA->NA;
  ok(Rstats::NA->is_na($na));
}

# operator
{
  # operator - +
  {
    my $na = Rstats::NA->NA;
    my $ret = $na + 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - -
  {
    my $na = Rstats::NA->NA;
    my $ret = $na - 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - *
  {
    my $na = Rstats::NA->NA;
    my $ret = $na * 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - /
  {
    my $na = Rstats::NA->NA;
    my $ret = $na / 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - **
  {
    my $na = Rstats::NA->NA;
    my $ret = $na ** 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - %
  {
    my $na = Rstats::NA->NA;
    my $ret = $na % 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - negation
  {
    my $na = Rstats::NA->NA;
    my $ret = -$na;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - <
  {
    my $na = Rstats::NA->NA;
    my $ret = $na < 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - <=
  {
    my $na = Rstats::NA->NA;
    my $ret = $na <= 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - >
  {
    my $na = Rstats::NA->NA;
    my $ret = $na > 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - >=
  {
    my $na = Rstats::NA->NA;
    my $ret = $na >= 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - ==
  {
    my $na = Rstats::NA->NA;
    my $ret = $na == 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - !=
  {
    my $na = Rstats::NA->NA;
    my $ret = $na != 1;
    is(ref $ret, 'Rstats::NA');
  }
}
