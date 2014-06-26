use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Math::Trig ();

my $r = Rstats->new;

# tanh
{
  # tanh - array reference
  {
    my $a1_values = [2, 3];
    my $a2 = $r->tanh($a1_values);
    is_deeply(
      $a2->values,
      [
        Math::Trig::tanh($a1_values->[0]),
        Math::Trig::tanh($a1_values->[1]),
      ]
    );
  }

  # atan - matrix
  {
    my $a1_values = [2, 3];
    my $a2 = $r->tanh($r->matrix($a1_values));
    is_deeply(
      $a2->values,
      [
        Math::Trig::tanh($a1_values->[0]),
        Math::Trig::tanh($a1_values->[1]),
      ]
    );
    is($a2->type, 'matrix');
  }
}

# cosh
{
  # cosh - array reference
  {
    my $a1_values = [2, 3];
    my $a2 = $r->cosh($a1_values);
    is_deeply(
      $a2->values,
      [
        Math::Trig::cosh($a1_values->[0]),
        Math::Trig::cosh($a1_values->[1]),
      ]
    );
  }

  # cosh - matrix
  {
    my $a1_values = [2, 3];
    my $a2 = $r->cosh($r->matrix($a1_values));
    is_deeply(
      $a2->values,
      [
        Math::Trig::cosh($a1_values->[0]),
        Math::Trig::cosh($a1_values->[1]),
      ]
    );
    is($a2->type, 'matrix');
  }
}

# sinh
{
  # sinh - array reference
  {
    my $a1_values = [2, 3];
    my $a2 = $r->sinh($a1_values);
    is_deeply(
      $a2->values,
      [
        Math::Trig::sinh($a1_values->[0]),
        Math::Trig::sinh($a1_values->[1]),
      ]
    );
  }

  # sinh - matrix
  {
    my $a1_values = [2, 3];
    my $a2 = $r->sinh($r->matrix($a1_values));
    is_deeply(
      $a2->values,
      [
        Math::Trig::sinh($a1_values->[0]),
        Math::Trig::sinh($a1_values->[1]),
      ]
    );
    is($a2->type, 'matrix');
  }
}

# atan
{
  # atan - array reference
  {
    my $a1_values = [2, 3];
    my $a2 = $r->atan($a1_values);
    is_deeply(
      $a2->values,
      [
        Math::Trig::atan($a1_values->[0]),
        Math::Trig::atan($a1_values->[1]),
      ]
    );
  }

  # atan - matrix
  {
    my $a1_values = [2, 3];
    my $a2 = $r->atan($r->matrix($a1_values));
    is_deeply(
      $a2->values,
      [
        Math::Trig::atan($a1_values->[0]),
        Math::Trig::atan($a1_values->[1]),
      ]
    );
    is($a2->type, 'matrix');
  }
}

# acos
{
  # acos - array reference
  {
    my $a1_values = [2, 3];
    my $a2 = $r->acos($a1_values);
    is_deeply(
      $a2->values,
      [
        Math::Trig::acos($a1_values->[0]),
        Math::Trig::acos($a1_values->[1]),
      ]
    );
  }

  # acos - matrix
  {
    my $a1_values = [2, 3];
    my $a2 = $r->acos($r->matrix($a1_values));
    is_deeply(
      $a2->values,
      [
        Math::Trig::acos($a1_values->[0]),
        Math::Trig::acos($a1_values->[1]),
      ]
    );
    is($a2->type, 'matrix');
  }
}

# asin
{
  # asin - array reference
  {
    my $a1_values = [2, 3];
    my $a2 = $r->asin($a1_values);
    is_deeply(
      $a2->values,
      [
        Math::Trig::asin($a1_values->[0]),
        Math::Trig::asin($a1_values->[1]),
      ]
    );
  }

  # asin - matrix
  {
    my $a1_values = [2, 3];
    my $a2 = $r->asin($r->matrix($a1_values));
    is_deeply(
      $a2->values,
      [
        Math::Trig::asin($a1_values->[0]),
        Math::Trig::asin($a1_values->[1]),
      ]
    );
    is($a2->type, 'matrix');
  }
}

# tan
{
  # tan - array reference
  {
    my $a1_values = [2, 3];
    my $a2 = $r->tan($a1_values);
    is_deeply(
      $a2->values,
      [
        Math::Trig::tan($a1_values->[0]),
        Math::Trig::tan($a1_values->[1]),
      ]
    );
  }

  # tan - matrix
  {
    my $a1_values = [2, 3];
    my $a2 = $r->tan($r->matrix($a1_values));
    is_deeply(
      $a2->values,
      [
        Math::Trig::tan($a1_values->[0]),
        Math::Trig::tan($a1_values->[1]),
      ]
    );
    is($a2->type, 'matrix');
  }
}

# cos
{
  # cos - array reference
  {
    my $a1_values = [2, 3];
    my $a2 = $r->cos($a1_values);
    is_deeply(
      $a2->values,
      [
        cos $a1_values->[0],
        cos $a1_values->[1],
      ]
    );
  }

  # cos - matrix
  {
    my $a1_values = [2, 3];
    my $a2 = $r->cos($r->matrix($a1_values));
    is_deeply(
      $a2->values,
      [
        cos $a1_values->[0],
        cos $a1_values->[1],
      ]
    );
    is($a2->type, 'matrix');
  }
}

# sin
{
  # sin - array reference
  {
    my $a1_values = [2, 3];
    my $a2 = $r->sin($a1_values);
    is_deeply(
      $a2->values,
      [
        sin $a1_values->[0],
        sin $a1_values->[1],
      ]
    );
  }

  # sin - matrix
  {
    my $a1_values = [2, 3];
    my $a2 = $r->sin($r->matrix($a1_values));
    is_deeply(
      $a2->values,
      [
        sin $a1_values->[0],
        sin $a1_values->[1],
      ]
    );
    is($a2->type, 'matrix');
  }
}

# log10
{
  # log10 - array reference
  {
    my $a1_values = [2, 3];
    my $a2 = $r->log10($a1_values);
    is_deeply(
      $a2->values,
      [
        log $a1_values->[0] / log 10,
        log $a1_values->[1] / log 10,
      ]
    );
  }

  # log10 - matrix
  {
    my $a1_values = [2, 3];
    my $a2 = $r->log10($r->matrix($a1_values));
    is_deeply(
      $a2->values,
      [
        log $a1_values->[0] / log 10,
        log $a1_values->[1] / log 10,
      ]
    );
    is($a2->type, 'matrix');
  }
}

# log2
{
  # log2 - array reference
  {
    my $a1_values = [2, 3];
    my $a2 = $r->log2($a1_values);
    is_deeply(
      $a2->values,
      [
        log $a1_values->[0] / log 2,
        log $a1_values->[1] / log 2,
      ]
    );
  }

  # log2 - matrix
  {
    my $a1_values = [2, 3];
    my $a2 = $r->log2($r->matrix($a1_values));
    is_deeply(
      $a2->values,
      [
        log $a1_values->[0] / log 2,
        log $a1_values->[1] / log 2,
      ]
    );
    is($a2->type, 'matrix');
  }
}

# log
{
  # log - array reference
  {
    my $a1_values = [2, 3];
    my $a2 = $r->log($a1_values);
    is_deeply(
      $a2->values,
      [
        log $a1_values->[0],
        log $a1_values->[1],
      ]
    );
  }

  # log - matrix
  {
    my $a1_values = [2, 3];
    my $a2 = $r->log($r->matrix($a1_values));
    is_deeply(
      $a2->values,
      [
        log $a1_values->[0],
        log $a1_values->[1],
      ]
    );
    is($a2->type, 'matrix');
  }
}

# expm1
{
  # expm1 - array refference
  {
    my $a1 = $r->expm1([-0.0000005, -4]);
    is_deeply($a1->values, [
      -0.0000005 + 0.5 * -0.0000005 * -0.0000005, exp(-4) - 1.0
    ]);
  }

  # expm1 - matrix
  {
    my $a1 = $r->expm1($r->matrix([-0.0000005, -4]));
    is_deeply($a1->values, [
      -0.0000005 + 0.5 * -0.0000005 * -0.0000005, exp(-4) - 1.0
    ]);
    is($a1->type, 'matrix');
  }
}

# sqrt
{
  # sqrt - array reference
  {
    my $a1_values = [2, 3, 4];
    my $a2 = $r->sqrt($a1_values);
    is_deeply(
      $a2->values,
      [
        sqrt $a1_values->[0],
        sqrt $a1_values->[1],
        sqrt $a1_values->[2]
      ]
    );
  }

  # sqrt - matrix
  {
    my $a1_values = [2, 3, 4];
    my $a2 = $r->sqrt($r->matrix($a1_values));
    is_deeply(
      $a2->values,
      [
        sqrt $a1_values->[0],
        sqrt $a1_values->[1],
        sqrt $a1_values->[2]
      ]
    );
    is($a2->type, 'matrix');
  }
}

# abs
{
  # abs - array refference
  {
    my $a1 = $r->abs([-3, 4]);
    is_deeply($a1->values, [3, 4]);
  }

  # abs - matrix
  {
    my $a1 = $r->abs($r->matrix([-3, 4]));
    is_deeply($a1->values, [3, 4]);
    is($a1->type, 'matrix');
  }
}

# exp
{
  my $v1 = $r->c([2, 3, 4]);
  my $v2 = $r->exp($v1);
  is_deeply(
    $v2->values,
    [
      exp $v1->values->[0],
      exp $v1->values->[1],
      exp $v1->values->[2]
    ]
  );
}

