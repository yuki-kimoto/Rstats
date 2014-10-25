use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Math::Trig ();

# NULL
{
  my $v1 = r->NULL;
  is_deeply($v1->values, []);
  is("$v1", 'NULL');
  $v1->at(3)->set(5);
  is_deeply($v1->values, [undef, undef, 5]);
}


# tail
{
  {
    my $v1 = c(1, 2, 3, 4, 5, 6, 7);
    my $tail = r->tail($v1);
    is_deeply($tail->values, [2, 3, 4, 5, 6, 7]);
  }
  
  # tail - values is low than 6
  {
    my $v1 = c(1, 2, 3);
    my $tail = r->tail($v1);
    is_deeply($tail->values, [1, 2, 3]);
  }
  
  # tail - n option
  {
    my $v1 = c(1, 2, 3, 4);
    my $tail = r->tail($v1, {n => 3});
    is_deeply($tail->values, [2, 3, 4]);
  }
}

# class
{
  # class - vector, numeric
  {
    my $x1 = c(1, 2);
    is_deeply($x1->class->values, ['numeric']);
  }
  
  # class - matrix
  {
    my $x1 = matrix(2, 2);
    is_deeply($x1->class->values, ['matrix']);
  }

  # class - array
  {
    my $x1 = array(ve('1:24'), c(4, 3, 2));
    is_deeply($x1->class->values, ['array']);
  }
  
  # class - factor
  {
    my $x1 = factor(c(1, 2, 3));
    is_deeply($x1->class->values, ['factor']);
  }
  
  # class - factor, ordered
  {
    my $x1 = ordered(c(1, 2, 3));
    is_deeply($x1->class->values, ['factor', 'ordered']);
  }
  
  # class - list
  {
    my $x1 = list(1, 2);
    is_deeply($x1->class->values, ['list']);
  }
  
  # class - data frame
  {
    my $x1 = data_frame(sex => c(1, 2));
    is_deeply($x1->class->values, ['data.frame']);
  }
}

# as_numeric
{
  # as_numeric - from complex
  {
    my $x1 = c(r->complex(1, 1), r->complex(2, 2));
    r->mode($x1 => 'complex');
    my $x2 = r->as_numeric($x1);
    is(r->mode($x2)->value, 'numeric');
    is_deeply($x2->values, [1, 2]);
  }

  # as_numeric - from numeric
  {
    my $x1 = c(0.1, 1.1, 2.2);
    r->mode($x1 => 'numeric');
    my $x2 = r->as_numeric($x1);
    is(r->mode($x2)->value, 'numeric');
    is_deeply($x2->values, [0.1, 1.1, 2.2]);
  }
    
  # as_numeric - from integer
  {
    my $x1 = c(0, 1, 2);
    r->mode($x1 => 'integer');
    my $x2 = r->as_numeric($x1);
    is(r->mode($x2)->value, 'numeric');
    is_deeply($x2->values, [0, 1, 2]);
  }
  
  # as_numeric - from logical
  {
    my $x1 = c(r->TRUE, r->FALSE);
    r->mode($x1 => 'logical');
    my $x2 = r->as_numeric($x1);
    is(r->mode($x2)->value, 'numeric');
    is_deeply($x2->values, [1, 0]);
  }

  # as_numeric - from character
  {
    my $x1 = r->as_integer(c(0, 1, 2));
    my $x2 = r->as_numeric($x1);
    is(r->mode($x2)->value, 'numeric');
    is_deeply($x2->values, [0, 1, 2]);
  }
}
  
# is_*, as_*, typeof
{
  # is_*, as_*, typeof - integer
  {
    my $c = c(0, 1, 2);
    ok(r->is_integer(r->as_integer($c)));
    is(r->mode(r->as_integer($c))->value, 'numeric');
    is(r->typeof(r->as_integer($c))->value, 'integer');
  }
  
  # is_*, as_*, typeof - character
  {
    my $c = c(0, 1, 2);
    ok(r->is_character(r->as_character($c)));
    is(r->mode(r->as_character($c))->value, 'character');
    is(r->typeof(r->as_character($c))->value, 'character');
  }
  
  # is_*, as_*, typeof - complex
  {
    my $c = c(0, 1, 2);
    ok(r->is_complex(r->as_complex($c)));
    is(r->mode(r->as_complex($c))->value, 'complex');
    is(r->typeof(r->as_complex($c))->value, 'complex');
  }
  
  # is_*, as_*, typeof - logical
  {
    my $x1 = c(0, 1, 2);
    my $x2 = r->as_logical($x1);
    ok(r->is_logical($x2));
    is(r->mode($x2)->value, 'logical');
    is(r->typeof($x2)->value, 'logical');
  }

  # is_*, as_*, typeof - NULL
  {
    my $x1 = r->NULL;
    is(r->mode($x1)->value, 'logical');
    is(r->typeof($x1)->value, 'logical');
  }
}

# matrix
{
  {
    my $mat = matrix(0, 2, 5);
    is_deeply($mat->values, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    is_deeply(r->dim($mat)->values, [2, 5]);
    ok(r->is_matrix($mat));
  }
  
  # matrix - repeat values
  {
    my $mat = matrix([1,2], 2, 5);
    is_deeply($mat->values, [1, 2, 1, 2, 1, 2, 1, 2, 1, 2]);
    is_deeply(r->dim($mat)->values, [2, 5]);
    ok(r->is_matrix($mat));
  }
}

# rnorm
{
  my $v1 = r->rnorm(100);
  is(r->length($v1)->value, 100);
}

# sequence
{
  my $v1 = c(1, 2, 3);
  my $v2 = r->sequence($v1);
  is_deeply($v2->values, [1, 1, 2, 1, 2, 3])
}
  
# sample
{
  {
    my $v1 = ve('1:100');
    my $v2 = r->sample($v1, 50);
    is(r->length($v2)->value, 50);
    my $duplicate_h = {};
    my $duplicate;
    my $invalid_value;
    for my $v2_value (@{$v2->values}) {
      $duplicate_h->{$v2_value}++;
      $duplicate = 1 if $duplicate_h->{$v2_value} > 2;
      unless (grep { $_ eq $v2_value } (1 .. 100)) {
        $invalid_value = 1;
      }
    }
    ok(!$duplicate);
    ok(!$invalid_value);
  }
  
  # sample - replace => 0
  {
    my $v1 = ve('1:100');
    my $v2 = r->sample($v1, 50, {replace => 0});
    is(r->length($v2)->value, 50);
    my $duplicate_h = {};
    my $duplicate;
    my $invalid_value;
    for my $v2_value (@{$v2->values}) {
      $duplicate_h->{$v2_value}++;
      $duplicate = 1 if $duplicate_h->{$v2_value} > 2;
      unless (grep { $_ eq $v2_value } (1 .. 100)) {
        $invalid_value = 1;
      }
    }
    ok(!$duplicate);
    ok(!$invalid_value);
  }

  # sample - replace => 0
  {
    my $v1 = ve('1:100');
    my $v2 = r->sample($v1, 50, {replace => 1});
    is(r->length($v2)->value, 50);
    my $duplicate_h = {};
    my $duplicate;
    my $invalid_value;
    for my $v2_value (@{$v2->values}) {
      unless (grep { $_ eq $v2_value } (1 .. 100)) {
        $invalid_value = 1;
      }
    }
    ok(!$invalid_value);
  }
  
  # sample - replace => 0, (strict check)
  {
    my $v1 = c(1);
    my $v2 = r->sample($v1, 5, {replace => 1});
    is(r->length($v2)->value, 5);
    is_deeply($v2->values, [1, 1, 1, 1, 1]);
  }
}

# runif
{
  {
    srand 100;
    my $rands = [rand 1, rand 1, rand 1, rand 1, rand 1];
    r->set_seed(100);
    my $v1 = r->runif(5);
    is_deeply($v1->values, $rands);
    
    my $v2 = r->runif(5);
    isnt($v1->values->[0], $v2->values->[0]);

    my $v3 = r->runif(5);
    isnt($v2->values->[0], $v3->values->[0]);
    
    my $v4 = r->runif(100);
    my @in_ranges = grep { $_ >= 0 && $_ <= 1 } @{$v4->values};
    is(scalar @in_ranges, 100);
  }
  
  # runif - min and max
  {
    srand 100;
    my $rands = [
      rand(9) + 1,
      rand(9) + 1,
      rand(9) + 1,
      rand(9) + 1,
      rand(9) + 1
    ];
    r->set_seed(100);
    my $v1 = r->runif(5, 1, 10);
    is_deeply($v1->values, $rands);

    my $v2 = r->runif(100, 1, 2);
    my @in_ranges = grep { $_ >= 1 && $_ <= 2 } @{$v2->values};
    is(scalar @in_ranges, 100);
  }
}

# which
{
  my $v1 = c('a', 'b', 'a');
  my $v2 = r->which($v1, sub { $_ eq 'a' });
  is_deeply($v2->values, [1, 3]);
}

# elseif
{
  my $v1 = c(1, 0, 1);
  my $v2 = r->ifelse($v1, 'a', 'b');
  is_deeply($v2->values, ['a', 'b', 'a']);
}

# head
{
  {
    my $v1 = c(1, 2, 3, 4, 5, 6, 7);
    my $head = r->head($v1);
    is_deeply($head->values, [1, 2, 3, 4, 5, 6]);
  }
  
  # head - values is low than 6
  {
    my $v1 = c(1, 2, 3);
    my $head = r->head($v1);
    is_deeply($head->values, [1, 2, 3]);
  }
  
  # head - n option
  {
    my $v1 = c(1, 2, 3, 4);
    my $head = r->head($v1, {n => 3});
    is_deeply($head->values, [1, 2, 3]);
  }
}

# length
{
  my $x = array(c(1, 2, 3));
  is(r->length($x)->value, 3);
}

# array
{
  {
    my $x = array(25);
    is_deeply($x->values, [25]);
  }
  {
    my $x = array(c(1, 2, 3));
    is_deeply(r->dim($x)->values, [3]);
  }
}

# Array get and set
{
  my $x = array(c(1, 2, 3));
  is_deeply($x->get(1)->values, [1]);
  is_deeply($x->get(3)->values, [3]);
  $x->at(1)->set(5);;
  is_deeply($x->get(1)->values, [5]);
}

# c
{
  # c($x)
  {
    my $v = c(1, 2, 3);
    is_deeply($v->values, [1, 2, 3]);
  }
  
  # c($vector)
  {
    my $v = c(c(1, 2, 3));
    is_deeply($v->values, [1, 2, 3]);
  }
  
  # c(ve('1:3')
  {
    my $v = ve('1:3');
    is_deeply($v->values, [1, 2, 3]);
  }
  
  # c('0.5*1:3')
  {
    my $v = ve('0.5*1:3');
    is_deeply($v->values, [1, 1.5, 2, 2.5, 3]);
  }
}

# rep function
{
  # req($v, {times => $times});
  {
    my $v1 = c(1, 2, 3);
    my $v2 = r->rep($v1, {times => 3});
    is_deeply($v2->values, [1, 2, 3, 1, 2, 3, 1, 2, 3]);
  }
}

# seq function
{
  # seq($from, $to),  n > m
  {
    my $v = r->seq(1, 3);
    is_deeply($v->values, [1, 2, 3]);
  }

  # seq({from => $from, to => $to}),  n > m
  {
    my $v = r->seq({from => 1, to => 3});
    is_deeply($v->values, [1, 2, 3]);
  }
  
  # seq($from, $to),  n < m
  {
    my $v = r->seq(3, 1);
    is_deeply($v->values, [3, 2, 1]);
  }
  
  # seq($from, $to), n = m
  {
    my $v = r->seq(2, 2);
    is_deeply($v->values, [2]);
  }
  
  # seq($from, $to, {by => p}) n > m
  {
    my $v = r->seq(1, 3, {by => 0.5});
    is_deeply($v->values, [1, 1.5, 2.0, 2.5, 3.0]);
  }

  # seq($from, $to, {by => p}) n > m
  {
    my $v = r->seq(3, 1, {by => -0.5});
    is_deeply($v->values, [3.0, 2.5, 2.0, 1.5, 1.0]);
  }
  
  # seq($from, {by => p, length => l})
  {
    my $v = r->seq(1, 3, {length => 5});
    is_deeply($v->values, [1, 1.5, 2.0, 2.5, 3.0]);
  }
  
  # seq(along => $v);
  my $v1 = c(3, 4, 5);
  my $v2 = r->seq({along => $v1});
  is_deeply($v2->values, [1, 2, 3]);
}
