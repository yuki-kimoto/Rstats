use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use POSIX();
use Rstats;

my $r = Rstats->new;

# pow
{
  # pow - dim
  {
    my $x1 = $r->array($r->c(5), 2);
    my $x2 = $r->array($r->c(2), 2);
    my $x3 = $x1 ** $x2;
    ok($r->is->double($x3));
    ok($r->dim($x3)->values, [2]);
    is_deeply($x3->values, [25, 25]);
  }
  
  # pow - double
  {
    my $x1 = $r->c(5);
    my $x2 = $r->c(2);
    my $x3 = $x1 ** $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, [25]);
  }

  # pow - integer
  {
    my $x1 = $r->as->integer($r->c(5));
    my $x2 = $r->as->integer($r->c(2));
    my $x3 = $x1 ** $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, [25]);
  }

  # pow - $r->NULL, left
  {
    my $x1 = $r->NULL;
    my $x2 = $r->c(1);
    my $x3 = $x1 ** $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, []);
  }

  # pow - $r->NULL, right
  {
    my $x1 = $r->c(1);
    my $x2 = $r->NULL;
    my $x3 = $x1 ** $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, []);
  }
  
  # pow - different number elements
  {
    my $x1 = $r->c(5, 3);
    my $x2 = $r->c(2, 2, 3, 1);
    my $x3 = $x1 ** $x2;
    is_deeply($x3->values, [25, 9, 125, 3]);
  }

  # pow - perl number
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = $x1 ** 2;
    is_deeply($x2->values, [1, 4, 9]);
  }

  # pow - perl number,reverse
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = 2 ** $x1;
    is_deeply($x2->values, [2, 4, 8]);
  }
}

# add
{
  # add - double
  {
    my $x1 = $r->c(1);
    my $x2 = $r->c(2);
    my $x3 = $x1 + $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, [3]);
  }

  # add - integer
  {
    my $x1 = $r->as->integer($r->c(1));
    my $x2 = $r->as->integer($r->c(2));
    my $x3 = $x1 + $x2;
    ok($r->is->integer($x3));
    is_deeply($x3->values, [3]);
  }

  # add - $r->NULL, left
  {
    my $x1 = $r->NULL;
    my $x2 = $r->c(1);
    my $x3 = $x1 + $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, []);
  }

  # add - $r->NULL, right
  {
    my $x1 = $r->c(1);
    my $x2 = $r->NULL;
    my $x3 = $x1 + $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, []);
  }
      
  # add - different number elements
  {
    my $x1 = $r->c(1, 2);
    my $x2 = $r->c(3, 4, 5, 6);
    my $x3 = $x1 + $x2;
    is_deeply($x3->values, [4, 6, 6, 8]);
  }

  # add - perl number
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = $x1 + 1;
    is_deeply($x2->values, [2, 3, 4]);
  }

  # add - perl number,reverse
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = 1 + $x1;
    is_deeply($x2->values, [2, 3, 4]);
  }
}

# subtract
{
  # subtract - dim
  {
    my $x1 = $r->array($r->c(1), 2);
    my $x2 = $r->array($r->c(2), 2);
    my $x3 = $x1 - $x2;
    ok($r->is->double($x3));
    ok($r->dim($x3)->values, [2]);
    is_deeply($x3->values, [-1, -1]);
  }
  
  # subtract - double
  {
    my $x1 = $r->c(1);
    my $x2 = $r->c(2);
    my $x3 = $x1 - $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, [-1]);
  }

  # subtract - integer
  {
    my $x1 = $r->as->integer($r->c(1));
    my $x2 = $r->as->integer($r->c(2));
    my $x3 = $x1 - $x2;
    ok($r->is->integer($x3));
    is_deeply($x3->values, [-1]);
  }

  # subtract - $r->NULL, left
  {
    my $x1 = $r->NULL;
    my $x2 = $r->c(1);
    my $x3 = $x1 - $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, []);
  }

  # subtract - $r->NULL, right
  {
    my $x1 = $r->c(1);
    my $x2 = $r->NULL;
    my $x3 = $x1 - $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, []);
  }
      
  # subtract - different number elements
  {
    my $x1 = $r->c(1, 2);
    my $x2 = $r->c(3, 4, 5, 6);
    my $x3 = $x1 - $x2;
    is_deeply($x3->values, [-2, -2, -4, -4]);
  }

  # subtract - perl number
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = $x1 - 1;
    is_deeply($x2->values, [0, 1, 2]);
  }

  # subtract - perl number,reverse
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = 1 - $x1;
    is_deeply($x2->values, [0, -1, -2]);
  }
}

# multiply
{
  # multiply - double
  {
    my $x1 = $r->array($r->c(3), 2);
    my $x2 = $r->array($r->c(2), 2);
    my $x3 = $x1 * $x2;
    ok($r->is->double($x3));
    ok($r->dim($x3)->values, [2]);
    is_deeply($x3->values, [6, 6]);
  }

  # multiply - double
  {
    my $x1 = $r->c(3);
    my $x2 = $r->c(2);
    my $x3 = $x1 * $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, [6]);
  }

  # multiply - integer
  {
    my $x1 = $r->as->integer($r->c(3));
    my $x2 = $r->as->integer($r->c(2));
    my $x3 = $x1 * $x2;
    ok($r->is->integer($x3));
    is_deeply($x3->values, [6]);
  }

  # multiply - $r->NULL, left
  {
    my $x1 = $r->NULL;
    my $x2 = $r->c(1);
    my $x3 = $x1 * $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, []);
  }

  # multiply - $r->NULL, right
  {
    my $x1 = $r->c(1);
    my $x2 = $r->NULL;
    my $x3 = $x1 * $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, []);
  }
  
  # multiply - different number elements
  {
    my $x1 = $r->c(1, 2);
    my $x2 = $r->c(3, 4, 5, 6);
    my $x3 = $x1 * $x2;
    is_deeply($x3->values, [3, 8, 5, 12]);
  }

  # multiply - perl number
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = $x1 * 2;
    is_deeply($x2->values, [2, 4, 6]);
  }

  # multiply - perl number,reverse
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = 2 * $x1;
    is_deeply($x2->values, [2, 4, 6]);
  }
}

# divide
{
  # divide - dim
  {
    my $x1 = $r->array($r->c(5), 2);
    my $x2 = $r->array($r->c(2), 2);
    my $x3 = $x1 / $x2;
    ok($r->is->double($x3));
    ok($r->dim($x3)->values, [2]);
    is_deeply($x3->values, [5/2, 5/2]);
  }
  
  # divide - double
  {
    my $x1 = $r->c(5);
    my $x2 = $r->c(2);
    my $x3 = $x1 / $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, [5/2]);
  }

  # divide - integer
  {
    my $x1 = $r->as->integer($r->c(5));
    my $x2 = $r->as->integer($r->c(2));
    my $x3 = $x1 / $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, [5/2]);
  }

  # divide - $r->NULL, left
  {
    my $x1 = $r->NULL;
    my $x2 = $r->c(1);
    my $x3 = $x1 / $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, []);
  }

  # divide - $r->NULL, right
  {
    my $x1 = $r->c(1);
    my $x2 = $r->NULL;
    my $x3 = $x1 / $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, []);
  }
  
  # divide - different number elements
  {
    my $x1 = $r->c(24, 12);
    my $x2 = $r->c(2, 3, 4, 6);
    my $x3 = $x1 / $x2;
    is_deeply($x3->values, [12, 4, 6, 2]);
  }

  # divide - perl number
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = $x1 / 2;
    is_deeply($x2->values, [1/2, 1, 3/2]);
  }

  # divide - perl number,reverse
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = 2 / $x1;
    is_deeply($x2->values, [2, 1, 2/3]);
  }
}

# remainder
{
  # remainder - double
  {
    my $x1 = $r->array($r->c(5), 2);
    my $x2 = $r->array($r->c(2), 2);
    my $x3 = $x1 % $x2;
    ok($r->is->double($x3));
    ok($r->dim($x3)->values, [2]);
    is_deeply($x3->values, [1, 1]);
  }

  # remainder - double
  {
    my $x1 = $r->c(5, 5, 2, 2);
    my $x2 = $r->c(2, 3, 2/5, 0);
    my $x3 = $x1 % $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, [1, 2, POSIX::fmod(2, 2/5), "NaN"]);
  }

  # remainder - integer
  {
    my $x1 = $r->as->integer($r->c(5));
    my $x2 = $r->as->integer($r->c(2));
    my $x3 = $x1 % $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, [1]);
  }

  # remainder - $r->NULL, left
  {
    my $x1 = $r->NULL;
    my $x2 = $r->c(1);
    my $x3 = $x1 % $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, []);
  }

  # remainder - $r->NULL, right
  {
    my $x1 = $r->c(1);
    my $x2 = $r->NULL;
    my $x3 = $x1 % $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, []);
  }
  
  # remainder - different number elements
  {
    my $x1 = $r->c(24, 12);
    my $x2 = $r->c(3, 5, 7, 9);
    my $x3 = $x1 % $x2;
    is_deeply($x3->values, [0, 2, 3, 3]);
  }

  # remainder - auto upgrade type
  {
    my $x1 = $r->c(5);
    my $x2 = $r->as->integer($r->c(3));
    my $x3 = $x1 % $x2;
    ok($r->is->double($x3));
    is_deeply($x3->values, [2]);
  }
  
  # remainder - perl number
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = $x1 % 2;
    is_deeply($x2->values, [1, 0, 1]);
  }

  # remainder - perl number,reverse
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = 5 % $x1;
    is_deeply($x2->values, [0, 1, 2]);
  }
}

# negate
{
  # negate - dimention
  {
    my $x1 = $r->array($r->c(1, 2, 3));
    my $x2 = -$x1;
    ok($r->is->double($x2));
    is_deeply($x2->values, [-1, -2, -3]);
    is_deeply($x2->dim->values, [3]);
  }
  
  # negate - double
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = -$x1;
    ok($r->is->double($x2));
    is_deeply($x2->values, [-1, -2, -3]);
  }

  # negate - double,NaN
  {
    my $x1 = $r->NaN;
    my $x2 = -$x1;
    ok($r->is->double($x2));
    ok($r->is->nan($x2)->value);
  }
  
  # negate - double,-Inf
  {
    my $x1 = -$r->Inf;
    my $x2 = -$x1;
    ok($r->is->double($x2));
    ok($x2->value, 'Inf');
  }

  # negate - double,Inf
  {
    my $x1 = $r->Inf;
    my $x2 = -$x1;
    ok($r->is->double($x2));
    is($x2->value, '-Inf');
  }
}

# bool
{
  {
    my $x1 = $r->array(1);
    if ($x1) {
      pass;
    }
    else {
      fail;
    }
  }
  
  # bool - one argument, false
  {
    my $x1 = $r->array(0);
    if ($x1) {
      fail;
    }
    else {
      pass;
    }
  }

  # bool - two argument, true
  {
    my $x1 = $r->array(3, 3);
    if ($x1) {
      pass;
    }
    else {
      fail;
    }
  }

  # bool - two argument, true
  {
    my $x1 = $r->NULL;
    eval {
      if ($x1) {
      
      }
    };
    like($@, qr/zero/);
  }
}

# numeric operator auto upgrade
{
  # numeric operator auto upgrade - integer
  {
    my $x1 = $r->as->integer($r->c(3, 5));
    my $x2 = $r->c($r->TRUE, $r->FALSE);
    my $x3 = $x1 + $x2;
    ok($r->is->integer($x3));
    is_deeply($x3->values, [4, 5])
  }
    
  # numeric operator auto upgrade - numeric
  {
    my $x1 = $r->array($r->c(1.1, 1.2));
    my $x2 = $r->as->integer($r->array($r->c(1, 2)));
    my $x3 = $x1 + $x2;
    ok($r->is->numeric($x3));
    is_deeply($x3->values, [2.1, 3.2])
  }
}

# numeric operator
{
  # numeric operator - -0.2 * -Inf
  {
    my $x1 = $r->c(-0.2);
    my $x2 = $r->c(-Inf);
    my $x3 = $x1 * $x2;
    is_deeply($x3->values, ['Inf']);
  }
}
