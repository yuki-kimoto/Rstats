use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::Class;

my $r = Rstats::Class->new;

# lapply
{
  my $x1 = $r->list($r->c_(1, 2), $r->c_(3, 4));
  my $x2 = r->lapply($x1, 'sum');
  ok(r->is->list($x2));
  is_deeply($x2->getin(1)->values, [3]);
  is_deeply($x2->getin(2)->values, [7]);
}

# sweep
{
  # sweep - margin 1, %
  {
    my $x1 = $r->array($r->C('1:6'), $r->c_(3, 2));
    my $x2 = r->sweep($x1, 1, $r->c_(1, 2, 3), {FUN => '%'});
    is_deeply($x2->values, [qw/0 0 0 0 1 0/]);
    is_deeply(r->dim($x2)->values, [3, 2]);
  }

  # sweep - margin 1, **
  {
    my $x1 = $r->array($r->C('1:6'), $r->c_(3, 2));
    my $x2 = r->sweep($x1, 1, $r->c_(1, 2, 3), {FUN => '**'});
    is_deeply($x2->values, [qw/1 4 27 4 25 216/]);
    is_deeply(r->dim($x2)->values, [3, 2]);
  }

  # sweep - margin 1, /
  {
    my $x1 = $r->array($r->C('1:6'), $r->c_(3, 2));
    my $x2 = r->sweep($x1, 1, $r->c_(1, 2, 3), {FUN => '/'});
    is_deeply($x2->values, [qw/1 1 1 4 2.5 2/]);
    is_deeply(r->dim($x2)->values, [3, 2]);
  }

  # sweep - margin 1, *
  {
    my $x1 = $r->array($r->C('1:6'), $r->c_(3, 2));
    my $x2 = r->sweep($x1, 1, $r->c_(1, 2, 3), {FUN => '*'});
    is_deeply($x2->values, [qw/1 4 9 4 10 18/]);
    is_deeply(r->dim($x2)->values, [3, 2]);
  }

  # sweep - margin 1, -
  {
    my $x1 = $r->array($r->C('1:6'), $r->c_(3, 2));
    my $x2 = r->sweep($x1, 1, $r->c_(1, 2, 3), {FUN => '-'});
    is_deeply($x2->values, [qw/0 0 0 3 3 3/]);
    is_deeply(r->dim($x2)->values, [3, 2]);
  }
  
  # sweep - margin 1, +
  {
    my $x1 = $r->array($r->C('1:6'), $r->c_(3, 2));
    my $x2 = r->sweep($x1, 1, $r->c_(1, 2, 3), {FUN => '+'});
    is_deeply($x2->values, [qw/2 4 6 5 7 9/]);
    is_deeply(r->dim($x2)->values, [3, 2]);
  }
  
  # sweep - margin 1
  {
    my $x1 = $r->array($r->C('1:6'), $r->c_(3, 2));
    my $x2 = r->sweep($x1, 1, $r->c_(1, 2, 3));
    is_deeply($x2->values, [qw/0 0 0 3 3 3/]);
    is_deeply(r->dim($x2)->values, [3, 2]);
  }

  # sweep - margin 2
  {
    my $x1 = $r->array($r->C('1:6'), $r->c_(3, 2));
    my $x2 = r->sweep($x1, 2, $r->c_(1, 2));
    is_deeply($x2->values, [qw/0 1 2 2 3 4/]);
  }

  # sweep - margin 1, 2
  {
    my $x1 = $r->array($r->C('1:6'), $r->c_(3, 2));
    my $x2 = $r->array($r->C('2:7'), $r->c_(3, 2));
    my $x3 = r->sweep($x1, $r->c_(1, 2), $x2);
    is_deeply($x3->values, [qw/-1 -1 -1 -1 -1 -1/]);
  }
}

# mapply
{
  # mapply - same length
  {
    my $x1 = $r->c_(1, 2, 3);
    my $x2 = $r->c_(3, 2, 1);
    my $x3 = r->mapply('rep', $x1, $x2);
    ok(r->is->list($x3));
    is_deeply($x3->getin(1)->values, [1, 1, 1]);
    is_deeply($x3->getin(2)->values, [2, 2]);
    is_deeply($x3->getin(3)->values, [3]);
  }
  
  # mapply - different length
  {
    my $x1 = $r->c_(1, 2, 3);
    my $x2 = $r->c_(6, 5, 4, 3, 2, 1);
    my $x3 = r->mapply('rep', $x1, $x2);
    ok(r->is->list($x3));
    is_deeply($x3->getin(1)->values, [1, 1, 1, 1, 1, 1]);
    is_deeply($x3->getin(6)->values, [3]);
  }

  # mapply - only first element
  {
    my $x1 = $r->c_(1);
    my $x2 = $r->c_(3);
    my $x3 = r->mapply('rep', $x1, $x2);
    is_deeply($x3->values, [1, 1, 1]);
  }
}

# tapply
{
  my $x1 = $r->c_(1, 2, 4, 5, 4);
  my $x2 = $r->factor($r->c_("M", "L", "M", "L", "M"));
  my $x3 = r->tapply($x1, $x2, 'mean');
  is_deeply($x3->values, [3.5, 3]);
  is_deeply(r->names($x3)->values, ["L", "M"]);
  is_deeply(r->dim($x3)->values, [2]);
}

# sapply
{
  my $x1 = $r->list($r->c_(1, 2), $r->c_(3.2, 4.2));
  my $x2 = r->sapply($x1, 'sum');
  ok(r->is->vector($x2));
  is_deeply($x2->values, [3, 7.4]);
}

# apply
{
  # apply - code reference
  {
    my $x1 = $r->array($r->C('1:24'), $r->c_(4, 3, 2));
    my $x2 = r->apply($x1, 1, sub {
      my ($r, $x1) = @_;
      $r->sum($x1)
    });
    is_deeply($x2->values, [qw/66 72 78 84/]);
    is_deeply(r->dim($x2)->values, []);
  }
  
  # apply - three dimention, margin 3,2
  {
    my $x1 = $r->array($r->C('1:24'), $r->c_(4, 3, 2));
    my $x2 = r->apply($x1, $r->c_(3, 2), 'sum');
    is_deeply($x2->values, [qw/10 58 26 74 42 90/]);
    is_deeply(r->dim($x2)->values, [qw/2 3/]);
  }
  
  # apply - three dimention, margin 2,3
  {
    my $x1 = $r->array($r->C('1:24'), $r->c_(4, 3, 2));
    my $x2 = r->apply($x1, $r->c_(2, 3), 'sum');
    is_deeply($x2->values, [qw/10 26 42 58 74 90/]);
    is_deeply(r->dim($x2)->values, [qw/3 2/]);
  }
  
  # apply - three dimention, margin 1, 2
  {
    my $x1 = $r->array($r->C('1:24'), $r->c_(4, 3, 2));
    my $x2 = r->apply($x1, $r->c_(1, 2), 'sum');
    is_deeply($x2->values, [qw/14 16 18 20 22 24 26 28 30 32 34 36/]);
    is_deeply(r->dim($x2)->values, [qw/4 3/]);
  }
  
  # apply - three dimention, margin 1
  {
    my $x1 = $r->array($r->C('1:24'), $r->c_(4, 3, 2));
    my $x2 = r->apply($x1, 1, 'sum');
    is_deeply($x2->values, [qw/66 72 78 84/]);
    is_deeply(r->dim($x2)->values, []);
  }

  # apply - three dimention, margin 2
  {
    my $x1 = $r->array($r->C('1:24'), $r->c_(4, 3, 2));
    my $x2 = r->apply($x1, 2, 'sum');
    is_deeply($x2->values, [qw/68 100 132/]);
    is_deeply(r->dim($x2)->values, []);
  }

  # apply - three dimention, margin 3
  {
    my $x1 = $r->array($r->C('1:24'), $r->c_(4, 3, 2));
    my $x2 = r->apply($x1, 3, 'sum');
    is_deeply($x2->values, [qw/78 222/]);
    is_deeply(r->dim($x2)->values, []);
  }
    
  # apply - two dimention, margin 1
  {
    my $x1 = $r->matrix($r->C('1:6'), 2, 3);
    my $x2 = r->apply($x1, 1, 'sum');
    is_deeply($x2->values, [9, 12]);
    is_deeply(r->dim($x2)->values, []);
  }

  # apply - two dimention, margin 2
  {
    my $x1 = $r->matrix($r->C('1:6'), 2, 3);
    my $x2 = r->apply($x1, 2, 'sum');
    is_deeply($x2->values, [3, 7, 11]);
    is_deeply(r->dim($x2)->values, []);
  }

  # apply - two dimention, margin 1, 2
  {
    my $x1 = $r->matrix($r->c_(1, 4, 9, 16, 25, 36), 2, 3);
    my $x2 = r->apply($x1, $r->c_(1, 2), 'sqrt');
    is_deeply($x2->values, [1, 2, 3, 4, 5, 6]);
    is_deeply(r->dim($x2)->values, [2, 3]);
  }
}

