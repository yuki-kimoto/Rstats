use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# sweep
{
  # sweep - minus, margin 1
  {
    my $x1 = array(C('1:6'), c(3, 2));
    my $x2 = r->sweep($x1, 1, c(1, 2, 3));
    is_deeply($x2->values, [qw/0 0 0 3 3 3/]);
    is_deeply($x2->dim->values, [3, 2]);
  }

  # sweep - minus, margin 2
  {
    my $x1 = array(C('1:6'), c(3, 2));
    my $x2 = r->sweep($x1, 2, c(1, 2));
    is_deeply($x2->values, [qw/0 1 2 2 3 4/]);
  }

  # sweep - minus, margin 1, 2
  {
    my $x1 = array(C('1:6'), c(3, 2));
    my $x2 = array(C('2:7'), c(3, 2));
    my $x3 = r->sweep($x1, c(1, 2), $x2);
    is_deeply($x3->values, [qw/-1 -1 -1 -1 -1 -1/]);
  }
}

# apply
{
  # apply - code reference
  {
    my $x1 = array(C('1:24'), c(4, 3, 2));
    my $x2 = r->apply($x1, 1, sub { r->sum($_[0]) });
    is_deeply($x2->values, [qw/66 72 78 84/]);
    is_deeply($x2->dim->values, []);
  }
  
  # apply - three dimention, margin 3,2
  {
    my $x1 = array(C('1:24'), c(4, 3, 2));
    my $x2 = r->apply($x1, c(3, 2), 'sum');
    is_deeply($x2->values, [qw/10 58 26 74 42 90/]);
    is_deeply($x2->dim->values, [qw/2 3/]);
  }
  
  # apply - three dimention, margin 2,3
  {
    my $x1 = array(C('1:24'), c(4, 3, 2));
    my $x2 = r->apply($x1, c(2, 3), 'sum');
    is_deeply($x2->values, [qw/10 26 42 58 74 90/]);
    is_deeply($x2->dim->values, [qw/3 2/]);
  }
  
  # apply - three dimention, margin 1, 2
  {
    my $x1 = array(C('1:24'), c(4, 3, 2));
    my $x2 = r->apply($x1, c(1, 2), 'sum');
    is_deeply($x2->values, [qw/14 16 18 20 22 24 26 28 30 32 34 36/]);
    is_deeply($x2->dim->values, [qw/4 3/]);
  }
  
  # apply - three dimention, margin 1
  {
    my $x1 = array(C('1:24'), c(4, 3, 2));
    my $x2 = r->apply($x1, 1, 'sum');
    is_deeply($x2->values, [qw/66 72 78 84/]);
    is_deeply($x2->dim->values, []);
  }

  # apply - three dimention, margin 2
  {
    my $x1 = array(C('1:24'), c(4, 3, 2));
    my $x2 = r->apply($x1, 2, 'sum');
    is_deeply($x2->values, [qw/68 100 132/]);
    is_deeply($x2->dim->values, []);
  }

  # apply - three dimention, margin 3
  {
    my $x1 = array(C('1:24'), c(4, 3, 2));
    my $x2 = r->apply($x1, 3, 'sum');
    is_deeply($x2->values, [qw/78 222/]);
    is_deeply($x2->dim->values, []);
  }
    
  # apply - two dimention, margin 1
  {
    my $x1 = matrix(C('1:6'), 2, 3);
    my $x2 = r->apply($x1, 1, 'sum');
    is_deeply($x2->values, [9, 12]);
    is_deeply($x2->dim->values, []);
  }

  # apply - two dimention, margin 2
  {
    my $x1 = matrix(C('1:6'), 2, 3);
    my $x2 = r->apply($x1, 2, 'sum');
    is_deeply($x2->values, [3, 7, 11]);
    is_deeply($x2->dim->values, []);
  }

  # apply - two dimention, margin 1, 2
  {
    my $x1 = matrix(c(1, 4, 9, 16, 25, 36), 2, 3);
    my $x2 = r->apply($x1, c(1, 2), 'sqrt');
    is_deeply($x2->values, [1, 2, 3, 4, 5, 6]);
    is_deeply($x2->dim->values, [2, 3]);
  }
}

