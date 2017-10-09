use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats;

my $r = Rstats->new;

# is->nan
{
  # is->nan - double
  {
    my $x1 = $r->c([1, 2]);
    my $x2 = $r->is->nan($x1);
    is_deeply($x2->values, [0, 0]);
  }

  # is->nan - double,Inf
  {
    my $x1 = $r->Inf;
    my $x2 = $r->is->nan($x1);
    is_deeply($x2->values, [0]);
  }
  
  # is->nan - double,-Inf
  {
    my $x1 = $r->neg($r->Inf);
    my $x2 = $r->is->nan($x1);
    is_deeply($x2->values, [0]);
  }

  # is->nan - double,NaN
  {
    my $x1 = $r->NaN;
    my $x2 = $r->is->nan($x1);
    is_deeply($x2->values, [1]);
  }

  # is->nan - int
  {
    my $x1 = $r->as->int($r->c(1));
    my $x2 = $r->is->nan($x1);
    is_deeply($x2->values, [0]);
  }

  # is->nan - dimention
  {
    my $x1 = $r->array($r->c([1, 2]));
    my $x2 = $r->is->nan($x1);
    is_deeply($x2->dim->values, [2]);
  }
}

# is->infinite
{
  # is->infinite - double
  {
    my $x1 = $r->c([1, 2]);
    my $x2 = $r->is->infinite($x1);
    is_deeply($x2->values, [0, 0]);
  }

  # is->infinite - double,Inf
  {
    my $x1 = $r->Inf;
    my $x2 = $r->is->infinite($x1);
    is_deeply($x2->values, [1]);
  }
  
  # is->infinite - double,-Inf
  {
    my $x1 = $r->neg($r->Inf);
    my $x2 = $r->is->infinite($x1);
    is_deeply($x2->values, [1]);
  }

  # is->infinite - double,NaN
  {
    my $x1 = $r->NaN;
    my $x2 = $r->is->infinite($x1);
    is_deeply($x2->values, [0]);
  }

  # is->infinite - int
  {
    my $x1 = $r->as->int($r->c(1));
    my $x2 = $r->is->infinite($x1);
    is_deeply($x2->values, [0]);
  }

  # is->infinite - dimention
  {
    my $x1 = $r->array($r->c([1, 2]));
    my $x2 = $r->is->infinite($x1);
    is_deeply($x2->dim->values, [2]);
  }
}
# is->finite
{
  # is->finite - Inf, false
  {
    my $x_inf = $r->Inf;
    ok(!$r->is->finite($x_inf)->value);
  }
  
  # is->finite - -Inf, false
  {
    my $x1 = $r->neg($r->Inf);
    ok(!$r->is->finite($x1)->value);
  }
  
  # is->finite - Double
  {
    my $x_num = $r->c(1);
    ok($r->is->finite($x_num)->value);
  }
}
