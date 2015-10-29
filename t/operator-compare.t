use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# comparison operator
{
  # comparison operator - ==, true
  {
    my $z1 = r->c_complex({re => 1, im => 2});
    my $z2 = r->c_complex({re => 1, im => 2});
    my $ret = r->equal($z1, $z2);
    is($ret->value, 1);
  }
  # comparison operator - ==, false
  {
    my $z1 = r->c_complex({re => 1, im => 2});
    my $z2 = r->c_complex({re => 1, im => 1});
    my $ret = r->equal($z1, $z2);
    is($ret->value, 0);
  }

  # comparison operator - !=, true
  {
    my $z1 = r->c_complex({re => 1, im => 2});
    my $z2 = r->c_complex({re => 1, im => 2});
    is(r->not_equal($z1, $z2)->value, 0);
  }
  
  # comparison operator - !=, false
  {
    my $z1 = r->c_complex({re => 1, im => 2});
    my $z2 = r->c_complex({re => 1, im => 1});
    is(r->not_equal($z1, $z2)->value, 1);
  }

  # comparison operator - <, error
  {
    my $z1 = r->c_complex({re => 1, im => 2});
    my $z2 = r->c_complex({re => 1, im => 2});
    eval { my $result = r->less_than($z1, $z2) };
    like($@, qr/invalid/);
  }

  # comparison operator - <=, error
  {
    my $z1 = r->c_complex({re => 1, im => 2});
    my $z2 = r->c_complex({re => 1, im => 2});
    eval { my $result = r->less_than_or_equal($z1, $z2) };
    like($@, qr/invalid/);
  }

  # comparison operator - >, error
  {
    my $z1 = r->c_complex({re => 1, im => 2});
    my $z2 = r->c_complex({re => 1, im => 2});
    eval { my $result = r->more_than($z1, $z2) };
    like($@, qr/invalid/);
  }

  # comparison operator - >=, error
  {
    my $z1 = r->c_complex({re => 1, im => 2});
    my $z2 = r->c_complex({re => 1, im => 2});
    eval { my $result = r->more_than_or_equal($z1, $z2) };
    like($@, qr/invalid/);
  }
}