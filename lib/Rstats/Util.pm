package Rstats::Util;
use strict;
use warnings;

use Scalar::Util ();

sub looks_like_number {
  my $value = shift;
  
  return if !defined $value || !CORE::length $value;
  $value =~ s/^ +//;
  $value =~ s/ +$//;
  
  if (Scalar::Util::looks_like_number $value) {
    return $value + 0;
  }
  else {
    return;
  }
}

sub looks_like_complex {
  my $value = shift;
  
  return if !defined $value || !CORE::length $value;
  $value =~ s/^ +//;
  $value =~ s/ +$//;
  
  my $re;
  my $im;
  
  if ($value =~ /^([\+\-]?[^\+\-]+)i$/) {
    $re = 0;
    $im = $1;
  }
  elsif($value =~ /^([\+\-]?[^\+\-]+)(?:([\+\-][^\+\-i]+)i)?$/) {
    $re = $1;
    $im = $2;
    $im = 0 unless defined $im;
  }
  else {
    return;
  }
  
  if (defined Rstats::Util::looks_like_number($re) && defined Rstats::Util::looks_like_number($im)) {
    return {re => $re + 0, im => $im + 0};
  }
  else {
    return;
  }
}

1;
