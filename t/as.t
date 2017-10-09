use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats;

my $r = Rstats->new;

# as->int
{
  # as->int - dim
  {
    my $x1 = $r->array($r->c([1, 2]));
    my $x2 = $r->as->int($x1);
    is_deeply($x2->dim->values, [2]);
  }

  # as->int - double
  {
    my $x1 = $r->c(1.1);
    my $x2 = $r->as->int($x1);
    ok($r->is->int($x2)->value);
    is($x2->values->[0], 1);
  }
  
  # as->int - int
  {
    my $x1 = $r->c(1);
    my $x2 = $r->as->int($r->as->int($x1));
    ok($r->is->int($x2)->value);
    is($x2->values->[0], 1);
  }
}

# as->double
{
  # as->double - dim
  {
    my $x1 = $r->array($r->c([1.1, 1.2]));
    my $x2 = $r->as->double($x1);
    is_deeply($x2->dim->values, [2]);
  }
  
  # as->double - $r->Inf
  {
    my $x1 = $r->Inf;
    my $x2 = $r->as->double($x1);
    ok($r->is->double($x2)->value);
    is_deeply($x2->values, ['Inf']);
  }

  # as->double - NaN
  {
    my $x1 = $r->NaN;
    my $x2 = $r->as->double($x1);
    ok($r->is->double($x2)->value);
    is_deeply($x2->values, ['NaN']);
  }

  # as->double - double
  {
    my $x1 = $r->array($r->c(1.1));
    my $x2 = $r->as->double($x1);
    ok($r->is->double($x2)->value);
    is($x2->values->[0], 1.1);
  }
  
  # as->double - int
  {
    my $x1 = $r->array($r->c(1));
    my $x2 = $r->as->double($r->as->int($x1));
    ok($r->is->double($x2)->value);
    is($x2->values->[0], 1);
  }
}

# array decide type
{
  # array decide type - numerci
  {
    my $x1 = $r->array($r->c([1, 2]));
    is_deeply($x1->values, [1, 2]);
    ok($r->is->double($x1)->value);
  }
  
  # array decide type - $r->Inf
  {
    my $x1 = $r->Inf;
    is_deeply($x1->values, ['Inf']);
    ok($r->is->double($x1)->value);
  }

  # array decide type - NaN
  {
    my $x1 = $r->NaN;
    is_deeply($x1->values, ['NaN']);
    ok($r->is->double($x1)->value);
  }
}
