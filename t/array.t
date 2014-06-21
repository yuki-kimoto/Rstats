use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

my $r = Rstats->new;

# array test
{
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    is_deeply($a1->values, [1 .. 24]);
    is_deeply($r->dim($a1)->values, [4, 3, 2]);
  }
  
  # array - dim option
  {
    my $a1 = $r->array('1:24', {dim => [4, 3, 2]});
    is_deeply($a1->values, [1 .. 24]);
    is_deeply($r->dim($a1)->values, [4, 3, 2]);
  }
}

# get 3-dimention
{
  # get 3-dimention - minus
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    $DB::single = 1;
    my $a2 = $a1->get([-1, -2], [-1, -2]);
    is_deeply($a2->values, [11, 12, 23, 24]);
    is_deeply($r->dim($a2)->values, [2, 2]);
  }
  
  # get 3-dimention - dimention one
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a2 = $a1->get(2);
    is_deeply($a2->values, [2, 6, 10, 14, 18 ,22]);
    is_deeply($r->dim($a2)->values, [3, 2]);
  }

  # get 3-dimention - dimention two
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a2 = $a1->get('', 2);
    is_deeply($a2->values, [5, 6, 7, 8, 17, 18, 19, 20]);
    is_deeply($r->dim($a2)->values, [4, 2]);
  }

  # get 3-dimention - dimention three
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a2 = $a1->get('', '', 2);
    is_deeply($a2->values, [13 .. 24]);
    is_deeply($r->dim($a2)->values, [4, 3]);
  }

  # get 3-dimention - one value
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a2 = $a1->get(3, 2, 1);
    is_deeply($a2->values, [7]);
    is_deeply($r->dim($a2)->values, []);
  }

  # get 3-dimention - dimention one and two
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a2 = $a1->get(1, 2);
    is_deeply($a2->values, [5, 17]);
    is_deeply($r->dim($a2)->values, [2]);
  }
  # get 3-dimention - dimention one and three
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a2 = $a1->get(3, '', 2);
    is_deeply($a2->values, [15, 19, 23]);
    is_deeply($r->dim($a2)->values, [3]);
  }

  # get 3-dimention - dimention two and three
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a2 = $a1->get('', 1, 2);
    is_deeply($a2->values, [13, 14, 15, 16]);
    is_deeply($r->dim($a2)->values, [4]);
  }
  
  # get 3-dimention - all values
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a2 = $a1->get([1, 2, 3, 4], [1, 2, 3], [1, 2]);
    is_deeply($a2->values, [1 .. 24]);
    is_deeply($r->dim($a2)->values, [4, 3, 2]);
  }

  # get 3-dimention - some values
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a2 = $a1->get([2, 3], [1, 3], [1, 2]);
    is_deeply($a2->values, [2, 3, 10, 11, 14, 15, 22, 23]);
    is_deeply($r->dim($a2)->values, [2, 2, 2]);
  }
}

# _pos
{
  my $a1 = $r->array('1:24', [4, 3, 2]);
  my $dim = [4, 3, 2];
  
  {
    my $value = $a1->_pos([4, 3, 2], $dim);
    is($value, 24);
  }
  
  {
    my $value = $a1->_pos([3, 3, 2], $dim);
    is($value, 23);
  }
}

# _cross_product
{
  my $values = [
    ['a1', 'a2'],
    ['b1', 'b2'],
    ['c1', 'c2']
  ];
  
  my $a1 = $r->array('1:3');
  my $result = $a1->_cross_product($values);
  is_deeply($result, [
    ['a1', 'b1', 'c1'],
    ['a2', 'b1', 'c1'],
    ['a1', 'b2', 'c1'],
    ['a2', 'b2', 'c1'],
    ['a1', 'b1', 'c2'],
    ['a2', 'b1', 'c2'],
    ['a1', 'b2', 'c2'],
    ['a2', 'b2', 'c2']
  ]);
}

# get
{

  # get - one value
  {
    my $v1 = $r->c([1]);
    my $v2 = $v1->get(1);
    is_deeply($v2->values, [1]);
    is_deeply($v2->dim->values, []);
  }

  # get - single index
  {
    my $v1 = $r->c([1, 2, 3, 4]);
    my $v2 = $v1->get(1);
    is_deeply($v2->values, [1]);
  }
  # get - array
  {
    my $v1 = $r->c([1, 3, 5, 7]);
    my $v2 = $v1->get([1, 2]);
    is_deeply($v2->values, [1, 3]);
  }
  # get - vector
  {
    my $v1 = $r->c([1, 3, 5, 7]);
    my $v2 = $v1->get($r->c([1, 2]));
    is_deeply($v2->values, [1, 3]);
  }
  
  # get - minus number
  {
    my $v1 = $r->c([1, 3, 5, 7]);
    my $v2 = $v1->get(-1);
    is_deeply($v2->values, [3, 5, 7]);
  }

  # get - minus number + array
  {
    my $v1 = $r->c([1, 3, 5, 7]);
    my $v2 = $v1->get([-1, -2]);
    is_deeply($v2->values, [5, 7]);
  }
  
  # get - subroutine
  {
    my $v1 = $r->c([1, 2, 3, 4, 5]);
    my $v2 = $v1->get(sub { $_ > 3});
    is_deeply($v2->values, [4, 5]);
  }
  
  # get - character
  {
    my $v1 = $r->c([1, 2, 3, 4]);
    $r->names($v1 => $r->c(['a', 'b', 'c', 'd']));
    my $v2 = $v1->get($r->c(['b', 'd'])->as_character);
    is_deeply($v2->values, [2, 4]);
  }
  
  # get - logical
  {
    my $v1 = $r->c([1, 3, 5, 7]);
    my $logical_v = $r->c([0, 1, 0, 1, 1])->as_logical;
    my $v2 = $v1->get($logical_v);
    is_deeply($v2->values, [3, 7, undef]);
  }
  
  # get - at
  {
    my $v1 = $r->c([1, 2, 3, 4]);
    my $v2 = $v1->at(1)->get;
    is_deeply($v2->values, [1]);
  }
}
