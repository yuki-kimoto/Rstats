use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats;

my $r = Rstats->new;

# is->nan
{
  # is->nan - character
  {
    my $x1 = $r->c("a");
    my $x2 = $r->is->nan($x1);
    is_deeply($x2->values, [0]);
  }

  # is->nan - double
  {
    my $x1 = $r->c(1, 2);
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
    my $x1 = -$r->Inf;
    my $x2 = $r->is->nan($x1);
    is_deeply($x2->values, [0]);
  }

  # is->nan - double,NaN
  {
    my $x1 = $r->NaN;
    my $x2 = $r->is->nan($x1);
    is_deeply($x2->values, [1]);
  }

  # is->nan - integer
  {
    my $x1 = $r->as->integer($r->c(1));
    my $x2 = $r->is->nan($x1);
    is_deeply($x2->values, [0]);
  }

  # is->nan - dimention
  {
    my $x1 = $r->array($r->c(1, 2));
    my $x2 = $r->is->nan($x1);
    is_deeply($x2->dim->values, [2]);
  }
}

# is->infinite
{
  # is->infinite - character
  {
    my $x1 = $r->c("a");
    my $x2 = $r->is->infinite($x1);
    is_deeply($x2->values, [0]);
  }

  # is->infinite - double
  {
    my $x1 = $r->c(1, 2);
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
    my $x1 = -$r->Inf;
    my $x2 = $r->is->infinite($x1);
    is_deeply($x2->values, [1]);
  }

  # is->infinite - double,NaN
  {
    my $x1 = $r->NaN;
    my $x2 = $r->is->infinite($x1);
    is_deeply($x2->values, [0]);
  }

  # is->infinite - integer
  {
    my $x1 = $r->as->integer($r->c(1));
    my $x2 = $r->is->infinite($x1);
    is_deeply($x2->values, [0]);
  }

  # is->infinite - dimention
  {
    my $x1 = $r->array($r->c(1, 2));
    my $x2 = $r->is->infinite($x1);
    is_deeply($x2->dim->values, [2]);
  }
}

# is->integer
{
  # is->integer, as_integer, typeof - integer
  {
    my $c = $r->c(0, 1, 2);
    ok($r->is->integer($r->as->integer($c)));
    is($r->mode($r->as->integer($c))->value, 'numeric');
    is($r->typeof($r->as->integer($c))->value, 'integer');
  }
}

# is->character
{
  # is->character, as_character, typeof - character
  {
    my $c = $r->c(0, 1, 2);
    ok($r->is->character($r->as->character($c)));
    is($r->mode($r->as->character($c))->value, 'character');
    is($r->typeof($r->as->character($c))->value, 'character');
  }
}
# is->vector
{
  # is->vector
  {
    my $x = $r->array($r->C('1:24'));
    ok(!$r->is->vector($x));
  }
}

# is->matrix
{
  # is->matrix
  {
    my $x = $r->matrix($r->C('1:24'), 4, 3);
    ok($r->is->matrix($x));
  }
}

# is->array
{
  # is->array
  {
    
    my $x = $r->array($r->C('1:12'), $r->c(4, 3, 2));
    ok($r->is->array($x));
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
    my $x1 = -$r->Inf;
    ok(!$r->is->finite($x1)->value);
  }
  
  # is->finite - Double
  {
    my $x_num = $r->c(1);
    ok($r->is->finite($x_num)->value);
  }
}
