use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::Util;
use Math::Trig ();

# NA
{
  my $na = NA;
  my $na_element = $na->element;
  is($na_element, Rstats::Util::NA);
}

# round
{
  # round - array reference
  {
    my $a1 = c(-1.3, 2.4, 2.5, 2.51, 3.51);
    my $a2 = r->round($a1);
    is_deeply(
      $a2->values,
      [-1, 2, 2, 3, 4]
    );
  }

  # round - matrix
  {
    my $a1 = c(-1.3, 2.4, 2.5, 2.51, 3.51);
    my $a2 = r->round(matrix($a1));
    is_deeply(
      $a2->values,
      [-1, 2, 2, 3, 4]
    );
  }

  # round - array reference
  {
    my $a1 = c(-13, 24, 25, 25.1, 35.1);
    my $a2 = r->round($a1, -1);
    is_deeply(
      $a2->values,
      [-10, 20, 20, 30, 40]
    );
  }

  # round - array reference
  {
    my $a1 = c(-13, 24, 25, 25.1, 35.1);
    my $a2 = r->round($a1, {digits => -1});
    is_deeply(
      $a2->values,
      [-10, 20, 20, 30, 40]
    );
  }
  
  # round - matrix
  {
    my $a1 = c(-13, 24, 25, 25.1, 35.1);
    my $a2 = r->round(matrix($a1), -1);
    is_deeply(
      $a2->values,
      [-10, 20, 20, 30, 40]
    );
  }
  
  # round - array reference
  {
    my $a1 = c(-0.13, 0.24, 0.25, 0.251, 0.351);
    my $a2 = r->round($a1, 1);
    is_deeply(
      $a2->values,
      [-0.1, 0.2, 0.2, 0.3, 0.4]
    );
  }

  # round - matrix
  {
    my $a1 = c(-0.13, 0.24, 0.25, 0.251, 0.351);
    my $a2 = r->round(matrix($a1), 1);
    is_deeply(
      $a2->values,
      [-0.1, 0.2, 0.2, 0.3, 0.4]
    );
  }
}

# trunc
{
  # trunc - array reference
  {
    my $a1 = c(-1.2, -1, 1, 1.2);
    my $a2 = r->trunc($a1);
    is_deeply(
      $a2->values,
      [-1, -1, 1, 1]
    );
  }

  # trunc - matrix
  {
    my $a1 = c(-1.2, -1, 1, 1.2);
    my $a2 = r->trunc(matrix($a1));
    is_deeply(
      $a2->values,
      [-1, -1, 1, 1]
    );
  }
}

# floor
{
  # floor - array reference
  {
    my $a1 = c(2.5, 2.0, -1.0, -1.3);
    my $a2 = r->floor($a1);
    is_deeply(
      $a2->values,
      [2, 2, -1, -2]
    );
  }

  # floor - matrix
  {
    my $a1 = c(2.5, 2.0, -1.0, -1.3);
    my $a2 = r->floor(matrix($a1));
    is_deeply(
      $a2->values,
      [2, 2, -1, -2]
    );
  }
}

# ceiling
{
  # ceiling - array reference
  {
    my $a1 = c(2.5, 2.0, -1.0, -1.3);
    my $a2 = r->ceiling($a1);
    is_deeply(
      $a2->values,
      [3, 2, -1, -1]
    );
  }

  # ceiling - matrix
  {
    my $a1 = c(2.5, 2.0, -1.0, -1.3);
    my $a2 = r->ceiling(matrix($a1));
    is_deeply(
      $a2->values,
      [3, 2, -1, -1]
    );
  }
}

# atanh
{
  # atanh - array reference
  {
    my $a1 = c(2, 3);
    my $a2 = r->atanh($a1);
    is_deeply(
      $a2->values,
      [
        Math::Trig::atanh($a1->values->[0]),
        Math::Trig::atanh($a1->values->[1]),
      ]
    );
  }

  # atanh - matrix
  {
    my $a1 = c(2, 3);
    my $a2 = r->atanh(matrix($a1));
    is_deeply(
      $a2->values,
      [
        Math::Trig::atanh($a1->values->[0]),
        Math::Trig::atanh($a1->values->[1]),
      ]
    );
  }
}

# acosh
{
  # acosh - array reference
  {
    my $a1 = c(2, 3);
    my $a2 = r->acosh($a1);
    is_deeply(
      $a2->values,
      [
        Math::Trig::acosh($a1->values->[0]),
        Math::Trig::acosh($a1->values->[1]),
      ]
    );
  }

  # acosh - matrix
  {
    my $a1 = c(2, 3);
    my $a2 = r->acosh(matrix($a1));
    is_deeply(
      $a2->values,
      [
        Math::Trig::acosh($a1->values->[0]),
        Math::Trig::acosh($a1->values->[1]),
      ]
    );
  }
}

# asinh
{
  # asinh - array reference
  {
    my $a1 = c(2, 3);
    my $a2 = r->asinh($a1);
    is_deeply(
      $a2->values,
      [
        Math::Trig::asinh($a1->values->[0]),
        Math::Trig::asinh($a1->values->[1]),
      ]
    );
  }

  # asinh - matrix
  {
    my $a1 = c(2, 3);
    my $a2 = r->asinh(matrix($a1));
    is_deeply(
      $a2->values,
      [
        Math::Trig::asinh($a1->values->[0]),
        Math::Trig::asinh($a1->values->[1]),
      ]
    );
  }
}

# tanh
{
  # tanh - array reference
  {
    my $a1 = c(2, 3);
    my $a2 = r->tanh($a1);
    is_deeply(
      $a2->values,
      [
        Math::Trig::tanh($a1->values->[0]),
        Math::Trig::tanh($a1->values->[1]),
      ]
    );
  }

  # atan - matrix
  {
    my $a1 = c(2, 3);
    my $a2 = r->tanh(matrix($a1));
    is_deeply(
      $a2->values,
      [
        Math::Trig::tanh($a1->values->[0]),
        Math::Trig::tanh($a1->values->[1]),
      ]
    );
  }
}

# cosh
{
  # cosh - array reference
  {
    my $a1 = c(2, 3);
    my $a2 = r->cosh($a1);
    is_deeply(
      $a2->values,
      [
        Math::Trig::cosh($a1->values->[0]),
        Math::Trig::cosh($a1->values->[1]),
      ]
    );
  }

  # cosh - matrix
  {
    my $a1 = c(2, 3);
    my $a2 = r->cosh(matrix($a1));
    is_deeply(
      $a2->values,
      [
        Math::Trig::cosh($a1->values->[0]),
        Math::Trig::cosh($a1->values->[1]),
      ]
    );
  }
}

# sinh
{
  # sinh - array reference
  {
    my $a1 = c(2, 3);
    my $a2 = r->sinh($a1);
    is_deeply(
      $a2->values,
      [
        Math::Trig::sinh($a1->values->[0]),
        Math::Trig::sinh($a1->values->[1]),
      ]
    );
  }

  # sinh - matrix
  {
    my $a1 = c(2, 3);
    my $a2 = r->sinh(matrix($a1));
    is_deeply(
      $a2->values,
      [
        Math::Trig::sinh($a1->values->[0]),
        Math::Trig::sinh($a1->values->[1]),
      ]
    );
  }
}

# atan
{
  # atan - array reference
  {
    my $a1 = c(2, 3);
    my $a2 = r->atan($a1);
    is_deeply(
      $a2->values,
      [
        Math::Trig::atan($a1->values->[0]),
        Math::Trig::atan($a1->values->[1]),
      ]
    );
  }

  # atan - matrix
  {
    my $a1 = c(2, 3);
    my $a2 = r->atan(matrix($a1));
    is_deeply(
      $a2->values,
      [
        Math::Trig::atan($a1->values->[0]),
        Math::Trig::atan($a1->values->[1]),
      ]
    );
  }
}

# acos
{
  # acos - array reference
  {
    my $a1 = c(2, 3);
    my $a2 = r->acos($a1);
    is_deeply(
      $a2->values,
      [
        Math::Trig::acos($a1->values->[0]),
        Math::Trig::acos($a1->values->[1]),
      ]
    );
  }

  # acos - matrix
  {
    my $a1 = c(2, 3);
    my $a2 = r->acos(matrix($a1));
    is_deeply(
      $a2->values,
      [
        Math::Trig::acos($a1->values->[0]),
        Math::Trig::acos($a1->values->[1]),
      ]
    );
  }
}

# asin
{
  # asin - array reference
  {
    my $a1 = c(2, 3);
    my $a2 = r->asin($a1);
    is_deeply(
      $a2->values,
      [
        Math::Trig::asin($a1->values->[0]),
        Math::Trig::asin($a1->values->[1]),
      ]
    );
  }

  # asin - matrix
  {
    my $a1 = c(2, 3);
    my $a2 = r->asin(matrix($a1));
    is_deeply(
      $a2->values,
      [
        Math::Trig::asin($a1->values->[0]),
        Math::Trig::asin($a1->values->[1]),
      ]
    );
  }
}

# tan
{
  # tan - array reference
  {
    my $a1 = c(2, 3);
    my $a2 = r->tan($a1);
    is_deeply(
      $a2->values,
      [
        Math::Trig::tan($a1->values->[0]),
        Math::Trig::tan($a1->values->[1]),
      ]
    );
  }

  # tan - matrix
  {
    my $a1 = c(2, 3);
    my $a2 = r->tan(matrix($a1));
    is_deeply(
      $a2->values,
      [
        Math::Trig::tan($a1->values->[0]),
        Math::Trig::tan($a1->values->[1]),
      ]
    );
  }
}

# cos
{
  # cos - array reference
  {
    my $a1 = c(2, 3);
    my $a2 = r->cos($a1);
    is_deeply(
      $a2->values,
      [
        cos $a1->values->[0],
        cos $a1->values->[1],
      ]
    );
  }

  # cos - matrix
  {
    my $a1 = c(2, 3);
    my $a2 = r->cos(matrix($a1));
    is_deeply(
      $a2->values,
      [
        cos $a1->values->[0],
        cos $a1->values->[1],
      ]
    );
  }
}

# sin
{
  # sin - array reference
  {
    my $a1 = c(2, 3);
    my $a2 = r->sin($a1);
    is_deeply(
      $a2->values,
      [
        sin $a1->values->[0],
        sin $a1->values->[1],
      ]
    );
  }

  # sin - matrix
  {
    my $a1 = c(2, 3);
    my $a2 = r->sin(matrix($a1));
    is_deeply(
      $a2->values,
      [
        sin $a1->values->[0],
        sin $a1->values->[1],
      ]
    );
  }
}

# log10
{
  # log10 - array reference
  {
    my $a1 = c(2, 3);
    my $a2 = r->log10($a1);
    is_deeply(
      $a2->values,
      [
        log $a1->values->[0] / log 10,
        log $a1->values->[1] / log 10,
      ]
    );
  }

  # log10 - matrix
  {
    my $a1 = c(2, 3);
    my $a2 = r->log10(matrix($a1));
    is_deeply(
      $a2->values,
      [
        log $a1->values->[0] / log 10,
        log $a1->values->[1] / log 10,
      ]
    );
  }
}

# log2
{
  # log2 - array reference
  {
    my $a1 = c(2, 3);
    my $a2 = r->log2($a1);
    is_deeply(
      $a2->values,
      [
        log $a1->values->[0] / log 2,
        log $a1->values->[1] / log 2,
      ]
    );
  }

  # log2 - matrix
  {
    my $a1 = c(2, 3);
    my $a2 = r->log2(matrix($a1));
    is_deeply(
      $a2->values,
      [
        log $a1->values->[0] / log 2,
        log $a1->values->[1] / log 2,
      ]
    );
  }
}

# log
{
  # log - array reference
  {
    my $a1 = c(2, 3);
    my $a2 = r->log($a1);
    is_deeply(
      $a2->values,
      [
        log $a1->values->[0],
        log $a1->values->[1],
      ]
    );
  }

  # log - matrix
  {
    my $a1 = c(2, 3);
    my $a2 = r->log(matrix($a1));
    is_deeply(
      $a2->values,
      [
        log $a1->values->[0],
        log $a1->values->[1],
      ]
    );
  }
}

# logb
{
  # logb - array reference
  {
    my $a1 = c(2, 3);
    my $a2 = r->logb($a1);
    is_deeply(
      $a2->values,
      [
        log $a1->values->[0],
        log $a1->values->[1],
      ]
    );
  }

  # logb - matrix
  {
    my $a1 = c(2, 3);
    my $a2 = r->logb(matrix($a1));
    is_deeply(
      $a2->values,
      [
        log $a1->values->[0],
        log $a1->values->[1],
      ]
    );
  }
}

# expm1
{
  # expm1 - array refference
  {
    my $a1 = r->expm1([-0.0000005, -4]);
    is_deeply($a1->values, [
      -0.0000005 + 0.5 * -0.0000005 * -0.0000005, exp(-4) - 1.0
    ]);
  }

  # expm1 - matrix
  {
    my $a1 = r->expm1(matrix([-0.0000005, -4]));
    is_deeply($a1->values, [
      -0.0000005 + 0.5 * -0.0000005 * -0.0000005, exp(-4) - 1.0
    ]);
  }
}

# sqrt
{
  # sqrt - array reference
  {
    my $a1 = c(2, 3, 4);
    my $a2 = r->sqrt($a1);
    is_deeply(
      $a2->values,
      [
        sqrt $a1->values->[0],
        sqrt $a1->values->[1],
        sqrt $a1->values->[2]
      ]
    );
  }

  # sqrt - matrix
  {
    my $a1 = c(2, 3, 4);
    my $a2 = r->sqrt(matrix($a1));
    is_deeply(
      $a2->values,
      [
        sqrt $a1->values->[0],
        sqrt $a1->values->[1],
        sqrt $a1->values->[2]
      ]
    );
  }
}

# abs
{
  # abs - array refference
  {
    my $a1 = r->abs([-3, 4]);
    is_deeply($a1->values, [3, 4]);
  }

  # abs - matrix
  {
    my $a1 = r->abs(matrix([-3, 4]));
    is_deeply($a1->values, [3, 4]);
  }
}

# exp
{
  my $v1 = r->c([2, 3, 4]);
  my $v2 = r->exp($v1);
  is_deeply(
    $v2->values,
    [
      exp $v1->values->[0],
      exp $v1->values->[1],
      exp $v1->values->[2]
    ]
  );
}

