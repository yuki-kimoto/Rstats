use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats;

my $r = Rstats->new;

# get
{
  # get - logical
  {
    my $x1 = $r->c(1, 3, 5, 7);
    my $logical_v = $r->c($r->FALSE, $r->TRUE, $r->FALSE, $r->TRUE, $r->TRUE);
    my $x2 = $x1->get($logical_v);
    is_deeply($x2->values, [3, 7, undef]);
  }

  # get - one value
  {
    my $x1 = $r->c(1);
    my $x2 = $x1->get(1);
    is_deeply($x2->values, [1]);
    is_deeply($r->dim($x2)->values, [1]);
  }

  # get - single index
  {
    my $x1 = $r->c(1, 2, 3, 4);
    my $x2 = $x1->get(1);
    is_deeply($x2->values, [1]);
  }
  
  # get - $r->array
  {
    my $x1 = $r->c(1, 3, 5, 7);
    my $x2 = $x1->get($r->c(1, 2));
    is_deeply($x2->values, [1, 3]);
  }
  
  # get - vector
  {
    my $x1 = $r->c(1, 3, 5, 7);
    my $x2 = $x1->get($r->c(1, 2));
    is_deeply($x2->values, [1, 3]);
  }
  
  # get - minus number
  {
    my $x1 = $r->c(1, 3, 5, 7);
    my $x2 = $x1->get(-1);
    is_deeply($x2->values, [3, 5, 7]);
  }

  # get - minus number + $r->array
  {
    my $x1 = $r->c(1, 3, 5, 7);
    my $x2 = $x1->get($r->c(-1, -2));
    is_deeply($x2->values, [5, 7]);
  }
  
  # get - grep
  {
    my $x1 = $r->c(1, 2, 3, 4, 5);
    my $x2 = $x1 > 3;
    my $x3 = $x1->get($x2);
    is_deeply($x3->values, [4, 5]);
  }
  
  # get - as_logical
  {
    my $x1 = $r->c(1, 3, 5, 7);
    my $logical_v = $r->as->logical($r->c(0, 1, 0, 1, 1));
    my $x2 = $x1->get($logical_v);
    is_deeply($x2->values, [3, 7, undef]);
  }

  # get - as_vector
  {
    my $x1 = $r->array($r->C('1:24'), $r->c(4, 3, 2));
    is_deeply($r->as->vector($x1)->get(5)->values, [5]);
  }

  # get - as_matrix
  {
    my $x1 = $r->array($r->C('1:24'), $r->c(4, 3, 2));
    is_deeply($r->as->vector($x1)->get(5, 1)->values, [5]);
  }
}

# get logical $r->array
{
  # get logical $r->array - basic
  {
    my $x1 = $r->matrix($r->C('1:9'), 3, 3);
    my $x2 = $r->matrix($r->c($r->TRUE, $r->FALSE, $r->FALSE, $r->FALSE, $r->TRUE, $r->FALSE, $r->FALSE, $r->FALSE, $r->TRUE), 3, 3);
    my $x3 = $x1->get($x2);
    is_deeply($x3->values, [1, 5, 9]);
    is_deeply($r->dim($x3)->values, [3]);
  }
}

# get 3-dimention
{
  # get 3-dimention - minus
  {
    my $x1 = $r->array($r->C('1:24'), $r->c(4, 3, 2));
    my $x2 = $x1->get($r->c(-1, -2), $r->c(-1, -2));
    is_deeply($x2->values, [11, 12, 23, 24]);
    is_deeply($r->dim($x2)->values, [2, 2]);
  }
  
  # get 3-dimention - dimention one
  {
    my $x1 = $r->array($r->C('1:24'), $r->c(4, 3, 2));
    my $x2 = $x1->get(2);
    is_deeply($x2->values, [2, 6, 10, 14, 18 ,22]);
    is_deeply($r->dim($x2)->values, [3, 2]);
  }

  # get 3-dimention - dimention two
  {
    my $x1 = $r->array($r->C('1:24'), $r->c(4, 3, 2));
    my $x2 = $x1->get($r->c(), 2);
    is_deeply($x2->values, [5, 6, 7, 8, 17, 18, 19, 20]);
    is_deeply($r->dim($x2)->values, [4, 2]);
  }

  # get 3-dimention - dimention three
  {
    my $x1 = $r->array($r->C('1:24'), $r->c(4, 3, 2));
    my $x2 = $x1->get($r->c(), $r->c(), 2);
    is_deeply($x2->values, [13 .. 24]);
    is_deeply($r->dim($x2)->values, [4, 3]);
  }
  
  # get 3-dimention - one value
  {
    my $x1 = $r->array($r->C('1:24'), $r->c(4, 3, 2));
    my $x2 = $x1->get(3, 2, 1);
    is_deeply($x2->values, [7]);
    is_deeply($r->dim($x2)->values, [1]);
  }

  # get 3-dimention - one value, drop => 0
  {
    my $x1 = $r->array($r->C('1:24'), $r->c(4, 3, 2));
    my $x2 = $x1->get(3, 2, 1, {drop => 0});
    is_deeply($x2->values, [7]);
    is_deeply($r->dim($x2)->values, [1, 1, 1]);
  }
  
  # get 3-dimention - dimention one and two
  {
    my $x1 = $r->array($r->C('1:24'), $r->c(4, 3, 2));
    my $x2 = $x1->get(1, 2);
    is_deeply($x2->values, [5, 17]);
    is_deeply($r->dim($x2)->values, [2]);
  }
  # get 3-dimention - dimention one and three
  {
    my $x1 = $r->array($r->C('1:24'), $r->c(4, 3, 2));
    my $x2 = $x1->get(3, $r->c(), 2);
    is_deeply($x2->values, [15, 19, 23]);
    is_deeply($r->dim($x2)->values, [3]);
  }

  # get 3-dimention - dimention two and three
  {
    my $x1 = $r->array($r->C('1:24'), $r->c(4, 3, 2));
    my $x2 = $x1->get($r->c(), 1, 2);
    is_deeply($x2->values, [13, 14, 15, 16]);
    is_deeply($r->dim($x2)->values, [4]);
  }
  
  # get 3-dimention - all values
  {
    my $x1 = $r->array($r->C('1:24'), $r->c(4, 3, 2));
    my $x2 = $x1->get($r->c(1, 2, 3, 4), $r->c(1, 2, 3), $r->c(1, 2));
    is_deeply($x2->values, [1 .. 24]);
    is_deeply($r->dim($x2)->values, [4, 3, 2]);
  }

  # get 3-dimention - all values 2
  {
    my $x1 = $r->array($r->c(map { $_ * 2 } (1 .. 24)), $r->c(4, 3, 2));
    my $x2 = $x1->get($r->c(1, 2, 3, 4), $r->c(1, 2, 3), $r->c(1, 2));
    is_deeply($x2->values, [map { $_ * 2 } (1 .. 24)]);
    is_deeply($r->dim($x2)->values, [4, 3, 2]);
  }
  
  # get 3-dimention - some values
  {
    my $x1 = $r->array($r->C('1:24'), $r->c(4, 3, 2));
    my $x2 = $x1->get($r->c(2, 3), $r->c(1, 3), $r->c(1, 2));
    is_deeply($x2->values, [2, 3, 10, 11, 14, 15, 22, 23]);
    is_deeply($r->dim($x2)->values, [2, 2, 2]);
  }
}

