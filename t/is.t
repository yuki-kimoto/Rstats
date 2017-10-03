use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::Class;

my $r = Rstats::Class->new;

# is->nan
{
  # is->nan - NA
  {
    my $x1 = $r->NA;
    my $x2 = r->is->nan($x1);
    is_deeply($x2->values, [0]);
  }

  # is->nan - character
  {
    my $x1 = $r->c_("a");
    my $x2 = r->is->nan($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0]);
  }

  # is->nan - double
  {
    my $x1 = $r->c_(1, 2);
    my $x2 = r->is->nan($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0, 0]);
  }

  # is->nan - double,Inf
  {
    my $x1 = $r->Inf;
    my $x2 = r->is->nan($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0]);
  }
  
  # is->nan - double,-Inf
  {
    my $x1 = -$r->Inf;
    my $x2 = r->is->nan($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0]);
  }

  # is->nan - double,NaN
  {
    my $x1 = $r->NaN;
    my $x2 = r->is->nan($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [1]);
  }

  # is->nan - integer
  {
    my $x1 = r->as->integer($r->c_(1));
    my $x2 = r->is->nan($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0]);
  }

  # is->nan - logical
  {
    my $x1 = $r->TRUE;
    my $x2 = r->is->nan($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0]);
  }
  
  # is->nan - dimention
  {
    my $x1 = $r->array($r->c_(1, 2));
    my $x2 = r->is->nan($x1);
    is_deeply($x2->dim->values, [2]);
  }
  
  # is->nan - complex
  {
    my $x1 = $r->c_(1+2*$r->i, r->complex($r->NaN, 1), r->complex(1, $r->NaN));
    my $x2 = r->is->nan($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0, 1, 1]);
  }
}

# is->infinite
{
  # is->infinite - NA
  {
    my $x1 = $r->NA;
    my $x2 = r->is->infinite($x1);
    is_deeply($x2->values, [0]);
  }

  # is->infinite - character
  {
    my $x1 = $r->c_("a");
    my $x2 = r->is->infinite($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0]);
  }

  # is->infinite - complex
  {
    my $x1 = $r->c_(1+2*$r->i, r->complex($r->NaN, 1), $r->Inf + 1*$r->i, r->complex(1, $r->Inf));
    my $x2 = r->is->infinite($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0, 0, 1, 1]);
  }
    
  # is->infinite - double
  {
    my $x1 = $r->c_(1, 2);
    my $x2 = r->is->infinite($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0, 0]);
  }

  # is->infinite - double,Inf
  {
    my $x1 = $r->Inf;
    my $x2 = r->is->infinite($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [1]);
  }
  
  # is->infinite - double,-Inf
  {
    my $x1 = -$r->Inf;
    my $x2 = r->is->infinite($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [1]);
  }

  # is->infinite - double,NaN
  {
    my $x1 = $r->NaN;
    my $x2 = r->is->infinite($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0]);
  }

  # is->infinite - integer
  {
    my $x1 = r->as->integer($r->c_(1));
    my $x2 = r->is->infinite($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0]);
  }

  # is->infinite - logical
  {
    my $x1 = $r->TRUE;
    my $x2 = r->is->infinite($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0]);
  }
  
  # is->infinite - dimention
  {
    my $x1 = $r->array($r->c_(1, 2));
    my $x2 = r->is->infinite($x1);
    is_deeply($x2->dim->values, [2]);
  }
}

# is->na
{
  # is->na - dim
  {
    my $x1 = $r->array($r->c_(1.1, 1.2));
    my $x2 = r->is->na($x1);
    is_deeply($x2->dim->values, [2]);
  }
  
  # is->na - NULL
  {
    my $x1 = $r->NULL;
    my $x2 = r->is->na($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, []);
  }
  
  # is->na - character
  {
    my $x1 = $r->c_("aaa", $r->NA);
    my $x2 = r->is->na($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0, 1]);
  }
  
  # is->na - complex
  {
    my $x1 = $r->c_(1 + 2*$r->i, $r->NA);
    my $x2 = r->is->na($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0, 1]);
  }
  
  # is->na - double
  {
    my $x1 = $r->c_(1.1, $r->NA);
    my $x2 = r->is->na($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0, 1]);
  }
  
  # is->na - integer
  {
    my $x1 = r->as->integer($r->c_(1, $r->NA));
    my $x2 = r->is->na(r->as->integer($x1));
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0, 1]);
  }
  
  # is->na - logical
  {
    my $x1 = $r->c_($r->TRUE, $r->NA);
    my $x2 = r->is->na($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0, 1]);
  }
  
  # is->na - $r->list
  {
    my $x1 = $r->list(1, 2);
    my $x2 = r->is->na($x1);
    ok(r->is->logical($x2));
    is_deeply($x2->values, [0]);
  }
}

# is->integer
{
  # is->integer, as_integer, typeof - integer
  {
    my $c = $r->c_(0, 1, 2);
    ok(r->is->integer(r->as->integer($c)));
    is(r->mode(r->as->integer($c))->value, 'numeric');
    is(r->typeof(r->as->integer($c))->value, 'integer');
  }
}

# is->character
{
  # is->character, as_character, typeof - character
  {
    my $c = $r->c_(0, 1, 2);
    ok(r->is->character(r->as->character($c)));
    is(r->mode(r->as->character($c))->value, 'character');
    is(r->typeof(r->as->character($c))->value, 'character');
  }
}

# is->complex
{
  # is->complex, as_complex, typeof - complex
  {
    my $c = $r->c_(0, 1, 2);
    ok(r->is->complex(r->as->complex($c)));
    is(r->mode(r->as->complex($c))->value, 'complex');
    is(r->typeof(r->as->complex($c))->value, 'complex');
  }
}

# is->logical
{  
  # is->logical, as_logical, typeof - logical
  {
    my $x1 = $r->c_(0, 1, 2);
    my $x2 = r->as->logical($x1);
    ok(r->is->logical($x2));
    is(r->mode($x2)->value, 'logical');
    is(r->typeof($x2)->value, 'logical');
  }

  # is->logical, as_logical, typeof - NULL
  {
    my $x1 = r->NULL;
    is(r->mode($x1)->value, 'NULL');
    is(r->typeof($x1)->value, 'NULL');
  }
}

# is->vector
{
  # is->vector
  {
    my $x = $r->array($r->C('1:24'));
    ok(!r->is->vector($x));
  }
}

# is->matrix
{
  # is->matrix
  {
    my $x = $r->matrix($r->C('1:24'), 4, 3);
    ok(r->is->matrix($x));
  }
}

# is->array
{
  # is->array
  {
    
    my $x = $r->array($r->C('1:12'), $r->c_(4, 3, 2));
    ok(r->is->array($x));
  }
}

# is->finite
{
  # is->infinite - NA
  {
    my $x1 = $r->NA;
    my $x2 = r->is->finite($x1);
    is_deeply($x2->values, [0]);
  }
  
  # is->finite - Inf, false
  {
    my $x_inf = $r->Inf;
    ok(!r->is->finite($x_inf)->value);
  }
  
  # is->finite - -Inf, false
  {
    my $x1 = -$r->Inf;
    ok(!r->is->finite($x1)->value);
  }
  
  # is->finite - Double
  {
    my $x_num = $r->c_(1);
    ok(r->is->finite($x_num)->value);
  }
  
  # is->finite - logical, TRUE
  {
    my $x_num = $r->TRUE;
    ok(r->is->finite($x_num)->value);
  }
}
