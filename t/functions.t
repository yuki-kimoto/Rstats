use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

my $r = Rstats->new;

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

# abs
{
  # abs - pass array refference
  {
    my $a1 = $r->abs([-3, 4]);
    is_deeply($a1->values, [3, 4]);
  }

  # abs - pass matrix
  {
    my $a1 = $r->abs($r->matrix([-3, 4]));
    is_deeply($a1->values, [3, 4]);
    is($a1->type, 'matrix');
  }
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

