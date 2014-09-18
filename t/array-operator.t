use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# numeric operator
{
  # numeric operator - -Inf + 2i
  {
    my $x1 = c(-Inf);
    my $x2 = c(2*i);
    my $x3 = $x1 + $x2;
    ok($x3->element->re->is_negative_infinite);
    is($x3->value->{im}, 2);
  }
  
  # numeric operator - -0.2 * -Inf
  {
    my $x1 = c(-0.2);
    my $x2 = c(-Inf);
    my $x3 = $x1 * $x2;
    is_deeply($x3->elements, [Rstats::ElementFunc::Inf]);
  }
}

# comparison operator numeric
{

  # comparison operator numeric - <
  {
    my $x1 = array(c(1,2,3));
    my $x2 = array(c(2,1,3));
    my $x3 = $x1 < $x2;
    is_deeply($x3->elements, [Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE, Rstats::ElementFunc::FALSE]);
  }
  
  # comparison operator numeric - <, arguments count is different
  {
    my $x1 = array(c(1,2,3));
    my $x2 = array(c(2));
    my $x3 = $x1 < $x2;
    is_deeply($x3->elements, [Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE, Rstats::ElementFunc::FALSE]);
  }

  # comparison operator numeric - <=
  {
    my $x1 = array(c(1,2,3));
    my $x2 = array(c(2,1,3));
    my $x3 = $x1 <= $x2;
    is_deeply($x3->elements, [Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE, Rstats::ElementFunc::TRUE]);
  }

  # comparison operator numeric - <=, arguments count is different
  {
    my $x1 = array(c(1,2,3));
    my $x2 = array(c(2));
    my $x3 = $x1 <= $x2;
    is_deeply($x3->elements, [Rstats::ElementFunc::TRUE, Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE]);
  }

  # comparison operator numeric - >
  {
    my $x1 = array(c(1,2,3));
    my $x2 = array(c(2,1,3));
    my $x3 = $x1 > $x2;
    is_deeply($x3->elements, [Rstats::ElementFunc::FALSE, Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE]);
  }

  # comparison operator numeric - >, arguments count is different
  {
    my $x1 = array(c(1,2,3));
    my $x2 = array(c(2));
    my $x3 = $x1 > $x2;
    is_deeply($x3->elements, [Rstats::ElementFunc::FALSE, Rstats::ElementFunc::FALSE, Rstats::ElementFunc::TRUE]);
  }

  # comparison operator numeric - >=
  {
    my $x1 = array(c(1,2,3));
    my $x2 = array(c(2,1,3));
    my $x3 = $x1 >= $x2;
    is_deeply($x3->elements, [Rstats::ElementFunc::FALSE, Rstats::ElementFunc::TRUE, Rstats::ElementFunc::TRUE]);
  }

  # comparison operator numeric - >=, arguments count is different
  {
    my $x1 = array(c(1,2,3));
    my $x2 = array(c(2));
    my $x3 = $x1 >= $x2;
    is_deeply($x3->elements, [Rstats::ElementFunc::FALSE, Rstats::ElementFunc::TRUE, Rstats::ElementFunc::TRUE]);
  }

  # comparison operator numeric - ==
  {
    my $x1 = array(c(1,2));
    my $x2 = array(c(2,2));
    my $x3 = $x1 == $x2;
    is_deeply($x3->elements, [Rstats::ElementFunc::FALSE, Rstats::ElementFunc::TRUE]);
  }

  # comparison operator numeric - ==, arguments count is different
  {
    my $x1 = array(c(1,2));
    my $x2 = array(c(2));
    my $x3 = $x1 == $x2;
    is_deeply($x3->elements, [Rstats::ElementFunc::FALSE, Rstats::ElementFunc::TRUE]);
  }

  # comparison operator numeric - !=
  {
    my $x1 = array(c(1,2));
    my $x2 = array(c(2,2));
    my $x3 = $x1 != $x2;
    is_deeply($x3->elements, [Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE]);
  }

  # comparison operator numeric - !=, arguments count is different
  {
    my $x1 = array(c(1,2));
    my $x2 = array(c(2));
    my $x3 = $x1 != $x2;
    is_deeply($x3->elements, [Rstats::ElementFunc::TRUE, Rstats::ElementFunc::FALSE]);
  }
}
