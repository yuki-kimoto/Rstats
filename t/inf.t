use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::Inf;

# Inf
{
  # Inf - singleton
  {
    my $inf = Rstats::Util::inf;
    my $inf2 = Rstats::Util::inf;
  
    cmp_ok($inf, '==', $inf2);
  }
  
  # Inf - singleton, minus
  {
    my $inf = Rstats::Util::inf;
    my $inf_minus = -$inf;
    my $inf_minus2 = Rstats::Util::inf_minus;
    cmp_ok($inf_minus, '==', $inf_minus2);
  }
  
  # Inf - negation
  {
    my $inf = Rstats::Util::inf;
    my $inf_minus = -$inf;
    my $inf_minus2 = Rstats::Util::inf_minus;
    cmp_ok($inf_minus, '==', $inf_minus2);
  }

  # Inf - negation repeat
  {
    my $inf = Rstats::Util::inf;
    my $inf_minus = -$inf;
    my $inf2 = -$inf_minus;
    cmp_ok($inf, '==', $inf2);
  }
  
  # Inf - to_string, plus
  {
    my $inf = Rstats::Util::inf;
    is("$inf", 'Inf');
  }

  # Inf - to_string, minus
  {
    my $inf_minus = Rstats::Util::inf_minus;
    is("$inf_minus", '-Inf');
  }

}
