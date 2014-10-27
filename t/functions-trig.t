use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::ElementsFunc;
use Math::Trig ();
use Math::Complex ();

# atanh
{
  # atanh - complex, 1 + 2i
  {
    my $x1 = c(1 + 2*i);
    my $x2 = r->atanh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '0.173287');
    is(sprintf("%.6f", $x2->value->{im}), '1.178097');
    ok(r->is_complex($x2));
  }

  # atanh - complex, 1 + 0i
  {
    my $x1 = c(1 + 0*i);
    my $x2 = r->atanh($x1);
    ok($x2->element->re->is_positive_infinite);
    ok($x2->element->im->is_nan);
    ok(r->is_complex($x2));
  }

  # atanh - complex, -1 + 0i
  {
    my $x1 = c(-1 + 0*i);
    my $x2 = r->atanh($x1);
    ok($x2->element->re->is_negative_infinite);
    ok($x2->element->im->is_nan);
    ok(r->is_complex($x2));
  }
        
  # atanh - double,array
  {
    my $x1 = array(c(0, 0.5, 1, 2, -1, -0.5, -2));
    my $x2 = r->atanh($x1);
    is($x2->values->[0], 0);
    is(sprintf("%.6f", $x2->values->[1]), '0.549306');
    ok($x2->decompose_elements->[2]->is_positive_infinite);
    ok($x2->decompose_elements->[3]->is_nan);
    ok($x2->decompose_elements->[4]->is_negative_infinite);
    is(sprintf("%.6f", $x2->values->[5]), '-0.549306');
    ok($x2->decompose_elements->[6]->is_nan);
    is_deeply(r->dim($x2)->values, [7]);
    ok(r->is_double($x2));
  }

  # atanh - Inf
  {
    my $x1 = c(Inf);
    my $x2 = r->atanh($x1);
    ok($x2->element->is_nan);
  }
  
  # atanh - -Inf
  {
    my $x1 = c(-Inf);
    my $x2 = r->atanh($x1);
    ok($x2->element->is_nan);
  }

  # atanh - NA
  {
    my $x1 = c(NA);
    my $x2 = r->atanh($x1);
    ok($x2->element->is_na);
  }

  # atanh - NaN
  {
    my $x1 = c(NaN);
    my $x2 = r->atanh($x1);
    ok($x2->element->is_nan);
  }
}

# acosh
{
  # acosh - complex, -1 + 0i
  {
    my $x1 = c(-1 + 0*i);
    my $x2 = r->acosh($x1);
    cmp_ok($x2->value->{re}, '==', 0);
    #is($x2->value->{re}, -0);
    is(sprintf("%.6f", $x2->value->{im}), '3.141593');
    ok(r->is_complex($x2));
  }

  # acosh - complex, -2 + 0i
  {
    my $x1 = c(-2 + 0*i);
    my $x2 = r->acosh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '1.316958');
    is(sprintf("%.6f", $x2->value->{im}), '3.141593');
    ok(r->is_complex($x2));
  }

  # acosh - complex, 0 + 1i
  {
    my $x1 = c(0 + 1*i);
    my $x2 = r->acosh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '0.881374');
    is(sprintf("%.6f", $x2->value->{im}), '1.570796');
    ok(r->is_complex($x2));
  }

  # acosh - complex, 1 + 1i
  {
    my $x1 = c(1 + 1*i);
    my $x2 = r->acosh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '1.061275');
    is(sprintf("%.6f", $x2->value->{im}), '0.904557');
    ok(r->is_complex($x2));
  }

  # acosh - complex, -1 + 1i
  {
    my $x1 = c(-1 + 1*i);
    my $x2 = r->acosh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '1.061275');
    is(sprintf("%.6f", $x2->value->{im}), '2.237036');
    ok(r->is_complex($x2));
  }
        
  # acosh - double,array
  {
    my $x1 = array(c(0, 1, 2));
    my $x2 = r->acosh($x1);
    ok($x2->decompose_elements->[0]->is_nan);
    is($x2->values->[1], 0);
    is(sprintf("%.6f", $x2->values->[2]), '1.316958');
    is_deeply(r->dim($x2)->values, [3]);
    ok(r->is_double($x2));
  }

  # acosh - Inf
  {
    my $x1 = c(Inf);
    my $x2 = r->acosh($x1);
    ok($x2->element->is_nan);
  }
  
  # acosh - -Inf
  {
    my $x1 = c(-Inf);
    my $x2 = r->acosh($x1);
    ok($x2->element->is_nan);
  }

  # acosh - NA
  {
    my $x1 = c(NA);
    my $x2 = r->acosh($x1);
    ok($x2->element->is_na);
  }

  # acosh - NaN
  {
    my $x1 = c(NaN);
    my $x2 = r->acosh($x1);
    ok($x2->element->is_nan);
  }
}

# asinh
{
  # asinh - complex, 1 + 2i
  {
    my $x1 = c(1 + 2*i);
    my $x2 = r->asinh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '1.469352');
    is(sprintf("%.6f", $x2->value->{im}), '1.063440');
    ok(r->is_complex($x2));
  }
  
  # asinh - double,array
  {
    my $x1 = array(c(0, 1));
    my $x2 = r->asinh($x1);
    is($x2->values->[0], '0');
    is(sprintf("%.6f", $x2->values->[1]), '0.881374');
    is_deeply(r->dim($x2)->values, [2]);
    ok(r->is_double($x2));
  }

  # asinh - Inf
  {
    my $x1 = c(Inf);
    my $x2 = r->asinh($x1);
    ok($x2->element->is_positive_infinite);
  }
  
  # asinh - -Inf
  {
    my $x1 = c(-Inf);
    my $x2 = r->asinh($x1);
    ok($x2->element->is_negative_infinite);
  }

  # asinh - NA
  {
    my $x1 = c(NA);
    my $x2 = r->asinh($x1);
    ok($x2->element->is_na);
  }

  # asinh - NaN
  {
    my $x1 = c(NaN);
    my $x2 = r->asinh($x1);
    ok($x2->element->is_nan);
  }
}

# tanh
{
  # tanh - complex, 1 + 2i
  {
    my $x1 = c(1 + 2*i);
    my $x2 = r->tanh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '1.166736');
    is(sprintf("%.6f", $x2->value->{im}), '-0.243458');
    ok(r->is_complex($x2));
  }

  # tanh - complex, -Inf - 2i
  {
    my $x1 = c(-Inf - 2*i);
    $ENV{a}++;
    my $x2 = r->tanh($x1);
    is($x2->value->{re}, '-1');
    cmp_ok($x2->value->{im}, '==', 0);
  }
  
  # tanh - complex, -Inf + 2i
  {
    my $x1 = c(-Inf + 2*i);
    my $x2 = r->tanh($x1);
    is($x2->value->{re}, '-1');
    is($x2->value->{im}, '0');
  }
  
  # tanh - double,array
  {
    my $x1 = array(c(0, 2));
    my $x2 = r->tanh($x1);
    is($x2->values->[0], '0');
    is(sprintf("%.6f", $x2->values->[1]), '0.964028');
    is_deeply(r->dim($x2)->values, [2]);
    ok(r->is_double($x2));
  }

  # tanh - Inf
  {
    my $x1 = c(Inf);
    my $x2 = r->tanh($x1);
    is($x2->value, '1');
  }
  
  # tanh - -Inf
  {
    my $x1 = c(-Inf);
    my $x2 = r->tanh($x1);
    is($x2->value, '-1');
  }

  # tanh - NA
  {
    my $x1 = c(NA);
    my $x2 = r->tanh($x1);
    ok($x2->element->is_na);
  }  

  # tanh - NaN
  {
    my $x1 = c(NaN);
    my $x2 = r->tanh($x1);
    ok($x2->element->is_nan);
  }
}

# cosh
{
  # cosh - complex, 1 + 2i
  {
    my $x1 = c(1 + 2*i);
    my $x2 = r->cosh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '-0.642148');
    is(sprintf("%.6f", $x2->value->{im}), '1.068607');
    ok(r->is_complex($x2));
  }

  # cosh - complex, -Inf - 2i
  {
    my $x1 = c(-Inf - 2*i);
    my $x2 = r->cosh($x1);
    ok($x2->element->re->is_negative_infinite);
    ok($x2->element->im->is_positive_infinite);
  }
  
  # cosh - complex, -Inf + 2i
  {
    my $x1 = c(-Inf + 2*i);
    my $x2 = r->cosh($x1);
    ok($x2->element->re->is_negative_infinite);
    ok($x2->element->im->is_negative_infinite);
  }
  
  # cosh - double,array
  {
    my $x1 = array(c(0, Inf, 2, -Inf));
    my $x2 = r->cosh($x1);
    is($x2->values->[0], '1');
    ok($x2->decompose_elements->[1]->is_positive_infinite);
    is(sprintf("%.6f", $x2->values->[2]), '3.762196');
    ok($x2->decompose_elements->[3]->is_positive_infinite);
    is_deeply(r->dim($x2)->values, [4]);
    ok(r->is_double($x2));
  }

  # cosh - Inf
  {
    my $x1 = c(Inf);
    my $x2 = r->cosh($x1);
    ok($x2->element->is_positive_infinite);
  }
  
  # cosh - -Inf
  {
    my $x1 = c(-Inf);
    my $x2 = r->cosh($x1);
    ok($x2->element->is_positive_infinite);
  }

  # cosh - NA
  {
    my $x1 = c(NA);
    my $x2 = r->cosh($x1);
    ok($x2->element->is_na);
  }  

  # cosh - NaN
  {
    my $x1 = c(NaN);
    my $x2 = r->cosh($x1);
    ok($x2->element->is_nan);
  }
}

# sinh
{
  # sinh - complex, 1 + 2i
  {
    my $x1 = c(1 + 2*i);
    my $x2 = r->sinh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '-0.489056');
    is(sprintf("%.6f", $x2->value->{im}), '1.403119');
    ok(r->is_complex($x2));
  }

  # sinh - complex, -Inf - 2i
  {
    my $x1 = c(-Inf - 2*i);
    my $x2 = r->sinh($x1);
    ok($x2->element->re->is_positive_infinite);
    ok($x2->element->im->is_negative_infinite);
  }
  
  # sinh - complex, -Inf + 2i
  {
    my $x1 = c(-Inf + 2*i);
    my $x2 = r->sinh($x1);
    ok($x2->element->re->is_positive_infinite);
    ok($x2->element->im->is_positive_infinite);
  }
  
  # sinh - double,array
  {
    my $x1 = array(c(0, Inf, 2, -Inf));
    my $x2 = r->sinh($x1);
    is($x2->values->[0], '0');
    ok($x2->decompose_elements->[1]->is_positive_infinite);
    is(sprintf("%.6f", $x2->values->[2]), '3.626860');
    ok($x2->decompose_elements->[3]->is_negative_infinite);
    is_deeply(r->dim($x2)->values, [4]);
    ok(r->is_double($x2));
  }

  # sinh - Inf
  {
    my $x1 = c(Inf);
    my $x2 = r->sinh($x1);
    ok($x2->element->is_positive_infinite);
  }
  
  # sinh - -Inf
  {
    my $x1 = c(-Inf);
    my $x2 = r->sinh($x1);
    ok($x2->element->is_negative_infinite);
  }

  # sinh - NA
  {
    my $x1 = c(NA);
    my $x2 = r->sinh($x1);
    ok($x2->element->is_na);
  }  

  # sinh - NaN
  {
    my $x1 = c(NaN);
    my $x2 = r->sinh($x1);
    ok($x2->element->is_nan);
  }
}

# atan
{
  # atan - complex, 0
  {
    my $x1 = c(0*i);
    my $x2 = r->atan($x1);
    is($x2->values->[0]{re}, 0);
    is($x2->values->[0]{im}, 0);
    ok(r->is_complex($x2));
  }

  # atan - complex, 1i
  {
    my $x1 = c(1*i);
    my $x2 = r->atan($x1);
    is($x2->values->[0]{re}, 0);
    ok($x2->decompose_elements->[0]->im->is_positive_infinite);
    ok(r->is_complex($x2));
  }
  
  # atan - complex, -1
  {
    my $x1 = c(-1*i);
    my $x2 = r->atan($x1);
    is($x2->values->[0]{re}, 0);
    ok($x2->decompose_elements->[0]->im->is_negative_infinite);
    ok(r->is_complex($x2));
  }

  # atan - complex, 1 + 2i
  {
    my $x1 = c(1 + 2*i);
    my $x2 = r->atan($x1);
    is(sprintf("%.6f", $x2->value->{re}), '1.338973');
    is(sprintf("%.6f", $x2->value->{im}), '0.402359');
  }
  
  # atan - double,array
  {
    my $x1 = array(c(0.5, 0.6));
    my $x2 = r->atan($x1);
    is(sprintf("%.6f", $x2->values->[0]), '0.463648');
    is(sprintf("%.6f", $x2->values->[1]), '0.540420');
    is_deeply(r->dim($x2)->values, [2]);
    ok(r->is_double($x2));
  }

  # atan - Inf
  {
    my $x1 = c(Inf);
    my $x2 = r->atan($x1);
    is(sprintf("%.6f", $x2->value), '1.570796');
  }
  
  # atan - -Inf
  {
    my $x1 = c(-Inf);
    my $x2 = r->atan($x1);
    is(sprintf("%.6f", $x2->value), '-1.570796');
  }

  # atan - NA
  {
    my $x1 = c(NA);
    my $x2 = r->atan($x1);
    ok($x2->element->is_na);
  }  

  # atan - NaN
  {
    my $x1 = c(NaN);
    my $x2 = r->atan($x1);
    ok($x2->element->is_nan);
  }
}

# acos
{
  # acos - complex, 1 + 2*i
  {
  
    my $x1 = c(1 + 2*i);
    my $x2 = r->acos($x1);
    is(sprintf("%.6f", $x2->value->{re}), '1.143718');
    is(sprintf("%.6f", $x2->value->{im}), '-1.528571');
  }

  # acos - complex, 0.5 + 0.5*i
  {
    my $x1 = c(0.5 + 0.5*i);
    my $x2 = r->acos($x1);
    is(sprintf("%.6f", $x2->value->{re}), '1.118518');
    is(sprintf("%.6f", $x2->value->{im}), '-0.530638');
  }

  # acos - complex, 1 + 1*i
  {
    my $x1 = c(1 + 1*i);
    my $x2 = r->acos($x1);
    is(sprintf("%.6f", $x2->value->{re}), '0.904557');
    is(sprintf("%.6f", $x2->value->{im}), '-1.061275');
  }

  # acos - complex, 1.5 + 1.5*i
  {
    my $x1 = c(1.5 + 1.5*i);
    my $x2 = r->acos($x1);
    is(sprintf("%.6f", $x2->value->{re}), '0.840395');
    is(sprintf("%.6f", $x2->value->{im}), '-1.449734');
  }

  # acos - complex, -0.5 - 0.5*i
  {
    my $x1 = c(-0.5 - 0.5*i);
    my $x2 = r->acos($x1);
    is(sprintf("%.6f", $x2->value->{re}), '2.023075');
    is(sprintf("%.6f", $x2->value->{im}), '0.530638');
  }

  # acos - complex, -1 - 1*i
  {
    my $x1 = c(-1 - 1*i);
    my $x2 = r->acos($x1);
    is(sprintf("%.6f", $x2->value->{re}), '2.237036');
    is(sprintf("%.6f", $x2->value->{im}), '1.061275');
  }

  # acos - complex, 0
  {
    my $x1 = c(0*i);
    my $x2 = r->acos($x1);
    is(sprintf("%.6f", $x2->values->[0]{re}), 1.570796);
    is($x2->values->[0]{im}, 0);
    ok(r->is_complex($x2));
  }

  # acos - complex, 1
  {
    my $x1 = c(1 + 0*i);
    my $x2 = r->acos($x1);
    is($x2->values->[0]{re}, 0);
    is($x2->values->[0]{im}, 0);
    ok(r->is_complex($x2));
  }
      
  # acos - complex, -1.5
  {
    my $x1 = c(-1.5 + 0*i);
    my $x2 = r->acos($x1);
    is(sprintf("%.6f", $x2->values->[0]{re}), '3.141593');
    is(sprintf("%.6f", $x2->values->[0]{im}), '-0.962424');
    ok(r->is_complex($x2));
  }

  # acos - double,array
  {
    my $x1 = array(c(1, 1.1, -1.1));
    my $x2 = r->acos($x1);
    is($x2->values->[0], 0);
    ok($x2->decompose_elements->[1]->is_nan);
    ok($x2->decompose_elements->[2]->is_nan);
    is_deeply(r->dim($x2)->values, [3]);
    ok(r->is_double($x2));
  }

  # acos - Inf
  {
    my $x1 = c(Inf);
    my $x2 = r->acos($x1);
    ok($x2->element->is_nan);
  }
  
  # acos - -Inf
  {
    my $x1 = c(-Inf);
    my $x2 = r->acos($x1);
    ok($x2->element->is_nan);
  }

  # acos - NA
  {
    my $x1 = c(NA);
    my $x2 = r->acos($x1);
    ok($x2->element->is_na);
  }  

  # acos - NaN
  {
    my $x1 = c(NaN);
    my $x2 = r->acos($x1);
    ok($x2->element->is_nan);
  }
}

# asin
{
  # asin - complex, 1 + 2*i
  {
    my $x1 = c(1 + 2*i);
    my $x2 = r->asin($x1);
    is(sprintf("%.6f", $x2->value->{re}), '0.427079');
    is(sprintf("%.6f", $x2->value->{im}), '1.528571');
  }

  # asin - complex, 0.5 + 0.5*i
  {
    my $x1 = c(0.5 + 0.5*i);
    my $x2 = r->asin($x1);
    is(sprintf("%.6f", $x2->value->{re}), '0.452278');
    is(sprintf("%.6f", $x2->value->{im}), '0.530638');
  }

  # asin - complex, 1 + 1*i
  {
    my $x1 = c(1 + 1*i);
    my $x2 = r->asin($x1);
    is(sprintf("%.6f", $x2->value->{re}), '0.666239');
    is(sprintf("%.6f", $x2->value->{im}), '1.061275');
  }

  # asin - complex, 1.5 + 1.5*i
  {
    my $x1 = c(1.5 + 1.5*i);
    my $x2 = r->asin($x1);
    is(sprintf("%.6f", $x2->value->{re}), '0.730401');
    is(sprintf("%.6f", $x2->value->{im}), '1.449734');
  }

  # asin - complex, -0.5 - 0.5*i
  {
    my $x1 = c(-0.5 - 0.5*i);
    my $x2 = r->asin($x1);
    is(sprintf("%.6f", $x2->value->{re}), '-0.452278');
    is(sprintf("%.6f", $x2->value->{im}), '-0.530638');
  }

  # asin - complex, -1 - 1*i
  {
    my $x1 = c(-1 - 1*i);
    my $x2 = r->asin($x1);
    is(sprintf("%.6f", $x2->value->{re}), '-0.666239');
    is(sprintf("%.6f", $x2->value->{im}), '-1.061275');
  }

  # asin - complex, 0
  {
    my $x1 = c(0*i);
    my $x2 = r->asin($x1);
    is($x2->values->[0]{re}, 0);
    is($x2->values->[0]{im}, 0);
    ok(r->is_complex($x2));
  }
    
  # asin - complex, 0.5,
  {
    my $x1 = c(-1.5 + 0*i);
    my $x2 = r->asin($x1);
    is(sprintf("%.6f", $x2->values->[0]{re}), '-1.570796');
    is(sprintf("%.6f", $x2->values->[0]{im}), '0.962424');
    ok(r->is_complex($x2));
  }

  # asin - double,array
  {
    my $x1 = array(c(1, 1.1, -1.1));
    my $x2 = r->asin($x1);
    is(sprintf("%.6f", $x2->values->[0]), '1.570796');
    ok($x2->decompose_elements->[1]->is_nan);
    ok($x2->decompose_elements->[2]->is_nan);
    is_deeply(r->dim($x2)->values, [3]);
    ok(r->is_double($x2));
  }

  # asin - Inf
  {
    my $x1 = c(Inf);
    my $x2 = r->asin($x1);
    ok($x2->element->is_nan);
  }
  
  # asin - -Inf
  {
    my $x1 = c(-Inf);
    my $x2 = r->asin($x1);
    ok($x2->element->is_nan);
  }

  # asin - NA
  {
    my $x1 = c(NA);
    my $x2 = r->asin($x1);
    ok($x2->element->is_na);
  }  

  # asin - NaN
  {
    my $x1 = c(NaN);
    my $x2 = r->asin($x1);
    ok($x2->element->is_nan);
  }
}

# atan
{
  # atan - complex
  {
    my $x1 = c(1 + 2*i, i, -i);
    my $x2 = r->atan($x1);
    is(sprintf("%.6f", $x2->values->[0]{re}), '1.338973');
    is(sprintf("%.6f", $x2->values->[0]{im}), '0.402359');
    is($x2->values->[1]{re}, 0);
    is($x2->values->[1]{im}, 'Inf');
    is($x2->values->[2]{re}, 0);
    is($x2->values->[2]{im}, '-Inf');
    ok(r->is_complex($x2));
  }
  
  # atan - double,array
  {
    my $x1 = array(c(1, 2));
    my $x2 = r->atan($x1);
    is(sprintf("%.6f", $x2->values->[0]), '0.785398');
    is(sprintf("%.6f", $x2->values->[1]), '1.107149');
    is_deeply(r->dim($x2)->values, [2]);
    ok(r->is_double($x2));
  }

  # atan - Inf
  {
    my $x1 = c(Inf);
    my $x2 = r->atan($x1);
    is(sprintf("%.6f", $x2->values->[0]), '1.570796');
  }
  
  # atan - -Inf
  {
    my $x1 = c(-Inf);
    my $x2 = r->atan($x1);
    is(sprintf("%.6f", $x2->values->[0]), '-1.570796');
  }

  # atan - NA
  {
    my $x1 = c(NA);
    my $x2 = r->atan($x1);
    ok($x2->element->is_na);
  }  

  # atan - NaN
  {
    my $x1 = c(NaN);
    my $x2 = r->atan($x1);
    ok($x2->element->is_nan);
  }
}

# atan2
{
  # atan2 - complex
  {
    my $x1 = c(1 + 2*i);
    my $x2 = c(3 + 4*i);
    my $x3 = r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->value->{re}), 0.416491);
    is(sprintf("%.6f", $x3->value->{im}), 0.067066);
    ok(r->is_complex($x3));
  }
  
  # atan2 - double,array
  {
    my $x1 = array(c(1, 2));
    my $x2 = array(c(3, 4));
    my $x3 = r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->values->[0]), '0.321751');
    is(sprintf("%.6f", $x3->values->[1]), '0.463648');
    is_deeply(r->dim($x3)->values, [2]);
    ok(r->is_double($x3));
  }

  # atan2 - y is -Inf, x is Inf
  {
    my $x1 = c(-Inf);
    my $x2 = c(Inf);
    my $x3 = r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->value), '-0.785398');
  }
  
  # atan2 - y is inf, x is -inf
  {
    my $x1 = c(Inf);
    my $x2 = c(-Inf);
    my $x3 = r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->value), '2.356194');
  }
  
  # atan2 - x and y is Inf
  {
    my $x1 = c(Inf);
    my $x2 = c(Inf);
    my $x3 = r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->value), '0.785398');
  }
  
  # atan2 - x and y is -Inf
  {
    my $x1 = c(-Inf);
    my $x2 = c(-Inf);
    my $x3 = r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->value), '-2.356194');
  }
  
  # atan2 - x is Inf
  {
    my $x1 = c(0);
    my $x2 = c(Inf);
    my $x3 = r->atan2($x1, $x2);
    is($x3->value, 0);
  }
  
  # atan2 - y >= 0, x is -Inf
  {
    my $x1 = c(0, 1);
    my $x2 = c(-Inf, -Inf);
    my $x3 = r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->values->[0]), 3.141593);
    is(sprintf("%.6f", $x3->values->[1]), 3.141593);
  }
  
  # atan2 - y >= 0, x is -Inf
  {
    my $x1 = c(-1);
    my $x2 = c(-Inf);
    my $x3 = r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->value), -3.141593);
  }
  
  # atan2 - y is Inf
  {
    my $x1 = c(Inf);
    my $x2 = c(0);
    my $x3 = r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->value), '1.570796');
  }
  
  # atan2 - y is -Inf
  {
    my $x1 = c(-Inf);
    my $x2 = c(0);
    my $x3 = r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->value), '-1.570796');
  }

  # atan2 - y is NA
  {
    my $x1 = r->atan2(NA, 0);
    ok($x1->element->is_na);
  }  

  # atan2 - x is NA
  {
    my $x1 = r->atan2(0, NA);
    ok($x1->element->is_na);
  }

  # atan2 - y is NaN
  {
    my $x1 = r->atan2(NaN, 0);
    ok($x1->element->is_nan);
  }
  
  # atan2 - x is NaN
  {
    my $x1 = r->atan2(0, NaN);
    ok($x1->element->is_nan);
  }
}

# tan
{
  # tan - complex
  {
    my $x1 = c(1 + 2*i);
    my $x2 = r->tan($x1);
    my $exp = Math::Complex->make(1, 2)->tan;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is(sprintf("%.6f", $x2->value->{re}), 0.033813);
    is(sprintf("%.6f", $x2->value->{im}), 1.014794);
    ok(r->is_complex($x2));
  }
  
  # tan - double, array
  {
    my $x1 = array(c(2, 3));
    my $x2 = r->tan($x1);
    is_deeply(
      $x2->values,
      [
        Math::Trig::tan(2),
        Math::Trig::tan(3),
      ]
    );
    is_deeply(r->dim($x2)->values, [2]);
    ok(r->is_double($x2));
  }
}

# cos
{
  # cos - complex
  {
    my $x1 = c(1 + 2*i);
    my $x2 = r->cos($x1);
    my $exp = Math::Complex->make(1, 2)->cos;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is($x2->value->{re}, $exp_re);
    is($x2->value->{im}, $exp_im);
    ok(r->is_complex($x2));
  }
  
  # cos - double,array
  {
    my $x1 = array(c(pi/2, pi/3));
    my $x2 = r->cos($x1);
    cmp_ok(abs($x2->values->[0]), '<', 1e-15);
    is(sprintf("%.5f", $x2->values->[1]), '0.50000');
    is_deeply(r->dim($x2)->values, [2]);
    ok(r->is_double($x2));
  }

  # cos - Inf
  {
    my $x1 = c(Inf);
    my $x2 = r->cos($x1);
    ok($x2->element->is_nan);
  }
  
  # cos - -Inf
  {
    my $x1 = c(-Inf);
    my $x2 = r->cos($x1);
    ok($x2->element->is_nan);
  }

  # cos - NA
  {
    my $x1 = c(NA);
    my $x2 = r->cos($x1);
    ok($x2->element->is_na);
  }  

  # cos - NaN
  {
    my $x1 = c(NaN);
    my $x2 = r->cos($x1);
    ok($x2->element->is_nan);
  }
}

# sin
{
  # sin - complex
  {
    my $x1 = c(1 + 2*i);
    my $x2 = r->sin($x1);
    my $exp = Math::Complex->make(1, 2)->sin;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is($x2->value->{re}, $exp_re);
    is($x2->value->{im}, $exp_im);
    ok(r->is_complex($x2));
  }
  
  # sin - double,array
  {
    my $x1 = array(c(pi/2, pi/6));
    my $x2 = r->sin($x1);
    is(sprintf("%.5f", $x2->values->[0]), '1.00000');
    is(sprintf("%.5f", $x2->values->[1]), '0.50000');
    is_deeply(r->dim($x2)->values, [2]);
    ok(r->is_double($x2));
  }

  # sin - Inf
  {
    my $x1 = c(Inf);
    my $x2 = r->sin($x1);
    ok($x2->element->is_nan);
  }
  
  # sin - -Inf
  {
    my $x1 = c(-Inf);
    my $x2 = r->sin($x1);
    ok($x2->element->is_nan);
  }

  # sin - NA
  {
    my $x1 = c(NA);
    my $x2 = r->sin($x1);
    ok($x2->element->is_na);
  }  

  # sin - NaN
  {
    my $x1 = c(NaN);
    my $x2 = r->sin($x1);
    ok($x2->element->is_nan);
  }
}
