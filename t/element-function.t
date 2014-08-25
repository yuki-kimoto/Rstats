use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::API;

# sqrt
{
  # sqrt - numeric
  {
    my $e1 = Rstats::API::double(4);
    my $e2 = Rstats::API::sqrt($e1);
    is($e2->value, 2);
  }
  
  # sqrt - complex
  {
    my $e1 = Rstats::API::complex(-1, 0);
    my $e2 = Rstats::API::sqrt($e1);
    is_deeply($e2->value, {re => 0, im => 1});
  }
}
