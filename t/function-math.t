use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Math::Trig ();
use Math::Complex ();

use Rstats;

my $r = Rstats->new;



# Im
{
  my $x1 = $r->c(1 + 2*$r->i, 2 + 3*$r->i);
  my $x2 = $r->Im($x1);
  is_deeply($x2->values, [2, 3]);
}

# Re
{
  my $x1 = $r->c(1 + 2*$r->i, 2 + 3*$r->i);
  my $x2 = $r->Re($x1);
  is_deeply($x2->values, [1, 2]);
}

# Conj
{
  my $x1 = $r->c(1 + 2*$r->i, 2 + 3*$r->i);
  my $x2 = $r->Conj($x1);
  is_deeply($x2->values, [{re => 1, im => -2}, {re => 2, im => -3}]);
}

# abs
{
  # abs - $r->array refference
  {
    my $x1 = $r->abs($r->c(-3, 4));
    is_deeply($x1->values, [3, 4]);
  }

  # abs - matrix
  {
    my $x1 = $r->abs($r->matrix($r->c(-3, 4)));
    is_deeply($x1->values, [3, 4]);
  }
  
  # abs - complex
  {
    my $x1 = $r->c(3 + 4*$r->i, 6 + 8*$r->i);
    my $x2 = $r->abs($x1);
    is_deeply($x2->values, [5, 10]);
  }
}

# Mod
{
  # Mod - complex
  {
    my $x1 = $r->c(3 + 4*$r->i, 6 + 8*$r->i);
    my $x2 = $r->Mod($x1);
    is_deeply($x2->values, [5, 10]);
  }
}

# atan2
{

  # atan2 - auto upgrade type
  {
    my $x1 = $r->c(1 + 2*$r->i);
    my $x2 = $r->c(3);
    my $x3 = $r->atan2($x1, $x2);
    ok($r->is->complex($x3));
    is(sprintf("%.6f", $x3->values->[0]->{re}), '0.491397');
    is(sprintf("%.6f", $x3->values->[0]->{im}), '0.641237');
  }

  # atan2 - complex
  {
    my $x1 = $r->c(1 + 2*$r->i);
    my $x2 = $r->c(3 + 4*$r->i);
    my $x3 = $r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->value->{re}), 0.416491);
    is(sprintf("%.6f", $x3->value->{im}), 0.067066);
    ok($r->is->complex($x3));
  }
  
  # atan2 - dim
  {
    my $x1 = $r->array($r->c(1, 2));
    my $x2 = $r->array($r->c(3, 4));
    my $x3 = $r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->values->[0]), '0.321751');
    is(sprintf("%.6f", $x3->values->[1]), '0.463648');
    is_deeply($r->dim($x3)->values, [2]);
    ok($r->is->double($x3));
  }

  # atan2 - double
  {
    my $x1 = $r->c(1, 2);
    my $x2 = $r->c(3, 4);
    my $x3 = $r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->values->[0]), '0.321751');
    is(sprintf("%.6f", $x3->values->[1]), '0.463648');
    ok($r->is->double($x3));
  }
  
  # atan2 - y is -$r->Inf, x is Inf
  {
    my $x1 = $r->c(-$r->Inf);
    my $x2 = $r->c($r->Inf);
    my $x3 = $r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->value), '-0.785398');
  }
  
  # atan2 - y is inf, x is -inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->c(-$r->Inf);
    my $x3 = $r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->value), '2.356194');
  }
  
  # atan2 - x and y is Inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->c($r->Inf);
    my $x3 = $r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->value), '0.785398');
  }
  
  # atan2 - x and y is -$r->Inf
  {
    my $x1 = $r->c(-$r->Inf);
    my $x2 = $r->c(-$r->Inf);
    my $x3 = $r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->value), '-2.356194');
  }
  
  # atan2 - x is Inf
  {
    my $x1 = $r->c(0);
    my $x2 = $r->c($r->Inf);
    my $x3 = $r->atan2($x1, $x2);
    is($x3->value, 0);
  }
  
  # atan2 - y >= 0, x is -$r->Inf
  {
    my $x1 = $r->c(0, 1);
    my $x2 = $r->c(-$r->Inf, -$r->Inf);
    my $x3 = $r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->values->[0]), 3.141593);
    is(sprintf("%.6f", $x3->values->[1]), 3.141593);
  }
  
  # atan2 - y >= 0, x is -$r->Inf
  {
    my $x1 = $r->c(-1);
    my $x2 = $r->c(-$r->Inf);
    my $x3 = $r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->value), -3.141593);
  }
  
  # atan2 - y is Inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->c(0);
    my $x3 = $r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->value), '1.570796');
  }
  
  # atan2 - y is -$r->Inf
  {
    my $x1 = $r->c(-$r->Inf);
    my $x2 = $r->c(0);
    my $x3 = $r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->value), '-1.570796');
  }

  # atan2 - y is NaN
  {
    my $x1 = $r->atan2($r->NaN, 0);
    is($x1->value, 'NaN');
  }
  
  # atan2 - x is NaN
  {
    my $x1 = $r->atan2(0, $r->NaN);
    is($x1->value, 'NaN');
  }

  # atan2 - character
  {
    my $x1 = $r->c("a");
    my $x2 = $r->c("b");
    my $x3;
    eval { $x3 = $r->atan2($x1, $x2) };
    like($@, qr#\QError in atan2() : non-numeric argument#);
  }

  # atan2 - NULL, left
  {
    my $x1 = $r->NULL;
    my $x2 = $r->c(1);
    my $x3;
    eval { $x3 = $r->atan2($x1, $x2) };
    like($@, qr#\QError in atan2() : non-numeric argument#);
  }

  # atan2 - NULL, right
  {
    my $x1 = $r->c(1);
    my $x2 = $r->NULL;
    my $x3;
    eval { $x3 = $r->atan2($x1, $x2) };
    like($@, qr#\QError in atan2() : non-numeric argument#);
  }
  
  # atan2 - different number elements
  {
    my $x1 = $r->c(1, 2);
    my $x2 = $r->c(3, 4, 3, 4);
    my $x3 = $r->atan2($x1, $x2);
    is(sprintf("%.6f", $x3->values->[0]), '0.321751');
    is(sprintf("%.6f", $x3->values->[1]), '0.463648');
    is(sprintf("%.6f", $x3->values->[2]), '0.321751');
    is(sprintf("%.6f", $x3->values->[3]), '0.463648');
    ok($r->is->double($x3));
  }
}

# tanh
{
  # tanh - complex, -$r->Inf - 2i
  {
    my $x0 = -$r->Inf;
    
    my $x1 = $r->c(-$r->Inf - 2*$r->i);
    my $x2 = $r->tanh($x1);
    is($x2->value->{re}, '-1');
    cmp_ok($x2->value->{im}, '==', 0);
  }
  
  # tanh - complex, 1 + 2i
  {
    my $x1 = $r->c(1 + 2*$r->i);
    my $x2 = $r->tanh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '1.166736');
    is(sprintf("%.6f", $x2->value->{im}), '-0.243458');
    ok($r->is->complex($x2));
  }
  
  # tanh - complex, 1 + Inf
  {
    my $x1 = $r->complex({re => 1, im => $r->Inf});
    my $x2 = $r->tanh($x1);
    is($x2->value->{re}, 'NaN');
    is($x2->value->{im}, 'NaN');
  }

  # tanh - complex, -$r->Inf + 2i
  {
    my $x1 = $r->c(-$r->Inf + 2*$r->i);
    my $x2 = $r->tanh($x1);
    is($x2->value->{re}, '-1');
    is($x2->value->{im}, '0');
  }
  
  # tanh - double,array
  {
    my $x1 = $r->array($r->c(0, 2));
    my $x2 = $r->tanh($x1);
    is($x2->values->[0], '0');
    is(sprintf("%.6f", $x2->values->[1]), '0.964028');
    is_deeply($r->dim($x2)->values, [2]);
    ok($r->is->double($x2));
  }

  # tanh - Inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->tanh($x1);
    is($x2->value, '1');
  }
  
  # tanh - -$r->Inf
  {
    my $x1 = $r->c(-$r->Inf);
    my $x2 = $r->tanh($x1);
    is($x2->value, '-1');
  }

  # tanh - NaN
  {
    my $x1 = $r->c($r->NaN);
    my $x2 = $r->tanh($x1);
    is($x2->value, 'NaN');
  }
}

# atanh
{
  # atanh - complex, 1 + 2i
  {
    my $x1 = $r->c(1 + 2*$r->i);
    my $x2 = $r->atanh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '0.173287');
    is(sprintf("%.6f", $x2->value->{im}), '1.178097');
    ok($r->is->complex($x2));
  }

  # atanh - complex, 1 + 0i
  {
    my $x1 = $r->c(1 + 0*$r->i);
    my $x2 = $r->atanh($x1);
    is($x2->value->{re}, 'Inf');
    is($x2->value->{im}, 'NaN');
    ok($r->is->complex($x2));
  }

  # atanh - complex, -1 + 0i
  {
    my $x1 = $r->c(-1 + 0*$r->i);
    my $x2 = $r->atanh($x1);
    is($x2->value->{re}, '-Inf');
    is($x2->value->{im}, 'NaN');
    ok($r->is->complex($x2));
  }
        
  # atanh - double,array
  {
    my $x1 = $r->array($r->c(0, 0.5, 1, 2, -1, -0.5, -2));
    my $x2 = $r->atanh($x1);
    is($x2->values->[0], 0);
    is(sprintf("%.6f", $x2->values->[1]), '0.549306');
    is($x2->values->[2], 'Inf');
    is($x2->values->[3], 'NaN');
    is($x2->values->[4], '-Inf');
    is(sprintf("%.6f", $x2->values->[5]), '-0.549306');
    is($x2->values->[6], 'NaN');
    is_deeply($r->dim($x2)->values, [7]);
    ok($r->is->double($x2));
  }

  # atanh - integer
  {
    my $x1 = $r->array($r->c(0, 1, 2, -1, -2));
    my $x2 = $r->atanh($x1);
    is($x2->values->[0], 0);
    is($x2->values->[1], 'Inf');
    is($x2->values->[2], 'NaN');
    is($x2->values->[3], '-Inf');
    is($x2->values->[4], 'NaN');
    is_deeply($r->dim($x2)->values, [5]);
    ok($r->is->double($x2));
  }

  # atanh - Inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->atanh($x1);
    is($x2->value, 'NaN');
  }
  
  # atanh - -$r->Inf
  {
    my $x1 = $r->c(-$r->Inf);
    my $x2 = $r->atanh($x1);
    is($x2->value, 'NaN');
  }

  # atanh - NaN
  {
    my $x1 = $r->c($r->NaN);
    my $x2 = $r->atanh($x1);
    is($x2->value, 'NaN');
  }
}

# acosh
{
  # acosh - complex, -1 + 0i
  {
    my $x1 = $r->c(-1 + 0*$r->i);
    my $x2 = $r->acosh($x1);
    cmp_ok($x2->value->{re}, '==', 0);
    #is($x2->value->{re}, -0);
    is(sprintf("%.6f", $x2->value->{im}), '3.141593');
    ok($r->is->complex($x2));
  }

  # acosh - complex, -2 + 0i
  {
    my $x1 = $r->c(-2 + 0*$r->i);
    my $x2 = $r->acosh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '1.316958');
    is(sprintf("%.6f", $x2->value->{im}), '3.141593');
    ok($r->is->complex($x2));
  }

  # acosh - complex, 0 + 1i
  {
    my $x1 = $r->c(0 + 1*$r->i);
    my $x2 = $r->acosh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '0.881374');
    is(sprintf("%.6f", $x2->value->{im}), '1.570796');
    ok($r->is->complex($x2));
  }

  # acosh - complex, 1 + 1i
  {
    my $x1 = $r->c(1 + 1*$r->i);
    my $x2 = $r->acosh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '1.061275');
    is(sprintf("%.6f", $x2->value->{im}), '0.904557');
    ok($r->is->complex($x2));
  }

  # acosh - complex, -1 + 1i
  {
    my $x1 = $r->c(-1 + 1*$r->i);
    my $x2 = $r->acosh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '1.061275');
    is(sprintf("%.6f", $x2->value->{im}), '2.237036');
    ok($r->is->complex($x2));
  }
        
  # acosh - double,array
  {
    my $x1 = $r->array($r->c(0, 1, 2));
    my $x2 = $r->acosh($x1);
    is($x2->values->[0], 'NaN');
    is($x2->values->[1], 0);
    is(sprintf("%.6f", $x2->values->[2]), '1.316958');
    is_deeply($r->dim($x2)->values, [3]);
    ok($r->is->double($x2));
  }

  # acosh - integer
  {
    my $x1 = $r->as->integer($r->array($r->c(0, 1, 2)));
    my $x2 = $r->acosh($x1);
    is($x2->values->[0], 'NaN');
    is($x2->values->[1], 0);
    is(sprintf("%.6f", $x2->values->[2]), '1.316958');
    is_deeply($r->dim($x2)->values, [3]);
    ok($r->is->double($x2));
  }

  # acosh - Inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->acosh($x1);
    is($x2->value, 'NaN');
  }
  
  # acosh - -$r->Inf
  {
    my $x1 = $r->c(-$r->Inf);
    my $x2 = $r->acosh($x1);
    is($x2->value, 'NaN');
  }

  # acosh - NaN
  {
    my $x1 = $r->c($r->NaN);
    my $x2 = $r->acosh($x1);
    is($x2->value, 'NaN');
  }
}

# asinh
{
  # asinh - complex, 1 + 2i
  {
    my $x1 = $r->c(1 + 2*$r->i);
    my $x2 = $r->asinh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '1.469352');
    is(sprintf("%.6f", $x2->value->{im}), '1.063440');
    ok($r->is->complex($x2));
  }
  
  # asinh - double
  {
    my $x1 = $r->array($r->c(0, 1));
    my $x2 = $r->asinh($x1);
    is($x2->values->[0], '0');
    is(sprintf("%.6f", $x2->values->[1]), '0.881374');
    is_deeply($r->dim($x2)->values, [2]);
    ok($r->is->double($x2));
  }

  # asinh - integer
  {
    my $x1 = $r->as->integer($r->array($r->c(0, 1)));
    my $x2 = $r->asinh($x1);
    is($x2->values->[0], '0');
    is(sprintf("%.6f", $x2->values->[1]), '0.881374');
    is_deeply($r->dim($x2)->values, [2]);
    ok($r->is->double($x2));
  }

  # asinh - Inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->asinh($x1);
    is($x2->value, 'Inf');
  }
  
  # asinh - -$r->Inf
  {
    my $x1 = $r->c(-$r->Inf);
    my $x2 = $r->asinh($x1);
    ok($x2->value, '-Inf');
  }

  # asinh - NaN
  {
    my $x1 = $r->c($r->NaN);
    my $x2 = $r->asinh($x1);
    is($x2->value, 'NaN');
  }
}

# cosh
{
  # cosh - complex, 1 + 2i
  {
    my $x1 = $r->c(1 + 2*$r->i);
    my $x2 = $r->cosh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '-0.642148');
    is(sprintf("%.6f", $x2->value->{im}), '1.068607');
    ok($r->is->complex($x2));
  }

  # cosh - complex, -$r->Inf - 2i
  {
    my $x1 = $r->c(-$r->Inf - 2*$r->i);
    my $x2 = $r->cosh($x1);
    is($x2->value->{re}, '-Inf');
    is($x2->value->{im}, 'Inf');
  }
  
  # cosh - complex, -$r->Inf + 2i
  {
    my $x1 = $r->c(-$r->Inf + 2*$r->i);
    my $x2 = $r->cosh($x1);
    is($x2->value->{re}, '-Inf');
    ok($x2->value->{im}, '-Inf');
  }
  
  # cosh - double,array
  {
    my $x1 = $r->array($r->c(0, $r->Inf, 2, -$r->Inf));
    my $x2 = $r->cosh($x1);
    is($x2->values->[0], '1');
    is($x2->values->[1], 'Inf');
    is(sprintf("%.6f", $x2->values->[2]), '3.762196');
    is($x2->values->[3], 'Inf');
    is_deeply($r->dim($x2)->values, [4]);
    ok($r->is->double($x2));
  }

  # cosh - Inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->cosh($x1);
    is($x2->value, 'Inf');
  }
  
  # cosh - -$r->Inf
  {
    my $x1 = $r->c(-$r->Inf);
    my $x2 = $r->cosh($x1);
    is($x2->value, 'Inf');
  }

  # cosh - NaN
  {
    my $x1 = $r->c($r->NaN);
    my $x2 = $r->cosh($x1);
    is($x2->value, 'NaN');
  }
}

# sinh
{
  # sinh - complex, 1 + 2i
  {
    my $x1 = $r->c(1 + 2*$r->i);
    my $x2 = $r->sinh($x1);
    is(sprintf("%.6f", $x2->value->{re}), '-0.489056');
    is(sprintf("%.6f", $x2->value->{im}), '1.403119');
    ok($r->is->complex($x2));
  }

  # sinh - complex, -$r->Inf - 2i
  {
    my $x1 = $r->c(-$r->Inf - 2*$r->i);
    my $x2 = $r->sinh($x1);
    is($x2->value->{re}, 'Inf');
    is($x2->value->{im}, '-Inf');
  }
  
  # sinh - complex, -$r->Inf + 2i
  {
    my $x1 = $r->c(-$r->Inf + 2*$r->i);
    my $x2 = $r->sinh($x1);
    is($x2->value->{re}, 'Inf');
    is($x2->value->{im}, 'Inf');
  }
  
  # sinh - double,array
  {
    my $x1 = $r->array($r->c(0, $r->Inf, 2, -$r->Inf));
    my $x2 = $r->sinh($x1);
    is($x2->values->[0], '0');
    is($x2->values->[1], 'Inf');
    is(sprintf("%.6f", $x2->values->[2]), '3.626860');
    is($x2->values->[3], '-Inf');
    is_deeply($r->dim($x2)->values, [4]);
    ok($r->is->double($x2));
  }

  # sinh - Inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->sinh($x1);
    is($x2->value, 'Inf');
  }
  
  # sinh - -$r->Inf
  {
    my $x1 = $r->c(-$r->Inf);
    my $x2 = $r->sinh($x1);
    is($x2->value, '-Inf');
  }

  # sinh - NaN
  {
    my $x1 = $r->c($r->NaN);
    my $x2 = $r->sinh($x1);
    is($x2->value, 'NaN');
  }
}

# atan
{
  # atan - complex, 0
  {
    my $x1 = $r->c(0*$r->i);
    my $x2 = $r->atan($x1);
    is($x2->values->[0]{re}, 0);
    is($x2->values->[0]{im}, 0);
    ok($r->is->complex($x2));
  }

  # atan - complex, 1i
  {
    my $x1 = $r->c(1*$r->i);
    my $x2 = $r->atan($x1);
    is($x2->values->[0]{re}, 0);
    is($x2->values->[0]->{im}, 'Inf');
    ok($r->is->complex($x2));
  }
  
  # atan - complex, -1
  {
    my $x1 = $r->c(-1*$r->i);
    my $x2 = $r->atan($x1);
    is($x2->values->[0]{re}, 0);
    is($x2->values->[0]->{im}, '-Inf');
    ok($r->is->complex($x2));
  }

  # atan - complex, 1 + 2i
  {
    my $x1 = $r->c(1 + 2*$r->i);
    my $x2 = $r->atan($x1);
    is(sprintf("%.6f", $x2->value->{re}), '1.338973');
    is(sprintf("%.6f", $x2->value->{im}), '0.402359');
  }
  
  # atan - double,array
  {
    my $x1 = $r->array($r->c(0.5, 0.6));
    my $x2 = $r->atan($x1);
    is(sprintf("%.6f", $x2->values->[0]), '0.463648');
    is(sprintf("%.6f", $x2->values->[1]), '0.540420');
    is_deeply($r->dim($x2)->values, [2]);
    ok($r->is->double($x2));
  }

  # atan - Inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->atan($x1);
    is(sprintf("%.6f", $x2->value), '1.570796');
  }
  
  # atan - -$r->Inf
  {
    my $x1 = $r->c(-$r->Inf);
    my $x2 = $r->atan($x1);
    is(sprintf("%.6f", $x2->value), '-1.570796');
  }

  # atan - NaN
  {
    my $x1 = $r->c($r->NaN);
    my $x2 = $r->atan($x1);
    is($x2->value, 'NaN');
  }
}

# acos
{
  # acos - complex, -1 - 1*$r->i
  {
    my $x1 = $r->c(-1 - 1*$r->i);
    my $x2 = $r->acos($x1);
    is(sprintf("%.6f", $x2->value->{re}), '2.237036');
    is(sprintf("%.6f", $x2->value->{im}), '1.061275');
  }


  # acos - complex, 1 + 2*$r->i
  {
  
    my $x1 = $r->c(1 + 2*$r->i);
    my $x2 = $r->acos($x1);
    is(sprintf("%.6f", $x2->value->{re}), '1.143718');
    is(sprintf("%.6f", $x2->value->{im}), '-1.528571');
  }

  # acos - complex, 0.5 + 0.5*$r->i
  {
    my $x1 = $r->c(0.5 + 0.5*$r->i);
    my $x2 = $r->acos($x1);
    is(sprintf("%.6f", $x2->value->{re}), '1.118518');
    is(sprintf("%.6f", $x2->value->{im}), '-0.530638');
  }

  # acos - complex, 1 + 1*$r->i
  {
    my $x1 = $r->c(1 + 1*$r->i);
    my $x2 = $r->acos($x1);
    is(sprintf("%.6f", $x2->value->{re}), '0.904557');
    is(sprintf("%.6f", $x2->value->{im}), '-1.061275');
  }

  # acos - complex, 1.5 + 1.5*$r->i
  {
    my $x1 = $r->c(1.5 + 1.5*$r->i);
    my $x2 = $r->acos($x1);
    is(sprintf("%.6f", $x2->value->{re}), '0.840395');
    is(sprintf("%.6f", $x2->value->{im}), '-1.449734');
  }

  # acos - complex, -0.5 - 0.5*$r->i
  {
    my $x1 = $r->c(-0.5 - 0.5*$r->i);
    my $x2 = $r->acos($x1);
    is(sprintf("%.6f", $x2->value->{re}), '2.023075');
    is(sprintf("%.6f", $x2->value->{im}), '0.530638');
  }

  # acos - complex, 0
  {
    my $x1 = $r->c(0*$r->i);
    my $x2 = $r->acos($x1);
    is(sprintf("%.6f", $x2->values->[0]{re}), 1.570796);
    is($x2->values->[0]{im}, 0);
    ok($r->is->complex($x2));
  }

  # acos - complex, 1
  {
    my $x1 = $r->c(1 + 0*$r->i);
    my $x2 = $r->acos($x1);
    is($x2->values->[0]{re}, 0);
    is($x2->values->[0]{im}, 0);
    ok($r->is->complex($x2));
  }
      
  # acos - complex, -1.5
  {
    my $x1 = $r->c(-1.5 + 0*$r->i);
    my $x2 = $r->acos($x1);
    is(sprintf("%.6f", $x2->values->[0]{re}), '3.141593');
    is(sprintf("%.6f", $x2->values->[0]{im}), '-0.962424');
    ok($r->is->complex($x2));
  }

  # acos - double,array
  {
    my $x1 = $r->array($r->c(1, 1.1, -1.1));
    my $x2 = $r->acos($x1);
    is($x2->values->[0], 0);
    is($x2->values->[1], 'NaN');
    is($x2->values->[2], 'NaN');
    is_deeply($r->dim($x2)->values, [3]);
    ok($r->is->double($x2));
  }

  # acos - Inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->acos($x1);
    is($x2->value, 'NaN');
  }
  
  # acos - -$r->Inf
  {
    my $x1 = $r->c(-$r->Inf);
    my $x2 = $r->acos($x1);
    is($x2->value, 'NaN');
  }

  # acos - NaN
  {
    my $x1 = $r->c($r->NaN);
    my $x2 = $r->acos($x1);
    is($x2->value, 'NaN');
  }
}

# asin
{
  # asin - complex, 1 + 2*$r->i
  {
    my $x1 = $r->c(1 + 2*$r->i);
    my $x2 = $r->asin($x1);
    is(sprintf("%.6f", $x2->value->{re}), '0.427079');
    is(sprintf("%.6f", $x2->value->{im}), '1.528571');
  }

  # asin - complex, 0.5 + 0.5*$r->i
  {
    my $x1 = $r->c(0.5 + 0.5*$r->i);
    my $x2 = $r->asin($x1);
    is(sprintf("%.6f", $x2->value->{re}), '0.452278');
    is(sprintf("%.6f", $x2->value->{im}), '0.530638');
  }

  # asin - complex, 1 + 1*$r->i
  {
    my $x1 = $r->c(1 + 1*$r->i);
    my $x2 = $r->asin($x1);
    is(sprintf("%.6f", $x2->value->{re}), '0.666239');
    is(sprintf("%.6f", $x2->value->{im}), '1.061275');
  }

  # asin - complex, 1.5 + 1.5*$r->i
  {
    my $x1 = $r->c(1.5 + 1.5*$r->i);
    my $x2 = $r->asin($x1);
    is(sprintf("%.6f", $x2->value->{re}), '0.730401');
    is(sprintf("%.6f", $x2->value->{im}), '1.449734');
  }

  # asin - complex, -0.5 - 0.5*$r->i
  {
    my $x1 = $r->c(-0.5 - 0.5*$r->i);
    my $x2 = $r->asin($x1);
    is(sprintf("%.6f", $x2->value->{re}), '-0.452278');
    is(sprintf("%.6f", $x2->value->{im}), '-0.530638');
  }

  # asin - complex, -1 - 1*$r->i
  {
    my $x1 = $r->c(-1 - 1*$r->i);
    my $x2 = $r->asin($x1);
    is(sprintf("%.6f", $x2->value->{re}), '-0.666239');
    is(sprintf("%.6f", $x2->value->{im}), '-1.061275');
  }

  # asin - complex, 0
  {
    my $x1 = $r->c(0*$r->i);
    my $x2 = $r->asin($x1);
    is($x2->values->[0]{re}, 0);
    is($x2->values->[0]{im}, 0);
    ok($r->is->complex($x2));
  }
    
  # asin - complex, 0.5,
  {
    my $x1 = $r->c(-1.5 + 0*$r->i);
    my $x2 = $r->asin($x1);
    is(sprintf("%.6f", $x2->values->[0]{re}), '-1.570796');
    is(sprintf("%.6f", $x2->values->[0]{im}), '0.962424');
    ok($r->is->complex($x2));
  }

  # asin - double,array
  {
    my $x1 = $r->array($r->c(1, 1.1, -1.1));
    my $x2 = $r->asin($x1);
    is(sprintf("%.6f", $x2->values->[0]), '1.570796');
    is($x2->values->[1], 'NaN');
    is($x2->values->[2], 'NaN');
    is_deeply($r->dim($x2)->values, [3]);
    ok($r->is->double($x2));
  }

  # asin - Inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->asin($x1);
    is($x2->value, 'NaN');
  }
  
  # asin - -$r->Inf
  {
    my $x1 = $r->c(-$r->Inf);
    my $x2 = $r->asin($x1);
    is($x2->value, 'NaN');
  }

  # asin - NaN
  {
    my $x1 = $r->c($r->NaN);
    my $x2 = $r->asin($x1);
    is($x2->value, 'NaN');
  }
}

# atan
{
  # atan - complex
  {
    my $x1 = $r->c(1 + 2*$r->i, $r->i, -$r->i);
    my $x2 = $r->atan($x1);
    is(sprintf("%.6f", $x2->values->[0]{re}), '1.338973');
    is(sprintf("%.6f", $x2->values->[0]{im}), '0.402359');
    is($x2->values->[1]{re}, 0);
    is($x2->values->[1]{im}, 'Inf');
    is($x2->values->[2]{re}, 0);
    is($x2->values->[2]{im}, '-Inf');
    ok($r->is->complex($x2));
  }
  
  # atan - double,array
  {
    my $x1 = $r->array($r->c(1, 2));
    my $x2 = $r->atan($x1);
    is(sprintf("%.6f", $x2->values->[0]), '0.785398');
    is(sprintf("%.6f", $x2->values->[1]), '1.107149');
    is_deeply($r->dim($x2)->values, [2]);
    ok($r->is->double($x2));
  }

  # atan - Inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->atan($x1);
    is(sprintf("%.6f", $x2->values->[0]), '1.570796');
  }
  
  # atan - -$r->Inf
  {
    my $x1 = $r->c(-$r->Inf);
    my $x2 = $r->atan($x1);
    is(sprintf("%.6f", $x2->values->[0]), '-1.570796');
  }

  # atan - NaN
  {
    my $x1 = $r->c($r->NaN);
    my $x2 = $r->atan($x1);
    is($x2->value, 'NaN');
  }
}

# tan
{
  # tan - complex
  {
    my $x1 = $r->c(1 + 2*$r->i);
    my $x2 = $r->tan($x1);
    my $exp = Math::Complex->make(1, 2)->tan;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is(sprintf("%.6f", $x2->value->{re}), 0.033813);
    is(sprintf("%.6f", $x2->value->{im}), 1.014794);
    ok($r->is->complex($x2));
  }
  
  # tan - double, $r->array
  {
    my $x1 = $r->array($r->c(2, 3));
    my $x2 = $r->tan($x1);
    is_deeply(
      $x2->values,
      [
        Math::Trig::tan(2),
        Math::Trig::tan(3),
      ]
    );
    is_deeply($r->dim($x2)->values, [2]);
    ok($r->is->double($x2));
  }
}

# cos
{
  # cos - complex
  {
    my $x1 = $r->c(1 + 2*$r->i);
    my $x2 = $r->cos($x1);
    my $exp = Math::Complex->make(1, 2)->cos;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is($x2->value->{re}, $exp_re);
    is($x2->value->{im}, $exp_im);
    ok($r->is->complex($x2));
  }
  
  # cos - double,array
  {
    my $x1 = $r->array($r->c($r->pi/2, $r->pi/3));
    my $x2 = $r->cos($x1);
    cmp_ok(abs($x2->values->[0]), '<', 1e-15);
    is(sprintf("%.5f", $x2->values->[1]), '0.50000');
    is_deeply($r->dim($x2)->values, [2]);
    ok($r->is->double($x2));
  }

  # cos - Inf
  {
    my $x1 = $r->c($r->Inf);
    my $x2 = $r->cos($x1);
    is($x2->value, 'NaN');
  }
  
  # cos - -$r->Inf
  {
    my $x1 = $r->c(-$r->Inf);
    my $x2 = $r->cos($x1);
    is($x2->value, 'NaN');
  }

  # cos - NaN
  {
    my $x1 = $r->c($r->NaN);
    my $x2 = $r->cos($x1);
    is($x2->value, 'NaN');
  }
}

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

  # sin - NaN
  {
    my $x1 = $r->c($r->NaN);
    my $x2 = $r->sin($x1);
    is($x2->value, 'NaN');
  }
}
