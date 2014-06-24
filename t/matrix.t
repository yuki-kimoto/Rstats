use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

my $r = Rstats->new;

# rownames and colnames
{
  {
    my $m1 = $r->matrix('1:6', 2, 3);
    $r->colnames($m1, [qw/c1 c2 c3/]);
    is_deeply($r->colnames($m1)->values, [qw/c1 c2 c3/]);
    $r->rownames($m1, [qw/r1 r2 r3/]);
    is_deeply($r->rownames($m1)->values, [qw/r1 r2 r3/]);
  }
}

# t
{
  # t - basic
  {
    my $m1 = $r->matrix('1:6', 3, 2);
    my $m2 = $r->t($m1);
    is_deeply($m2->values, [1, 4, 2, 5, 3, 6]);
    is_deeply($r->dim($m2)->values, [2, 3]);
  }
}

# matrix
{
  {
    my $m1 = $r->matrix('1:12', 3, 4);
    is_deeply($m1->values, [1 .. 12]);
    is_deeply($r->dim($m1)->values, [3, 4]);
    ok($m1->is_matrix);
  }
  
  # matrix - omit row
  {
    my $m1 = $r->matrix('1:12', 3);
    is_deeply($m1->values, [1 .. 12]);
    is_deeply($r->dim($m1)->values, [3, 4]);
    ok($m1->is_matrix);
  }
  
  # matrix - omit col
  {
    my $m1 = $r->matrix('1:12', undef, 4);
    is_deeply($m1->values, [1 .. 12]);
    is_deeply($r->dim($m1)->values, [3, 4]);
    ok($m1->is_matrix);
  }

  # matrix - omit col
  {
    my $m1 = $r->matrix('1:12');
    is_deeply($m1->values, [1 .. 12]);
    is_deeply($r->dim($m1)->values, [12, 1]);
    ok($m1->is_matrix);
  }

  # matrix - repeat
  {
    my $m1 = $r->matrix('1:3', 3, 4);
    is_deeply($m1->values, [(1 .. 3) x 4]);
    is_deeply($r->dim($m1)->values, [3, 4]);
    ok($m1->is_matrix);
  }

  # matrix - repeat 2
  {
    my $m1 = $r->matrix('1:10', 3, 4);
    is_deeply($m1->values, [1 .. 10, 1, 2]);
    is_deeply($r->dim($m1)->values, [3, 4]);
    ok($m1->is_matrix);
  }
  
  # matrix - repeat 3
  {
    my $m1 = $r->matrix(0, 3, 4);
    is_deeply($m1->values, [(0) x 12]);
    is_deeply($r->dim($m1)->values, [3, 4]);
    ok($m1->is_matrix);
  }
  
}
