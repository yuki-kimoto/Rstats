use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::Util;

my $r = Rstats->new;

# comparison operator
{
  # comparison operator - ==, true
  {
    my $z1 = Rstats::Util::complex(1,2);
    my $z2 = Rstats::Util::complex(1,2);
    is(Rstats::Util::equal($z1, $z2), $r->TRUE);
  }
  # comparison operator - ==, false
  {
    my $z1 = Rstats::Util::complex(1,2);
    my $z2 = Rstats::Util::complex(1,1);
    is(Rstats::Util::equal($z1, $z2), $r->FALSE);
  }

  # comparison operator - !=, true
  {
    my $z1 = Rstats::Util::complex(1,2);
    my $z2 = Rstats::Util::complex(1,2);
    is(Rstats::Util::not_equal($z1, $z2), $r->FALSE);
  }
  
  # comparison operator - !=, false
  {
    my $z1 = Rstats::Util::complex(1,2);
    my $z2 = Rstats::Util::complex(1,1);
    is(Rstats::Util::not_equal($z1, $z2), $r->TRUE);
  }

  # comparison operator - <, error
  {
    my $z1 = Rstats::Util::complex(1,2);
    my $z2 = Rstats::Util::complex(1,2);
    eval { my $result = Rstats::Util::less_than($z1, $z2) };
    like($@, qr/invalid/);
  }

  # comparison operator - <=, error
  {
    my $z1 = Rstats::Util::complex(1,2);
    my $z2 = Rstats::Util::complex(1,2);
    eval { my $result = Rstats::Util::less_than_or_equal($z1, $z2) };
    like($@, qr/invalid/);
  }

  # comparison operator - >, error
  {
    my $z1 = Rstats::Util::complex(1,2);
    my $z2 = Rstats::Util::complex(1,2);
    eval { my $result = Rstats::Util::more_than($z1, $z2) };
    like($@, qr/invalid/);
  }

  # comparison operator - >=, error
  {
    my $z1 = Rstats::Util::complex(1,2);
    my $z2 = Rstats::Util::complex(1,2);
    eval { my $result = Rstats::Util::more_than_or_equal($z1, $z2) };
    like($@, qr/invalid/);
  }
}

# to_string
{
  # to_string - basic
  {
    my $z1 = Rstats::Util::complex(1,2);
    is(Rstats::Util::to_string($z1), "1+2i");
  }
  
  # to_string - image number is 0
  {
    my $z1 = Rstats::Util::complex(1,0);
    is(Rstats::Util::to_string($z1), "1+0i");
  }
  
  # to_string - image number is minus
  {
    my $z1 = Rstats::Util::complex(1, -1);
    is(Rstats::Util::to_string($z1), "1-1i");
  }
}

# new
{

  # new
  {
    my $z1 = Rstats::Util::complex(1,2);
    is($z1->value->{re}, 1);
    is($z1->value->{im}, 2);
  }
}

# operation
{
  # operation - negation
  {
    my $z1 = Rstats::Util::complex(1,2);
    my $z2 = Rstats::Util::negation($z1);
    is($z2->value->{re}, -1);
    is($z2->value->{im}, -2);
  }
  
  # operation - add
  {
    my $z1 = Rstats::Util::complex(1,2);
    my $z2 = Rstats::Util::complex(3,4);
    my $z3 = Rstats::Util::add($z1, $z2);
    is($z3->value->{re}, 4);
    is($z3->value->{im}, 6);
  }
  
  # operation - subtract
  {
    my $z1 = Rstats::Util::complex(1,2);
    my $z2 = Rstats::Util::complex(3,4);
    my $z3 = Rstats::Util::subtract($z1, $z2);
    is($z3->value->{re}, -2);
    is($z3->value->{im}, -2);
  }
  
  # operation - multiply
  {
    my $z1 = 1 + $r->i * 2;
    my $z2 = 3 + $r->i * 4;
    my $z3 = Rstats::Util::multiply($z1, $z2);
    is($z3->value->{re}, -5);
    is($z3->value->{im}, 10);
  }

  # operation - abs
  {
    my $z1 = 3 + $r->i * 4;
    my $abs = $z1->abs;
    is($abs, 5);
  }
  
  # operation - conj
  {
    my $z1 = 1 + $r->i * 2;
    my $conj = $z1->conj;
    is($conj->value->{re}, 1);
    is($conj->value->{im}, -2);
  }
  
  # operation - divide
  {
    my $z1 = 5 - $r->i * 6;
    my $z2 = 3 + $r->i * 2;
    my $z3 = $z1 / $z2;
    is($z3->value->{re}, 3/13);
    is($z3->value->{im}, -28/13);
  }

  # operation - divide(real number)
  {
    my $z1 = 2 + $r->i * 4;
    my $z2 = $z1 / 2;
    is($z2->value->{re}, 1);
    is($z2->value->{im}, 2);
  }

  # operation - divide(real number, reverse)
  {
    my $z1 = 3 + $r->i * 2;
    my $z2 = 5 / $z1;
    is($z2->value->{re}, 15 / 13);
    is($z2->value->{im}, -10 / 13);
  }

  # operation - raise
  {
    my $z1 = 1 + $r->i * 2;
    my $z2 = $z1 ** 3;
    is($z2->value->{re}, -11);
    is($z2->value->{im}, -2);
  }
}
