use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::Func::Vector;

# sqrt
{
  # sqrt - numeric
  {
    my $e1 = Rstats::Func::Vector::new_double(4);
    my $e2 = Rstats::Func::Vector::sqrt($e1);
    is($e2->value, 2);
  }
  
  # sqrt - complex
  {
    my $e1 = Rstats::Func::Vector::new_complex({re => -1, im => 0});
    my $e2 = Rstats::Func::Vector::sqrt($e1);
    is_deeply($e2->value, {re => 0, im => 1});
  }
}
