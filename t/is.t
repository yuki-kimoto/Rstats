use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# is
{
  # is->integer, as_integer, typeof - integer
  {
    my $c = c_(0, 1, 2);
    ok(r->is->integer(r->as->integer($c)));
    is(r->mode(r->as->integer($c))->value, 'numeric');
    is(r->typeof(r->as->integer($c))->value, 'integer');
  }
  
  # is->character, as_character, typeof - character
  {
    my $c = c_(0, 1, 2);
    ok(r->is->character(r->as->character($c)));
    is(r->mode(r->as->character($c))->value, 'character');
    is(r->typeof(r->as->character($c))->value, 'character');
  }
  
  # is->complex, as_complex, typeof - complex
  {
    my $c = c_(0, 1, 2);
    ok(r->is->complex(r->as->complex($c)));
    is(r->mode(r->as->complex($c))->value, 'complex');
    is(r->typeof(r->as->complex($c))->value, 'complex');
  }
  
  # is->logical, as_logical, typeof - logical
  {
    my $x1 = c_(0, 1, 2);
    my $x2 = r->as->logical($x1);
    ok(r->is->logical($x2));
    is(r->mode($x2)->value, 'logical');
    is(r->typeof($x2)->value, 'logical');
  }

  # is->logical, as_logical, typeof - NULL
  {
    my $x1 = r->NULL;
    is(r->mode($x1)->value, 'NULL');
    is(r->typeof($x1)->value, 'NULL');
  }
}

# is from Rstats object
{
  # is->vector
  {
    my $x = array(C_('1:24'));
    ok(!r->is->vector($x));
  }
  
  # is->matrix
  {
    my $x = matrix(C_('1:24'), 4, 3);
    ok(r->is->matrix($x));
  }

  # is->array
  {
    
    my $x = array(C_('1:12'), c_(4, 3, 2));
    ok(r->is->array($x));
  }
}


