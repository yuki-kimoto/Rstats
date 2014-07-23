use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::Util;
use Math::Trig ();
use Math::Complex ();

# sin
{
  # sin - complex
  {
    my $a1 = c(1 + 2*i);
    my $a2 = r->sin($a1);
    my $exp = Math::Complex->make(1, 2)->sin;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is($a2->value->{re}, $exp_re), ;
    is($a2->value->{im}, $exp_im);
  }
  
  # sin - array
  {
    my $a1 = array(c(pi/2, pi/6));
    my $a2 = r->sin($a1);
    is(sprintf("%.5f", $a2->values->[0]), '1.00000');
    is(sprintf("%.5f", $a2->values->[1]), '0.50000');
    is_deeply(r->dim($a2)->values, [2]);
  }

  # sin - Inf
  {
    my $a1 = c(Inf);
    my $a2 = r->sin($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }
  
  # sin - Inf()
  {
    my $a1 = c(-Inf);
    my $a2 = r->sin($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }

  # sin - NA
  {
    my $a1 = c(NA);
    my $a2 = r->sin($a1);
    ok(Rstats::Util::is_na($a2->value));
  }  

  # sin - NaN
  {
    my $a1 = c(NaN);
    my $a2 = r->sin($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }
}
