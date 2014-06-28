use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::Complex;

my $r = Rstats->new;

# to_string
{
  # to_string - basic
  {
    my $z1 = $r->complex(1, 2);
    is("$z1", "1+2i");
  }
  
  # to_string - image number is 0
  {
    my $z1 = $r->complex(1, 0);
    is("$z1", "1+0i");
  }
  
  # to_string - image number is minus
  {
    my $z1 = $r->complex(1, -1);
    is("$z1", "1-1i");
  }
}

# new
{

  # new
  {
    my $z1 = Rstats::Complex->new(re => 1, im => 2);
    is($z1->re, 1);
    is($z1->im, 2);
  }
}

# operation
{
  # operation - negation
  {
    my $z1 = Rstats::Complex->new(re => 1, im => 2);
    my $z2 = - $z1;
    is($z2->re, -1);
    is($z2->im, -2);
  }
  
  # operation - add
  {
    my $z1 = Rstats::Complex->new(re => 1, im => 2);
    my $z2 = Rstats::Complex->new(re => 3, im => 4);
    my $z3 = $z1 + $z2;
    is($z3->re, 4);
    is($z3->im, 6);
  }
  
  # operation - add(real number)
  {
    my $z1 = Rstats::Complex->new(re => 1, im => 2);
    my $z2 = $z1 + 3;
    is($z2->re, 4);
    is($z2->im, 2);
  }

  # operation - subtract
  {
    my $z1 = Rstats::Complex->new(re => 1, im => 2);
    my $z2 = Rstats::Complex->new(re => 3, im => 4);
    my $z3 = $z1 - $z2;
    is($z3->re, -2);
    is($z3->im, -2);
  }
  
  #operation -  subtract(real number)
  {
    my $z1 = Rstats::Complex->new(re => 1, im => 2);
    my $z2 = $z1 - 3;
    is($z2->re, -2);
    is($z2->im, 2);
  }
  
  # operation - subtract(real number, reverse)
  {
    my $z1 = Rstats::Complex->new(re => 1, im => 2);
    my $z2 = 3 - $z1;
    is($z2->re, 2);
    is($z2->im, -2);
  }
  
  # operation - multiply
  {
    my $z1 = 1 + $r->i * 2;
    my $z2 = 3 + $r->i * 4;
    my $z3 = $z1 * $z2;
    is($z3->re, -5);
    is($z3->im, 10);
  }

  # operation - multiply(real number)
  {
    my $z1 = 1 + $r->i * 2;
    my $z2 = $z1 * 3;
    is($z2->re, 3);
    is($z2->im, 6);
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
    is($conj->re, 1);
    is($conj->im, -2);
  }
  
  # operation - divide
  {
    my $z1 = 5 - $r->i * 6;
    my $z2 = 3 + $r->i * 2;
    my $z3 = $z1 / $z2;
    is($z3->re, 3/13);
    is($z3->im, -28/13);
  }

  # operation - divide(real number)
  {
    my $z1 = 2 + $r->i * 4;
    my $z2 = $z1 / 2;
    is($z2->re, 1);
    is($z2->im, 2);
  }

  # operation - divide(real number, reverse)
  {
    my $z1 = 3 + $r->i * 2;
    my $z2 = 5 / $z1;
    is($z2->re, 15 / 13);
    is($z2->im, -10 / 13);
  }

  # operation - raise
  {
    my $z1 = 1 + $r->i * 2;
    my $z2 = $z1 ** 3;
    is($z2->re, -11);
    is($z2->im, -2);
  }
}
