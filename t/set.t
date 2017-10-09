use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats;

my $r = Rstats->new;

# set 3-dimention
{
  # set 3-dimention
  {
    my $x1 = $r->array($r->C('1:24'), $r->c([4, 3, 2]));
    my $x2 = $x1->at($r->c(4), $r->c(3), $r->c(2))->set($r->c(25));
    is_deeply($x2->values, [1 .. 23, 25]);
  }

  # set 3-dimention - one and tow dimention
  {
    my $x1 = $r->array($r->C('1:24'), $r->c([4, 3, 2]));
    my $x2 = $x1->at($r->c(4), $r->c(3))->set($r->c(25));
    is_deeply($x2->values, [1 .. 11, 25, 13 .. 23, 25]);
  }

  # set 3-dimention - one and tow dimention, value is two
  {
    my $x1 = $r->array($r->C('1:24'), $r->c([4, 3, 2]));
    my $x2 = $x1->at($r->c(4), $r->c(3))->set($r->c(25, 26));
    is_deeply($x2->values, [1 .. 11, 25, 13 .. 23, 26]);
  }
  
  # set 3-dimention - one and three dimention, value is three
  {
    my $x1 = $r->array($r->C('1:24'), $r->c([4, 3, 2]));
    my $x2 = $x1->at($r->c(2), undef, $r->c(1))->set($r->c(31, 32, 33));
    is_deeply($x2->values, [1, 31, 3, 4, 5, 32, 7, 8, 9, 33, 11 .. 24]);
  }
}

