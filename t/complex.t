use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

use Rstats::Class;
use Rstats::VectorFunc;

my $r = Rstats::Class->new;

# to_string
{
  # to_string - image number is 0
  {
    my $z1 = r->new_complex({re => 1, im => 0});
    is("$z1", "[1] 1+0i\n");
  }
  
  # to_string - basic
  {
    my $z1 = r->new_complex({re => 1, im => 2});
    is("$z1", "[1] 1+2i\n");
  }
  
  # to_string - image number is minus
  {
    my $z1 = r->new_complex({re => 1, im => -1});
    is("$z1", "[1] 1-1i\n");
  }
}

# comparison operator
{
  # comparison operator - ==, true
  {
    my $z1 = r->new_complex({re => 1, im => 2});
    my $z2 = r->new_complex({re => 1, im => 2});
    my $ret = r->equal($z1, $z2);
    is($ret->value, 1);
  }
  # comparison operator - ==, false
  {
    my $z1 = r->new_complex({re => 1, im => 2});
    my $z2 = r->new_complex({re => 1, im => 1});
    my $ret = r->equal($z1, $z2);
    is($ret->value, 0);
  }

  # comparison operator - !=, true
  {
    my $z1 = r->new_complex({re => 1, im => 2});
    my $z2 = r->new_complex({re => 1, im => 2});
    is(r->not_equal($z1, $z2)->value, 0);
  }
  
  # comparison operator - !=, false
  {
    my $z1 = r->new_complex({re => 1, im => 2});
    my $z2 = r->new_complex({re => 1, im => 1});
    is(r->not_equal($z1, $z2)->value, 1);
  }

  # comparison operator - <, error
  {
    my $z1 = r->new_complex({re => 1, im => 2});
    my $z2 = r->new_complex({re => 1, im => 2});
    eval { my $result = r->less_than($z1, $z2) };
    like($@, qr/invalid/);
  }

  # comparison operator - <=, error
  {
    my $z1 = r->new_complex({re => 1, im => 2});
    my $z2 = r->new_complex({re => 1, im => 2});
    eval { my $result = r->less_than_or_equal($z1, $z2) };
    like($@, qr/invalid/);
  }

  # comparison operator - >, error
  {
    my $z1 = r->new_complex({re => 1, im => 2});
    my $z2 = r->new_complex({re => 1, im => 2});
    eval { my $result = r->more_than($z1, $z2) };
    like($@, qr/invalid/);
  }

  # comparison operator - >=, error
  {
    my $z1 = r->new_complex({re => 1, im => 2});
    my $z2 = r->new_complex({re => 1, im => 2});
    eval { my $result = r->more_than_or_equal($z1, $z2) };
    like($@, qr/invalid/);
  }
}

# new
{
  # new
  {
    my $z1 = r->new_complex({re => 1, im => 2});
    is($z1->value->{re}, 1);
    is($z1->value->{im}, 2);
  }
}

# operation
{
  # operation - negation
  {
    my $z1 = r->new_complex({re => 1, im => 2});
    my $z2 = r->negation($z1);
    is($z2->value->{re}, -1);
    is($z2->value->{im}, -2);
  }
  
  # operation - add
  {
    my $z1 = r->new_complex({re => 1, im => 2});
    my $z2 = r->new_complex({re => 3, im => 4});
    my $z3 = r->add($z1, $z2);
    is($z3->value->{re}, 4);
    is($z3->value->{im}, 6);
  }
  
  # operation - subtract
  {
    my $z1 = r->new_complex({re => 1, im => 2});
    my $z2 = r->new_complex({re => 3, im => 4});
    my $z3 = r->subtract($z1, $z2);
    is($z3->value->{re}, -2);
    is($z3->value->{im}, -2);
  }
  
  # operation - multiply
  {
    my $z1 = r->new_complex({re => 1, im => 2});
    my $z2 = r->new_complex({re => 3, im => 4});
    my $z3 = r->multiply($z1, $z2);
    is($z3->value->{re}, -5);
    is($z3->value->{im}, 10);
  }

  # operation - abs
  {
    my $z1 = r->new_complex({re => 3, im => 4});
    my $abs = r->abs($z1);
    is($abs->value, 5);
  }
  
  # operation - Conj
  {
    my $z1 = r->new_complex({re => 1, im => 2});
    my $conj = r->Conj($z1);
    is($conj->value->{re}, 1);
    is($conj->value->{im}, -2);
  }
  
  # operation - divide
  {
    my $z1 = r->new_complex({re => 5, im => -6});
    my $z2 = r->new_complex({re => 3, im => 2});
    my $z3 = r->divide($z1, $z2);
    is($z3->value->{re}, 3/13);
    is($z3->value->{im}, -28/13);
  }

  # operation - pow
  {
    my $z1 = r->new_complex({re => 1, im => 2});
    my $z2 = r->new_complex({re => 3, im => 0});
    my $z3 = r->pow($z1, $z2);
    is($z3->value->{re}, -11);
    is($z3->value->{im}, -2);
  }
}
