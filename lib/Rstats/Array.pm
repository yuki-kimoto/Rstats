package Rstats::Array;
use Object::Simple -base;

use Carp 'croak', 'carp';
use List::Util;
use Rstats;
use B;
use Scalar::Util 'looks_like_number';
use Rstats::Type::NA;
use Rstats::Type::Logical;
use Rstats::Type::Character;

our @CARP_NOT = ('Rstats');

my %types_h = map { $_ => 1 } qw/character complex numeric integer logical/;

use overload
  bool => \&bool,
  '+' => \&add,
  '-' => \&subtract,
  '*' => \&multiply,
  '/' => \&divide,
  '%' => \&remainder,
  'neg' => \&negation,
  '**' => \&raise,
  '<' => \&less_than,
  '<=' => \&less_than_or_equal,
  '>' => \&more_than,
  '>=' => \&more_than_or_equal,
  '==' => \&equal,
  '!=' => \&not_equal,
  '""' => \&to_string,
  fallback => 1;

has 'values';

sub typeof {
  my $self = shift;
  
  my $type = $self->{type};
  my $a1_values = defined $type ? $type : "NULL";
  my $a1 = Rstats::Array->c([$a1_values]);
  
  return $a1;
}

sub mode {
  my $self = shift;
  
  if (@_) {
    my $type = $_[0];
    croak qq/Error in eval(expr, envir, enclos) : could not find function "as_$type"/
      unless $types_h{$type};
    
    $self->{type} = $type;
    
    return $self;
  }
  else {
    my $type = $self->{type};
    my $mode;
    if (defined $type) {
      $mode = $type eq 'integer' ? 'numeric' : $type;
    }
    else {
      $mode = 'NULL';
    }

    my $a1 = Rstats::Array->c([$mode]);

    return $a1;
  }
}

sub bool {
  my $self = shift;
  
  my $length = @{$self->values};
  if ($length == 0) {
    croak 'Error in if (a) { : argument is of length zero';
  }
  elsif ($length > 1) {
    carp 'In if (a) { : the condition has length > 1 and only the first element will be used';
  }
  
  my $value = $self->value;
  my $a1 = Rstats::Array->array([$value]);
  my $a2 = $a1->as_logical;
  my $a2_value = $a2->value;
  
  return $a2_value ? 1 : 0;
}

sub clone_without_values {
  my ($self, %opt) = @_;
  
  my $array = Rstats::Array->new;
  $array->{type} = $self->{type};
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
    my $a1 = $_[0];
    if (ref $a1 eq 'Rstats::Array') {
      $self->{dim} = $a1->values;
    }
    elsif (ref $a1 eq 'ARRAY') {
      $self->{dim} = $a1;
    }
    elsif(!ref $a1) {
      $self->{dim} = [$a1];
    }
    else {
      croak "Invalid values is passed to dim argument";
    }
  }
  else {
    $self->{dim} = [] unless exists $self->{dim};
    return Rstats::Array->new(values => $self->{dim});
  }
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
    
    my $a1 = $self->array($values);
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
  
  return unless defined $value;
  
  return B::svref_2object(\$value)->FLAGS & (B::SVp_IOK | B::SVp_NOK) 
        && 0 + $value eq $value
        && $value * 0 == 0
}

sub array {
  my $self = shift;
  
  # Arguments
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my ($a1, $_dim) = @_;
  $_dim = $opt->{dim} unless defined $_dim;
  
  # Array
  my $array = Rstats::Array->new;
  
  # Value
  my $values = [];
  if (defined $a1) {
    if (ref $a1 eq 'ARRAY') {
      for my $a (@$a1) {
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
    elsif (ref $a1 eq 'Rstats::Array') {
      $values = $a1->values;
    }
    elsif(!ref $a1) {
      $values = $self->_parse_seq_str($a1)->values;
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
    if (!defined $value) {
      croak "undef is invalid value";
    }
    elsif (ref $value eq 'Rstats::Type::Character') {
      $mode_h->{character}++;
    }
    elsif (ref $value eq 'Rstats::Type::Complex') {
      $mode_h->{complex}++;
    }
    elsif (ref $value eq 'Rstats::Type::Double') {
      $mode_h->{numeric}++;
    }
    elsif (ref $value eq 'Rstats::Type::Integer') {
      $value = Rstats::Type::Double->new(value => $value->value);
      $mode_h->{numeric}++;
    }
    elsif (ref $value eq 'Rstats::Type::Logical') {
      $mode_h->{logical}++;
    }
    elsif (Rstats::Util::is_numeric($value)) {
      $value = Rstats::Type::Double->new(value => $value);
      $mode_h->{numeric}++;
    }
    else {
      $value = Rstats::Type::Character->new(value => "$value");
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
    $array->mode($modes[0] || 'logical');
  }
  
  # Fix values
  my $max_length = 1;
  $max_length *= $_ for @{$array->_real_dim_values || [scalar @$values]};
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

sub _real_dim_values {
  my $self = shift;
  
  my $dim = $self->dim;
  my $dim_values = $dim->values;
  if (@$dim_values) {
    return $dim_values;
  }
  else {
    if (defined $self->values) {
      my $length = @{$self->values};
      return [$length];
    }
    else {
      return;
    }
  }
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
  
  my $dim_values = $self->_real_dim_values;
  
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
  
  my $is = ($self->{type} || '') eq 'numeric' ? 1 : 0;
  
  return $self->c([$is]);
}

sub is_integer {
  my $self = shift;
  
  my $is = ($self->{type} || '') eq 'integer' ? 1 : 0;
  
  return $self->c([$is]);
}

sub is_complex {
  my $self = shift;
  
  my $is = ($self->{type} || '') eq 'complex' ? 1 : 0;
  
  return $self->c([$is]);
}

sub is_character {
  my $self = shift;
  
  my $is = ($self->{type} || '') eq 'character' ? 1 : 0;
  
  return $self->c([$is]);
}

sub is_logical {
  my $self = shift;
  
  my $is = ($self->{type} || '') eq 'logical' ? 1 : 0;
  
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

sub _as {
  my ($self, $mode) = @_;
  
  if ($mode eq 'character') {
    return $self->as_character;
  }
  elsif ($mode eq 'complex') {
    return $self->as_complex;
  }
  elsif ($mode eq 'numeric') {
    return $self->as_numeric;
  }
  elsif ($mode eq 'integer') {
    return $self->as_integer;
  }
  elsif ($mode eq 'logical') {
    return $self->as_logical;
  }
  else {
    croak "Invalid mode is passed";
  }
}

sub as_complex {
  my $self = shift;
  
  my $a1 = $self;
  my $a1_values = $a1->values;
  my $a2 = $self->clone_without_values;
  my @a2_values = map {
    if (ref $_ eq 'Rstats::Type::NA') {
      $_;
    }
    elsif (ref $_ eq 'Rstats::Type::Character') {
      if (my @nums = $self->_looks_like_complex($_) {
        Rstats::Util::complex(@nums);
      }
      else {
        carp 'NAs introduced by coercion';
        Rstats::Util::na;
      }
    }
    elsif (ref $_ eq 'Rstats::Type::Complex') {
      $_;
    }
    elsif (ref $_ eq 'Rstats::Type::Double') {
      if (Rstats::Util::is_nan($_)) {
        Rstats::Util::na;
      }
      else {
        Rstats::Util::complex($_, 0);
      }
    }
    elsif (ref $_ eq 'Rstats::Type::Integer') {
      Rstats::Util::complex($_, 0);
    }
    elsif (ref $_ eq 'Rstats::Type::Logical') {
      Rstats::Util::complex($_->value ? 1 : 0, 0);
    }
    else {
      croak "unexpected type";
    }
  } @$a1_values;
  $a2->values(\@a2_values);
  $a2->{type} = 'complex';

  return $a2;
}

sub as_numeric {
  my $self = shift;
  
  my $a1 = $self;
  my $a1_values = $a1->values;
  my $a2 = $self->clone_without_values;
  my @a2_values = map {
    if (ref $_ eq 'Rstats::Type::NA') {
      $_;
    }
    elsif (ref $_ eq 'Rstats::Type::Character') {
      if ($self->_looks_like_number($_) {
        Rstats::Type::Double->new(value => $_ + 0);
      }
      else {
        carp 'NAs introduced by coercion';
        Rstats::Util::na;
      }
    }
    elsif (ref $_ eq 'Rstats::Type::Complex') {
      carp "imaginary parts discarded in coercion";
      Rstats::Type::Double->new(value => $_->re);
    }
    elsif (ref $_ eq 'Rstats::Type::Double') {
      $_;
    }
    elsif (ref $_ eq 'Rstats::Type::Integer') {
      Rstats::Type::Double->new(value => $_->value);
    }
    elsif (ref $_ eq 'Rstats::Type::Logical') {
      Rstats::Type::Double->new(value => $_ ? 1 : 0);
    }
    else {
      croak "unexpected type";
    }
  } @$a1_values;
  $a2->values(\@a2_values);
  $a2->{type} = 'numeric';

  return $a2;
}

sub as_integer {
  my $self = shift;
  
  my $a1 = $self;
  my $a1_values = $a1->values;
  my $a2 = $self->clone_without_values;
  my @a2_values = map {
    if (ref $_ eq 'Rstats::Type::NA') {
      $_;
    }
    elsif (ref $_ eq 'Rstats::Type::Character') {
      if ($self->_looks_like_number($_) {
        Rstats::Type::Integer->new(value => int($_ + 0));
      }
      else {
        carp 'NAs introduced by coercion';
        Rstats::Util::na;
      }
    }
    elsif (ref $_ eq 'Rstats::Type::Complex') {
      carp "imaginary parts discarded in coercion";
      Rstats::Type::Integer->new(value => int($_->re));
    }
    elsif (ref $_ eq 'Rstats::Type::Double') {
      if (Rstats::Util::is_nan($_) || Rstats::Util::is_inifinite($_)) {
        Rstats::Util::na;
      }
      else {
        $_ == 0 ? Rstats::Util::false : Rstats::Util::true;
      }
    }
    elsif (ref $_ eq 'Rstats::Type::Integer') {
      $_; 
    }
    elsif (ref $_ eq 'Rstats::Type::Logical') {
      Rstats::Type::Integer->new(value => $_ ? 1 : 0);
    }
    else {
      croak "unexpected type";
    }
  } @$a1_values;
  $a2->values(\@a2_values);
  $a2->{type} = 'integer';

  return $a2;
}

sub as_logical {
  my $self = shift;
  
  my $a1 = $self;
  my $a1_values = $a1->values;
  my $a2 = $self->clone_without_values;
  my @a2_values = map {
    if (ref $_ eq 'Rstats::Type::NA') {
      $_;
    }
    elsif (ref $_ eq 'Rstats::Type::Character') {
      if ($self->_looks_like_number($_) {
        $_ ? Rstats::Util::true : Rstats::Util::false;
      }
      else {
        carp 'NAs introduced by coercion';
        Rstats::Util::na;
      }
    }
    elsif (ref $_ eq 'Rstats::Type::Complex') {
      carp "imaginary parts discarded in coercion";
      my $re = $_->re->value;
      my $im = $_->im->value;
      if (defined $re && $re == 0 && defined $im && $im == 0) {
        Rstats::Util::false;
      }
      else {
        Rstats::Util::true;
      }
    }
    elsif (ref $_ eq 'Rstats::Type::Double') {
      if (Rstats::Util::is_nan($_)) {
        Rstats::Util::na;
      }
      elsif (Rstats::Util::is_inifinite($_)) {
        Rstats::Util::true;
      }
      else {
        $_ == 0 ? Rstats::Util::false : Rstats::Util::true;
      }
    }
    elsif (ref $_ eq 'Rstats::Type::Integer') {
      $_->value == 0 ? Rstats::Util::false : Rstats::Util::true;
    }
    elsif (ref $_ eq 'Rstats::Type::Logical') {
      $_;
    }
    else {
      croak "unexpected type";
    }
  } @$a1_values;
  $a2->values(\@a2_values);
  $a2->{type} = 'logical';

  return $a2;
}

sub as_character {
  my $self = shift;

  my $a1_values = $self->values;
  my $a2 = $self->clone_without_values;
  my @a2_values = map { Rstats::Type::Chracter->new(value => "$_") } @$a1_values;
  $a2->values(\@a2_values);
  $a2->{type} = 'character';

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

sub _to_a {
  my ($self, $data) = @_;
  
  croak "undef value is invalid" unless defined $data;
  my $v;
  if (ref $data eq 'ARRAY') {
    $v = Rstats::Array->c($data);
  }
  elsif (ref $data eq 'Rstats::Array') {
    $v = $data;
  }
  elsif (!ref $data) {
    if ($data eq '') {
      $v = Rstats::Array->NULL;
    }
    else {
      $v = Rstats::Array->c($data);
    }
  }
  else {
    croak "Invalid data is passed";
  }
  
  return $v;
}

sub c {
  my ($self, $data) = @_;
  
  my $vector = Rstats::Array->array($data, []);
  
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
    $array = Rstats::Array->_to_a($_array);
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
  my $a1_dim = $self->_real_dim_values;
  
  my @indexs;
  my @a2_dim;
  
  for (my $i = 0; $i < @$a1_dim; $i++) {
    my $_index = $_indexs[$i];
    
    $_index = '' unless defined $_index;
    
    my $index = Rstats::Array->_to_a($_index);
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
      if ($self->is_vector) {
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
      elsif ($self->is_matrix) {
        
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
  
  my $dim_values = $self->_real_dim_values;
  
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
  
  my $a1_values = $self->values;
  my $a2_values = [];
  $a2_values->[$_] = -$a1_values->[$_] for (0 .. @$a1_values - 1);
  
  return Rstats::Array->array($a2_values);
}

sub add { shift->_operation('+', @_) }
sub subtract { shift->_operation('-', @_) }
sub multiply { shift->_operation('*', @_) }
sub divide { shift->_operation('/', @_) }
sub raise { shift->_operation('**', @_) }
sub remainder { shift->_operation('%', @_) }

sub less_than { shift->_operation('<', @_) }
sub less_than_or_equal { shift->_operation('<=', @_) }
sub more_than { shift->_operation('>', @_) }
sub more_than_or_equal { shift->_operation('>=', @_) }
sub equal { shift->_operation('==', @_) }
sub not_equal { shift->_operation('!=', @_) }

my $culcs = {};
my %numeric_ops_h = map { $_ => 1} (qw#+ - * / ** %#);
my %comparison_ops_h = map { $_ => 1} (qw/< <= > >= == !=/);
my @ops = (keys %numeric_ops_h, keys %comparison_ops_h);
my %character_comparison_ops = (
  '<' => 'lt',
  '<=' => 'le',
  '>' => 'gt',
  '>=' => 'ge',
  '==' => 'eq',
  '!=' => 'ne'
);
for my $op (@ops) {
   my $code = <<"EOS";
sub {
  my (\$a1_values, \$a2_values) = \@_;
   
  my \$a1_length = \@{\$a1_values};
  my \$a2_length = \@{\$a2_values};
  my \$longer_length = \$a1_length > \$a2_length ? \$a1_length : \$a2_length;

  my \@a3_values = map {
    \$a1_values->[\$_ % \$a1_length] $op \$a2_values->[\$_ % \$a2_length]
EOS
  
  if ($comparison_ops_h{$op}) {
    $code .= "? Rstats::Logical->TRUE : Rstats::Logical->FALSE\n";
  }
  
  $code .= <<"EOS";
  } (0 .. \$longer_length - 1);

  return \@a3_values;
}
EOS
  
  $culcs->{$op} = eval $code;

  croak $@ if $@;
}

sub _operation {
  my ($self, $op, $data, $reverse) = @_;
  
  my $a1;
  my $a2;
  if (ref $data eq 'Rstats::Array') {
    $a1 = $self;
    $a2 = $data;
  }
  else {
    if ($reverse) {
      $a1 = Rstats::Array->array([$data]);
      $a2 = $self;
    }
    else {
      $a1 = $self;
      $a2 = Rstats::Array->array([$data]);
    }
  }
  
  # Upgrade mode if mode is different
  ($a1, $a2) = $self->_upgrade_mode($a1, $a2)
    if ($a1->{type} || '') ne ($a2->{type} || '');
  
  # Error when numeric operator is used to character
  croak("Error in a + b : non-numeric argument to binary operator")
    if $a1->is_character && $numeric_ops_h{$op};
  
  # Convert operator to Perl character comparison operator
  $op = $character_comparison_ops{$op}
    if $a1->is_character && $character_comparison_ops{$op};
  
  my @a3_values = $culcs->{$op}->($a1->values, $a2->values);
  
  my $a3 = Rstats::Array->array(\@a3_values);
  $a3->{type} = 'integer' if $a1->is_integer;
  return $a3;
}

sub _upgrade_mode {
  my ($self, @arrays) = @_;
  
  # Check values
  my $mode_h = {};
  for my $array (@arrays) {
    my $type = $array->{type} || '';
    if ($type eq 'character') {
      $mode_h->{character}++;
    }
    elsif ($type eq 'complex') {
      $mode_h->{complex}++;
    }
    elsif ($type eq 'numeric') {
      $mode_h->{numeric}++;
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

  # Upgrade values and type if mode is different
  my @modes = keys %$mode_h;
  if (@modes > 1) {
    my $to_mode;
    if ($mode_h->{character}) {
      $to_mode = 'character';
    }
    elsif ($mode_h->{complex}) {
      $to_mode = 'complex';
    }
    elsif ($mode_h->{numeric}) {
      $to_mode = 'numeric';
    }
    elsif ($mode_h->{integer}) {
      $to_mode = 'integer';
    }
    elsif ($mode_h->{logical}) {
      $to_mode = 'logical';
    }
    $_ = $_->_as($to_mode) for @arrays;
  }
  
  return @arrays;
}


sub matrix {
  my $self = shift;
  
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};

  my ($_a1, $nrow, $ncol, $byrow, $dirnames) = @_;

  croak "matrix method need data as frist argument"
    unless defined $_a1;
  
  my $a1 = Rstats::Array->_to_a($_a1);
  
  # Row count
  $nrow = $opt->{nrow} unless defined $nrow;
  
  # Column count
  $ncol = $opt->{ncol} unless defined $ncol;
  
  # By row
  $byrow = $opt->{byrow} unless defined $byrow;
  
  my $a1_values = $a1->values;
  my $a1_length = @$a1_values;
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
    $matrix = $self->array(
      $a1_values,
      [$dim->[1], $dim->[0]],
    );
    
    $matrix = $self->t($matrix);
  }
  else {
    $matrix = $self->array($a1_values, $dim);
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
  
  return $self->c([Rstats::Logical->TRUE]);
}

sub is_vector {
  my $self = shift;
  
  my $is = @{$self->dim->values} == 0 ? Rstats::Logical->TRUE : Rstats::Logical->FALSE;
  
  return $self->c([$is]);
}

sub is_matrix {
  my $self = shift;

  my $is = @{$self->dim->values} == 2 ? Rstats::Logical->TRUE : Rstats::Logical->FALSE;
  
  return $self->c([$is]);
}

sub as_matrix {
  my $self = shift;
  
  my $a1_dim_values = $self->_real_dim_values;
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
  my $a1_dim_values = [@{$self->_real_dim_values}];
  
  return $self->array($a1_values, $a1_dim_values);
}

sub as_vector {
  my $self = shift;
  
  my $a1_values = [@{$self->values}];
  
  return $self->c($a1_values);
}

1;

