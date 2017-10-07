use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::Util;
use Math::Complex ();
use Math::Trig ();
use Rstats;

my $r = Rstats->new;

# c
{
  # $r->c($r->TRUE, $r->as->integer(2));
  {
    my $x1 = $r->c($r->TRUE, $r->as->integer(2));
    ok($r->is->integer($x1));
    is_deeply($x1->values, [1, 2]);
  }

  # $r->c(1, $r->as->integer(2));
  {
    my $x1 = $r->c(1, $r->as->integer(2));
    ok($r->is->double($x1));
    is_deeply($x1->values, [1, 2]);
  }
    
  # $r->c([1, 2, 3])
  {
    my $x1 = $r->c([1, 2, 3]);
    ok($r->is->double($x1));
    is_deeply($x1->values, [1, 2, 3]);
  }
  
  # $r->c($r->c(1, 2, 3))
  {
    my $x1 = $r->c($r->c(1, 2, 3));
    ok($r->is->double($x1));
    is_deeply($x1->values, [1, 2, 3]);
  }
  
  # $r->c(1, 2, $r->c(3, 4, 5))
  {
    my $x1 = $r->c(1, 2, $r->c(3, 4, 5));
    is_deeply($x1->values, [1, 2, 3, 4, 5]);
  }

  # c_ - append (array)
  {
    my $x1 = $r->c($r->c(1, 2), 3, 4);
    is_deeply($x1->values, [1, 2, 3, 4]);
  }
  
  # c_ - append to original vector
  {
    my $x1 = $r->c(1, 2, 3);
    $x1->at($r->length($x1)->value + 1)->set(6);
    is_deeply($x1->values, [1, 2, 3, 6]);
  }
}

# $r->C
{
  # $r->C('1:3')
  {
    my $x1 = $r->C('1:3');
    is_deeply($x1->values, [1, 2, 3]);
  }
  
  # $r->C('0.5*1:3')
  {
    my $x1 = $r->C('0.5*1:3');
    is_deeply($x1->values, [1, 1.5, 2, 2.5, 3]);
  }
}

# tail
{
  {
    my $x1 = $r->c(1, 2, 3, 4, 5, 6, 7);
    my $tail = $r->tail($x1);
    is_deeply($tail->values, [2, 3, 4, 5, 6, 7]);
  }
  
  # tail - values is low than 6
  {
    my $x1 = $r->c(1, 2, 3);
    my $tail = $r->tail($x1);
    is_deeply($tail->values, [1, 2, 3]);
  }
  
  # tail - n option
  {
    my $x1 = $r->c(1, 2, 3, 4);
    my $tail = $r->tail($x1, {n => 3});
    is_deeply($tail->values, [2, 3, 4]);
  }
}

# matrix
{
  {
    my $mat = $r->matrix(0, 2, 5);
    is_deeply($mat->values, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    is_deeply($r->dim($mat)->values, [2, 5]);
    ok($r->is->matrix($mat));
  }
  
  # matrix - repeat values
  {
    my $mat = $r->matrix($r->c(1,2), 2, 5);
    is_deeply($mat->values, [1, 2, 1, 2, 1, 2, 1, 2, 1, 2]);
    is_deeply($r->dim($mat)->values, [2, 5]);
    ok($r->is->matrix($mat));
  }
}

# rnorm
{
  my $x1 = $r->rnorm(100);
  is($r->length($x1)->value, 100);
}

# sequence
{
  my $x1 = $r->c(1, 2, 3);
  my $x2 = $r->sequence($x1);
  is_deeply($x2->values, [1, 1, 2, 1, 2, 3])
}
  
# sample
{
  {
    my $x1 = $r->C('1:100');
    my $x2 = $r->sample($x1, 50);
    is($r->length($x2)->value, 50);
    my $duplicate_h = {};
    my $duplicate;
    my $invalid_value;
    for my $x2_value (@{$x2->values}) {
      $duplicate_h->{$x2_value}++;
      $duplicate = 1 if $duplicate_h->{$x2_value} > 2;
      unless (grep { $_ eq $x2_value } (1 .. 100)) {
        $invalid_value = 1;
      }
    }
    ok(!$duplicate);
    ok(!$invalid_value);
  }
  
  # sample - replace => 0
  {
    my $x1 = $r->C('1:100');
    my $x2 = $r->sample($x1, 50, {replace => 0});
    is($r->length($x2)->value, 50);
    my $duplicate_h = {};
    my $duplicate;
    my $invalid_value;
    for my $x2_value (@{$x2->values}) {
      $duplicate_h->{$x2_value}++;
      $duplicate = 1 if $duplicate_h->{$x2_value} > 2;
      unless (grep { $_ eq $x2_value } (1 .. 100)) {
        $invalid_value = 1;
      }
    }
    ok(!$duplicate);
    ok(!$invalid_value);
  }

  # sample - replace => 0
  {
    my $x1 = $r->C('1:100');
    my $x2 = $r->sample($x1, 50, {replace => 1});
    is($r->length($x2)->value, 50);
    my $duplicate_h = {};
    my $duplicate;
    my $invalid_value;
    for my $x2_value (@{$x2->values}) {
      unless (grep { $_ eq $x2_value } (1 .. 100)) {
        $invalid_value = 1;
      }
    }
    ok(!$invalid_value);
  }
  
  # sample - replace => 0, (strict check)
  {
    my $x1 = $r->c(1);
    my $x2 = $r->sample($x1, 5, {replace => 1});
    is($r->length($x2)->value, 5);
    is_deeply($x2->values, [1, 1, 1, 1, 1]);
  }
}

# which
{
  my $x1 = $r->c(5, 7, 5);
  my $x2 = $r->which($x1, sub { $_ eq 5 });
  is_deeply($x2->values, [1, 3]);
}

# elseif
{
  my $x1 = $r->c(1, 0, 1);
  my $x2 = $r->ifelse($x1, 5, 7);
  is_deeply($x2->values, [5, 7, 5]);
}

# head
{
  {
    my $x1 = $r->c(1, 2, 3, 4, 5, 6, 7);
    my $head = $r->head($x1);
    is_deeply($head->values, [1, 2, 3, 4, 5, 6]);
  }
  
  # head - values is low than 6
  {
    my $x1 = $r->c(1, 2, 3);
    my $head = $r->head($x1);
    is_deeply($head->values, [1, 2, 3]);
  }
  
  # head - n option
  {
    my $x1 = $r->c(1, 2, 3, 4);
    my $head = $r->head($x1, {n => 3});
    is_deeply($head->values, [1, 2, 3]);
  }
}

# length
{
  my $x = $r->array($r->c(1, 2, 3));
  is($r->length($x)->value, 3);
}

# array
{
  {
    my $x = $r->array(25);
    is_deeply($x->values, [25]);
  }
  {
    my $x = $r->array($r->c(1, 2, 3));
    is_deeply($r->dim($x)->values, [3]);
  }
}

# Array get and set
{
  my $x = $r->array($r->c(1, 2, 3));
  is_deeply($x->get(1)->values, [1]);
  is_deeply($x->get(3)->values, [3]);
  $x->at(1)->set(5);;
  is_deeply($x->get(1)->values, [5]);
}

# rep function
{
  # req($v, {times => $times});
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = $r->rep($x1, {times => 3});
    is_deeply($x2->values, [1, 2, 3, 1, 2, 3, 1, 2, 3]);
  }
}

# seq function
{
  # seq($from, $to),  n > m
  {
    my $x1 = $r->seq(1, 3);
    is_deeply($x1->values, [1, 2, 3]);
  }

  # seq({from => $from, to => $to}),  n > m
  {
    my $x1 = $r->seq({from => 1, to => 3});
    is_deeply($x1->values, [1, 2, 3]);
  }
  
  # seq($from, $to),  n < m
  {
    my $x1 = $r->seq(3, 1);
    is_deeply($x1->values, [3, 2, 1]);
  }
  
  # seq($from, $to), n = m
  {
    my $x1 = $r->seq(2, 2);
    is_deeply($x1->values, [2]);
  }
  
  # seq($from, $to, {by => p}) n > m
  {
    my $x1 = $r->seq(1, 3, {by => 0.5});
    is_deeply($x1->values, [1, 1.5, 2.0, 2.5, 3.0]);
  }

  # seq($from, $to, {by => p}) n > m
  {
    my $x1 = $r->seq(3, 1, {by => -0.5});
    is_deeply($x1->values, [3.0, 2.5, 2.0, 1.5, 1.0]);
  }
  
  # seq($from, {by => p, length => l})
  {
    my $x1 = $r->seq(1, 3, {length => 5});
    is_deeply($x1->values, [1, 1.5, 2.0, 2.5, 3.0]);
  }
  
  # seq(along => $v);
  my $x1 = $r->c(3, 4, 5);
  my $x2 = $r->seq({along => $x1});
  is_deeply($x2->values, [1, 2, 3]);
}

# NaN
{
  # NaN - type
  {
    my $x_nan = $r->NaN;
    ok($r->is->double($x_nan));
  }
}

# Arg
{
  # Arg - double
  {
    my $x1 = $r->c(1.2);
    my $x2 = $r->Arg($x1);
    ok($r->is->double($x2));
    is_deeply($x2->values, [0]);
  }

  # Arg - integer
  {
    my $x1 = $r->as->integer($r->c(-3));
    my $x2 = $r->Arg($x1);
    ok($r->is->double($x2));
    is_deeply($x2->values, [$r->pi->value]);
  }

  # Arg - double,NaN
  {
    my $x1 = $r->c($r->NaN);
    my $x2 = $r->Arg($x1);
    ok($r->is->double($x2));
    is_deeply($x2->values, ['NaN']);
  }
  
  # Arg - dim
  {
    my $x1 = $r->array($r->c($r->TRUE, $r->TRUE));
    my $x2 = $r->Arg($x1);
    is_deeply($x2->dim->values, [2]);
  }
}

# Method
{
  # sort - contain NaN
  {
    my $x1 = $r->c(2, 1, 5, $r->NaN);
    my $x1_sorted = $r->sort($x1);
    is_deeply($x1_sorted->values, [1, 2, 5]);
  }
    
  # c_ - append (vector)
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = $r->c($x1, 4, 5);
    is_deeply($x2->values, [1, 2, 3, 4, 5]);
  }

=pod
  # TODO
  # var
  {
    my $x1 = $r->c(2, 3, 4, 7, 9);
    my $var = $r->var($x1);
    is($var->value, 8.5);
  }
=cut

  # numeric
  {
    my $x1 = $r->numeric(3);
    is_deeply($x1->values, [0, 0, 0]);
  }

  # length
  {
    my $x1 = $r->c(1, 2, 4);
    my $length = $r->length($x1);
    is($length->value, 3);
  }
  
  # mean
  {
    my $x1 = $r->c(1, 2, 3);
    my $mean = $r->mean($x1);
    is($mean->value, 2);
  }

  # sort
  {
    # sort - acending
    {
      my $x1 = $r->c(2, 1, 5);
      my $x1_sorted = $r->sort($x1);
      is_deeply($x1_sorted->values, [1, 2, 5]);
    }
    
    # sort - decreasing
    {
      my $x1 = $r->c(2, 1, 5);
      my $x1_sorted = $r->sort($x1, {decreasing => 1});
      is_deeply($x1_sorted->values, [5, 2, 1]);
    }
  }
}

# min
{
  # min
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = $r->min($x1);
    is_deeply($x2->values, [1]);
  }

  # min - multiple $r->arrays
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = $r->c(4, 5, 6);
    my $x3 = $r->min($x1, $x2);
    is_deeply($x3->values, [1]);
  }
  
  # min - contain NaN
  {
    my $x1 = $r->min($r->c(1, 2, $r->NaN));
    is_deeply($x1->values, ['NaN']);
  }
}

# expm1
{
  # expm1 - double,array
  {
    my $x0 = $r->c(1, 2);
    my $x1 = $r->array($x0);
    my $x2 = $r->expm1($x1);
    is(sprintf("%.6f", $x2->values->[0]), '1.718282');
    is(sprintf("%.6f", $x2->values->[1]), '6.389056');
    is_deeply($r->dim($x2)->values, [2]);
    ok($r->is->double($x2));
  }

  # expm1 - double,less than 1e-5
  {
    my $x1 = $r->array($r->c(0.0000001234));
    my $x2 = $r->expm1($x1);
    my $x2_value_str = sprintf("%.13e", $x2->value);
    $x2_value_str =~ s/e-0+/e-/;
    is($x2_value_str, '1.2340000761378e-7');
    ok($r->is->double($x2));
  }

  # expm1 - integer
  {
    my $x1 = $r->as->integer($r->array($r->c(2)));
    my $x2 = $r->expm1($x1);
    is(sprintf("%.6f", $x2->value), '6.389056');
    ok($r->is->double($x2));
  }
    
  # expm1 - Inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->expm1($x1);
    is($x2->value, 'Inf');
  }
  
  # expm1 - -Inf
  {
    my $x1 = $r->c($r->negate($r->Inf));
    my $x2 = $r->expm1($x1);
    is($x2->value, -1);
  }

  # expm1 - NaN
  {
    my $x1 = $r->c($r->NaN);
    my $x2 = $r->expm1($x1);
    is($x2->value, 'NaN');
  }
}

# prod
{
  # prod - double
  {
    my $x1 = $r->c(2, 3, 4);
    my $x2 = $r->prod($x1);
    ok($r->is->double($x2));
    is_deeply($x2->values, [24]);
  }

  # prod - integer
  {
    my $x1 = $r->as->integer($r->c(2, 3, 4));
    my $x2 = $r->prod($x1);
    ok($r->is->double($x2));
    is_deeply($x2->values, [24]);
  }
}

# sum
{
  # sum - double
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = $r->sum($x1);
    ok($r->is->double($x2));
    is_deeply($x2->values, [6]);
  }
  
  # sum - integer
  {
    my $x1 = $r->as->integer($r->c(1, 2, 3));
    my $x2 = $r->sum($x1);
    ok($r->is->integer($x2));
    is_deeply($x2->values, [6]);
  }
}

# ve - minus
{
  my $x1 = $r->negate($r->C('1:4'));
  is_deeply($x1->values, [-1, -2, -3, -4]);
}

# str
{

  # str - $r->array, one element
  {
    my $x1 = $r->array(1, 1);
    is($r->str($x1), 'num [1(1d)] 1');
  }
  
  # str - $r->array, one dimention
  {
    my $x1 = $r->array($r->C('1:4'), $r->c(4));
    is($r->str($x1), 'num [1:4(1d)] 1 2 3 4');
  }
  
  # str - $r->array
  {
    my $x1 = $r->array($r->C('1:12'), $r->c(4, 3));
    is($r->str($x1), 'num [1:4, 1:3] 1 2 3 4 5 6 7 8 9 10 ...');
  }
  
  # str - vector, more than 10 element
  {
    my $x1 = $r->C('1:11');
    is($r->str($x1), 'num [1:11] 1 2 3 4 5 6 7 8 9 10 ...');
  }

  # str - vector, 10 element
  {
    my $x1 = $r->C('1:10');
    is($r->str($x1), 'num [1:10] 1 2 3 4 5 6 7 8 9 10');
  }

  # str - vector, integer
  {
    my $x1 = $r->as->integer($r->c(1, 2));
    is($r->str($x1), 'int [1:2] 1 2');
  }

  # str - vector, one element
  {
    my $x1 = $r->c(1);
    is($r->str($x1), 'num 1');
  }

  # str - vector, double
  {
    my $x1 = $r->c(1, 2, 3);
    is($r->str($x1), 'num [1:3] 1 2 3');
  }
}

# exp
{
  # exp - double,array
  {
    my $x1 = $r->array($r->c(1, 2));
    my $x2 = $r->exp($x1);
    is(sprintf("%.6f", $x2->values->[0]), '2.718282');
    is(sprintf("%.6f", $x2->values->[1]), '7.389056');
    is_deeply($r->dim($x2)->values, [2]);
    ok($r->is->double($x2));
  }

  # exp - Inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->exp($x1);
    is($x2->value, 'Inf');
  }
  
  # exp - -Inf
  {
    my $x1 = $r->c($r->negate($r->Inf));
    my $x2 = $r->exp($x1);
    is($x2->value, 0);
  }

  # exp - NaN
  {
    my $x1 = $r->c($r->NaN);
    my $x2 = $r->exp($x1);
    is($x2->value, 'NaN');
  }
}

# log10
{
  # log10 - double,array
  {
    my $x1 = $r->array($r->c(10));
    my $x2 = $r->log10($x1);
    is($x2->value, 1);
    is_deeply($r->dim($x2)->values, [1]);
    ok($r->is->double($x2));
  }

  # log10 - integer
  {
    my $x1 = $r->array($r->c_integer(10));
    my $x2 = $r->log10($x1);
    is($x2->value, 1);
    is_deeply($r->dim($x2)->values, [1]);
    ok($r->is->double($x2));
  }

}

# log2
{
  # log2 - double,array
  {
    my $x1 = $r->array($r->c(2));
    my $x2 = $r->log2($x1);
    is($x2->values->[0], 1);
    is_deeply($r->dim($x2)->values, [1]);
    ok($r->is->double($x2));
  }
}

# logb
{
  # logb - double,array
  {
    my $x1 = $r->array($r->c(1, 10, -1, 0));
    my $x2 = $r->logb($x1);
    is($x2->values->[0], 0);
    is(sprintf("%.5f", $x2->values->[1]), '2.30259');
    is($x2->values->[2], 'NaN');
    ok($x2->values->[3], '-Inf');
    is_deeply($r->dim($x2)->values, [4]);
    ok($r->is->double($x2));
  }
}

# log
{
  # log - double,array
  {
    my $x1 = $r->array($r->c(1, 10, -1, 0));
    my $x2 = $r->log($x1);
    is($x2->values->[0], 0);
    is(sprintf("%.5f", $x2->values->[1]), '2.30259');
    ok($x2->values->[2], 'NaN');
    ok($x2->values->[3], '-Inf');
    is_deeply($r->dim($x2)->values, [4]);
    ok($r->is->double($x2));
  }

  # log - Inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->log($x1);
    ok($r->is->infinite($x2)->values, [1]);
  }
  
  # log - Inf()
  {
    my $x1 = $r->c($r->negate($r->Inf));
    my $x2 = $r->log($x1);
    is($x2->value, 'NaN');
  }

  # log - NaN
  {
    my $x1 = $r->c($r->NaN);
    my $x2 = $r->log($x1);
    is($x2->value, 'NaN');
  }
}

# pi
{
  my $x1 = $r->pi;
  is(sprintf('%.4f', $x1->value), 3.1416);
}

# append
{
  # append - after option
  {
    my $x1 = $r->c(1, 2, 3, 4, 5);
    my $x2 = $r->append($x1, 1, {after => 3});
    is_deeply($x2->values, [1, 2, 3, 1, 4, 5]);
  }

  # append - no after option
  {
    my $x1 = $r->c(1, 2, 3, 4, 5);
    my $x2 = $r->append($x1, 1);
    is_deeply($x2->values, [1, 2, 3, 4, 5, 1]);
  }

  # append - vector
  {
    my $x1 = $r->c(1, 2, 3, 4, 5);
    my $x2 = $r->append($x1, $r->c(6, 7));
    is_deeply($x2->values, [1, 2, 3, 4, 5, 6, 7]);
  }
}

# replace
{
  {
    my $x1 = $r->C('1:10');
    my $x2 = $r->c(2, 5, 10);
    my $x3 = $r->c(12, 15, 20);
    my $x4 = $r->replace($x1, $x2, $x3);
    is_deeply($x4->values, [1, 12, 3, 4, 15, 6, 7, 8, 9, 20]);
  }
  
  # replace - single value
  {
    my $x1 = $r->C('1:10');
    my $x2 = $r->c(2, 5, 10);
    my $x4 = $r->replace($x1, $x2, 11);
    is_deeply($x4->values, [1, 11, 3, 4, 11, 6, 7, 8, 9, 11]);
  }
  
  # replace - few values
  {
    my $x1 = $r->C('1:10');
    my $x2 = $r->c(2, 5, 10);
    my $x4 = $r->replace($x1, $x2, $r->c(12, 15));
    is_deeply($x4->values, [1, 12, 3, 4, 15, 6, 7, 8, 9, 12]);
  }
}

# is->element
{
  # is->element - numeric
  {
    my $x1 = $r->c(1, 2, 3, 4);
    my $x2 = $r->c(1, 2, 3);
    my $x3 = $r->is->element($x1, $x2);
    is_deeply($x3->values, [1, 1, 1, 0]);
  }
}

# setequal
{
  # setequal - equal
  {
    my $x1 = $r->c(2, 3, 1);
    my $x2 = $r->c(3, 2, 1);
    my $x3 = $r->setequal($x1, $x2);
    is_deeply($x3->value, 1);
  }

  # setequal - not equal
  {
    my $x1 = $r->c(2, 3, 1);
    my $x2 = $r->c(2, 3, 4);
    my $x3 = $r->setequal($x1, $x2);
    is_deeply($x3->value, 0);
  }
    
  # setequal - not equal, element count is diffrent
  {
    my $x1 = $r->c(2, 3, 1);
    my $x2 = $r->c(2, 3, 1, 5);
    my $x3 = $r->setequal($x1, $x2);
    is_deeply($x3->value, 0);
  }
}

# setdiff
{
  my $x1 = $r->c(1, 2, 3, 4);
  my $x2 = $r->c(3, 4);
  my $x3 = $r->setdiff($x1, $x2);
  is_deeply($x3->values, [1, 2]);
}

# intersect
{
  my $x1 = $r->c(1, 2, 3, 4);
  my $x2 = $r->c(3, 4, 5, 6);
  my $x3 = $r->intersect($x1, $x2);
  is_deeply($x3->values, [3, 4]);
}

# union
{
  my $x1 = $r->c(1, 2, 3, 4);
  my $x2 = $r->c(3, 4, 5, 6);
  my $x3 = $r->union($x1, $x2);
  is_deeply($x3->values, [1, 2, 3, 4, 5, 6]);
}

# cummin
{
  my $x1 = $r->c(7, 3, 5, 1);
  my $x2 = $r->cummin($x1);
  is_deeply($x2->values, [7, 3, 3, 1]);
}

# cummax
{
  my $x1 = $r->c(1, 5, 3, 7);
  my $x2 = $r->cummax($x1);
  is_deeply($x2->values, [1, 5, 5, 7]);
}

# cumprod
{
  # cumprod - integer
  {
    my $x1 = $r->c_integer(2, 3, 4);
    my $x2 = $r->cumprod($x1);
    ok($r->is->double($x2));
    is_deeply($x2->values, [2, 6, 24]);
  }

  # cumprod - double
  {
    my $x1 = $r->c(2, 3, 4);
    my $x2 = $r->cumprod($x1);
    ok($r->is->double($x2));
    is_deeply($x2->values, [2, 6, 24]);
  }
}

# cumsum
{
  # cumsum - integer
  {
    my $x1 = $r->c_integer(1, 2, 3);
    my $x2 = $r->cumsum($x1);
    ok($r->is->double($x2));
    is_deeply($x2->values, [1, 3, 6]);
  }

  # cumsum - double
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = $r->cumsum($x1);
    ok($r->is->double($x2));
    is_deeply($x2->values, [1, 3, 6]);
  }
}

# rank
{
  my $x1 = $r->c(1, 5, 5, 5, 3, 3, 7);
  my $x2 = $r->rank($x1);
  is_deeply($x2->values, [1, 5, 5, 5, 2.5, 2.5, 7]);
}

# order
{
  # order - 2 condition,decreasing TRUE
  {
    my $x1 = $r->c(4, 3, 3, 3, 1, 5);
    my $x2 = $r->c(1, 2, 3, 1, 1, 1);
    my $x3 = $r->order($x1, $x2, {decreasing => $r->TRUE});
    is_deeply($x3->values, [6, 1, 3, 2, 4, 5]);
  }
  
  # order - 2 condition,decreasing FALSE
  {
    my $x1 = $r->c(4, 3, 3, 3, 1, 5);
    my $x2 = $r->c(1, 2, 3, 1, 1, 1);
    my $x3 = $r->order($x1, $x2);
    is_deeply($x3->values, [5, 4, 2, 3, 1, 6]);
  }
  
  # order - decreasing FALSE
  {
    my $x1 = $r->c(2, 4, 3, 1);
    my $x2 = $r->order($x1, {decreasing => $r->FALSE});
    is_deeply($x2->values, [4, 1, 3, 2]);
  }
  
  # order - decreasing TRUE
  {
    my $x1 = $r->c(2, 4, 3, 1);
    my $x2 = $r->order($x1, {decreasing => $r->TRUE});
    is_deeply($x2->values, [2, 3, 1, 4]);
  }

  # order - decreasing FALSE
  {
    my $x1 = $r->c(2, 4, 3, 1);
    my $x2 = $r->order($x1);
    is_deeply($x2->values, [4, 1, 3, 2]);
  }
}

# diff
{
  # diff - numeric
  {
    my $x1 = $r->c(1, 5, 10);
    my $x2 = $r->diff($x1);
    is_deeply($x2->values, [4, 5]);
  }
}

# range
{
  my $x1 = $r->c(1, 2, 3);
  my $x2 = $r->range($x1);
  is_deeply($x2->values, [1, 3]);
}

# pmax
{
  my $x1 = $r->c(1, 6, 3, 8);
  my $x2 = $r->c(5, 2, 7, 4);
  my $pmax = $r->pmax($x1, $x2);
  is_deeply($pmax->values, [5, 6, 7, 8]);
}

# pmin
{
  my $x1 = $r->c(1, 6, 3, 8);
  my $x2 = $r->c(5, 2, 7, 4);
  my $pmin = $r->pmin($x1, $x2);
  is_deeply($pmin->values, [1, 2, 3, 4]);
}
  
# rev
{
  my $x1 = $r->c(2, 4, 3, 1);
  my $x2 = $r->rev($x1);
  is_deeply($x2->values, [1, 3, 4, 2]);
}

# T, F
{
  my $x1 = $r->c($r->TRUE, $r->FALSE);
  is_deeply($x1->values, [1, 0]);
}

# sqrt
{
  # sqrt - numeric
  {
    my $e1 = $r->c(4, 9);
    my $e2 = $r->sqrt($e1);
    is_deeply($e2->values, [2, 3]);
  }
}

# max
{
  # max
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = $r->max($x1);
    is_deeply($x2->values, [3]);
  }

  # max - multiple $r->arrays
  {
    my $x1 = $r->c(1, 2, 3);
    my $x2 = $r->c(4, 5, 6);
    my $x3 = $r->max($x1, $x2);
    is_deeply($x3->values, [6]);
  }
  
  # max - contain NaN
  {
    my $x1 = $r->max($r->c(1, 2, $r->NaN));
    is_deeply($x1->values, ['NaN']);
  }
}

# median
{
  # median - odd number
  {
    my $x1 = $r->c(2, 3, 3, 4, 5, 1);
    my $x2 = $r->median($x1);
    is_deeply($x2->values, [3]);
  }
  # median - even number
  {
    my $x1 = $r->c(2, 3, 3, 4, 5, 1, 6);
    my $x2 = $r->median($x1);
    is_deeply($x2->values, [3.5]);
  }
}

# quantile
{
  # quantile - odd number
  {
    my $x1 = $r->C('0:100');
    my $x2 = $r->quantile($x1);
    is_deeply($x2->values, [0, 25, 50, 75, 100]);
  }
  
  # quantile - even number
  {
    my $x1 = $r->C('1:100');
    my $x2 = $r->quantile($x1);
    is_deeply($x2->values, [1.00, 25.75, 50.50, 75.25, 100.00]);
  }

  # quantile - one element
  {
    my $x1 = $r->c(1);
    my $x2 = $r->quantile($x1);
    is_deeply($x2->values, [1, 1, 1, 1, 1]);
  }
}

# unique
{
  # uniqeu - numeric
  my $x1 = $r->c(1, 1, 2, 2, 3, $r->Inf, $r->Inf);
  my $x2 = $r->unique($x1);
  is_deeply($x2->values, [1, 2, 3, 'Inf']);
}

# round
{
  # round - $r->array reference
  {
    my $x1 = $r->c(-1.3, 2.4, 2.5, 2.51, 3.51);
    my $x2 = $r->round($x1);
    is_deeply(
      $x2->values,
      [-1, 2, 2, 3, 4]
    );
  }

  # round - matrix
  {
    my $x1 = $r->c(-1.3, 2.4, 2.5, 2.51, 3.51);
    my $x2 = $r->round($r->matrix($x1));
    is_deeply(
      $x2->values,
      [-1, 2, 2, 3, 4]
    );
  }

  # round - $r->array reference
  {
    my $x1 = $r->c(-13, 24, 25, 25.1, 35.1);
    my $x2 = $r->round($x1, -1);
    is_deeply(
      $x2->values,
      [-10, 20, 20, 30, 40]
    );
  }

  # round - $r->array reference
  {
    my $x1 = $r->c(-13, 24, 25, 25.1, 35.1);
    my $x2 = $r->round($x1, {digits => -1});
    is_deeply(
      $x2->values,
      [-10, 20, 20, 30, 40]
    );
  }
  
  # round - matrix
  {
    my $x1 = $r->c(-13, 24, 25, 25.1, 35.1);
    my $x2 = $r->round($r->matrix($x1), -1);
    is_deeply(
      $x2->values,
      [-10, 20, 20, 30, 40]
    );
  }
  
  # round - $r->array reference
  {
    my $x1 = $r->c(-0.13, 0.24, 0.25, 0.251, 0.351);
    my $x2 = $r->round($x1, 1);
    is_deeply(
      $x2->values,
      [-0.1, 0.2, 0.2, 0.3, 0.4]
    );
  }

  # round - matrix
  {
    my $x1 = $r->c(-0.13, 0.24, 0.25, 0.251, 0.351);
    my $x2 = $r->round($r->matrix($x1), 1);
    is_deeply(
      $x2->values,
      [-0.1, 0.2, 0.2, 0.3, 0.4]
    );
  }
}

# trunc
{
  # trunc - $r->array reference
  {
    my $x1 = $r->c(-1.2, -1, 1, 1.2);
    my $x2 = $r->trunc($x1);
    is_deeply(
      $x2->values,
      [-1, -1, 1, 1]
    );
  }

  # trunc - matrix
  {
    my $x1 = $r->c(-1.2, -1, 1, 1.2);
    my $x2 = $r->trunc($r->matrix($x1));
    is_deeply(
      $x2->values,
      [-1, -1, 1, 1]
    );
  }
}

# floor
{
  # floor - $r->array reference
  {
    my $x1 = $r->c(2.5, 2.0, -1.0, -1.3);
    my $x2 = $r->floor($x1);
    is_deeply(
      $x2->values,
      [2, 2, -1, -2]
    );
  }

  # floor - matrix
  {
    my $x1 = $r->c(2.5, 2.0, -1.0, -1.3);
    my $x2 = $r->floor($r->matrix($x1));
    is_deeply(
      $x2->values,
      [2, 2, -1, -2]
    );
  }
}

# ceiling
{
  # ceiling - $r->array reference
  {
    my $x1 = $r->c(2.5, 2.0, -1.0, -1.3);
    my $x2 = $r->ceiling($x1);
    is_deeply(
      $x2->values,
      [3, 2, -1, -1]
    );
  }

  # ceiling - $r->matrix
  {
    my $x1 = $r->c(2.5, 2.0, -1.0, -1.3);
    my $x2 = $r->ceiling($r->matrix($x1));
    is_deeply(
      $x2->values,
      [3, 2, -1, -1]
    );
  }
}

# sqrt
{
  # sqrt - $r->array reference
  {
    my $x1 = $r->c(2, 3, 4);
    my $x2 = $r->sqrt($x1);
    is_deeply(
      $x2->values,
      [
        sqrt $x1->values->[0],
        sqrt $x1->values->[1],
        sqrt $x1->values->[2]
      ]
    );
  }

  # sqrt - $r->matrix
  {
    my $x1 = $r->c(2, 3, 4);
    my $x2 = $r->sqrt($r->matrix($x1));
    is_deeply(
      $x2->values,
      [
        sqrt $x1->values->[0],
        sqrt $x1->values->[1],
        sqrt $x1->values->[2]
      ]
    );
  }
}

# c_double
{
  # c_double - arguments is list
  {
    my $x1 = $r->c_double(1.1, 1.2, 1.3);
    ok($x1->is->double);
    is_deeply($x1->values, [1.1, 1.2, 1.3]);
  }

  # c_double - arguments is $r->array reference
  {
    my $x1 = $r->c_double([1.1, 1.2, 1.3]);
    ok($x1->is->double);
    is_deeply($x1->values, [1.1, 1.2, 1.3]);
  }
}

# clone
{
  # clone - $r->matrix
  {
    my $x1 = $r->matrix($r->C('1:24'), 3, 2);
    my $x2 = $r->clone($x1);
    ok($r->is->matrix($x2));
    is_deeply($r->dim($x2)->values, [3, 2]);
  }
}

# array
{
  # array - basic
  {
    my $x1 = $r->array($r->C('1:24'), $r->c(4, 3, 2));
    is_deeply($x1->values, [1 .. 24]);
    is_deeply($r->dim($x1)->values, [4, 3, 2]);
  }
  
  # array - dim option
  {
    my $x1 = $r->array($r->C('1:24'), {dim => $r->c(4, 3, 2)});
    is_deeply($x1->values, [1 .. 24]);
    is_deeply($r->dim($x1)->values, [4, 3, 2]);
  }
}

# value
{
  # value - none argument
  {
    my $x1 = $r->array($r->C('1:4'));
    is($x1->value, 1);
  }

  # value - one-dimetion
  {
    my $x1 = $r->array($r->C('1:4'));
    is($x1->value(2), 2);
  }
  
  # value - two-dimention
  {
    my $x1 = $r->array($r->C('1:12'), $r->c(4, 3));
    is($x1->value(3, 2), 7);
  }

  # value - two-dimention, as_vector
  {
    my $x1 = $r->array($r->C('1:12'), $r->c(4, 3));
    is($r->as->vector($x1)->value(5), 5);
  }
  
  # value - three-dimention
  {
    my $x1 = $r->array($r->C('1:24'), $r->c(4, 3, 1));
    is($x1->value(3, 2, 1), 7);
  }
}

# create element
{
  # create element - double
  {
    my $x1 = $r->c(1, 2, 3);
  }
}
