package Rstats::Array;
use Object::Simple -base;
use Carp 'croak';
use List::Util;
use Rstats;

use overload
  bool => sub {1},
  '+' => \&add,
  '-' => \&subtract,
  '*' => \&multiply,
  '/' => \&divide,
  'neg' => \&negation,
  '**' => \&raise,
  '""' => \&to_string,
  fallback => 1;

has 'values';
has 'type';
has 'mode';

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
    
    my $v1 = $self->array($values, {type => 'vector'});
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
  
  # Type
  my $type = $opt->{type} || 'array';
  $array->type($type);
  
  # Mode
  my $mode = $opt->{mode} || 'numeric';
  $array->mode($mode);
  
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

sub value { shift->{values}[0] }

my $r = Rstats->new;

sub is_numeric { (shift->{mode} || '') eq 'numeric' }
sub is_integer { (shift->{mode} || '') eq 'integer' }
sub is_complex { (shift->{mode} || '') eq 'complex' }
sub is_character { (shift->{mode} || '') eq 'character' }
sub is_logical { (shift->{mode} || '') eq 'logical' }

sub as_numeric {
  my $self = shift;

  $self->{mode} = 'numeric';

  return $self;
}

sub as_integer {
  my $self = shift;

  $self->{mode} = 'integer';

  return $self;
}

sub as_complex {
  my $self = shift;

  $self->{mode} = 'complex';

  return $self;
}

sub as_character {
  my $self = shift;

  $self->{mode} = 'character';

  return $self;
}

sub as_logical {
  my $self = shift;

  $self->{mode} = 'logical';

  return $self;
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
    return Rstats::Array->array(\@values2,{type => 'vector'});
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
  
  my $vector = $self->array($data, {type => 'vector'});
  
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
  my $a1_dim = [@{$self->dim->values}];
  my $type = $self->type;
  if ($type eq 'vector') {
  
  }
  elsif ($type eq 'matrix') {
    
  }
  else {
    
  }
  
  my @indexs;
  my @a2_dim;
  
  for (my $i = 0; $i < @$a1_dim; $i++) {
    my $_index = $_indexs[$i];
    
    $_index = '' unless defined $_index;
    
    my $index = Rstats::Array->_v($_index);
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
    
    push @indexs, $index;
    
    if (!@{$index->values}) {
      my $index_value_new = [1 .. $a1_dim->[$i]];
      $index->values($index_value_new);
    }
    elsif ($index->is_character) {
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
    elsif ($index->is_logical) {
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

  my $str;
  
  my $dim_values = $self->dim->values;
  
  my $dim_length = @$dim_values;
  my $dim_num = $dim_length - 1;
  my $positions = [];
  my $type = $self->{type};
  
  my $output_type;
  if ($type eq 'vector') {
    $output_type = 'vector';
  }
  elsif ($type eq 'matrix') {
    $output_type = 'matrix';
  }
  elsif ($type eq 'array') {
    if ($dim_length == 1) {
      $output_type = 'vector';
    }
    elsif ($dim_length == 2) {
      $output_type = 'matrix';
    }
    else {
      $output_type = 'array';
    }
  }
  
  if (@$values) {
    if ($output_type eq 'vector') {
      my $names = $self->names->values;
      if (@$names) {
        $str .= join(' ', @$names) . "\n";
      }
      $str .= '[1] ' . join(' ', @$values) . "\n";
    }
    elsif ($output_type eq 'matrix') {
      $str .= '     ';
      
      my $dim_values0;
      my $dim_values1;
      if ($dim_length == 1) {
        $dim_values0 = $dim_values->[0];
        $dim_values1 = 1;
      }
      elsif ($dim_length == 2) {
        $dim_values0 = $dim_values->[0];
        $dim_values1 = $dim_values->[1];
      }
      elsif ($dim_length > 2) {
        $dim_values0 = 1;
        $dim_values0 *= $_ for @$dim_values;
        $dim_values1 = 1;
      }
      
      my $colnames = $self->colnames->values;
      if (@$colnames) {
        $str .= join(' ', @$colnames) . "\n";
      }
      else {
        for my $d2 (1 .. $dim_values1) {
          $str .= $d2 == $dim_values1 ? "[,$d2]\n" : "[,$d2] ";
        }
      }
      
      my $rownames = $self->rownames->values;
      my $use_rownames = @$rownames ? 1 : 0;
      for my $d1 (1 .. $dim_values0) {
        if ($use_rownames) {
          my $rowname = $rownames->[$d1 - 1];
          $str .= "$rowname ";
        }
        else {
          $str .= "[$d1,] ";
        }
        
        my @values;
        for my $d2 (1 .. $dim_values1) {
          push @values, $self->get($d1, $d2, @$positions)->value;
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
                push @values, $self->get($d1, $d2, @$positions)->value;
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

my $culcs = {};
my @ops = qw#+ - * / **#;
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

sub is_array {
  my $self = shift;
  
  return $self->{type} eq 'array';
}

sub is_vector {
  my $self = shift;
  
  return $self->{type} eq 'vector';
}

sub is_matrix {
  my $self = shift;
  
  return $self->{type} eq 'matrix';
}

sub as_matrix {
  my $self = shift;
  
  $self->{type} = 'matrix';
  
  return $self;
}

sub as_array {
  my $self = shift;
  
  $self->{type} = 'array';
  
  return $self;
}

sub as_vector {
  my $self = shift;
  
  $self->{type} = 'vector';
  
  return $self;
}

1;

