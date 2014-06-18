use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Math::Trig ();
use Rstats::Array;

my $r = Rstats->new;

# which
{
  my $v1 = $r->c(['a', 'b', 'a']);
  my $v2 = $r->which($v1, sub { $_ eq 'a' });
  is_deeply($v2->values, [1, 3]);
}

# elseif
{
  my $v1 = $r->c([1, 0, 1]);
  my $v2 = $r->ifelse($v1, 'a', 'b');
  is_deeply($v2->values, ['a', 'b', 'a']);
}

# replace
{
  {
    my $v1 = $r->c('1:10');
    my $v2 = $r->c([2, 5, 10]);
    my $v3 = $r->c([12, 15, 20]);
    my $v4 = $r->replace($v1, $v2, $v3);
    is_deeply($v4->values, [1, 12, 3, 4, 15, 6, 7, 8, 9, 20]);
  }
  
  # replace - single value
  {
    my $v1 = $r->c('1:10');
    my $v2 = $r->c([2, 5, 10]);
    my $v4 = $r->replace($v1, $v2, 11);
    is_deeply($v4->values, [1, 11, 3, 4, 11, 6, 7, 8, 9, 11]);
  }
  
  # replace - few values
  {
    my $v1 = $r->c('1:10');
    my $v2 = $r->c([2, 5, 10]);
    my $v4 = $r->replace($v1, $v2, [12, 15]);
    is_deeply($v4->values, [1, 12, 3, 4, 15, 6, 7, 8, 9, 12]);
  }
}

# head
{
  {
    my $v1 = $r->c([1, 2, 3, 4, 5, 6, 7]);
    my $head = $r->head($v1);
    is_deeply($head->values, [1, 2, 3, 4, 5, 6]);
  }
  
  # head - values is low than 6
  {
    my $v1 = $r->c([1, 2, 3]);
    my $head = $r->head($v1);
    is_deeply($head->values, [1, 2, 3]);
  }
  
  # head - n option
  {
    my $v1 = $r->c([1, 2, 3, 4]);
    my $head = $r->head($v1, {n => 3});
    is_deeply($head->values, [1, 2, 3]);
  }
}

# tail
{
  {
    my $v1 = $r->c([1, 2, 3, 4, 5, 6, 7]);
    my $tail = $r->tail($v1);
    is_deeply($tail->values, [2, 3, 4, 5, 6, 7]);
  }
  
  # tail - values is low than 6
  {
    my $v1 = $r->c([1, 2, 3]);
    my $tail = $r->tail($v1);
    is_deeply($tail->values, [1, 2, 3]);
  }
  
  # tail - n option
  {
    my $v1 = $r->c([1, 2, 3, 4]);
    my $tail = $r->tail($v1, {n => 3});
    is_deeply($tail->values, [2, 3, 4]);
  }
}

# names
{
  my $v1 = $r->c([1, 2, 3, 4]);
  $r->names($v1 => $r->c(['a', 'b', 'c', 'd']));
  my $v2 = $v1->get_s($r->c(['b', 'd']));
  is_deeply($v2->values, [2, 4]);
}

# matrix
{
  my $mat = $r->matrix(0, 2, 5);
  is_deeply($mat->values, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
  my $dim = $r->dim($mat);
  is_deeply($dim->values, [2, 5]);
  is($r->type($mat), 'matrix');
}

# to_string
{
  my $array = $r->array([1, 2, 3]);
  is("$array", "[1] 1 2 3\n");
  
  my $v = $r->c([1, 2, 3]);
  $r->names($v => ['a', 'b', 'c']);
  is("$v", "a b c\n[1] 1 2 3\n");
}

# length
{
  my $array = $r->array([1, 2, 3]);
  is($r->length($array), 3);
}

=pod
# Type
{
  my $array = Rstats::Array->new(values => [1, 2, 3]);
  ok($array->is_array);
  $array->as_vector;
  ok($array->is_vector);
  $array->as_matrix;
  ok($array->is_matrix);
}
=cut

# Array get and set
{
  my $array = Rstats::Array->new(values => [1, 2, 3]);
  is_deeply($array->get(1)->values, [1]);
  is_deeply($array->get(3)->values, [3]);
  $array->set(1 => 5);;
  is_deeply($array->get(1)->values, [5]);
}

# abs
{
  my $r = Rstats->new;
  my $v1 = $r->c([3, 4]);
  my $abs = $r->abs($v1);
  is($abs, 5);
}

# paste
{
  my $r = Rstats->new;
  
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
  my $r = Rstats->new;
  
  # c($array)
  {
    my $v = $r->c([1, 2, 3]);
    is_deeply($v->values, [1, 2, 3]);
  }
  
  # c($vector)
  {
    my $v = $r->c($r->c([1, 2, 3]));
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
  my $r = Rstats->new;
  
  # req($v, {times => $times});
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $r->rep($v1, {times => 3});
    is_deeply($v2->values, [1, 2, 3, 1, 2, 3, 1, 2, 3]);
  }
}

# seq function
{
  my $r = Rstats->new;
  
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

# Method
{
  my $r = Rstats->new;
  
  # add (vector)
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $r->c([$v1, 4, 5]);
    is_deeply($v2->values, [1, 2, 3, 4, 5]);
  }
  # add (array)
  {
    my $v1 = $r->c([[1, 2], 3, 4]);
    is_deeply($v1->values, [1, 2, 3, 4]);
  }
  
  # add to original vector
  {
    my $v1 = $r->c([1, 2, 3]);
    $v1->set($r->length($v1) + 1 => 6);
    is_deeply($v1->values, [1, 2, 3, 6]);
  }
  
  # append(after option)
  {
    my $v1 = $r->c([1, 2, 3, 4, 5]);
    $r->append($v1, 1, {after => 3});
    is_deeply($v1->values, [1, 2, 3, 1, 4, 5]);
  }

  # append(no after option)
  {
    my $v1 = $r->c([1, 2, 3, 4, 5]);
    $r->append($v1, 1);
    is_deeply($v1->values, [1, 2, 3, 4, 5, 1]);
  }

  # append(array)
  {
    my $v1 = $r->c([1, 2, 3, 4, 5]);
    $r->append($v1, [6, 7]);
    is_deeply($v1->values, [1, 2, 3, 4, 5, 6, 7]);
  }

  # append(vector)
  {
    my $v1 = $r->c([1, 2, 3, 4, 5]);
    $r->append($v1, $r->c([6, 7]));
    is_deeply($v1->values, [1, 2, 3, 4, 5, 6, 7]);
  }
    
  # numeric
  {
    my $v1 = $r->numeric(3);
    is_deeply($v1->values, [0, 0, 0]);
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
