use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

my $r = Rstats->new;

# comparison operator numeric
{

  # comparison operator numeric - <
  {
    my $a1 = $r->array([1,2,3]);
    my $a2 = $r->array([2,1,3]);
    my $a3 = $a1 < $a2;
    is_deeply($a3->values, [$r->TRUE, $r->FALSE, $r->FALSE]);
  }

  # comparison operator numeric - <, arguments count is different
  {
    my $a1 = $r->array([1,2,3]);
    my $a2 = $r->array([2]);
    my $a3 = $a1 < $a2;
    is_deeply($a3->values, [$r->TRUE, $r->FALSE, $r->FALSE]);
  }

  # comparison operator numeric - <=
  {
    my $a1 = $r->array([1,2,3]);
    my $a2 = $r->array([2,1,3]);
    my $a3 = $a1 <= $a2;
    is_deeply($a3->values, [$r->TRUE, $r->FALSE, $r->TRUE]);
  }

  # comparison operator numeric - <=, arguments count is different
  {
    my $a1 = $r->array([1,2,3]);
    my $a2 = $r->array([2]);
    my $a3 = $a1 <= $a2;
    is_deeply($a3->values, [$r->TRUE, $r->TRUE, $r->FALSE]);
  }

  # comparison operator numeric - >
  {
    my $a1 = $r->array([1,2,3]);
    my $a2 = $r->array([2,1,3]);
    my $a3 = $a1 > $a2;
    is_deeply($a3->values, [$r->FALSE, $r->TRUE, $r->FALSE]);
  }

  # comparison operator numeric - >, arguments count is different
  {
    my $a1 = $r->array([1,2,3]);
    my $a2 = $r->array([2]);
    my $a3 = $a1 > $a2;
    is_deeply($a3->values, [$r->FALSE, $r->FALSE, $r->TRUE]);
  }

  # comparison operator numeric - >=
  {
    my $a1 = $r->array([1,2,3]);
    my $a2 = $r->array([2,1,3]);
    my $a3 = $a1 >= $a2;
    is_deeply($a3->values, [$r->FALSE, $r->TRUE, $r->TRUE]);
  }

  # comparison operator numeric - >=, arguments count is different
  {
    my $a1 = $r->array([1,2,3]);
    my $a2 = $r->array([2]);
    my $a3 = $a1 >= $a2;
    is_deeply($a3->values, [$r->FALSE, $r->TRUE, $r->TRUE]);
  }

  # comparison operator numeric - ==
  {
    my $a1 = $r->array([1,2]);
    my $a2 = $r->array([2,2]);
    my $a3 = $a1 == $a2;
    is_deeply($a3->values, [$r->FALSE, $r->TRUE]);
  }

  # comparison operator numeric - ==, arguments count is different
  {
    my $a1 = $r->array([1,2]);
    my $a2 = $r->array([2]);
    my $a3 = $a1 == $a2;
    is_deeply($a3->values, [$r->FALSE, $r->TRUE]);
  }

  # comparison operator numeric - !=
  {
    my $a1 = $r->array([1,2]);
    my $a2 = $r->array([2,2]);
    my $a3 = $a1 != $a2;
    is_deeply($a3->values, [$r->TRUE, $r->FALSE]);
  }

  # comparison operator numeric - !=, arguments count is different
  {
    my $a1 = $r->array([1,2]);
    my $a2 = $r->array([2]);
    my $a3 = $a1 != $a2;
    is_deeply($a3->values, [$r->TRUE, $r->FALSE]);
  }
}
