package Rstats::Array;
use Object::Simple -base;
use Carp 'croak', 'carp';
use List::Util;
use Rstats;
use B;
use Scalar::Util 'looks_like_number';
use Rstats::NA;
use Rstats::NaN;
use Rstats::Inf;

our @CARP_NOT = ('Rstats');

use overload
  bool => sub {1},
  '+' => \&add,
  '-' => \&subtract,
  '*' => \&multiply,
  '/' => \&divide,
  '%' => \&remainder,
  'neg' => \&negation,
  '**' => \&raise,
  '""' => \&to_string,
  fallback => 1;

has 'values';
has 'mode';

sub clone_without_values {
  my ($self, %opt) = @_;
  
  my $array = Rstats::Array->new;
  $array->{mode} = $self->{mode};
  $array->{names} = [@{$self->{names} || []}];
  $array->{rownames} = [@{$self->{rownames} || []}];
  $array->{colnames} = [@{$self->{colnames} || []}];
  $array->{dim} = [@{$self->{dim} || []}];
  $array->{values} = $opt{values} ? $opt{values} : [];
  
  return $array;
}

sub row {
  my $self = shift;
  
  my $nrow = $self->nrow->value;
  my $ncol = $self->ncol->value;
  
  my @values = (1 .. $nrow) x $ncol;
  
  return Rstats::Array->array(\@values, [$nrow, $ncol]);
}

sub col {
  my $self = shift;
  
  my $nrow = $self->nrow->value;
  my $ncol = $self->ncol->value;
  
  my @values;
  for my $col (1 .. $ncol) {
    push @values, ($col) x $nrow;
  }
  
  return Rstats::Array->array(\@values, [$nrow, $ncol]);
}

sub nrow {
  my $self = shift;
  
  return Rstats::Array->array($self->dim->values->[0]);
}

sub ncol {
  my $self = shift;
  
  return Rstats::Array->array($self->dim->values->[1]);
}

sub names {
  my $self = shift;
  
  if (@_) {
    my $_names = shift;
    my $names;
    if (!defined $_names) {
      $names = [];
    }
    elsif (ref $_names eq 'ARRAY') {
      $names = $_names;
    }
    elsif (ref $_names eq 'Rstats::Array') {
      $names = $_names->values;
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
    $self->{names} = $names;
  }
  else {
    $self->{names} = [] unless exists $self->{names};
    return Rstats::Array->array($self->{names});
  }
}

sub colnames {
  my $self = shift;
  
  if (@_) {
    my $_colnames = shift;
    my $colnames;
    if (!defined $_colnames) {
      $colnames = [];
    }
    elsif (ref $_colnames eq 'ARRAY') {
      $colnames = $_colnames;
    }
    elsif (ref $_colnames eq 'Rstats::Array') {
      $colnames = $_colnames->values;
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
    $self->{colnames} = $colnames;
  }
  else {
    $self->{colnames} = [] unless exists $self->{colnames};
    return Rstats::Array->array($self->{colnames});
  }
}

sub rownames {
  my $self = shift;
  
  if (@_) {
    my $_rownames = shift;
    my $rownames;
    if (!defined $_rownames) {
      $rownames = [];
    }
    elsif (ref $_rownames eq 'ARRAY') {
      $rownames = $_rownames;
    }
    elsif (ref $_rownames eq 'Rstats::Array') {
      $rownames = $_rownames->values;
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
    $self->{rownames} = $rownames;
  }
  else {
    $self->{rownames} = [] unless exists $self->{rownames};
    return Rstats::Array->array($self->{rownames});
  }
}

sub dim {
  my $self = shift;
  
  if (@_) {
    my $v1 = $_[0];
    if (ref $v1 eq 'Rstats::Array') {
      $self->{dim} = $v1->values;
    }
    elsif (ref $v1 eq 'ARRAY') {
      $self->{dim} = $v1;
    }
    elsif(!ref $v1) {
      $self->{dim} = [$v1];
    }
    else {
      croak "Invalid values is passed to dim argument";
    }
  }
  else {
    $self->{dim} = [] unless exists $self->{dim};
    return Rstats::Array->array($self->{dim});
  } 
}

sub dim_as {
  
}

sub length {
  my $self = shift;
  
  my $length = @{$self->values};
  
  return $length;
}

sub seq {
  my $self = shift;
  
  # Option
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  # Along
  my $along = $opt->{along};
  
  if ($along) {
    my $length = $along->length;
    return $self->seq([1,$length]);
  }
  else {
    my $from_to = shift;
    my $from;
    my $to;
    if (ref $from_to eq 'ARRAY') {
      $from = $from_to->[0];
      $to = $from_to->[1];
    }
    elsif (defined $from_to) {
      $from = 1;
      $to = $from_to;
    }
    
    # From
    $from = $opt->{from} unless defined $from;
    croak "seq function need from option" unless defined $from;
    
    # To
    $to = $opt->{to} unless defined $to;

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
    
    my $values = [];
    if ($to == $from) {
      $values->[0] = $to;
    }
    elsif ($to > $from) {
      if ($by < 0) {
        croak "by option is invalid number(seq function)";
      }
      
      my $value = $from;
      while ($value <= $to) {
        push @$values, $value;
        $value += $by;
      }
    }
    else {
      if ($by > 0) {
        croak "by option is invalid number(seq function)";
      }
      
      my $value = $from;
      while ($value >= $to) {
        push @$values, $value;
        $value += $by;
      }
    }
    
    my $v1 = $self->array($values);
  }
}

sub _parse_seq_str {
  my ($self, $seq_str) = @_;
  
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
  
  my $array = $self->seq({from => $from, to => $to, by => $by});
  
  return $array;
}

sub _is_numeric {
  my ($self, $value) = @_;
  
  return B::svref_2object(\$value)->FLAGS & (B::SVp_IOK | B::SVp_NOK) 
        && 0 + $value eq $value
        && $value * 0 == 0
}

sub array {
  my $self = shift;
  
  # Arguments
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my ($v1, $_dim) = @_;
  $_dim = $opt->{dim} unless defined $_dim;
  
  # Array
  my $array = Rstats::Array->new;
  
  # Value
  my $values = [];
  if (defined $v1) {
    if (ref $v1 eq 'ARRAY') {
      for my $a (@$v1) {
        if (ref $a eq 'ARRAY') {
          push @$values, @$a;
        }
        elsif (ref $a eq 'Rstats::Array') {
          push @$values, @{$a->values};
        }
        else {
          push @$values, $a;
        }
      }
    }
    elsif (ref $v1 eq 'Rstats::Array') {
      $values = $v1->values;
    }
    elsif(!ref $v1) {
      $values = $self->_parse_seq_str($v1)->values;
    }
  }
  else {
    croak "Invalid first argument";
  }
  
  # Dimention
  my $dim;
  if (defined $_dim) {
    if (ref $_dim eq 'Rstats::Array') {
      $dim = $_dim->values;
    }
    elsif (ref $_dim eq 'ARRAY') {
      $dim = $_dim;
    }
    elsif(!ref $_dim) {
      $dim = [$_dim];
    }
  }
  else {
    $dim = [scalar @$values]
  }
  $array->dim($dim);
  
  # Check values
  my $mode_h = {};
  for my $value (@$values) {
    if (ref $value eq 'Rstats::Complex') {
      $mode_h->{complex}++;
    }
    elsif (ref $value eq 'Rstats::Logical' || ref $value eq 'Rstats::NA') {
      $mode_h->{logical}++;
    }
    elsif (ref $value eq 'Rstats::NaN' && ref $value eq 'Rstats::Inf') {
      $mode_h->{numeric}++;
    }
    elsif ($self->_is_numeric($value)) {
      $mode_h->{numeric}++;
    }
    else {
      $mode_h->{character}++;
    }
  }

  # Upgrade values and type
  my @modes = keys %$mode_h;
  if (@modes > 1) {
    if ($mode_h->{character}) {
      my $a1 = Rstats::Array->new(values => $values)->as_character;
      $values = $a1->values;
      $array->mode('character');
    }
    elsif ($mode_h->{complex}) {
      my $a1 = Rstats::Array->new(values => $values)->as_complex;
      $values = $a1->values;
      $array->mode('complex');
    }
    elsif ($mode_h->{numeric}) {
      my $a1 = Rstats::Array->new(values => $values)->as_numeric;
      $values = $a1->values;
      $array->mode('numeric');
    }
    elsif ($mode_h->{logical}) {
      my $a1 = Rstats::Array->new(values => $values)->as_logical;
      $values = $a1->values;
      $array->mode('logical');
    }
  }
  else {
    $array->mode($modes[0]);
  }
  
  # Fix values
  my $max_length = 1;
  $max_length *= $_ for @$dim;
  if (@$values > $max_length) {
    @$values = splice @$values, 0, $max_length;
  }
  elsif (@$values < $max_length) {
    my $repeat_count = int($max_length / @$values) + 1;
    @$values = (@$values) x $repeat_count;
    @$values = splice @$values, 0, $max_length;
  }
  $array->values($values);
  
  return $array;
}

sub at {
  my $self = shift;
  
  if (@_) {
    $self->{at} = [@_];
    
    return $self;
  }
  
  return $self->{at};
}

sub value {
  my $self = shift;
  
  my $dim_values = $self->dim->values;
  
  if (@_) {
    if (@$dim_values == 1) {
      return $self->{values}[$_[0] - 1];
    }
    elsif (@$dim_values == 2) {
      return $self->{values}[($_[0] + $dim_values->[0] * ($_[1] - 1)) - 1];
    }
    else {
      return $self->get(@_)->value;
    }
  }
  else {
    return $self->{values}[0];
  }
}

sub is_numeric {
  my $self = shift;
  
  my $is = ($self->{mode} || '') eq 'numeric' ? 1 : 0;
  
  return $self->c([$is]);
}

sub is_integer {
  my $self = shift;
  
  my $is = ($self->{mode} || '') eq 'integer' ? 1 : 0;
  
  return $self->c([$is]);
}

sub is_complex {
  my $self = shift;
  
  my $is = ($self->{mode} || '') eq 'complex' ? 1 : 0;
  
  return $self->c([$is]);
}

sub is_character {
  my $self = shift;
  
  my $is = ($self->{mode} || '') eq 'character' ? 1 : 0;
  
  return $self->c([$is]);
}

sub is_logical {
  my $self = shift;
  
  my $is = ($self->{mode} || '') eq 'logical' ? 1 : 0;
  
  return $self->c([$is]);
}

sub _looks_like_complex {
  my ($self, $value) = @_;
  
  return if !defined $value || !CORE::length $value;
  $value =~ s/^ +//;
  $value =~ s/ +$//;
  
  my $re;
  my $im;
  
  if ($value =~ /^([\+\-]?[^\+\-]+)i$/) {
    $re = 0;
    $im = $1;
  }
  elsif($value =~ /^([\+\-]?[^\+\-]+)([\+\-][^\+\-i]+)i?$/) {
    $re = $1;
    $im = $2;
  }
  else {
    return;
  }
  
  if (looks_like_number $re && looks_like_number $im) {
    return ($re, $im);
  }
  else {
    return;
  }
}

sub _looks_like_number {
  my ($self, $value) = @_;
  
  return if !defined $value || !CORE::length $value;
  $value =~ s/^ +//;
  $value =~ s/ +$//;
  
  if (looks_like_number $value) {
    return ($value);
  }
  else {
    return;
  }
}

sub as_complex {
  my $self = shift;
  
  my $a1_values = $self->values;
  my $a2 = $self->clone_without_values;
  my @a2_values = map {
    if (ref $_ eq 'Rstats::Complex') {
      Rstats::Complex->new(re => $_->re, im => $_->im);
    }
    elsif (ref $_ eq 'Rstats::Logical') {
      if ($_) {
        Rstats::Complex->new(re => 1, im => 0);
      }
      else {
        Rstats::Complex->new(re => 0, im => 0);
      }
    }
    elsif (ref $_ eq 'Rstats::NA' || ref $_ eq 'Rstats::NaN') {
      Rstats::NA->NA;
    }
    elsif (ref $_ eq 'Rstats::Inf') {
      Rstats::Complex->new(re => $_, im => 0);
    }
    elsif (my @nums = $self->_looks_like_number($_)) {
      Rstats::Complex->new(re => $nums[0] + 0, im => 0);
    }
    elsif (my @c_nums = $self->_looks_like_complex($_)) {
      Rstats::Complex->new(re => $c_nums[0] + 0, im => $c_nums[1] + 0);
    }
    else {
      carp 'NAs introduced by coercion';
      Rstats::NA->NA;
    }
  } @$a1_values;
  $a2->values(\@a2_values);
  $a2->{mode} = 'complex';

  return $a2;
}

sub as_numeric {
  my $self = shift;
  
  my $a1 = $self;
  my $a1_values = $a1->values;
  my $a2 = $self->clone_without_values;
  my @a2_values = map {
    if (ref $_ eq 'Rstats::Complex') {
      carp "imaginary parts discarded in coercion";
      $_->re;
    }
    elsif (ref $_ eq 'Rstats::Logical') {
      $_ ? 1 : 0;
    }
    elsif (ref $_ eq 'Rstats::NA' || ref $_ eq 'Rstats::NaN') {
      Rstats::NA->NA;
    }
    elsif (ref $_ eq 'Rstats::Inf') {
      $_;
    }
    elsif (my @nums = $self->_looks_like_number($_)) {
      $nums[0] + 0;
    }
    else {
      carp 'NAs introduced by coercion';
      Rstats::NA->NA;
    } 
  } @$a1_values;
  $a2->values(\@a2_values);
  $a2->{mode} = 'numeric';

  return $a2;
}

sub as_integer {
  my $self = shift;
  
  my $a1 = $self;
  my $a1_values = $a1->values;
  my $a2 = $self->clone_without_values;
  my @a2_values;
  if ($a1->is_complex->value) {
    carp "Complex image number is removed";
    @a2_values = map { int $_->re } @$a1_values;    
  }
  elsif ($a1->is_numeric->value) {
    @a2_values = map { int $_ } @$a1_values;
  }
  elsif ($a1->is_integer->value) {
    @a2_values = @$a1_values;
  }
  elsif ($a1->is_logical->value) {
    @a2_values = map { $_ ? 1 : 0 } @$a1_values;
  }
  elsif ($a1->is_character->value) {
    carp "NA is created for forced conversion";
    @a2_values = map { Rstats::NA->new } (1 .. @$a1_values);
  }
  $a2->values(\@a2_values);
  $a2->{mode} = 'integer';

  return $a2;
}

sub as_logical {
  my $self = shift;

  my $a1_values = $self->values;
  my $a2 = $self->clone_without_values;
  my @a2_values = map {
      ref $_ eq 'Rstats::NA' || ref $_ eq 'Rstats::NaN' ? Rstats::Na->NA
    : $_ ? Rstats::Logical->TRUE
    : Rstats::Logical->FALSE
  } @$a1_values;
  $a2->values(\@a2_values);
  $a2->{mode} = 'logical';
  
  return $a2;
}

sub as_character {
  my $self = shift;

  my $a1_values = $self->values;
  my $a2 = $self->clone_without_values;
  my @a2_values = map { "$_" } @$a1_values;
  $a2->values(\@a2_values);
  $a2->{mode} = 'character';

  return $a2;
}


sub get {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $drop = $opt->{drop};
  $drop = 1 unless defined $drop;
  
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
  
  if (ref $_indexs->[0] eq 'CODE') {
    my $a1_values = $self->values;
    my @values2 = grep { $_indexs->[0]->() } @$a1_values;
    return Rstats::Array->array(\@values2);
  }

  my ($positions, $a2_dim) = $self->_parse_index($drop, @$_indexs);
  
  my @a2_values = map { $self->values->[$_ - 1] } @$positions;
  
  return Rstats::Array->array(\@a2_values, $a2_dim);
}

sub NULL {
  my $self = shift;
  
  return Rstats::Array->numeric(0);
}

sub numeric {
  my ($self, $num) = @_;
  
  return Rstats::Array->c([(0) x $num]);
}

sub _v {
  my ($self, $data) = @_;
  
  my $v;
  if (!defined $data) {
    $v = Rstats::Array->c([undef]);
  }
  elsif (defined $data && $data eq '') {
    $v = Rstats::Array->NULL;
  }
  elsif (!ref $data) {
    $v = Rstats::Array->c($data);
  }
  elsif (ref $data eq 'ARRAY') {
    $v = Rstats::Array->c($data);
  }
  elsif (ref $data eq 'Rstats::Array') {
    $v = $data;
  }
  else {
    croak "Invalid data is passed";
  }
  
  return $v;
}

sub c {
  my ($self, $data) = @_;
  
  my $vector = $self->array($data);
  
  return $vector;
}

sub set {
  my ($self, $_array) = @_;

  my $at = $self->at;
  my $_indexs = ref $at eq 'ARRAY' ? $at : [$at];

  my $code;
  my $array;
  if (ref $_array eq 'CODE') {
    $code = $_array;
  }
  else {
    $array = Rstats::Array->_v($_array);
  }
  
  my ($positions, $a2_dim) = $self->_parse_index(0, @$_indexs);
  
  my $self_values = $self->values;
  if ($code) {
    for (my $i = 0; $i < @$positions; $i++) {
      my $pos = $positions->[$i];
      local $_ = $self_values->[$pos - 1];
      $self_values->[$pos - 1] = $code->();
    }    
  }
  else {
    my $array_values = $array->values;
    for (my $i = 0; $i < @$positions; $i++) {
      my $pos = $positions->[$i];
      $self_values->[$pos - 1] = $array_values->[(($i + 1) % @$positions) - 1];
    }
  }
  
  return $self;
}


sub _parse_index {
  my ($self, $drop, @_indexs) = @_;
  
  my $a1_values = $self->values;
  my $a1_dim = $self->dim->values;
  
  my @indexs;
  my @a2_dim;
  
  for (my $i = 0; $i < @$a1_dim; $i++) {
    my $_index = $_indexs[$i];
    
    $_index = '' unless defined $_index;
    
    my $index = Rstats::Array->_v($_index);
    my $index_values = $index->values;
    if (@$index_values && !$index->is_character->value && !$index->is_logical->value) {
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
    
    push @indexs, $index;
    
    if (!@{$index->values}) {
      my $index_value_new = [1 .. $a1_dim->[$i]];
      $index->values($index_value_new);
    }
    elsif ($index->is_character->value) {
      if ($self->is_vector->value) {
        my $index_new_values = [];
        for my $name (@{$index->values}) {
          my $i = 0;
          my $value;
          for my $self_name (@{$self->names->values}) {
            if ($name eq $self_name) {
              $value = $self->values->[$i];
              last;
            }
            $i++;
          }
          croak "Can't find name" unless defined $value;
          push @$index_new_values, $value;
        }
        $indexs[$i]->values($index_new_values);
      }
      elsif ($self->is_matrix->value) {
        
      }
      else {
        croak "Can't support name except vector and matrix";
      }
    }
    elsif ($index->is_logical->value) {
      my $index_values_new = [];
      for (my $i = 0; $i < @{$index->values}; $i++) {
        push @$index_values_new, $i + 1 if $index->values->[$i];
      }
      $index->values($index_values_new);
    }
    elsif ($index->{_minus}) {
      my $index_value_new = [];
      
      for my $k (1 .. $a1_dim->[$i]) {
        push @$index_value_new, $k unless grep { $_ == -$k } @{$index->values};
      }
      $index->values($index_value_new);
      delete $index->{_minus};
    }
    
    my $count = @{$index->values};
    push @a2_dim, $count unless $count == 1 && $drop;
  }
  @a2_dim = (1) unless @a2_dim;
  
  my $index_values = [map { $_->values } @indexs];
  my $ords = $self->_cross_product($index_values);
  my @positions = map { $self->_pos($_, $a1_dim) } @$ords;
  
  return (\@positions, \@a2_dim);
}

sub _cross_product {
  my ($self, $values) = @_;

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

sub _pos {
  my ($self, $ord, $dim) = @_;
  
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

sub to_string {
  my $self = shift;

  my $values = $self->values;
  
  my $dim_values = $self->dim->values;
  
  my $dim_length = @$dim_values;
  my $dim_num = $dim_length - 1;
  my $positions = [];
  
  my $str;
  if (@$values) {
    if ($dim_length == 1) {
      my $names = $self->names->values;
      if (@$names) {
        $str .= join(' ', @$names) . "\n";
      }
      $str .= '[1] ' . join(' ', @$values) . "\n";
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
        
        my @values;
        for my $d2 (1 .. $dim_values->[1]) {
          push @values, $self->value($d1, $d2);
        }
        
        $str .= join(' ', @values) . "\n";
      }
    }
    else {
      my $code;
      $code = sub {
        my (@dim_values) = @_;
        my $dim_value = pop @dim_values;
        
        for (my $i = 1; $i <= $dim_value; $i++) {
          $str .= (',' x $dim_num) . "$i" . "\n";
          unshift @$positions, $i;
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
              
              my @values;
              for my $d2 (1 .. $dim_values[1]) {
                push @values, $self->value($d1, $d2, @$positions);
              }
              
              $str .= join(' ', @values) . "\n";
            }
          }
          shift @$positions;
        }
      };
      $code->(@$dim_values);
    }
  }
  else {
    $str = 'NULL';
  }
  
  return $str;
}

sub negation {
  my $self = shift;
  
  my $v1_values = $self->values;
  my $v2_values = [];
  $v2_values->[$_] = -$v1_values->[$_] for (0 .. @$v1_values - 1);
  
  return Rstats::Array->array($v2_values);
}

sub add { shift->_operation('+', @_) }
sub subtract { shift->_operation('-', @_) }
sub multiply { shift->_operation('*', @_) }
sub divide { shift->_operation('/', @_) }
sub raise { shift->_operation('**', @_) }
sub remainder { shift->_operation('%', @_) }

my $culcs = {};
my @ops = qw#+ - * / ** %#;
for my $op (@ops) {
   my $code = <<"EOS";
sub {
  my (\$v1_values, \$v2_values) = \@_;
   
  my \$v1_length = \@{\$v1_values};
  my \$v2_length = \@{\$v2_values};
  my \$longer_length = \$v1_length > \$v2_length ? \$v1_length : \$v2_length;

  my \@v3_values = map {
    \$v1_values->[\$_ % \$v1_length] $op \$v2_values->[\$_ % \$v2_length]
    } (0 .. \$longer_length - 1);
  
  return \@v3_values;
}
EOS
  
  $culcs->{$op} = eval $code;

  croak $@ if $@;
}

sub _operation {
  my ($self, $op, $data, $reverse) = @_;

  my $v1_values;
  my $v2_values;
  if (ref $data eq 'Rstats::Array') {
    $v1_values = $self->values;
    my $v2 = $data;
    $v2_values = $v2->values;
  }
  else {
    if ($reverse) {
      $v1_values = [$data];
      $v2_values = $self->values;
    }
    else {
      $v1_values = $self->values;
      $v2_values = [$data];
    }
  }
  
  my @v3_values = $culcs->{$op}->($v1_values, $v2_values);
  
  return Rstats::Array->array(\@v3_values);
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
    );
    
    $matrix = $self->t($matrix);
  }
  else {
    $matrix = $self->array($v1_values, $dim);
  }
  
  return $matrix;
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

sub is_array {
  my $self = shift;
  
  
  return $self->c([1]);
}

sub is_vector {
  my $self = shift;
  
  my $is = @{$self->dim->values} == 1 ? 1 : 0;
  
  return $self->c([$is]);
}

sub is_matrix {
  my $self = shift;

  my $is = @{$self->dim->values} == 2 ? 1 : 0;
  
  return $self->c([$is]);
}

sub as_matrix {
  my $self = shift;
  
  my $a1_dim_values = $self->dim->values;
  my $a1_dim_count = @$a1_dim_values;
  my $a2_dim_values = [];
  my $row;
  my $col;
  if ($a1_dim_count == 2) {
    $row = $a1_dim_values->[0];
    $col = $a1_dim_values->[1];
  }
  else {
    $row = 1;
    $row *= $_ for @$a1_dim_values;
    $col = 1;
  }
  
  my $a2_values = [@{$self->values}];
  
  return $self->matrix($a2_values, $row, $col);
}

sub as_array {
  my $self = shift;
  
  my $a1_values = [@{$self->values}];
  my $a1_dim_values = [@{$self->dim->values}];
  
  return $self->array($a1_values, $a1_dim_values);
}

sub as_vector {
  my $self = shift;
  
  my $a1_values = [@{$self->values}];
  
  return $self->c($a1_values);
}

1;

