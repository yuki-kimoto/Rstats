use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::Func;

# negate
{
  # negate - dimention
  {
    my $x1 = array(c_(1, 2, 3));
    my $x2 = -$x1;
    ok(r->is->double($x2));
    is_deeply($x2->values, [-1, -2, -3]);
    is_deeply($x2->dim->values, [3]);
  }
  
  # negate - double
  {
    my $x1 = c_(1, 2, 3);
    my $x2 = -$x1;
    ok(r->is->double($x2));
    is_deeply($x2->values, [-1, -2, -3]);
  }

  # negate - double,NaN
  {
    my $x1 = NaN;
    my $x2 = -$x1;
    ok(r->is->double($x2));
    ok(r->is->nan($x2)->value);
  }
  
  # negate - double,-Inf
  {
    my $x1 = -Inf;
    my $x2 = -$x1;
    ok(r->is->double($x2));
    ok($x2->value, 'Inf');
  }

  # negate - double,Inf
  {
    my $x1 = Inf;
    my $x2 = -$x1;
    ok(r->is->double($x2));
    is($x2->value, '-Inf');
  }

  # negate - complex
  {
    my $x1 = c_(1 + 2*i_);
    my $x2 = -$x1;
    ok(r->is->complex($x2));
    is($x2->value->{re}, -1);
    is($x2->value->{im}, -2);
  }
  
  # negate - logical,true
  {
    my $x1 = c_(T_);
    my $x2 = -$x1;
    ok(r->is->integer($x2));
    is($x2->value, -1);
  }

  # negate - logical,false
  {
    my $x1 = c_(F_);
    my $x2 = -$x1;
    ok(r->is->integer($x2));
    is($x2->value, 0);
  }
  
  # negate - NA
  {
    my $x1 = NA;
    my $x2 = r->negate($x1);
    ok(r->is->integer($x2));
    ok(r->is->na($x2));
  }
}


# operator
{
  # operator - remainder, integer
  {
    my $x1 = r->as->integer(c_(1, 2, 3));
    my $x2 = r->as->integer(c_(2, 2, 0));
    my $x3 = $x1 % $x2;
    ok(r->is->double($x3));
    is_deeply($x3->values, [1, 0, 'NaN']);
  }
  
  # operator - remainder
  {
    my $x1 = c_(1, 2, 3);
    my $x2 = $x1 % 3;
    is_deeply($x2->values, [1, 2, 0]);
  }

  # operator - remainder, reverse
  {
    my $x1 = c_(1, 2, 3);
    my $x2 = 2 % $x1;
    is_deeply($x2->values, [0, 0, 2]);
  }
  
  # operator - add(different element number)
  {
    my $x1 = c_(1, 2);
    my $x2 = c_(3, 4, 5, 6);
    
    my $x3 = $x1 + $x2;
    is_deeply($x3->values, [4, 6, 6, 8]);
  }
  
  # operator - add
  {
    my $x1 = c_(1, 2, 3);
    my $x2 = c_(2, 3, 4);
    my $x3 = $x1 + $x2;
    is_deeply($x3->values, [3, 5, 7]);
  }

  # operator - add(real number)
  {
    my $x1 = c_(1, 2, 3);
    my $x2 = $x1 + 1;
    is_deeply($x2->values, [2, 3, 4]);
  }
  
  # operator - subtract
  {
    my $x1 = c_(1, 2, 3);
    my $x2 = c_(3, 3, 3);
    my $x3 = $x1 - $x2;
    is_deeply($x3->values, [-2, -1, 0]);
  }

  # operator - subtract(real number)
  {
    my $x1 = c_(1, 2, 3);
    my $x2 = $x1 - 1;
    is_deeply($x2->values, [0, 1, 2]);
  }

  # operator - subtract(real number, reverse)
  {
    my $x1 = c_(1, 2, 3);
    my $x2 = 1 - $x1;
    is_deeply($x2->values, [0, -1, -2]);
  }
    
  # operator - mutiply
  {
    my $x1 = c_(1, 2, 3);
    my $x2 = c_(2, 3, 4);
    my $x3 = $x1 * $x2;
    is_deeply($x3->values, [2, 6, 12]);
  }

  # operator - mutiply(real number)
  {
    my $x1 = c_(1, 2, 3);
    my $x2 = $x1 * 2;
    is_deeply($x2->values, [2, 4, 6]);
  }

  # operator - divide
  {
    my $x1 = r->as->integer(c_(6, 3, 12));
    my $x2 = r->as->integer(c_(2, 3, 4));
    my $x3 = $x1 / $x2;
    is_deeply($x3->values, [3, 1, 3]);
    ok(r->is->double($x3));
  }
  
  # operator - divide
  {
    my $x1 = c_(6, 3, 12);
    my $x2 = c_(2, 3, 4);
    my $x3 = $x1 / $x2;
    is_deeply($x3->values, [3, 1, 3]);
  }

  # operator - divide(real number)
  {
    my $x1 = c_(2, 4, 6);
    my $x2 = $x1 / 2;
    is_deeply($x2->values, [1, 2, 3]);
  }

  # operator - divide(real number, reverse)
  {
    my $x1 = c_(2, 4, 6);
    my $x2 = 2 / $x1;
    is_deeply($x2->values, [1, 1/2, 1/3]);
  }
  
  # operator - pow
  {
    my $x1 = c_(1, 2, 3);
    my $x2 = $x1 ** 2;
    is_deeply($x2->values, [1, 4, 9]);
  }

  # operator - pow, reverse
  {
    my $x1 = c_(1, 2, 3);
    my $x2 = 2 ** $x1;
    is_deeply($x2->values, [2, 4, 8]);
  }
}

# logical operator
{
  # logical operator - &
  {
    my $x1 = c_(TRUE, FALSE, TRUE, FALSE);
    my $x2 = c_(TRUE, TRUE, FALSE, FALSE);
    my $x3 = $x1 & $x2;
    my $proxy = r->is;
    ok(r->is->logical($x3));
    ok($x3->is->logical);
    ok(r->is->logical($x3));
    ok($x3->is->logical);
    ok(r->is->logical($x3));
    is_deeply($x3->values, [qw/1 0 0 0/]);
  }
  
  # logical operator - |
  {
    my $x1 = c_(TRUE, FALSE, TRUE, FALSE);
    my $x2 = c_(TRUE, TRUE, FALSE, FALSE);
    my $x3 = $x1 | $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [qw/1 1 1 0/]);
  }
}

# bool context
{
  {
    my $x1 = array(1);
    if ($x1) {
      pass;
    }
    else {
      fail;
    }
  }
  
  # bool context - one argument, false
  {
    my $x1 = array(0);
    if ($x1) {
      fail;
    }
    else {
      pass;
    }
  }

  # bool context - two argument, true
  {
    my $x1 = array(3, 3);
    if ($x1) {
      pass;
    }
    else {
      fail;
    }
  }

  # bool context - two argument, true
  {
    my $x1 = r->NULL;
    eval {
      if ($x1) {
      
      }
    };
    like($@, qr/zero/);
  }
}

# numeric operator auto upgrade
{
  # numeric operator auto upgrade - complex
  {
    my $x1 = array(c_(r->complex(1,2), r->complex(3,4)));
    my $x2 = array(c_(1, 2));
    my $x3 = $x1 + $x2;
    ok(r->is->complex($x3));
    is($x3->values->[0]->{re}, 2);
    is($x3->values->[0]->{im}, 2);
    is($x3->values->[1]->{re}, 5);
    is($x3->values->[1]->{im}, 4);
  }

  # numeric operator auto upgrade - integer
  {
    my $x1 = r->as->integer(c_(3, 5));
    my $x2 = c_(TRUE, FALSE);
    my $x3 = $x1 + $x2;
    ok(r->is->integer($x3));
    is_deeply($x3->values, [4, 5])
  }
    
  # numeric operator auto upgrade - numeric
  {
    my $x1 = array(c_(1.1, 1.2));
    my $x2 = r->as->integer(array(c_(1, 2)));
    my $x3 = $x1 + $x2;
    ok(r->is->numeric($x3));
    is_deeply($x3->values, [2.1, 3.2])
  }

  # numeric operator auto upgrade - character, +
  {
    my $x1 = array(c_("1", "2", "3"));
    my $x2 = array(c_(1, 2, 3));
    eval { my $ret = $x1 + $x2 };
    like($@, qr/non-numeric argument/);
  }

  # numeric operator auto upgrade - character, -
  {
    my $x1 = array(c_("1", "2", "3"));
    my $x2 = array(c_(1, 2, 3));
    eval { my $ret = $x1 - $x2 };
    like($@, qr/non-numeric argument/);
  }

  # numeric operator auto upgrade - character, *
  {
    my $x1 = array(c_("1", "2", "3"));
    my $x2 = array(c_(1, 2, 3));
    eval { my $ret = $x1 * $x2 };
    like($@, qr/non-numeric argument/);
  }

  # numeric operator auto upgrade - character, /
  {
    my $x1 = array(c_("1", "2", "3"));
    my $x2 = array(c_(1, 2, 3));
    eval { my $ret = $x1 / $x2 };
    like($@, qr/non-numeric argument/);
  }

  # numeric operator auto upgrade - character, ^
  {
    my $x1 = array(c_("1", "2", "3"));
    my $x2 = array(c_(1, 2, 3));
    eval { my $ret = $x1 ** $x2 };
    like($@, qr/non-numeric argument/);
  }

  # numeric operator auto upgrade - character, %
  {
    my $x1 = array(c_("1", "2", "3"));
    my $x2 = array(c_(1, 2, 3));
    eval { my $ret = $x1 % $x2 };
    like($@, qr/non-numeric argument/);
  }
}

# comparison operator
{
  # comparison operator - >
  {
    my $x1 = array(c_(0, 1, 2));
    my $x2 = array(c_(1, 1, 1));
    my $x3 = $x1 > $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [qw/0 0 1/]);
  }

  # comparison operator - >=
  {
    my $x1 = array(c_(0, 1, 2));
    my $x2 = array(c_(1, 1, 1));
    my $x3 = $x1 >= $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [qw/0 1 1/]);
  }

  # comparison operator - <
  {
    my $x1 = array(c_(0, 1, 2));
    my $x2 = array(c_(1, 1, 1));
    my $x3 = $x1 < $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [qw/1 0 0/]);
  }

  # comparison operator - <=
  {
    my $x1 = array(c_(0, 1, 2));
    my $x2 = array(c_(1, 1, 1));
    my $x3 = $x1 <= $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [qw/1 1 0/]);
  }

  # comparison operator - ==
  {
    my $x1 = array(c_(0, 1, 2));
    my $x2 = array(c_(1, 1, 1));
    my $x3 = $x1 == $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [qw/0 1 0/]);
  }

  # comparison operator - !=
  {
    my $x1 = array(c_(0, 1, 2));
    my $x2 = array(c_(1, 1, 1));
    my $x3 = $x1 != $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [qw/1 0 1/]);
  }
}

# comparison operator numeric
{

  # comparison operator numeric - <
  {
    my $x1 = array(c_(1, 2, 3));
    my $x2 = array(c_(2,1,3));
    my $x3 = $x1 < $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [1, 0, 0]);
  }

  # comparison operator numeric - <, arguments count is different
  {
    my $x1 = array(c_(1,2,3));
    my $x2 = array(c_(2));
    my $x3 = $x1 < $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [1, 0, 0]);
  }

  # comparison operator numeric - <=
  {
    my $x1 = array(c_(1,2,3));
    my $x2 = array(c_(2,1,3));
    my $x3 = $x1 <= $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [1, 0, 1]);
  }

  # comparison operator numeric - <=, arguments count is different
  {
    my $x1 = array(c_(1,2,3));
    my $x2 = array(c_(2));
    my $x3 = $x1 <= $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [1, 1, 0]);
  }

  # comparison operator numeric - >
  {
    my $x1 = array(c_(1,2,3));
    my $x2 = array(c_(2,1,3));
    my $x3 = $x1 > $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [0, 1, 0]);
  }

  # comparison operator numeric - >, arguments count is different
  {
    my $x1 = array(c_(1,2,3));
    my $x2 = array(c_(2));
    my $x3 = $x1 > $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [0, 0, 1]);
  }

  # comparison operator numeric - >=
  {
    my $x1 = array(c_(1,2,3));
    my $x2 = array(c_(2,1,3));
    my $x3 = $x1 >= $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [0, 1, 1]);
  }

  # comparison operator numeric - >=, arguments count is different
  {
    my $x1 = array(c_(1,2,3));
    my $x2 = array(c_(2));
    my $x3 = $x1 >= $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [0, 1, 1]);
  }

  # comparison operator numeric - ==
  {
    my $x1 = array(c_(1,2));
    my $x2 = array(c_(2,2));
    my $x3 = $x1 == $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [0, 1]);
  }

  # comparison operator numeric - ==, arguments count is different
  {
    my $x1 = array(c_(1,2));
    my $x2 = array(c_(2));
    my $x3 = $x1 == $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [0, 1]);
  }

  # comparison operator numeric - !=
  {
    my $x1 = array(c_(1,2));
    my $x2 = array(c_(2,2));
    my $x3 = $x1 != $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [1, 0]);
  }

  # comparison operator numeric - !=, arguments count is different
  {
    my $x1 = array(c_(1,2));
    my $x2 = array(c_(2));
    my $x3 = $x1 != $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [1, 0]);
  }
}

# numeric operator
{
  # numeric operator - -Inf + 2i
  {
    my $x2 = c_(2*i_);
    my $x1 = c_(-Inf);
    my $x3 = $x1 + $x2;
    is($x3->value->{re}, '-Inf');
    is($x3->value->{im}, 2);
  }

  # numeric operator - -0.2 * -Inf
  {
    my $x1 = c_(-0.2);
    my $x2 = c_(-Inf);
    my $x3 = $x1 * $x2;
    is_deeply($x3->values, ['Inf']);
  }
}

# comparison operator numeric
{

  # comparison operator numeric - <
  {
    my $x1 = array(c_(1,2,3));
    my $x2 = array(c_(2,1,3));
    my $x3 = $x1 < $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [1, 0, 0]);
  }
  
  # comparison operator numeric - <, arguments count is different
  {
    my $x1 = array(c_(1,2,3));
    my $x2 = array(c_(2));
    my $x3 = $x1 < $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [1, 0, 0]);
  }

  # comparison operator numeric - <=
  {
    my $x1 = array(c_(1,2,3));
    my $x2 = array(c_(2,1,3));
    my $x3 = $x1 <= $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [1, 0, 1]);
  }

  # comparison operator numeric - <=, arguments count is different
  {
    my $x1 = array(c_(1,2,3));
    my $x2 = array(c_(2));
    my $x3 = $x1 <= $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [1, 1, 0]);
  }

  # comparison operator numeric - >
  {
    my $x1 = array(c_(1,2,3));
    my $x2 = array(c_(2,1,3));
    my $x3 = $x1 > $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [0, 1, 0]);
  }

  # comparison operator numeric - >, arguments count is different
  {
    my $x1 = array(c_(1,2,3));
    my $x2 = array(c_(2));
    my $x3 = $x1 > $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [0, 0, 1]);
  }

  # comparison operator numeric - >=
  {
    my $x1 = array(c_(1,2,3));
    my $x2 = array(c_(2,1,3));
    my $x3 = $x1 >= $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [0, 1, 1]);
  }

  # comparison operator numeric - >=, arguments count is different
  {
    my $x1 = array(c_(1,2,3));
    my $x2 = array(c_(2));
    my $x3 = $x1 >= $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [0, 1, 1]);
  }

  # comparison operator numeric - ==
  {
    my $x1 = array(c_(1,2));
    my $x2 = array(c_(2,2));
    my $x3 = $x1 == $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [0, 1]);
  }

  # comparison operator numeric - ==, arguments count is different
  {
    my $x1 = array(c_(1,2));
    my $x2 = array(c_(2));
    my $x3 = $x1 == $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [0, 1]);
  }

  # comparison operator numeric - !=
  {
    my $x1 = array(c_(1,2));
    my $x2 = array(c_(2,2));
    my $x3 = $x1 != $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [1, 0]);
  }

  # comparison operator numeric - !=, arguments count is different
  {
    my $x1 = array(c_(1,2));
    my $x2 = array(c_(2));
    my $x3 = $x1 != $x2;
    ok(r->is->logical($x3));
    is_deeply($x3->values, [1, 0]);
  }
}

# inner product
{
  # inner product - inner product
  {
    my $x1 = c_(1, 2, 3);
    my $x2 = c_(4, 5, 6);
    my $x3 = $x1 x $x2;
    is_deeply($x3->values, [32]);
    is_deeply(r->dim($x3)->values, [1, 1]);
  }
  
  # innert product - size is different
  {
    my $x1 = c_(1, 2, 3);
    my $x2 = c_(4, 5);
    eval { my $x3 = $x1 x $x2 };
    like($@, qr/non-conformable/);
  }

  # innert product - size of first argument is zero
  {
    my $x1 = c_();
    my $x2 = c_(4, 5);
    eval { my $x3 = $x1 x $x2 };
    like($@, qr#requires numeric/complex matrix/vector arguments#);
  }

  # innert product - size of second argument is zero
  {
    my $x1 = c_(1, 2, 3);
    my $x2 = c_();
    eval { my $x3 = $x1 x $x2 };
    like($@, qr#requires numeric/complex matrix/vector arguments#);
  }
}