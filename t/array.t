use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::Func;

# TODO
#   which
#   get - logical, undef

# logical operator
{
  # logical operator - &
  {
    my $a1 = c(TRUE, FALSE, TRUE, FALSE);
    my $a2 = c(TRUE, TRUE, FALSE, FALSE);
    my $a3 = $a1 & $a2;
    ok($a3->is_logical);
    is_deeply($a3->values, [qw/1 0 0 0/]);
  }

  # logical operator - |
  {
    my $a1 = c(TRUE, FALSE, TRUE, FALSE);
    my $a2 = c(TRUE, TRUE, FALSE, FALSE);
    my $a3 = $a1 | $a2;
    ok($a3->is_logical);
    is_deeply($a3->values, [qw/1 1 1 0/]);
  }
}

# comparison operator
{
  # comparison operator - >
  {
    my $a1 = array(c(0, 1, 2));
    my $a2 = array(c(1, 1, 1));
    my $a3 = $a1 > $a2;
    ok($a3->is_logical);
    is_deeply($a3->values, [qw/0 0 1/]);
  }

  # comparison operator - >=
  {
    my $a1 = array(c(0, 1, 2));
    my $a2 = array(c(1, 1, 1));
    my $a3 = $a1 >= $a2;
    ok($a3->is_logical);
    is_deeply($a3->values, [qw/0 1 1/]);
  }

  # comparison operator - <
  {
    my $a1 = array(c(0, 1, 2));
    my $a2 = array(c(1, 1, 1));
    my $a3 = $a1 < $a2;
    ok($a3->is_logical);
    is_deeply($a3->values, [qw/1 0 0/]);
  }

  # comparison operator - <=
  {
    my $a1 = array(c(0, 1, 2));
    my $a2 = array(c(1, 1, 1));
    my $a3 = $a1 <= $a2;
    ok($a3->is_logical);
    is_deeply($a3->values, [qw/1 1 0/]);
  }

  # comparison operator - ==
  {
    my $a1 = array(c(0, 1, 2));
    my $a2 = array(c(1, 1, 1));
    my $a3 = $a1 == $a2;
    ok($a3->is_logical);
    is_deeply($a3->values, [qw/0 1 0/]);
  }

  # comparison operator - !=
  {
    my $a1 = array(c(0, 1, 2));
    my $a2 = array(c(1, 1, 1));
    my $a3 = $a1 != $a2;
    ok($a3->is_logical);
    is_deeply($a3->values, [qw/1 0 1/]);
  }
}

# get
{
  # get - have dimnames
  {
    my $a1 = r->matrix(C('1:24'), 3, 2);
    r->dimnames($a1 => list(c('r1', 'r2', 'r3'), c('c1', 'c2')));
    my $a2 = $a1->get(c(1, 3), c(2));
    is_deeply($a2->dimnames->getin(1)->values, ['r1', 'r3']);
    is_deeply($a2->dimnames->getin(2)->values, ['c2']);
  }
  
  # get - have names
  {
    my $v1 = c(4, 5, 6);
    $v1->names(c("a", "b", "c"));
    my $v2 = $v1->get(c(1, 3));
    is_deeply($v2->values, [4, 6]);
    is_deeply($v2->names->values, ["a", "c"]);
  }

  # get - one value
  {
    my $v1 = c(1);
    my $v2 = $v1->get(1);
    is_deeply($v2->values, [1]);
    is_deeply(r->dim($v2)->values, [1]);
  }

  # get - single index
  {
    my $v1 = c(1, 2, 3, 4);
    my $v2 = $v1->get(1);
    is_deeply($v2->values, [1]);
  }
  
  # get - array
  {
    my $v1 = c(1, 3, 5, 7);
    my $v2 = $v1->get(c(1, 2));
    is_deeply($v2->values, [1, 3]);
  }
  
  # get - vector
  {
    my $v1 = c(1, 3, 5, 7);
    my $v2 = $v1->get(c(1, 2));
    is_deeply($v2->values, [1, 3]);
  }
  
  # get - minus number
  {
    my $v1 = c(1, 3, 5, 7);
    my $v2 = $v1->get(-1);
    is_deeply($v2->values, [3, 5, 7]);
  }

  # get - minus number + array
  {
    my $v1 = c(1, 3, 5, 7);
    my $v2 = $v1->get(c(-1, -2));
    is_deeply($v2->values, [5, 7]);
  }
  
  # get - character
  {
    my $v1 = c(1, 2, 3, 4);
    r->names($v1 => c('a', 'b', 'c', 'd'));
    my $v2 = $v1->get(c('b', 'd'));
    is_deeply($v2->values, [2, 4]);
  }

  # get - logical
  {
    my $v1 = c(1, 3, 5, 7);
    my $logical_v = c(FALSE, TRUE, FALSE, TRUE, TRUE);
    my $v2 = $v1->get($logical_v);
    is_deeply($v2->values, [3, 7, undef]);
  }

  # get - grep
  {
    my $v1 = c(1, 2, 3, 4, 5);
    my $v2 = $v1 > 3;
    my $v3 = $v1->get($v2);
    is_deeply($v3->values, [4, 5]);
  }
  
  # get - as_logical
  {
    my $v1 = c(1, 3, 5, 7);
    my $logical_v = r->as_logical(c(0, 1, 0, 1, 1));
    my $v2 = $v1->get($logical_v);
    is_deeply($v2->values, [3, 7, undef]);
  }

  # get - as_vector
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    is_deeply(r->as_vector($a1)->get(5)->values, [5]);
  }

  # get - as_matrix
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    is_deeply(r->as_vector($a1)->get(5, 1)->values, [5]);
  }
}

# to_string
{
  # to_string - character, 1 dimention
  {
    my $a1 = array(c("a", "b"));
    my $a1_str = "$a1";
    $a1_str =~ s/[ \t]+/ /;
    my $expected = qq/[1] "a" "b"\n/;
    is($a1_str, $expected);
  }

  # to_string - character, 2 dimention
  {
    my $a1 = array(C('1:4'), c(4, 1));
    my $a2 = r->as_character($a1);
    my $a2_str = "$a2";
    $a2_str =~ s/[ \t]+/ /;

  my $expected = <<'EOS';
     [,1]
[1,] "1"
[2,] "2"
[3,] "3"
[4,] "4"
EOS
    $expected =~ s/[ \t]+/ /;
    
    is($a2_str, $expected);
  }

  # to_string - character,3 dimention
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    $a1 = $a1->as_character;
    my $a1_str = "$a1";
    $a1_str =~ s/[ \t]+/ /;

  my $expected = <<'EOS';
,,1
     [,1] [,2] [,3]
[1,] "1" "5" "9"
[2,] "2" "6" "10"
[3,] "3" "7" "11"
[4,] "4" "8" "12"
,,2
     [,1] [,2] [,3]
[1,] "13" "17" "21"
[2,] "14" "18" "22"
[3,] "15" "19" "23"
[4,] "16" "20" "24"
EOS
    $expected =~ s/[ \t]+/ /;
    
    is($a1_str, $expected);
  }

  # to_string - one element
  {
    my $a1 = array(0);
    my $a1_str = "$a1";
    $a1_str =~ s/[ \t]+/ /;
    my $expected = "[1] 0\n";
    is($a1_str, $expected);
  }

  # to_string - 2-dimention
  {
    my $a1 = array(C('1:12'), c(4, 3));
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
    my $a1 = array(C('1:4'));
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
    my $a1 = array(C('1:4'));
    my $a2 = r->as_vector($a1);
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
    my $a1 = array(C('1:4'));
    my $a2 = r->as_matrix($a1);
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
  

  # to_string - 1-dimention, TRUE, FALSE
  {
    my $a1 = array(c(r->TRUE, r->FALSE));
    my $a1_str = "$a1";
    $a1_str =~ s/[ \t]+/ /;

  my $expected = <<'EOS';
[1] TRUE FALSE
EOS
    $expected =~ s/[ \t]+/ /;
    
    is($a1_str, $expected);
  }

  # to_string - 2-dimention
  {
    my $a1 = array(C('1:12'), c(4, 3));
    my $a2 = r->as_matrix($a1);
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
    my $a1 = array(C('1:12'), c(4, 3));
    my $a2 = r->as_vector($a1);
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
    my $a1 = array(C('1:12'), c(4, 3));
    my $a2 = r->as_matrix($a1);
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
    my $a1 = array(C('1:24'), c(4, 3, 2));
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
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = r->as_vector($a1);
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
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = r->as_matrix($a1);
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
    my $a1 = array(C('1:120'), c(5, 4, 3, 2));
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

# numeric operator auto upgrade
{
  # numeric operator auto upgrade - complex
  {
    my $a1 = array(c(r->complex(1,2), r->complex(3,4)));
    my $a2 = array(c(1, 2));
    my $a3 = $a1 + $a2;
    ok(r->is_complex($a3));
    is($a3->values->[0]->{re}, 2);
    is($a3->values->[0]->{im}, 2);
    is($a3->values->[1]->{re}, 5);
    is($a3->values->[1]->{im}, 4);
  }

  # numeric operator auto upgrade - numeric
  {
    my $a1 = array(c(1.1, 1.2));
    my $a2 = r->as_integer(array(c(1, 2)));
    my $a3 = $a1 + $a2;
    ok(r->is_numeric($a3));
    is_deeply($a3->values, [2.1, 3.2])
  }

  # numeric operator auto upgrade - integer
  {
    my $a1 = r->as_integer(array(c(3, 5)));
    my $a2 = array(c(r->TRUE, r->FALSE));
    my $a3 = $a1 + $a2;
    ok(r->is_integer($a3));
    is_deeply($a3->values, [4, 5])
  }
    
  # numeric operator auto upgrade - character, +
  {
    my $a1 = array(c("1", "2", "3"));
    my $a2 = array(c(1, 2, 3));
    eval { my $ret = $a1 + $a2 };
    like($@, qr/non-numeric argument to binary operator/);
  }

  # numeric operator auto upgrade - character, -
  {
    my $a1 = array(c("1", "2", "3"));
    my $a2 = array(c(1, 2, 3));
    eval { my $ret = $a1 - $a2 };
    like($@, qr/non-numeric argument to binary operator/);
  }

  # numeric operator auto upgrade - character, *
  {
    my $a1 = array(c("1", "2", "3"));
    my $a2 = array(c(1, 2, 3));
    eval { my $ret = $a1 * $a2 };
    like($@, qr/non-numeric argument to binary operator/);
  }

  # numeric operator auto upgrade - character, /
  {
    my $a1 = array(c("1", "2", "3"));
    my $a2 = array(c(1, 2, 3));
    eval { my $ret = $a1 / $a2 };
    like($@, qr/non-numeric argument to binary operator/);
  }

  # numeric operator auto upgrade - character, ^
  {
    my $a1 = array(c("1", "2", "3"));
    my $a2 = array(c(1, 2, 3));
    eval { my $ret = $a1 ** $a2 };
    like($@, qr/non-numeric argument to binary operator/);
  }

  # numeric operator auto upgrade - character, %
  {
    my $a1 = array(c("1", "2", "3"));
    my $a2 = array(c(1, 2, 3));
    eval { my $ret = $a1 % $a2 };
    like($@, qr/non-numeric argument to binary operator/);
  }
}

# clone
{
  # clone - matrix
  {
    my $a1 = r->matrix(C('1:24'), 3, 2);
    r->rownames($a1 => c('r1', 'r2', 'r3'));
    r->colnames($a1 => c('c1', 'c2'));
    my $a2 = $a1->clone(elements => []);
    ok(r->is_matrix($a2));
    is_deeply(r->dim($a2)->values, [3, 2]);
    is_deeply(r->rownames($a2)->values, ['r1', 'r2', 'r3']);
    is_deeply(r->colnames($a2)->values, ['c1', 'c2']);
    is_deeply($a2->values, []);
  }
  
  # clone - matrix with value
  {
    my $a1 = r->matrix(C('1:24'), 3, 2);
    my $a2 = $a1->clone;
    $a2->values([2 .. 25]);
    is_deeply($a2->values, [2 .. 25]);
  }
  
  # clone - vector
  {
    my $a1 = r->matrix(C('1:24'), 3, 2);
    r->names($a1 => c('r1', 'r2', 'r3'));
    my $a2 = $a1->clone;
    is_deeply(r->names($a2)->values, ['r1', 'r2', 'r3']);
  }
}

# get logical array
{
  # get logical array - basic
  {
    my $a1 = matrix(C('1:9'), 3, 3);
    my $a2 = matrix(c(T, F, F, F, T, F, F, F, T), 3, 3);
    my $a3 = $a1->get($a2);
    is_deeply($a3->values, [1, 5, 9]);
    is_deeply(r->dim($a3)->values, [3]);
  }
}

# set_diag
{
  # set_diag - 3 x 3
  {
    my $a1 = matrix(4, 3, 3);
    my $a2 = r->set_diag($a1, c(1, 2, 3));
    is_deeply($a1->values, [1, 4, 4, 4, 2, 4, 4, 4, 3]);
    is_deeply(r->dim($a1)->values, [3, 3]);
  }  

  # set_diag - repeat
  {
    my $a1 = matrix(4, 3, 3);
    my $a2 = r->set_diag($a1, 1);
    is_deeply($a1->values, [1, 4, 4, 4, 1, 4, 4, 4, 1]);
    is_deeply(r->dim($a1)->values, [3, 3]);
  }
  
  # set_diag - 2 x 3
  {
    my $a1 = matrix(4, 2, 3);
    my $a2 = r->set_diag($a1, c(1, 2));
    is_deeply($a1->values, [1, 4, 4, 2, 4, 4]);
    is_deeply(r->dim($a1)->values, [2, 3]);
  }  

  # set_diag - 3 x 2
  {
    my $a1 = matrix(4, 3, 2);
    my $a2 = r->set_diag($a1, c(1, 2));
    is_deeply($a1->values, [1, 4, 4, 4, 2, 4]);
    is_deeply(r->dim($a1)->values, [3, 2]);
  } 
}

# diag
{
  # diag - unit matrix
  {
    my $a1 = r->diag(3);
    is_deeply($a1->values, [1, 0, 0, 0, 1, 0, 0, 0, 1]);
    is_deeply(r->dim($a1)->values, [3, 3]);
  }

  # diag - basic
  {
    my $a1 = r->diag(c(1, 2, 3));
    is_deeply($a1->values, [1, 0, 0, 0, 2, 0, 0, 0, 3]);
    is_deeply(r->dim($a1)->values, [3, 3]);
  }  
}

# kronecker
{
  # kronecker - basic
  {
    my $a1 = array(C('1:12'), c(3, 4));
    my $a2 = array(C('1:24'), c(4, 3, 2));
    my $a3 = r->kronecker($a1, $a2);
    is_deeply($a3->values, [
      qw/
     1   2   3   4   2   4   6   8   3   6   9  12   5   6   7   8  10  12  14  16  15  18  21
    24   9  10  11  12  18  20  22  24  27  30  33  36   4   8  12  16   5  10  15  20   6  12
    18  24  20  24  28  32  25  30  35  40  30  36  42  48  36  40  44  48  45  50  55  60  54
    60  66  72   7  14  21  28   8  16  24  32   9  18  27  36  35  42  49  56  40  48  56  64
    45  54  63  72  63  70  77  84  72  80  88  96  81  90  99 108  10  20  30  40  11  22  33
    44  12  24  36  48  50  60  70  80  55  66  77  88  60  72  84  96  90 100 110 120  99 110
   121 132 108 120 132 144  13  14  15  16  26  28  30  32  39  42  45  48  17  18  19  20  34
    36  38  40  51  54  57  60  21  22  23  24  42  44  46  48  63  66  69  72  52  56  60  64
    65  70  75  80  78  84  90  96  68  72  76  80  85  90  95 100 102 108 114 120  84  88  92
    96 105 110 115 120 126 132 138 144  91  98 105 112 104 112 120 128 117 126 135 144 119 126
   133 140 136 144 152 160 153 162 171 180 147 154 161 168 168 176 184 192 189 198 207 216 130
   140 150 160 143 154 165 176 156 168 180 192 170 180 190 200 187 198 209 220 204 216 228 240
   210 220 230 240 231 242 253 264 252 264 276 288
      /]);
    is_deeply(r->dim($a3)->values, [12, 12, 2]);
  }

  # kronecker - reverse
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = array(C('1:12'), c(3, 4));
    my $a3 = r->kronecker($a1, $a2);
    is_deeply($a3->values, [
      qw/
 1   2   3   2   4   6   3   6   9   4   8  12   4   5   6   8  10  12  12  15  18  16  20
 24   7   8   9  14  16  18  21  24  27  28  32  36  10  11  12  20  22  24  30  33  36  40
 44  48   5  10  15   6  12  18   7  14  21   8  16  24  20  25  30  24  30  36  28  35  42
 32  40  48  35  40  45  42  48  54  49  56  63  56  64  72  50  55  60  60  66  72  70  77
 84  80  88  96   9  18  27  10  20  30  11  22  33  12  24  36  36  45  54  40  50  60  44
 55  66  48  60  72  63  72  81  70  80  90  77  88  99  84  96 108  90  99 108 100 110 120
110 121 132 120 132 144  13  26  39  14  28  42  15  30  45  16  32  48  52  65  78  56  70
 84  60  75  90  64  80  96  91 104 117  98 112 126 105 120 135 112 128 144 130 143 156 140
154 168 150 165 180 160 176 192  17  34  51  18  36  54  19  38  57  20  40  60  68  85 102
 72  90 108  76  95 114  80 100 120 119 136 153 126 144 162 133 152 171 140 160 180 170 187
204 180 198 216 190 209 228 200 220 240  21  42  63  22  44  66  23  46  69  24  48  72  84
105 126  88 110 132  92 115 138  96 120 144 147 168 189 154 176 198 161 184 207 168 192 216
210 231 252 220 242 264 230 253 276 240 264 288
      /]);
    is_deeply(r->dim($a3)->values, [12, 12, 2]);
  }
}

# pos_to_index
{
  # pos_to_index - first position
  {
    my $pos = 0;
    my $index = Rstats::Util::pos_to_index($pos, [4, 3, 2]);
    is_deeply($index, [1, 1, 1]);
  }
  
  # pos_to_index - some position
  {
    my $pos = 21;
    my $index = Rstats::Util::pos_to_index($pos, [4, 3, 2]);
    is_deeply($index, [2, 3, 2]);
  }

  # pos_to_index - last position
  {
    my $pos = 23;
    my $index = Rstats::Util::pos_to_index($pos, [4, 3, 2]);
    is_deeply($index, [4, 3, 2]);
  }
}

# outer
{
  # outer - basic
  my $a1 = array(C('1:2'), c(1, 2));
  my $a2 = array(C('1:24'), c(3, 4));
  my $a3 = r->outer($a1, $a2);
  is_deeply($a3->values, [qw/1  2  2  4  3  6  4  8  5 10  6 12  7 14  8 16  9 18 10 20 11 22 12 24/]);
  is_deeply(r->dim($a3)->values, [1, 2, 3, 4]);
}

# comparison operator numeric
{

  # comparison operator numeric - <
  {
    my $v1 = c(1, 2, 3);
    my $a1 = array($v1);
    my $a2 = array(c(2,1,3));
    my $a3 = $a1 < $a2;
    is_deeply($a3->elements, [Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE, Rstats::ElementFunc::FALSE]);
  }

  # comparison operator numeric - <, arguments count is different
  {
    my $a1 = array(c(1,2,3));
    my $a2 = array(c(2));
    my $a3 = $a1 < $a2;
    is_deeply($a3->elements, [Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE, Rstats::ElementFunc::FALSE]);
  }

  # comparison operator numeric - <=
  {
    my $a1 = array(c(1,2,3));
    my $a2 = array(c(2,1,3));
    my $a3 = $a1 <= $a2;
    is_deeply($a3->elements, [Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE, Rstats::ElementFunc::TRUE]);
  }

  # comparison operator numeric - <=, arguments count is different
  {
    my $a1 = array(c(1,2,3));
    my $a2 = array(c(2));
    my $a3 = $a1 <= $a2;
    is_deeply($a3->elements, [Rstats::ElementFunc::TRUE, Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE]);
  }

  # comparison operator numeric - >
  {
    my $a1 = array(c(1,2,3));
    my $a2 = array(c(2,1,3));
    my $a3 = $a1 > $a2;
    is_deeply($a3->elements, [Rstats::ElementFunc::FALSE, Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE]);
  }

  # comparison operator numeric - >, arguments count is different
  {
    my $a1 = array(c(1,2,3));
    my $a2 = array(c(2));
    my $a3 = $a1 > $a2;
    is_deeply($a3->elements, [Rstats::ElementFunc::FALSE, Rstats::ElementFunc::FALSE, Rstats::ElementFunc::TRUE]);
  }

  # comparison operator numeric - >=
  {
    my $a1 = array(c(1,2,3));
    my $a2 = array(c(2,1,3));
    my $a3 = $a1 >= $a2;
    is_deeply($a3->elements, [Rstats::ElementFunc::FALSE, Rstats::ElementFunc::TRUE, Rstats::ElementFunc::TRUE]);
  }

  # comparison operator numeric - >=, arguments count is different
  {
    my $a1 = array(c(1,2,3));
    my $a2 = array(c(2));
    my $a3 = $a1 >= $a2;
    is_deeply($a3->elements, [Rstats::ElementFunc::FALSE, Rstats::ElementFunc::TRUE, Rstats::ElementFunc::TRUE]);
  }

  # comparison operator numeric - ==
  {
    my $a1 = array(c(1,2));
    my $a2 = array(c(2,2));
    my $a3 = $a1 == $a2;
    is_deeply($a3->elements, [Rstats::ElementFunc::FALSE, Rstats::ElementFunc::TRUE]);
  }

  # comparison operator numeric - ==, arguments count is different
  {
    my $a1 = array(c(1,2));
    my $a2 = array(c(2));
    my $a3 = $a1 == $a2;
    is_deeply($a3->elements, [Rstats::ElementFunc::FALSE, Rstats::ElementFunc::TRUE]);
  }

  # comparison operator numeric - !=
  {
    my $a1 = array(c(1,2));
    my $a2 = array(c(2,2));
    my $a3 = $a1 != $a2;
    is_deeply($a3->elements, [Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE]);
  }

  # comparison operator numeric - !=, arguments count is different
  {
    my $a1 = array(c(1,2));
    my $a2 = array(c(2));
    my $a3 = $a1 != $a2;
    is_deeply($a3->elements, [Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE]);
  }
}

# bool context
{
  # bool context - one argument, true
  {
    my $a1 = array(1);
    if ($a1) {
      pass;
    }
    else {
      fail;
    }
  }
  
  # bool context - one argument, false
  {
    my $a1 = array(0);
    if ($a1) {
      fail;
    }
    else {
      pass;
    }
  }

  # bool context - two argument, true
  {
    my $a1 = array(3, 3);
    if ($a1) {
      pass;
    }
    else {
      fail;
    }
  }

  # bool context - two argument, true
  {
    my $a1 = r->NULL;
    eval {
      if ($a1) {
      
      }
    };
    like($@, qr/zero/);
  }
}

# operator
{
  # operator - add to original vector
  {
    my $a1 = c(1, 2, 3);
    $a1->at(r->length($a1) + 1)->set(6);
    is_deeply($a1->values, [1, 2, 3, 6]);
  }
  
  # operator - negation
  {
    my $a1 = c(1, 2, 3);
    my $a2 = -$a1;
    is_deeply($a2->values, [-1, -2, -3]);
  }
  
  # operator - add
  {
    my $a1 = c(1, 2, 3);
    my $a2 = c(2, 3, 4);
    my $v3 = $a1 + $a2;
    is_deeply($v3->values, [3, 5, 7]);
  }

  # operator - add(different element number)
  {
    my $a1 = c(1, 2);
    my $a2 = c(3, 4, 5, 6);
    my $v3 = $a1 + $a2;
    is_deeply($v3->values, [4, 6, 6, 8]);
  }
  
  # operator - add(real number)
  {
    my $a1 = c(1, 2, 3);
    my $a2 = $a1 + 1;
    is_deeply($a2->values, [2, 3, 4]);
  }
  
  # operator - subtract
  {
    my $a1 = c(1, 2, 3);
    my $a2 = c(3, 3, 3);
    my $v3 = $a1 - $a2;
    is_deeply($v3->values, [-2, -1, 0]);
  }

  # operator - subtract(real number)
  {
    my $a1 = c(1, 2, 3);
    my $a2 = $a1 - 1;
    is_deeply($a2->values, [0, 1, 2]);
  }

  # operator - subtract(real number, reverse)
  {
    my $a1 = c(1, 2, 3);
    my $a2 = 1 - $a1;
    is_deeply($a2->values, [0, -1, -2]);
  }
    
  # operator - mutiply
  {
    my $a1 = c(1, 2, 3);
    my $a2 = c(2, 3, 4);
    my $v3 = $a1 * $a2;
    is_deeply($v3->values, [2, 6, 12]);
  }

  # operator - mutiply(real number)
  {
    my $a1 = c(1, 2, 3);
    my $a2 = $a1 * 2;
    is_deeply($a2->values, [2, 4, 6]);
  }

  # operator - divide
  {
    my $a1 = c(6, 3, 12)->as_integer;
    my $a2 = c(2, 3, 4)->as_integer;
    my $v3 = $a1 / $a2;
    is_deeply($v3->values, [3, 1, 3]);
    ok($v3->is_double);
  }
  
  # operator - divide
  {
    my $a1 = c(6, 3, 12);
    my $a2 = c(2, 3, 4);
    my $v3 = $a1 / $a2;
    is_deeply($v3->values, [3, 1, 3]);
  }

  # operator - divide(real number)
  {
    my $a1 = c(2, 4, 6);
    my $a2 = $a1 / 2;
    is_deeply($a2->values, [1, 2, 3]);
  }

  # operator - divide(real number, reverse)
  {
    my $a1 = c(2, 4, 6);
    my $a2 = 2 / $a1;
    is_deeply($a2->values, [1, 1/2, 1/3]);
  }
  
  # operator - raise
  {
    my $a1 = c(1, 2, 3);
    my $a2 = $a1 ** 2;
    is_deeply($a2->values, [1, 4, 9]);
  }

  # operator - raise, reverse
  {
    my $a1 = c(1, 2, 3);
    my $a2 = 2 ** $a1;
    is_deeply($a2->values, [2, 4, 8]);
  }

  # operator - remainder
  {
    my $a1 = c(1, 2, 3);
    my $a2 = $a1 % 3;
    is_deeply($a2->values, [1, 2, 0]);
  }

  # operator - remainder, reverse
  {
    my $a1 = c(1, 2, 3);
    my $a2 = 2 % $a1;
    is_deeply($a2->values, [0, 0, 2]);
  }
}

# value
{
  # value - none argument
  {
    my $a1 = array(C('1:4'));
    is($a1->value, 1);
  }

  # value - one-dimetion
  {
    my $a1 = array(C('1:4'));
    is($a1->value(2), 2);
  }
  
  # value - two-dimention
  {
    my $a1 = array(C('1:12'), c(4, 3));
    is($a1->value(3, 2), 7);
  }

  # value - two-dimention, as_vector
  {
    my $a1 = array(C('1:12'), c(4, 3));
    is(r->as_vector($a1)->value(5), 5);
  }
  
  # value - three-dimention
  {
    my $a1 = array(C('1:24'), c(4, 3, 1));
    is($a1->value(3, 2, 1), 7);
  }
}

# array
{
  # array - basic
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    is_deeply($a1->values, [1 .. 24]);
    is_deeply(r->dim($a1)->values, [4, 3, 2]);
  }
  
  # array - dim option
  {
    my $a1 = array(C('1:24'), {dim => [4, 3, 2]});
    is_deeply($a1->values, [1 .. 24]);
    is_deeply(r->dim($a1)->values, [4, 3, 2]);
  }
}

# set 3-dimention
{
  # set 3-dimention
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = $a1->at(4, 3, 2)->set(25);
    is_deeply($a2->values, [1 .. 23, 25]);
  }

  # set 3-dimention - one and tow dimention
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = $a1->at(4, 3)->set(25);
    is_deeply($a2->values, [1 .. 11, 25, 13 .. 23, 25]);
  }

  # set 3-dimention - one and tow dimention, value is two
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = $a1->at(4, 3)->set(c(25, 26));
    is_deeply($a2->values, [1 .. 11, 25, 13 .. 23, 26]);
  }
  
  # set 3-dimention - one and three dimention, value is three
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = $a1->at(2, [], 1)->set(c(31, 32, 33));
    is_deeply($a2->values, [1, 31, 3, 4, 5, 32, 7, 8, 9, 33, 11 .. 24]);
  }
}

# get 3-dimention
{
  # get 3-dimention - minus
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = $a1->get(c(-1, -2), c(-1, -2));
    is_deeply($a2->values, [11, 12, 23, 24]);
    is_deeply(r->dim($a2)->values, [2, 2]);
  }
  
  # get 3-dimention - dimention one
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = $a1->get(2);
    is_deeply($a2->values, [2, 6, 10, 14, 18 ,22]);
    is_deeply(r->dim($a2)->values, [3, 2]);
  }

  # get 3-dimention - dimention two
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = $a1->get(c(), 2);
    is_deeply($a2->values, [5, 6, 7, 8, 17, 18, 19, 20]);
    is_deeply(r->dim($a2)->values, [4, 2]);
  }

  # get 3-dimention - dimention three
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = $a1->get(c(), c(), 2);
    is_deeply($a2->values, [13 .. 24]);
    is_deeply(r->dim($a2)->values, [4, 3]);
  }
  
  # get 3-dimention - one value
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = $a1->get(3, 2, 1);
    is_deeply($a2->values, [7]);
    is_deeply(r->dim($a2)->values, [1]);
  }

  # get 3-dimention - one value, drop => 0
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = $a1->get(3, 2, 1, {drop => 0});
    is_deeply($a2->values, [7]);
    is_deeply(r->dim($a2)->values, [1, 1, 1]);
  }
  
  # get 3-dimention - dimention one and two
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = $a1->get(1, 2);
    is_deeply($a2->values, [5, 17]);
    is_deeply(r->dim($a2)->values, [2]);
  }
  # get 3-dimention - dimention one and three
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = $a1->get(3, [], 2);
    is_deeply($a2->values, [15, 19, 23]);
    is_deeply(r->dim($a2)->values, [3]);
  }

  # get 3-dimention - dimention two and three
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = $a1->get(c(), 1, 2);
    is_deeply($a2->values, [13, 14, 15, 16]);
    is_deeply(r->dim($a2)->values, [4]);
  }
  
  # get 3-dimention - all values
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = $a1->get(c(1, 2, 3, 4), c(1, 2, 3), c(1, 2));
    is_deeply($a2->values, [1 .. 24]);
    is_deeply(r->dim($a2)->values, [4, 3, 2]);
  }

  # get 3-dimention - all values 2
  {
    my $a1 = array(c(map { $_ * 2 } (1 .. 24)), c(4, 3, 2));
    my $a2 = $a1->get(c(1, 2, 3, 4), c(1, 2, 3), c(1, 2));
    is_deeply($a2->values, [map { $_ * 2 } (1 .. 24)]);
    is_deeply(r->dim($a2)->values, [4, 3, 2]);
  }
  
  # get 3-dimention - some values
  {
    my $a1 = array(C('1:24'), c(4, 3, 2));
    my $a2 = $a1->get(c(2, 3), c(1, 3), c(1, 2));
    is_deeply($a2->values, [2, 3, 10, 11, 14, 15, 22, 23]);
    is_deeply(r->dim($a2)->values, [2, 2, 2]);
  }
}

# pos
{
  my $a1 = array(C('1:24'), c(4, 3, 2));
  my $dim = [4, 3, 2];
  
  {
    my $value = Rstats::Util::pos([4, 3, 2], $dim);
    is($value, 24);
  }
  
  {
    my $value = Rstats::Util::pos([3, 3, 2], $dim);
    is($value, 23);
  }
}

# cross_product
{
  my $values = [
    ['a1', 'a2'],
    ['b1', 'b2'],
    ['c1', 'c2']
  ];
  
  my $a1 = array(C('1:3'));
  my $result =  Rstats::Util::cross_product($values);
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

