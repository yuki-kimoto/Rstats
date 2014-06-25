package Rstats;

our $VERSION = '0.01';

use Object::Simple -base;

use List::Util;
use Math::Trig ();
use Carp 'croak';
use Rstats;
use Rstats::Array;
use Rstats::Complex;

sub rowSums {
  my ($self, $m1) = @_;
  
  my $dim_values = $m1->_current_dim_values;
  if (@$dim_values == 2) {
    my $v1_values = [];
    for my $col (1 .. $dim_values->[1]) {
      my $v1_value = 0;
      $v1_value += $m1->value($_, $col) for (1 .. $dim_values->[0]);
      push @$v1_values, $v1_value;
    }
    return $self->c($v1_values);
  }
  else {
    croak "Can't culculate rowSums";
  }
}

sub colSums {
  my ($self, $m1) = @_;
  
  my $dim_values = $m1->_current_dim_values;
  if (@$dim_values == 2) {
    my $v1_values = [];
    for my $row (1 .. $dim_values->[0]) {
      my $v1_value = 0;
      $v1_value += $m1->value($row, $_) for (1 .. $dim_values->[1]);
      push @$v1_values, $v1_value;
    }
    return $self->c($v1_values);
  }
  else {
    croak "Can't culculate colSums";
  }
}

sub rowMeans {
  
}

sub colMeans {
  
}

sub row {
  my ($self, $m) = @_;
  
  return $m->row;
}

sub col {
  my ($self, $m) = @_;
  
  return $m->col;
}

sub nrow {
  my ($self, $m) = @_;
  
  return $m->nrow;
}

sub ncol {
  my ($self, $m) = @_;
  
  return $m->ncol;
}

sub t {
  my ($self, $m1) = @_;
  
  my $m1_row = $m1->dim->values->[0];
  my $m1_col = $m1->dim->values->[1];
  
  my $m2 = $self->matrix(0, $m1_col, $m1_row);
  
  for my $row (1 .. $m1_row) {
    for my $col (1 .. $m1_col) {
      my $value = $m1->value($row, $col);
      $m2->at($col, $row)->set($value);
    }
  }
  
  return $m2;
}

sub cumsum {
  my ($self, $_v1) = @_;
  
  my $v1 = $self->_v($_v1);
  my $v1_values = $v1->values;
  my @v2_values;
  my $total = 0;
  push @v2_values, $total = $total + $_ for (@$v1_values);
  
  return $self->c(\@v2_values);
}

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
  my @v1_values;
  for (1 .. $count) {
    my ($rand1, $rand2) = (rand, rand);
    while ($rand1 == 0) { $rand1 = rand(); }
    
    my $rnorm = ($sd * sqrt(-2 * log($rand1))
      * sin(2 * Math::Trig::pi * $rand2))
      + $mean;
    
    push @v1_values, $rnorm;
  }
  
  return $self->c(\@v1_values);
}

sub sequence {
  my ($self, $_v1) = @_;
  
  my $v1 = $self->_v($_v1);
  my $v1_values = $v1->values;
  
  my @v2_values;
  for my $v1_value (@$v1_values) {
    push @v2_values, $self->seq($v1_value)->values;
  }
  
  return $self->c(\@v2_values);
}

# TODO: prob option
sub sample {
  my $self = shift;
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  my ($_v1, $length) = @_;
  my $v1 = $self->_v($_v1);
  
  # Replace
  my $replace = $opt->{replace};
  
  my $v1_length = $self->length($v1);
  $length = $v1_length unless defined $length;
  
  croak "second argument value must be bigger than first argument elements count when you specify 'replace' option"
    if $length > $v1_length && !$replace;
  
  my @v2_values;
  for my $i (0 .. $length - 1) {
    my $rand_num = int(rand $self->length($v1));
    my $rand_value = splice @{$v1->values}, $rand_num, 1;
    push @v2_values, $rand_value;
    push @{$v1->values}, $rand_value if $replace;
  }
  
  return $self->c(\@v2_values);
}

sub NULL {
  my $self = shift;
  
  return Rstats::Array->NULL;
}

sub _v {
  my $self = shift;
  
  return Rstats::Array->_v(@_);
}

sub order { shift->_order(1, @_) }
sub rev { shift->_order(0, @_) }

sub _order {
  my ($self, $asc, $_v1) = @_;
  
  my $v1 = $self->_v($_v1);
  my $v1_values = $v1->values;
  
  my @pos_vals;
  push @pos_vals, {pos => $_ + 1, val => $v1_values->[$_]} for (0 .. @$v1_values - 1);
  my @sorted_pos_values = $asc
    ? sort { $a->{val} <=> $b->{val} } @pos_vals
    : sort { $b->{val} <=> $a->{val} } @pos_vals;
  my @orders = map { $_->{pos} } @sorted_pos_values;
  
  return $self->c(\@orders);
}

sub which {
  my ($self, $_v1, $cond_cb) = @_;
  
  my $v1 = $self->_v($_v1);
  my $v1_values = $v1->values;
  my @v2_values;
  for (my $i = 0; $i < @$v1_values; $i++) {
    local $_ = $v1_values->[$i];
    if ($cond_cb->($v1_values->[$i])) {
      push @v2_values, $i + 1;
    }
  }
  
  return $self->c(\@v2_values);
}

sub ifelse {
  my ($self, $_v1, $value1, $value2) = @_;
  
  my $v1 = $self->_v($_v1);
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
  
  return $self->array(\@v2_values, {type => $v1->type});
}

sub replace {
  my ($self, $_v1, $_v2, $_v3) = @_;
  
  my $v1 = $self->_v($_v1);
  my $v2 = $self->_v($_v2);
  my $v3 = $self->_v($_v3);
  
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
  
  return $self->array($v4_values, {type => $v1->type});
}

sub dim {
  my $self = shift;
  my $v1 = shift;
  
  return $v1->dim(@_);
}

sub append {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $v1 = shift;
  my $value = shift;
  
  my $after = $opt->{after};
  $after = $self->length($v1) unless defined $after;
  
  if (ref $value eq 'ARRAY') {
    splice @{$v1->values}, $after, 0, @$value;
  }
  elsif (ref $value eq 'Rstats::Array') {
    splice @{$v1->values}, $after, 0, @{$value->values};
  }
  else {
    splice @{$v1->values}, $after, 0, $value;
  }
  
  return $v1
}

sub names {
  my $self = shift;
  my $v1 = shift;
  
  return $v1->names(@_);
}

sub rownames {
  my $self = shift;
  my $m1 = shift;
  
  return $m1->rownames(@_);
}

sub colnames {
  my $self = shift;
  my $m1 = shift;
  
  return $m1->colnames(@_);
}

sub numeric {
  my $self = shift;
  
  return Rstats::Array->numeric(@_);
}

sub matrix {
  my $self = shift;
  
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};

  my ($_v1, $nrow, $ncol, $byrow, $dirnames) = @_;

  croak "matrix method need data as frist argument"
    unless defined $_v1;
  
  my $v1 = $self->_v($_v1);
  
  # Row count
  $nrow = $opt->{nrow} unless defined $nrow;
  
  # Column count
  $ncol = $opt->{ncol} unless defined $ncol;
  
  # By row
  $byrow = $opt->{byrow} unless defined $byrow;
  
  my $v1_values = $v1->values;
  my $v1_length = @$v1_values;
  if (!defined $nrow && !defined $ncol) {
    $nrow = $v1_length;
    $ncol = 1;
  }
  elsif (!defined $nrow) {
    $nrow = int($v1_length / $ncol);
  }
  elsif (!defined $ncol) {
    $ncol = int($v1_length / $nrow);
  }
  my $length = $nrow * $ncol;
  
  my $dim = [$nrow, $ncol];
  my $matrix;
  if ($byrow) {
    $matrix = $self->array(
      $v1_values,
      [$dim->[1], $dim->[0]],
      {type => 'matrix'}
    );
    
    $matrix = $self->t($matrix);
  }
  else {
    $matrix = $self->array($v1_values, $dim, {type => 'matrix'});
  }
  
  return $matrix;
}

sub type {
  my ($self, $array) = @_;
  
  return $array->type;
}

sub array {
  my $self = shift;
  
  return Rstats::Array->array(@_);
}

sub paste {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  my $sep = $opt->{sep};
  $sep = ' ' unless defined $sep;
  
  my $str = shift;
  my $v1 = shift;
  
  my $v1_values = $v1->values;
  my $v2 = $self->array([]);
  my $v2_values = $v2->values;
  push @$v2_values, "$str$sep$_" for @$v1_values;
  
  return $v2;
}

sub c {
  my $self = shift;
  
  return Rstats::Array->c(@_);
}

sub set_seed {
  my ($self, $seed) = @_;
  
  $self->{seed} = $seed;
}

sub runif {
  my ($self, $count, $min, $max) = @_;
  
  $min = 0 unless defined $min;
  $max = 1 unless defined $max;
  croak "runif third argument must be bigger than second argument"
    if $min > $max;
  
  my $diff = $max - $min;
  my @v1_values;
  if (defined $self->{seed}) {
    srand $self->{seed};
    $self->{seed} = undef;
  }
  for (1 .. $count) {
    my $rand = rand($diff) + $min;
    push @v1_values, $rand;
  }
  
  return $self->c(\@v1_values);
}

sub seq {
  my $self = shift;
  
  return Rstats::Array->seq(@_);
}

sub rep {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  my $v1 = shift;
  my $times = $opt->{times} || 1;
  
  my $values = [];
  push @$values, @{$v1->values} for 1 .. $times;
  my $v2 = $self->c($values);
  
  return $v2;
}

sub max {
  my ($self, @vs) = @_;
  
  my @all_values = map { @{$_->values} } @vs;
  my $max = List::Util::max(@all_values);
  return $max;
}

sub min {
  my ($self, @vs) = @_;
  
  my @all_values = map { @{$_->values} } @vs;
  my $min = List::Util::min(@all_values);
  return $min;
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
  
  my $v_max = $self->c(\@maxs);
  
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
  
  my $v_min = $self->c(\@mins);
  
  return $v_min;
}

sub abs {
  my ($self, $v1) = @_;
  
  my $tmp_v = $v1 * $v1;
  my $abs = sqrt $self->sum($tmp_v)->value;

  return $self->c($abs);
}

sub sum {
  my ($self, $_v1) = @_;
  
  my $v1 = $self->_v($_v1);
  my $v1_values = $v1->values;
  my $sum = List::Util::sum(@$v1_values);
  return $self->c($sum);
}

sub prod {
  my ($self, $v1) = @_;
  
  my $v1_values = $v1->values;
  my $prod = List::Util::product(@$v1_values);
  return $self->c($prod);
}

sub mean {
  my ($self, $data) = @_;
  
  my $v = $data;
  my $mean = $self->sum($v)->value / $self->length($v);
  
  return $self->c($mean);
}

sub var {
  my ($self, $v1) = @_;

  my $var = $self->sum(($v1 - $self->mean($v1)) ** 2)->value
    / ($self->length($v1) - 1);
  
  return $self->c($var);
}

sub head {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $v1 = shift;
  
  my $n = $opt->{n};
  $n = 6 unless defined $n;
  
  my $values1 = $v1->{values};
  my $max = $self->length($v1) < $n ? $self->length($v1) : $n;
  my @values2;
  for (my $i = 0; $i < $max; $i++) {
    push @values2, $values1->[$i];
  }
  
  return $v1->new(values => \@values2);
}

sub tail {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $v1 = shift;
  
  my $n = $opt->{n};
  $n = 6 unless defined $n;
  
  my $values1 = $v1->{values};
  my $max = $self->length($v1) < $n ? $self->length($v1) : $n;
  my @values2;
  for (my $i = 0; $i < $max; $i++) {
    unshift @values2, $values1->[$self->length($v1) - ($i  + 1)];
  }
  
  return $v1->new(values => \@values2);
}

sub length {
  my $self = shift;
  my $v1 = shift;
  
  return $v1->length;
}

sub sort {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $decreasing = $opt->{decreasing};
  my $_v1 = shift;
  
  my $v1 = $self->_v($_v1);
  my $v1_values = $v1->values;
  my $v2_values = $decreasing ? [reverse sort(@$v1_values)] : [sort(@$v1_values)];
  return $self->c($v2_values);
}

sub log {
  my ($self, $array) = @_;
  
  return $self->_apply($array, sub { log $_[0] });
}

sub exp {
  my ($self, $array) = @_;
  
  return $self->_apply($array, sub { exp $_[0] });
}

sub sin {
  my ($self, $array) = @_;
  
  return $self->_apply($array, sub { sin $_[0] });
}

sub cos {
  my ($self, $array) = @_;
  
  return $self->_apply($array, sub { cos $_[0] });
}

sub tan {
  my ($self, $array) = @_;
  
  return $self->_apply($array, sub { Math::Trig::tan $_[0] });
}

sub sqrt {
  my ($self, $array) = @_;

  return $self->_apply($array, sub { sqrt $_[0] });
}

sub _apply {
  my ($self, $array1, $cb) = @_;
  
  my $array1_values = $array1->values;
  my @array2_values = map {
    $cb->($array1_values->[$_]) 
  } (0 .. @$array1_values - 1);

  return $array1->new(values => \@array2_values);
}

sub range {
  my ($self, $array) = @_;
  
  my $min = $self->min($array);
  my $max = $self->max($array);
  
  return $self->c([$min, $max]);
}

sub i {
  my $self = shift;
  
  my $i = Rstats::Complex->new(re => 0, im => 1);
  
  return $i;
}

1;

=head1 NAME

Rstats - R language build on Perl

=head1 SYNOPSYS
  
  use Rstats;
  my $r = Rstats->new;
  
  # Array
  my $v1 = $r->c([1, 2, 3]);
  my $v2 = $r->c([2, 3, 4]);
  my $v3 = $v1 + v2;
  print $v3;
