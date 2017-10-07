use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats;

my $r = Rstats->new;

# TODO
# arr.ind=TRUE

# matrix
{
  
  # matrix - $r->matrix(2, 2);
  {
    my $x1 = $r->matrix($r->c(2), $r->c(2));
    is_deeply($x1->values, [2, 2]);
    is_deeply($x1->dim->values, [2, 1]);
  }
  
  # matrix - byrow
  {
    my $m1 = $r->matrix($r->C('1:12'), $r->c(3), $r->c(4), {byrow => $r->c(1)});
    is_deeply($m1->values, [(1, 5, 9), (2, 6, 10), (3, 7,11), (4, 8, 12)]);
    is_deeply($r->dim($m1)->values, [3, 4]);
    ok($r->is->matrix($m1));
  }

  # matrix - basic
  {
    my $m1 = $r->matrix($r->C('1:12'), $r->c(3), $r->c(4));
    is_deeply($m1->values, [1 .. 12]);
    is_deeply($r->dim($m1)->values, [3, 4]);
    ok($r->is->matrix($m1));
  }
  
  # matrix - omit row
  {
    my $m1 = $r->matrix($r->C('1:12'), $r->c(3));
    is_deeply($m1->values, [1 .. 12]);
    is_deeply($r->dim($m1)->values, [3, 4]);
    ok($r->is->matrix($m1));
  }
  
  # matrix - omit col
  {
    my $m1 = $r->matrix($r->C('1:12'));
    is_deeply($m1->values, [1 .. 12]);
    is_deeply($r->dim($m1)->values, [12, 1]);
    ok($r->is->matrix($m1));
  }

  # matrix - nrow and ncol option
  {
    my $m1 = $r->matrix($r->C('1:12'), {nrow => $r->c(4), ncol => $r->c(3)});
    is_deeply($m1->values, [1 .. 12]);
    is_deeply($r->dim($m1)->values, [4, 3]);
    ok($r->is->matrix($m1));
  }
  
  # matrix - repeat
  {
    my $m1 = $r->matrix($r->C('1:3'), $r->c(3), $r->c(4));
    is_deeply($m1->values, [(1 .. 3) x 4]);
    is_deeply($r->dim($m1)->values, [3, 4]);
    ok($r->is->matrix($m1));
  }

  # matrix - repeat 2
  {
    my $m1 = $r->matrix($r->C('1:10'), $r->c(3), $r->c(4));
    is_deeply($m1->values, [1 .. 10, 1, 2]);
    is_deeply($r->dim($m1)->values, [3, 4]);
    ok($r->is->matrix($m1));
  }
  
  # matrix - repeat 3
  {
    my $m1 = $r->matrix($r->c(0), $r->c(3), $r->c(4));
    is_deeply($m1->values, [(0) x 12]);
    is_deeply($r->dim($m1)->values, [3, 4]);
    ok($r->is->matrix($m1));
  }
}

# upper_tri
{
  # upper_tri - basic
  {
    my $x1 = $r->matrix($r->C('1:12'), $r->c(3), $r->c(4));
    my $x2 = $r->lower_tri($x1);
    is_deeply($x2->values, [
      0,
      1,
      1,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      0
    ]);
    is_deeply($r->dim($x2)->values, [3, 4]);
  }

  # upper_tri - diag = TRUE
  {
    my $x1 = $r->matrix($r->C('1:12'), $r->c(3), $r->c(4));
    my $x2 = $r->lower_tri($x1, {diag => $r->TRUE});
    is_deeply($x2->values, [
      1,
      1,
      1,
      0,
      1,
      1,
      0,
      0,
      1,
      0,
      0,
      0
    ]);
    is_deeply($r->dim($x2)->values, [3, 4]);
  }
}

# upper_tri
{
  # upper_tri - basic
  {
    my $x1 = $r->matrix($r->C('1:12'), $r->c(3), $r->c(4));
    my $x2 = $r->upper_tri($x1);
    is_deeply($x2->values, [
      0,
      0,
      0,
      1,
      0,
      0,
      1,
      1,
      0,
      1,
      1,
      1
    ]);
    is_deeply($r->dim($x2)->values, [3, 4]);
  }

  # upper_tri - diag = TRUE
  {
    my $x1 = $r->matrix($r->C('1:12'), $r->c(3), $r->c(4));
    my $x2 = $r->upper_tri($x1, {diag => $r->TRUE});
    is_deeply($x2->values, [
      1,
      0,
      0,
      1,
      1,
      0,
      1,
      1,
      1,
      1,
      1,
      1
    ]);
    is_deeply($r->dim($x2)->values, [3, 4]);
  }
}

# t
{
  # t - basic
  {
    my $m1 = $r->matrix($r->C('1:6'), $r->c(3), $r->c(2));
    my $m2 = $r->t($m1);
    is_deeply($m2->values, [1, 4, 2, 5, 3, 6]);
    is_deeply($r->dim($m2)->values, [2, 3]);
  }
}

# rowSums
{
  my $m1 = $r->matrix($r->C('1:12'), $r->c(4), $r->c(3));
  my $v1 = $r->rowSums($m1);
  is_deeply($v1->values,[10, 26, 42]);
  ok(!defined $r->dim($v1));
}

# rowMeans
{
  my $m1 = $r->matrix($r->C('1:12'), $r->c(4), $r->c(3));
  my $v1 = $r->rowMeans($m1);
  is_deeply($v1->values,[10/4, 26/4, 42/4]);
  ok(!defined $r->dim($v1));
}

# colSums
{
  my $m1 = $r->matrix($r->C('1:12'), $r->c(4), $r->c(3));
  my $v1 = $r->colSums($m1);
  is_deeply($v1->values,[15, 18, 21, 24]);
  ok(!defined $r->dim($v1));
}

# colMeans
{
  my $m1 = $r->matrix($r->C('1:12'), $r->c(4), $r->c(3));
  my $v1 = $r->colMeans($m1);
  is_deeply($v1->values,[15/3, 18/3, 21/3, 24/3]);
  ok(!defined $r->dim($v1));
}

# row
{
  my $m1 = $r->matrix($r->C('1:12'), $r->c(3), $r->c(4));
  my $m2 = $r->row($m1);
  is_deeply($m2->values,[1,2,3,1,2,3,1,2,3,1,2,3]);
  is_deeply($r->dim($m2)->values, [3, 4]);
}

# col
{
  my $m1 = $r->matrix($r->C('1:12'), $r->c(3), $r->c(4));
  my $m2 = $r->col($m1);
  is_deeply($m2->values,[1,1,1,2,2,2,3,3,3,4,4,4]);
  is_deeply($r->dim($m2)->values, [3, 4]);
}

# nrow and ncol
{
  my $m1 = $r->matrix($r->C('1:12'), $r->c(3), $r->c(4));
  is_deeply($r->nrow($m1)->values, [3]);
  is_deeply($r->ncol($m1)->values, [4]);
}

# cbind
{
  my $m1 = $r->cbind(
    $r->c(1, 2, 3, 4),
    $r->c(5, 6, 7, 8),
    $r->c(9, 10, 11, 12)
  );
  is_deeply($m1->values, [1 .. 12]);
  is_deeply($r->dim($m1)->values, [4, 3]);
}

# rbind
{
  my $m1 = $r->rbind(
    $r->c(1, 2, 3, 4),
    $r->c(5, 6, 7, 8),
    $r->c(9, 10, 11, 12)
  );
  is_deeply($m1->values, [1, 5, 9, 2, 6, 10, 3, 7, 11, 4, 8, 12]);
  is_deeply($r->dim($m1)->values, [3, 4]);
}
