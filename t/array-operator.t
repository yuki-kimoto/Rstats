use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# comparison operator numeric
{

  # comparison operator numeric - <
  {
    my $a1 = array([1,2,3]);
    my $a2 = array([2,1,3]);
    my $a3 = $a1 < $a2;
    is_deeply($a3->elements, [Rstats::Util::TRUE, Rstats::Util::FALSE, Rstats::Util::FALSE]);
  }
  
  # comparison operator numeric - <, arguments count is different
  {
    my $a1 = array([1,2,3]);
    my $a2 = array([2]);
    my $a3 = $a1 < $a2;
    is_deeply($a3->elements, [Rstats::Util::TRUE, Rstats::Util::FALSE, Rstats::Util::FALSE]);
  }

  # comparison operator numeric - <=
  {
    my $a1 = array([1,2,3]);
    my $a2 = array([2,1,3]);
    my $a3 = $a1 <= $a2;
    is_deeply($a3->elements, [Rstats::Util::TRUE, Rstats::Util::FALSE, Rstats::Util::TRUE]);
  }

  # comparison operator numeric - <=, arguments count is different
  {
    my $a1 = array([1,2,3]);
    my $a2 = array([2]);
    my $a3 = $a1 <= $a2;
    is_deeply($a3->elements, [Rstats::Util::TRUE, Rstats::Util::TRUE, Rstats::Util::FALSE]);
  }

  # comparison operator numeric - >
  {
    my $a1 = array([1,2,3]);
    my $a2 = array([2,1,3]);
    my $a3 = $a1 > $a2;
    is_deeply($a3->elements, [Rstats::Util::FALSE, Rstats::Util::TRUE, Rstats::Util::FALSE]);
  }

  # comparison operator numeric - >, arguments count is different
  {
    my $a1 = array([1,2,3]);
    my $a2 = array([2]);
    my $a3 = $a1 > $a2;
    is_deeply($a3->elements, [Rstats::Util::FALSE, Rstats::Util::FALSE, Rstats::Util::TRUE]);
  }

  # comparison operator numeric - >=
  {
    my $a1 = array([1,2,3]);
    my $a2 = array([2,1,3]);
    my $a3 = $a1 >= $a2;
    is_deeply($a3->elements, [Rstats::Util::FALSE, Rstats::Util::TRUE, Rstats::Util::TRUE]);
  }

  # comparison operator numeric - >=, arguments count is different
  {
    my $a1 = array([1,2,3]);
    my $a2 = array([2]);
    my $a3 = $a1 >= $a2;
    is_deeply($a3->elements, [Rstats::Util::FALSE, Rstats::Util::TRUE, Rstats::Util::TRUE]);
  }

  # comparison operator numeric - ==
  {
    my $a1 = array([1,2]);
    my $a2 = array([2,2]);
    my $a3 = $a1 == $a2;
    is_deeply($a3->elements, [Rstats::Util::FALSE, Rstats::Util::TRUE]);
  }

  # comparison operator numeric - ==, arguments count is different
  {
    my $a1 = array([1,2]);
    my $a2 = array([2]);
    my $a3 = $a1 == $a2;
    is_deeply($a3->elements, [Rstats::Util::FALSE, Rstats::Util::TRUE]);
  }

  # comparison operator numeric - !=
  {
    my $a1 = array([1,2]);
    my $a2 = array([2,2]);
    my $a3 = $a1 != $a2;
    is_deeply($a3->elements, [Rstats::Util::TRUE, Rstats::Util::FALSE]);
  }

  # comparison operator numeric - !=, arguments count is different
  {
    my $a1 = array([1,2]);
    my $a2 = array([2]);
    my $a3 = $a1 != $a2;
    is_deeply($a3->elements, [Rstats::Util::TRUE, Rstats::Util::FALSE]);
  }
}
