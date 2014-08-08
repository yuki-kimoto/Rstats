use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# numeric operator
{
  # numeric operator - -Inf + 2i
  {
    my $a1 = c(-Inf);
    my $a2 = c(2*i);
    my $a3 = $a1 + $a2;
    ok(Rstats::Util::is_negative_infinite($a3->value->{re}));
    is($a3->value->{im}, 2);
  }
  
  # numeric operator - -0.2 * -Inf
  {
    my $a1 = c(-0.2);
    my $a2 = c(-Inf);
    my $a3 = $a1 * $a2;
    is_deeply($a3->elements, [Rstats::Util::Inf]);
  }
}

# comparison operator numeric
{

  # comparison operator numeric - <
  {
    my $a1 = array(c(1,2,3));
    my $a2 = array(c(2,1,3));
    my $a3 = $a1 < $a2;
    is_deeply($a3->elements, [Rstats::Util::TRUE, Rstats::Util::FALSE, Rstats::Util::FALSE]);
  }
  
  # comparison operator numeric - <, arguments count is different
  {
    my $a1 = array(c(1,2,3));
    my $a2 = array(c(2));
    my $a3 = $a1 < $a2;
    is_deeply($a3->elements, [Rstats::Util::TRUE, Rstats::Util::FALSE, Rstats::Util::FALSE]);
  }

  # comparison operator numeric - <=
  {
    my $a1 = array(c(1,2,3));
    my $a2 = array(c(2,1,3));
    my $a3 = $a1 <= $a2;
    is_deeply($a3->elements, [Rstats::Util::TRUE, Rstats::Util::FALSE, Rstats::Util::TRUE]);
  }

  # comparison operator numeric - <=, arguments count is different
  {
    my $a1 = array(c(1,2,3));
    my $a2 = array(c(2));
    my $a3 = $a1 <= $a2;
    is_deeply($a3->elements, [Rstats::Util::TRUE, Rstats::Util::TRUE, Rstats::Util::FALSE]);
  }

  # comparison operator numeric - >
  {
    my $a1 = array(c(1,2,3));
    my $a2 = array(c(2,1,3));
    my $a3 = $a1 > $a2;
    is_deeply($a3->elements, [Rstats::Util::FALSE, Rstats::Util::TRUE, Rstats::Util::FALSE]);
  }

  # comparison operator numeric - >, arguments count is different
  {
    my $a1 = array(c(1,2,3));
    my $a2 = array(c(2));
    my $a3 = $a1 > $a2;
    is_deeply($a3->elements, [Rstats::Util::FALSE, Rstats::Util::FALSE, Rstats::Util::TRUE]);
  }

  # comparison operator numeric - >=
  {
    my $a1 = array(c(1,2,3));
    my $a2 = array(c(2,1,3));
    my $a3 = $a1 >= $a2;
    is_deeply($a3->elements, [Rstats::Util::FALSE, Rstats::Util::TRUE, Rstats::Util::TRUE]);
  }

  # comparison operator numeric - >=, arguments count is different
  {
    my $a1 = array(c(1,2,3));
    my $a2 = array(c(2));
    my $a3 = $a1 >= $a2;
    is_deeply($a3->elements, [Rstats::Util::FALSE, Rstats::Util::TRUE, Rstats::Util::TRUE]);
  }

  # comparison operator numeric - ==
  {
    my $a1 = array(c(1,2));
    my $a2 = array(c(2,2));
    my $a3 = $a1 == $a2;
    is_deeply($a3->elements, [Rstats::Util::FALSE, Rstats::Util::TRUE]);
  }

  # comparison operator numeric - ==, arguments count is different
  {
    my $a1 = array(c(1,2));
    my $a2 = array(c(2));
    my $a3 = $a1 == $a2;
    is_deeply($a3->elements, [Rstats::Util::FALSE, Rstats::Util::TRUE]);
  }

  # comparison operator numeric - !=
  {
    my $a1 = array(c(1,2));
    my $a2 = array(c(2,2));
    my $a3 = $a1 != $a2;
    is_deeply($a3->elements, [Rstats::Util::TRUE, Rstats::Util::FALSE]);
  }

  # comparison operator numeric - !=, arguments count is different
  {
    my $a1 = array(c(1,2));
    my $a2 = array(c(2));
    my $a3 = $a1 != $a2;
    is_deeply($a3->elements, [Rstats::Util::TRUE, Rstats::Util::FALSE]);
  }
}
