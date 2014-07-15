package Rstats::Array;
use Object::Simple -base;

use Carp 'croak', 'carp';
use Rstats::ArrayUtil;
use Rstats::Util;

our @CARP_NOT = ('Rstats');

use overload
  bool => \&bool,
  '+' => sub { shift->_operation('add', @_) },
  '-' => sub { shift->_operation('subtract', @_) },
  '*' => sub { shift->_operation('multiply', @_) },
  '/' => sub { shift->_operation('divide', @_) },
  '%' => sub { shift->_operation('remainder', @_) },
  'neg' => \&negation,
  '**' => sub { shift->_operation('raise', @_) },
  'x' => sub { shift->inner_product(@_) },
  '<' => sub { shift->_operation('less_than', @_) },
  '<=' => sub { shift->_operation('less_than_or_equal', @_) },
  '>' => sub { shift->_operation('more_than', @_) },
  '>=' => sub { shift->_operation('more_than_or_equal', @_) },
  '==' => sub { shift->_operation('equal', @_) },
  '!=' => sub { shift->_operation('not_equal', @_) },
  '""' => \&to_string,
  fallback => 1;

has 'elements';

sub bool {
  my $self = shift;
  
  my $length = @{$self->elements};
  if ($length == 0) {
    croak 'Error in if (a) { : argument is of length zero';
  }
  elsif ($length > 1) {
    carp 'In if (a) { : the condition has length > 1 and only the first element will be used';
  }
  
  my $element = $self->element;
  
  return Rstats::Util::bool($element);
}

sub element {
  my $array = shift;
  
  my $dim_values = Rstats::ArrayUtil::dim_as_array($array)->values;
  
  if (@_) {
    if (@$dim_values == 1) {
      return $array->elements->[$_[0] - 1];
    }
    elsif (@$dim_values == 2) {
      return $array->elements->[($_[0] + $dim_values->[0] * ($_[1] - 1)) - 1];
    }
    else {
      return $array->get(@_)->elements->[0];
    }
  }
  else {
    return $array->elements->[0];
  }
}

sub inner_product {
  my ($self, $data, $reverse) = @_;
  
  # fix postion
  my ($a1, $a2) = $self->_fix_position($data, $reverse);
  
  # Upgrade type if type is different
  ($a1, $a2) = Rstats::ArrayUtil::upgrade_type($a1, $a2) if $a1->{type} ne $a2->{type};

  return Rstats::ArrayUtil::inner_product($a1, $a2);
}

sub to_string {
  my $self = shift;

  my $elements = $self->elements;
  
  my $dim_values = Rstats::ArrayUtil::dim_as_array($self)->values;
  
  my $dim_length = @$dim_values;
  my $dim_num = $dim_length - 1;
  my $positions = [];
  
  my $str;
  if (@$elements) {
    if ($dim_length == 1) {
      my $names = Rstats::ArrayUtil::names($self)->values;
      if (@$names) {
        $str .= join(' ', @$names) . "\n";
      }
      my @parts = map { Rstats::Util::to_string($_) } @$elements;
      $str .= '[1] ' . join(' ', @parts) . "\n";
    }
    elsif ($dim_length == 2) {
      $str .= '     ';
      
      my $colnames = Rstats::ArrayUtil::colnames($self)->values;
      if (@$colnames) {
        $str .= join(' ', @$colnames) . "\n";
      }
      else {
        for my $d2 (1 .. $dim_values->[1]) {
          $str .= $d2 == $dim_values->[1] ? "[,$d2]\n" : "[,$d2] ";
        }
      }
      
      my $rownames = Rstats::ArrayUtil::rownames($self)->values;
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
          push @parts, Rstats::Util::to_string($self->element($d1, $d2));
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
              
              my @parts;
              for my $d2 (1 .. $dim_values[1]) {
                push @parts, Rstats::Util::to_string($self->element($d1, $d2, @$positions));
              }
              
              $str .= join(' ', @parts) . "\n";
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
  
  my $a1_elements = [map { Rstats::Util::negation($_) } @{$self->elements}];
  my $a1 = $self->clone_without_elements;
  $a1->elements($a1_elements);
  
  return $a1;
}

sub _operation {
  my ($self, $op, $data, $reverse) = @_;
  
  # fix postion
  my ($a1, $a2) = $self->_fix_position($data, $reverse);
  
  # Upgrade mode if mode is different
  ($a1, $a2) = Rstats::ArrayUtil::upgrade_type($a1, $a2) if $a1->{type} ne $a2->{type};
  
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

sub clone_without_elements {
  my ($self, %opt) = @_;
  
  my $array = Rstats::Array->new;
  $array->{type} = $self->{type};
  $array->{names} = [@{$self->{names} || []}];
  $array->{rownames} = [@{$self->{rownames} || []}];
  $array->{colnames} = [@{$self->{colnames} || []}];
  $array->{dim} = [@{$self->{dim} || []}];
  $array->{elements} = $opt{elements} ? $opt{elements} : [];
  
  return $array;
}

sub values {
  my $self = shift;
  
  if (@_) {
    my @elements = map { Rstats::Util::element($_) } @{$_[0]};
    $self->{elements} = \@elements;
  }
  else {
    my @values = map { Rstats::Util::value($_) } @{$self->elements};
  
    return \@values;
  }
}

sub value { Rstats::Util::value(shift->element(@_)) }

sub at {
  my $self = shift;
  
  if (@_) {
    $self->{at} = [@_];
    
    return $self;
  }
  
  return $self->{at};
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
    my @elements2 = grep { $_indexs->[0]->() } @{$self->values};
    return Rstats::ArrayUtil::c(\@elements2);
  }

  my ($positions, $a2_dim) = Rstats::ArrayUtil::parse_index($self, $drop, @$_indexs);
  
  my @a2_elements = map { $self->elements->[$_ - 1] ? $self->elements->[$_ - 1] : Rstats::Util::NA } @$positions;
  
  return Rstats::ArrayUtil::array(\@a2_elements, $a2_dim);
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
    $array = Rstats::ArrayUtil::to_array($_array);
  }
  
  my ($positions, $a2_dim) = Rstats::ArrayUtil::parse_index($self, 0, @$_indexs);
  
  my $self_elements = $self->elements;
  if ($code) {
    for (my $i = 0; $i < @$positions; $i++) {
      my $pos = $positions->[$i];
      local $_ = Rstats::Util::value($self_elements->[$pos - 1]);
      $self_elements->[$pos - 1] = Rstats::Util::element($code->());
    }
  }
  else {
    my $array_elements = $array->elements;
    for (my $i = 0; $i < @$positions; $i++) {
      my $pos = $positions->[$i];
      $self_elements->[$pos - 1] = $array_elements->[(($i + 1) % @$positions) - 1];
    }
  }
  
  return $self;
}

sub _fix_position {
  my ($self, $data, $reverse) = @_;
  
  my $a1;
  my $a2;
  if (ref $data eq 'Rstats::Array') {
    $a1 = $self;
    $a2 = $data;
  }
  else {
    if ($reverse) {
      $a1 = Rstats::ArrayUtil::c($data);
      $a2 = $self;
    }
    else {
      $a1 = $self;
      $a2 = Rstats::ArrayUtil::c($data);
    }
  }
  
  return ($a1, $a2);
}



1;

