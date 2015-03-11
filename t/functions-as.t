use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# as_array
{
  # as_array - from vector
  {
    my $x1 = se('1:24');
    is_deeply(r->as_array($x1)->values, [1 .. 24]);
    is_deeply(r->dim(r->as_array($x1))->values, [24]);
  }

  # as_array - from array
  {
    my $x1 = array(se('1:24'), c(4, 3, 2));
    is_deeply(r->as_array($x1)->values, [1 .. 24]);
    is_deeply(r->dim(r->as_array($x1))->values, [4, 3, 2]);
  }
}

# as_numeric
{
  # as_numeric - from complex
  {
    my $x1 = c(r->complex(1, 1), r->complex(2, 2));
    r->mode($x1 => 'complex');
    my $x2 = r->as_numeric($x1);
    is(r->mode($x2)->value, 'numeric');
    is_deeply($x2->values, [1, 2]);
  }

  # as_numeric - from numeric
  {
    my $x1 = c(0.1, 1.1, 2.2);
    r->mode($x1 => 'numeric');
    my $x2 = r->as_numeric($x1);
    is(r->mode($x2)->value, 'numeric');
    is_deeply($x2->values, [0.1, 1.1, 2.2]);
  }
    
  # as_numeric - from integer
  {
    my $x1 = c(0, 1, 2);
    r->mode($x1 => 'integer');
    my $x2 = r->as_numeric($x1);
    is(r->mode($x2)->value, 'numeric');
    is_deeply($x2->values, [0, 1, 2]);
  }
  
  # as_numeric - from logical
  {
    my $x1 = c(r->TRUE, r->FALSE);
    r->mode($x1 => 'logical');
    my $x2 = r->as_numeric($x1);
    is(r->mode($x2)->value, 'numeric');
    is_deeply($x2->values, [1, 0]);
  }

  # as_numeric - from character
  {
    my $x1 = r->as_integer(c(0, 1, 2));
    my $x2 = r->as_numeric($x1);
    is(r->mode($x2)->value, 'numeric');
    is_deeply($x2->values, [0, 1, 2]);
  }
}

# is_*, as_*, typeof
{
  # is_integer, as_integer, typeof - integer
  {
    my $c = c(0, 1, 2);
    ok(r->is_integer(r->as_integer($c)));
    is(r->mode(r->as_integer($c))->value, 'numeric');
    is(r->typeof(r->as_integer($c))->value, 'integer');
  }
  
  # is_character, as_character, typeof - character
  {
    my $c = c(0, 1, 2);
    ok(r->is_character(r->as_character($c)));
    is(r->mode(r->as_character($c))->value, 'character');
    is(r->typeof(r->as_character($c))->value, 'character');
  }
  
  # is_complex, as_complex, typeof - complex
  {
    my $c = c(0, 1, 2);
    ok(r->is_complex(r->as_complex($c)));
    is(r->mode(r->as_complex($c))->value, 'complex');
    is(r->typeof(r->as_complex($c))->value, 'complex');
  }
  
  # is_logical, as_logical, typeof - logical
  {
    my $x1 = c(0, 1, 2);
    my $x2 = r->as_logical($x1);
    ok(r->is_logical($x2));
    is(r->mode($x2)->value, 'logical');
    is(r->typeof($x2)->value, 'logical');
  }

  # is_logical, as_logical, typeof - NULL
  {
    my $x1 = r->NULL;
    is(r->mode($x1)->value, 'logical');
    is(r->typeof($x1)->value, 'logical');
  }
}
# as_vector
{
  # as_vector - from array
  {
    my $x1 = array(se('1:24'), c(4, 3, 2));
    is_deeply(r->as_vector($x1)->values, [1 .. 24]);
    is_deeply(r->dim(r->as_vector($x1))->values, []);
  }
}

# as_matrix
{
  # as_matrix - from vector
  {
    my $x = se('1:24');
    is_deeply(r->as_matrix($x)->values, [1 .. 24]);
    is_deeply(r->dim(r->as_matrix($x))->values, [24, 1]);
  }

  # as_matrix - from matrix
  {
    my $x1 = matrix(se('1:12'), 4, 3);
    is_deeply(r->as_matrix($x1)->values, [1 .. 12]);
    is_deeply(r->dim(r->as_matrix($x1))->values, [4, 3]);
  }

  # as_matrix - from array
  {
    my $x1 = array(se('1:24'), c(4, 3, 2));
    is_deeply(r->as_matrix($x1)->values, [1 .. 24]);
    is_deeply(r->dim(r->as_matrix($x1))->values, [24, 1]);
  }
}
