use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::ElementFunc;

# as_character
{
  # as_character - Inf
  {
    my $a1 = array(Rstats::ElementFunc::Inf);
    my $a2 = r->as_character($a1);
    ok(r->is_character($a2));
    is_deeply($a2->values, ["Inf"]);
  }

  # as_character - NA
  {
    my $a1 = array(Rstats::ElementFunc::NA);
    my $a2 = r->as_character($a1);
    ok(r->is_character($a2));
    is_deeply($a2->values, ["NA"]);
  }

  # as_character - NaN
  {
    my $a1 = array(Rstats::ElementFunc::NaN);
    my $a2 = r->as_character($a1);
    ok(r->is_character($a2));
    is_deeply($a2->values, ["NaN"]);
  }
  
  # as_character - character
  {
    my $a1 = array(c("a"));
    my $a2 = r->as_character($a1);
    ok(r->is_character($a2));
    is($a2->values->[0], "a");
  }
  
  # as_character - complex
  {
    my $a1 = array(r->complex(1, 2));
    my $a2 = r->as_character($a1);
    ok(r->is_character($a2));
    is($a2->values->[0], "1+2i");
  }

  # as_character - complex, 0 + 0i
  {
    my $a1 = array(r->complex(0, 0));
    my $a2 = r->as_character($a1);
    ok(r->is_character($a2));
    is($a2->values->[0], "0+0i");
  }
  
  # as_character - numeric
  {
    my $a1 = array(c(1.1, 0));
    my $a2 = r->as_character($a1);
    ok(r->is_character($a2));
    is($a2->values->[0], "1.1");
    is($a2->values->[1], "0");
  }
  
  # as_character - logical
  {
    my $a1 = array(c(Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE));
    my $a2 = r->as_character($a1);
    ok(r->is_character($a2));
    is($a2->values->[0], "TRUE");
    is($a2->values->[1], "FALSE");
  }
}

# as_logical
{
  # as_logical - Inf
  {
    my $a1 = array(Rstats::ElementFunc::Inf);
    my $a2 = r->as_logical($a1);
    ok(r->is_logical($a2));
    is_deeply($a2->values, [1]);
  }

  # as_logical - NA
  {
    my $a1 = array(Rstats::ElementFunc::NA);
    my $a2 = r->as_logical($a1);
    ok(r->is_logical($a2));
    is_deeply($a2->elements, [Rstats::ElementFunc::NA]);
  }

  # as_logical - NaN
  {
    my $a1 = array(Rstats::ElementFunc::NaN);
    my $a2 = r->as_logical($a1);
    ok(r->is_logical($a2));
    is_deeply($a2->elements, [Rstats::ElementFunc::NA]);
  }
  
  # as_logical - character, number
  {
    my $a1 = array(c("1.23"));
    my $a2 = r->as_logical($a1);
    ok(r->is_logical($a2));
    ok($a2->elements->[0]->is_na);
  }

  # as_logical - character, pre and trailing space
  {
    my $a1 = array(c("  1  "));
    my $a2 = r->as_logical($a1);
    ok(r->is_logical($a2));
    ok($a2->elements->[0]->is_na);
  }

  # as_logical - character
  {
    my $a1 = array(c("a"));
    my $a2 = r->as_logical($a1);
    ok(r->is_logical($a2));
    ok($a2->elements->[0]->is_na);
  }
  
  # as_logical - complex
  {
    my $a1 = array(r->complex(1, 2));
    my $a2 = r->as_logical($a1);
    ok(r->is_logical($a2));
    is($a2->values->[0], 1);
  }

  # as_logical - complex, 0 + 0i
  {
    my $a1 = array(r->complex(0, 0));
    my $a2 = r->as_logical($a1);
    ok(r->is_logical($a2));
    is($a2->values->[0], 0);
  }
  
  # as_logical - numeric
  {
    my $a1 = array(c(1.1, 0));
    my $a2 = r->as_logical($a1);
    ok(r->is_logical($a2));
    is($a2->values->[0], 1);
    is($a2->values->[1], 0);
  }
  
  # as_logical - logical
  {
    my $a1 = array(c(Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE));
    my $a2 = r->as_logical($a1);
    ok(r->is_logical($a2));
    is($a2->values->[0], 1);
    is($a2->values->[1], 0);
  }
}

# as_integer
{
  # as_integer - Inf
  {
    my $a1 = array(Rstats::ElementFunc::Inf);
    my $a2 = r->as_integer($a1);
    ok(r->is_integer($a2));
    is_deeply($a2->elements, [Rstats::ElementFunc::NA]);
  }

  # as_integer - NA
  {
    my $a1 = array(Rstats::ElementFunc::NA);
    my $a2 = r->as_integer($a1);
    ok(r->is_integer($a2));
    is_deeply($a2->elements, [Rstats::ElementFunc::NA]);
  }

  # as_integer - NaN
  {
    my $a1 = array(Rstats::ElementFunc::NaN);
    my $a2 = r->as_integer($a1);
    ok(r->is_integer($a2));
    is_deeply($a2->elements, [Rstats::ElementFunc::NA]);
  }
  
  # as_integer - character, only real number, no sign
  {
    my $a1 = array(c("1.23"));
    my $a2 = r->as_integer($a1);
    ok(r->is_integer($a2));
    is($a2->values->[0], 1);
  }

  # as_integer - character, only real number, plus
  {
    my $a1 = array(c("+1"));
    my $a2 = r->as_integer($a1);
    ok(r->is_integer($a2));
    is($a2->values->[0], 1);
  }
  
  # as_integer - character, only real number, minus
  {
    my $a1 = array(c("-1.23"));
    my $a2 = r->as_integer($a1);
    ok(r->is_integer($a2));
    is($a2->values->[0], -1);
  }

  # as_integer - character, pre and trailing space
  {
    my $a1 = array(c("  1  "));
    my $a2 = r->as_integer($a1);
    ok(r->is_integer($a2));
    is($a2->values->[0], 1);
  }

  # as_integer - error
  {
    my $a1 = array(c("a"));
    my $a2 = r->as_integer($a1);
    ok(r->is_integer($a2));
    ok($a2->elements->[0]->is_na);
  }
  
  # as_integer - complex
  {
    my $a1 = array(r->complex(1, 2));
    my $a2 = r->as_integer($a1);
    ok(r->is_integer($a2));
    is($a2->values->[0], 1);
  }
  
  # as_integer - integer
  {
    my $a1 = array(c(1.1));
    my $a2 = r->as_integer($a1);
    ok(r->is_integer($a2));
    is($a2->values->[0], 1);
  }
  
  # as_integer - integer
  {
    my $a1 = array(c(1));
    my $a2 = r->as_integer($a1);
    ok(r->is_integer($a2));
    is($a2->values->[0], 1);
  }
  
  # as_integer - logical
  {
    my $a1 = array(c(Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE));
    my $a2 = r->as_integer($a1);
    ok(r->is_integer($a2));
    is($a2->values->[0], 1);
    is($a2->values->[1], 0);
  }
}

# as_numeric
{
  # as_numeric - Inf
  {
    my $a1 = array(Rstats::ElementFunc::Inf);
    my $a2 = r->as_numeric($a1);
    ok(r->is_numeric($a2));
    is_deeply($a2->values, ['Inf']);
  }

  # as_numeric - NA
  {
    my $a1 = array(Rstats::ElementFunc::NA);
    my $a2 = r->as_numeric($a1);
    ok(r->is_numeric($a2));
    is_deeply($a2->elements, [Rstats::ElementFunc::NA]);
  }

  # as_numeric - NaN
  {
    my $a1 = array(Rstats::ElementFunc::NaN);
    my $a2 = r->as_numeric($a1);
    ok(r->is_numeric($a2));
    is_deeply($a2->values, ['NaN']);
  }

  # as_numeric - character, only real number, no sign
  {
    my $a1 = array("1.23");
    my $a2 = r->as_numeric($a1);
    ok(r->is_numeric($a2));
    is($a2->values->[0], 1.23);
  }

  # as_numeric - character, only real number, plus
  {
    my $a1 = array("+1.23");
    my $a2 = r->as_numeric($a1);
    ok(r->is_numeric($a2));
    is($a2->values->[0], 1.23);
  }
  
  # as_numeric - character, only real number, minus
  {
    my $a1 = array("-1.23");
    my $a2 = r->as_numeric($a1);
    ok(r->is_numeric($a2));
    is($a2->values->[0], -1.23);
  }

  # as_numeric - character, pre and trailing space
  {
    my $a1 = array("  1  ");
    my $a2 = r->as_numeric($a1);
    ok(r->is_numeric($a2));
    is($a2->values->[0], 1);
  }

  # as_numeric - error
  {
    my $a1 = array("a");
    my $a2 = r->as_numeric($a1);
    ok(r->is_numeric($a2));
    ok($a2->elements->[0]->is_na);
  }
  
  # as_numeric - complex
  {
    my $a1 = array(r->complex(1, 2));
    my $a2 = r->as_numeric($a1);
    ok(r->is_numeric($a2));
    is($a2->values->[0], 1);
  }
  
  # as_numeric - numeric
  {
    my $a1 = array(1.1);
    my $a2 = r->as_numeric($a1);
    ok(r->is_numeric($a2));
    is($a2->values->[0], 1.1);
  }
  
  # as_numeric - integer
  {
    my $a1 = array(1);
    my $a2 = r->as_numeric($a1);
    ok(r->is_numeric($a2));
    is($a2->values->[0], 1);
  }
  
  # as_numeric - logical
  {
    my $a1 = array(c(Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE));
    my $a2 = r->as_numeric($a1);
    ok(r->is_numeric($a2));
    is($a2->values->[0], 1);
    is($a2->values->[1], 0);
  }
}

# as_complex
{
  # as_complex - Inf
  {
    my $a1 = array(Rstats::ElementFunc::Inf);
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is($a2->values->[0]->{re}, 'Inf');
    is($a2->values->[0]->{im}, 0);
  }

  # as_complex - NA
  {
    my $a1 = array(Rstats::ElementFunc::NA);
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is_deeply($a2->elements, [Rstats::ElementFunc::NA]);
  }

  # as_complex - NaN
  {
    my $a1 = array(Rstats::ElementFunc::NaN);
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is_deeply($a2->elements, [Rstats::ElementFunc::NA]);
  }

  # as_complex - character, only real number, no sign
  {
    my $a1 = array("1.23");
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is($a2->values->[0]->{re}, 1.23);
    is($a2->values->[0]->{im}, 0);
  }

  # as_complex - character, only real number, pre and trailing space
  {
    my $a1 = array("  1.23  ");
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is($a2->values->[0]->{re}, 1.23);
    is($a2->values->[0]->{im}, 0);
  }
  
  # as_complex - character, only real number, plus
  {
    my $a1 = array("+1.23");
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is($a2->values->[0]->{re}, 1.23);
    is($a2->values->[0]->{im}, 0);
  }
  
  # as_complex - character, only real number, minus
  {
    my $a1 = array("-1.23");
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is($a2->values->[0]->{re}, -1.23);
    is($a2->values->[0]->{im}, 0);
  }

  # as_complex - character, only image number, no sign
  {
    my $a1 = array("1.23i");
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is($a2->values->[0]->{re}, 0);
    is($a2->values->[0]->{im}, 1.23);
  }

  # as_complex - character, only image number, plus
  {
    my $a1 = array("+1.23i");
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is($a2->values->[0]->{re}, 0);
    is($a2->values->[0]->{im}, 1.23);
  }

  # as_complex - character, only image number, minus
  {
    my $a1 = array(["-1.23i"]);
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is($a2->values->[0]->{re}, 0);
    is($a2->values->[0]->{im}, -1.23);
  }

  # as_complex - character, real number and image number, no sign
  {
    my $a1 = array("2.5+1.23i");
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is($a2->values->[0]->{re}, 2.5);
    is($a2->values->[0]->{im}, 1.23);
  }

  # as_complex - character, real number and image number, plus
  {
    my $a1 = array("+2.5+1.23i");
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is($a2->values->[0]->{re}, 2.5);
    is($a2->values->[0]->{im}, 1.23);
  }
  
  # as_complex - character, real number and image number, minus
  {
    my $a1 = array("-2.5-1.23i");
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is($a2->values->[0]->{re}, -2.5);
    is($a2->values->[0]->{im}, -1.23);
  }

  # as_complex - character, pre and trailing space
  {
    my $a1 = array("  2.5+1.23i  ");
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is($a2->values->[0]->{re}, 2.5);
    is($a2->values->[0]->{im}, 1.23);
  }

  # as_complex - error
  {
    my $a1 = array("a");
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    ok($a2->elements->[0]->is_na);
  }

  # as_complex - error
  {
    my $a1 = array("i");
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    ok($a2->elements->[0]->is_na);
  }
        
  # as_complex - complex
  {
    my $a1 = array(r->complex(1, 2));
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is($a2->values->[0]->{re}, 1);
    is($a2->values->[0]->{im}, 2);
  }
  
  # as_complex - numeric
  {
    my $a1 = array(1.1);
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is($a2->values->[0]->{re}, 1.1);
    is($a2->values->[0]->{im}, 0);
  }
  
  # as_complex - integer
  {
    my $a1 = array(1);
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is($a2->values->[0]->{re}, 1);
    is($a2->values->[0]->{im}, 0);
  }
  
  # as_complex - logical
  {
    my $a1 = array(c(Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE));
    my $a2 = r->as_complex($a1);
    ok(r->is_complex($a2));
    is($a2->values->[0]->{re}, 1);
    is($a2->values->[0]->{im}, 0);
    is($a2->values->[1]->{re}, 0);
    is($a2->values->[1]->{im}, 0);
  }
}

# array decide type
{
  # array decide type - complex
  {
    my $a1 = array(c(r->complex(1, 2), r->complex(3, 4)));
    is($a1->values->[0]->{re}, 1);
    is($a1->values->[0]->{im}, 2);
    is($a1->values->[1]->{re}, 3);
    is($a1->values->[1]->{im}, 4);
    ok(r->is_complex($a1));
  }

  # array decide type - numerci
  {
    my $a1 = array(c(1, 2));
    is_deeply($a1->values, [1, 2]);
    ok(r->is_numeric($a1));
  }
  
  # array decide type - logical
  {
    my $a1 = array(c(Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE));
    is_deeply($a1->values, [1, 0]);
    ok(r->is_logical($a1));
  }

  # array decide type - character
  {
    my $a1 = array(c("c1", "c2"));
    is_deeply($a1->values, ["c1", "c2"]);
    ok(r->is_character($a1));
  }

  # array decide type - character, look like number
  {
    my $a1 = array(c("1", "2"));
    is_deeply($a1->values, ["1", "2"]);
    ok(r->is_character($a1));
  }

  # array decide type - Inf
  {
    my $a1 = array(Rstats::ElementFunc::Inf);
    is_deeply($a1->values, ['Inf']);
    ok(r->is_numeric($a1));
  }

  # array decide type - NaN
  {
    my $a1 = array(Rstats::ElementFunc::NaN);
    is_deeply($a1->values, ['NaN']);
    ok(r->is_numeric($a1));
  }

  # array decide type - NA
  {
    my $a1 = array(Rstats::ElementFunc::NA);
    is_deeply($a1->elements, [Rstats::ElementFunc::NA]);
    ok(r->is_logical($a1));
  }
}

# array upgrade mode
{
  # array decide mode - complex
  {
    my $a1 = array(c(1, r->complex(3, 4)));
    is($a1->values->[0]->{re}, 1);
    is($a1->values->[0]->{im}, 0);
    is($a1->values->[1]->{re}, 3);
    is($a1->values->[1]->{im}, 4);
    ok(r->is_complex($a1));
  }

}

# is_*
{
  # is_* - is_vector
  {
    my $array = C('1:24');
    ok(r->is_vector($array));
    ok(r->is_array($array));
  }

  # is_* - is_vector
  {
    my $array = array(C('1:24'));
    ok(!r->is_vector($array));
    ok(r->is_array($array));
  }
    
  # is_* - is_matrix
  {
    my $array = matrix(C('1:12'), 4, 3);
    ok(r->is_matrix($array));
    ok(r->is_array($array));
  }

  # is_* - is_array
  {
    my $array = array(C('1:24'), [4, 3, 2]);
    ok(r->is_array($array));
    ok(!r->is_vector($array));
    ok(!r->is_matrix($array));
  }
}

# is_* fro Rstats object
{
  # is_* - is_vector
  {
    my $array = array(C('1:24'));
    ok(!r->is_vector($array));
  }
  
  # is_* - is_matrix
  {
    my $array = matrix(C('1:24'), 4, 3);
    ok(r->is_matrix($array));
  }

  # is_* - is_array
  {
    my $array = array(C('1:12'), c(4, 3, 2));
    ok(r->is_array($array));
  }
}

# as_*
{
  # as_* - as_vector
  {
    my $array = array(C('1:24'), c(4, 3, 2));
    is_deeply(r->as_vector($array)->values, [1 .. 24]);
    is_deeply(r->dim(r->as_vector($array))->values, []);
  }
  
  # as_* - as_matrix, from vector
  {
    my $array = c(C('1:24'));
    is_deeply(r->as_matrix($array)->values, [1 .. 24]);
    is_deeply(r->dim(r->as_matrix($array))->values, [24, 1]);
  }

  # as_* - as_matrix, from matrix
  {
    my $array = matrix(C('1:12'), 4, 3);
    is_deeply(r->as_matrix($array)->values, [1 .. 12]);
    is_deeply(r->dim(r->as_matrix($array))->values, [4, 3]);
  }

  # as_* - as_matrix, from array
  {
    my $array = array(C('1:24'), c(4, 3, 2));
    is_deeply(r->as_matrix($array)->values, [1 .. 24]);
    is_deeply(r->dim(r->as_matrix($array))->values, [24, 1]);
  }
}

# as_* from Rstats object
{
  # as_* from Rstats object - as_vector
  {
    my $array = array(C('1:24'), c(4, 3, 2));
    is_deeply(r->as_vector($array)->values, [1 .. 24]);
    is_deeply(r->dim(r->as_vector($array))->values, []);
  }
  
  # as_* from Rstats object - as_matrix, from vector
  {
    my $array = C('1:24');
    is_deeply(r->as_matrix($array)->values, [1 .. 24]);
    is_deeply(r->dim(r->as_matrix($array))->values, [24, 1]);
  }

  # as_* from Rstats object - as_matrix, from matrix
  {
    my $array = matrix(C('1:12'), 4, 3);
    is_deeply(r->as_matrix($array)->values, [1 .. 12]);
    is_deeply(r->dim(r->as_matrix($array))->values, [4, 3]);
  }

  # as_* from Rstats object - as_matrix, from array
  {
    my $array = array(C('1:24'), c(4, 3, 2));
    is_deeply(r->as_matrix($array)->values, [1 .. 24]);
    is_deeply(r->dim(r->as_matrix($array))->values, [24, 1]);
  }
}
