use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::EFunc;
use Math::Trig ();

# expm1
{
  # expm1 - complex
  {
    my $a1 = c(1 + 2*i);
    eval {
      my $a2 = r->expm1($a1);
    };
    like($@, qr/unimplemented/);
  }
  
  # expm1 - double,array
  {
    my $a1 = array(c(1, 2));
    my $a2 = r->expm1($a1);
    is(sprintf("%.6f", $a2->values->[0]), '1.718282');
    is(sprintf("%.6f", $a2->values->[1]), '6.389056');
    is_deeply(r->dim($a2)->values, [2]);
    ok(r->is_double($a2));
  }

  # expm1 - double,less than 1e-5
  {
    my $a1 = array(c(0.0000001234));
    my $a2 = r->expm1($a1);
    is(sprintf("%.13e", $a2->value), '1.2340000761378e-07');
    ok(r->is_double($a2));
  }

  # expm1 - integer
  {
    my $a1 = r->as_integer(array(c(2)));
    my $a2 = r->expm1($a1);
    is(sprintf("%.6f", $a2->value), '6.389056');
    ok(r->is_double($a2));
  }
    
  # expm1 - Inf
  {
    my $a1 = c(Inf);
    my $a2 = r->expm1($a1);
    ok($a2->element->is_positive_infinite);
  }
  
  # expm1 - -Inf
  {
    my $a1 = c(-Inf);
    my $a2 = r->expm1($a1);
    is($a2->value, -1);
  }

  # expm1 - NA
  {
    my $a1 = c(NA);
    my $a2 = r->expm1($a1);
    ok($a2->element->is_na);
  }

  # expm1 - NaN
  {
    my $a1 = c(NaN);
    my $a2 = r->expm1($a1);
    ok($a2->element->is_nan);
  }
}

# exp
{
  # exp - complex
  {
    my $a1 = c(1 + 2*i);
    my $a2 = r->exp($a1);
    is(sprintf("%.6f", $a2->value->{re}), '-1.131204');
    is(sprintf("%.6f", $a2->value->{im}), '2.471727');
    ok(r->is_complex($a2));
  }
  
  # exp - double,array
  {
    my $a1 = array(c(1, 2));
    my $a2 = r->exp($a1);
    is(sprintf("%.6f", $a2->values->[0]), '2.718282');
    is(sprintf("%.6f", $a2->values->[1]), '7.389056');
    is_deeply(r->dim($a2)->values, [2]);
    ok(r->is_double($a2));
  }

  # exp - Inf
  {
    my $a1 = c(Inf);
    my $a2 = r->exp($a1);
    ok($a2->element->is_positive_infinite);
  }
  
  # exp - -Inf
  {
    my $a1 = c(-Inf);
    my $a2 = r->exp($a1);
    is($a2->value, 0);
  }

  # exp - NA
  {
    my $a1 = c(NA);
    my $a2 = r->exp($a1);
    ok($a2->element->is_na);
  }  

  # exp - NaN
  {
    my $a1 = c(NaN);
    my $a2 = r->exp($a1);
    ok($a2->element->is_nan);
  }
}

# log10
{
  # log10 - complex
  {
    my $a1 = c(1 + 2*i);
    my $a2 = r->log10($a1);
    my $exp = Math::Complex->make(1, 2)->log / Math::Complex->make(10, 0)->log;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is($a2->value->{re}, $exp_re);
    is($a2->value->{im}, $exp_im);
    ok(r->is_complex($a2));
  }
  
  # log10 - double,array
  {
    my $a1 = array(c(10));
    my $a2 = r->log10($a1);
    is($a2->value, 1);
    is_deeply(r->dim($a2)->values, [1]);
    ok(r->is_double($a2));
  }
}

# log2
{
  # log2 - complex
  {
    my $a1 = c(1 + 2*i);
    my $a2 = r->log2($a1);
    my $exp = Math::Complex->make(1, 2)->log;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is($a2->value->{re}, $exp_re / log(2));
    is($a2->value->{im}, $exp_im / log(2));
    ok(r->is_complex($a2));
  }
  
  # log2 - double,array
  {
    my $a1 = array(c(2));
    my $a2 = r->log2($a1);
    is($a2->values->[0], 1);
    is_deeply(r->dim($a2)->values, [1]);
    ok(r->is_double($a2));
  }
}

# logb
{
  # logb - complex
  {
    my $a1 = c(1 + 2*i);
    my $a2 = r->logb($a1);
    my $exp = Math::Complex->make(1, 2)->log;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is($a2->value->{re}, $exp_re);
    is($a2->value->{im}, $exp_im);
    ok(r->is_complex($a2));
  }
  
  # logb - double,array
  {
    my $a1 = array(c(1, 10, -1, 0));
    my $a2 = r->logb($a1);
    is($a2->values->[0], 0);
    is(sprintf("%.5f", $a2->values->[1]), '2.30259');
    ok($a2->elements->[2]->is_nan);
    ok($a2->elements->[3]->is_negative_infinite);
    is_deeply(r->dim($a2)->values, [4]);
    ok(r->is_double($a2));
  }
}

# log
{
  # log - complex
  {
    my $a1 = c(1 + 2*i);
    my $a2 = r->log($a1);
    my $exp = Math::Complex->make(1, 2)->log;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is($a2->value->{re}, $exp_re);
    is($a2->value->{im}, $exp_im);
    ok(r->is_complex($a2));
  }
  
  # log - double,array
  {
    my $a1 = array(c(1, 10, -1, 0));
    my $a2 = r->log($a1);
    is($a2->values->[0], 0);
    is(sprintf("%.5f", $a2->values->[1]), '2.30259');
    ok($a2->elements->[2]->is_nan);
    ok($a2->elements->[3]->is_negative_infinite);
    is_deeply(r->dim($a2)->values, [4]);
    ok(r->is_double($a2));
  }

  # log - Inf
  {
    my $a1 = c(Inf);
    my $a2 = r->log($a1);
    ok($a2->element->is_nan);
  }
  
  # log - Inf()
  {
    my $a1 = c(-Inf);
    my $a2 = r->log($a1);
    ok($a2->element->is_nan);
  }

  # log - NA
  {
    my $a1 = c(NA);
    my $a2 = r->log($a1);
    ok($a2->element->is_na);
  }  

  # log - NaN
  {
    my $a1 = c(NaN);
    my $a2 = r->log($a1);
    ok($a2->element->is_nan);
  }
}

# Arg
{
  # Arg - non 0 values
  {
    my $a1 = c(1 + 1*i, 2 + 2*i);
    my $a2 = r->Arg($a1);
    is_deeply($a2->values, [Math::Trig::pi / 4, Math::Trig::pi / 4]);
  }
  
  # Arg - 0 values
  {
    my $a1 = c(0 + 0*i);
    my $a2 = r->Arg($a1);
    is_deeply($a2->values, [0]);
  }
}

# sub
{
  # sub - case not ignore
  {
    my $a1 = c("a");
    my $a2 = c("b");
    my $a3 = c("ad1ad1", NA, "ad2ad2");
    my $a4 = r->sub($a1, $a2, $a3);
    is_deeply($a4->values, ["bd1ad1", undef, "bd2ad2"]);
  }

  # sub - case ignore
  {
    my $a1 = c("a");
    my $a2 = c("b");
    my $a3 = c("Ad1ad1", NA, "ad2ad2");
    my $a4 = r->sub($a1, $a2, $a3, {'ignore.case' => TRUE});
    is_deeply($a4->values, ["bd1ad1", undef, "bd2ad2"]);
  }
}

# gsub
{
  # gsub - case not ignore
  {
    my $a1 = c("a");
    my $a2 = c("b");
    my $a3 = c("ad1ad1", NA, "ad2ad2");
    my $a4 = r->gsub($a1, $a2, $a3);
    is_deeply($a4->values, ["bd1bd1", undef, "bd2bd2"]);
  }

  # sub - case ignore
  {
    my $a1 = c("a");
    my $a2 = c("b");
    my $a3 = c("Ad1Ad1", NA, "Ad2Ad2");
    my $a4 = r->gsub($a1, $a2, $a3, {'ignore.case' => TRUE});
    is_deeply($a4->values, ["bd1bd1", undef, "bd2bd2"]);
  }
}

# grep
{
  # grep - case not ignore
  {
    my $a1 = c("abc");
    my $a2 = c("abc", NA, "ABC");
    my $a3 = r->grep($a1, $a2);
    is_deeply($a3->values, [1]);
  }

  # grep - case ignore
  {
    my $a1 = c("abc");
    my $a2 = c("abc", NA, "ABC");
    my $a3 = r->grep($a1, $a2, {'ignore.case' => TRUE});
    is_deeply($a3->values, [1, 3]);
  }
}

# chartr
{
  my $a1 = c("a-z");
  my $a2 = c("A-Z");
  my $a3 = c("abc", "def", NA);
  my $a4 = r->chartr($a1, $a2, $a3);
  is_deeply($a4->values, ["ABC", "DEF", undef]);
}

# charmatch
{
  # charmatch - empty string
  {
    my $a1 = r->charmatch("", "");
    is_deeply($a1->value, 1);
  }
  
  # charmatch - multiple match
  {
    my $a1 = r->charmatch("m",   c("mean", "median", "mode"));
    is_deeply($a1->value, 0);
  }
  
  # charmatch - multiple match
  {
    my $a1 = r->charmatch("m",   c("mean", "median", "mode"));
    is_deeply($a1->value, 0);
  }

  # charmatch - one match
  {
    my $a1 = r->charmatch("med",   c("mean", "median", "mode"));
    is_deeply($a1->value, 2);
  }
    
  # charmatch - one match, multiple elements
  {
    my $a1 = r->charmatch(c("med", "mod"),   c("mean", "median", "mode"));
    is_deeply($a1->values, [2, 3]);
  }
}

# Im
{
  my $a1 = c(1 + 2*i, 2 + 3*i);
  my $a2 = r->Im($a1);
  is_deeply($a2->values, [2, 3]);
}

# Re
{
  my $a1 = c(1 + 2*i, 2 + 3*i);
  my $a2 = r->Re($a1);
  is_deeply($a2->values, [1, 2]);
}

# Conj
{
  my $a1 = c(1 + 2*i, 2 + 3*i);
  my $a2 = r->Conj($a1);
  is_deeply($a2->values, [{re => 1, im => -2}, {re => 2, im => -3}]);
}

# pi
{
  my $a1 = pi;
  is(sprintf('%.4f', $a1->value), 3.1416);
}

# complex
{
  # complex
  {
    my $a1 = r->complex(1, 2);
    is($a1->value->{re}, 1);
    is($a1->value->{im}, 2);
  }
  
  # complex - array
  {
    my $a1 = r->complex(c(1, 2), c(3, 4));
    is_deeply($a1->values, [{re => 1, im => 3}, {re => 2, im => 4}]);
  }

  # complex - array, some elements lack
  {
    my $a1 = r->complex(c(1, 2), c(3, 4, 5));
    is_deeply($a1->values, [{re => 1, im => 3}, {re => 2, im => 4}, {re => 0, im => 5}]);
  }

  # complex - re and im option
  {
    my $a1 = r->complex({re => c(1, 2), im => c(3, 4)});
    is_deeply($a1->values, [{re => 1, im => 3}, {re => 2, im => 4}]);
  }
  
  # complex - mod and arg option
  {
    my $a1 = r->complex({mod => 2, arg => pi});
    is($a1->value->{re}, -2);
    is(sprintf("%.5f", $a1->value->{im}), '0.00000');
  }

  # complex - mod and arg option, omit arg
  {
    my $a1 = r->complex({mod => 2});
    is($a1->value->{re}, 2);
    is(sprintf("%.5f", $a1->value->{im}), '0.00000');
  }

  # complex - mod and arg option, omit mod
  {
    my $a1 = r->complex({arg => pi});
    is($a1->value->{re}, -1);
    is(sprintf("%.5f", $a1->value->{im}), '0.00000');
  }
}

# append
{
  # append - after option
  {
    my $v1 = c(1, 2, 3, 4, 5);
    r->append($v1, 1, {after => 3});
    is_deeply($v1->values, [1, 2, 3, 1, 4, 5]);
  }

  # append - no after option
  {
    my $v1 = c(1, 2, 3, 4, 5);
    r->append($v1, 1);
    is_deeply($v1->values, [1, 2, 3, 4, 5, 1]);
  }

  # append - vector
  {
    my $v1 = c(1, 2, 3, 4, 5);
    r->append($v1, c([6, 7]));
    is_deeply($v1->values, [1, 2, 3, 4, 5, 6, 7]);
  }
}

# replace
{
  {
    my $v1 = C('1:10');
    my $v2 = c(2, 5, 10);
    my $v3 = c(12, 15, 20);
    my $v4 = r->replace($v1, $v2, $v3);
    is_deeply($v4->values, [1, 12, 3, 4, 15, 6, 7, 8, 9, 20]);
  }
  
  # replace - single value
  {
    my $v1 = C('1:10');
    my $v2 = c(2, 5, 10);
    my $v4 = r->replace($v1, $v2, 11);
    is_deeply($v4->values, [1, 11, 3, 4, 11, 6, 7, 8, 9, 11]);
  }
  
  # replace - few values
  {
    my $v1 = C('1:10');
    my $v2 = c(2, 5, 10);
    my $v4 = r->replace($v1, $v2, c(12, 15));
    is_deeply($v4->values, [1, 12, 3, 4, 15, 6, 7, 8, 9, 12]);
  }
}

# is_element
{
  # cumprod - numeric
  {
    my $v1 = c(1, 2, 3, 4);
    my $v2 = c(1, 2, 3);
    my $v3 = r->is_element($v1, $v2);
    is_deeply($v3->values, [1, 1, 1, 0]);
  }
  
  # cumprod - complex
  {
    my $v1 = c(1*i, 2*i, 3*i, 4*i);
    my $v2 = c(1*i, 2*i, 3*i);
    my $v3 = r->is_element($v1, $v2);
    is_deeply($v3->values, [1, 1, 1, 0])
  }
}

# setequal
{
  # setequal - equal
  {
    my $v1 = c(2, 3, 1);
    my $v2 = c(3, 2, 1);
    my $v3 = r->setequal($v1, $v2);
    is_deeply($v3->value, 1);
  }

  # setequal - not equal
  {
    my $v1 = c(2, 3, 1);
    my $v2 = c(2, 3, 4);
    my $v3 = r->setequal($v1, $v2);
    is_deeply($v3->value, 0);
  }
    
  # setequal - not equal, element count is diffrent
  {
    my $v1 = c(2, 3, 1);
    my $v2 = c(2, 3, 1, 5);
    my $v3 = r->setequal($v1, $v2);
    is_deeply($v3->value, 0);
  }
}

# setdiff
{
  my $v1 = c(1, 2, 3, 4);
  my $v2 = c(3, 4);
  my $v3 = r->setdiff($v1, $v2);
  is_deeply($v3->values, [1, 2]);
}

# intersect
{
  my $v1 = c(1, 2, 3, 4);
  my $v2 = c(3, 4, 5, 6);
  my $v3 = r->intersect($v1, $v2);
  is_deeply($v3->values, [3, 4]);
}

# union
{
  my $v1 = c(1, 2, 3, 4);
  my $v2 = c(3, 4, 5, 6);
  my $v3 = r->union($v1, $v2);
  is_deeply($v3->values, [1, 2, 3, 4, 5, 6]);
}

# cummin
{
  my $v1 = c(7, 3, 5, 1);
  my $v2 = r->cummin($v1);
  is_deeply($v2->values, [7, 3, 3, 1]);
}

# cummax
{
  my $v1 = c(1, 5, 3, 7);
  my $v2 = r->cummax($v1);
  is_deeply($v2->values, [1, 5, 5, 7]);
}

# cumprod
{
  # cumprod - numeric
  {
    my $v1 = c(2, 3, 4);
    my $v2 = r->cumprod($v1);
    is_deeply($v2->values, [2, 6, 24]);
  }
  
  # cumprod - complex
  {
    my $v1 = c(2*i, 3*i, 4*i);
    my $v2 = r->cumprod($v1);
    is_deeply($v2->values, [{re => 0, im => 2}, {re => -6, im => 0}, {re => 0, im => -24}])
  }
}

# cumsum
{
  # cumsum - numeric
  {
    my $v1 = c(1, 2, 3);
    my $v2 = r->cumsum($v1);
    is_deeply($v2->values, [1, 3, 6]);
  }
  
  # cumsum - complex
  {
    my $v1 = c(1*i, 2*i, 3*i);
    my $v2 = r->cumsum($v1);
    is_deeply($v2->values, [{re => 0, im => 1}, {re => 0, im => 3}, {re => 0, im => 6}]);
  }
}

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
    is_deeply($v2->values, [4, 5, undef]);
  }
  
  # diff - complex
  {
    my $v1 = c(1 + 2*i, 5 + 3*i, NA);
    my $v2 = r->diff($v1);
    is_deeply($v2->values, [{re => 4, im => 1}, undef]);
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
  is_deeply($v2->values, [3, 2, undef])
}

# tolower
{
  my $v1 = c("AA", "BB", NA);
  my $v2 = r->tolower($v1);
  is_deeply($v2->values, ["aa", "bb", undef])
}

# toupper
{
  my $v1 = c("aa", "bb", NA);
  my $v2 = r->toupper($v1);
  is_deeply($v2->values, ["AA", "BB", undef])
}

# match
{
  my $v1 = c("ATG", "GC", "AT", "GCGC");
  my $v2 = c("CGCA", "GC", "AT", "AT", "ATA");
  my $v3 = r->match($v1, $v2);
  is_deeply($v3->values, [undef, 2, 3, undef])
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
  is_deeply($v1->values, [1, 0]);
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
    is_deeply($v1->values, ['Inf']);
  }
  
  # min - contain NA
  {
    my $v1 = r->min(c(1, 2, NaN, NA));
    is_deeply($v1->values, [undef]);
  }
  
  # min - contain NaN
  {
    my $v1 = r->min(c(1, 2, NaN));
    is_deeply($v1->values, ['NaN']);
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
    is_deeply($v1->values, ['-Inf']);
  }
  
  # max - contain NA
  {
    my $v1 = r->max(c(1, 2, NaN, NA));
    is_deeply($v1->values, [undef]);
  }
  
  # max - contain NaN
  {
    my $v1 = r->max(c(1, 2, NaN));
    is_deeply($v1->values, ['NaN']);
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
  is_deeply($v2->values, [1, 2, 3, undef, 'Inf']);
}

# NA
{
  my $na = NA;
  my $na_element = $na->element;
  is($na_element, Rstats::EFunc::NA);
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
  
  # abs - complex
  {
    my $a1 = c(3 + 4*i, 6 + 8*i);
    my $a2 = r->abs($a1);
    is_deeply($a2->values, [5, 10]);
  }
}

# Mod
{
  # Mod - complex
  {
    my $a1 = c(3 + 4*i, 6 + 8*i);
    my $a2 = r->Mod($a1);
    is_deeply($a2->values, [5, 10]);
  }
}
