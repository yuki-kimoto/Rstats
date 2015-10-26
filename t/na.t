use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# NA
{

=pod
  # NA - 128
  {
    my $x1 = array(c_(1, NA), c_(4, 8));
    my $x2 = array(c_(1, NA, NA, 2), c_(4, 8));
    my $x3 = $x1 + $x2;
    1;
  }
=cut

  # NA - NA + NA
  {
    my $x1 = NA;
    my $x2 = NA;
    my $x3 = $x1 + $x2;
    is_deeply($x3->values, [undef]);
  }
  
  # NA - NA + double
  {
    my $x1 = NA;
    my $x2 = c_(1);
    my $x3 = $x1 + $x2;
    is_deeply($x3->values, [undef]);
  }

  # NA - double + NA
  {
    my $x1 = c_(1);
    my $x2 = NA;
    my $x3 = $x1 + $x2;
    is_deeply($x3->values, [undef]);
  }
}
  