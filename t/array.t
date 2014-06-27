use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

my $r = Rstats->new;

# which

# is_*
{
  # is_* - is_vector
  {
    my $array = $r->array('1:24');
    ok($array->is_vector->value);
    ok($array->is_array->value);
  }
  
  # is_* - is_matrix
  {
    my $array = $r->matrix('1:12', 4, 3);
    ok($array->is_matrix->value);
    ok($array->is_array->value);
  }

  # is_* - is_array
  {
    my $array = $r->matrix('1:12', [4, 3, 2]);
    ok($array->is_array->value);
  }
}

# is_* fro Rstats object
{
  # is_* - is_vector
  {
    my $array = $r->array('1:24');
    ok($r->is_vector($array)->value);
    ok($r->is_vector($array)->value);
  }
  
  # is_* - is_matrix
  {
    my $array = $r->matrix('1:24', 4, 3);
    ok($r->is_matrix($array)->value);
    ok($r->is_matrix($array)->value);
  }

  # is_* - is_array
  {
    my $array = $r->matrix('1:12', [4, 3, 2]);
    ok($r->is_array($array)->value);
  }
}

# as_*
{
  # as_* - as_vector
  {
    my $array = $r->array('1:24', [4, 3, 2]);
    is_deeply($array->as_vector->values, [1 .. 24]);
    is_deeply($array->as_vector->dim->values, [24]);
  }
  
  # as_* - as_matrix, from vector
  {
    my $array = $r->c('1:24');
    is_deeply($array->as_matrix->values, [1 .. 24]);
    is_deeply($array->as_matrix->dim->values, [24, 1]);
  }

  # as_* - as_matrix, from matrix
  {
    my $array = $r->matrix('1:12', 4, 3);
    is_deeply($array->as_matrix->values, [1 .. 12]);
    is_deeply($array->as_matrix->dim->values, [4, 3]);
  }

  # as_* - as_matrix, from array
  {
    my $array = $r->array('1:24', [4, 3, 2]);
    is_deeply($array->as_matrix->values, [1 .. 24]);
    is_deeply($array->as_matrix->dim->values, [24, 1]);
  }
}

# as_* from Rstats object
{
  # as_* from Rstats object - as_vector
  {
    my $array = $r->array('1:24', [4, 3, 2]);
    is_deeply($r->as_vector($array)->values, [1 .. 24]);
    is_deeply($r->as_vector($array)->dim->values, [24]);
  }
  
  # as_* from Rstats object - as_matrix, from vector
  {
    my $array = $r->c('1:24');
    is_deeply($r->as_matrix($array)->values, [1 .. 24]);
    is_deeply($r->as_matrix($array)->dim->values, [24, 1]);
  }

  # as_* from Rstats object - as_matrix, from matrix
  {
    my $array = $r->matrix('1:12', 4, 3);
    is_deeply($r->as_matrix($array)->values, [1 .. 12]);
    is_deeply($r->as_matrix($array)->dim->values, [4, 3]);
  }

  # as_* from Rstats object - as_matrix, from array
  {
    my $array = $r->array('1:24', [4, 3, 2]);
    is_deeply($r->as_matrix($array)->values, [1 .. 24]);
    is_deeply($r->as_matrix($array)->dim->values, [24, 1]);
  }
}

# operation
{
  # operation - add to original vector
  {
    my $a1 = $r->c([1, 2, 3]);
    $a1->at($r->length($a1) + 1)->set(6);
    is_deeply($a1->values, [1, 2, 3, 6]);
  }
  
  # operation - negation
  {
    my $a1 = $r->c([1, 2, 3]);
    my $a2 = -$a1;
    is_deeply($a2->values, [-1, -2, -3]);
  }
  
  # operation - add
  {
    my $a1 = $r->c([1, 2, 3]);
    my $a2 = $r->c([2, 3, 4]);
    my $v3 = $a1 + $a2;
    is_deeply($v3->values, [3, 5, 7]);
  }

  # operation - add(different element number)
  {
    my $a1 = $r->c([1, 2]);
    my $a2 = $r->c([3, 4, 5, 6]);
    my $v3 = $a1 + $a2;
    is_deeply($v3->values, [4, 6, 6, 8]);
  }
  
  # operation - add(real number)
  {
    my $a1 = $r->c([1, 2, 3]);
    my $a2 = $a1 + 1;
    is_deeply($a2->values, [2, 3, 4]);
  }
  
  # operation - subtract
  {
    my $a1 = $r->c([1, 2, 3]);
    my $a2 = $r->c([3, 3, 3]);
    my $v3 = $a1 - $a2;
    is_deeply($v3->values, [-2, -1, 0]);
  }

  # operation - subtract(real number)
  {
    my $a1 = $r->c([1, 2, 3]);
    my $a2 = $a1 - 1;
    is_deeply($a2->values, [0, 1, 2]);
  }

  # operation - subtract(real number, reverse)
  {
    my $a1 = $r->c([1, 2, 3]);
    my $a2 = 1 - $a1;
    is_deeply($a2->values, [0, -1, -2]);
  }
    
  # operation - mutiply
  {
    my $a1 = $r->c([1, 2, 3]);
    my $a2 = $r->c([2, 3, 4]);
    my $v3 = $a1 * $a2;
    is_deeply($v3->values, [2, 6, 12]);
  }

  # operation - mutiply(real number)
  {
    my $a1 = $r->c([1, 2, 3]);
    my $a2 = $a1 * 2;
    is_deeply($a2->values, [2, 4, 6]);
  }
  
  # operation - divide
  {
    my $a1 = $r->c([6, 3, 12]);
    my $a2 = $r->c([2, 3, 4]);
    my $v3 = $a1 / $a2;
    is_deeply($v3->values, [3, 1, 3]);
  }

  # operation - divide(real number)
  {
    my $a1 = $r->c([2, 4, 6]);
    my $a2 = $a1 / 2;
    is_deeply($a2->values, [1, 2, 3]);
  }

  # operation - divide(real number, reverse)
  {
    my $a1 = $r->c([2, 4, 6]);
    my $a2 = 2 / $a1;
    is_deeply($a2->values, [1, 1/2, 1/3]);
  }
  
  # operation - raise
  {
    my $a1 = $r->c([1, 2, 3]);
    my $a2 = $a1 ** 2;
    is_deeply($a2->values, [1, 4, 9]);
  }

  # operation - raise, reverse
  {
    my $a1 = $r->c([1, 2, 3]);
    my $a2 = 2 ** $a1;
    is_deeply($a2->values, [2, 4, 8]);
  }

  # operation - remainder
  {
    my $a1 = $r->c([1, 2, 3]);
    my $a2 = $a1 % 3;
    is_deeply($a2->values, [1, 2, 0]);
  }

  # operation - remainder, reverse
  {
    my $a1 = $r->c([1, 2, 3]);
    my $a2 = 2 % $a1;
    is_deeply($a2->values, [0, 0, 2]);
  }
}

# clone_without_values
{
  # clone_without_values - matrix
  {
    my $a1 = $r->matrix('1:24', 3, 2);
    $a1->rownames(['r1', 'r2', 'r3']);
    $a1->colnames(['c1', 'c2']);
    my $a2 = $a1->clone_without_values;
    ok($a2->is_matrix->value);
    is($a2->mode, 'numeric');
    is_deeply($a2->dim->values, [3, 2]);
    is_deeply($a2->rownames->values, ['r1', 'r2', 'r3']);
    is_deeply($a2->colnames->values, ['c1', 'c2']);
    is_deeply($a2->values, []);
  }
  
  # clone_without_values - matrix with value
  {
    my $a1 = $r->matrix('1:24', 3, 2);
    my $a2 = $a1->clone_without_values(values => [2 .. 25]);
    is_deeply($a2->values, [2 .. 25]);
  }
  
  # clone_without_values - vector
  {
    my $a1 = $r->matrix('1:24', 3, 2);
    $a1->names(['r1', 'r2', 'r3']);
    my $a2 = $a1->clone_without_values;
    is_deeply($a2->names->values, ['r1', 'r2', 'r3']);
  }
}

# value
{
  # value - none argument
  {
    my $a1 = $r->array('1:4');
    is($a1->value, 1);
  }

  # value - one-dimetion
  {
    my $a1 = $r->array('1:4');
    is($a1->value(2), 2);
  }
  
  # value - two-dimention
  {
    my $a1 = $r->array('1:12', [4, 3]);
    is($a1->value(3, 2), 7);
  }

  # value - two-dimention, as_vector
  {
    my $a1 = $r->array('1:12', [4, 3]);
    is($a1->as_vector->value(5), 5);
  }
  
  # value - three-dimention
  {
    my $a1 = $r->array('1:24', [4, 3, 1]);
    is($a1->value(3, 2, 1), 7);
  }
}

# to_string
{
  # to_string - one element
  {
    my $a1 = $r->array('0');
    my $a1_str = "$a1";
    $a1_str =~ s/[ \t]+/ /;
    my $expected = "[1] 0\n";
    is($a1_str, $expected);
  }

  # to_string - 2-dimention
  {
    my $a1 = $r->array('1:12', [4, 3]);
    my $a1_str = "$a1";
    $a1_str =~ s/[ \t]+/ /;

  my $expected = <<'EOS';
     [,1] [,2] [,3]
[1,] 1 5 9
[2,] 2 6 10
[3,] 3 7 11
[4,] 4 8 12
EOS
    $expected =~ s/[ \t]+/ /;
    
    is($a1_str, $expected);
  }

  # to_string - 1-dimention
  {
    my $a1 = $r->array('1:4');
    my $a1_str = "$a1";
    $a1_str =~ s/[ \t]+/ /;

  my $expected = <<'EOS';
[1] 1 2 3 4
EOS
    $expected =~ s/[ \t]+/ /;
    
    is($a1_str, $expected);
  }

  # to_string - 1-dimention, as_vector
  {
    my $a1 = $r->array('1:4');
    my $a2 = $a1->as_vector;
    my $a2_str = "$a2";
    $a2_str =~ s/[ \t]+/ /;

  my $expected = <<'EOS';
[1] 1 2 3 4
EOS
    $expected =~ s/[ \t]+/ /;
    
    is($a2_str, $expected);
  }

  # to_string - 1-dimention, as_matrix
  {
    my $a1 = $r->array('1:4');
    my $a2 = $a1->as_matrix;
    my $a2_str = "$a2";
    $a2_str =~ s/[ \t]+/ /;

  my $expected = <<'EOS';
   [,1]
[1,] 1
[2,] 2
[3,] 3
[4,] 4
EOS
    $expected =~ s/[ \t]+/ /;
    
    is($a2_str, $expected);
  }

  # to_string - 2-dimention
  {
    my $a1 = $r->array('1:12', [4, 3]);
    my $a2 = $a1->as_matrix;
    my $a2_str = "$a2";
    $a2_str =~ s/[ \t]+/ /;

  my $expected = <<'EOS';
     [,1] [,2] [,3]
[1,] 1 5 9
[2,] 2 6 10
[3,] 3 7 11
[4,] 4 8 12
EOS
    $expected =~ s/[ \t]+/ /;
    
    is($a2_str, $expected);
  }

  # to_string - 2-dimention, as_vector
  {
    my $a1 = $r->array('1:12', [4, 3]);
    my $a2 = $a1->as_vector;
    my $a2_str = "$a2";
    $a2_str =~ s/[ \t]+/ /;

  my $expected = <<'EOS';
[1] 1 2 3 4 5 6 7 8 9 10 11 12
EOS
    $expected =~ s/[ \t]+/ /;
    
    is($a2_str, $expected);
  }

  # to_string - 2-dimention, as_matrix
  {
    my $a1 = $r->array('1:12', [4, 3]);
    my $a2 = $a1->as_matrix;
    my $a2_str = "$a2";
    $a2_str =~ s/[ \t]+/ /;

  my $expected = <<'EOS';
     [,1] [,2] [,3]
[1,] 1 5 9
[2,] 2 6 10
[3,] 3 7 11
[4,] 4 8 12
EOS
    $expected =~ s/[ \t]+/ /;
    
    is($a2_str, $expected);
  }
  
  # to_string - 3-dimention
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a1_str = "$a1";
    $a1_str =~ s/[ \t]+/ /;

  my $expected = <<'EOS';
,,1
     [,1] [,2] [,3]
[1,] 1 5 9
[2,] 2 6 10
[3,] 3 7 11
[4,] 4 8 12
,,2
     [,1] [,2] [,3]
[1,] 13 17 21
[2,] 14 18 22
[3,] 15 19 23
[4,] 16 20 24
EOS
    $expected =~ s/[ \t]+/ /;
    
    is($a1_str, $expected);
  }

  # to_string - 3-dimention, as_vector
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a2 = $a1->as_vector;
    my $a2_str = "$a2";
    $a2_str =~ s/[ \t]+/ /;

  my $expected = <<'EOS';
[1] 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24
EOS
    $expected =~ s/[ \t]+/ /;
    
    is($a2_str, $expected);
  }

  # to_string - 3-dimention, as_matrix
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a2 = $a1->as_matrix;
    my $a2_str = "$a2";
    $a2_str =~ s/[ \t]+/ /;
    my $expected = <<'EOS';
     [,1]
[1,] 1
[2,] 2
[3,] 3
[4,] 4
[5,] 5
[6,] 6
[7,] 7
[8,] 8
[9,] 9
[10,] 10
[11,] 11
[12,] 12
[13,] 13
[14,] 14
[15,] 15
[16,] 16
[17,] 17
[18,] 18
[19,] 19
[20,] 20
[21,] 21
[22,] 22
[23,] 23
[24,] 24
EOS
    $expected =~ s/[ \t]+/ /;
    
    is($a2_str, $expected);
  }
  
  # to_string - 4 dimention
  {
    my $a1 = $r->array('1:120', [5, 4, 3, 2]);
    my $a1_str = "$a1";
    $a1_str =~ s/[ \t]+/ /;

  my $expected = <<'EOS';
,,,1
,,1
     [,1] [,2] [,3] [,4]
[1,] 1 6 11 16
[2,] 2 7 12 17
[3,] 3 8 13 18
[4,] 4 9 14 19
[5,] 5 10 15 20
,,2
     [,1] [,2] [,3] [,4]
[1,] 21 26 31 36
[2,] 22 27 32 37
[3,] 23 28 33 38
[4,] 24 29 34 39
[5,] 25 30 35 40
,,3
     [,1] [,2] [,3] [,4]
[1,] 41 46 51 56
[2,] 42 47 52 57
[3,] 43 48 53 58
[4,] 44 49 54 59
[5,] 45 50 55 60
,,,2
,,1
     [,1] [,2] [,3] [,4]
[1,] 61 66 71 76
[2,] 62 67 72 77
[3,] 63 68 73 78
[4,] 64 69 74 79
[5,] 65 70 75 80
,,2
     [,1] [,2] [,3] [,4]
[1,] 81 86 91 96
[2,] 82 87 92 97
[3,] 83 88 93 98
[4,] 84 89 94 99
[5,] 85 90 95 100
,,3
     [,1] [,2] [,3] [,4]
[1,] 101 106 111 116
[2,] 102 107 112 117
[3,] 103 108 113 118
[4,] 104 109 114 119
[5,] 105 110 115 120
EOS
    $expected =~ s/[ \t]+/ /;
    
    is($a1_str, $expected);
  }

}

# array
{
  # array - basic
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

# set 3-dimention
{
  # set 3-dimention
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a2 = $a1->at(4, 3, 2)->set(25);
    is_deeply($a2->values, [1 .. 23, 25]);
  }

  # set 3-dimention - one and tow dimention
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a2 = $a1->at(4, 3)->set(25);
    is_deeply($a2->values, [1 .. 11, 25, 13 .. 23, 25]);
  }

  # set 3-dimention - one and tow dimention, value is two
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a2 = $a1->at(4, 3)->set([25, 26]);
    is_deeply($a2->values, [1 .. 11, 25, 13 .. 23, 26]);
  }
  
  # set 3-dimention - one and three dimention, value is three
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a2 = $a1->at(2, '', 1)->set([31, 32, 33]);
    is_deeply($a2->values, [1, 31, 3, 4, 5, 32, 7, 8, 9, 33, 11 .. 24]);
  }

  # set 3-dimention
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a2 = $a1->at(4, '', 1)->set(sub { $_ * 2 });
    is_deeply($a2->values, [1, 2, 3, 8, 5, 6, 7, 16, 9, 10, 11, 24, 13 .. 24]);
  }
}
# get 3-dimention
{
  # get 3-dimention - minus
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
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
    is_deeply($r->dim($a2)->values, [1]);
  }

  # get 3-dimention - one value, drop => 0
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    my $a2 = $a1->get(3, 2, 1, {drop => 0});
    is_deeply($a2->values, [7]);
    is_deeply($r->dim($a2)->values, [1, 1, 1]);
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

  # get 3-dimention - all values 2
  {
    my $a1 = $r->array([map { $_ * 2 } (1 .. 24)], [4, 3, 2]);
    my $a2 = $a1->get([1, 2, 3, 4], [1, 2, 3], [1, 2]);
    is_deeply($a2->values, [map { $_ * 2 } (1 .. 24)]);
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
    is_deeply($v2->dim->values, [1]);
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

  # get - as_vector
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    is_deeply($a1->as_vector->get(5)->values, [5]);
  }

  # get - as_matrix
  {
    my $a1 = $r->array('1:24', [4, 3, 2]);
    is_deeply($a1->as_vector->get(5, 1)->values, [5]);
  }
}