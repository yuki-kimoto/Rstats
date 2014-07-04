use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::Util;
use Scalar::Util 'refaddr';

# Inf
{
  # Inf - singleton
  {
    my $inf = Rstats::Util::inf;
    my $inf2 = Rstats::Util::inf;
  
    is(refaddr $inf, refaddr $inf2);
  }
  
  # Inf - singleton, minus
  {
    my $inf = Rstats::Util::inf;
    my $inf_minus = -$inf;
    my $inf_minus2 = Rstats::Util::inf_minus;
    is(refaddr $inf_minus, refaddr $inf_minus2);
  }
  
  # Inf - negation
  {
    my $inf = Rstats::Util::inf;
    my $inf_minus = -$inf;
    my $inf_minus2 = Rstats::Util::inf_minus;
    is(refaddr $inf_minus, refaddr $inf_minus2);
  }

  # Inf - negation repeat
  {
    my $inf = Rstats::Util::inf;
    my $inf_minus = -$inf;
    my $inf2 = -$inf_minus;
    is(refaddr $inf, refaddr $inf2);
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

# is_infinite
{
  # is_infinite - Inf, true
  {
    my $inf = Rstats::Util::inf;
    ok(Rstats::Util::is_infinite($inf));
  }
  
  # is_infinite - -Inf, true
  {
    my $inf_minus = Rstats::Util::inf_minus;
    ok(Rstats::Util::is_infinite($inf_minus));
  }
  
  # is_infinite - Double, false
  {
    my $num = Rstats::Type::Double->new(value => 1);
    ok(!Rstats::Util::is_infinite($num));
  }
}

# is_finite
{
  # is_finite - Inf, false
  {
    my $inf = Rstats::Util::inf;
    ok(!Rstats::Util::is_finite($inf));
  }
  
  # is_finite - -Inf, false
  {
    my $inf_minus = Rstats::Util::inf_minus;
    ok(!Rstats::Util::is_finite($inf_minus));
  }
  
  # is_finite - Double, true
  {
    my $num = Rstats::Type::Double->new(value => 1);
    ok(Rstats::Util::is_finite($num));
  }
  
  # is_finite - Integer, true
  {
    my $num = Rstats::Type::Integer->new(value => 1);
    ok(Rstats::Util::is_finite($num));
  }
}
