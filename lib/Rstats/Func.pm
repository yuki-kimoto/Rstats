package Rstats::Func;

use strict;
use warnings;

require Rstats;

use Carp 'croak';
use Rstats::Func;
use Rstats::Util;
use Text::UnicodeTable::Simple;

use List::Util ();
use POSIX ();
use Math::Round ();
use Encode ();

sub matrix {
  my $r = shift;
  
  
  my ($x1, $x_nrow, $x_ncol, $x_byrow, $x_dirnames)
    = Rstats::Func::args_array($r, ['x1', 'nrow', 'ncol', 'byrow', 'dirnames'], @_);

  Carp::croak "matrix method need data as frist argument"
    unless defined $x1;
  
  # Row count
  my $nrow;
  $nrow = $x_nrow->value if defined $x_nrow;
  
  # Column count
  my $ncol;
  $ncol = $x_ncol->value if defined $x_ncol;
  
  # By row
  my $byrow;
  $byrow = $x_byrow->value if defined $x_byrow;
  
  my $x1_values = $x1->values;
  my $x1_length = Rstats::Func::get_length($r, $x1);
  if (!defined $nrow && !defined $ncol) {
    $nrow = $x1_length;
    $ncol = 1;
  }
  elsif (!defined $nrow) {
    $nrow = int($x1_length / $ncol);
    $nrow ||= 1;
  }
  elsif (!defined $ncol) {
    $ncol = int($x1_length / $nrow);
    $ncol ||= 1;
  }
  my $length = $nrow * $ncol;
  
  my $dim = [$nrow, $ncol];
  my $matrix;
  my $x_matrix;

  if (Rstats::Func::get_type($r, $x1)  eq "double") {
    $x_matrix = c_double($r, $x1_values);
  }
  elsif (Rstats::Func::get_type($r, $x1)  eq "integer") {
    $x_matrix = c_integer($r, $x1_values);
  }
  else {
    croak("Invalid type " . Rstats::Func::get_type($r, $x1) . " is passed");
  }
  
  if ($byrow) {
    $matrix = Rstats::Func::array(
      $r,
      $x_matrix,
      Rstats::Func::c($r, $dim->[1], $dim->[0]),
    );
    
    $matrix = Rstats::Func::t($r, $matrix);
  }
  else {
    $matrix = Rstats::Func::array($r, $x_matrix, Rstats::Func::c($r, @$dim));
  }
  
  return $matrix;
}

sub as_matrix {
  my $r = shift;
  
  my $x1 = shift;
  
  my $x1_dim_elements = $x1->dim_as_array->values;
  my $x1_dim_count = @$x1_dim_elements;
  my $x2_dim_elements = [];
  my $row;
  my $col;
  if ($x1_dim_count == 2) {
    $row = $x1_dim_elements->[0];
    $col = $x1_dim_elements->[1];
  }
  else {
    $row = 1;
    $row *= $_ for @$x1_dim_elements;
    $col = 1;
  }
  
  my $x2 = Rstats::Func::as_vector($r, $x1);
  
  return Rstats::Func::matrix($r, $x2, $row, $col);
}

sub I {
  my $r = shift;
  
  my $x1 = shift;
  
  my $x2 = Rstats::Func::c($r, $x1);
  Rstats::Func::copy_attrs_to($r, $x1, $x2);
  
  return $x2;
}

sub subset {
  my $r = shift;
  
  my ($x1, $x_condition, $x_names)
    = args_array($r, ['x1', 'condition', 'names'], @_);
  
  $x_names = undef unless defined $x_names;
  
  my $x2 = $x1->get($x_condition, $x_names);
  
  return $x2;
}

sub t {
  my $r = shift;
  
  my $x1 = shift;
  
  my $x1_row = Rstats::Func::dim($r, $x1)->values->[0];
  my $x1_col = Rstats::Func::dim($r, $x1)->values->[1];
  
  my $x2 = matrix($r, 0, $x1_col, $x1_row);
  
  for my $row (1 .. $x1_row) {
    for my $col (1 .. $x1_col) {
      my $value = $x1->value($row, $col);
      $x2->at($col, $row);
      Rstats::Func::set($r, $x2, $value);
    }
  }
  
  return $x2;
}

my $type_level = {
  double => 4,
  integer => 3,
  na => 1
};

sub higher_type {
  my $r = shift;
  
  my ($type1, $type2) = @_;
  
  if ($type_level->{$type1} > $type_level->{$type2}) {
    return $type1;
  }
  else {
    return $type2;
  }
}

sub upper_tri {
  my $r = shift;
  
  my ($x1_m, $x1_diag) = args_array($r, ['m', 'diag'], @_);
  
  my $diag = defined $x1_diag ? $x1_diag->value : 0;
  
  my $x2_values = [];
  if (Rstats::Func::is_matrix($r, $x1_m)) {
    my $x1_dim_values = Rstats::Func::dim($r, $x1_m)->values;
    my $rows_count = $x1_dim_values->[0];
    my $cols_count = $x1_dim_values->[1];
    
    for (my $col = 0; $col < $cols_count; $col++) {
      for (my $row = 0; $row < $rows_count; $row++) {
        my $x2_value;
        if ($diag) {
          $x2_value = $col >= $row ? 1 : 0;
        }
        else {
          $x2_value = $col > $row ? 1 : 0;
        }
        push @$x2_values, $x2_value;
      }
    }
    
    my $x2 = matrix($r, Rstats::Func::c_integer($r, @$x2_values), $rows_count, $cols_count);
    
    return $x2;
  }
  else {
    Carp::croak 'Error in upper_tri() : Not implemented';
  }
}

sub lower_tri {
  my $r = shift;
  
  my ($x1_m, $x1_diag) = args_array($r, ['m', 'diag'], @_);
  
  my $diag = defined $x1_diag ? $x1_diag->value : 0;
  
  my $x2_values = [];
  if (Rstats::Func::is_matrix($r, $x1_m)) {
    my $x1_dim_values = Rstats::Func::dim($r, $x1_m)->values;
    my $rows_count = $x1_dim_values->[0];
    my $cols_count = $x1_dim_values->[1];
    
    for (my $col = 0; $col < $cols_count; $col++) {
      for (my $row = 0; $row < $rows_count; $row++) {
        my $x2_value;
        if ($diag) {
          $x2_value = $col <= $row ? 1 : 0;
        }
        else {
          $x2_value = $col < $row ? 1 : 0;
        }
        push @$x2_values, $x2_value;
      }
    }
    
    my $x2 = matrix($r, Rstats::Func::c_integer($r, @$x2_values), $rows_count, $cols_count);
    
    return $x2;
  }
  else {
    Carp::croak 'Error in lower_tri() : Not implemented';
  }
}

sub diag {
  my $r = shift;
  
  my $x1 = to_object($r, shift);
  
  my $size;
  my $x2_values;
  if (Rstats::Func::get_length($r, $x1) == 1) {
    $size = $x1->value;
    $x2_values = [];
    push @$x2_values, 1 for (1 .. $size);
  }
  else {
    $size = Rstats::Func::get_length($r, $x1);
    $x2_values = $x1->values;
  }
  
  my $x2 = matrix($r, 0, $size, $size);
  for (my $i = 0; $i < $size; $i++) {
    $x2->at($i + 1, $i + 1);
    $x2->set($x2_values->[$i]);
  }

  return $x2;
}

sub set_diag {
  my $r = shift;
  
  my $x1 = to_object($r, shift);
  my $x2 = to_object($r, shift);
  
  my $x2_elements;
  my $x1_dim_values = Rstats::Func::dim($r, $x1)->values;
  my $size = $x1_dim_values->[0] < $x1_dim_values->[1] ? $x1_dim_values->[0] : $x1_dim_values->[1];
  
  $x2 = array($r, $x2, $size);
  my $x2_values = $x2->values;
  
  for (my $i = 0; $i < $size; $i++) {
    $x1->at($i + 1, $i + 1);
    $x1->set($x2_values->[$i]);
  }
  
  return $x1;
}

sub kronecker {
  my $r = shift;
  
  my $x1 = to_object($r, shift);
  my $x2 = to_object($r, shift);
  
  ($x1, $x2) = @{Rstats::Func::upgrade_type($r, [$x1, $x2])} if $x1->get_type ne $x2->get_type;
  
  my $x1_dim = Rstats::Func::dim($r, $x1);
  my $x2_dim = Rstats::Func::dim($r, $x2);
  my $dim_max_length
    = Rstats::Func::get_length($r, $x1_dim) > Rstats::Func::get_length($r, $x2_dim) ? Rstats::Func::get_length($r, $x1_dim) : Rstats::Func::get_length($r, $x2_dim);
  
  my $x3_dim_values = [];
  my $x1_dim_values = $x1_dim->values;
  my $x2_dim_values = $x2_dim->values;
  for (my $i = 0; $i < $dim_max_length; $i++) {
    my $x1_dim_value = $x1_dim_values->[$i] || 1;
    my $x2_dim_value = $x2_dim_values->[$i] || 1;
    my $x3_dim_value = $x1_dim_value * $x2_dim_value;
    push @$x3_dim_values, $x3_dim_value;
  }
  
  my $x3_dim_product = 1;
  $x3_dim_product *= $_ for @{$x3_dim_values};
  
  my $x3_values = [];
  for (my $i = 0; $i < $x3_dim_product; $i++) {
    my $x3_index = Rstats::Util::pos_to_index($i, $x3_dim_values);
    my $x1_index = [];
    my $x2_index = [];
    for (my $k = 0; $k < @$x3_index; $k++) {
      my $x3_i = $x3_index->[$k];
      
      my $x1_dim_value = $x1_dim_values->[$k] || 1;
      my $x2_dim_value = $x2_dim_values->[$k] || 1;

      my $x1_ind = int(($x3_i - 1)/$x2_dim_value) + 1;
      push @$x1_index, $x1_ind;
      my $x2_ind = $x3_i - $x2_dim_value * ($x1_ind - 1);
      push @$x2_index, $x2_ind;
    }
    my $x1_value = $x1->value(@$x1_index);
    my $x2_value = $x2->value(@$x2_index);
    my $x3_value = multiply($r, $x1_value, $x2_value);
    push @$x3_values, $x3_value;
  }
  
  my $x3 = array($r, c($r, @$x3_values), Rstats::Func::c($r, @$x3_dim_values));
  
  return $x3;
}

sub outer {
  my $r = shift;
  
  my $x1 = to_object($r, shift);
  my $x2 = to_object($r, shift);
  
  ($x1, $x2) = @{Rstats::Func::upgrade_type($r, [$x1, $x2])} if $x1->get_type ne $x2->get_type;
  
  my $x1_dim = Rstats::Func::dim($r, $x1);
  my $x2_dim = Rstats::Func::dim($r, $x2);
  my $x3_dim = [@{$x1_dim->values}, @{$x2_dim->values}];
  
  my $indexs = [];
  for my $x3_d (@$x3_dim) {
    push @$indexs, [1 .. $x3_d];
  }
  my $poses = Rstats::Util::cross_product($indexs);
  
  my $x1_dim_length = Rstats::Func::get_length($r, $x1_dim);
  my $x3_values = [];
  for my $pos (@$poses) {
    my $pos_tmp = [@$pos];
    my $x1_pos = [splice @$pos_tmp, 0, $x1_dim_length];
    my $x2_pos = $pos_tmp;
    my $x1_value = $x1->value(@$x1_pos);
    my $x2_value = $x2->value(@$x2_pos);
    my $x3_value = $x1_value * $x2_value;
    push @$x3_values, $x3_value;
  }
  
  my $x3 = array($r, c($r, @$x3_values), Rstats::Func::c($r, @$x3_dim));
  
  return $x3;
}



sub grep {
  my $r = shift;
  
  my ($x1_pattern, $x1_x, $x1_ignore_case) = args_array($r, ['pattern', 'x', 'ignore.case'], @_);
  
  my $pattern = $x1_pattern->value;
  my $ignore_case = defined $x1_ignore_case ? $x1_ignore_case->value : 0;
  
  my $x2_values = [];
  my $x1_x_values = $x1_x->values;
  for (my $i = 0; $i < @$x1_x_values; $i++) {
    my $x = $x1_x_values->[$i];
    
    unless (!defined $x) {
      if ($ignore_case) {
        if ($x =~ /$pattern/i) {
          push @$x2_values, $i + 1;
        }
      }
      else {
        if ($x =~ /$pattern/) {
          push @$x2_values, $i + 1;
        }
      }
    }
  }
  
  return Rstats::Func::c_double($r, @$x2_values);
}

sub C {
  my $r = shift;
  my $seq_str = shift;

  my $by;
  if ($seq_str =~ s/^(.+)\*//) {
    $by = $1;
  }
  
  my $from;
  my $to;
  if ($seq_str =~ /([^\:]+)(?:\:(.+))?/) {
    $from = $1;
    $to = $2;
    $to = $from unless defined $to;
  }
  
  my $vector = seq($r,{from => $from, to => $to, by => $by});
  
  return $vector;
}

sub col {
  my $r = shift;
  my $x1 = shift;
  
  my $nrow = nrow($r, $x1)->value;
  my $ncol = ncol($r, $x1)->value;
  
  my @values;
  for my $col (1 .. $ncol) {
    push @values, ($col) x $nrow;
  }
  
  return array($r, c($r, @values), Rstats::Func::c($r, $nrow, $ncol));
}

sub nrow {
  my $r = shift;
  
  my $x1 = shift;
  
  return Rstats::Func::c($r, Rstats::Func::dim($r, $x1)->values->[0]);
}

sub is_element {
  my $r = shift;
  
  my ($x1, $x2) = (to_object($r, shift), to_object($r, shift));
  
  Carp::croak "type is diffrence" if $x1->get_type ne $x2->get_type;
  
  my $type = $x1->get_type;
  my $x1_values = $x1->values;
  my $x2_values = $x2->values;
  my $x3_values = [];
  for my $x1_value (@$x1_values) {
    my $match;
    for my $x2_value (@$x2_values) {
      if ($type eq 'double' || $type eq 'integer') {
        if ($x1_value == $x2_value) {
          $match = 1;
          last;
        }
      }
    }
    push @$x3_values, $match ? 1 : 0;
  }
  
  return Rstats::Func::c_integer($r, @$x3_values);
}

sub setequal {
  my $r = shift;
  
  my ($x1, $x2) = (to_object($r, shift), to_object($r, shift));
  
  Carp::croak "type is diffrence" if $x1->get_type ne $x2->get_type;
  
  my $x3 = Rstats::Func::sort($r, $x1);
  my $x4 = Rstats::Func::sort($r, $x2);
  
  return Rstats::Func::FALSE($r) if Rstats::Func::get_length($r, $x3) ne Rstats::Func::get_length($r, $x4);
  
  my $not_equal;
  my $x3_elements = Rstats::Func::decompose($r, $x3);
  my $x4_elements = Rstats::Func::decompose($r, $x4);
  for (my $i = 0; $i < Rstats::Func::get_length($r, $x3); $i++) {
    unless ($x3_elements->[$i] == $x4_elements->[$i]) {
      $not_equal = 1;
      last;
    }
  }
  
  return $not_equal ? Rstats::Func::FALSE($r) : TRUE($r);
}

sub setdiff {
  my $r = shift;
  
  my ($x1, $x2) = (to_object($r, shift), to_object($r, shift));
  
  Carp::croak "type is diffrence" if $x1->get_type ne $x2->get_type;
  
  my $x1_elements = Rstats::Func::decompose($r, $x1);
  my $x2_elements = Rstats::Func::decompose($r, $x2);
  my $x3_elements = [];
  for my $x1_element (@$x1_elements) {
    my $match;
    for my $x2_element (@$x2_elements) {
      if ($x1_element == $x2_element) {
        $match = 1;
        last;
      }
    }
    push @$x3_elements, $x1_element unless $match;
  }

  return Rstats::Func::c($r, @$x3_elements);
}

sub intersect {
  my $r = shift;
  
  my ($x1, $x2) = (to_object($r, shift), to_object($r, shift));
  
  Carp::croak "type is diffrence" if $x1->get_type ne $x2->get_type;
  
  my $x1_elements = Rstats::Func::decompose($r, $x1);
  my $x2_elements = Rstats::Func::decompose($r, $x2);
  my $x3_elements = [];
  for my $x1_element (@$x1_elements) {
    for my $x2_element (@$x2_elements) {
      if ($x1_element == $x2_element) {
        push @$x3_elements, $x1_element;
      }
    }
  }
  
  return Rstats::Func::c($r, @$x3_elements);
}

sub union {
  my $r = shift;
  
  my ($x1, $x2) = (to_object($r, shift), to_object($r, shift));

  Carp::croak "type is diffrence" if $x1->get_type ne $x2->get_type;
  
  my $x3 = Rstats::Func::c($r, $x1, $x2);
  my $x4 = unique($r, $x3);
  
  return $x4;
}

sub diff {
  my $r = shift;
  
  my $x1 = to_object($r, shift);
  
  my $x2_elements = [];
  my $x1_elements = Rstats::Func::decompose($r, $x1);
  for (my $i = 0; $i < Rstats::Func::get_length($r, $x1) - 1; $i++) {
    my $x1_element1 = $x1_elements->[$i];
    my $x1_element2 = $x1_elements->[$i + 1];
    my $x2_element = $x1_element2 - $x1_element1;
    push @$x2_elements, $x2_element;
  }
  my $x2 = Rstats::Func::c($r, @$x2_elements);
  Rstats::Func::copy_attrs_to($r, $x1, $x2);
  
  return $x2;
}

sub match {
  my $r = shift;
  
  my ($x1, $x2) = (to_object($r, shift), to_object($r, shift));
  
  my $x1_elements = Rstats::Func::decompose($r, $x1);
  my $x2_elements = Rstats::Func::decompose($r, $x2);
  my @matches;
  for my $x1_element (@$x1_elements) {
    my $i = 1;
    my $match;
    for my $x2_element (@$x2_elements) {
      if ($x1_element == $x2_element) {
        $match = 1;
        last;
      }
      $i++;
    }
    if ($match) {
      push @matches, $i;
    }
    else {
      push @matches, undef;
    }
  }
  
  return Rstats::Func::c_double($r, @matches);
}



sub append {
  my $r = shift;
  
  my ($x1, $x2, $x_after) = args_array($r, ['x1', 'x2', 'after'], @_);
  
  # Default
  $x_after = undef unless defined $x_after;
  
  my $x1_length = Rstats::Func::get_length($r, $x1);
  $x_after = Rstats::Func::c($r, $x1_length) unless defined $x_after;
  my $after = $x_after->value;
  
  my $x1_elements = Rstats::Func::decompose($r, $x1);
  my $x2_elements = Rstats::Func::decompose($r, $x2);
  my @x3_elements = @$x1_elements;
  splice @x3_elements, $after, 0, @$x2_elements;
  
  my $x3 = Rstats::Func::c($r, @x3_elements);
  
  return $x3;
}



sub cbind {
  my $r = shift;
  
  my @xs = @_;

  return unless @xs;
  
  my $row_count_needed;
  my $col_count_total;
  my $x2_elements = [];
  for my $_x (@xs) {
    
    my $x1 = to_object($r, $_x);
    my $x1_dim_elements = Rstats::Func::decompose($r, Rstats::Func::dim($r, $x1));
    
    my $row_count;
    if (Rstats::Func::is_matrix($r, $x1)) {
      $row_count = $x1_dim_elements->[0];
      $col_count_total += $x1_dim_elements->[1];
    }
    elsif (Rstats::Func::is_vector($r, $x1)) {
      $row_count = $x1->dim_as_array->values->[0];
      $col_count_total += 1;
    }
    else {
      Carp::croak "cbind or rbind can only receive matrix and vector";
    }
    
    $row_count_needed = $row_count unless defined $row_count_needed;
    Carp::croak "Row count is different" if $row_count_needed ne $row_count;
    
    push @$x2_elements, @{Rstats::Func::decompose($r, $x1)};
  }
  my $matrix = matrix($r, c($r, @$x2_elements), $row_count_needed, $col_count_total);
  
  return $matrix;
}

sub ceiling {
  my $r = shift;
  my $_x1 = shift;
  
  my $x1 = to_object($r, $_x1);
  my @x2_elements
    = map { Rstats::Func::c_double($r, POSIX::ceil Rstats::Func::value($r, $_)) }
    @{Rstats::Func::decompose($r, $x1)};
  
  my $x2 = Rstats::Func::c($r, @x2_elements);
  Rstats::Func::copy_attrs_to($r, $x1, $x2);
  
  return $x2;
}

sub colMeans {
  my $r = shift;
  my $x1 = shift;
  
  my $dim_values = Rstats::Func::dim($r, $x1)->values;
  if (@$dim_values == 2) {
    my $x1_values = [];
    for my $row (1 .. $dim_values->[0]) {
      my $x1_value = 0;
      $x1_value += $x1->value($row, $_) for (1 .. $dim_values->[1]);
      push @$x1_values, $x1_value / $dim_values->[1];
    }
    return Rstats::Func::c($r, @$x1_values);
  }
  else {
    Carp::croak "Can't culculate colSums";
  }
}

sub colSums {
  my $r = shift;
  my $x1 = shift;
  
  my $dim_values = Rstats::Func::dim($r, $x1)->values;
  if (@$dim_values == 2) {
    my $x1_values = [];
    for my $row (1 .. $dim_values->[0]) {
      my $x1_value = 0;
      $x1_value += $x1->value($row, $_) for (1 .. $dim_values->[1]);
      push @$x1_values, $x1_value;
    }
    return Rstats::Func::c($r, @$x1_values);
  }
  else {
    Carp::croak "Can't culculate colSums";
  }
}





sub cummax {
  my $r = shift;
  
  my $x1 = to_object($r, shift);
  
  unless (Rstats::Func::get_length($r, $x1)) {
    Carp::carp 'no non-missing arguments to max; returning -Inf';
    return -(Rstats::Func::Inf($r));
  }
  
  my @x2_elements;
  my $x1_elements = Rstats::Func::decompose($r, $x1);
  my $max = shift @$x1_elements;
  push @x2_elements, $max;
  for my $element (@$x1_elements) {
    
    if (Rstats::Func::is_nan($r, $element)) {
      $max = $element;
    }
    if ($element > $max && !Rstats::Func::is_nan($r, $max)) {
      $max = $element;
    }
    push @x2_elements, $max;
  }
  
  return Rstats::Func::c($r, @x2_elements);
}

sub cummin {
  my $r = shift;
  
  my $x1 = to_object($r, shift);
  
  unless (Rstats::Func::get_length($r, $x1)) {
    Carp::carp 'no non-missing arguments to max; returning -Inf';
    return -(Rstats::Func::Inf($r));
  }
  
  my @x2_elements;
  my $x1_elements = Rstats::Func::decompose($r, $x1);
  my $min = shift @$x1_elements;
  push @x2_elements, $min;
  for my $element (@$x1_elements) {
    if (Rstats::Func::is_nan($r, $element)) {
      $min = $element;
    }
    if ($element < $min && !Rstats::Func::is_nan($r, $min)) {
      $min = $element;
    }
    push @x2_elements, $min;
  }
  
  return Rstats::Func::c($r, @x2_elements);
}



sub args_array {
  my $r = shift;
  
  my $names = shift;
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my @args;
  for (my $i = 0; $i < @$names; $i++) {
    my $name = $names->[$i];
    my $arg;
    if (exists $opt->{$name}) {
      $arg = to_object($r, delete $opt->{$name});
    }
    elsif ($i < @_) {
      $arg = to_object($r, $_[$i]);
    }
    push @args, $arg;
  }
  
  Carp::croak "unused argument ($_)" for keys %$opt;
  
  return @args;
}

sub floor {
  my $r = shift;
  
  my $_x1 = shift;
  
  my $x1 = to_object($r, $_x1);
  
  my @x2_elements
    = map { Rstats::Func::c_double($r, POSIX::floor Rstats::Func::value($r, $_)) }
    @{Rstats::Func::decompose($r, $x1)};

  my $x2 = Rstats::Func::c($r, @x2_elements);
  Rstats::Func::copy_attrs_to($r, $x1, $x2);
  
  return $x2;
}

sub head {
  my $r = shift;
  
  my ($x1, $x_n) = args_array($r, ['x1', 'n'], @_);
  
  my $n = defined $x_n ? $x_n->value : 6;
  
  my $x1_elements = Rstats::Func::decompose($r, $x1);
  my $max = Rstats::Func::get_length($r, $x1) < $n ? Rstats::Func::get_length($r, $x1) : $n;
  my @x2_elements;
  for (my $i = 0; $i < $max; $i++) {
    push @x2_elements, $x1_elements->[$i];
  }
  
  my $x2 = Rstats::Func::c($r, @x2_elements);
  Rstats::Func::copy_attrs_to($r, $x1, $x2);

  return $x2;
}

sub ifelse {
  my $r = shift;
  
  my ($_x1, $value1, $value2) = @_;
  
  my $x1 = to_object($r, $_x1);
  my $x1_values = $x1->values;
  my @x2_values;
  for my $x1_value (@$x1_values) {
    local $_ = $x1_value;
    if ($x1_value) {
      push @x2_values, $value1;
    }
    else {
      push @x2_values, $value2;
    }
  }
  
  return Rstats::Func::array($r, c($r, @x2_values));
}



sub max {
  my $r = shift;
  
  my $x1 = Rstats::Func::c($r, @_);
  
  unless (Rstats::Func::get_length($r, $x1)) {
    Carp::carp 'no non-missing arguments to max; returning -Inf';
    return -(Rstats::Func::Inf($r));
  }
  
  my $x1_elements = Rstats::Func::decompose($r, $x1);
  my $max = shift @$x1_elements;
  for my $element (@$x1_elements) {
    
    if (Rstats::Func::is_nan($r, $element)) {
      $max = $element;
    }
    if (!Rstats::Func::is_nan($r, $max) && Rstats::Func::value($r, $r->more_than($element, $max))) {
      $max = $element;
    }
  }
  
  return Rstats::Func::c($r, $max);
}

sub mean {
  my $r = shift;
  
  my $x1 = to_object($r, shift);
  
  my $x2 = divide($r, sum($r, $x1), Rstats::Func::get_length($r, $x1));
  
  return $x2;
}

sub min {
  my $r = shift;
  
  my $x1 = Rstats::Func::c($r, @_);
  
  unless (Rstats::Func::get_length($r, $x1)) {
    Carp::carp 'no non-missing arguments to min; returning Inf';
    return Rstats::Func::Inf($r);
  }
  
  my $x1_elements = Rstats::Func::decompose($r, $x1);
  my $min = shift @$x1_elements;
  for my $element (@$x1_elements) {
    
    if (Rstats::Func::is_nan($r, $element)) {
      $min = $element;
    }
    if (!Rstats::Func::is_nan($r, $min) && Rstats::Func::value($r, $r->less_than($element, $min))) {
      $min = $element;
    }
  }
  
  return Rstats::Func::c($r, $min);
}

sub order {
  my $r = shift;
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my @xs = map { to_object($r, $_) } @_;
  
  my @xs_values;
  for my $x (@xs) {
    push @xs_values, $x->values;
  }

  my $decreasing = $opt->{decreasing} || Rstats::Func::FALSE($r);
  
  my @pos_vals;
  for my $i (0 .. @{$xs_values[0]} - 1) {
    my $pos_val = {pos => $i + 1};
    $pos_val->{val} = [];
    push @{$pos_val->{val}}, $xs_values[$_][$i] for (0 .. @xs_values);
    push @pos_vals, $pos_val;
  }
  
  my @sorted_pos_values = !$decreasing
    ? sort {
        my $comp;
        for (my $i = 0; $i < @xs_values; $i++) {
          $comp = $a->{val}[$i] <=> $b->{val}[$i];
          last if $comp != 0;
        }
        $comp;
      } @pos_vals
    : sort {
        my $comp;
        for (my $i = 0; $i < @xs_values; $i++) {
          $comp = $b->{val}[$i] <=> $a->{val}[$i];
          last if $comp != 0;
        }
        $comp;
      } @pos_vals;
  my @orders = map { $_->{pos} } @sorted_pos_values;
  
  return Rstats::Func::c($r, @orders);
}

# TODO
# na.last
sub rank {
  my $r = shift;
  
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $x1 = to_object($r, shift);
  my $decreasing = $opt->{decreasing};
  
  my $x1_values = $x1->values;
  
  my @pos_vals;
  push @pos_vals, {pos => $_ + 1, value => $x1_values->[$_]} for (0 .. @$x1_values - 1);
  my @sorted_pos_values = sort { $a->{value} <=> $b->{value} } @pos_vals;
  
  # Rank
  for (my $i = 0; $i < @sorted_pos_values; $i++) {
    $sorted_pos_values[$i]{rank} = $i + 1;
  }
  
  # Average rank
  my $element_info = {};
  for my $sorted_pos_value (@sorted_pos_values) {
    my $value = $sorted_pos_value->{value};
    $element_info->{$value} ||= {};
    $element_info->{$value}{rank_total} += $sorted_pos_value->{rank};
    $element_info->{$value}{rank_count}++;
  }
  
  for my $sorted_pos_value (@sorted_pos_values) {
    my $value = $sorted_pos_value->{value};
    $sorted_pos_value->{rank_average}
      = $element_info->{$value}{rank_total} / $element_info->{$value}{rank_count};
  }
  
  my @sorted_pos_values2 = sort { $a->{pos} <=> $b->{pos} } @sorted_pos_values;
  my @rank = map { $_->{rank_average} } @sorted_pos_values2;
  
  return Rstats::Func::c($r, @rank);
}

sub paste {
  my $r = shift;
  
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $sep = $opt->{sep};
  $sep = ' ' unless defined $sep;
  
  my $str = shift;
  my $x1 = shift;
  
  my $x1_values = $x1->values;
  my $x2_values = [];
  push @$x2_values, "$str$sep$_" for @$x1_values;
  
  return Rstats::Func::c($r, @$x2_values);
}

sub pmax {
  my $r = shift;
  
  my @vs = @_;
  
  my @maxs;
  for my $v (@vs) {
    my $elements = Rstats::Func::decompose($r, $v);
    for (my $i = 0; $i <@$elements; $i++) {
      $maxs[$i] = $elements->[$i]
        if !defined $maxs[$i] || $elements->[$i] > $maxs[$i]
    }
  }
  
  return  Rstats::Func::c($r, @maxs);
}

sub pmin {
  my $r = shift;
  
  my @vs = @_;
  
  my @mins;
  for my $v (@vs) {
    my $elements = Rstats::Func::decompose($r, $v);
    for (my $i = 0; $i <@$elements; $i++) {
      $mins[$i] = $elements->[$i]
        if !defined $mins[$i] || $elements->[$i] < $mins[$i];
    }
  }
  
  return Rstats::Func::c($r, @mins);
}



sub range {
  my $r = shift;
  
  my $x1 = shift;
  
  my $min = $r->min($x1);
  my $max = $r->max($x1);
  
  return Rstats::Func::c($r, $min, $max);
}

sub rbind {
  my $r = shift;
  my (@xs) = @_;
  
  return unless @xs;
  
  my $matrix = cbind($r, @xs);
  
  return Rstats::Func::t($r, $matrix);
}

sub rep {
  my $r = shift;
  
  my ($x1, $x_times) = args_array($r, ['x1', 'times'], @_);
  
  my $times = defined $x_times ? $x_times->value : 1;
  
  my $elements = [];
  push @$elements, @{Rstats::Func::decompose($r, $x1)} for 1 .. $times;
  my $x2 = Rstats::Func::c($r, @$elements);
  
  return $x2;
}

sub replace {
  my $r = shift;
  
  my $x1 = to_object($r, shift);
  my $x2 = to_object($r, shift);
  my $x3 = to_object($r, shift);
  
  my $x1_elements = Rstats::Func::decompose($r, $x1);
  my $x2_elements = Rstats::Func::decompose($r, $x2);
  my $x2_elements_h = {};
  for my $x2_element (@$x2_elements) {
    my $x2_element_hash = Rstats::Func::to_string($r, $x2_element);
    
    $x2_elements_h->{$x2_element_hash}++;
    Carp::croak "replace second argument can't have duplicate number"
      if $x2_elements_h->{$x2_element_hash} > 1;
  }
  my $x3_elements = Rstats::Func::decompose($r, $x3);
  my $x3_length = @{$x3_elements};
  
  my $x4_elements = [];
  my $replace_count = 0;
  for (my $i = 0; $i < @$x1_elements; $i++) {
    my $hash = Rstats::Func::to_string($r, Rstats::Func::c_double($r, $i + 1));
    if ($x2_elements_h->{$hash}) {
      push @$x4_elements, $x3_elements->[$replace_count % $x3_length];
      $replace_count++;
    }
    else {
      push @$x4_elements, $x1_elements->[$i];
    }
  }
  
  return Rstats::Func::array($r, c($r, @$x4_elements));
}

sub rev {
  my $r = shift;
  
  my $x1 = shift;
  
  # Reverse elements
  my @x2_elements = reverse @{Rstats::Func::decompose($r, $x1)};
  my $x2 = Rstats::Func::c($r, @x2_elements);
  Rstats::Func::copy_attrs_to($r, $x1, $x2);
  
  return $x2;
}

sub rnorm {
  my $r = shift;
  
  # Option
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  # Count
  my ($count, $mean, $sd) = @_;
  Carp::croak "rnorm count should be bigger than 0"
    if $count < 1;
  
  # Mean
  $mean = 0 unless defined $mean;
  
  # Standard deviation
  $sd = 1 unless defined $sd;
  
  # Random numbers(standard deviation)
  my @x1_elements;
  
  my $pi = $r->pi->value;
  for (1 .. $count) {
    my ($rand1, $rand2) = (rand, rand);
    while ($rand1 == 0) { $rand1 = rand(); }
    
    my $rnorm = ($sd * CORE::sqrt(-2 * CORE::log($rand1))
      * CORE::sin(2 * $pi * $rand2))
      + $mean;
    
    push @x1_elements, $rnorm;
  }
  
  return Rstats::Func::c($r, @x1_elements);
}

sub round {
  my $r = shift;
  
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my ($_x1, $digits) = @_;
  $digits = $opt->{digits} unless defined $digits;
  $digits = 0 unless defined $digits;
  
  my $x1 = to_object($r, $_x1);

  my $ro = 10 ** $digits;
  my @x2_elements = map { Rstats::Func::c_double($r, Math::Round::round_even(Rstats::Func::value($r, $_) * $ro) / $ro) } @{Rstats::Func::decompose($r, $x1)};
  my $x2 = Rstats::Func::c($r, @x2_elements);
  Rstats::Func::copy_attrs_to($r, $x1, $x2);
  
  return $x2;
}

sub rowMeans {
  my $r = shift;
  
  my $x1 = shift;
  
  my $dim_values = Rstats::Func::dim($r, $x1)->values;
  if (@$dim_values == 2) {
    my $x1_values = [];
    for my $col (1 .. $dim_values->[1]) {
      my $x1_value = 0;
      $x1_value += $x1->value($_, $col) for (1 .. $dim_values->[0]);
      push @$x1_values, $x1_value / $dim_values->[0];
    }
    return Rstats::Func::c($r, @$x1_values);
  }
  else {
    Carp::croak "Can't culculate rowMeans";
  }
}

sub rowSums {
  my $r = shift;
  
  my $x1 = shift;
  
  my $dim_values = Rstats::Func::dim($r, $x1)->values;
  if (@$dim_values == 2) {
    my $x1_values = [];
    for my $col (1 .. $dim_values->[1]) {
      my $x1_value = 0;
      $x1_value += $x1->value($_, $col) for (1 .. $dim_values->[0]);
      push @$x1_values, $x1_value;
    }
    return Rstats::Func::c($r, @$x1_values);
  }
  else {
    Carp::croak "Can't culculate rowSums";
  }
}

# TODO: prob option
sub sample {
  my $r = shift;
  
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  my ($_x1, $length) = @_;
  my $x1 = to_object($r, $_x1);
  
  # Replace
  my $replace = $opt->{replace};
  
  my $x1_length = Rstats::Func::get_length($r, $x1);
  $length = $x1_length unless defined $length;
  
  Carp::croak "second argument element must be bigger than first argument elements count when you specify 'replace' option"
    if $length > $x1_length && !$replace;
  
  my @x2_elements;
  my $x1_elements = Rstats::Func::decompose($r, $x1);
  for my $i (0 .. $length - 1) {
    my $rand_num = int(rand @$x1_elements);
    my $rand_element = splice @$x1_elements, $rand_num, 1;
    push @x2_elements, $rand_element;
    push @$x1_elements, $rand_element if $replace;
  }
  
  return Rstats::Func::c($r, @x2_elements);
}

sub sequence {
  my $r = shift;
  
  my $_x1 = shift;
  
  my $x1 = to_object($r, $_x1);
  my $x1_values = $x1->values;
  
  my @x2_values;
  for my $x1_value (@$x1_values) {
    push @x2_values, @{seq($r, 1, $x1_value)->values};
  }
  
  return Rstats::Func::c($r, @x2_values);
}


sub tail {
  my $r = shift;
  
  my ($x1, $x_n) = Rstats::Func::args_array($r, ['x1', 'n'], @_);
  
  my $n = defined $x_n ? $x_n->value : 6;
  
  my $e1 = Rstats::Func::decompose($r, $x1);
  my $max = Rstats::Func::get_length($r, $x1) < $n ? Rstats::Func::get_length($r, $x1) : $n;
  my @e2;
  for (my $i = 0; $i < $max; $i++) {
    unshift @e2, $e1->[Rstats::Func::get_length($r, $x1) - ($i  + 1)];
  }
  
  my $x2 = Rstats::Func::c($r, @e2);
  Rstats::Func::copy_attrs_to($r, $x1, $x2);
  
  return $x2;
}

sub trunc {
  my $r = shift;
  
  my ($_x1) = @_;
  
  my $x1 = to_object($r, $_x1);
  
  my @x2_elements
    = map { Rstats::Func::c_double($r, int Rstats::Func::value($r, $_)) } @{Rstats::Func::decompose($r, $x1)};

  my $x2 = Rstats::Func::c($r, @x2_elements);
  Rstats::Func::copy_attrs_to($r, $x1, $x2);
  
  return $x2;
}

sub unique {
  my $r = shift;
  
  my $x1 = to_object($r, shift);
  
  if (Rstats::Func::is_vector($r, $x1)) {
    my $x2_elements = [];
    my $elements_count = {};
    my $na_count;
    for my $x1_element (@{Rstats::Func::decompose($r, $x1)}) {
      my $str = Rstats::Func::to_string($r, $x1_element);
      unless ($elements_count->{$str}) {
        push @$x2_elements, $x1_element;
      }
      $elements_count->{$str}++;
    }

    return Rstats::Func::c($r, @$x2_elements);
  }
  else {
    return $x1;
  }
}

sub median {
  my $r = shift;
  
  my $x1 = to_object($r, shift);
  
  my $x2 = unique($r, $x1);
  my $x3 = Rstats::Func::sort($r, $x2);
  my $x3_length = Rstats::Func::get_length($r, $x3);
  
  if ($x3_length % 2 == 0) {
    my $middle = $x3_length / 2;
    my $x4 = $x3->get($middle);
    my $x5 = $x3->get($middle + 1);
    
    return $r->divide(($x4 + $x5), 2);
  }
  else {
    my $middle = int($x3_length / 2) + 1;
    return $x3->get($middle);
  }
}

sub quantile {
  my $r = shift;
  
  my $x1 = to_object($r, shift);
  
  my $x2 = Rstats::Func::unique($r, $x1);
  my $x3 = Rstats::Func::sort($r, $x2);
  my $x3_length = Rstats::Func::get_length($r, $x3);
  
  my $quantile_elements = [];
  
  # Min
  push @$quantile_elements , $x3->get(1);
  
  # 1st quoter
  if ($x3_length % 4 == 0) {
    my $first_quoter = $x3_length * (1 / 4);
    my $x4 = $x3->get($first_quoter);
    my $x5 = $x3->get($first_quoter + 1);
    
    push @$quantile_elements, ((($x4 + $x5) / 2) + $x5) / 2;
  }
  else {
    my $first_quoter = int($x3_length * (1 / 4)) + 1;
    push @$quantile_elements, $x3->get($first_quoter);
  }
  
  # middle
  if ($x3_length % 2 == 0) {
    my $middle = $x3_length / 2;
    my $x4 = $x3->get($middle);
    my $x5 = $x3->get($middle + 1);
    
    push @$quantile_elements, (($x4 + $x5) / 2);
  }
  else {
    my $middle = int($x3_length / 2) + 1;
    push @$quantile_elements, $x3->get($middle);
  }
  
  # 3rd quoter
  if ($x3_length % 4 == 0) {
    my $third_quoter = $x3_length * (3 / 4);
    my $x4 = $x3->get($third_quoter);
    my $x5 = $x3->get($third_quoter + 1);
    
    push @$quantile_elements, (($x4 + (($x4 + $x5) / 2)) / 2);
  }
  else {
    my $third_quoter = int($x3_length * (3 / 4)) + 1;
    push @$quantile_elements, $x3->get($third_quoter);
  }
  
  # Max
  push @$quantile_elements , $x3->get($x3_length);
  
  my $x4 = Rstats::Func::c($r, @$quantile_elements);
  
  return $x4;
}

sub sd {
  my $r = shift;
  
  my $x1 = to_object($r, shift);
  
  my $sd = Rstats::Func::sqrt($r, var($r, $x1));
  
  return $sd;
}

=pod
sub var {
  my $r = shift;
  
  my $x1 = to_object($r, shift);
  
  my $x1_length = Rstats::Func::get_length($r, $x1);
  
  my $mean = Rstats::Func::mean($r, $x1);
  
  my $mean_length = Rstats::Func::get_length($r, $mean);
  
  my $var = sum($r, ($x1 - $mean) ** 2) / ($x1_length - 1);
  
  return $var;
}
=cut

sub which {
  my $r = shift;
  
  my ($_x1, $cond_cb) = @_;
  
  my $x1 = to_object($r, $_x1);
  my $x1_values = $x1->values;
  my @x2_values;
  for (my $i = 0; $i < @$x1_values; $i++) {
    local $_ = $x1_values->[$i];
    if ($cond_cb->($x1_values->[$i])) {
      push @x2_values, $i + 1;
    }
  }
  
  return Rstats::Func::c($r, @x2_values);
}

sub inner_product {
  my $r = shift;
  
  my ($x1, $x2) = @_;
  
  # Convert to matrix
  $x1 = Rstats::Func::t($r, Rstats::Func::as_matrix($r, $x1))
    if Rstats::Func::is_vector($r, $x1);
  $x2 = Rstats::Func::as_matrix($r, $x2) if Rstats::Func::is_vector($r, $x2);
  
  # Calculate
  if (Rstats::Func::is_matrix($r, $x1) && Rstats::Func::is_matrix($r, $x2)) {
    
    Carp::croak "requires numeric matrix/vector arguments"
      if Rstats::Func::get_length($r, $x1) == 0 || Rstats::Func::get_length($r, $x2) == 0;
    Carp::croak "Error in a x b : non-conformable arguments"
      unless Rstats::Func::dim($r, $x1)->values->[1] == Rstats::Func::dim($r, $x2)->values->[0];
    
    my $row_max = Rstats::Func::dim($r, $x1)->values->[0];
    my $col_max = Rstats::Func::dim($r, $x2)->values->[1];
    
    my $x3_elements = [];
    for (my $col = 1; $col <= $col_max; $col++) {
      for (my $row = 1; $row <= $row_max; $row++) {
        my $x1_part = Rstats::Func::get($r, $x1, $row);
        my $x2_part = Rstats::Func::get($r, $x2, undef, $col);
        my $x3_part = sum($r, $r->multiply($x1, $x2));
        push @$x3_elements, $x3_part;
      }
    }
    
    my $x3 = Rstats::Func::matrix($r, c($r, @$x3_elements), $row_max, $col_max);
    
    return $x3;
  }
  else {
    Carp::croak "inner_product should be dim < 3."
  }
}

sub row {
  my $r = shift;
  
  my $x1 = shift;
  
  my $nrow = Rstats::Func::nrow($r, $x1)->value;
  my $ncol = Rstats::Func::ncol($r, $x1)->value;
  
  my @values = (1 .. $nrow) x $ncol;
  
  return Rstats::Func::array($r, Rstats::Func::c($r, @values), Rstats::Func::c($r, $nrow, $ncol));
}



sub ncol {
  my $r = shift;
  
  my $x1 = shift;
  
  return Rstats::Func::c($r, Rstats::Func::dim($r, $x1)->values->[1]);
}

sub seq {
  my $r = shift;
  
  # Option
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  # Along
  my $_along = $opt->{along};
  if (defined $_along) {
    my $along = to_object($r, $_along);
    my $length = Rstats::Func::get_length($r, $along);
    return seq($r, 1, $length);
  }
  else {
    my ($from, $to) = @_;
    
    # From
    $from = $opt->{from} unless defined $from;
    Carp::croak "seq function need from option" unless defined $from;
    
    # To
    $to = $opt->{to} unless defined $to;
    Carp::croak "seq function need to option" unless defined $to;

    # Length
    my $length = $opt->{length};
    
    # By
    my $by = $opt->{by};
    
    if (defined $length && defined $by) {
      Carp::croak "Can't use by option and length option as same time";
    }
    
    unless (defined $by) {
      if ($to >= $from) {
        $by = 1;
      }
      else {
        $by = -1;
      }
    }
    Carp::croak "by option should be except for 0" if $by == 0;
    
    $to = $from unless defined $to;
    
    if (defined $length && $from ne $to) {
      $by = ($to - $from) / ($length - 1);
    }
    
    my $elements = [];
    if ($to == $from) {
      $elements->[0] = $to;
    }
    elsif ($to > $from) {
      if ($by < 0) {
        Carp::croak "by option is invalid number(seq function)";
      }
      
      my $element = $from;
      while ($element <= $to) {
        push @$elements, $element;
        $element += $by;
      }
    }
    else {
      if ($by > 0) {
        Carp::croak "by option is invalid number(seq function)";
      }
      
      my $element = $from;
      while ($element >= $to) {
        push @$elements, $element;
        $element += $by;
      }
    }
    
    return Rstats::Func::c($r, @$elements);
  }
}

sub numeric {
  my $r = shift;
  
  my $num = shift;
  
  return Rstats::Func::c($r, (0) x $num);
}

sub _fix_pos {
  my $r = shift;
  
  my ($data1, $datx2, $reverse) = @_;
  
  my $x1;
  my $x2;
  if (ref $datx2) {
    $x1 = $data1;
    $x2 = $datx2;
  }
  else {
    if ($reverse) {
      $x1 = Rstats::Func::c($r, $datx2);
      $x2 = $data1;
    }
    else {
      $x1 = $data1;
      $x2 = Rstats::Func::c($r, $datx2);
    }
  }
  
  return ($x1, $x2);
}

sub bool {
  my $r = shift;
  
  my $x1 = shift;
  
  my $length = Rstats::Func::get_length($r, $x1);
  if ($length == 0) {
    Carp::croak 'Error in if (a) { : argument is of length zero';
  }
  elsif ($length > 1) {
    Carp::carp 'In if (a) { : the condition has length > 1 and only the first element will be used';
  }
  
  my $type = $x1->get_type;
  my $value = $x1->value;

  my $is;
  if ($type eq 'double') {
    if ($value eq 'Inf' || $value eq '-Inf') {
      $is = 1;
    }
    elsif ($value eq 'NaN') {
      Carp::croak 'argument is not interpretable in bool context';
    }
    else {
      $is = $value;
    }
  }
  elsif ($type eq 'integer') {
    $is = $value;
  }
  else {
    Carp::croak "Invalid type";
  }
  
  if (!defined $value) {
    Carp::croak "Error in bool context (a) { : missing value where TRUE/FALSE needed"
  }

  return $is;
}

sub set {
  my ($r, $x1) = @_;
  
  return Rstats::Func::set_array(@_);
}



sub get_array {
  my $r = shift;
  
  my $x1 = shift;
  
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $dim_drop;
  $dim_drop = $opt->{drop};
  
  $dim_drop = 1 unless defined $dim_drop;
  
  my @_indexs = @_;

  my $_indexs;
  if (@_indexs) {
    $_indexs = \@_indexs;
  }
  else {
    my $at = $x1->at;
    $_indexs = ref $at eq 'ARRAY' ? $at : [$at];
  }
  $x1->at($_indexs);
  
  my ($poss, $x2_dim, $new_indexes) = @{Rstats::Util::parse_index($r, $x1, $dim_drop, $_indexs)};
  
  my $x1_values = $x1->values;
  my @x2_values = map { $x1_values->[$_] } @$poss;
  
  # array
  my $x_matrix;
  if ($x1->get_type eq "double") {
    $x_matrix = c_double($r, \@x2_values);
  }
  elsif ($x1->get_type eq "integer") {
    $x_matrix = c_integer($r, \@x2_values);
  }
  else {
    croak("Invalid type " . $x1->get_type . " is passed");
  }
  
  my $x2 = Rstats::Func::array(
    $r,
    $x_matrix,
    Rstats::Func::c($r, @$x2_dim)
  );
  
  # Copy attributes
  Rstats::Func::copy_attrs_to($r, $x1, $x2, {new_indexes => $new_indexes, exclude => ['dim']});

  return $x2;
}

sub getin_array { get(@_) }

sub to_string_array {
  my $r = shift;
  
  my $x1 = shift;

  my $values = $x1->values;
  my $type = $x1->get_type;
  
  my $dim_values = $x1->dim_as_array->values;
  
  my $dim_length = @$dim_values;
  my $dim_num = $dim_length - 1;
  my $poss = [];
  
  my $str;
  if (@$values) {
    if ($dim_length == 1) {
      my @parts = map { Rstats::Func::_value_to_string($r, $x1, $_, $type) } @$values;
      $str .= '[1] ' . join(' ', @parts) . "\n";
    }
    elsif ($dim_length == 2) {
      $str .= '     ';
      
      for my $d2 (1 .. $dim_values->[1]) {
        $str .= $d2 == $dim_values->[1] ? "[,$d2]\n" : "[,$d2] ";
      }
      
      for my $d1 (1 .. $dim_values->[0]) {
        $str .= "[$d1,] ";
        
        my @parts;
        for my $d2 (1 .. $dim_values->[1]) {
          my $part = $x1->value($d1, $d2);
          push @parts, Rstats::Func::_value_to_string($r, $x1, $part, $type);
        }
        
        $str .= join(' ', @parts) . "\n";
      }
    }
    else {
      my $code;
      $code = sub {
        my (@dim_values) = @_;
        my $dim_value = pop @dim_values;
        
        for (my $i = 1; $i <= $dim_value; $i++) {
          $str .= (',' x $dim_num) . "$i" . "\n";
          unshift @$poss, $i;
          if (@dim_values > 2) {
            $dim_num--;
            $code->(@dim_values);
            $dim_num++;
          }
          else {
            $str .= '     ';
            
            for my $d2 (1 .. $dim_values[1]) {
              $str .= $d2 == $dim_values[1] ? "[,$d2]\n" : "[,$d2] ";
            }

            for my $d1 (1 .. $dim_values[0]) {
              $str .= "[$d1,] ";
              
              my @parts;
              for my $d2 (1 .. $dim_values[1]) {
                my $part = $x1->value($d1, $d2, @$poss);
                push @parts, Rstats::Func::_value_to_string($r, $x1, $part, $type);
              }
              
              $str .= join(' ', @parts) . "\n";
            }
          }
          shift @$poss;
        }
      };
      $code->(@$dim_values);
    }
  }
  
  return $str;
}

sub _value_to_string {
  my $r = shift;
  
  my ($x1, $value, $type) = @_;
  
  my $string = "$value";
  
  return $string;
}

sub str {
  my $r = shift;
  
  my $x1 = shift;
  
  my @str;
  
  if (Rstats::Func::is_vector($r, $x1) || is_array($r, $x1)) {
    # Short type
    my $type = $x1->get_type;
    my $short_type;
    if ($type eq 'double') {
      $short_type = 'num';
    }
    elsif ($type eq 'integer') {
      $short_type = 'int';
    }
    else {
      $short_type = 'Unkonown';
    }
    push @str, $short_type;
    
    # Dimention
    my @dim_str;
    my $length = Rstats::Func::get_length($r, $x1);
    if (exists $x1->{dim}) {
      my $dim_values = $x1->{dim}->values;
      for (my $i = 0; $i < $x1->{dim}->get_length; $i++) {
        my $d = $dim_values->[$i];
        my $d_str;
        if ($d == 1) {
          $d_str = "1";
        }
        else {
          $d_str = "1:$d";
        }
        
        if ($x1->{dim}->get_length == 1) {
          $d_str .= "(" . ($i + 1) . "d)";
        }
        push @dim_str, $d_str;
      }
    }
    else {
      if ($length != 1) {
        push @dim_str, "1:$length";
      }
    }
    if (@dim_str) {
      my $dim_str = join(', ', @dim_str);
      push @str, "[$dim_str]";
    }
    
    # Vector
    my @element_str;
    my $max_count = $length > 10 ? 10 : $length;
    my $values = $x1->values;
    for (my $i = 0; $i < $max_count; $i++) {
      push @element_str, Rstats::Func::_value_to_string($r, $x1, $values->[$i], $type);
    }
    if ($length > 10) {
      push @element_str, '...';
    }
    my $element_str = join(' ', @element_str);
    push @str, $element_str;
  }
  
  my $str = join(' ', @str);
  
  return $str;
}

sub at {
  my $r = shift;
  
  my $x1 = shift;
  
  if (@_) {
    $x1->{at} = [@_];
    
    return $x1;
  }
  
  return $x1->{at};
}

sub _name_to_index {
  my $r = shift;
  my $x1 = shift;
  my $x1_index = Rstats::Func::to_object($r, shift);
  
  my $e1_name = $x1_index->value;
  my $found;
  my $names = Rstats::Func::names($r, $x1)->values;
  my $index;
  for (my $i = 0; $i < @$names; $i++) {
    my $name = $names->[$i];
    if ($e1_name eq $name) {
      $index = $i + 1;
      $found = 1;
      last;
    }
  }
  croak "Not found $e1_name" unless $found;
  
  return $index;
}

sub sweep {
  my $r = shift;
  
  my ($x1, $x_margin, $x2, $x_func)
    = Rstats::Func::args_array($r, ['x1', 'margin', 'x2', 'FUN'], @_);
  
  my $x_margin_values = $x_margin->values;
  my $func = defined $x_func ? $x_func->value : '-';
  
  my $x2_dim_values = Rstats::Func::dim($r, $x2)->values;
  my $x1_dim_values = Rstats::Func::dim($r, $x1)->values;
  
  my $x1_length = Rstats::Func::get_length($r, $x1);
  
  my $x_result_elements = [];
  for (my $x1_pos = 0; $x1_pos < $x1_length; $x1_pos++) {
    my $x1_index = Rstats::Util::pos_to_index($x1_pos, $x1_dim_values);
    
    my $new_index = [];
    for my $x_margin_value (@$x_margin_values) {
      push @$new_index, $x1_index->[$x_margin_value - 1];
    }
    
    my $e1 = $x2->value(@{$new_index});
    push @$x_result_elements, $e1;
  }
  my $x3 = Rstats::Func::c($r, @$x_result_elements);
  
  my $x4;
  if ($func eq '+') {
    $x4 = $x1 + $x3;
  }
  elsif ($func eq '-') {
    $x4 = $x1 - $x3;
  }
  elsif ($func eq '*') {
    $x4 = $x1 * $x3;
  }
  elsif ($func eq '/') {
    $x4 = $x1 / $x3;
  }
  elsif ($func eq '**') {
    $x4 = $x1 ** $x3;
  }
  elsif ($func eq '%') {
    $x4 = $x1 % $x3;
  }
  
  Rstats::Func::copy_attrs_to($r, $x1, $x4);
  
  return $x4;
}

sub set_seed {
  my ($r, $seed) = @_;
  
  $r->{seed} = $seed;
}

sub runif {
  my $r = shift;

  my ($x_count, $x_min, $x_max)
    =  Rstats::Func::args_array($r, ['count', 'min', 'max'], @_);
  
  my $count = $x_count->value;
  my $min = defined $x_min ? $x_min->value : 0;
  my $max = defined $x_max ? $x_max->value : 1;
  Carp::croak "runif third argument must be bigger than second argument"
    if $min > $max;
  
  my $diff = $max - $min;
  my @x1_elements;
  if (defined $r->{seed}) {
    srand $r->{seed};
  }
  
  for (1 .. $count) {
    my $rand = rand($diff) + $min;
    push @x1_elements, $rand;
  }
  
  $r->{seed} = undef;
  
  return Rstats::Func::c($r, @x1_elements);
}

sub to_string {
  my ($r, $x1) = @_;
  
  return Rstats::Func::to_string_array(@_);
}

sub get {
  my ($r, $x1) = @_;
  
  return Rstats::Func::get_array(@_);
}

sub getin {
  my ($r, $x1) = @_;
  
  return Rstats::Func::getin_array(@_);
}

sub set_array {
  my $r = shift;
  
  my $x1 = shift;
  my $x2 = Rstats::Func::to_object($r, shift);
  
  my $at = $x1->at;
  my $_indexs = ref $at eq 'ARRAY' ? $at : [$at];
  my ($poss, $x2_dim) = @{Rstats::Util::parse_index($r, $x1, 0, $_indexs)};
  
  my $type;
  my $x1_elements;
  # Upgrade type if type is different
  if ($x1->get_type ne $x2->get_type) {
    my $x1_tmp;
    ($x1_tmp, $x2) = @{Rstats::Func::upgrade_type($r, [$x1, $x2])};
    Rstats::Func::copy_attrs_to($r, $x1_tmp, $x1);
    $x1->vector($x1_tmp->vector);
    
    $type = $x1_tmp->get_type;
  }
  else {
    $type = $x1->get_type;
  }

  $x1_elements = Rstats::Func::decompose($r, $x1);

  my $x2_elements = Rstats::Func::decompose($r, $x2);
  for (my $i = 0; $i < @$poss; $i++) {
    my $pos = $poss->[$i];
    $x1_elements->[$pos] = $x2_elements->[(($i + 1) % @$poss) - 1];
  }
  
  my $x1_tmp = Rstats::Func::compose($r, $type, $x1_elements);
  $x1->vector($x1_tmp->vector);
  $x1->{type} = $x1_tmp->{type};
  
  return $x1;
}

sub sort {
  my $r = shift;
  
  my ($x1, $x_decreasing) = Rstats::Func::args_array($r, ['x1', 'decreasing', 'na.last'], @_);
  
  my $decreasing = defined $x_decreasing ? $x_decreasing->value : 0;
  
  my @x2_elements = grep { !Rstats::Func::is_nan($r, $_) } @{Rstats::Func::decompose($r, $x1)};
  
  my $x3_elements = $decreasing
    ? [reverse sort { ($a > $b) ? 1 : ($a == $b) ? 0 : -1 } @x2_elements]
    : [sort { ($a > $b) ? 1 : ($a == $b) ? 0 : -1 } @x2_elements];

  return Rstats::Func::c($r, @$x3_elements);
}

sub value {
  my $r = shift;
  my $x1 = shift;
  
  my $e1;
  my $dim_values = Rstats::Func::values($r, $x1->dim_as_array);
  my $x1_elements = Rstats::Func::decompose($r, $x1);
  if (@_) {
    if (@$dim_values == 1) {
      $e1 = $x1_elements->[$_[0] - 1];
    }
    elsif (@$dim_values == 2) {
      $e1 = $x1_elements->[($_[0] + $dim_values->[0] * ($_[1] - 1)) - 1];
    }
    else {
      $e1 = Rstats::Func::decompose($r, $x1->get(@_))->[0];
    }
    
  }
  else {
    $e1 = $x1_elements->[0];
  }
  
  return defined $e1 ? Rstats::Func::first_value($r, $e1) : undef;
}

1;

=head1 NAME

Rstats::Func - Functions

