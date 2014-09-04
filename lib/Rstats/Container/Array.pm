package Rstats::Container::Array;
use Rstats::Container -base;

use Rstats::ElementFunc;
use Rstats::Func;
use Rstats::Util;
use Carp 'croak', 'carp';

our @CARP_NOT = ('Rstats');

use overload
  bool => \&bool,
  '+' => sub { shift->operation('add', @_) },
  '-' => sub { shift->operation('subtract', @_) },
  '*' => sub { shift->operation('multiply', @_) },
  '/' => sub { shift->operation('divide', @_) },
  '%' => sub { shift->operation('remainder', @_) },
  'neg' => sub { shift->negation(@_) },
  '**' => sub { shift->operation('raise', @_) },
  'x' => sub { shift->inner_product(@_) },
  '<' => sub { shift->operation('less_than', @_) },
  '<=' => sub { shift->operation('less_than_or_equal', @_) },
  '>' => sub { shift->operation('more_than', @_) },
  '>=' => sub { shift->operation('more_than_or_equal', @_) },
  '==' => sub { shift->operation('equal', @_) },
  '!=' => sub { shift->operation('not_equal', @_) },
  '""' => sub { shift->to_string(@_) },
  fallback => 1;

sub _element_to_string {
  my ($self, $element, $is_character, $is_factor) = @_;
  
  my $string;
  if ($is_factor) {
    if ($element->is_na) {
      $string = '<NA>';
    }
    else {
      $string = "$element";
    }
  }
  else {
    if ($is_character) {
      $string = '"' . $element . '"';
    }
    else {
      $string = "$element";
    }
  }
  
  return $string;
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

  my $elements = $self->elements;
  
  my $dim_values = $self->dim_as_array->values;
  
  my $dim_length = @$dim_values;
  my $dim_num = $dim_length - 1;
  my $positions = [];
  
  my $str;
  if (@$elements) {
    if ($dim_length == 1) {
      my $names = $self->names->values;
      if (@$names) {
        $str .= join(' ', @$names) . "\n";
      }
      my @parts = map { $self->_element_to_string($_, $is_character, $is_factor) } @$elements;
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
          my $part = $self->element($d1, $d2);
          push @parts, $self->_element_to_string($part, $is_character, $is_factor);
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
            my $a_dimnames = $self->dimnames->get($i);
            my $dimnames = defined $a_dimnames ? $a_dimnames->values : [];
            
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
                my $part = $self->element($d1, $d2, @$positions);
                push @parts, $self->_element_to_string($part, $is_character, $is_factor);
              }
              
              $str .= join(' ', @parts) . "\n";
            }
          }
          shift @$positions;
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

sub is_finite {
  my $_a1 = shift;

  my $a1 = Rstats::Func::to_c($_a1);
  
  my @a2_elements = map {
    !ref $_ || ref $_ eq 'Rstats::Type::Complex' || ref $_ eq 'Rstats::Logical' 
      ? Rstats::ElementFunc::TRUE()
      : Rstats::ElementFunc::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::Func::array(\@a2_elements);
  $a2->mode('logical');
  
  return $a2;
}

sub is_infinite {
  my $_a1 = shift;
  
  my $a1 = Rstats::Func::to_c($_a1);
  
  my @a2_elements = map {
    ref $_ eq 'Rstats::Inf' ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::Func::c(\@a2_elements);
  $a2->mode('logical');
  
  return $a2;
}

sub is_nan {
  my $_a1 = shift;
  
  my $a1 = Rstats::Func::to_c($_a1);
  
  my @a2_elements = map {
    ref $_ eq  'Rstats::NaN' ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::Func::array(\@a2_elements);
  $a2->mode('logical');
  
  return $a2;
}

sub is_null {
  my $_a1 = shift;
  
  my $a1 = Rstats::Func::to_c($_a1);
  
  my @a2_elements = [!$a1->length_value ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE()];
  my $a2 = Rstats::Func::array(\@a2_elements);
  $a2->mode('logical');
  
  return $a2;
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
  
  if (ref $_indexs->[0] eq 'CODE') {
    my @elements2 = grep { $_indexs->[0]->() } @{$self->values};
    return Rstats::Func::c(\@elements2);
  }
  
  my ($positions, $a2_dim, $new_indexs) = Rstats::Util::parse_index($self, $dim_drop, @$_indexs);
  
  my @a2_elements = map { defined $self->elements->[$_ - 1] ? $self->elements->[$_ - 1] : Rstats::ElementFunc::NA() } @$positions;
  
  # array
  my $a2 = Rstats::Func::array(\@a2_elements, $a2_dim);

  # class
  $a2->{class} =  $self->{class} if exists $self->{class};

  # levels
  $a2->{levels} = $self->{levels} if exists $self->{levels};
  
  # level drop
  if ($level_drop) {
    $a2 = Rstats::Func::factor($a2->as_character);
  }
  
  # names
  if (exists $self->{names}) {
    my $names = [];
    my $index = $new_indexs->[0];
    if (defined $index) {
      for my $i (@{$index->values}) {
        push @$names, $self->{names}[$i - 1];
      }
    }
    $a2->{names} = $names;
  }
  
  # dimnames
  if (exists $self->{dimnames}) {
    my $new_dimnames = [];
    my $dimnames = $self->{dimnames};
    my $length = @$dimnames;
    for (my $i = 0; $i < $length; $i++) {
      my $dimname = $dimnames->[$i];
      if (defined $dimname && !$dimname->is_null) {
        my $index = $new_indexs->[$i];
        my $new_dimname = [];
        for my $k (@{$index->values}) {
          push @$new_dimname, $dimname->get($k);
        }
        push @$new_dimnames, Rstats::Func::c($new_dimname);
      }
    }
    $a2->{dimnames} = $new_dimnames;
  }
  
  return $a2;
}

sub set {
  my ($self, $_a2) = @_;

  my $at = $self->at;
  my $_indexs = ref $at eq 'ARRAY' ? $at : [$at];
  
  my $a2 = Rstats::Func::to_c($_a2);

  my ($positions, $a2_dim) = Rstats::Util::parse_index($self, 0, @$_indexs);
  
  my $self_elements = $self->elements;
  

  my $a2_elements = $a2->elements;
  for (my $i = 0; $i < @$positions; $i++) {
    my $pos = $positions->[$i];
    $self_elements->[$pos - 1] = $a2_elements->[(($i + 1) % @$positions) - 1];
  }
  
  return $self;
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

  my $element = $self->element;
  
  return !!$element;
}

sub element {
  my $self = shift;
  
  my $dim_values = $self->dim_as_array->values;
  
  if (@_) {
    if (@$dim_values == 1) {
      return $self->elements->[$_[0] - 1];
    }
    elsif (@$dim_values == 2) {
      return $self->elements->[($_[0] + $dim_values->[0] * ($_[1] - 1)) - 1];
    }
    else {
      return $self->get(@_)->elements->[0];
    }
  }
  else {
    return $self->elements->[0];
  }
}

sub inner_product {
  my ($self, $data, $reverse) = @_;
  
  # fix postion
  my ($a1, $a2) = $self->_fix_position($data, $reverse);
  
  return Rstats::Func::inner_product($a1, $a2);
}

sub negation { Rstats::Func::negation(@_) }

sub operation {
  my ($self, $op, $data, $reverse) = @_;
  
  # fix postion
  my ($a1, $a2) = $self->_fix_position($data, $reverse);
  
  return Rstats::Func::operation($op, $a1, $a2);
}

sub _fix_position {
  my ($self, $data, $reverse) = @_;
  
  my $a1;
  my $a2;
  if (ref $data eq 'Rstats::Container::Array') {
    $a1 = $self;
    $a2 = $data;
  }
  else {
    if ($reverse) {
      $a1 = Rstats::Func::c($data);
      $a2 = $self;
    }
    else {
      $a1 = $self;
      $a2 = Rstats::Func::c($data);
    }
  }
  
  return ($a1, $a2);
}

1;
