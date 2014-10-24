use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# hash
{
  my %hash = (-c => 1);
  is((keys %hash)[0], "-c");
}

# string -i and -c is not chaged to - i and - c
{
  my $str = "-c and -i";
  is(length $str, 9);
}

# i - minus
{
  my $x1 = -i;
  cmp_ok($x1->values->[0]->{re}, '==', 0);
  cmp_ok($x1->values->[0]->{im}, '==', -1);
}

# c - minus
{
  my $x1 = -c(1, 2, 3);
  is_deeply($x1->values, [-1, -2, -3]);
}
