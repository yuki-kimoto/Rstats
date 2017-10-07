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
}

# atan2
{
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
  # sin - double
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
