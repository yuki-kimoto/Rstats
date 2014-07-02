use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::Inf;

# Inf
{
  # Inf - singleton
  {
    my $inf = Rstats::Inf->Inf;
    my $inf2 = Rstats::Inf->Inf;
  
    cmp_ok($inf, '==', $inf2);
  }
  
  # Inf - singleton, minus
  {
    my $inf = Rstats::Inf->Inf;
    my $inf_minus = -$inf;
    my $inf_minus2 = Rstats::Inf->Inf_minus;
    cmp_ok($inf_minus, '==', $inf_minus2);
  }
  
  # Inf - negation
  {
    my $inf = Rstats::Inf->Inf;
    my $inf_minus = -$inf;
    my $inf_minus2 = Rstats::Inf->Inf_minus;
    cmp_ok($inf_minus, '==', $inf_minus2);
  }

  # Inf - negation repeat
  {
    my $inf = Rstats::Inf->Inf;
    my $inf_minus = -$inf;
    my $inf2 = -$inf_minus;
    cmp_ok($inf, '==', $inf2);
  }
  
  # Inf - to_string, plus
  {
    my $inf = Rstats::Inf->Inf;
    is("$inf", 'Inf');
  }

  # Inf - to_string, minus
  {
    my $inf_minus = Rstats::Inf->Inf_minus;
    is("$inf_minus", '-Inf');
  }

}
