use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::NA;
use Rstats::Logical;

# singleton
{
  my $na = Rstats::NA->new;
  is(ref $na, 'Rstats::NA');
}

# to_string
{
  my $na = Rstats::NA->new;
  ok(Rstats::NA->is_na($na));
}

# is_na
{
  my $na = Rstats::NA->new;
  
}

# operator
{
  # operator - +
  {
    my $na = Rstats::NA->new;
    my $ret = $na + 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - -
  {
    my $na = Rstats::NA->new;
    my $ret = $na - 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - *
  {
    my $na = Rstats::NA->new;
    my $ret = $na * 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - /
  {
    my $na = Rstats::NA->new;
    my $ret = $na / 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - **
  {
    my $na = Rstats::NA->new;
    my $ret = $na ** 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - %
  {
    my $na = Rstats::NA->new;
    my $ret = $na % 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - negation
  {
    my $na = Rstats::NA->new;
    my $ret = -$na;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - <
  {
    my $na = Rstats::NA->new;
    my $ret = $na < 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - <=
  {
    my $na = Rstats::NA->new;
    my $ret = $na <= 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - >
  {
    my $na = Rstats::NA->new;
    my $ret = $na > 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - >=
  {
    my $na = Rstats::NA->new;
    my $ret = $na >= 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - ==
  {
    my $na = Rstats::NA->new;
    my $ret = $na == 1;
    is(ref $ret, 'Rstats::NA');
  }

  # operator - !=
  {
    my $na = Rstats::NA->new;
    my $ret = $na != 1;
    is(ref $ret, 'Rstats::NA');
  }
}
