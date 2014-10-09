use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::ElementFunc;
use Math::Trig ();

# str
{

  # str - array, one element
  {
    my $x1 = array(1, 1);
    is(r->str($x1), 'num [1(1d)] 1');
  }
  
  # str - array, one dimention
  {
    my $x1 = array(C('1:4'), c(4));
    is(r->str($x1), 'num [1:4(1d)] 1 2 3 4');
  }
  
  # str - array
  {
    my $x1 = array(C('1:12'), c(4, 3));
    is(r->str($x1), 'num [1:4, 1:3] 1 2 3 4 5 6 7 8 9 10 ...');
  }
  
  # str - vector, more than 10 element
  {
    my $x1 = C('1:11');
    is(r->str($x1), 'num [1:11] 1 2 3 4 5 6 7 8 9 10 ...');
  }

  # str - vector, 10 element
  {
    my $x1 = C('1:10');
    is(r->str($x1), 'num [1:10] 1 2 3 4 5 6 7 8 9 10');
  }

  # str - vector, logical
  {
    my $x1 = c(T, F);
    is(r->str($x1), 'logi [1:2] TRUE FALSE');
  }

  # str - vector, integer
  {
    my $x1 = c(1, 2)->as_integer;
    is(r->str($x1), 'int [1:2] 1 2');
  }

  # str - vector, complex
  {
    my $x1 = c(1 + 1*i, 1 + 2*i);
    is(r->str($x1), 'cplx [1:2] 1+1i 1+2i');
  }

  # str - vector, character
  {
    my $x1 = c("a", "b", "c");
    is(r->str($x1), 'chr [1:3] "a" "b" "c"');
  }

  # str - vector, one element
  {
    my $x1 = c(1);
    is(r->str($x1), 'num 1');
  }

  # str - vector, double
  {
    my $x1 = c(1, 2, 3);
    is(r->str($x1), 'num [1:3] 1 2 3');
  }
}

# expm1
{
  # expm1 - complex
  {
    my $x1 = c(1 + 2*i);
    eval {
      my $x2 = r->expm1($x1);
    };
    like($@, qr/unimplemented/);
  }
  
  # expm1 - double,array
  {
    my $x1 = array(c(1, 2));
    my $x2 = r->expm1($x1);
    is(sprintf("%.6f", $x2->values->[0]), '1.718282');
    is(sprintf("%.6f", $x2->values->[1]), '6.389056');
    is_deeply(r->dim($x2)->values, [2]);
    ok(r->is_double($x2));
  }

  # expm1 - double,less than 1e-5
  {
    my $x1 = array(c(0.0000001234));
    my $x2 = r->expm1($x1);
    my $x2_value_str = sprintf("%.13e", $x2->value);
    $x2_value_str =~ s/e-0+/e-/;
    is($x2_value_str, '1.2340000761378e-7');
    ok(r->is_double($x2));
  }

  # expm1 - integer
  {
    my $x1 = r->as_integer(array(c(2)));
    my $x2 = r->expm1($x1);
    is(sprintf("%.6f", $x2->value), '6.389056');
    ok(r->is_double($x2));
  }
    
  # expm1 - Inf
  {
    my $x1 = c(Inf);
    my $x2 = r->expm1($x1);
    ok($x2->element->is_positive_infinite);
  }
  
  # expm1 - -Inf
  {
    my $x1 = c(-Inf);
    my $x2 = r->expm1($x1);
    is($x2->value, -1);
  }

  # expm1 - NA
  {
    my $x1 = c(NA);
    my $x2 = r->expm1($x1);
    ok($x2->element->is_na);
  }

  # expm1 - NaN
  {
    my $x1 = c(NaN);
    my $x2 = r->expm1($x1);
    ok($x2->element->is_nan);
  }
}

# exp
{
  # exp - complex
  {
    my $x1 = c(1 + 2*i);
    my $x2 = r->exp($x1);
    is(sprintf("%.6f", $x2->value->{re}), '-1.131204');
    is(sprintf("%.6f", $x2->value->{im}), '2.471727');
    ok(r->is_complex($x2));
  }
  
  # exp - double,array
  {
    my $x1 = array(c(1, 2));
    my $x2 = r->exp($x1);
    is(sprintf("%.6f", $x2->values->[0]), '2.718282');
    is(sprintf("%.6f", $x2->values->[1]), '7.389056');
    is_deeply(r->dim($x2)->values, [2]);
    ok(r->is_double($x2));
  }

  # exp - Inf
  {
    my $x1 = c(Inf);
    my $x2 = r->exp($x1);
    ok($x2->element->is_positive_infinite);
  }
  
  # exp - -Inf
  {
    my $x1 = c(-Inf);
    my $x2 = r->exp($x1);
    is($x2->value, 0);
  }

  # exp - NA
  {
    my $x1 = c(NA);
    my $x2 = r->exp($x1);
    ok($x2->element->is_na);
  }  

  # exp - NaN
  {
    my $x1 = c(NaN);
    my $x2 = r->exp($x1);
    ok($x2->element->is_nan);
  }
}

# log10
{
  # log10 - complex
  {
    my $x1 = c(1 + 2*i);
    my $x2 = r->log10($x1);
    my $exp = Math::Complex->make(1, 2)->log / Math::Complex->make(10, 0)->log;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is($x2->value->{re}, $exp_re);
    is($x2->value->{im}, $exp_im);
    ok(r->is_complex($x2));
  }
  
  # log10 - double,array
  {
    my $x1 = array(c(10));
    my $x2 = r->log10($x1);
    is($x2->value, 1);
    is_deeply(r->dim($x2)->values, [1]);
    ok(r->is_double($x2));
  }
}

# log2
{
  # log2 - complex
  {
    my $x1 = c(1 + 2*i);
    my $x2 = r->log2($x1);
    my $exp = Math::Complex->make(1, 2)->log;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is($x2->value->{re}, $exp_re / log(2));
    is($x2->value->{im}, $exp_im / log(2));
    ok(r->is_complex($x2));
  }
  
  # log2 - double,array
  {
    my $x1 = array(c(2));
    my $x2 = r->log2($x1);
    is($x2->values->[0], 1);
    is_deeply(r->dim($x2)->values, [1]);
    ok(r->is_double($x2));
  }
}

# logb
{
  # logb - complex
  {
    my $x1 = c(1 + 2*i);
    my $x2 = r->logb($x1);
    my $exp = Math::Complex->make(1, 2)->log;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is($x2->value->{re}, $exp_re);
    is($x2->value->{im}, $exp_im);
    ok(r->is_complex($x2));
  }
  
  # logb - double,array
  {
    my $x1 = array(c(1, 10, -1, 0));
    my $x2 = r->logb($x1);
    is($x2->values->[0], 0);
    is(sprintf("%.5f", $x2->values->[1]), '2.30259');
    ok($x2->elements->[2]->is_nan);
    ok($x2->elements->[3]->is_negative_infinite);
    is_deeply(r->dim($x2)->values, [4]);
    ok(r->is_double($x2));
  }
}

# log
{
  # log - complex
  {
    my $x1 = c(1 + 2*i);
    my $x2 = r->log($x1);
    my $exp = Math::Complex->make(1, 2)->log;
    my $exp_re = Math::Complex::Re($exp);
    my $exp_im = Math::Complex::Im($exp);
    
    is($x2->value->{re}, $exp_re);
    is($x2->value->{im}, $exp_im);
    ok(r->is_complex($x2));
  }
  
  # log - double,array
  {
    my $x1 = array(c(1, 10, -1, 0));
    my $x2 = r->log($x1);
    is($x2->values->[0], 0);
    is(sprintf("%.5f", $x2->values->[1]), '2.30259');
    ok($x2->elements->[2]->is_nan);
    ok($x2->elements->[3]->is_negative_infinite);
    is_deeply(r->dim($x2)->values, [4]);
    ok(r->is_double($x2));
  }

  # log - Inf
  {
    my $x1 = c(Inf);
    my $x2 = r->log($x1);
    ok($x2->element->is_nan);
  }
  
  # log - Inf()
  {
    my $x1 = c(-Inf);
    my $x2 = r->log($x1);
    ok($x2->element->is_nan);
  }

  # log - NA
  {
    my $x1 = c(NA);
    my $x2 = r->log($x1);
    ok($x2->element->is_na);
  }  

  # log - NaN
  {
    my $x1 = c(NaN);
    my $x2 = r->log($x1);
    ok($x2->element->is_nan);
  }
}

# Arg
{
  # Arg - non 0 values
  {
    my $x1 = c(1 + 1*i, 2 + 2*i);
    my $x2 = r->Arg($x1);
    is_deeply($x2->values, [Math::Trig::pi / 4, Math::Trig::pi / 4]);
  }
  
  # Arg - 0 values
  {
    my $x1 = c(0 + 0*i);
    my $x2 = r->Arg($x1);
    is_deeply($x2->values, [0]);
  }
}

# sub
{
  # sub - case not ignore
  {
    my $x1 = c("a");
    my $x2 = c("b");
    my $x3 = c("ad1ad1", NA, "ad2ad2");
    my $x4 = r->sub($x1, $x2, $x3);
    is_deeply($x4->values, ["bd1ad1", undef, "bd2ad2"]);
  }

  # sub - case ignore
  {
    my $x1 = c("a");
    my $x2 = c("b");
    my $x3 = c("Ad1ad1", NA, "ad2ad2");
    my $x4 = r->sub($x1, $x2, $x3, {'ignore.case' => TRUE});
    is_deeply($x4->values, ["bd1ad1", undef, "bd2ad2"]);
  }
}

# gsub
{
  # gsub - case not ignore
  {
    my $x1 = c("a");
    my $x2 = c("b");
    my $x3 = c("ad1ad1", NA, "ad2ad2");
    my $x4 = r->gsub($x1, $x2, $x3);
    is_deeply($x4->values, ["bd1bd1", undef, "bd2bd2"]);
  }

  # sub - case ignore
  {
    my $x1 = c("a");
    my $x2 = c("b");
    my $x3 = c("Ad1Ad1", NA, "Ad2Ad2");
    my $x4 = r->gsub($x1, $x2, $x3, {'ignore.case' => TRUE});
    is_deeply($x4->values, ["bd1bd1", undef, "bd2bd2"]);
  }
}

# grep
{
  # grep - case not ignore
  {
    my $x1 = c("abc");
    my $x2 = c("abc", NA, "ABC");
    my $x3 = r->grep($x1, $x2);
    is_deeply($x3->values, [1]);
  }

  # grep - case ignore
  {
    my $x1 = c("abc");
    my $x2 = c("abc", NA, "ABC");
    my $x3 = r->grep($x1, $x2, {'ignore.case' => TRUE});
    is_deeply($x3->values, [1, 3]);
  }
}

# chartr
{
  my $x1 = c("a-z");
  my $x2 = c("A-Z");
  my $x3 = c("abc", "def", NA);
  my $x4 = r->chartr($x1, $x2, $x3);
  is_deeply($x4->values, ["ABC", "DEF", undef]);
}

# charmatch
{
  # charmatch - empty string
  {
    my $x1 = r->charmatch("", "");
    is_deeply($x1->value, 1);
  }
  
  # charmatch - multiple match
  {
    my $x1 = r->charmatch("m",   c("mean", "median", "mode"));
    is_deeply($x1->value, 0);
  }
  
  # charmatch - multiple match
  {
    my $x1 = r->charmatch("m",   c("mean", "median", "mode"));
    is_deeply($x1->value, 0);
  }

  # charmatch - one match
  {
    my $x1 = r->charmatch("med",   c("mean", "median", "mode"));
    is_deeply($x1->value, 2);
  }
    
  # charmatch - one match, multiple elements
  {
    my $x1 = r->charmatch(c("med", "mod"),   c("mean", "median", "mode"));
    is_deeply($x1->values, [2, 3]);
  }
}

# Im
{
  my $x1 = c(1 + 2*i, 2 + 3*i);
  my $x2 = r->Im($x1);
  is_deeply($x2->values, [2, 3]);
}

# Re
{
  my $x1 = c(1 + 2*i, 2 + 3*i);
  my $x2 = r->Re($x1);
  is_deeply($x2->values, [1, 2]);
}

# Conj
{
  my $x1 = c(1 + 2*i, 2 + 3*i);
  my $x2 = r->Conj($x1);
  is_deeply($x2->values, [{re => 1, im => -2}, {re => 2, im => -3}]);
}

# pi
{
  my $x1 = pi;
  is(sprintf('%.4f', $x1->value), 3.1416);
}

# complex
{
  # complex
  {
    my $x1 = r->complex(1, 2);
    is($x1->value->{re}, 1);
    is($x1->value->{im}, 2);
  }
  
  # complex - array
  {
    my $x1 = r->complex(c(1, 2), c(3, 4));
    is_deeply($x1->values, [{re => 1, im => 3}, {re => 2, im => 4}]);
  }

  # complex - array, some elements lack
  {
    my $x1 = r->complex(c(1, 2), c(3, 4, 5));
    is_deeply($x1->values, [{re => 1, im => 3}, {re => 2, im => 4}, {re => 0, im => 5}]);
  }

  # complex - re and im option
  {
    my $x1 = r->complex({re => c(1, 2), im => c(3, 4)});
    is_deeply($x1->values, [{re => 1, im => 3}, {re => 2, im => 4}]);
  }
  
  # complex - mod and arg option
  {
    my $x1 = r->complex({mod => 2, arg => pi});
    is($x1->value->{re}, -2);
    cmp_ok(abs($x1->value->{im}), '<', 1e-15);
  }

  # complex - mod and arg option, omit arg
  {
    my $x1 = r->complex({mod => 2});
    is($x1->value->{re}, 2);
    is(sprintf("%.5f", $x1->value->{im}), '0.00000');
  }

  # complex - mod and arg option, omit mod
  {
    my $x1 = r->complex({arg => pi});
    is($x1->value->{re}, -1);
    cmp_ok(abs($x1->value->{im}), '<', 1e-15);
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
  # order - 2 condition,decreasing TRUE
  {
    my $v1 = c(4, 3, 3, 3, 1, 5);
    my $v2 = c(1, 2, 3, 1, 1, 1);
    my $v3 = r->order($v1, $v2, {decreasing => TRUE});
    is_deeply($v3->values, [6, 1, 3, 2, 4, 5]);
  }
  
  # order - 2 condition,decreasing FALSE
  {
    my $v1 = c(4, 3, 3, 3, 1, 5);
    my $v2 = c(1, 2, 3, 1, 1, 1);
    my $v3 = r->order($v1, $v2);
    is_deeply($v3->values, [5, 4, 2, 3, 1, 6]);
  }
  
  # order - decreasing FALSE
  {
    my $v1 = c(2, 4, 3, 1);
    my $v2 = r->order($v1, {decreasing => FALSE});
    is_deeply($v2->values, [4, 1, 3, 2]);
  }
  
  # order - decreasing TRUE
  {
    my $v1 = c(2, 4, 3, 1);
    my $v2 = r->order($v1, {decreasing => TRUE});
    is_deeply($v2->values, [2, 3, 1, 4]);
  }

  # order - decreasing FALSE
  {
    my $v1 = c(2, 4, 3, 1);
    my $v2 = r->order($v1);
    is_deeply($v2->values, [4, 1, 3, 2]);
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

# quantile
{
  # quantile - odd number
  {
    my $v1 = C('0:100');
    my $v2 = r->quantile($v1);
    is_deeply($v2->values, [0, 25, 50, 75, 100]);
    is_deeply($v2->names->values, [qw/0%  25%  50%  75% 100% /]);
  }
  
  # quantile - even number
  {
    my $v1 = C('1:100');
    my $v2 = r->quantile($v1);
    is_deeply($v2->values, [1.00, 25.75, 50.50, 75.25, 100.00]);
  }

  # quantile - one element
  {
    my $v1 = c(1);
    my $v2 = r->quantile($v1);
    is_deeply($v2->values, [1, 1, 1, 1, 1]);
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
  is($na_element, Rstats::ElementFunc::NA);
}

# round
{
  # round - array reference
  {
    my $x1 = c(-1.3, 2.4, 2.5, 2.51, 3.51);
    my $x2 = r->round($x1);
    is_deeply(
      $x2->values,
      [-1, 2, 2, 3, 4]
    );
  }

  # round - matrix
  {
    my $x1 = c(-1.3, 2.4, 2.5, 2.51, 3.51);
    my $x2 = r->round(matrix($x1));
    is_deeply(
      $x2->values,
      [-1, 2, 2, 3, 4]
    );
  }

  # round - array reference
  {
    my $x1 = c(-13, 24, 25, 25.1, 35.1);
    my $x2 = r->round($x1, -1);
    is_deeply(
      $x2->values,
      [-10, 20, 20, 30, 40]
    );
  }

  # round - array reference
  {
    my $x1 = c(-13, 24, 25, 25.1, 35.1);
    my $x2 = r->round($x1, {digits => -1});
    is_deeply(
      $x2->values,
      [-10, 20, 20, 30, 40]
    );
  }
  
  # round - matrix
  {
    my $x1 = c(-13, 24, 25, 25.1, 35.1);
    my $x2 = r->round(matrix($x1), -1);
    is_deeply(
      $x2->values,
      [-10, 20, 20, 30, 40]
    );
  }
  
  # round - array reference
  {
    my $x1 = c(-0.13, 0.24, 0.25, 0.251, 0.351);
    my $x2 = r->round($x1, 1);
    is_deeply(
      $x2->values,
      [-0.1, 0.2, 0.2, 0.3, 0.4]
    );
  }

  # round - matrix
  {
    my $x1 = c(-0.13, 0.24, 0.25, 0.251, 0.351);
    my $x2 = r->round(matrix($x1), 1);
    is_deeply(
      $x2->values,
      [-0.1, 0.2, 0.2, 0.3, 0.4]
    );
  }
}

# trunc
{
  # trunc - array reference
  {
    my $x1 = c(-1.2, -1, 1, 1.2);
    my $x2 = r->trunc($x1);
    is_deeply(
      $x2->values,
      [-1, -1, 1, 1]
    );
  }

  # trunc - matrix
  {
    my $x1 = c(-1.2, -1, 1, 1.2);
    my $x2 = r->trunc(matrix($x1));
    is_deeply(
      $x2->values,
      [-1, -1, 1, 1]
    );
  }
}

# floor
{
  # floor - array reference
  {
    my $x1 = c(2.5, 2.0, -1.0, -1.3);
    my $x2 = r->floor($x1);
    is_deeply(
      $x2->values,
      [2, 2, -1, -2]
    );
  }

  # floor - matrix
  {
    my $x1 = c(2.5, 2.0, -1.0, -1.3);
    my $x2 = r->floor(matrix($x1));
    is_deeply(
      $x2->values,
      [2, 2, -1, -2]
    );
  }
}

# ceiling
{
  # ceiling - array reference
  {
    my $x1 = c(2.5, 2.0, -1.0, -1.3);
    my $x2 = r->ceiling($x1);
    is_deeply(
      $x2->values,
      [3, 2, -1, -1]
    );
  }

  # ceiling - matrix
  {
    my $x1 = c(2.5, 2.0, -1.0, -1.3);
    my $x2 = r->ceiling(matrix($x1));
    is_deeply(
      $x2->values,
      [3, 2, -1, -1]
    );
  }
}

# sqrt
{
  # sqrt - array reference
  {
    my $x1 = c(2, 3, 4);
    my $x2 = r->sqrt($x1);
    is_deeply(
      $x2->values,
      [
        sqrt $x1->values->[0],
        sqrt $x1->values->[1],
        sqrt $x1->values->[2]
      ]
    );
  }

  # sqrt - matrix
  {
    my $x1 = c(2, 3, 4);
    my $x2 = r->sqrt(matrix($x1));
    is_deeply(
      $x2->values,
      [
        sqrt $x1->values->[0],
        sqrt $x1->values->[1],
        sqrt $x1->values->[2]
      ]
    );
  }
}

# abs
{
  # abs - array refference
  {
    my $x1 = r->abs([-3, 4]);
    is_deeply($x1->values, [3, 4]);
  }

  # abs - matrix
  {
    my $x1 = r->abs(matrix([-3, 4]));
    is_deeply($x1->values, [3, 4]);
  }
  
  # abs - complex
  {
    my $x1 = c(3 + 4*i, 6 + 8*i);
    my $x2 = r->abs($x1);
    is_deeply($x2->values, [5, 10]);
  }
}

# Mod
{
  # Mod - complex
  {
    my $x1 = c(3 + 4*i, 6 + 8*i);
    my $x2 = r->Mod($x1);
    is_deeply($x2->values, [5, 10]);
  }
}
