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

sub r { Rstats->new }

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

sub new {
  my $self = shift->SUPER::new(@_);
  
  $self->{values} ||= [];
  $self->{type} ||= 'array';
  if (defined $self->{dim}) {
    $self->dim($self->{dim});
  }
  else {
    my $length = @{$self->{values}};
    $self->dim([$length]);
  }
  $self->{mode} = 'numeric' unless $self->{mode};
  
  return $self;
}

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
    my $dim = $self->{dim};
    my $length = @$dim;
    
    my $v1 = Rstats::Array->new(
      values => $dim,
      type => 'matrix',
      dim => [$length]
    );
    
    return $v1;
  } 
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
    return Rstats::Array->new(values => \@values2, type => 'vector');
  }

  my ($positions, $a2_dim) = $self->_parse_index($drop, @$_indexs);
  
  my @a2_values = map { $self->values->[$_ - 1] } @$positions;
  
  return Rstats::Array->new(values => \@a2_values, dim => $a2_dim);
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
    $array = $self->r->_v($_array);
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
    
    my $index = $self->r->_v($_index);
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
          for my $self_name (@{$self->r->names($self)->values}) {
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
  my $names_v = $r->names($self);
  if ($names_v) {
    $str .= join(' ', @{$names_v->values}) . "\n";
  }
  
  my $dim_values = $self->r->dim($self)->values;
  
  my $dim_length = @$dim_values;
  my $dim_num = $dim_length - 1;
  my $postions = [];
  if (@$values) {
    if ($dim_length == 1) {
      $str .= '[1] ' . join(' ', @$values) . "\n";
    }
    else {
      my $code;
      $code = sub {
        my (@dim_values) = @_;
        my $dim_value = pop @dim_values;
        
        for (my $i = 1; $i <= $dim_value; $i++) {
          $str .= (',' x $dim_num) . "$i"
            . (',' x ($dim_length - $dim_num - 1)) . "\n";
          if (@dim_values > 2) {
            $dim_num--;
            $code->(@dim_values);
            $dim_num++;
          }
          else {
            $str .= "ppp\n";
          }
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
  
  my $v2 = $self->new;
  my $v1_values = $self->values;
  my $v2_values = $v2->values;
  $v2_values->[$_] = -$v1_values->[$_] for (0 .. @$v1_values - 1);
  
  return $v2;
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
  
  return $self->new(values => \@v3_values);
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

