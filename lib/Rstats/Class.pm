package Rstats::Class;

use Object::Simple -base;

use List::Util;
use Math::Trig ();
use Carp 'croak';
use POSIX ();;
use Math::Round ();
require Rstats::Util;
require Rstats::Array;

# TODO
#   logp1x
#   gamma
#   lgamma
#   complete_cases

{
  no strict 'refs';
  my @methods = qw/
    as_array,
    as_character
    as_complex
    as_integer
    as_logical
    as_matrix
    as_numeric
    as_vector
    c
    C
    col
    colnames
    dim
    is_array
    is_complex
    is_matrix
    is_numeric
    is_double
    is_integer
    is_logical
    is_vector
    length
    NA
    names
    NaN
    ncol
    nrow
    NULL
    numeric
    row
    rownames
    seq
  /;
  for my $method (@methods) {
    *{"Rstats::Class::$method"} = sub {
      my $self = shift;
      
      my $function = "Rstats::ArrayUtil::$method";
      return &$function(@_);
    };
  }
}

sub abs {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(abs $_->value) } @{$a1->elements};
  
  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub acos {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::acos $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub acosh {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::acosh $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub append {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $v1 = shift;
  my $element = shift;
  
  my $after = $opt->{after};
  $after = Rstats::Util::length($v1) unless defined $after;
  
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
  my $self = shift;
  
  return Rstats::ArrayUtil::array(@_);
}

sub asin {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::asin $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub asinh {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::asinh $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub atan {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::atan $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub atanh {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::atanh($_->value)) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub cbind {
  my ($self, @arrays) = @_;
  
  my $row_count_needed;
  my $col_count_total;
  my $a2_elements = [];
  for my $_a (@arrays) {
    
    my $a = Rstats::ArrayUtil::to_array($_a);
    
    my $row_count;
    if ($a->is_matrix) {
      $row_count = Rstats::ArrayUtil::dim($a)->elements->[0];
      $col_count_total += Rstats::ArrayUtil::dim($a)->elements->[1];
    }
    elsif ($a->is_vector) {
      $row_count = $a->_real_dim_values->[0];
      $col_count_total += 1;
    }
    else {
      croak "cbind or rbind can only receive matrix and vector";
    }
    
    $row_count_needed = $row_count unless defined $row_count_needed;
    croak "Row count is different" if $row_count_needed ne $row_count;
    
    push @$a2_elements, $a->elements;
  }
  my $matrix = $self->matrix($a2_elements, $row_count_needed, $col_count_total);
  
  return $matrix;
}

sub ceiling {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  my @a2_elements = map { Rstats::Util::double(POSIX::ceil $_->value) } @{$a1->elements};
  
  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub colMeans {
  my ($self, $m1) = @_;
  
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
  my ($self, $m1) = @_;
  
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
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(cos $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub cosh {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::cosh $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub cumsum {
  my ($self, $_v1) = @_;
  
  my $v1 = Rstats::ArrayUtil::to_array($_v1);
  my @v2_values;
  my $total = 0;
  push @v2_values, $total = $total + $_ for @{$v1->values};
  
  return Rstats::ArrayUtil::c(\@v2_values);
}

sub complex {
  my ($self, $re, $im) = @_;
  
  return Rstats::ArrayUtil::c([Rstats::Util::complex($re, $im)]);
}

sub exp {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(exp $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub expm1 {
  my ($self, $_a1) = @_;
  
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

sub FALSE { shift->c(Rstats::Util::FALSE()) }

sub floor {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(POSIX::floor $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub head {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $v1 = shift;
  
  my $n = $opt->{n};
  $n = 6 unless defined $n;
  
  my $elements1 = $v1->{elements};
  my $max = Rstats::Util::length($v1) < $n ? Rstats::Util::length($v1) : $n;
  my @elements2;
  for (my $i = 0; $i < $max; $i++) {
    push @elements2, $elements1->[$i];
  }
  
  return $v1->new(elements => \@elements2);
}

sub i {
  my $self = shift;
  
  my $i = Rstats::Util::complex(0, 1);
  
  return Rstats::ArrayUtil::c($i);
}

sub ifelse {
  my ($self, $_v1, $value1, $value2) = @_;
  
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
  
  return $self->array(\@v2_values);
}

sub Inf { shift->c(Rstats::Util::Inf()) }

sub is_finite {
  my ($self, $_a1) = @_;

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
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map {
    ref $_ eq 'Rstats::Inf' ? Rstats::Util::TRUE() : Rstats::Util::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::ArrayUtil::array(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'logical');

  return $a1->clone_without_elements(elements => \@a2_elements);
}

sub is_na {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map {
    ref $_ eq  'Rstats::Type::NA' ? Rstats::Util::TRUE() : Rstats::Util::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::ArrayUtil::array(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'logical');
  
  return $a2;
}

sub is_nan {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map {
    ref $_ eq  'Rstats::NaN' ? Rstats::Util::TRUE() : Rstats::Util::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::ArrayUtil::array(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'logical');
  
  return $a2;
}

sub is_null {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = [!@$a1->elements ? Rstats::Util::TRUE() : Rstats::Util::FALSE()];
  my $a2 = Rstats::ArrayUtil::array(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'logical');
  
  return $a2;
}

sub log {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(log $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub logb { shift->log(@_) }

sub log2 {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(CORE::log $_->value / CORE::log 2) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub log10 {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(CORE::log $_->value / CORE::log 10) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
}

sub matrix {
  my $self = shift;
  
  return Rstats::ArrayUtil::matrix(@_);
}

sub max {
  my ($self, @vs) = @_;
  
  my @all_values = map { @{$_->values} } @vs;
  my $max = List::Util::max(@all_values);
  return $max;
}

sub mean {
  my ($self, $data) = @_;
  
  my $v = $data;
  my $mean = $self->sum($v)->value / $self->length($v);
  
  return Rstats::ArrayUtil::c($mean);
}

sub min {
  my ($self, @vs) = @_;
  
  my @all_values = map { @{$_->values} } @vs;
  my $min = List::Util::min(@all_values);
  return $min;
}

sub order { shift->_order(1, @_) }

sub paste {
  my $self = shift;

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
  my ($self, @vs) = @_;
  
  my @maxs;
  for my $v (@vs) {
    my $values = $v->values;
    for (my $i = 0; $i <@$values; $i++) {
      $maxs[$i] = $values->[$i]
        if !defined $maxs[$i] || $values->[$i] > $maxs[$i]
    }
  }
  
  my $v_max = Rstats::ArrayUtil::c(\@maxs);
  
  return $v_max;
}

sub pmin {
  my ($self, @vs) = @_;
  
  my @mins;
  for my $v (@vs) {
    my $values = $v->values;
    for (my $i = 0; $i <@$values; $i++) {
      $mins[$i] = $values->[$i]
        if !defined $mins[$i] || $values->[$i] < $mins[$i]
    }
  }
  
  my $v_min = Rstats::ArrayUtil::c(\@mins);
  
  return $v_min;
}

sub prod {
  my ($self, $v1) = @_;
  
  my $v1_values = $v1->values;
  my $prod = List::Util::product(@$v1_values);
  return Rstats::ArrayUtil::c($prod);
}

sub set_seed {
  my ($self, $seed) = @_;
  
  $self->{seed} = $seed;
}

sub range {
  my ($self, $array) = @_;
  
  my $min = $self->min($array);
  my $max = $self->max($array);
  
  return Rstats::ArrayUtil::c([$min, $max]);
}

sub rbind {
  my ($self, @arrays) = @_;
  
  my $matrix = $self->cbind(@arrays);
  
  return $self->t($matrix);
}

sub rep {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  my $v1 = shift;
  my $times = $opt->{times} || 1;
  
  my $elements = [];
  push @$elements, @{$v1->elements} for 1 .. $times;
  my $v2 = Rstats::ArrayUtil::c($elements);
  
  return $v2;
}

sub replace {
  my ($self, $_v1, $_v2, $_v3) = @_;
  
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
  
  return $self->array($v4_values);
}

sub rev { shift->_order(0, @_) }

sub rnorm {
  my $self = shift;
  
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
  my $self = shift;

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
  my ($self, $m1) = @_;
  
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
  my ($self, $m1) = @_;
  
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
  my ($self, $count, $min, $max) = @_;
  
  $min = 0 unless defined $min;
  $max = 1 unless defined $max;
  croak "runif third argument must be bigger than second argument"
    if $min > $max;
  
  my $diff = $max - $min;
  my @v1_elements;
  if (defined $self->{seed}) {
    srand $self->{seed};
    $self->{seed} = undef;
  }
  for (1 .. $count) {
    my $rand = rand($diff) + $min;
    push @v1_elements, $rand;
  }
  
  return Rstats::ArrayUtil::c(\@v1_elements);
}

# TODO: prob option
sub sample {
  my $self = shift;
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  my ($_v1, $length) = @_;
  my $v1 = Rstats::ArrayUtil::to_array($_v1);
  
  # Replace
  my $replace = $opt->{replace};
  
  my $v1_length = $self->length($v1);
  $length = $v1_length unless defined $length;
  
  croak "second argument element must be bigger than first argument elements count when you specify 'replace' option"
    if $length > $v1_length && !$replace;
  
  my @v2_elements;
  for my $i (0 .. $length - 1) {
    my $rand_num = int(rand $self->length($v1));
    my $rand_element = splice @{$v1->elements}, $rand_num, 1;
    push @v2_elements, $rand_element;
    push @{$v1->elements}, $rand_element if $replace;
  }
  
  return Rstats::ArrayUtil::c(\@v2_elements);
}

sub sequence {
  my ($self, $_v1) = @_;
  
  my $v1 = Rstats::ArrayUtil::to_array($_v1);
  my $v1_values = $v1->values;
  
  my @v2_values;
  for my $v1_value (@$v1_values) {
    push @v2_values, Rstats::ArrayUtil::seq(1, $v1_value)->values;
  }
  
  return Rstats::ArrayUtil::c(\@v2_values);
}

sub sin {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(sin $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub sinh {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::sinh $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub sqrt {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(sqrt $_->value) } @{$a1->elements};
  
  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub sort {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $decreasing = $opt->{decreasing};
  my $_v1 = shift;
  
  my $v1 = Rstats::ArrayUtil::to_array($_v1);
  my $v1_values = $v1->values;
  my $v2_values = $decreasing ? [reverse sort(@$v1_values)] : [sort(@$v1_values)];
  return Rstats::ArrayUtil::c($v2_values);
}

sub sum {
  my ($self, $_v1) = @_;
  
  my $v1 = Rstats::ArrayUtil::to_array($_v1);
  my $v1_values = $v1->values;
  my $sum = List::Util::sum(@$v1_values);
  return Rstats::ArrayUtil::c($sum);
}

sub t {
  my $self = shift;
  
  return Rstats::ArrayUtil::t(@_);
}

sub tail {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $v1 = shift;
  
  my $n = $opt->{n};
  $n = 6 unless defined $n;
  
  my $elements1 = $v1->{elements};
  my $max = $self->length($v1) < $n ? $self->length($v1) : $n;
  my @elements2;
  for (my $i = 0; $i < $max; $i++) {
    unshift @elements2, $elements1->[$self->length($v1) - ($i  + 1)];
  }
  
  return $v1->new(elements => \@elements2);
}

sub tan {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::tan $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub tanh {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(Math::Trig::tanh $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub TRUE { shift->c(Rstats::Util::TRUE()) }

sub trunc {
  my ($self, $_a1) = @_;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(int $_->value) } @{$a1->elements};

  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  Rstats::ArrayUtil::mode($a2 => 'double');
  
  return $a2;
}

sub var {
  my ($self, $v1) = @_;

  my $var = $self->sum(($v1 - $self->mean($v1)) ** 2)->value
    / ($self->length($v1) - 1);
  
  return Rstats::ArrayUtil::c($var);
}

sub which {
  my ($self, $_v1, $cond_cb) = @_;
  
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
  my ($self, $asc, $_v1) = @_;
  
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

1;

=head1 NAME

Rstats::Class - Rstats class interface

=head1 SYNOPSYS
  
  use Rstats::Class;
  my $r = Rstats::Class->new;
  
  # Array
  my $v1 = $r->c([1, 2, 3]);
  my $v2 = $r->c([2, 3, 4]);
  my $v3 = $v1 + v2;
  print $v3;
