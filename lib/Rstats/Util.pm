package Rstats::Util;
use strict;
use warnings;

use Scalar::Util ();
use B ();
use Carp 'croak';
use Rstats::Func;

sub is_perl_number {
  my ($value) = @_;
  
  return unless defined $value;
  
  return B::svref_2object(\$value)->FLAGS & (B::SVp_IOK | B::SVp_NOK) 
        && 0 + $value eq $value
        && $value * 0 == 0
}

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

sub parse_index {
  my ($a1, $drop, @_indexs) = @_;
  
  my $a1_dim = $a1->dim_as_array->values;
  my @indexs;
  my @a2_dim;

  if (ref $_indexs[0] && $_indexs[0]->is_array && $_indexs[0]->is_logical && @{$_indexs[0]->dim->elements} > 1) {
    my $a2 = $_indexs[0];
    my $a2_dim_values = $a2->dim->values;
    my $a2_elements = $a2->elements;
    my $positions = [];
    for (my $i = 0; $i < @$a2_elements; $i++) {
      next unless $a2_elements->[$i];
      push @$positions, $i + 1;
    }
    
    return ($positions, []);
  }
  else {
    for (my $i = 0; $i < @$a1_dim; $i++) {
      my $_index = $_indexs[$i];

      my $index = defined $_index ? Rstats::Func::to_array($_index) : Rstats::Func::NULL();
      my $index_values = $index->values;
      if (@$index_values && !$index->is_character && !$index->is_logical) {
        my $minus_count = 0;
        for my $index_value (@$index_values) {
          if ($index_value == 0) {
            croak "0 is invalid index";
          }
          else {
            $minus_count++ if $index_value < 0;
          }
        }
        croak "Can't min minus sign and plus sign"
          if $minus_count > 0 && $minus_count != @$index_values;
        $index->{_minus} = 1 if $minus_count > 0;
      }
      
      if (!@{$index->values}) {
        my $index_values_new = [1 .. $a1_dim->[$i]];
        $index = Rstats::Func::array($index_values_new);
      }
      elsif ($index->is_character) {
        if ($a1->is_vector) {
          my $index_new_values = [];
          for my $name (@{$index->values}) {
            my $i = 0;
            my $value;
            for my $a1_name (@{$a1->names->values}) {
              if ($name eq $a1_name) {
                $value = $a1->values->[$i];
                last;
              }
              $i++;
            }
            croak "Can't find name" unless defined $value;
            push @$index_new_values, $value;
          }
          $indexs[$i] = Rstats::Func::array($index_new_values);
        }
        elsif ($a1->is_matrix) {
          
        }
        else {
          croak "Can't support name except vector and matrix";
        }
      }
      elsif ($index->is_logical) {
        my $index_values_new = [];
        for (my $i = 0; $i < @{$index->values}; $i++) {
          push @$index_values_new, $i + 1 if $index->elements->[$i];
        }
        $index = Rstats::Func::array($index_values_new);
      }
      elsif ($index->{_minus}) {
        my $index_value_new = [];
        
        for my $k (1 .. $a1_dim->[$i]) {
          push @$index_value_new, $k unless grep { $_ == -$k } @{$index->values};
        }
        $index = Rstats::Func::array($index_value_new);
      }

      push @indexs, $index;

      my $count = @{$index->elements};
      push @a2_dim, $count unless $count == 1 && $drop;
    }
    @a2_dim = (1) unless @a2_dim;
    
    my $index_values = [map { $_->values } @indexs];
    my $ords = cross_product($index_values);
    my @positions = map { Rstats::Util::pos($_, $a1_dim) } @$ords;
  
    return (\@positions, \@a2_dim);
  }
}

sub cross_product {
  my $values = shift;

  my @idxs = (0) x @$values;
  my @idx_idx = 0..(@idxs - 1);
  my @a1 = map { $_->[0] } @$values;
  my $result = [];
  
  push @$result, [@a1];
  my $end_loop;
  while (1) {
    foreach my $i (@idx_idx) {
      if( $idxs[$i] < @{$values->[$i]} - 1 ) {
        $a1[$i] = $values->[$i][++$idxs[$i]];
        push @$result, [@a1];
        last;
      }
      
      if ($i == $idx_idx[-1]) {
        $end_loop = 1;
        last;
      }
      
      $idxs[$i] = 0;
      $a1[$i] = $values->[$i][0];
    }
    last if $end_loop;
  }
  
  return $result;
}

sub pos {
  my ($ord, $dim) = @_;
  
  my $pos = 0;
  for (my $d = 0; $d < @$dim; $d++) {
    if ($d > 0) {
      my $tmp = 1;
      $tmp *= $dim->[$_] for (0 .. $d - 1);
      $pos += $tmp * ($ord->[$d] - 1);
    }
    else {
      $pos += $ord->[$d];
    }
  }
  
  return $pos;
}

sub pos_to_index {
  my ($pos, $dim) = @_;
  
  my $index = [];
  my $before_dim_product = 1;
  $before_dim_product *= $dim->[$_] for (0 .. @$dim - 1);
  for (my $i = @{$dim} - 1; $i >= 0; $i--) {
    my $dim_product = 1;
    $dim_product *= $dim->[$_] for (0 .. $i - 1);
    my $reminder = $pos % $before_dim_product;
    my $quotient = int ($reminder / $dim_product);
    unshift @$index, $quotient + 1;
    $before_dim_product = $dim_product;
  }
  
  return $index;
}

1;
