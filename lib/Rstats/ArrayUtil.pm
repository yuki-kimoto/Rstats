package Rstats::ArrayUtil;

use strict;
use warnings;
use Carp qw/croak carp/;
use Rstats::Array;
use Rstats::Util;
use List::Util;
use Math::Trig ();
use POSIX ();;
use Math::Round ();

my %types_h = map { $_ => 1 } qw/character complex numeric double integer logical/;

sub NULL { Rstats::Array->new(elements => [], dim => [], type => 'logical') }

sub operation {
  my ($op, $a1, $a2) = @_;
  
  $a1 = Rstats::ArrayUtil::to_array($a1);
  $a2 = Rstats::ArrayUtil::to_array($a2);
  
  # Upgrade mode if mode is different
  ($a1, $a2) = Rstats::ArrayUtil::upgrade_mode($a1, $a2) if $a1->{type} ne $a2->{type};
  
  # Calculate
  my $a1_length = @{$a1->elements};
  my $a2_length = @{$a2->elements};
  my $longer_length = $a1_length > $a2_length ? $a1_length : $a2_length;
  
  no strict 'refs';
  my $operation = "Rstats::Util::$op";
  my @a3_elements = map {
    &$operation($a1->elements->[$_ % $a1_length], $a2->elements->[$_ % $a2_length])
  } (0 .. $longer_length - 1);
  
  my $a3 = Rstats::ArrayUtil::array(\@a3_elements);
  if ($op eq '/') {
    $a3->{type} = 'double';
  }
  else {
    $a3->{type} = $a1->{type};
  }
  
  return $a3;
}

sub add { Rstats::ArrayUtil::operation('add', @_) }

sub subtract { Rstats::ArrayUtil::operation('subtract', @_)}

sub multiply { Rstats::ArrayUtil::operation('multiply', @_)}

sub divide { Rstats::ArrayUtil::operation('divide', @_)}

sub raise { Rstats::ArrayUtil::operation('raise', @_)}

sub remainder { Rstats::ArrayUtil::operation('remainder', @_)}

sub more_than { Rstats::ArrayUtil::operation('more_than', @_)}

sub more_than_or_equal { Rstats::ArrayUtil::operation('more_than_or_equal', @_)}

sub less_than { Rstats::ArrayUtil::operation('less_than', @_)}

sub less_than_or_equal { Rstats::ArrayUtil::operation('less_than_or_equal', @_)}

sub equal { Rstats::ArrayUtil::operation('equal', @_)}

sub not_equal { Rstats::ArrayUtil::operation('not_equal', @_)}

sub abs {
  my $a1 = Rstats::ArrayUtil::to_array(shift);
  
  my @a2_elements = map { Rstats::Util::abs($_) } @{$a1->elements};
  
  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub acos {
  my $_a1 = shift;;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::acos $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub acosh {
  my $_a1 = shift;;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::acosh $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub append {

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $v1 = shift;
  my $element = shift;
  
  my $after = $opt->{after};
  $after = @{$v1->elements} unless defined $after;
  
  if (ref $element eq 'ARRAY') {
    splice @{$v1->elements}, $after, 0, @$element;
  }
  elsif (ref $element eq 'Rstats::Array') {
    splice @{$v1->elements}, $after, 0, @{$element->elements};
  }
  else {
    splice @{$v1->elements}, $after, 0, $element;
  }
  
  return $v1
}

sub array {
  
  # Arguments
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my ($a1, $_dim) = @_;
  $_dim = $opt->{dim} unless defined $_dim;
  
  my $array = Rstats::ArrayUtil::c($a1);

  # Dimention
  my $elements = $array->elements;
  my $dim;
  if (defined $_dim) {
    if (ref $_dim eq 'Rstats::Array') {
      $dim = $_dim->elements;
    }
    elsif (ref $_dim eq 'ARRAY') {
      $dim = $_dim;
    }
    elsif(!ref $_dim) {
      $dim = [$_dim];
    }
  }
  else {
    $dim = [scalar @$elements]
  }
  Rstats::ArrayUtil::dim($array => $dim);
  
  # Fix elements
  my $max_length = 1;
  $max_length *= $_ for @{Rstats::ArrayUtil::dim_as_array($array)->values};
  if (@$elements > $max_length) {
    @$elements = splice @$elements, 0, $max_length;
  }
  elsif (@$elements < $max_length) {
    my $repeat_count = int($max_length / @$elements) + 1;
    @$elements = (@$elements) x $repeat_count;
    @$elements = splice @$elements, 0, $max_length;
  }
  $array->elements($elements);
  
  return $array;
}

sub asin {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::asin $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub asinh {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::asinh $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub atan {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::atan $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub atanh {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::atanh($_->value)) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub cbind {
  my @arrays = @_;
  
  my $row_count_needed;
  my $col_count_total;
  my $a2_elements = [];
  for my $_a (@arrays) {
    
    my $a = Rstats::ArrayUtil::to_array($_a);
    
    my $row_count;
    if (Rstats::ArrayUtil::is_matrix($a)) {
      $row_count = Rstats::ArrayUtil::dim($a)->elements->[0];
      $col_count_total += Rstats::ArrayUtil::dim($a)->elements->[1];
    }
    elsif (Rstats::ArrayUtil::is_vector($a)) {
      $row_count = Rstats::ArrayUtil::dim_as_array($a)->values->[0];
      $col_count_total += 1;
    }
    else {
      croak "cbind or rbind can only receive matrix and vector";
    }
    
    $row_count_needed = $row_count unless defined $row_count_needed;
    croak "Row count is different" if $row_count_needed ne $row_count;
    
    push @$a2_elements, $a->elements;
  }
  my $matrix = Rstats::ArrayUtil::matrix($a2_elements, $row_count_needed, $col_count_total);
  
  return $matrix;
}

sub ceiling {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  my @a2_elements = map { Rstats::Util::double(POSIX::ceil $_->value) } @{$a1->elements};
  
  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub colMeans {
  my $m1 = shift;
  
  my $dim_values = Rstats::ArrayUtil::dim($m1)->values;
  if (@$dim_values == 2) {
    my $v1_values = [];
    for my $row (1 .. $dim_values->[0]) {
      my $v1_value = 0;
      $v1_value += $m1->value($row, $_) for (1 .. $dim_values->[1]);
      push @$v1_values, $v1_value / $dim_values->[1];
    }
    return Rstats::ArrayUtil::c($v1_values);
  }
  else {
    croak "Can't culculate colSums";
  }
}

sub colSums {
  my $m1 = shift;
  
  my $dim_values = Rstats::ArrayUtil::dim($m1)->values;
  if (@$dim_values == 2) {
    my $v1_values = [];
    for my $row (1 .. $dim_values->[0]) {
      my $v1_value = 0;
      $v1_value += $m1->value($row, $_) for (1 .. $dim_values->[1]);
      push @$v1_values, $v1_value;
    }
    return Rstats::ArrayUtil::c($v1_values);
  }
  else {
    croak "Can't culculate colSums";
  }
}

sub cos {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(cos $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub cosh {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::cosh $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub cumsum {
  my $_v1 = shift;
  
  my $v1 = Rstats::ArrayUtil::to_array($_v1);
  my @v2_values;
  my $total = 0;
  push @v2_values, $total = $total + $_ for @{$v1->values};
  
  return Rstats::ArrayUtil::c(\@v2_values);
}

sub complex {
  my ($re, $im) = @_;
  
  return Rstats::ArrayUtil::c(Rstats::Util::complex($re, $im));
}

sub exp {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(exp $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub expm1 {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements
    = map {
      Rstats::Util::double(
        CORE::abs($_->value) < 1e-5
          ? $_->value + 0.5 * $_->value * $_->value
          : CORE::exp($_->value) - 1.0
      )
    } @{$a1->elements};
  
  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub FALSE { Rstats::ArrayUtil::c(Rstats::Util::FALSE()) }

sub floor {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(POSIX::floor $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub head {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $v1 = shift;
  
  my $n = $opt->{n};
  $n = 6 unless defined $n;
  
  my $elements1 = $v1->{elements};
  my $max = @{$v1->elements} < $n ? @{$v1->elements} : $n;
  my @elements2;
  for (my $i = 0; $i < $max; $i++) {
    push @elements2, $elements1->[$i];
  }
  
  return $v1->new(elements => \@elements2);
}

sub i {
  my $i = Rstats::Util::complex(0, 1);
  
  return Rstats::ArrayUtil::c($i);
}

sub ifelse {
  my ($_v1, $value1, $value2) = @_;
  
  my $v1 = Rstats::ArrayUtil::to_array($_v1);
  my $v1_values = $v1->values;
  my @v2_values;
  for my $v1_value (@$v1_values) {
    local $_ = $v1_value;
    if ($v1_value) {
      push @v2_values, $value1;
    }
    else {
      push @v2_values, $value2;
    }
  }
  
  return Rstats::ArrayUtil::array(\@v2_values);
}

sub Inf { Rstats::ArrayUtil::c(Rstats::Util::Inf()) }

sub is_finite {
  my $_a1 = shift;

  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map {
    !ref $_ || ref $_ eq 'Rstats::Type::Complex' || ref $_ eq 'Rstats::Logical' 
      ? Rstats::Util::TRUE()
      : Rstats::Util::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::ArrayUtil::array(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'logical');
  
  return $a2;
}

sub is_infinite {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map {
    ref $_ eq 'Rstats::Inf' ? Rstats::Util::TRUE() : Rstats::Util::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::ArrayUtil::array(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'logical');

  return $a1->clone_without_elements(elements => \@a2_elements);
}

sub is_na {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map {
    ref $_ eq  'Rstats::Type::NA' ? Rstats::Util::TRUE() : Rstats::Util::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::ArrayUtil::array(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'logical');
  
  return $a2;
}

sub is_nan {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map {
    ref $_ eq  'Rstats::NaN' ? Rstats::Util::TRUE() : Rstats::Util::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::ArrayUtil::array(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'logical');
  
  return $a2;
}

sub is_null {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = [!@$a1->elements ? Rstats::Util::TRUE() : Rstats::Util::FALSE()];
  my $a2 = Rstats::ArrayUtil::array(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'logical');
  
  return $a2;
}

sub log {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(log $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub logb { Rstats::ArrayUtil::log(@_) }

sub log2 {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(CORE::log $_->value / CORE::log 2) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub log10 {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(CORE::log $_->value / CORE::log 10) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
}

sub max {
  my @vs = @_;
  
  my @all_values = map { @{$_->values} } @vs;
  my $max = List::Util::max(@all_values);
  return $max;
}

sub mean {
  my $a1 = Rstats::ArrayUtil::to_array(shift);
  
  my $a2 = Rstats::ArrayUtil::divide(Rstats::ArrayUtil::sum($a1), scalar @{$a1->elements});
  
  return $a2;
}

sub min {
  my @vs = @_;
  
  my @all_values = map { @{$_->values} } @vs;
  my $min = List::Util::min(@all_values);
  return $min;
}

sub order { Rstats::ArrayUtil::_order(1, @_) }

sub paste {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  my $sep = $opt->{sep};
  $sep = ' ' unless defined $sep;
  
  my $str = shift;
  my $v1 = shift;
  
  my $v1_values = $v1->values;
  my $v2_values = [];
  push @$v2_values, "$str$sep$_" for @$v1_values;
  
  return Rstats::ArrayUtil::c($v2_values);
}

sub pmax {
  my @vs = @_;
  
  my @maxs;
  for my $v (@vs) {
    my $values = $v->values;
    for (my $i = 0; $i <@$values; $i++) {
      $maxs[$i] = $values->[$i]
        if !defined $maxs[$i] || $values->[$i] > $maxs[$i]
    }
  }
  
  return  Rstats::ArrayUtil::c(\@maxs);
}

sub pmin {
  my @vs = @_;
  
  my @mins;
  for my $v (@vs) {
    my $values = $v->values;
    for (my $i = 0; $i <@$values; $i++) {
      $mins[$i] = $values->[$i]
        if !defined $mins[$i] || $values->[$i] < $mins[$i]
    }
  }
  
  return Rstats::ArrayUtil::c(\@mins);
}

sub prod {
  my $v1 = shift;
  
  my $v1_values = $v1->values;
  my $prod = List::Util::product(@$v1_values);
  return Rstats::ArrayUtil::c($prod);
}

sub range {
  my $array = shift;
  
  my $min = Rstats::ArrayUtil::min($array);
  my $max = Rstats::ArrayUtil::max($array);
  
  return Rstats::ArrayUtil::c($min, $max);
}

sub rbind {
  my (@arrays) = @_;
  
  my $matrix = Rstats::ArrayUtil::cbind(@arrays);
  
  return Rstats::ArrayUtil::t($matrix);
}

sub rep {

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  my $v1 = shift;
  my $times = $opt->{times} || 1;
  
  my $elements = [];
  push @$elements, @{$v1->elements} for 1 .. $times;
  my $v2 = Rstats::ArrayUtil::c($elements);
  
  return $v2;
}

sub replace {
  my ($_v1, $_v2, $_v3) = @_;
  
  my $v1 = Rstats::ArrayUtil::to_array($_v1);
  my $v2 = Rstats::ArrayUtil::to_array($_v2);
  my $v3 = Rstats::ArrayUtil::to_array($_v3);
  
  my $v1_values = $v1->values;
  my $v2_values = $v2->values;
  my $v2_values_h = {};
  for my $v2_value (@$v2_values) {
    $v2_values_h->{$v2_value - 1}++;
    croak "replace second argument can't have duplicate number"
      if $v2_values_h->{$v2_value - 1} > 1;
  }
  my $v3_values = $v3->values;
  my $v3_length = @{$v3_values};
  
  my $v4_values = [];
  my $replace_count = 0;
  for (my $i = 0; $i < @$v1_values; $i++) {
    if ($v2_values_h->{$i}) {
      push @$v4_values, $v3_values->[$replace_count % $v3_length];
      $replace_count++;
    }
    else {
      push @$v4_values, $v1_values->[$i];
    }
  }
  
  return Rstats::ArrayUtil::array($v4_values);
}

sub rev { Rstats::ArrayUtil::_order(0, @_) }

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
  my @v1_elements;
  for (1 .. $count) {
    my ($rand1, $rand2) = (rand, rand);
    while ($rand1 == 0) { $rand1 = rand(); }
    
    my $rnorm = ($sd * sqrt(-2 * CORE::log($rand1))
      * sin(2 * Math::Trig::pi * $rand2))
      + $mean;
    
    push @v1_elements, $rnorm;
  }
  
  return Rstats::ArrayUtil::c(\@v1_elements);
}

sub round {

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my ($_a1, $digits) = @_;
  $digits = $opt->{digits} unless defined $digits;
  $digits = 0 unless defined $digits;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);

  my $r = 10 ** $digits;
  my @a2_elements = map { Rstats::Util::double(Math::Round::round_even($_->value * $r) / $r) } @{$a1->elements};
  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub rowMeans {
  my $m1 = shift;
  
  my $dim_values = Rstats::ArrayUtil::dim($m1)->values;
  if (@$dim_values == 2) {
    my $v1_values = [];
    for my $col (1 .. $dim_values->[1]) {
      my $v1_value = 0;
      $v1_value += $m1->value($_, $col) for (1 .. $dim_values->[0]);
      push @$v1_values, $v1_value / $dim_values->[0];
    }
    return Rstats::ArrayUtil::c($v1_values);
  }
  else {
    croak "Can't culculate rowSums";
  }
}

sub rowSums {
  my $m1 = shift;
  
  my $dim_values = Rstats::ArrayUtil::dim($m1)->values;
  if (@$dim_values == 2) {
    my $v1_values = [];
    for my $col (1 .. $dim_values->[1]) {
      my $v1_value = 0;
      $v1_value += $m1->value($_, $col) for (1 .. $dim_values->[0]);
      push @$v1_values, $v1_value;
    }
    return Rstats::ArrayUtil::c($v1_values);
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
  my @v1_elements;
  if (defined $opt->{seed}) {
    srand $opt->{seed};
  }
  for (1 .. $count) {
    my $rand = rand($diff) + $min;
    push @v1_elements, $rand;
  }
  
  return Rstats::ArrayUtil::c(\@v1_elements);
}

# TODO: prob option
sub sample {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  my ($_v1, $length) = @_;
  my $v1 = Rstats::ArrayUtil::to_array($_v1);
  
  # Replace
  my $replace = $opt->{replace};
  
  my $v1_length = @{$v1->elements};
  $length = $v1_length unless defined $length;
  
  croak "second argument element must be bigger than first argument elements count when you specify 'replace' option"
    if $length > $v1_length && !$replace;
  
  my @v2_elements;
  for my $i (0 .. $length - 1) {
    my $rand_num = int(rand @{$v1->elements});
    my $rand_element = splice @{$v1->elements}, $rand_num, 1;
    push @v2_elements, $rand_element;
    push @{$v1->elements}, $rand_element if $replace;
  }
  
  return Rstats::ArrayUtil::c(\@v2_elements);
}

sub sequence {
  my $_v1 = shift;
  
  my $v1 = Rstats::ArrayUtil::to_array($_v1);
  my $v1_values = $v1->values;
  
  my @v2_values;
  for my $v1_value (@$v1_values) {
    push @v2_values, Rstats::ArrayUtil::seq(1, $v1_value)->values;
  }
  
  return Rstats::ArrayUtil::c(\@v2_values);
}

sub sin {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(sin $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub sinh {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::sinh $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub sqrt {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(sqrt $_->value) } @{$a1->elements};
  
  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub sort {

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $decreasing = $opt->{decreasing};
  my $_v1 = shift;
  
  my $v1 = Rstats::ArrayUtil::to_array($_v1);
  my $v1_values = $v1->values;
  my $v2_values = $decreasing ? [reverse sort(@$v1_values)] : [sort(@$v1_values)];
  return Rstats::ArrayUtil::c($v2_values);
}

sub tail {

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $v1 = shift;
  
  my $n = $opt->{n};
  $n = 6 unless defined $n;
  
  my $elements1 = $v1->{elements};
  my $max = @{$v1->elements} < $n ? @{$v1->elements} : $n;
  my @elements2;
  for (my $i = 0; $i < $max; $i++) {
    unshift @elements2, $elements1->[@{$v1->elements} - ($i  + 1)];
  }
  
  return $v1->new(elements => \@elements2);
}

sub tan {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::tan $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub tanh {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::tanh $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub TRUE { Rstats::ArrayUtil::c(Rstats::Util::TRUE()) }

sub trunc {
  my ($_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(int $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub unique {
  my $a1 = Rstats::ArrayUtil::to_array(shift);
  
  if (Rstats::ArrayUtil::is_vector($a1)) {
    my $a2_elements = [];
    my $elements_count = {};
    my $na_count;
    for my $a1_element (@{$a1->elements}) {
      if (Rstats::Util::is_na($a1_element)) {
        unless ($na_count) {
          push @$a2_elements, $a1_element;
        }
        $na_count++;
      }
      else {
        my $str = Rstats::Util::to_string($a1_element);
        unless ($elements_count->{$str}) {
          push @$a2_elements, $a1_element;
        }
        $elements_count->{$str}++;
      }
    }

    return Rstats::ArrayUtil::c($a2_elements);
  }
  else {
    return $a1;
  }
}


sub var {
  my $a1 = shift;

  my $var = sum(($a1 - Rstats::ArrayUtil::mean($a1)) ** 2) / (@{$a1->elements} - 1);
  
  return $var;
}

sub which {
  my ($_v1, $cond_cb) = @_;
  
  my $v1 = Rstats::ArrayUtil::to_array($_v1);
  my $v1_values = $v1->values;
  my @v2_values;
  for (my $i = 0; $i < @$v1_values; $i++) {
    local $_ = $v1_values->[$i];
    if ($cond_cb->($v1_values->[$i])) {
      push @v2_values, $i + 1;
    }
  }
  
  return Rstats::ArrayUtil::c(\@v2_values);
}

sub _order {
  my ($asc, $_v1) = @_;
  
  my $v1 = Rstats::ArrayUtil::to_array($_v1);
  my $v1_values = $v1->values;
  
  my @pos_vals;
  push @pos_vals, {pos => $_ + 1, val => $v1_values->[$_]} for (0 .. @$v1_values - 1);
  my @sorted_pos_values = $asc
    ? sort { $a->{val} <=> $b->{val} } @pos_vals
    : sort { $b->{val} <=> $a->{val} } @pos_vals;
  my @orders = map { $_->{pos} } @sorted_pos_values;
  
  return Rstats::ArrayUtil::c(\@orders);
}

sub matrix {
  
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};

  my ($_a1, $nrow, $ncol, $byrow, $dirnames) = @_;

  croak "matrix method need data as frist argument"
    unless defined $_a1;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  # Row count
  $nrow = $opt->{nrow} unless defined $nrow;
  
  # Column count
  $ncol = $opt->{ncol} unless defined $ncol;
  
  # By row
  $byrow = $opt->{byrow} unless defined $byrow;
  
  my $a1_elements = $a1->elements;
  my $a1_length = @$a1_elements;
  if (!defined $nrow && !defined $ncol) {
    $nrow = $a1_length;
    $ncol = 1;
  }
  elsif (!defined $nrow) {
    $nrow = int($a1_length / $ncol);
  }
  elsif (!defined $ncol) {
    $ncol = int($a1_length / $nrow);
  }
  my $length = $nrow * $ncol;
  
  my $dim = [$nrow, $ncol];
  my $matrix;
  if ($byrow) {
    $matrix = Rstats::ArrayUtil::array(
      $a1_elements,
      [$dim->[1], $dim->[0]],
    );
    
    $matrix = Rstats::ArrayUtil::t($matrix);
  }
  else {
    $matrix = Rstats::ArrayUtil::array($a1_elements, $dim);
  }
  
  return $matrix;
}

sub typeof {
  my $array = shift;
  
  my $type = $array->{type};
  my $a1_elements = defined $type ? $type : "NULL";
  my $a1 = Rstats::ArrayUtil::c($a1_elements);
  
  return $a1;
}

sub mode {
  my $array = shift;
  
  if (@_) {
    my $type = $_[0];
    croak qq/Error in eval(expr, envir, enclos) : could not find function "as_$type"/
      unless $types_h{$type};
    
    if ($type eq 'numeric') {
      $array->{type} = 'double';
    }
    else {
      $array->{type} = $type;
    }
    
    return $array;
  }
  else {
    my $type = $array->{type};
    my $mode;
    if (defined $type) {
      if ($type eq 'integer' || $type eq 'double') {
        $mode = 'numeric';
      }
      else {
        $mode = $type;
      }
    }
    else {
      croak qq/could not find function "as_$type"/;
    }

    return Rstats::ArrayUtil::c($mode);
  }
}

sub NA { Rstats::ArrayUtil::c(Rstats::Util::NA()) }

sub NaN { Rstats::ArrayUtil::c(Rstats::Util::NaN()) }

sub inner_product {
  my ($a1, $a2) = @_;
  
  # Convert to matrix
  $a1 = Rstats::ArrayUtil::t(Rstats::ArrayUtil::as_matrix($a1)) if Rstats::ArrayUtil::is_vector($a1);
  $a2 = Rstats::ArrayUtil::as_matrix($a2) if Rstats::ArrayUtil::is_vector($a2);
  
  # Calculate
  if (Rstats::ArrayUtil::is_matrix($a1) && Rstats::ArrayUtil::is_matrix($a2)) {
    
    croak "requires numeric/complex matrix/vector arguments"
      if @{$a1->elements} == 0 || @{$a2->elements} == 0;
    croak "Error in a x b : non-conformable arguments"
      unless Rstats::ArrayUtil::dim($a1)->values->[1] == Rstats::ArrayUtil::dim($a2)->values->[0];
    
    my $row_max = Rstats::ArrayUtil::dim($a1)->values->[0];
    my $col_max = Rstats::ArrayUtil::dim($a2)->values->[1];
    
    my $a3_elements = [];
    for (my $col = 1; $col <= $col_max; $col++) {
      for (my $row = 1; $row <= $row_max; $row++) {
        my $v1 = $a1->get($row);
        my $v2 = $a2->get(Rstats::ArrayUtil::NULL, $col);
        my $v3 = Rstats::ArrayUtil::sum($a1 * $a2);
        push $a3_elements, $v3;
      }
    }
    
    my $a3 = Rstats::ArrayUtil::matrix($a3_elements, $row_max, $col_max);
    
    return $a3;
  }
  else {
    croak "inner_product should be dim < 3."
  }
}

sub row {
  my $array = shift;
  
  my $nrow = Rstats::ArrayUtil::nrow($array)->value;
  my $ncol = Rstats::ArrayUtil::ncol($array)->value;
  
  my @values = (1 .. $nrow) x $ncol;
  
  return Rstats::ArrayUtil::array(\@values, [$nrow, $ncol]);
}

sub sum {
  my $a1 = Rstats::ArrayUtil::to_array(shift);
  
  my $type = $a1->{type};
  my $sum = Rstats::Util::create($type);
  $sum = Rstats::Util::add($sum, $_) for @{$a1->elements};
  
  return Rstats::ArrayUtil::c($sum);
}

sub col {
  my $array = shift;
  
  my $nrow = Rstats::ArrayUtil::nrow($array)->value;
  my $ncol = Rstats::ArrayUtil::ncol($array)->value;
  
  my @values;
  for my $col (1 .. $ncol) {
    push @values, ($col) x $nrow;
  }
  
  return Rstats::ArrayUtil::array(\@values, [$nrow, $ncol]);
}

sub nrow {
  my $array = shift;
  
  return Rstats::ArrayUtil::array(Rstats::ArrayUtil::dim($array)->values->[0]);
}

sub ncol {
  my $array = shift;
  
  return Rstats::ArrayUtil::array(Rstats::ArrayUtil::dim($array)->values->[1]);
}

sub names {
  my $array = shift;
  
  if (@_) {
    my $_names = shift;
    my $names;
    if (ref $_names eq 'Rstats::Array') {
      $names = $_names->elements;
    }
    elsif (!defined $_names) {
      $names = [];
    }
    elsif (ref $_names eq 'ARRAY') {
      $names = $_names;
    }
    else {
      $names = [$_names];
    }
    
    my $duplication = {};
    for my $name (@$names) {
      croak "Don't use same name in names arguments"
        if $duplication->{$name};
      $duplication->{$name}++;
    }
    $array->{names} = $names;
  }
  else {
    $array->{names} = [] unless exists $array->{names};
    return Rstats::ArrayUtil::array($array->{names});
  }
}

sub colnames {
  my $array = shift;
  
  if (@_) {
    my $_colnames = shift;
    my $colnames;
    if (ref $_colnames eq 'Rstats::Array') {
      $colnames = $_colnames->elements;
    }
    elsif (!defined $_colnames) {
      $colnames = [];
    }
    elsif (ref $_colnames eq 'ARRAY') {
      $colnames = $_colnames;
    }
    else {
      $colnames = [$_colnames];
    }
    
    my $duplication = {};
    for my $name (@$colnames) {
      croak "Don't use same name in colnames arguments"
        if $duplication->{$name};
      $duplication->{$name}++;
    }
    $array->{colnames} = $colnames;
  }
  else {
    $array->{colnames} = [] unless exists $array->{colnames};
    return Rstats::ArrayUtil::array($array->{colnames});
  }
}

sub rownames {
  my $array = shift;
  
  if (@_) {
    my $_rownames = shift;
    my $rownames;
    if (ref $_rownames eq 'Rstats::Array') {
      $rownames = $_rownames->elements;
    }
    elsif (!defined $_rownames) {
      $rownames = [];
    }
    elsif (ref $_rownames eq 'ARRAY') {
      $rownames = $_rownames;
    }
    else {
      $rownames = [$_rownames];
    }
    
    my $duplication = {};
    for my $name (@$rownames) {
      croak "Don't use same name in rownames arguments"
        if $duplication->{$name};
      $duplication->{$name}++;
    }
    $array->{rownames} = $rownames;
  }
  else {
    $array->{rownames} = [] unless exists $array->{rownames};
    return Rstats::ArrayUtil::array($array->{rownames});
  }
}

sub dim {
  my $array = shift;
  
  if (@_) {
    my $a1 = $_[0];
    if (ref $a1 eq 'Rstats::Array') {
      $array->{dim} = $a1->elements;
    }
    elsif (ref $a1 eq 'ARRAY') {
      $array->{dim} = $a1;
    }
    elsif(!ref $a1) {
      $array->{dim} = [$a1];
    }
    else {
      croak "Invalid elements is passed to dim argument";
    }
  }
  else {
    $array->{dim} = [] unless exists $array->{dim};
    return Rstats::ArrayUtil::c($array->{dim});
  }
}

sub length {
  my $array = shift;
  
  my $length = @{$array->elements};
  
  return Rstats::ArrayUtil::c($length);
}

sub seq {
  
  # Option
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  # Along
  my $_along = $opt->{along};
  if ($_along) {
    my $along = Rstats::ArrayUtil::to_array($_along);
    my $length = @{$along->elements};
    return Rstats::ArrayUtil::seq(1,$length);
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
    
    return Rstats::ArrayUtil::c($elements);
  }
}

sub c {
  my @elements_tmp1 = @_;
  
  # Fix elements
  my $elements_tmp2;
  if (@elements_tmp1 == 0) {
    return Rstats::ArrayUtil::NULL();
  }
  elsif (@elements_tmp1 > 1) {
    $elements_tmp2 = \@elements_tmp1;
  }
  else {
    $elements_tmp2 = $elements_tmp1[0];
  }

  my $elements = [];
  if (defined $elements_tmp2) {
    if (ref $elements_tmp2 eq 'ARRAY') {
      for my $element (@$elements_tmp2) {
        if (ref $element eq 'ARRAY') {
          push @$elements, @$element;
        }
        elsif (ref $element eq 'Rstats::Array') {
          push @$elements, @{$element->elements};
        }
        else {
          push @$elements, $element;
        }
      }
    }
    elsif (ref $elements_tmp2 eq 'Rstats::Array') {
      $elements = $elements_tmp2->elements;
    }
    else {
      $elements = [$elements_tmp2];
    }
  }
  else {
    croak "Invalid first argument";
  }
  
  # Check elements
  my $mode_h = {};
  for my $element (@$elements) {
    next if Rstats::Util::is_na($element);
    
    if (Rstats::Util::is_character($element)) {
      $mode_h->{character}++;
    }
    elsif (Rstats::Util::is_complex($element)) {
      $mode_h->{complex}++;
    }
    elsif (Rstats::Util::is_double($element)) {
      $mode_h->{double}++;
    }
    elsif (Rstats::Util::is_integer($element)) {
      $element = Rstats::Util::double($element->value);
      $mode_h->{double}++;
    }
    elsif (Rstats::Util::is_logical($element)) {
      $mode_h->{logical}++;
    }
    elsif (Rstats::Util::is_perl_number($element)) {
      $element = Rstats::Util::double($element);
      $mode_h->{double}++;
    }
    else {
      $element = Rstats::Util::character("$element");
      $mode_h->{character}++;
    }
  }

  # Array
  my $array = Rstats::ArrayUtil::NULL();
  $array->elements($elements);

  # Upgrade elements and type
  my @modes = keys %$mode_h;
  if (@modes > 1) {
    if ($mode_h->{character}) {
      $array = Rstats::ArrayUtil::as_character($array);
    }
    elsif ($mode_h->{complex}) {
      $array = Rstats::ArrayUtil::as_complex($array);
    }
    elsif ($mode_h->{double}) {
      $array = Rstats::ArrayUtil::as_double($array);
    }
  }
  else {
    Rstats::ArrayUtil::mode($array => $modes[0] || 'logical');
  }
  
  return $array;
}

sub C {
  my $seq_str = shift;

  my $by;
  my $mode;
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
  
  my $vector = Rstats::ArrayUtil::seq({from => $from, to => $to, by => $by});
  
  return $vector;
}

sub dim_as_array {
  my $array = shift;
  
  if (@{$array->{dim}}) {
    return Rstats::ArrayUtil::dim($array);
  }
  else {
    my $length = @{$array->elements};
    return Rstats::ArrayUtil::c($length);
  }
}

sub is_numeric {
  my $array = shift;
  
  my $is = ($array->{type} || '') eq 'double' || ($array->{type} || '') eq 'integer'
    ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return Rstats::ArrayUtil::c($is);
}

sub is_double {
  my $array = shift;
  
  my $is = ($array->{type} || '') eq 'double' ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return Rstats::ArrayUtil::c($is);
}

sub is_integer {
  my $array = shift;
  
  my $is = ($array->{type} || '') eq 'integer' ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return Rstats::ArrayUtil::c($is);
}

sub is_complex {
  my $array = shift;
  
  my $is = ($array->{type} || '') eq 'complex' ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return Rstats::ArrayUtil::c($is);
}

sub is_character {
  my $array = shift;
  
  my $is = ($array->{type} || '') eq 'character' ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return Rstats::ArrayUtil::c($is);
}

sub is_logical {
  my $array = shift;
  
  my $is = ($array->{type} || '') eq 'logical' ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return Rstats::ArrayUtil::c($is);
}

sub as {
  my ($array, $mode) = @_;
  
  if ($mode eq 'character') {
    return Rstats::ArrayUtil::as_character($array);
  }
  elsif ($mode eq 'complex') {
    return Rstats::ArrayUtil::as_complex($array);
  }
  elsif ($mode eq 'double') {
    return Rstats::ArrayUtil::as_double($array);
  }
  elsif ($mode eq 'numeric') {
    return Rstats::ArrayUtil::as_numeric($array);
  }
  elsif ($mode eq 'integer') {
    return Rstats::ArrayUtil::as_integer($array);
  }
  elsif ($mode eq 'logical') {
    return Rstats::ArrayUtil::as_logical($array);
  }
  else {
    croak "Invalid mode is passed";
  }
}

sub as_complex {
  my $array = shift;
  
  my $a1 = $array;
  my $a1_elements = $a1->elements;
  my $a2 = $a1->clone_without_elements;
  my @a2_elements = map {
    if (Rstats::Util::is_na($_)) {
      $_;
    }
    elsif (Rstats::Util::is_character($_)) {
      my $z = Rstats::Util::looks_like_complex($_->value);
      if (defined $z) {
        Rstats::Util::complex($z->{re}, $z->{im});
      }
      else {
        carp 'NAs introduced by coercion';
        Rstats::Util::NA;
      }
    }
    elsif (Rstats::Util::is_complex($_)) {
      $_;
    }
    elsif (Rstats::Util::is_double($_)) {
      if (Rstats::Util::is_nan($_)) {
        Rstats::Util::NA;
      }
      else {
        Rstats::Util::complex_double($_, Rstats::Util::double(0));
      }
    }
    elsif (Rstats::Util::is_integer($_)) {
      Rstats::Util::complex($_->value, 0);
    }
    elsif (Rstats::Util::is_logical($_)) {
      Rstats::Util::complex($_->value ? 1 : 0, 0);
    }
    else {
      croak "unexpected type";
    }
  } @$a1_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'complex';

  return $a2;
}

sub as_numeric { as_double(@_) }

sub as_double {
  my $array = shift;
  
  my $a1 = $array;
  my $a1_elements = $a1->elements;
  my $a2 = $a1->clone_without_elements;
  my @a2_elements = map {
    if (Rstats::Util::is_na($_)) {
      $_;
    }
    elsif (Rstats::Util::is_character($_)) {
      if (my $num = Rstats::Util::looks_like_number($_->value)) {
        Rstats::Util::double($num + 0);
      }
      else {
        carp 'NAs introduced by coercion';
        Rstats::Util::NA;
      }
    }
    elsif (Rstats::Util::is_complex($_)) {
      carp "imaginary parts discarded in coercion";
      Rstats::Util::double($_->re->value);
    }
    elsif (Rstats::Util::is_double($_)) {
      $_;
    }
    elsif (Rstats::Util::is_integer($_)) {
      Rstats::Util::double($_->value);
    }
    elsif (Rstats::Util::is_logical($_)) {
      Rstats::Util::double($_->value ? 1 : 0);
    }
    else {
      croak "unexpected type";
    }
  } @$a1_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'double';

  return $a2;
}

sub as_integer {
  my $array = shift;
  
  my $a1 = $array;
  my $a1_elements = $a1->elements;
  my $a2 = $a1->clone_without_elements;
  my @a2_elements = map {
    if (Rstats::Util::is_na($_)) {
      $_;
    }
    elsif (Rstats::Util::is_character($_)) {
      if (my $num = Rstats::Util::looks_like_number($_->value)) {
        Rstats::Util::integer(int $num);
      }
      else {
        carp 'NAs introduced by coercion';
        Rstats::Util::NA;
      }
    }
    elsif (Rstats::Util::is_complex($_)) {
      carp "imaginary parts discarded in coercion";
      Rstats::Util::integer(int($_->re->value));
    }
    elsif (Rstats::Util::is_double($_)) {
      if (Rstats::Util::is_nan($_) || Rstats::Util::is_infinite($_)) {
        Rstats::Util::NA;
      }
      else {
        Rstats::Util::integer($_->value);
      }
    }
    elsif (Rstats::Util::is_integer($_)) {
      $_; 
    }
    elsif (Rstats::Util::is_logical($_)) {
      Rstats::Util::integer($_->value ? 1 : 0);
    }
    else {
      croak "unexpected type";
    }
  } @$a1_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'integer';

  return $a2;
}

sub as_logical {
  my $array = shift;
  
  my $a1 = $array;
  my $a1_elements = $a1->elements;
  my $a2 = $a1->clone_without_elements;
  my @a2_elements = map {
    if (Rstats::Util::is_na($_)) {
      $_;
    }
    elsif (Rstats::Util::is_character($_)) {
      Rstats::Util::NA;
    }
    elsif (Rstats::Util::is_complex($_)) {
      carp "imaginary parts discarded in coercion";
      my $re = $_->re->value;
      my $im = $_->im->value;
      if (defined $re && $re == 0 && defined $im && $im == 0) {
        Rstats::Util::FALSE;
      }
      else {
        Rstats::Util::TRUE;
      }
    }
    elsif (Rstats::Util::is_double($_)) {
      if (Rstats::Util::is_nan($_)) {
        Rstats::Util::NA;
      }
      elsif (Rstats::Util::is_infinite($_)) {
        Rstats::Util::TRUE;
      }
      else {
        $_->value == 0 ? Rstats::Util::FALSE : Rstats::Util::TRUE;
      }
    }
    elsif (Rstats::Util::is_integer($_)) {
      $_->value == 0 ? Rstats::Util::FALSE : Rstats::Util::TRUE;
    }
    elsif (Rstats::Util::is_logical($_)) {
      $_->value == 0 ? Rstats::Util::FALSE : Rstats::Util::TRUE;
    }
    else {
      croak "unexpected type";
    }
  } @$a1_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'logical';

  return $a2;
}

sub as_character {
  my $a1 = shift;

  my $a1_elements = $a1->elements;
  my $a2 = $a1->clone_without_elements;
  my @a2_elements = map {
    Rstats::Util::character(Rstats::Util::to_string($_))
  } @$a1_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'character';

  return $a2;
}

sub numeric {
  my $num = shift;
  
  return Rstats::ArrayUtil::c((0) x $num);
}

sub to_array {
  my $_array = shift;
  
  my $array
   = !defined $_array ? Rstats::ArrayUtil::NULL
   : ref $_array eq 'Rstats::Array' ? $_array
   : Rstats::ArrayUtil::c($_array);
  
  return $array;
}

sub parse_index {
  my ($array, $drop, @_indexs) = @_;
  
  my $a1_dim = Rstats::ArrayUtil::dim_as_array($array)->values;
  my @indexs;
  my @a2_dim;
  
  for (my $i = 0; $i < @$a1_dim; $i++) {
    my $_index = $_indexs[$i];
    
    my $index = Rstats::ArrayUtil::to_array($_index);
    my $index_values = $index->values;
    if (@$index_values && !Rstats::ArrayUtil::is_character($index) && !Rstats::ArrayUtil::is_logical($index)) {
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
      $index = Rstats::ArrayUtil::array($index_values_new);
    }
    elsif (Rstats::ArrayUtil::is_character($index)) {
      if (Rstats::ArrayUtil::is_vector($array)) {
        my $index_new_values = [];
        for my $name (@{$index->values}) {
          my $i = 0;
          my $value;
          for my $array_name (@{Rstats::ArrayUtil::names($array)->values}) {
            if ($name eq $array_name) {
              $value = $array->values->[$i];
              last;
            }
            $i++;
          }
          croak "Can't find name" unless defined $value;
          push @$index_new_values, $value;
        }
        $indexs[$i] = Rstats::ArrayUtil::array($index_new_values);
      }
      elsif (Rstats::ArrayUtil::is_matrix($array)) {
        
      }
      else {
        croak "Can't support name except vector and matrix";
      }
    }
    elsif (Rstats::ArrayUtil::is_logical($index)) {
      my $index_values_new = [];
      for (my $i = 0; $i < @{$index->values}; $i++) {
        push @$index_values_new, $i + 1 if Rstats::Util::bool($index->elements->[$i]);
      }
      $index = Rstats::ArrayUtil::array($index_values_new);
    }
    elsif ($index->{_minus}) {
      my $index_value_new = [];
      
      for my $k (1 .. $a1_dim->[$i]) {
        push @$index_value_new, $k unless grep { $_ == -$k } @{$index->values};
      }
      $index = Rstats::ArrayUtil::array($index_value_new);
    }

    push @indexs, $index;

    my $count = @{$index->elements};
    push @a2_dim, $count unless $count == 1 && $drop;
  }
  @a2_dim = (1) unless @a2_dim;
  
  my $index_values = [map { $_->values } @indexs];
  my $ords = Rstats::ArrayUtil::cross_product($index_values);
  my @positions = map { Rstats::ArrayUtil::pos($_, $a1_dim) } @$ords;
  
  return (\@positions, \@a2_dim);
}

sub cross_product {
  my $values = shift;

  my @idxs = (0) x @$values;
  my @idx_idx = 0..(@idxs - 1);
  my @array = map { $_->[0] } @$values;
  my $result = [];
  
  push @$result, [@array];
  my $end_loop;
  while (1) {
    foreach my $i (@idx_idx) {
      if( $idxs[$i] < @{$values->[$i]} - 1 ) {
        $array[$i] = $values->[$i][++$idxs[$i]];
        push @$result, [@array];
        last;
      }
      
      if ($i == $idx_idx[-1]) {
        $end_loop = 1;
        last;
      }
      
      $idxs[$i] = 0;
      $array[$i] = $values->[$i][0];
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

sub t {
  my $m1 = shift;
  
  my $m1_row = Rstats::ArrayUtil::dim($m1)->values->[0];
  my $m1_col = Rstats::ArrayUtil::dim($m1)->values->[1];
  
  my $m2 = Rstats::ArrayUtil::matrix(0, $m1_col, $m1_row);
  
  for my $row (1 .. $m1_row) {
    for my $col (1 .. $m1_col) {
      my $element = $m1->element($row, $col);
      $m2->at($col, $row);
      $m2->set($element);
    }
  }
  
  return $m2;
}

sub is_array {
  my $array = shift;
  
  return Rstats::ArrayUtil::c(Rstats::Util::TRUE());
}

sub is_vector {
  my $array = shift;
  
  my $is = @{Rstats::ArrayUtil::dim($array)->elements} == 0 ? Rstats::Util::TRUE() : Rstats::Util::FALSE();
  
  return Rstats::ArrayUtil::c($is);
}

sub is_matrix {
  my $array = shift;

  my $is = @{Rstats::ArrayUtil::dim($array)->elements} == 2 ? Rstats::Util::TRUE() : Rstats::Util::FALSE();
  
  return Rstats::ArrayUtil::c($is);
}

sub as_matrix {
  my $array = shift;
  
  my $a1_dim_elements = Rstats::ArrayUtil::dim_as_array($array)->values;
  my $a1_dim_count = @$a1_dim_elements;
  my $a2_dim_elements = [];
  my $row;
  my $col;
  if ($a1_dim_count == 2) {
    $row = $a1_dim_elements->[0];
    $col = $a1_dim_elements->[1];
  }
  else {
    $row = 1;
    $row *= $_ for @$a1_dim_elements;
    $col = 1;
  }
  
  my $a2_elements = [@{$array->elements}];
  
  return Rstats::ArrayUtil::matrix($a2_elements, $row, $col);
}

sub as_array {
  my $array = shift;
  
  my $a1_elements = [@{$array->elements}];
  my $a1_dim_elements = [@{Rstats::ArrayUtil::dim_as_array($array)->values}];
  
  return $array->array($a1_elements, $a1_dim_elements);
}

sub as_vector {
  my $array = shift;
  
  my $a1_elements = [@{$array->elements}];
  
  return Rstats::ArrayUtil::c($a1_elements);
}

sub upgrade_mode {
  my (@arrays) = @_;
  
  # Check elements
  my $mode_h = {};
  for my $array (@arrays) {
    my $type = $array->{type} || '';
    if ($type eq 'character') {
      $mode_h->{character}++;
    }
    elsif ($type eq 'complex') {
      $mode_h->{complex}++;
    }
    elsif ($type eq 'double') {
      $mode_h->{double}++;
    }
    elsif ($type eq 'integer') {
      $mode_h->{integer}++;
    }
    elsif ($type eq 'logical') {
      $mode_h->{logical}++;
    }
    else {
      croak "Invalid mode";
    }
  }

  # Upgrade elements and type if mode is different
  my @modes = keys %$mode_h;
  if (@modes > 1) {
    my $to_mode;
    if ($mode_h->{character}) {
      $to_mode = 'character';
    }
    elsif ($mode_h->{complex}) {
      $to_mode = 'complex';
    }
    elsif ($mode_h->{double}) {
      $to_mode = 'double';
    }
    elsif ($mode_h->{integer}) {
      $to_mode = 'integer';
    }
    elsif ($mode_h->{logical}) {
      $to_mode = 'logical';
    }
    $_ = Rstats::ArrayUtil::as($_ => $to_mode) for @arrays;
  }
  
  return @arrays;
}

1;
