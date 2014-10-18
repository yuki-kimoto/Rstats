use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::ElementsFunc;

# sqrt
{
  # sqrt - numeric
  {
    my $e1 = Rstats::ElementsFunc::double(4);
    my $e2 = Rstats::ElementsFunc::sqrt($e1);
    is($e2->value, 2);
  }
  
  # sqrt - complex
  {
    my $e1 = Rstats::ElementsFunc::complex(-1, 0);
    my $e2 = Rstats::ElementsFunc::sqrt($e1);
    is_deeply($e2->value, {re => 0, im => 1});
  }
}
