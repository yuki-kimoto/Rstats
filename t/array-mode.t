use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::ElementsFunc;

# array upgrade mode
{
  # array decide mode - complex
  {
    my $x0 = r->complex(3, 4);
    my $x0_1 = c(1, $x0);
    my $x1 = array($x0_1);
    is($x1->values->[0]->{re}, 1);
    is($x1->values->[0]->{im}, 0);
    is($x1->values->[1]->{re}, 3);
    is($x1->values->[1]->{im}, 4);
    ok(r->is_complex($x1));
  }

}

# as_character
{
  # as_character - complex
  {
    my $x0 = r->complex(1, 2);
    "$x0";
    
    my $x1 = array(r->complex(1, 2));
    my $x2 = r->as_character($x1);
    ok(r->is_character($x2));
    is($x2->values->[0], "1+2i");
  }

  # as_character - NA
  {
    my $r = Rstats::ElementsFunc::logical(1);
    my $q = Rstats::ElementsFunc::Inf();
    my $p = Rstats::ElementsFunc::NA();
    my $x1 = array(Rstats::ElementsFunc::NA);
    my $x2 = r->as_character($x1);
    ok(r->is_character($x2));
    is_deeply($x2->values, ["NA"]);
  }

  # as_character - Inf
  {
    my $x1 = array(Rstats::ElementsFunc::Inf);
    my $x2 = r->as_character($x1);
    ok(r->is_character($x2));
    is_deeply($x2->values, ["Inf"]);
  }

  # as_character - NaN
  {
    my $x1 = array(Rstats::ElementsFunc::NaN);
    my $x2 = r->as_character($x1);
    ok(r->is_character($x2));
    is_deeply($x2->values, ["NaN"]);
  }
  
  # as_character - character
  {
    my $x1 = array(c("a"));
    my $x2 = r->as_character($x1);
    ok(r->is_character($x2));
    is($x2->values->[0], "a");
  }
  
  # as_character - complex, 0 + 0i
  {
    my $x1 = array(r->complex(0, 0));
    my $x2 = r->as_character($x1);
    ok(r->is_character($x2));
    is($x2->values->[0], "0+0i");
  }
  
  # as_character - numeric
  {
    my $x1 = array(c(1.1, 0));
    my $x2 = r->as_character($x1);
    ok(r->is_character($x2));
    is($x2->values->[0], 1.1);
    is($x2->values->[1], "0");
  }
  
  # as_character - logical
  {
    my $x1 = array(c(Rstats::ElementsFunc::TRUE, Rstats::ElementsFunc::FALSE));
    my $x2 = r->as_character($x1);
    ok(r->is_character($x2));
    is($x2->values->[0], "TRUE");
    is($x2->values->[1], "FALSE");
  }
}

# as_logical
{
  # as_logical - Inf
  {
    my $x1 = array(Rstats::ElementsFunc::Inf);
    my $x2 = r->as_logical($x1);
    ok(r->is_logical($x2));
    is_deeply($x2->values, [1]);
  }

  # as_logical - NA
  {
    my $x1 = array(Rstats::ElementsFunc::NA);
    my $x2 = r->as_logical($x1);
    ok(r->is_logical($x2));
    is_deeply($x2->decompose_elements, [Rstats::ElementsFunc::NA]);
  }

  # as_logical - NaN
  {
    my $x1 = array(Rstats::ElementsFunc::NaN);
    my $x2 = r->as_logical($x1);
    ok(r->is_logical($x2));
    is_deeply($x2->decompose_elements, [Rstats::ElementsFunc::NA]);
  }
  
  # as_logical - character, number
  {
    my $x1 = array(c("1.23"));
    my $x2 = r->as_logical($x1);
    ok(r->is_logical($x2));
    ok($x2->decompose_elements->[0]->is_na);
  }

  # as_logical - character, pre and trailing space
  {
    my $x1 = array(c("  1  "));
    my $x2 = r->as_logical($x1);
    ok(r->is_logical($x2));
    ok($x2->decompose_elements->[0]->is_na);
  }

  # as_logical - character
  {
    my $x1 = array(c("a"));
    my $x2 = r->as_logical($x1);
    ok(r->is_logical($x2));
    ok($x2->decompose_elements->[0]->is_na);
  }
  
  # as_logical - complex
  {
    my $x1 = array(r->complex(1, 2));
    my $x2 = r->as_logical($x1);
    ok(r->is_logical($x2));
    is($x2->values->[0], 1);
  }

  # as_logical - complex, 0 + 0i
  {
    my $x1 = array(r->complex(0, 0));
    my $x2 = r->as_logical($x1);
    ok(r->is_logical($x2));
    is($x2->values->[0], 0);
  }
  
  # as_logical - numeric
  {
    my $x1 = array(c(1.1, 0));
    my $x2 = r->as_logical($x1);
    ok(r->is_logical($x2));
    is($x2->values->[0], 1);
    is($x2->values->[1], 0);
  }
  
  # as_logical - logical
  {
    my $x1 = array(c(Rstats::ElementsFunc::TRUE, Rstats::ElementsFunc::FALSE));
    my $x2 = r->as_logical($x1);
    ok(r->is_logical($x2));
    is($x2->values->[0], 1);
    is($x2->values->[1], 0);
  }
}

# as_integer
{
  # as_integer - Inf
  {
    my $x1 = array(Rstats::ElementsFunc::Inf);
    my $x2 = r->as_integer($x1);
    ok(r->is_integer($x2));
    is_deeply($x2->decompose_elements, [Rstats::ElementsFunc::NA]);
  }

  # as_integer - NA
  {
    my $x1 = array(Rstats::ElementsFunc::NA);
    my $x2 = r->as_integer($x1);
    ok(r->is_integer($x2));
    is_deeply($x2->decompose_elements, [Rstats::ElementsFunc::NA]);
  }

  # as_integer - NaN
  {
    my $x1 = array(Rstats::ElementsFunc::NaN);
    my $x2 = r->as_integer($x1);
    ok(r->is_integer($x2));
    is_deeply($x2->decompose_elements, [Rstats::ElementsFunc::NA]);
  }
  
  # as_integer - character, only real number, no sign
  {
    my $x1 = array(c("1.23"));
    my $x2 = r->as_integer($x1);
    ok(r->is_integer($x2));
    is($x2->values->[0], 1);
  }

  # as_integer - character, only real number, plus
  {
    my $x1 = array(c("+1"));
    my $x2 = r->as_integer($x1);
    ok(r->is_integer($x2));
    is($x2->values->[0], 1);
  }
  
  # as_integer - character, only real number, minus
  {
    my $x1 = array(c("-1.23"));
    my $x2 = r->as_integer($x1);
    ok(r->is_integer($x2));
    is($x2->values->[0], -1);
  }

  # as_integer - character, pre and trailing space
  {
    my $x1 = array(c("  1  "));
    my $x2 = r->as_integer($x1);
    ok(r->is_integer($x2));
    is($x2->values->[0], 1);
  }

  # as_integer - error
  {
    my $x1 = array(c("a"));
    my $x2 = r->as_integer($x1);
    ok(r->is_integer($x2));
    ok($x2->decompose_elements->[0]->is_na);
  }
  
  # as_integer - complex
  {
    my $x1 = array(r->complex(1, 2));
    my $x2 = r->as_integer($x1);
    ok(r->is_integer($x2));
    is($x2->values->[0], 1);
  }
  
  # as_integer - integer
  {
    my $x1 = array(c(1.1));
    my $x2 = r->as_integer($x1);
    ok(r->is_integer($x2));
    is($x2->values->[0], 1);
  }
  
  # as_integer - integer
  {
    my $x1 = array(c(1));
    my $x2 = r->as_integer($x1);
    ok(r->is_integer($x2));
    is($x2->values->[0], 1);
  }
  
  # as_integer - logical
  {
    my $x1 = array(c(Rstats::ElementsFunc::TRUE, Rstats::ElementsFunc::FALSE));
    my $x2 = r->as_integer($x1);
    ok(r->is_integer($x2));
    is($x2->values->[0], 1);
    is($x2->values->[1], 0);
  }
}

# as_numeric
{
  # as_numeric - Inf
  {
    my $x1 = array(Rstats::ElementsFunc::Inf);
    my $x2 = r->as_numeric($x1);
    ok(r->is_numeric($x2));
    is_deeply($x2->values, ['Inf']);
  }

  # as_numeric - NA
  {
    my $x1 = array(Rstats::ElementsFunc::NA);
    my $x2 = r->as_numeric($x1);
    ok(r->is_numeric($x2));
    is_deeply($x2->decompose_elements, [Rstats::ElementsFunc::NA]);
  }

  # as_numeric - NaN
  {
    my $x1 = array(Rstats::ElementsFunc::NaN);
    my $x2 = r->as_numeric($x1);
    ok(r->is_numeric($x2));
    is_deeply($x2->values, ['NaN']);
  }

  # as_numeric - character, only real number, no sign
  {
    my $x1 = array("1.23");
    my $x2 = r->as_numeric($x1);
    ok(r->is_numeric($x2));
    is($x2->values->[0], 1.23);
  }

  # as_numeric - character, only real number, plus
  {
    my $x1 = array("+1.23");
    my $x2 = r->as_numeric($x1);
    ok(r->is_numeric($x2));
    is($x2->values->[0], 1.23);
  }
  
  # as_numeric - character, only real number, minus
  {
    my $x1 = array("-1.23");
    my $x2 = r->as_numeric($x1);
    ok(r->is_numeric($x2));
    is($x2->values->[0], -1.23);
  }

  # as_numeric - character, pre and trailing space
  {
    my $x1 = array("  1  ");
    my $x2 = r->as_numeric($x1);
    ok(r->is_numeric($x2));
    is($x2->values->[0], 1);
  }

  # as_numeric - error
  {
    my $x1 = array("a");
    my $x2 = r->as_numeric($x1);
    ok(r->is_numeric($x2));
    ok($x2->decompose_elements->[0]->is_na);
  }
  
  # as_numeric - complex
  {
    my $x1 = array(r->complex(1, 2));
    my $x2 = r->as_numeric($x1);
    ok(r->is_numeric($x2));
    is($x2->values->[0], 1);
  }
  
  # as_numeric - numeric
  {
    my $x1 = array(1.1);
    my $x2 = r->as_numeric($x1);
    ok(r->is_numeric($x2));
    is($x2->values->[0], 1.1);
  }
  
  # as_numeric - integer
  {
    my $x1 = array(1);
    my $x2 = r->as_numeric($x1);
    ok(r->is_numeric($x2));
    is($x2->values->[0], 1);
  }
  
  # as_numeric - logical
  {
    my $x1 = array(c(Rstats::ElementsFunc::TRUE, Rstats::ElementsFunc::FALSE));
    my $x2 = r->as_numeric($x1);
    ok(r->is_numeric($x2));
    is($x2->values->[0], 1);
    is($x2->values->[1], 0);
  }
}

# as_complex
{
  # as_complex - Inf
  {
    my $x1 = array(Rstats::ElementsFunc::Inf);
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is($x2->values->[0]->{re}, 'Inf');
    is($x2->values->[0]->{im}, 0);
  }

  # as_complex - NA
  {
    my $x1 = array(Rstats::ElementsFunc::NA);
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is_deeply($x2->decompose_elements, [Rstats::ElementsFunc::NA]);
  }

  # as_complex - NaN
  {
    my $x1 = array(Rstats::ElementsFunc::NaN);
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is_deeply($x2->decompose_elements, [Rstats::ElementsFunc::NA]);
  }

  # as_complex - character, only real number, no sign
  {
    my $x1 = array("1.23");
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is($x2->values->[0]->{re}, 1.23);
    is($x2->values->[0]->{im}, 0);
  }

  # as_complex - character, only real number, pre and trailing space
  {
    my $x1 = array("  1.23  ");
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is($x2->values->[0]->{re}, 1.23);
    is($x2->values->[0]->{im}, 0);
  }
  
  # as_complex - character, only real number, plus
  {
    my $x1 = array("+1.23");
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is($x2->values->[0]->{re}, 1.23);
    is($x2->values->[0]->{im}, 0);
  }
  
  # as_complex - character, only real number, minus
  {
    my $x1 = array("-1.23");
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is($x2->values->[0]->{re}, -1.23);
    is($x2->values->[0]->{im}, 0);
  }

  # as_complex - character, only image number, no sign
  {
    my $x1 = array("1.23i");
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is($x2->values->[0]->{re}, 0);
    is($x2->values->[0]->{im}, 1.23);
  }

  # as_complex - character, only image number, plus
  {
    my $x1 = array("+1.23i");
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is($x2->values->[0]->{re}, 0);
    is($x2->values->[0]->{im}, 1.23);
  }

  # as_complex - character, only image number, minus
  {
    my $x1 = array(["-1.23i"]);
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is($x2->values->[0]->{re}, 0);
    is($x2->values->[0]->{im}, -1.23);
  }

  # as_complex - character, real number and image number, no sign
  {
    my $x1 = array("2.5+1.23i");
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is($x2->values->[0]->{re}, 2.5);
    is($x2->values->[0]->{im}, 1.23);
  }

  # as_complex - character, real number and image number, plus
  {
    my $x1 = array("+2.5+1.23i");
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is($x2->values->[0]->{re}, 2.5);
    is($x2->values->[0]->{im}, 1.23);
  }
  
  # as_complex - character, real number and image number, minus
  {
    my $x1 = array("-2.5-1.23i");
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is($x2->values->[0]->{re}, -2.5);
    is($x2->values->[0]->{im}, -1.23);
  }

  # as_complex - character, pre and trailing space
  {
    my $x1 = array("  2.5+1.23i  ");
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is($x2->values->[0]->{re}, 2.5);
    is($x2->values->[0]->{im}, 1.23);
  }

  # as_complex - error
  {
    my $x1 = array("a");
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    ok($x2->decompose_elements->[0]->is_na);
  }

  # as_complex - error
  {
    my $x1 = array("i");
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    ok($x2->decompose_elements->[0]->is_na);
  }
        
  # as_complex - complex
  {
    my $x1 = array(r->complex(1, 2));
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is($x2->values->[0]->{re}, 1);
    is($x2->values->[0]->{im}, 2);
  }
  
  # as_complex - numeric
  {
    my $x1 = array(1.1);
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is($x2->values->[0]->{re}, 1.1);
    is($x2->values->[0]->{im}, 0);
  }
  
  # as_complex - integer
  {
    my $x1 = array(1);
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is($x2->values->[0]->{re}, 1);
    is($x2->values->[0]->{im}, 0);
  }
  
  # as_complex - logical
  {
    my $x1 = array(c(Rstats::ElementsFunc::TRUE, Rstats::ElementsFunc::FALSE));
    my $x2 = r->as_complex($x1);
    ok(r->is_complex($x2));
    is($x2->values->[0]->{re}, 1);
    is($x2->values->[0]->{im}, 0);
    is($x2->values->[1]->{re}, 0);
    is($x2->values->[1]->{im}, 0);
  }
}

# array decide type
{
  # array decide type - complex
  {
    my $x1 = array(c(r->complex(1, 2), r->complex(3, 4)));
    is($x1->values->[0]->{re}, 1);
    is($x1->values->[0]->{im}, 2);
    is($x1->values->[1]->{re}, 3);
    is($x1->values->[1]->{im}, 4);
    ok(r->is_complex($x1));
  }

  # array decide type - numerci
  {
    my $x1 = array(c(1, 2));
    is_deeply($x1->values, [1, 2]);
    ok(r->is_numeric($x1));
  }
  
  # array decide type - logical
  {
    my $x1 = array(c(Rstats::ElementsFunc::TRUE, Rstats::ElementsFunc::FALSE));
    is_deeply($x1->values, [1, 0]);
    ok(r->is_logical($x1));
  }

  # array decide type - character
  {
    my $x1 = array(c("c1", "c2"));
    is_deeply($x1->values, ["c1", "c2"]);
    ok(r->is_character($x1));
  }

  # array decide type - character, look like number
  {
    my $x1 = array(c("1", "2"));
    is_deeply($x1->values, ["1", "2"]);
    ok(r->is_character($x1));
  }

  # array decide type - Inf
  {
    my $x1 = array(Rstats::ElementsFunc::Inf);
    is_deeply($x1->values, ['Inf']);
    ok(r->is_numeric($x1));
  }

  # array decide type - NaN
  {
    my $x1 = array(Rstats::ElementsFunc::NaN);
    is_deeply($x1->values, ['NaN']);
    ok(r->is_numeric($x1));
  }

  # array decide type - NA
  {
    my $x1 = array(Rstats::ElementsFunc::NA);
    is_deeply($x1->decompose_elements, [Rstats::ElementsFunc::NA]);
    ok(r->is_logical($x1));
  }
}

# is_*
{
  # is_* - is_vector
  {
    my $x = ve('1:24');
    ok(r->is_vector($x));
    ok(!r->is_array($x));
  }

  # is_* - is_vector
  {
    my $x = array(ve('1:24'));
    ok(!r->is_vector($x));
    ok(r->is_array($x));
  }
    
  # is_* - is_matrix
  {
    my $x = matrix(ve('1:12'), 4, 3);
    ok(r->is_matrix($x));
    ok(r->is_array($x));
  }

  # is_* - is_array
  {
    my $x = array(ve('1:24'), [4, 3, 2]);
    ok(r->is_array($x));
    ok(!r->is_vector($x));
    ok(!r->is_matrix($x));
  }
}

# is_* fro Rstats object
{
  # is_* - is_vector
  {
    my $x = array(ve('1:24'));
    ok(!r->is_vector($x));
  }
  
  # is_* - is_matrix
  {
    my $x = matrix(ve('1:24'), 4, 3);
    ok(r->is_matrix($x));
  }

  # is_* - is_array
  {
    my $x = array(ve('1:12'), c(4, 3, 2));
    ok(r->is_array($x));
  }
}

# as_*
{
  # as_* - as_vector
  {
    my $x = array(ve('1:24'), c(4, 3, 2));
    is_deeply(r->as_vector($x)->values, [1 .. 24]);
    is_deeply(r->dim(r->as_vector($x))->values, []);
  }
  
  # as_* - as_matrix, from vector
  {
    my $x = c(ve('1:24'));
    is_deeply(r->as_matrix($x)->values, [1 .. 24]);
    is_deeply(r->dim(r->as_matrix($x))->values, [24, 1]);
  }

  # as_* - as_matrix, from matrix
  {
    my $x = matrix(ve('1:12'), 4, 3);
    is_deeply(r->as_matrix($x)->values, [1 .. 12]);
    is_deeply(r->dim(r->as_matrix($x))->values, [4, 3]);
  }

  # as_* - as_matrix, from array
  {
    my $x = array(ve('1:24'), c(4, 3, 2));
    is_deeply(r->as_matrix($x)->values, [1 .. 24]);
    is_deeply(r->dim(r->as_matrix($x))->values, [24, 1]);
  }
}

# as_* from Rstats object
{
  # as_* from Rstats object - as_vector
  {
    my $x = array(ve('1:24'), c(4, 3, 2));
    is_deeply(r->as_vector($x)->values, [1 .. 24]);
    is_deeply(r->dim(r->as_vector($x))->values, []);
  }
  
  # as_* from Rstats object - as_matrix, from vector
  {
    my $x = ve('1:24');
    is_deeply(r->as_matrix($x)->values, [1 .. 24]);
    is_deeply(r->dim(r->as_matrix($x))->values, [24, 1]);
  }

  # as_* from Rstats object - as_matrix, from matrix
  {
    my $x = matrix(ve('1:12'), 4, 3);
    is_deeply(r->as_matrix($x)->values, [1 .. 12]);
    is_deeply(r->dim(r->as_matrix($x))->values, [4, 3]);
  }

  # as_* from Rstats object - as_matrix, from array
  {
    my $x = array(ve('1:24'), c(4, 3, 2));
    is_deeply(r->as_matrix($x)->values, [1 .. 24]);
    is_deeply(r->dim(r->as_matrix($x))->values, [24, 1]);
  }
}
