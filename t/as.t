use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats;

my $r = Rstats->new;

# as->integer
{
  # as->integer - $r->Inf
  {
    my $x1 = $r->Inf;
    my $x2 = $r->as->integer($x1);
    ok($r->is->integer($x2));
    is_deeply($x2->values, [undef]);
  }
  # as->integer - NULL
  {
    my $x1 = $r->NULL;
    my $x2 = $r->as->integer($x1);
    ok($r->is->integer($x2));
    is_deeply($x2->values, []);
  }
  
  # as->integer - dim
  {
    my $x1 = $r->array($r->c(1, 2));
    my $x2 = $r->as->integer($x1);
    is_deeply($x2->dim->values, [2]);
  }

  # as->integer - double,NaN
  {
    my $x1 = $r->NaN;
    my $x2 = $r->as->integer($x1);
    ok($r->is->integer($x2));
    is_deeply($x2->values, [undef]);
  }
  
  # as->integer - error
  {
    my $x1 = $r->c("a");
    my $x2 = $r->as->integer($x1);
    ok($r->is->integer($x2));
    is($x2->values->[0], undef);
  }
  
  # as->integer - double
  {
    my $x1 = $r->c(1.1);
    my $x2 = $r->as->integer($x1);
    ok($r->is->integer($x2));
    is($x2->values->[0], 1);
  }
  
  # as->integer - integer
  {
    my $x1 = $r->c(1);
    my $x2 = $r->as->integer($r->as->integer($x1));
    ok($r->is->integer($x2));
    is($x2->values->[0], 1);
  }
}

# as->double
{
  # as->double - error
  {
    my $x1 = $r->array("a");
    my $x2 = $r->as->double($x1);
    ok($r->is->double($x2));
    is($x2->values->[0], undef);
  }
  
  # as->double - NULL
  {
    my $x1 = $r->NULL;
    my $x2 = $r->as->double($x1);
    ok($r->is->double($x2));
    is_deeply($x2->values, []);
  }

  # as->double - dim
  {
    my $x1 = $r->array($r->c(1.1, 1.2));
    my $x2 = $r->as->double($x1);
    is_deeply($x2->dim->values, [2]);
  }
  
  # as->double - $r->Inf
  {
    my $x1 = $r->Inf;
    my $x2 = $r->as->double($x1);
    ok($r->is->double($x2));
    is_deeply($x2->values, ['Inf']);
  }

  # as->double - NaN
  {
    my $x1 = $r->NaN;
    my $x2 = $r->as->double($x1);
    ok($r->is->double($x2));
    is_deeply($x2->values, ['NaN']);
  }

  # as->double - double
  {
    my $x1 = $r->array(1.1);
    my $x2 = $r->as->double($x1);
    ok($r->is->double($x2));
    is($x2->values->[0], 1.1);
  }
  
  # as->double - integer
  {
    my $x1 = $r->array(1);
    my $x2 = $r->as->double($r->as->integer($x1));
    ok($r->is->double($x2));
    is($x2->values->[0], 1);
  }
}

# as->numeric
{
  # as->numeric - from integer
  {
    my $x1 = $r->c(0, 1, 2);
    $r->mode($x1 => 'integer');
    my $x2 = $r->as->numeric($x1);
    is($r->mode($x2)->value, 'numeric');
    is_deeply($x2->values, [0, 1, 2]);
  }
  
  # as->numeric - from numeric
  {
    my $x1 = $r->c(0.1, 1.1, 2.2);
    $r->mode($x1 => 'numeric');
    my $x2 = $r->as->numeric($x1);
    is($r->mode($x2)->value, 'numeric');
    is_deeply($x2->values, [0.1, 1.1, 2.2]);
  }
}

# is_*
{
  # is_* - is_array
  {
    my $x = $r->array($r->C('1:24'), $r->c(4, 3, 2));
    ok($r->is->array($x));
    ok(!$r->is->vector($x));
    ok(!$r->is->matrix($x));
  }

  # is_* - is_matrix
  {
    my $x = $r->matrix($r->C('1:12'), 4, 3);
    ok($r->is->matrix($x));
    ok($r->is->array($x));
  }

  # is_* - is_vector
  {
    my $x = $r->C('1:24');
    ok($r->is->vector($x));
    ok(!$r->is->array($x));
  }

  # is_* - is_vector
  {
    my $x = $r->array($r->C('1:24'));
    ok(!$r->is->vector($x));
    ok($r->is->array($x));
  }
}

# array decide type
{
  # array decide type - numerci
  {
    my $x1 = $r->array($r->c(1, 2));
    is_deeply($x1->values, [1, 2]);
    ok($r->is->numeric($x1));
  }
  
  # array decide type - $r->Inf
  {
    my $x1 = $r->Inf;
    is_deeply($x1->values, ['Inf']);
    ok($r->is->numeric($x1));
  }

  # array decide type - NaN
  {
    my $x1 = $r->NaN;
    is_deeply($x1->values, ['NaN']);
    ok($r->is->numeric($x1));
  }
}

# as->vector
{
  my $x = $r->array($r->C('1:24'), $r->c(4, 3, 2));
  is_deeply($r->as->vector($x)->values, [1 .. 24]);
  is_deeply($r->dim($r->as->vector($x))->values, []);
}

# as->matrix
{
  # as->matrix - from vector
  {
    my $x = $r->c($r->C('1:24'));
    is_deeply($r->as->matrix($x)->values, [1 .. 24]);
    is_deeply($r->dim($r->as->matrix($x))->values, [24, 1]);
  }

  # as->matrix - from $r->matrix
  {
    my $x = $r->matrix($r->C('1:12'), 4, 3);
    is_deeply($r->as->matrix($x)->values, [1 .. 12]);
    is_deeply($r->dim($r->as->matrix($x))->values, [4, 3]);
  }

  # as->matrix - from $r->array
  {
    my $x = $r->array($r->C('1:24'), $r->c(4, 3, 2));
    is_deeply($r->as->matrix($x)->values, [1 .. 24]);
    is_deeply($r->dim($r->as->matrix($x))->values, [24, 1]);
  }
}

# as->array
{
  # as->array - from vector
  {
    my $x1 = $r->C('1:24');
    my $x2 = $r->as->array($x1);
    is_deeply($x2->values, [1 .. 24]);
    is_deeply($r->dim($x2)->values, [24]);
  }

  # as->array - from $r->array
  {
    my $x1 = $r->array($r->C('1:24'), $r->c(4, 3, 2));
    my $x2 = $r->as->array($x1);
    is_deeply($x2->values, [1 .. 24]);
    is_deeply($r->dim($x2)->values, [4, 3, 2]);
  }
}

