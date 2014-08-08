use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::Util;
use Math::Trig ();
use Math::Complex ();

# tanh
{
  # tanh - complex, 1 + 2i
  {
    my $a1 = c(1 + 2*i);
    my $a2 = r->tanh($a1);
    is(sprintf("%.6f", $a2->value->{re}), '1.166736');
    is(sprintf("%.6f", $a2->value->{im}), '-0.243458');
    ok(r->is_complex($a2));
  }

  # tanh - complex, -Inf - 2i
  {
    my $a1 = c(-Inf - 2*i);
    $ENV{a}++;
    my $a2 = r->tanh($a1);
    is($a2->value->{re}, '-1');
    is($a2->value->{im}, '0');
  }
  
  # tanh - complex, -Inf + 2i
  {
    my $a1 = c(-Inf + 2*i);
    my $a2 = r->tanh($a1);
    is($a2->value->{re}, '-1');
    is($a2->value->{im}, '0');
  }
  
  # tanh - double,array
  {
    my $a1 = array(c(0, 2));
    my $a2 = r->tanh($a1);
    is($a2->values->[0], '0');
    is(sprintf("%.6f", $a2->values->[1]), '0.964028');
    is_deeply(r->dim($a2)->values, [2]);
    ok(r->is_double($a2));
  }

  # tanh - Inf
  {
    my $a1 = c(Inf);
    my $a2 = r->tanh($a1);
    is($a2->value, '1');
  }
  
  # tanh - -Inf
  {
    my $a1 = c(-Inf);
    my $a2 = r->tanh($a1);
    is($a2->value, '-1');
  }

  # tanh - NA
  {
    my $a1 = c(NA);
    my $a2 = r->tanh($a1);
    ok(Rstats::Util::is_na($a2->value));
  }  

  # tanh - NaN
  {
    my $a1 = c(NaN);
    my $a2 = r->tanh($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }
}

# cosh
{
  # cosh - complex, 1 + 2i
  {
    my $a1 = c(1 + 2*i);
    my $a2 = r->cosh($a1);
    is(sprintf("%.6f", $a2->value->{re}), '-0.642148');
    is(sprintf("%.6f", $a2->value->{im}), '1.068607');
    ok(r->is_complex($a2));
  }

  # cosh - complex, -Inf - 2i
  {
    my $a1 = c(-Inf - 2*i);
    my $a2 = r->cosh($a1);
    ok(Rstats::Util::is_negative_infinite($a2->value->{re}));
    ok(Rstats::Util::is_positive_infinite($a2->value->{im}));
  }
  
  # cosh - complex, -Inf + 2i
  {
    my $a1 = c(-Inf + 2*i);
    my $a2 = r->cosh($a1);
    ok(Rstats::Util::is_negative_infinite($a2->value->{re}));
    ok(Rstats::Util::is_negative_infinite($a2->value->{im}));
  }
  
  # cosh - double,array
  {
    my $a1 = array(c(0, Inf, 2, -Inf));
    my $a2 = r->cosh($a1);
    is($a2->values->[0], '1');
    ok(Rstats::Util::is_positive_infinite($a2->values->[1]));
    is(sprintf("%.6f", $a2->values->[2]), '3.762196');
    ok(Rstats::Util::is_positive_infinite($a2->values->[3]));
    is_deeply(r->dim($a2)->values, [4]);
    ok(r->is_double($a2));
  }

  # cosh - Inf
  {
    my $a1 = c(Inf);
    my $a2 = r->cosh($a1);
    ok(Rstats::Util::is_positive_infinite($a2->value));
  }
  
  # cosh - -Inf
  {
    my $a1 = c(-Inf);
    my $a2 = r->cosh($a1);
    ok(Rstats::Util::is_positive_infinite($a2->value));
  }

  # cosh - NA
  {
    my $a1 = c(NA);
    my $a2 = r->cosh($a1);
    ok(Rstats::Util::is_na($a2->value));
  }  

  # cosh - NaN
  {
    my $a1 = c(NaN);
    my $a2 = r->cosh($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }
}

# sinh
{
  # sinh - complex, 1 + 2i
  {
    my $a1 = c(1 + 2*i);
    my $a2 = r->sinh($a1);
    is(sprintf("%.6f", $a2->value->{re}), '-0.489056');
    is(sprintf("%.6f", $a2->value->{im}), '1.403119');
    ok(r->is_complex($a2));
  }

  # sinh - complex, -Inf - 2i
  {
    my $a1 = c(-Inf - 2*i);
    my $a2 = r->sinh($a1);
    ok(Rstats::Util::is_positive_infinite($a2->value->{re}));
    ok(Rstats::Util::is_negative_infinite($a2->value->{im}));
  }
  
  # sinh - complex, -Inf + 2i
  {
    my $a1 = c(-Inf + 2*i);
    my $a2 = r->sinh($a1);
    ok(Rstats::Util::is_positive_infinite($a2->value->{re}));
    ok(Rstats::Util::is_positive_infinite($a2->value->{im}));
  }
  
  # sinh - double,array
  {
    my $a1 = array(c(0, Inf, 2, -Inf));
    my $a2 = r->sinh($a1);
    is($a2->values->[0], '0');
    ok(Rstats::Util::is_positive_infinite($a2->values->[1]));
    is(sprintf("%.6f", $a2->values->[2]), '3.626860');
    ok(Rstats::Util::is_negative_infinite($a2->values->[3]));
    is_deeply(r->dim($a2)->values, [4]);
    ok(r->is_double($a2));
  }

  # sinh - Inf
  {
    my $a1 = c(Inf);
    my $a2 = r->sinh($a1);
    ok(Rstats::Util::is_positive_infinite($a2->value));
  }
  
  # sinh - -Inf
  {
    my $a1 = c(-Inf);
    my $a2 = r->sinh($a1);
    ok(Rstats::Util::is_negative_infinite($a2->value));
  }

  # sinh - NA
  {
    my $a1 = c(NA);
    my $a2 = r->sinh($a1);
    ok(Rstats::Util::is_na($a2->value));
  }  

  # sinh - NaN
  {
    my $a1 = c(NaN);
    my $a2 = r->sinh($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }
}

# atan
{
  # atan - complex, 0
  {
    my $a1 = c(0*i);
    my $a2 = r->atan($a1);
    is($a2->values->[0]{re}, 0);
    is($a2->values->[0]{im}, 0);
    ok(r->is_complex($a2));
  }

  # atan - complex, 1i
  {
    my $a1 = c(1*i);
    my $a2 = r->atan($a1);
    is($a2->values->[0]{re}, 0);
    ok(Rstats::Util::is_positive_infinite($a2->values->[0]{im}));
    ok(r->is_complex($a2));
  }
  
  # atan - complex, -1
  {
    my $a1 = c(-1*i);
    my $a2 = r->atan($a1);
    is($a2->values->[0]{re}, 0);
    ok(Rstats::Util::is_negative_infinite($a2->values->[0]{im}));
    ok(r->is_complex($a2));
  }

  # atan - complex, 1 + 2i
  {
    my $a1 = c(1 + 2*i);
    my $a2 = r->atan($a1);
    is(sprintf("%.6f", $a2->value->{re}), '1.338973');
    is(sprintf("%.6f", $a2->value->{im}), '0.402359');
  }
  
  # atan - double,array
  {
    my $a1 = array(c(0.5, 0.6));
    my $a2 = r->atan($a1);
    is(sprintf("%.6f", $a2->values->[0]), '0.463648');
    is(sprintf("%.6f", $a2->values->[1]), '0.540420');
    is_deeply(r->dim($a2)->values, [2]);
    ok(r->is_double($a2));
  }

  # atan - Inf
  {
    my $a1 = c(Inf);
    my $a2 = r->atan($a1);
    is(sprintf("%.6f", $a2->value), '1.570796');
  }
  
  # atan - -Inf
  {
    my $a1 = c(-Inf);
    my $a2 = r->atan($a1);
    is(sprintf("%.6f", $a2->value), '-1.570796');
  }

  # atan - NA
  {
    my $a1 = c(NA);
    my $a2 = r->atan($a1);
    ok(Rstats::Util::is_na($a2->value));
  }  

  # atan - NaN
  {
    my $a1 = c(NaN);
    my $a2 = r->atan($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }
}

# acos
{
  # acos - complex, 1 + 2*i
  {
  
    my $a1 = c(1 + 2*i);
    my $a2 = r->acos($a1);
    is(sprintf("%.6f", $a2->value->{re}), '1.143718');
    is(sprintf("%.6f", $a2->value->{im}), '-1.528571');
  }

  # acos - complex, 0.5 + 0.5*i
  {
    my $a1 = c(0.5 + 0.5*i);
    my $a2 = r->acos($a1);
    is(sprintf("%.6f", $a2->value->{re}), '1.118518');
    is(sprintf("%.6f", $a2->value->{im}), '-0.530638');
  }

  # acos - complex, 1 + 1*i
  {
    my $a1 = c(1 + 1*i);
    my $a2 = r->acos($a1);
    is(sprintf("%.6f", $a2->value->{re}), '0.904557');
    is(sprintf("%.6f", $a2->value->{im}), '-1.061275');
  }

  # acos - complex, 1.5 + 1.5*i
  {
    my $a1 = c(1.5 + 1.5*i);
    my $a2 = r->acos($a1);
    is(sprintf("%.6f", $a2->value->{re}), '0.840395');
    is(sprintf("%.6f", $a2->value->{im}), '-1.449734');
  }

  # acos - complex, -0.5 - 0.5*i
  {
    my $a1 = c(-0.5 - 0.5*i);
    my $a2 = r->acos($a1);
    is(sprintf("%.6f", $a2->value->{re}), '2.023075');
    is(sprintf("%.6f", $a2->value->{im}), '0.530638');
  }

  # acos - complex, -1 - 1*i
  {
    my $a1 = c(-1 - 1*i);
    my $a2 = r->acos($a1);
    is(sprintf("%.6f", $a2->value->{re}), '2.237036');
    is(sprintf("%.6f", $a2->value->{im}), '1.061275');
  }

  # acos - complex, 0
  {
    my $a1 = c(0*i);
    my $a2 = r->acos($a1);
    is(sprintf("%.6f", $a2->values->[0]{re}), 1.570796);
    is($a2->values->[0]{im}, 0);
    ok(r->is_complex($a2));
  }

  # acos - complex, 1
  {
    my $a1 = c(1 + 0*i);
    my $a2 = r->acos($a1);
    is($a2->values->[0]{re}, 0);
    is($a2->values->[0]{im}, 0);
    ok(r->is_complex($a2));
  }
      
  # acos - complex, -1.5
  {
    my $a1 = c(-1.5 + 0*i);
    my $a2 = r->acos($a1);
    is(sprintf("%.6f", $a2->values->[0]{re}), '3.141593');
    is(sprintf("%.6f", $a2->values->[0]{im}), '-0.962424');
    ok(r->is_complex($a2));
  }

  # acos - double,array
  {
    my $a1 = array(c(1, 1.1, -1.1));
    my $a2 = r->acos($a1);
    is($a2->values->[0], 0);
    ok(Rstats::Util::is_nan($a2->values->[1]));
    ok(Rstats::Util::is_nan($a2->values->[2]));
    is_deeply(r->dim($a2)->values, [3]);
    ok(r->is_double($a2));
  }

  # acos - Inf
  {
    my $a1 = c(Inf);
    my $a2 = r->acos($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }
  
  # acos - -Inf
  {
    my $a1 = c(-Inf);
    my $a2 = r->acos($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }

  # acos - NA
  {
    my $a1 = c(NA);
    my $a2 = r->acos($a1);
    ok(Rstats::Util::is_na($a2->value));
  }  

  # acos - NaN
  {
    my $a1 = c(NaN);
    my $a2 = r->acos($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }
}

# asin
{
  # asin - complex, 1 + 2*i
  {
    my $a1 = c(1 + 2*i);
    my $a2 = r->asin($a1);
    is(sprintf("%.6f", $a2->value->{re}), '0.427079');
    is(sprintf("%.6f", $a2->value->{im}), '1.528571');
  }

  # asin - complex, 0.5 + 0.5*i
  {
    my $a1 = c(0.5 + 0.5*i);
    my $a2 = r->asin($a1);
    is(sprintf("%.6f", $a2->value->{re}), '0.452278');
    is(sprintf("%.6f", $a2->value->{im}), '0.530638');
  }

  # asin - complex, 1 + 1*i
  {
    my $a1 = c(1 + 1*i);
    my $a2 = r->asin($a1);
    is(sprintf("%.6f", $a2->value->{re}), '0.666239');
    is(sprintf("%.6f", $a2->value->{im}), '1.061275');
  }

  # asin - complex, 1.5 + 1.5*i
  {
    my $a1 = c(1.5 + 1.5*i);
    my $a2 = r->asin($a1);
    is(sprintf("%.6f", $a2->value->{re}), '0.730401');
    is(sprintf("%.6f", $a2->value->{im}), '1.449734');
  }

  # asin - complex, -0.5 - 0.5*i
  {
    my $a1 = c(-0.5 - 0.5*i);
    my $a2 = r->asin($a1);
    is(sprintf("%.6f", $a2->value->{re}), '-0.452278');
    is(sprintf("%.6f", $a2->value->{im}), '-0.530638');
  }

  # asin - complex, -1 - 1*i
  {
    my $a1 = c(-1 - 1*i);
    my $a2 = r->asin($a1);
    is(sprintf("%.6f", $a2->value->{re}), '-0.666239');
    is(sprintf("%.6f", $a2->value->{im}), '-1.061275');
  }

  # asin - complex, 0
  {
    my $a1 = c(0*i);
    my $a2 = r->asin($a1);
    is($a2->values->[0]{re}, 0);
    is($a2->values->[0]{im}, 0);
    ok(r->is_complex($a2));
  }
    
  # asin - complex, 0.5,
  {
    my $a1 = c(-1.5 + 0*i);
    my $a2 = r->asin($a1);
    is(sprintf("%.6f", $a2->values->[0]{re}), '-1.570796');
    is(sprintf("%.6f", $a2->values->[0]{im}), '0.962424');
    ok(r->is_complex($a2));
  }

  # asin - double,array
  {
    my $a1 = array(c(1, 1.1, -1.1));
    my $a2 = r->asin($a1);
    is(sprintf("%.6f", $a2->values->[0]), '1.570796');
    ok(Rstats::Util::is_nan($a2->values->[1]));
    ok(Rstats::Util::is_nan($a2->values->[2]));
    is_deeply(r->dim($a2)->values, [3]);
    ok(r->is_double($a2));
  }

  # asin - Inf
  {
    my $a1 = c(Inf);
    my $a2 = r->asin($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }
  
  # asin - -Inf
  {
    my $a1 = c(-Inf);
    my $a2 = r->asin($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }

  # asin - NA
  {
    my $a1 = c(NA);
    my $a2 = r->asin($a1);
    ok(Rstats::Util::is_na($a2->value));
  }  

  # asin - NaN
  {
    my $a1 = c(NaN);
    my $a2 = r->asin($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }
}

# atan
{
  # atan - complex
  {
    my $a1 = c(1 + 2*i, i, -i);
    my $a2 = r->atan($a1);
    is(sprintf("%.6f", $a2->values->[0]{re}), '1.338973');
    is(sprintf("%.6f", $a2->values->[0]{im}), '0.402359');
    is($a2->values->[1]{re}, 0);
    is($a2->values->[1]{im}, Rstats::Util::Inf);
    is($a2->values->[2]{re}, 0);
    is($a2->values->[2]{im}, Rstats::Util::negativeInf);
    ok(r->is_complex($a2));
  }
  
  # atan - double,array
  {
    my $a1 = array(c(1, 2));
    my $a2 = r->atan($a1);
    is(sprintf("%.6f", $a2->values->[0]), '0.785398');
    is(sprintf("%.6f", $a2->values->[1]), '1.107149');
    is_deeply(r->dim($a2)->values, [2]);
    ok(r->is_double($a2));
  }

  # atan - Inf
  {
    my $a1 = c(Inf);
    my $a2 = r->atan($a1);
    is(sprintf("%.6f", $a2->values->[0]), '1.570796');
  }
  
  # atan - -Inf
  {
    my $a1 = c(-Inf);
    my $a2 = r->atan($a1);
    is(sprintf("%.6f", $a2->values->[0]), '-1.570796');
  }

  # atan - NA
  {
    my $a1 = c(NA);
    my $a2 = r->atan($a1);
    ok(Rstats::Util::is_na($a2->value));
  }  

  # atan - NaN
  {
    my $a1 = c(NaN);
    my $a2 = r->atan($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }
}

# atan2
{
  # atan2 - complex
  {
    my $a1 = c(1 + 2*i);
    my $a2 = c(3 + 4*i);
    my $a3 = r->atan2($a1, $a2);
    is(sprintf("%.6f", $a3->value->{re}), 0.416491);
    is(sprintf("%.6f", $a3->value->{im}), 0.067066);
    ok(r->is_complex($a3));
  }
  
  # atan2 - double,array
  {
    my $a1 = array(c(1, 2));
    my $a2 = array(c(3, 4));
    my $a3 = r->atan2($a1, $a2);
    is(sprintf("%.6f", $a3->values->[0]), '0.321751');
    is(sprintf("%.6f", $a3->values->[1]), '0.463648');
    is_deeply(r->dim($a3)->values, [2]);
    ok(r->is_double($a3));
  }

  # atan2 - y is -Inf, x is Inf
  {
    my $a1 = c(-Inf);
    my $a2 = c(Inf);
    my $a3 = r->atan2($a1, $a2);
    is(sprintf("%.6f", $a3->value), '-0.785398');
  }
  
  # atan2 - y is inf, x is -inf
  {
    my $a1 = c(Inf);
    my $a2 = c(-Inf);
    my $a3 = r->atan2($a1, $a2);
    is(sprintf("%.6f", $a3->value), '2.356194');
  }
  
  # atan2 - x and y is Inf
  {
    my $a1 = c(Inf);
    my $a2 = c(Inf);
    my $a3 = r->atan2($a1, $a2);
    is(sprintf("%.6f", $a3->value), '0.785398');
  }
  
  # atan2 - x and y is -Inf
  {
    my $a1 = c(-Inf);
    my $a2 = c(-Inf);
    my $a3 = r->atan2($a1, $a2);
    is(sprintf("%.6f", $a3->value), '-2.356194');
  }
  
  # atan2 - x is Inf
  {
    my $a1 = c(0);
    my $a2 = c(Inf);
    my $a3 = r->atan2($a1, $a2);
    is($a3->value, 0);
  }
  
  # atan2 - y >= 0, x is -Inf
  {
    my $a1 = c(0, 1);
    my $a2 = c(-Inf, -Inf);
    my $a3 = r->atan2($a1, $a2);
    is(sprintf("%.6f", $a3->values->[0]), 3.141593);
    is(sprintf("%.6f", $a3->values->[1]), 3.141593);
  }
  
  # atan2 - y >= 0, x is -Inf
  {
    my $a1 = c(-1);
    my $a2 = c(-Inf);
    my $a3 = r->atan2($a1, $a2);
    is(sprintf("%.6f", $a3->value), -3.141593);
  }
  
  # atan2 - y is Inf
  {
    my $a1 = c(Inf);
    my $a2 = c(0);
    my $a3 = r->atan2($a1, $a2);
    is(sprintf("%.6f", $a3->value), '1.570796');
  }
  
  # atan2 - y is -Inf
  {
    my $a1 = c(-Inf);
    my $a2 = c(0);
    my $a3 = r->atan2($a1, $a2);
    is(sprintf("%.6f", $a3->value), '-1.570796');
  }

  # atan2 - y is NA
  {
    my $a1 = r->atan2(NA, 0);
    ok(Rstats::Util::is_na($a1->value));
  }  

  # atan2 - x is NA
  {
    my $a1 = r->atan2(0, NA);
    ok(Rstats::Util::is_na($a1->value));
  }

  # atan2 - y is NaN
  {
    my $a1 = r->atan2(NaN, 0);
    ok(Rstats::Util::is_nan($a1->value));
  }
  
  # atan2 - x is NaN
  {
    my $a1 = r->atan2(0, NaN);
    ok(Rstats::Util::is_nan($a1->value));
  }
}

# tan
{
  # tan - complex
  {
    my $a1 = c(1 + 2*i);
    my $a2 = r->tan($a1);
    my $exp = Math::Complex->make(1, 2)->tan;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is($a2->value->{re}, $exp_re);
    is($a2->value->{im}, $exp_im);
    ok(r->is_complex($a2));
  }
  
  # tan - double, array
  {
    my $a1 = array(c(2, 3));
    my $a2 = r->tan($a1);
    is_deeply(
      $a2->values,
      [
        Math::Trig::tan(2),
        Math::Trig::tan(3),
      ]
    );
    is_deeply(r->dim($a2)->values, [2]);
    ok(r->is_double($a2));
  }
}

# cos
{
  # cos - complex
  {
    my $a1 = c(1 + 2*i);
    my $a2 = r->cos($a1);
    my $exp = Math::Complex->make(1, 2)->cos;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is($a2->value->{re}, $exp_re);
    is($a2->value->{im}, $exp_im);
    ok(r->is_complex($a2));
  }
  
  # cos - double,array
  {
    my $a1 = array(c(pi/2, pi/3));
    my $a2 = r->cos($a1);
    is(sprintf("%.5f", $a2->values->[0]), '0.00000');
    is(sprintf("%.5f", $a2->values->[1]), '0.50000');
    is_deeply(r->dim($a2)->values, [2]);
    ok(r->is_double($a2));
  }

  # cos - Inf
  {
    my $a1 = c(Inf);
    my $a2 = r->cos($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }
  
  # cos - -Inf
  {
    my $a1 = c(-Inf);
    my $a2 = r->cos($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }

  # cos - NA
  {
    my $a1 = c(NA);
    my $a2 = r->cos($a1);
    ok(Rstats::Util::is_na($a2->value));
  }  

  # cos - NaN
  {
    my $a1 = c(NaN);
    my $a2 = r->cos($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }
}

# sin
{
  # sin - complex
  {
    my $a1 = c(1 + 2*i);
    my $a2 = r->sin($a1);
    my $exp = Math::Complex->make(1, 2)->sin;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is($a2->value->{re}, $exp_re);
    is($a2->value->{im}, $exp_im);
    ok(r->is_complex($a2));
  }
  
  # sin - double,array
  {
    my $a1 = array(c(pi/2, pi/6));
    my $a2 = r->sin($a1);
    is(sprintf("%.5f", $a2->values->[0]), '1.00000');
    is(sprintf("%.5f", $a2->values->[1]), '0.50000');
    is_deeply(r->dim($a2)->values, [2]);
    ok(r->is_double($a2));
  }

  # sin - Inf
  {
    my $a1 = c(Inf);
    my $a2 = r->sin($a1);
    ok(Rstats::Util::is_nan($a2->value));
  }
  
  # sin - -Inf
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
