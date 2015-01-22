package Rstats::ArrayFunc;

use strict;
use warnings;
use Carp 'croak', 'carp';

use Rstats::Func;
use Rstats::Util;
use Rstats::VectorFunc;
use POSIX ();

sub NULL {
  
  my $x1 = Rstats::Array->new;
  $x1->vector(Rstats::Vector->new_null);
  
  return $x1;
}

my $na;
sub NA  () { defined $na ? $na : $na = Rstats::Func::new_logical(undef) }
sub NaN () { Rstats::Func::new_double('NaN') }
sub Inf () { Rstats::Func::new_double('Inf') }

my $false;
sub FALSE () { defined $false ? $false : $false = Rstats::Func::new_logical(0) }
sub F () { FALSE }

my $true;
sub TRUE () { defined $true ? $true : $true = Rstats::Func::new_logical(1) }
sub T () { TRUE }
sub pi () { new_double(Rstats::Util::pi()); }

sub asin { operate_unary_old(\&Rstats::VectorFunc::asin, @_) }
sub asinh { operate_unary_old(\&Rstats::VectorFunc::asinh, @_) }
sub atan { operate_unary_old(\&Rstats::VectorFunc::atan, @_) }
sub atanh { operate_unary_old(\&Rstats::VectorFunc::atanh, @_) }

sub cbind {
  my @xs = @_;

  return Rstats::Func::NULL() unless @xs;
  
  if ($xs[0]->is_data_frame) {
    # Check row count
    my $first_row_length;
    my $different;
    for my $x (@xs) {
      if ($first_row_length) {
        $different = 1 if $x->{row_length} != $first_row_length;
      }
      else {
        $first_row_length = $x->{row_length};
      }
    }
    croak "cbind need same row count data frame"
      if $different;
    
    # Create new data frame
    my @data_frame_args;
    for my $x (@xs) {
      my $names = $x->names->values;
      for my $name (@$names) {
        push @data_frame_args, $name, $x->getin($name);
      }
    }
    my $data_frame = Rstats::Func::data_frame(@data_frame_args);
    
    return $data_frame;
  }
  else {
    my $row_count_needed;
    my $col_count_total;
    my $x2_elements = [];
    for my $_x (@xs) {
      
      my $a1 = to_c($_x);
      my $a1_dim_elements = $a1->dim->decompose;
      
      my $row_count;
      if ($a1->is_matrix) {
        $row_count = $a1_dim_elements->[0];
        $col_count_total += $a1_dim_elements->[1];
      }
      elsif ($a1->is_vector) {
        $row_count = $a1->dim_as_array->values->[0];
        $col_count_total += 1;
      }
      else {
        croak "cbind or rbind can only receive matrix and vector";
      }
      
      $row_count_needed = $row_count unless defined $row_count_needed;
      croak "Row count is different" if $row_count_needed ne $row_count;
      
      push @$x2_elements, @{$a1->decompose};
    }
    my $matrix = matrix(c(@$x2_elements), $row_count_needed, $col_count_total);
    
    return $matrix;
  }
}

sub ceiling {
  my $_x1 = shift;
  
  my $x1 = to_c($_x1);
  my @a2_elements = map { Rstats::VectorFunc::new_double(POSIX::ceil $_->value) } @{$x1->decompose};
  
  my $x2 = Rstats::ArrayFunc::c(@a2_elements);
  $x1->copy_attrs_to($x2);
  
  $x2->mode('double');
  
  return $x2;
}

sub colMeans {
  my $x1 = shift;
  
  my $dim_values = $x1->dim->values;
  if (@$dim_values == 2) {
    my $x1_values = [];
    for my $row (1 .. $dim_values->[0]) {
      my $x1_value = 0;
      $x1_value += $x1->value($row, $_) for (1 .. $dim_values->[1]);
      push @$x1_values, $x1_value / $dim_values->[1];
    }
    return Rstats::ArrayFunc::c(@$x1_values);
  }
  else {
    croak "Can't culculate colSums";
  }
}

sub colSums {
  my $x1 = shift;
  
  my $dim_values = $x1->dim->values;
  if (@$dim_values == 2) {
    my $x1_values = [];
    for my $row (1 .. $dim_values->[0]) {
      my $x1_value = 0;
      $x1_value += $x1->value($row, $_) for (1 .. $dim_values->[1]);
      push @$x1_values, $x1_value;
    }
    return Rstats::ArrayFunc::c(@$x1_values);
  }
  else {
    croak "Can't culculate colSums";
  }
}

sub cos { operate_unary(\&Rstats::VectorFunc::cos, @_) }

sub atan2 { operate_binary(\&Rstats::VectorFunc::atan2, @_) }

sub cosh { operate_unary(\&Rstats::VectorFunc::cosh, @_) }

sub cummax {
  my $x1 = to_c(shift);
  
  unless ($x1->length_value) {
    carp 'no non-missing arguments to max; returning -Inf';
    return -(Rstats::Func::Inf());
  }
  
  my @a2_elements;
  my $x1_elements = $x1->decompose;
  my $max = shift @$x1_elements;
  push @a2_elements, $max;
  for my $element (@$x1_elements) {
    
    if ($element->is_na->value) {
      return Rstats::Func::NA();
    }
    elsif ($element->is_nan->value) {
      $max = $element;
    }
    if (Rstats::VectorFunc::more_than($element, $max)->value && !$max->is_nan->value) {
      $max = $element;
    }
    push @a2_elements, $max;
  }
  
  return Rstats::ArrayFunc::c(@a2_elements);
}

sub cummin {
  my $x1 = to_c(shift);
  
  unless ($x1->length_value) {
    carp 'no non-missing arguments to max; returning -Inf';
    return -(Rstats::Func::Inf());
  }
  
  my @a2_elements;
  my $x1_elements = $x1->decompose;
  my $min = shift @$x1_elements;
  push @a2_elements, $min;
  for my $element (@$x1_elements) {
    if ($element->is_na->value) {
      return Rstats::Func::NA();
    }
    elsif ($element->is_nan->value) {
      $min = $element;
    }
    if (Rstats::VectorFunc::less_than($element, $min)->value && !$min->is_nan->value) {
      $min = $element;
    }
    push @a2_elements, $min;
  }
  
  return Rstats::ArrayFunc::c(@a2_elements);
}

sub cumsum { operate_unary(\&Rstats::VectorFunc::cumsum, @_) }

sub cumprod { operate_unary(\&Rstats::VectorFunc::cumprod, @_) }

sub args_array {
  my $names = shift;
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my @args;
  for (my $i = 0; $i < @$names; $i++) {
    my $name = $names->[$i];
    my $arg;
    if (exists $opt->{$name}) {
      $arg = to_c(delete $opt->{$name});
    }
    elsif ($i < @_) {
      $arg = to_c($_[$i]);
    }
    push @args, $arg;
  }
  
  croak "unused argument ($_)" for keys %$opt;
  
  return @args;
}

sub complex {
  my ($x1_re, $x1_im, $x1_mod, $x1_arg) = args_array(['re', 'im', 'mod', 'arg'], @_);
  
  $x1_mod = Rstats::Func::NULL() unless defined $x1_mod;
  $x1_arg = Rstats::Func::NULL() unless defined $x1_arg;

  my $x2_elements = [];
  # Create complex from mod and arg
  if ($x1_mod->length_value || $x1_arg->length_value) {
    my $x1_mod_length = $x1_mod->length_value;
    my $x1_arg_length = $x1_arg->length_value;
    my $longer_length = $x1_mod_length > $x1_arg_length ? $x1_mod_length : $x1_arg_length;
    
    my $x1_mod_elements = $x1_mod->decompose;
    my $x1_arg_elements = $x1_arg->decompose;
    for (my $i = 0; $i < $longer_length; $i++) {
      my $mod = $x1_mod_elements->[$i];
      $mod = Rstats::VectorFunc::new_double(1) unless $mod;
      my $arg = $x1_arg_elements->[$i];
      $arg = Rstats::VectorFunc::new_double(0) unless $arg;
      
      my $re = Rstats::VectorFunc::multiply(
        $mod,
        Rstats::VectorFunc::cos($arg)
      );
      my $im = Rstats::VectorFunc::multiply(
        $mod,
        Rstats::VectorFunc::sin($arg)
      );
      
      my $x2_element = Rstats::VectorFunc::complex_double($re, $im);
      push @$x2_elements, $x2_element;
    }
  }
  # Create complex from re and im
  else {
    croak "mode should be numeric" unless $x1_re->is_numeric && $x1_im->is_numeric;
    
    my $x1_re_elements = $x1_re->decompose;
    my $x1_im_elements = $x1_im->decompose;
    for (my $i = 0; $i <  $x1_im->length_value; $i++) {
      my $re = $x1_re_elements->[$i] || Rstats::VectorFunc::new_double(0);
      my $im = $x1_im_elements->[$i];
      my $x2_element = Rstats::VectorFunc::complex_double($re, $im);
      push @$x2_elements, $x2_element;
    }
  }
  
  return Rstats::ArrayFunc::c(@$x2_elements);
}

sub exp { operate_unary(\&Rstats::VectorFunc::exp, @_) }

sub expm1 { operate_unary(\&Rstats::VectorFunc::expm1, @_) }

sub max_type {
  my @xs = @_;
  
  my $type_h = {};
  
  for my $x (@xs) {
    my $x_type = $x->typeof->value;
    $type_h->{$x_type}++;
    unless ($x->is_null) {
      my $type = $x->type;
      $type_h->{$type}++;
    }
  }
  
  if ($type_h->{character}) {
    return 'character';
  }
  elsif ($type_h->{complex}) {
    return 'complex';
  }
  elsif ($type_h->{double}) {
    return 'double';
  }
  elsif ($type_h->{integer}) {
    return 'integer';
  }
  else {
    return 'logical';
  }
}

sub floor {
  my $_x1 = shift;
  
  my $x1 = to_c($_x1);
  
  my @a2_elements = map { Rstats::VectorFunc::new_double(POSIX::floor $_->value) } @{$x1->decompose};

  my $x2 = Rstats::ArrayFunc::c(@a2_elements);
  $x1->copy_attrs_to($x2);
  $x2->mode('double');
  
  return $x2;
}

sub head {
  my ($x1, $x_n) = args_array(['x1', 'n'], @_);
  
  my $n = defined $x_n ? $x_n->value : 6;
  
  if ($x1->is_data_frame) {
    my $max = $x1->{row_length} < $n ? $x1->{row_length} : $n;
    
    my $x_range = Rstats::Func::se("1:$max");
    my $x2 = $x1->get($x_range, Rstats::Func::NULL());
    
    return $x2;
  }
  else {
    my $x1_elements = $x1->decompose;
    my $max = $x1->length_value < $n ? $x1->length_value : $n;
    my @x2_elements;
    for (my $i = 0; $i < $max; $i++) {
      push @x2_elements, $x1_elements->[$i];
    }
    
    my $x2 = Rstats::ArrayFunc::c(@x2_elements);
    $x1->copy_attrs_to($x2);
  
    return $x2;
  }
}

sub i {
  my $i = Rstats::VectorFunc::new_complex({re => 0, im => 1});
  
  return Rstats::ArrayFunc::c($i);
}

sub ifelse {
  my ($_x1, $value1, $value2) = @_;
  
  my $x1 = to_c($_x1);
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
  
  return Rstats::Func::array(c(@x2_values));
}

sub log { operate_unary(\&Rstats::VectorFunc::log, @_) }
sub logb { operate_unary(\&Rstats::VectorFunc::logb, @_) }
sub log2 { operate_unary(\&Rstats::VectorFunc::log2, @_) }
sub log10 { operate_unary(\&Rstats::VectorFunc::log10, @_) }

sub max {
  my $x1 = Rstats::ArrayFunc::c(@_);
  
  unless ($x1->length_value) {
    carp 'no non-missing arguments to max; returning -Inf';
    return -(Rstats::Func::Inf());
  }
  
  my $x1_elements = $x1->decompose;
  my $max = shift @$x1_elements;
  for my $element (@$x1_elements) {
    
    if ($element->is_na->value) {
      return Rstats::Func::NA();
    }
    elsif ($element->is_nan->value) {
      $max = $element;
    }
    if (!$max->is_nan->value && Rstats::VectorFunc::more_than($element, $max)->value) {
      $max = $element;
    }
  }
  
  return Rstats::ArrayFunc::c($max);
}

sub mean {
  my $x1 = to_c(shift);
  
  my $x2 = divide(sum($x1), $x1->length_value);
  
  return $x2;
}

sub min {
  my $x1 = Rstats::ArrayFunc::c(@_);
  
  unless ($x1->length_value) {
    carp 'no non-missing arguments to min; returning -Inf';
    return Rstats::Func::Inf();
  }
  
  my $x1_elements = $x1->decompose;
  my $min = shift @$x1_elements;
  for my $element (@$x1_elements) {
    
    if ($element->is_na->value) {
      return Rstats::Func::NA();
    }
    elsif ($element->is_nan->value) {
      $min = $element;
    }
    if (!$min->is_nan->value && Rstats::VectorFunc::less_than($element, $min)->value) {
      $min = $element;
    }
  }
  
  return Rstats::ArrayFunc::c($min);
}

sub order {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my @xs = map { to_c($_) } @_;
  
  my @xs_values;
  for my $x (@xs) {
    push @xs_values, $x->values;
  }

  my $decreasing = $opt->{decreasing} || FALSE;
  
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
  
  return Rstats::ArrayFunc::c(@orders);
}

# TODO
# na.last
sub rank {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $x1 = to_c(shift);
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
  
  return Rstats::ArrayFunc::c(@rank);
}

sub paste {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $sep = $opt->{sep};
  $sep = ' ' unless defined $sep;
  
  my $str = shift;
  my $x1 = shift;
  
  my $x1_values = $x1->values;
  my $x2_values = [];
  push @$x2_values, "$str$sep$_" for @$x1_values;
  
  return Rstats::ArrayFunc::c(@$x2_values);
}

sub pmax {
  my @vs = @_;
  
  my @maxs;
  for my $v (@vs) {
    my $elements = $v->decompose;
    for (my $i = 0; $i <@$elements; $i++) {
      $maxs[$i] = $elements->[$i]
        if !defined $maxs[$i] || Rstats::VectorFunc::more_than($elements->[$i], $maxs[$i])->value
    }
  }
  
  return  Rstats::ArrayFunc::c(@maxs);
}

sub pmin {
  my @vs = @_;
  
  my @mins;
  for my $v (@vs) {
    my $elements = $v->decompose;
    for (my $i = 0; $i <@$elements; $i++) {
      $mins[$i] = $elements->[$i]
        if !defined $mins[$i] || Rstats::VectorFunc::less_than($elements->[$i], $mins[$i])->value
    }
  }
  
  return Rstats::ArrayFunc::c(@mins);
}

sub prod { operate_unary(\&Rstats::VectorFunc::prod, @_) }

sub range {
  my $x1 = shift;
  
  my $min = min($x1);
  my $max = max($x1);
  
  return Rstats::ArrayFunc::c($min, $max);
}

sub rbind {
  my (@xs) = @_;
  
  return Rstats::Func::NULL() unless @xs;
  
  if ($xs[0]->is_data_frame) {
    
    # Check names
    my $first_names;
    for my $x (@xs) {
      if ($first_names) {
        my $names = $x->names->values;
        my $different;
        $different = 1 if @$first_names != @$names;
        for (my $i = 0; $i < @$first_names; $i++) {
          $different = 1 if $names->[$i] ne $first_names->[$i];
        }
        croak "rbind require same names having data frame"
          if $different;
      }
      else {
        $first_names = $x->names->values;
      }
    }
    
    # Create new vectors
    my @new_vectors;
    for my $name (@$first_names) {
      my @vectors;
      for my $x (@xs) {
        my $v = $x->getin($name);
        if ($v->is_factor) {
          push @vectors, $v->as_character;
        }
        else {
          push @vectors, $v;
        }
      }
      my $new_vector = Rstats::ArrayFunc::c(@vectors);
      push @new_vectors, $new_vector;
    }
    
    # Create new data frame
    my @data_frame_args;
    for (my $i = 0; $i < @$first_names; $i++) {
      push @data_frame_args, $first_names->[$i], $new_vectors[$i];
    }
    my $data_frame = Rstats::Func::data_frame(@data_frame_args);
    
    return $data_frame;
  }
  else {
    my $matrix = cbind(@xs);
    
    return Rstats::Func::t($matrix);
  }
}

sub rep {
  my ($x1, $x_times) = args_array(['x1', 'times'], @_);
  
  my $times = defined $x_times ? $x_times->value : 1;
  
  my $elements = [];
  push @$elements, @{$x1->decompose} for 1 .. $times;
  my $x2 = Rstats::ArrayFunc::c(@$elements);
  
  return $x2;
}

sub replace {
  my $x1 = to_c(shift);
  my $x2 = to_c(shift);
  my $v3 = to_c(shift);
  
  my $x1_elements = $x1->decompose;
  my $x2_elements = $x2->decompose;
  my $x2_elements_h = {};
  for my $x2_element (@$x2_elements) {
    my $x2_element_hash = $x2_element->to_string;
    
    $x2_elements_h->{$x2_element_hash}++;
    croak "replace second argument can't have duplicate number"
      if $x2_elements_h->{$x2_element_hash} > 1;
  }
  my $v3_elements = $v3->decompose;
  my $v3_length = @{$v3_elements};
  
  my $v4_elements = [];
  my $replace_count = 0;
  for (my $i = 0; $i < @$x1_elements; $i++) {
    my $hash = Rstats::VectorFunc::new_double($i + 1)->to_string;
    if ($x2_elements_h->{$hash}) {
      push @$v4_elements, $v3_elements->[$replace_count % $v3_length];
      $replace_count++;
    }
    else {
      push @$v4_elements, $x1_elements->[$i];
    }
  }
  
  return Rstats::Func::array(c(@$v4_elements));
}

sub rev {
  my $x1 = shift;
  
  # Reverse elements
  my @a2_elements = reverse @{$x1->decompose};
  my $x2 = Rstats::ArrayFunc::c(@a2_elements);
  $x1->copy_attrs_to($x2);
  
  return $x2;
}

sub rnorm {
  
  # Option
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  # Count
  my ($count, $mean, $sd) = @_;
  croak "rnorm count should be bigger than 0"
    if $count < 1;
  
  # Mean
  $mean = 0 unless defined $mean;
  
  # Standard deviation
  $sd = 1 unless defined $sd;
  
  # Random numbers(standard deviation)
  my @x1_elements;
  for (1 .. $count) {
    my ($rand1, $rand2) = (rand, rand);
    while ($rand1 == 0) { $rand1 = rand(); }
    
    my $rnorm = ($sd * sqrt(-2 * CORE::log($rand1))
      * sin(2 * Rstats::Util::pi() * $rand2))
      + $mean;
    
    push @x1_elements, $rnorm;
  }
  
  return Rstats::ArrayFunc::c(@x1_elements);
}

sub round {

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my ($_x1, $digits) = @_;
  $digits = $opt->{digits} unless defined $digits;
  $digits = 0 unless defined $digits;
  
  my $x1 = to_c($_x1);

  my $r = 10 ** $digits;
  my @a2_elements = map { Rstats::VectorFunc::new_double(Math::Round::round_even($_->value * $r) / $r) } @{$x1->decompose};
  my $x2 = Rstats::ArrayFunc::c(@a2_elements);
  $x1->copy_attrs_to($x2);
  $x2->mode('double');
  
  return $x2;
}

sub rowMeans {
  my $x1 = shift;
  
  my $dim_values = $x1->dim->values;
  if (@$dim_values == 2) {
    my $x1_values = [];
    for my $col (1 .. $dim_values->[1]) {
      my $x1_value = 0;
      $x1_value += $x1->value($_, $col) for (1 .. $dim_values->[0]);
      push @$x1_values, $x1_value / $dim_values->[0];
    }
    return Rstats::ArrayFunc::c(@$x1_values);
  }
  else {
    croak "Can't culculate rowMeans";
  }
}

sub rowSums {
  my $x1 = shift;
  
  my $dim_values = $x1->dim->values;
  if (@$dim_values == 2) {
    my $x1_values = [];
    for my $col (1 .. $dim_values->[1]) {
      my $x1_value = 0;
      $x1_value += $x1->value($_, $col) for (1 .. $dim_values->[0]);
      push @$x1_values, $x1_value;
    }
    return Rstats::ArrayFunc::c(@$x1_values);
  }
  else {
    croak "Can't culculate rowSums";
  }
}

sub runif {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};

  my ($count, $min, $max) = @_;
  
  $min = 0 unless defined $min;
  $max = 1 unless defined $max;
  croak "runif third argument must be bigger than second argument"
    if $min > $max;
  
  my $diff = $max - $min;
  my @x1_elements;
  if (defined $opt->{seed}) {
    srand $opt->{seed};
  }
  for (1 .. $count) {
    my $rand = rand($diff) + $min;
    push @x1_elements, $rand;
  }
  
  return Rstats::ArrayFunc::c(@x1_elements);
}

# TODO: prob option
sub sample {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  my ($_x1, $length) = @_;
  my $x1 = to_c($_x1);
  
  # Replace
  my $replace = $opt->{replace};
  
  my $x1_length = $x1->length_value;
  $length = $x1_length unless defined $length;
  
  croak "second argument element must be bigger than first argument elements count when you specify 'replace' option"
    if $length > $x1_length && !$replace;
  
  my @x2_elements;
  my $x1_elements = $x1->decompose;
  for my $i (0 .. $length - 1) {
    my $rand_num = int(rand @$x1_elements);
    my $rand_element = splice @$x1_elements, $rand_num, 1;
    push @x2_elements, $rand_element;
    push @$x1_elements, $rand_element if $replace;
  }
  
  return Rstats::ArrayFunc::c(@x2_elements);
}

sub sequence {
  my $_x1 = shift;
  
  my $x1 = to_c($_x1);
  my $x1_values = $x1->values;
  
  my @x2_values;
  for my $x1_value (@$x1_values) {
    push @x2_values, @{seq(1, $x1_value)->values};
  }
  
  return Rstats::ArrayFunc::c(@x2_values);
}

sub sinh { operate_unary(\&Rstats::VectorFunc::sinh, @_) }
sub sqrt { operate_unary(\&Rstats::VectorFunc::sqrt, @_) }

sub sort {
  my ($x1, $x_decreasing) = Rstats::Func::args_array(['x1', 'decreasing', 'na.last'], @_);
  
  my $decreasing = defined $x_decreasing ? $x_decreasing->value : 0;
  
  my @a2_elements = grep { !$_->is_na->value && !$_->is_nan->value } @{$x1->decompose};
  
  my $x3_elements = $decreasing
    ? [reverse sort { Rstats::VectorFunc::more_than($a, $b)->value ? 1 : Rstats::VectorFunc::equal($a, $b)->value ? 0 : -1 } @a2_elements]
    : [sort { Rstats::VectorFunc::more_than($a, $b)->value ? 1 : Rstats::VectorFunc::equal($a, $b)->value ? 0 : -1 } @a2_elements];

  return Rstats::ArrayFunc::c(@$x3_elements);
}

sub tail {
  my ($x1, $x_n) = Rstats::Func::args_array(['x1', 'n'], @_);
  
  my $n = defined $x_n ? $x_n->value : 6;
  
  my $e1 = $x1->decompose;
  my $max = $x1->length_value < $n ? $x1->length_value : $n;
  my @e2;
  for (my $i = 0; $i < $max; $i++) {
    unshift @e2, $e1->[$x1->length_value - ($i  + 1)];
  }
  
  my $x2 = Rstats::ArrayFunc::c(@e2);
  $x1->copy_attrs_to($x1);
  
  return $x2;
}

sub tan { operate_unary(\&Rstats::VectorFunc::tan, @_) }

sub operate_unary_old {
  my $func = shift;
  my $x1 = to_c(shift);
  
  my @a2_elements = map { $func->($_) } @{$x1->decompose};
  my $x2 = Rstats::ArrayFunc::c(@a2_elements);
  $x1->copy_attrs_to($x2);
  $x2->mode(Rstats::Func::max_type($x1, $x2));
  
  return $x2;
}

sub sin { operate_unary(\&Rstats::VectorFunc::sin, @_) }

sub operate_unary {
  my $func = shift;
  my $x1 = to_c(shift);
  
  my $x2_elements = $func->($x1->vector);
  my $x2 = Rstats::Func::NULL();
  $x2->vector($x2_elements);
  $x1->copy_attrs_to($x2);
  
  return $x2;
}

sub tanh { operate_unary(\&Rstats::VectorFunc::tanh, @_) }

sub trunc {
  my ($_x1) = @_;
  
  my $x1 = to_c($_x1);
  
  my @a2_elements
    = map { Rstats::VectorFunc::new_double(int $_->value) } @{$x1->decompose};

  my $x2 = Rstats::ArrayFunc::c(@a2_elements);
  $x1->copy_attrs_to($x2);
  $x2->mode('double');
  
  return $x2;
}

sub unique {
  my $x1 = to_c(shift);
  
  if ($x1->is_vector) {
    my $x2_elements = [];
    my $elements_count = {};
    my $na_count;
    for my $x1_element (@{$x1->decompose}) {
      if ($x1_element->is_na->value) {
        unless ($na_count) {
          push @$x2_elements, $x1_element;
        }
        $na_count++;
      }
      else {
        my $str = $x1_element->to_string;
        unless ($elements_count->{$str}) {
          push @$x2_elements, $x1_element;
        }
        $elements_count->{$str}++;
      }
    }

    return Rstats::ArrayFunc::c(@$x2_elements);
  }
  else {
    return $x1;
  }
}

sub median {
  my $x1 = to_c(shift);
  
  my $x2 = unique($x1);
  my $x3 = Rstats::Func::sort($x2);
  my $x3_length = $x3->length_value;
  
  if ($x3_length % 2 == 0) {
    my $middle = $x3_length / 2;
    my $x4 = $x3->get($middle);
    my $x5 = $x3->get($middle + 1);
    
    return ($x4 + $x5) / 2;
  }
  else {
    my $middle = int($x3_length / 2) + 1;
    return $x3->get($middle);
  }
}

sub quantile {
  my $x1 = to_c(shift);
  
  my $x2 = Rstats::Func::unique($x1);
  my $x3 = Rstats::Func::sort($x2);
  my $x3_length = $x3->length_value;
  
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
  
  my $x4 = Rstats::ArrayFunc::c(@$quantile_elements);
  $x4->names(Rstats::ArrayFunc::c(qw/0%  25%  50%  75% 100%/));
  
  return $x4;
}

sub sd {
  my $x1 = to_c(shift);
  
  my $sd = Rstats::Func::sqrt(var($x1));
  
  return $sd;
}

sub var {
  my $x1 = to_c(shift);
  
  my $var = sum(($x1 - Rstats::Func::mean($x1)) ** 2) / ($x1->length_value - 1);
  
  return $var;
}

sub which {
  my ($_x1, $cond_cb) = @_;
  
  my $x1 = to_c($_x1);
  my $x1_values = $x1->values;
  my @x2_values;
  for (my $i = 0; $i < @$x1_values; $i++) {
    local $_ = $x1_values->[$i];
    if ($cond_cb->($x1_values->[$i])) {
      push @x2_values, $i + 1;
    }
  }
  
  return Rstats::ArrayFunc::c(@x2_values);
}

sub new_vector {
  my $type = shift;
  
  if ($type eq 'character') {
    return new_character(@_);
  }
  elsif ($type eq 'complex') {
    return new_complex(@_);
  }
  elsif ($type eq 'double') {
    return new_double(@_);
  }
  elsif ($type eq 'integer') {
    return new_integer(@_);
  }
  elsif ($type eq 'logical') {
    return new_logical(@_);
  }
  else {
    croak("Invalid type $type is passed(new_vector)");
  }
}

sub new_character {
  my $x1 = Rstats::Func::NULL();
  $x1->vector(Rstats::VectorFunc::new_character(@_));
}

sub new_complex {
  my $x1 = Rstats::Func::NULL();
  $x1->vector(Rstats::VectorFunc::new_complex(@_));
}

sub new_double {
  my $x1 = Rstats::Func::NULL();
  $x1->vector(Rstats::VectorFunc::new_double(@_));
}

sub new_integer {
  my $x1 = Rstats::Func::NULL();
  $x1->vector(Rstats::VectorFunc::new_integer(@_));
}

sub new_logical {
  my $x1 = Rstats::Func::NULL();
  $x1->vector(Rstats::VectorFunc::new_logical(@_));
}

sub matrix {
  my ($x1, $x_nrow, $x_ncol, $x_byrow, $x_dirnames)
    = Rstats::Func::args_array(['x1', 'nrow', 'ncol', 'byrow', 'dirnames'], @_);

  croak "matrix method need data as frist argument"
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
  my $x1_length = $x1->length_value;
  if (!defined $nrow && !defined $ncol) {
    $nrow = $x1_length;
    $ncol = 1;
  }
  elsif (!defined $nrow) {
    $nrow = int($x1_length / $ncol);
  }
  elsif (!defined $ncol) {
    $ncol = int($x1_length / $nrow);
  }
  my $length = $nrow * $ncol;
  
  my $dim = [$nrow, $ncol];
  my $matrix;
  my $x_matrix = Rstats::Func::NULL();
  $x_matrix->vector(Rstats::VectorFunc::new_vector($x1->vector->type, @$x1_values));
  if ($byrow) {
    $matrix = Rstats::Func::array(
      $x_matrix,
      Rstats::ArrayFunc::c($dim->[1], $dim->[0]),
    );
    
    $matrix = Rstats::Func::t($matrix);
  }
  else {
    $matrix = Rstats::Func::array($x_matrix, Rstats::ArrayFunc::c(@$dim));
  }
  
  return $matrix;
}

sub inner_product {
  my ($x1, $x2) = @_;
  
  # Convert to matrix
  $x1 = Rstats::Func::t($x1->as_matrix) if $x1->is_vector;
  $x2 = $x2->as_matrix if $x2->is_vector;
  
  # Calculate
  if ($x1->is_matrix && $x2->is_matrix) {
    
    croak "requires numeric/complex matrix/vector arguments"
      if $x1->length_value == 0 || $x2->length_value == 0;
    croak "Error in a x b : non-conformable arguments"
      unless $x1->dim->values->[1] == $x2->dim->values->[0];
    
    my $row_max = $x1->dim->values->[0];
    my $col_max = $x2->dim->values->[1];
    
    my $x3_elements = [];
    for (my $col = 1; $col <= $col_max; $col++) {
      for (my $row = 1; $row <= $row_max; $row++) {
        my $x1_part = $x1->get($row);
        my $x2_part = $x2->get(Rstats::Func::NULL(), $col);
        my $x3_part = sum($x1 * $x2);
        push @$x3_elements, $x3_part;
      }
    }
    
    my $x3 = Rstats::Func::matrix(c(@$x3_elements), $row_max, $col_max);
    
    return $x3;
  }
  else {
    croak "inner_product should be dim < 3."
  }
}

sub row {
  my $x1 = shift;
  
  my $nrow = Rstats::Func::nrow($x1)->value;
  my $ncol = Rstats::Func::ncol($x1)->value;
  
  my @values = (1 .. $nrow) x $ncol;
  
  return Rstats::Func::array(Rstats::ArrayFunc::c(@values), Rstats::ArrayFunc::c($nrow, $ncol));
}

sub sum { operate_unary(\&Rstats::VectorFunc::sum, @_) }

sub ncol {
  my $x1 = shift;
  
  return Rstats::ArrayFunc::c($x1->dim->values->[1]);
}

sub seq {
  
  # Option
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  # Along
  my $_along = $opt->{along};
  if (defined $_along) {
    my $along = to_c($_along);
    my $length = $along->length_value;
    return seq(1, $length);
  }
  else {
    my ($from, $to) = @_;
    
    # From
    $from = $opt->{from} unless defined $from;
    croak "seq function need from option" unless defined $from;
    
    # To
    $to = $opt->{to} unless defined $to;
    croak "seq function need to option" unless defined $to;

    # Length
    my $length = $opt->{length};
    
    # By
    my $by = $opt->{by};
    
    if (defined $length && defined $by) {
      croak "Can't use by option and length option as same time";
    }
    
    unless (defined $by) {
      if ($to >= $from) {
        $by = 1;
      }
      else {
        $by = -1;
      }
    }
    croak "by option should be except for 0" if $by == 0;
    
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
        croak "by option is invalid number(seq function)";
      }
      
      my $element = $from;
      while ($element <= $to) {
        push @$elements, $element;
        $element += $by;
      }
    }
    else {
      if ($by > 0) {
        croak "by option is invalid number(seq function)";
      }
      
      my $element = $from;
      while ($element >= $to) {
        push @$elements, $element;
        $element += $by;
      }
    }
    
    return Rstats::ArrayFunc::c(@$elements);
  }
}

sub numeric {
  my $num = shift;
  
  return Rstats::ArrayFunc::c((0) x $num);
}

sub upgrade_type {
  my (@xs) = @_;
  
  # Check elements
  my $type_h = {};
  for my $x1 (@xs) {
    my $type = $x1->vector->type || '';
    if ($type eq 'character') {
      $type_h->{character}++;
    }
    elsif ($type eq 'complex') {
      $type_h->{complex}++;
    }
    elsif ($type eq 'double') {
      $type_h->{double}++;
    }
    elsif ($type eq 'integer') {
      $type_h->{integer}++;
    }
    elsif ($type eq 'logical') {
      $type_h->{logical}++;
    }
    else {
      croak "Invalid type";
    }
  }

  # Upgrade elements and type if type is different
  my @types = keys %$type_h;
  if (@types > 1) {
    my $to_type;
    if ($type_h->{character}) {
      $to_type = 'character';
    }
    elsif ($type_h->{complex}) {
      $to_type = 'complex';
    }
    elsif ($type_h->{double}) {
      $to_type = 'double';
    }
    elsif ($type_h->{integer}) {
      $to_type = 'integer';
    }
    elsif ($type_h->{logical}) {
      $to_type = 'logical';
    }
    $_ = $_->as($to_type) for @xs;
  }
  
  return @xs;
}

sub add { operate_binary(\&Rstats::VectorFunc::add, @_) }
sub subtract { operate_binary(\&Rstats::VectorFunc::subtract, @_) }
sub multiply { operate_binary(\&Rstats::VectorFunc::multiply, @_) }
sub divide { operate_binary(\&Rstats::VectorFunc::divide, @_) }
sub remainder { operate_binary(\&Rstats::VectorFunc::remainder, @_) }
sub pow { operate_binary(\&Rstats::VectorFunc::pow, @_) }
sub less_than { operate_binary(\&Rstats::VectorFunc::less_than, @_) }
sub less_than_or_equal { operate_binary(\&Rstats::VectorFunc::less_than_or_equal, @_) }
sub more_than { operate_binary(\&Rstats::VectorFunc::more_than, @_) }
sub more_than_or_equal { operate_binary(\&Rstats::VectorFunc::more_than_or_equal, @_) }
sub equal { operate_binary(\&Rstats::VectorFunc::equal, @_) }
sub not_equal { operate_binary(\&Rstats::VectorFunc::not_equal, @_) }
sub and { operate_binary(\&Rstats::VectorFunc::and, @_) }
sub or { operate_binary(\&Rstats::VectorFunc::or, @_) }

sub negation { operate_unary(\&Rstats::VectorFunc::negation, @_) }

sub _fix_pos {
  my ($data1, $data2, $reverse) = @_;
  
  my $x1;
  my $x2;
  if (ref $data2 eq 'Rstats::Array') {
    $x1 = $data1;
    $x2 = $data2;
  }
  else {
    if ($reverse) {
      $x1 = Rstats::ArrayFunc::c($data2);
      $x2 = $data1;
    }
    else {
      $x1 = $data1;
      $x2 = Rstats::ArrayFunc::c($data2);
    }
  }
  
  return ($x1, $x2);
}

sub operate_binary {
  my ($func, $x1, $x2) = @_;
  
  $x1 = to_c($x1);
  $x2 = to_c($x2);
  
  # Upgrade mode if type is different
  ($x1, $x2) = Rstats::ArrayFunc::upgrade_type($x1, $x2) if $x1->vector->type ne $x2->vector->type;
  
  # Upgrade length if length is defferent
  my $x1_length = $x1->length_value;
  my $x2_length = $x2->length_value;
  my $length;
  if ($x1_length > $x2_length) {
    $x2 = Rstats::Func::array($x2, $x1_length);
    $length = $x1_length;
  }
  elsif ($x1_length < $x2_length) {
    $x1 = Rstats::Func::array($x1, $x2_length);
    $length = $x2_length;
  }
  else {
    $length = $x1_length;
  }
  
  no strict 'refs';
  my $x3;
  my $x3_elements = $func->($x1->vector, $x2->vector);
  $x3 = Rstats::Func::NULL();
  $x3->vector($x3_elements);
  
  $x1->copy_attrs_to($x3);

  return $x3;
}

sub operate_binary_fix_pos {
  my ($self, $func, $data, $reverse) = @_;
  
  # fix postion
  my ($x1, $x2) = Rstats::ArrayFunc::_fix_pos($self, $data, $reverse);
  
  return Rstats::Func::operate_binary($func, $x1, $x2);
}

sub value {
  my $self = shift;

  my $e1;
  my $dim_values = $self->dim_as_array->values;
  my $self_elements = $self->decompose;
  if (@_) {
    if (@$dim_values == 1) {
      $e1 = $self_elements->[$_[0] - 1];
    }
    elsif (@$dim_values == 2) {
      $e1 = $self_elements->[($_[0] + $dim_values->[0] * ($_[1] - 1)) - 1];
    }
    else {
      $e1 = $self->get(@_)->decompose->[0];
    }
  }
  else {
    $e1 = $self_elements->[0];
  }
  
  return defined $e1 ? $e1->value : undef;
}

sub bool {
  my $self = shift;
  
  my $length = $self->length_value;
  if ($length == 0) {
    croak 'Error in if (a) { : argument is of length zero';
  }
  elsif ($length > 1) {
    carp 'In if (a) { : the condition has length > 1 and only the first element will be used';
  }
  
  my $type = $self->type;
  my $value = $self->value;

  my $is;
  if ($type eq 'character' || $type eq 'complex') {
    croak 'Error in -a : invalid argument to unary operator ';
  }
  elsif ($type eq 'double') {
    if ($value eq 'Inf' || $value eq '-Inf') {
      $is = 1;
    }
    elsif ($value eq 'NaN') {
      croak 'argument is not interpretable as logical';
    }
    else {
      $is = $value;
    }
  }
  elsif ($type eq 'integer' || $type eq 'logical') {
    $is = $value;
  }
  else {
    croak "Invalid type";
  }
  
  if (!defined $value) {
    croak "Error in bool context (a) { : missing value where TRUE/FALSE needed"
  }

  return $is;
}

sub set {
  my $self = shift;
  my $x2 = Rstats::Func::to_c(shift);
  
  my $at = $self->at;
  my $_indexs = ref $at eq 'ARRAY' ? $at : [$at];
  my ($poss, $x2_dim) = Rstats::Util::parse_index($self, 0, @$_indexs);
  
  my $self_elements;
  if ($self->is_factor) {
    $self_elements = $self->decompose;
    $x2 = $x2->as_character unless $x2->is_character;
    my $x2_elements = $x2->decompose;
    my $levels_h = $self->_levels_h;
    for (my $i = 0; $i < @$poss; $i++) {
      my $pos = $poss->[$i];
      my $element = $x2_elements->[(($i + 1) % @$poss) - 1];
      if ($element->is_na->value) {
        $self_elements->[$pos] = Rstats::VectorFunc::new_logical(undef);
      }
      else {
        my $value = $element->to_string;
        if ($levels_h->{$value}) {
          $self_elements->[$pos] = $levels_h->{$value};
        }
        else {
          carp "invalid factor level, NA generated";
          $self_elements->[$pos] = Rstats::VectorFunc::new_logical(undef);
        }
      }
    }
  }
  else {
    # Upgrade mode if type is different
    if ($self->vector->type ne $x2->vector->type) {
      my $self_tmp;
      ($self_tmp, $x2) = Rstats::ArrayFunc::upgrade_type($self, $x2);
      $self_tmp->copy_attrs_to($self);
      $self->vector($self_tmp->vector);
    }

    $self_elements = $self->decompose;

    my $x2_elements = $x2->decompose;
    for (my $i = 0; $i < @$poss; $i++) {
      my $pos = $poss->[$i];
      $self_elements->[$pos] = $x2_elements->[(($i + 1) % @$poss) - 1];
    }
  }
  
  $self->vector(Rstats::Vector->compose($self->vector->type, $self_elements));
  
  return $self;
}

sub _levels_h {
  my $self = shift;
  
  my $levels_h = {};
  my $levels = $self->levels->values;
  for (my $i = 1; $i <= @$levels; $i++) {
    $levels_h->{$levels->[$i - 1]} = Rstats::VectorFunc::new_integer($i);
  }
  
  return $levels_h;
}

sub get {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $dim_drop;
  my $level_drop;
  if ($self->is_factor) {
    $level_drop = $opt->{drop};
  }
  else {
    $dim_drop = $opt->{drop};
  }
  
  $dim_drop = 1 unless defined $dim_drop;
  $level_drop = 0 unless defined $level_drop;
  
  my @_indexs = @_;

  my $_indexs;
  if (@_indexs) {
    $_indexs = \@_indexs;
  }
  else {
    my $at = $self->at;
    $_indexs = ref $at eq 'ARRAY' ? $at : [$at];
  }
  $self->at($_indexs);
  
  my ($poss, $x2_dim, $new_indexes) = Rstats::Util::parse_index($self, $dim_drop, @$_indexs);
  
  my $self_values = $self->values;
  my @a2_values = map { $self_values->[$_] } @$poss;
  
  # array
  my $x2 = Rstats::Func::array(
    Rstats::Func::new_vector($self->vector->type, @a2_values),
    Rstats::ArrayFunc::c(@$x2_dim)
  );
  
  # Copy attributes
  $self->copy_attrs_to($x2, {new_indexes => $new_indexes, exclude => ['dim']});

  # level drop
  if ($level_drop) {
    $x2 = Rstats::Func::factor($x2->as_character);
  }
  
  return $x2;
}

sub getin { get(@_) }

sub is_null {
  my $x1 = Rstats::Func::to_c(shift);
  
  my $x_is = $x1->length_value == 0 ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
  
  return $x_is;
}

sub is_nan {
  my $x1 = Rstats::Func::to_c(shift);
  
  if (my $vector = $x1->vector) {
    my $x2 = Rstats::Func::NULL();
    $x2->vector($x1->vector->is_nan);
    $x1->copy_attrs_to($x2);
    
    return $x2;
  }
  else {
    croak "Error : is_nan is not implemented except array";
  }
}

sub is_infinite {
  my $x1 = Rstats::Func::to_c(shift);
  
  if (my $vector = $x1->vector) {
    my $x2 = Rstats::Func::NULL();
    $x2->vector($x1->vector->is_infinite);
    $x1->copy_attrs_to($x2);
    
    return $x2;
  }
  else {
    croak "Error : is_infinite is not implemented except array";
  }
}

sub is_finite {
  my $x1 = Rstats::Func::to_c(shift);
  
  if (my $vector = $x1->vector) {
    my $x2 = Rstats::Func::NULL();
    $x2->vector($x1->vector->is_finite);
    $x1->copy_attrs_to($x2);
    
    return $x2;
  }
  else {
    croak "Error : is_finite is not implemented except array";
  }
}

sub to_string {
  my $self = shift;
  
  my $is_factor = $self->is_factor;
  my $is_ordered = $self->is_ordered;
  my $levels;
  if ($is_factor) {
    $levels = $self->levels->values;
  }
  
  $self = $self->as_character if $self->is_factor;
  
  my $is_character = $self->is_character;

  my $values = $self->values;
  my $type = $self->vector->type;
  
  my $dim_values = $self->dim_as_array->values;
  
  my $dim_length = @$dim_values;
  my $dim_num = $dim_length - 1;
  my $poss = [];
  
  my $str;
  if (@$values) {
    if ($dim_length == 1) {
      my $names = $self->names->values;
      if (@$names) {
        $str .= join(' ', @$names) . "\n";
      }
      my @parts = map { $self->_value_to_string($_, $type, $is_factor) } @$values;
      $str .= '[1] ' . join(' ', @parts) . "\n";
    }
    elsif ($dim_length == 2) {
      $str .= '     ';
      
      my $colnames = $self->colnames->values;
      if (@$colnames) {
        $str .= join(' ', @$colnames) . "\n";
      }
      else {
        for my $d2 (1 .. $dim_values->[1]) {
          $str .= $d2 == $dim_values->[1] ? "[,$d2]\n" : "[,$d2] ";
        }
      }
      
      my $rownames = $self->rownames->values;
      my $use_rownames = @$rownames ? 1 : 0;
      for my $d1 (1 .. $dim_values->[0]) {
        if ($use_rownames) {
          my $rowname = $rownames->[$d1 - 1];
          $str .= "$rowname ";
        }
        else {
          $str .= "[$d1,] ";
        }
        
        my @parts;
        for my $d2 (1 .. $dim_values->[1]) {
          my $part = $self->value($d1, $d2);
          push @parts, $self->_value_to_string($part, $type, $is_factor);
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
            
            my $l_dimnames = $self->dimnames;
            my $dimnames;
            if ($l_dimnames->is_null) {
              $dimnames = [];
            }
            else {
              my $x_dimnames = $l_dimnames->getin($i);
              $dimnames = defined $l_dimnames ? $l_dimnames->values : [];
            }
            
            if (@$dimnames) {
              $str .= join(' ', @$dimnames) . "\n";
            }
            else {
              for my $d2 (1 .. $dim_values[1]) {
                $str .= $d2 == $dim_values[1] ? "[,$d2]\n" : "[,$d2] ";
              }
            }

            for my $d1 (1 .. $dim_values[0]) {
              $str .= "[$d1,] ";
              
              my @parts;
              for my $d2 (1 .. $dim_values[1]) {
                my $part = $self->value($d1, $d2, @$poss);
                push @parts, $self->_value_to_string($part, $type, $is_factor);
              }
              
              $str .= join(' ', @parts) . "\n";
            }
          }
          shift @$poss;
        }
      };
      $code->(@$dim_values);
    }

    if ($is_factor) {
      if ($is_ordered) {
        $str .= 'Levels: ' . join(' < ', @$levels) . "\n";
      }
      else {
        $str .= 'Levels: ' . join(' ', , @$levels) . "\n";
      }
    }
  }
  else {
    $str = 'NULL';
  }
  
  return $str;
}

1;

=head1 NAME

Rstats::ArrayFunc - Array functions

