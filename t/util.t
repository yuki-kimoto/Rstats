use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::Util;

# TODO
#   which
#   get - logical, undef

# cross_product
{
  my $values = [
    ['a1', 'a2'],
    ['b1', 'b2'],
    ['c1', 'c2']
  ];
  
  my $x1 = array(ve('1:3'));
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

# pos_to_index
{
  # pos_to_index - last position
  {
    my $pos = 23;
    my $index = Rstats::Util::pos_to_index($pos, [4, 3, 2]);
    is_deeply($index, [4, 3, 2]);
  }

  # pos_to_index - some position
  {
    my $pos = 21;
    my $index = Rstats::Util::pos_to_index($pos, [4, 3, 2]);
    is_deeply($index, [2, 3, 2]);
  }

  # pos_to_index - first position
  {
    my $pos = 0;
    my $index = Rstats::Util::pos_to_index($pos, [4, 3, 2]);
    is_deeply($index, [1, 1, 1]);
  }
}


# index_to_pos
{
  my $x1 = array(ve('1:24'), c(4, 3, 2));
  my $dim = [4, 3, 2];
  
  {
    my $value = Rstats::Util::index_to_pos([4, 3, 2], $dim);
    is($value, 23);
  }
  
  {
    my $value = Rstats::Util::index_to_pos([3, 3, 2], $dim);
    is($value, 22);
  }
}