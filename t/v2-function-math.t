use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Math::Trig ();
use Math::Complex ();

use Rstats;

my $r = Rstats->new;

ok(1);

=pod

# sin
{
  # sin - complex
  {
    my $x1 = $r->c(1 + 2*$r->i);
    my $x2 = $r->sin($x1);
    my $exp = Math::Complex->make(1, 2)->sin;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is($x2->value->{re}, $exp_re);
    is($x2->value->{im}, $exp_im);
    ok($r->is->complex($x2));
  }
  
  # sin - double,array
  {
    my $x1 = $r->array($r->c($r->pi/2, $r->pi/6));
    my $x2 = $r->sin($x1);
    is(sprintf("%.5f", $x2->values->[0]), '1.00000');
    is(sprintf("%.5f", $x2->values->[1]), '0.50000');
    is_deeply($r->dim($x2)->values, [2]);
    ok($r->is->double($x2));
  }

  # sin - Inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->sin($x1);
    is($x2->value, 'NaN');
  }
  
  # sin - -$r->Inf
  {
    my $x1 = $r->c(-$r->Inf);
    my $x2 = $r->sin($x1);
    is($x2->value, 'NaN');
  }

  # sin - NA
  {
    my $x1 = $r->c($r->NA);
    my $x2 = $r->sin($x1);
    ok(!defined $x2->value);
  }  

  # sin - NaN
  {
    my $x1 = $r->c($r->NaN);
    my $x2 = $r->sin($x1);
    is($x2->value, 'NaN');
  }
}
=cut