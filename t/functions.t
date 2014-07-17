use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::Util;
use Math::Trig ();

# rank
{
  my $v1 = c(1, 5, 5, 5, 3, 3, 7);
  my $v2 = r->rank($v1);
  is_deeply($v2->values, [1, 5, 5, 5, 2.5, 2.5, 7]);
}

# order
{
  # order - decreasing FALSE
  {
    my $v1 = c(2, 4, 3, 1);
    my $v2 = r->order($v1);
    is_deeply($v2->values, [4, 1, 3, 2]);
  }
  
  # order - decreasing TRUE
  {
    my $v1 = c(2, 4, 3, 1);
    my $v2 = r->order($v1, {decreasing => TRUE});
    is_deeply($v2->values, [2, 3, 1, 4]);
  }
}

# diff
{
  # diff - numeric
  {
    my $v1 = c(1, 5, 10, NA);
    my $v2 = r->diff($v1);
    is_deeply($v2->values, [4, 5, Rstats::Util::NA]);
  }
  
  # diff - complex
  {
    my $v1 = c(1 + 2*i, 5 + 3*i, NA);
    my $v2 = r->diff($v1);
    is_deeply($v2->values, [{re => 4, im => 1}, Rstats::Util::NA]);
  }
}

# paste
{
  # paste($str, $vector);
  {
    my $v1 = r->paste('x', C('1:3'));
    is_deeply($v1->values, ['x 1', 'x 2', 'x 3']);
  }
  # paste($str, $vector, {sep => ''});
  {
    my $v1 = r->paste('x', C('1:3'), {sep => ''});
    is_deeply($v1->values, ['x1', 'x2', 'x3']);
  }
}

# nchar
{
  my $v1 = c("AAA", "BB", NA);
  my $v2 = r->nchar($v1);
  is_deeply($v2->values, [3, 2, Rstats::Util::NA])
}

# tolower
{
  my $v1 = c("AA", "BB", NA);
  my $v2 = r->tolower($v1);
  is_deeply($v2->values, ["aa", "bb", Rstats::Util::NA])
}

# toupper
{
  my $v1 = c("aa", "bb", NA);
  my $v2 = r->toupper($v1);
  is_deeply($v2->values, ["AA", "BB", Rstats::Util::NA])
}

# match
{
  my $v1 = c("ATG", "GC", "AT", "GCGC");
  my $v2 = c("CGCA", "GC", "AT", "AT", "ATA");
  my $v3 = r->match($v1, $v2);
  is_deeply($v3->values, [Rstats::Util::NA, 2, 3, Rstats::Util::NA])
}

# range
{
  my $v1 = c(1, 2, 3);
  my $v2 = r->range($v1);
  is_deeply($v2->values, [1, 3]);
}

# pmax
{
  my $v1 = c(1, 6, 3, 8);
  my $v2 = c(5, 2, 7, 4);
  my $pmax = r->pmax($v1, $v2);
  is_deeply($pmax->values, [5, 6, 7, 8]);
}

# pmin
{
  my $v1 = c(1, 6, 3, 8);
  my $v2 = c(5, 2, 7, 4);
  my $pmin = r->pmin($v1, $v2);
  is_deeply($pmin->values, [1, 2, 3, 4]);
}
  
# rev
{
  my $v1 = c(2, 4, 3, 1);
  my $v2 = r->rev($v1);
  is_deeply($v2->values, [1, 3, 4, 2]);
}

# T, F
{
  my $v1 = c(T, F);
  is_deeply($v1->values, [Rstats::Util::TRUE, Rstats::Util::FALSE]);
}

# sqrt
{
  # sqrt - numeric
  {
    my $e1 = c(4, 9);
    my $e2 = r->sqrt($e1);
    is_deeply($e2->values, [2, 3]);
  }

  # sqrt - complex
  {
    my $e1 = c(-1 + 0*i);
    my $e2 = r->sqrt($e1);
    is_deeply($e2->value, {re => 0, im => 1});
  }
}
# min
{
  # min
  {
    my $v1 = c(1, 2, 3);
    my $v2 = r->min($v1);
    is_deeply($v2->values, [1]);
  }

  # min - multiple arrays
  {
    my $v1 = c(1, 2, 3);
    my $v2 = c(4, 5, 6);
    my $v3 = r->min($v1, $v2);
    is_deeply($v3->values, [1]);
  }
  
  # min - no argument
  {
    my $v1 = r->min(NULL);
    is_deeply($v1->values, [Rstats::Util::Inf]);
  }
  
  # min - contain NA
  {
    my $v1 = r->min(c(1, 2, NaN, NA));
    is_deeply($v1->values, [Rstats::Util::NA]);
  }
  
  # min - contain NaN
  {
    my $v1 = r->min(c(1, 2, NaN));
    is_deeply($v1->values, [Rstats::Util::NaN]);
  }
}

# max
{
  # max
  {
    my $v1 = c(1, 2, 3);
    my $v2 = r->max($v1);
    is_deeply($v2->values, [3]);
  }

  # max - multiple arrays
  {
    my $v1 = c(1, 2, 3);
    my $v2 = c(4, 5, 6);
    my $v3 = r->max($v1, $v2);
    is_deeply($v3->values, [6]);
  }
  
  # max - no argument
  {
    my $v1 = r->max(NULL);
    is_deeply($v1->values, [Rstats::Util::negativeInf]);
  }
  
  # max - contain NA
  {
    my $v1 = r->max(c(1, 2, NaN, NA));
    is_deeply($v1->values, [Rstats::Util::NA]);
  }
  
  # max - contain NaN
  {
    my $v1 = r->max(c(1, 2, NaN));
    is_deeply($v1->values, [Rstats::Util::NaN]);
  }
}

# median
{
  # median - odd number
  {
    my $v1 = c(2, 3, 3, 4, 5, 1);
    my $v2 = r->median($v1);
    is_deeply($v2->values, [3]);
  }
  # median - even number
  {
    my $v1 = c(2, 3, 3, 4, 5, 1, 6);
    my $v2 = r->median($v1);
    is_deeply($v2->values, [3.5]);
  }
}

# unique
{
  # uniqeu - numeric
  my $v1 = c(1, 1, 2, 2, 3, NA, NA, Inf, Inf);
  my $v2 = r->unique($v1);
  is_deeply($v2->values, [1, 2, 3, Rstats::Util::NA, Rstats::Util::Inf]);
}

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

