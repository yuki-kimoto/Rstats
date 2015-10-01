use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Math::Trig ();

# NULL
{
  my $x1 = r->NULL;
  is_deeply($x1->values, []);
  is("$x1", 'NULL');
  $x1->at(3)->set(5);
  is_deeply($x1->values, [undef, undef, 5]);
}

# class
{
  # class - data frame
  {
    my $x1 = data_frame(sex => c_(1, 2));
    is_deeply($x1->class->values, ['data.frame']);
  }

  # class - vector, numeric
  {
    my $x1 = c_(1, 2);
    is_deeply($x1->class->values, ['numeric']);
  }
  
  # class - matrix
  {
    my $x1 = matrix(2, 2);
    is_deeply($x1->class->values, ['matrix']);
  }

  # class - array
  {
    my $x1 = array(C_('1:24'), c_(4, 3, 2));
    is_deeply($x1->class->values, ['array']);
  }
  
  # class - factor
  {
    my $x1 = factor(c_(1, 2, 3));
    is_deeply($x1->class->values, ['factor']);
  }
  
  # class - factor, ordered
  {
    my $x1 = ordered(c_(1, 2, 3));
    is_deeply($x1->class->values, ['factor', 'ordered']);
  }
  
  # class - list
  {
    my $x1 = list(1, 2);
    is_deeply($x1->class->values, ['list']);
  }
}

# c
{
  # c_("a", "b")
  {
    my $x1 = c_("a", "b");
    is_deeply($x1->values, ["a", "b"]);
  }

  # c_([1, 2, 3])
  {
    my $x1 = c_([1, 2, 3]);
    is(r->typeof($x1)->value, 'double');
    is_deeply($x1->values, [1, 2, 3]);
  }
  
  # c_(c_(1, 2, 3))
  {
    my $x1 = c_(c_(1, 2, 3));
    is_deeply($x1->values, [1, 2, 3]);
  }
  
  # c_(1, 2, c_(3, 4, 5))
  {
    my $x1 = c_(1, 2, c_(3, 4, 5));
    is_deeply($x1->values, [1, 2, 3, 4, 5]);
  }
}

# C_
{
  # C_('1:3')
  {
    my $x1 = C_('1:3');
    is_deeply($x1->values, [1, 2, 3]);
  }
  
  # C_('0.5*1:3')
  {
    my $x1 = C_('0.5*1:3');
    is_deeply($x1->values, [1, 1.5, 2, 2.5, 3]);
  }
}

# tail
{
  {
    my $x1 = c_(1, 2, 3, 4, 5, 6, 7);
    my $tail = r->tail($x1);
    is_deeply($tail->values, [2, 3, 4, 5, 6, 7]);
  }
  
  # tail - values is low than 6
  {
    my $x1 = c_(1, 2, 3);
    my $tail = r->tail($x1);
    is_deeply($tail->values, [1, 2, 3]);
  }
  
  # tail - n option
  {
    my $x1 = c_(1, 2, 3, 4);
    my $tail = r->tail($x1, {n => 3});
    is_deeply($tail->values, [2, 3, 4]);
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
    my $mat = matrix(c_(1,2), 2, 5);
    is_deeply($mat->values, [1, 2, 1, 2, 1, 2, 1, 2, 1, 2]);
    is_deeply(r->dim($mat)->values, [2, 5]);
    ok(r->is_matrix($mat));
  }
}

# rnorm
{
  my $x1 = r->rnorm(100);
  is(r->length($x1)->value, 100);
}

# sequence
{
  my $x1 = c_(1, 2, 3);
  my $x2 = r->sequence($x1);
  is_deeply($x2->values, [1, 1, 2, 1, 2, 3])
}
  
# sample
{
  {
    my $x1 = C_('1:100');
    my $x2 = r->sample($x1, 50);
    is(r->length($x2)->value, 50);
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
    my $x1 = C_('1:100');
    my $x2 = r->sample($x1, 50, {replace => 0});
    is(r->length($x2)->value, 50);
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
    my $x1 = C_('1:100');
    my $x2 = r->sample($x1, 50, {replace => 1});
    is(r->length($x2)->value, 50);
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
    my $x1 = c_(1);
    my $x2 = r->sample($x1, 5, {replace => 1});
    is(r->length($x2)->value, 5);
    is_deeply($x2->values, [1, 1, 1, 1, 1]);
  }
}

# runif
{
  {
    srand 100;
    my $rands = [rand 1, rand 1, rand 1, rand 1, rand 1];
    r->set_seed(100);
    my $x1 = r->runif(5);
    is_deeply($x1->values, $rands);
    
    my $x2 = r->runif(5);
    isnt($x1->values->[0], $x2->values->[0]);

    my $v3 = r->runif(5);
    isnt($x2->values->[0], $v3->values->[0]);
    
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
    my $x1 = r->runif(5, 1, 10);
    is_deeply($x1->values, $rands);

    my $x2 = r->runif(100, 1, 2);
    my @in_ranges = grep { $_ >= 1 && $_ <= 2 } @{$x2->values};
    is(scalar @in_ranges, 100);
  }
}

# which
{
  my $x1 = c_('a', 'b', 'a');
  my $x2 = r->which($x1, sub { $_ eq 'a' });
  is_deeply($x2->values, [1, 3]);
}

# elseif
{
  my $x1 = c_(1, 0, 1);
  my $x2 = r->ifelse($x1, 'a', 'b');
  is_deeply($x2->values, ['a', 'b', 'a']);
}

# head
{
  {
    my $x1 = c_(1, 2, 3, 4, 5, 6, 7);
    my $head = r->head($x1);
    is_deeply($head->values, [1, 2, 3, 4, 5, 6]);
  }
  
  # head - values is low than 6
  {
    my $x1 = c_(1, 2, 3);
    my $head = r->head($x1);
    is_deeply($head->values, [1, 2, 3]);
  }
  
  # head - n option
  {
    my $x1 = c_(1, 2, 3, 4);
    my $head = r->head($x1, {n => 3});
    is_deeply($head->values, [1, 2, 3]);
  }
}

# length
{
  my $x = array(c_(1, 2, 3));
  is(r->length($x)->value, 3);
}

# array
{
  {
    my $x = array(25);
    is_deeply($x->values, [25]);
  }
  {
    my $x = array(c_(1, 2, 3));
    is_deeply(r->dim($x)->values, [3]);
  }
}

# Array get and set
{
  my $x = array(c_(1, 2, 3));
  is_deeply($x->get(1)->values, [1]);
  is_deeply($x->get(3)->values, [3]);
  $x->at(1)->set(5);;
  is_deeply($x->get(1)->values, [5]);
}

# rep function
{
  # req($v, {times => $times});
  {
    my $x1 = c_(1, 2, 3);
    my $x2 = r->rep($x1, {times => 3});
    is_deeply($x2->values, [1, 2, 3, 1, 2, 3, 1, 2, 3]);
  }
}

# seq function
{
  # seq($from, $to),  n > m
  {
    my $x1 = r->seq(1, 3);
    is_deeply($x1->values, [1, 2, 3]);
  }

  # seq({from => $from, to => $to}),  n > m
  {
    my $x1 = r->seq({from => 1, to => 3});
    is_deeply($x1->values, [1, 2, 3]);
  }
  
  # seq($from, $to),  n < m
  {
    my $x1 = r->seq(3, 1);
    is_deeply($x1->values, [3, 2, 1]);
  }
  
  # seq($from, $to), n = m
  {
    my $x1 = r->seq(2, 2);
    is_deeply($x1->values, [2]);
  }
  
  # seq($from, $to, {by => p}) n > m
  {
    my $x1 = r->seq(1, 3, {by => 0.5});
    is_deeply($x1->values, [1, 1.5, 2.0, 2.5, 3.0]);
  }

  # seq($from, $to, {by => p}) n > m
  {
    my $x1 = r->seq(3, 1, {by => -0.5});
    is_deeply($x1->values, [3.0, 2.5, 2.0, 1.5, 1.0]);
  }
  
  # seq($from, {by => p, length => l})
  {
    my $x1 = r->seq(1, 3, {length => 5});
    is_deeply($x1->values, [1, 1.5, 2.0, 2.5, 3.0]);
  }
  
  # seq(along => $v);
  my $x1 = c_(3, 4, 5);
  my $x2 = r->seq({along => $x1});
  is_deeply($x2->values, [1, 2, 3]);
}
