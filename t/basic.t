use Test::More 'no_plan';
use strict;
use warnings;

use Data::R;
use Math::Trig ();
use Data::R::Complex;
use Data::R::Array;

# Array
{
  my $array = Data::R::Array->new(values => [1, 2, 3]);
  is($array->get(1), 1);
  is($array->get(3), 3);
  $array->set(1 => 5);;
  is($array->get(1), 5);
}

# abs
{
  my $r = Data::R->new;
  my $v1 = $r->c([3, 4]);
  my $abs = $r->abs($v1);
  is($abs, 5);
}

# grep
{
  my $r = Data::R->new;
  
  # callback
  {
    my $v1 = Data::R::Vector->new(values => [1, 2, 3, 4]);
    my $v2 = $v1->grep(sub { $_[0] % 2 == 0 });
    is_deeply($v2->values, [2, 4]);
  }
  
  # names
  {
    my $v1 = Data::R::Vector->new(values => [1, 2, 3, 4]);
    $v1->names($r->c(['a', 'b', 'c', 'd']));
    my $v2 = $v1->grep($r->c(['b', 'd']));
    is_deeply($v2->values, [2, 4]);
  }
}

# paste
{
  my $r = Data::R->new;
  
  # paste($str, $vector);
  {
    my $v = $r->paste('x', $r->c('1:3'));
    is_deeply($v->values, ['x 1', 'x 2', 'x 3']);
  }
  # paste($str, $vector, {sep => ''});
  {
    my $v = $r->paste('x', $r->c('1:3'), {sep => ''});
    is_deeply($v->values, ['x1', 'x2', 'x3']);
  }
}

# c
{
  my $r = Data::R->new;
  
  # c($array)
  {
    my $v = $r->c([1, 2, 3]);
    is_deeply($v->values, [1, 2, 3]);
  }
  
  # c($vector)
  {
    my $v = $r->c(Data::R::Vector->new(values => [1, 2, 3]));
    is_deeply($v->values, [1, 2, 3]);
  }
  
  # c('1:3')
  {
    my $v = $r->c('1:3');
    is_deeply($v->values, [1, 2, 3]);
  }
  
  # c('0.5*1:3')
  {
    my $v = $r->c('0.5*1:3');
    is_deeply($v->values, [1, 1.5, 2, 2.5, 3]);
  }
}

# rep function
{
  my $r = Data::R->new;
  
  # req($v, {times => $times});
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $r->rep($v1, {times => 3});
    is_deeply($v2->values, [1, 2, 3, 1, 2, 3, 1, 2, 3]);
  }
}

# seq function
{
  my $r = Data::R->new;
  
  # seq($from, $to),  n > m
  {
    my $v = $r->seq(1, 3);
    is_deeply($v->values, [1, 2, 3]);
  }

  # seq({from => $from, to => $to}),  n > m
  {
    my $v = $r->seq({from => 1, to => 3});
    is_deeply($v->values, [1, 2, 3]);
  }
  
  # seq($from, $to),  n < m
  {
    my $v = $r->seq(3, 1);
    is_deeply($v->values, [3, 2, 1]);
  }
  
  # seq($from, $to), n = m
  {
    my $v = $r->seq(2, 2);
    is_deeply($v->values, [2]);
  }
  
  # seq($from, $to, {by => p}) n > m
  {
    my $v = $r->seq(1, 3, {by => 0.5});
    is_deeply($v->values, [1, 1.5, 2.0, 2.5, 3.0]);
  }

  # seq($from, $to, {by => p}) n > m
  {
    my $v = $r->seq(3, 1, {by => -0.5});
    is_deeply($v->values, [3.0, 2.5, 2.0, 1.5, 1.0]);
  }
  
  # seq($from, {by => p, length => l})
  {
    my $v = $r->seq(1, {by => 0.5, length => 3});
    is_deeply($v->values, [1, 1.5, 2.0]);
  }
}

# Vector
{
  my $r = Data::R->new;

  # negation
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = -$v1;
    is_deeply($v2->values, [-1, -2, -3]);
  }
  
  # add
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $r->c([2, 3, 4]);
    my $v3 = $v1 + $v2;
    is_deeply($v3->values, [3, 5, 7]);
  }
  
  # add(real number)
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $v1 + 1;
    is_deeply($v2->values, [2, 3, 4]);
  }
  
  # subtract
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $r->c([3, 3, 3]);
    my $v3 = $v1 - $v2;
    is_deeply($v3->values, [-2, -1, 0]);
  }

  # subtract(real number)
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $v1 - 1;
    is_deeply($v2->values, [0, 1, 2]);
  }

  # subtract(real number, reverse)
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = 1 - $v1;
    is_deeply($v2->values, [0, -1, -2]);
  }
    
  # mutiply
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $r->c([2, 3, 4]);
    my $v3 = $v1 * $v2;
    is_deeply($v3->values, [2, 6, 12]);
  }

  # mutiply(real number)
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $v1 * 2;
    is_deeply($v2->values, [2, 4, 6]);
  }
  
  # divide
  {
    my $v1 = $r->c([6, 3, 12]);
    my $v2 = $r->c([2, 3, 4]);
    my $v3 = $v1 / $v2;
    is_deeply($v3->values, [3, 1, 3]);
  }

  # divide(real number)
  {
    my $v1 = $r->c([2, 4, 6]);
    my $v2 = $v1 / 2;
    is_deeply($v2->values, [1, 2, 3]);
  }

  # divide(real number, reverse)
  {
    my $v1 = $r->c([2, 4, 6]);
    my $v2 = 2 / $v1;
    is_deeply($v2->values, [1, 1/2, 1/3]);
  }
  
  # raise
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $v1 ** 2;
    is_deeply($v2->values, [1, 4, 9]);
  }

  # max
  {
    my $v = $r->c([1, 2, 3]);
    my $max = $r->max($v);
    is($max, 3);
  }
  
  # max - multiple vectors
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $r->c([4, 5, 6]);
    my $max = $r->max($v1, $v2);
    is($max, 6);
  }
  
  # min
  {
    my $v = $r->c([1, 2, 3]);
    my $min = $r->min($v);
    is($min, 1);
  }
  
  # pmax
  {
    my $v1 = $r->c([1, 6, 3, 8]);
    my $v2 = $r->c([5, 2, 7, 4]);
    my $pmax = $r->pmax($v1, $v2);
    is_deeply($pmax->values, [5, 6, 7, 8]);
  }

  # min - multiple vectors
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $r->c([4, 5, 6]);
    my $min = $r->min($v1, $v2);
    is($min, 1);
  }
  
  # pmin
  {
    my $v1 = $r->c([1, 6, 3, 8]);
    my $v2 = $r->c([5, 2, 7, 4]);
    my $pmin = $r->pmin($v1, $v2);
    is_deeply($pmin->values, [1, 2, 3, 4]);
  }
  
  # log
  {
    my $v1 = $r->c([2, 3, 4]);
    my $v2 = $r->log($v1);
    is_deeply(
      $v2->values,
      [
        log $v1->values->[0],
        log $v1->values->[1],
        log $v1->values->[2]
      ]
    );
  }

  # exp
  {
    my $v1 = $r->c([2, 3, 4]);
    my $v2 = $r->exp($v1);
    is_deeply(
      $v2->values,
      [
        exp $v1->values->[0],
        exp $v1->values->[1],
        exp $v1->values->[2]
      ]
    );
  }

  # sin
  {
    my $v1 = $r->c([2, 3, 4]);
    my $v2 = $r->sin($v1);
    is_deeply(
      $v2->values,
      [
        sin $v1->values->[0],
        sin $v1->values->[1],
        sin $v1->values->[2]
      ]
    );
  }

  # cos
  {
    my $v1 = $r->c([2, 3, 4]);
    my $v2 = $r->cos($v1);
    is_deeply(
      $v2->values,
      [
        cos $v1->values->[0],
        cos $v1->values->[1],
        cos $v1->values->[2]
      ]
    );
  }

  # tan
  {
    my $v1 = $r->c([2, 3, 4]);
    my $v2 = $r->tan($v1);
    is_deeply(
      $v2->values,
      [
        Math::Trig::tan($v1->values->[0]),
        Math::Trig::tan($v1->values->[1]),
        Math::Trig::tan($v1->values->[2])
      ]
    );
  }

  # sqrt
  {
    my $v1 = $r->c([2, 3, 4]);
    my $v2 = $r->sqrt($v1);
    is_deeply(
      $v2->values,
      [
        sqrt $v1->values->[0],
        sqrt $v1->values->[1],
        sqrt $v1->values->[2]
      ]
    );
  }
  
  # range
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $r->range($v1);
    is_deeply($v2->values, [1, 3]);
  }
  
  # length
  {
    my $v1 = $r->c([1, 2, 4]);
    my $length = $r->length($v1);
    is($length, 3);
  }

  # sum
  {
    my $v1 = $r->c([1, 2, 3]);
    my $sum = $r->sum($v1);
    is($sum, 6);
  }

  # prod
  {
    my $v1 = $r->c([2, 3, 4]);
    my $prod = $r->prod($v1);
    is($prod, 24);
  }
  
  # mean
  {
    my $v1 = $r->c([1, 2, 3]);
    my $mean = $r->mean($v1);
    is($mean, 2);
  }

  # var
  {
    my $v1 = $r->c([2, 3, 4, 7, 9]);
    my $var = $r->var($v1);
    is($var, 8.5);
  }
  
  # sort
  {
    my $v1 = $r->c([2, 1, 5]);
    my $v1_sorted = $r->sort($v1);
    is_deeply($v1_sorted->values, [1, 2, 5]);
  }
}

# Complex
{
  my $r = Data::R->new;

  # new
  {
    my $z1 = Data::R::Complex->make(1, 2);
    is($z1->re, 1);
    is($z1->im, 2);
  }
  
  # negation
  {
    my $z1 = Data::R::Complex->make(1, 2);
    my $z2 = - $z1;
    is($z2->re, -1);
    is($z2->im, -2);
  }
  
  # add
  {
    my $z1 = Data::R::Complex->make(1, 2);
    my $z2 = Data::R::Complex->make(3, 4);
    my $z3 = $z1 + $z2;
    is($z3->re, 4);
    is($z3->im, 6);
  }
  
  # add(real number)
  {
    my $z1 = Data::R::Complex->make(1, 2);
    my $z2 = $z1 + 3;
    is($z2->re, 4);
    is($z2->im, 2);
  }

  # subtract
  {
    my $z1 = Data::R::Complex->make(1, 2);
    my $z2 = Data::R::Complex->make(3, 4);
    my $z3 = $z1 - $z2;
    is($z3->re, -2);
    is($z3->im, -2);
  }
  
  # subtract(real number)
  {
    my $z1 = Data::R::Complex->make(1, 2);
    my $z2 = $z1 - 3;
    is($z2->re, -2);
    is($z2->im, 2);
  }
  
  # subtract(real number, reverse)
  {
    my $z1 = Data::R::Complex->make(1, 2);
    my $z2 = 3 - $z1;
    is($z2->re, 2);
    is($z2->im, -2);
  }
  
  # multiply
  {
    my $z1 = 1 + $r->i * 2;
    my $z2 = 3 + $r->i * 4;
    my $z3 = $z1 * $z2;
    is($z3->re, -5);
    is($z3->im, 10);
  }

  # multiply(real number)
  {
    my $z1 = 1 + $r->i * 2;
    my $z2 = $z1 * 3;
    is($z2->re, 3);
    is($z2->im, 6);
  }
  
  # divide
  {
    my $z1 = 5 - $r->i * 6;
    my $z2 = 3 + $r->i * 2;
    my $z3 = $z1 / $z2;
    is($z3->re, 3/13);
    is($z3->im, -28/13);
  }

  # divide(real number)
  {
    my $z1 = 2 + $r->i * 4;
    my $z2 = $z1 / 2;
    is($z2->re, 1);
    is($z2->im, 2);
  }

  # divide(real number, reverse)
  {
    my $z1 = 3 + $r->i * 2;
    my $z2 = 5 / $z1;
    is($z2->re, 15 / 13);
    is($z2->im, -10 / 13);
  }

  # raise
  {
    my $z1 = 1 + $r->i * 2;
    my $z2 = $z1 ** 3;
    is($z2->re, -11);
    is($z2->im, -2);
  }
}
