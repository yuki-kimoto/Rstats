use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::Vector;

# Vector
{
  my $r = Rstats->new;

  
  # head
  {
    {
      my $v1 = $r->c([1, 2, 3, 4, 5, 6, 7]);
      my $head = $v1->head;
      is_deeply($head->values, [1, 2, 3, 4, 5, 6]);
    }
    
    # head - values is low than 6
    {
      my $v1 = $r->c([1, 2, 3]);
      my $head = $v1->head;
      is_deeply($head->values, [1, 2, 3]);
    }
    
    # head - n option
    {
      my $v1 = $r->c([1, 2, 3, 4]);
      my $head = $v1->head({n => 3});
      is_deeply($head->values, [1, 2, 3]);
    }
  }

  # tail
  {
    {
      my $v1 = $r->c([1, 2, 3, 4, 5, 6, 7]);
      my $tail = $v1->tail;
      is_deeply($tail->values, [2, 3, 4, 5, 6, 7]);
    }
    
    # tail - values is low than 6
    {
      my $v1 = $r->c([1, 2, 3]);
      my $tail = $v1->tail;
      is_deeply($tail->values, [1, 2, 3]);
    }
    
    # tail - n option
    {
      my $v1 = $r->c([1, 2, 3, 4]);
      my $tail = $v1->tail({n => 3});
      is_deeply($tail->values, [2, 3, 4]);
    }
  }
  
  # length
  {
    my $v1 = $r->c([1, 2, 3]);
    is($v1->length, 3);
  }
  
  # get
  {
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
  }
  
  # get_b
  {
    # getb - single number
    {
      my $v1 = $r->c([1, 3, 5, 7]);
      my $v2 = $v1->get_b(1);
      is_deeply($v2->values, [1]);
    }
    # getb - multiple number
    {
      my $v1 = $r->c([1, 3, 5, 7]);
      my $v2 = $v1->get_b([0, 1, 0, 1, 1]);
      is_deeply($v2->values, [3, 7, undef]);
    }
  }

  # get_s
  {
    my $v1 = Rstats::Vector->new(values => [1, 2, 3, 4]);
    $v1->names($r->c(['a', 'b', 'c', 'd']));
    my $v2 = $v1->get_s($r->c(['b', 'd']));
    is_deeply($v2->values, [2, 4]);
  }
  
  # add to original vector
  {
    my $v1 = $r->c([1, 2, 3]);
    $v1->set($v1->length + 1 => 6);
    is_deeply($v1->values, [1, 2, 3, 6]);
  }
  
  # append(after option)
  {
    my $v1 = $r->c([1, 2, 3, 4, 5]);
    $v1->append(1, {after => 3});
    is_deeply($v1->values, [1, 2, 3, 1, 4, 5]);
  }

  # append(no after option)
  {
    my $v1 = $r->c([1, 2, 3, 4, 5]);
    $v1->append(1);
    is_deeply($v1->values, [1, 2, 3, 4, 5, 1]);
  }

  # append(array)
  {
    my $v1 = $r->c([1, 2, 3, 4, 5]);
    $v1->append([6, 7]);
    is_deeply($v1->values, [1, 2, 3, 4, 5, 6, 7]);
  }

  # append(vector)
  {
    my $v1 = $r->c([1, 2, 3, 4, 5]);
    $v1->append($r->c([6, 7]));
    is_deeply($v1->values, [1, 2, 3, 4, 5, 6, 7]);
  }
  
  # negation
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = -$v1;
    is_deeply($v2->values, [-1, -2, -3]);
  }
  
  # add
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $r->c([2, 3, 4]);
    my $v3 = $v1 + $v2;
    is_deeply($v3->values, [3, 5, 7]);
  }

  # add(different element number)
  {
    my $v1 = $r->c([1, 2]);
    my $v2 = $r->c([3, 4, 5, 6]);
    my $v3 = $v1 + $v2;
    is_deeply($v3->values, [4, 6, 6, 8]);
  }
  
  # add(real number)
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $v1 + 1;
    is_deeply($v2->values, [2, 3, 4]);
  }
  
  # subtract
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $r->c([3, 3, 3]);
    my $v3 = $v1 - $v2;
    is_deeply($v3->values, [-2, -1, 0]);
  }

  # subtract(real number)
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $v1 - 1;
    is_deeply($v2->values, [0, 1, 2]);
  }

  # subtract(real number, reverse)
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = 1 - $v1;
    is_deeply($v2->values, [0, -1, -2]);
  }
    
  # mutiply
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $r->c([2, 3, 4]);
    my $v3 = $v1 * $v2;
    is_deeply($v3->values, [2, 6, 12]);
  }

  # mutiply(real number)
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $v1 * 2;
    is_deeply($v2->values, [2, 4, 6]);
  }
  
  # divide
  {
    my $v1 = $r->c([6, 3, 12]);
    my $v2 = $r->c([2, 3, 4]);
    my $v3 = $v1 / $v2;
    is_deeply($v3->values, [3, 1, 3]);
  }

  # divide(real number)
  {
    my $v1 = $r->c([2, 4, 6]);
    my $v2 = $v1 / 2;
    is_deeply($v2->values, [1, 2, 3]);
  }

  # divide(real number, reverse)
  {
    my $v1 = $r->c([2, 4, 6]);
    my $v2 = 2 / $v1;
    is_deeply($v2->values, [1, 1/2, 1/3]);
  }
  
  # raise
  {
    my $v1 = $r->c([1, 2, 3]);
    my $v2 = $v1 ** 2;
    is_deeply($v2->values, [1, 4, 9]);
  }
}
