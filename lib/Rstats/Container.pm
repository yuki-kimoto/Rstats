package Rstats::Container;
use Object::Simple -base;

use Rstats::Func;
use Rstats::Container::List;
use Carp 'croak';

has 'elements' => sub { [] };

my %types_h = map { $_ => 1 } qw/character complex numeric double integer logical/;

sub _copy_attrs_to {
  my ($self, $x2, $new_indexs) = @_;
  
  # class
  $x2->{class} =  $self->{class} if exists $self->{class};

  # levels
  $x2->{levels} = $self->{levels} if exists $self->{levels};
  
  # names
  if (exists $self->{names}) {
    my $names = [];
    my $index = $self->is_data_frame ? $new_indexs->[1] : $new_indexs->[0];
    if (defined $index) {
      for my $i (@{$index->values}) {
        push @$names, $self->{names}[$i - 1];
      }
    }
    $x2->{names} = $names;
  }
  
  # dimnames
  if (exists $self->{dimnames}) {
    my $new_dimnames = [];
    my $dimnames = $self->{dimnames};
    my $length = @$dimnames;
    for (my $i = 0; $i < $length; $i++) {
      my $dimname = $dimnames->[$i];
      if (defined $dimname && @$dimname) {
        my $index = $new_indexs->[$i];
        my $new_dimname = [];
        for my $k (@{$index->values}) {
          push @$new_dimname, $dimname->[$k - 1];
        }
        push @$new_dimnames, $new_dimname;
      }
    }
    $x2->{dimnames} = $new_dimnames;
  }
}

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

sub str {
  my $self = shift;
  
  my @str;
  
  if ($self->is_vector || $self->is_array) {
    # Short type
    my $type = $self->{type};
    my $short_type;
    if ($type eq 'character') {
      $short_type = 'chr';
    }
    elsif ($type eq 'complex') {
      $short_type = 'cplx';
    }
    elsif ($type eq 'double') {
      $short_type = 'num';
    }
    elsif ($type eq 'integer') {
      $short_type = 'int';
    }
    elsif ($type eq 'logical') {
      $short_type = 'logi';
    }
    else {
      $short_type = 'Unkonown';
    }
    push @str, $short_type;
    
    # Dimention
    my @dim_str;
    my $length = $self->length_value;
    if (exists $self->{dim}) {
      for (my $i = 0; $i < @{$self->{dim}}; $i++) {
        my $d = $self->{dim}[$i];
        my $d_str;
        if ($d == 1) {
          $d_str = "1";
        }
        else {
          $d_str = "1:$d"
        }
        
        if (@{$self->{dim}} == 1) {
          $d_str .= "(" . ($i + 1) . "d)";
        }
        push @dim_str, $d_str;
      }
    }
    else {
      if ($length != 1) {
        push @dim_str, "1:$length";
      }
    }
    if (@dim_str) {
      my $dim_str = join(', ', @dim_str);
      push @str, "[$dim_str]";
    }
    
    # Elements
    my @element_str;
    my $max_count = $length > 10 ? 10 : $length;
    my $is_character = $self->is_character;
    my $elements = $self->elements;
    for (my $i = 0; $i < $max_count; $i++) {
      push @element_str, $self->_element_to_string($elements->[$i], $is_character);
    }
    if ($length > 10) {
      push @element_str, '...';
    }
    my $element_str = join(' ', @element_str);
    push @str, $element_str;
  }
  
  my $str = join(' ', @str);
  
  return $str;
}

sub levels {
  my $self = shift;
  
  if (@_) {
    my $x1_levels = Rstats::Func::to_c(shift);
    $x1_levels = $x1_levels->as_character unless $x1_levels->is_character;
    
    $self->{levels} = $x1_levels->values;
    
    return $self;
  }
  else {
    return exists $self->{levels} ? Rstats::Func::c($self->{levels}) : Rstats::Func::NULL();
  }
}

sub clone {
  my ($self, %opt) = @_;
  
  my $clone = {%$self};
  $clone = bless $clone, ref $self;
  $clone->{elements} = $opt{elements} if $opt{elements};
  
  return $clone;
}

sub at {
  my $x1 = shift;
  
  if (@_) {
    $x1->{at} = [@_];
    
    return $x1;
  }
  
  return $x1->{at};
}

sub _name_to_index {
  my $self = shift;
  my $x1_index = Rstats::Func::to_c(shift);
  
  my $e1_name = $x1_index->element;
  my $found;
  my $names = $self->names->elements;
  my $index;
  for (my $i = 0; $i < @$names; $i++) {
    my $name = $names->[$i];
    if (Rstats::ElementFunc::equal($e1_name, $name)) {
      $index = $i + 1;
      $found = 1;
      last;
    }
  }
  croak "Not found $e1_name" unless $found;
  
  return $index;
}

sub nlevels {
  my $self = shift;
  
  return Rstats::Func::c($self->levels->length_value);
}

sub length {
  my $self = shift;
  
  my $length = $self->length_value;
  
  return Rstats::Func::c($length);
}

sub length_value {
  my $self = shift;
  
  my $length = @{$self->elements};
  
  return $length;
}

sub is_na {
  my $_a1 = shift;
  
  my $x1 = Rstats::Func::to_c($_a1);
  
  my @a2_elements = map {
    ref $_ eq  'Rstats::Type::NA' ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE()
  } @{$x1->elements};
  my $x2 = Rstats::Func::array(\@a2_elements);
  $x2->mode('logical');
  
  return $x2;
}

sub as_list {
  my $container = shift;
  
  return $container if $container->is_list;

  my $list = Rstats::Container::List->new;
  $list->elements($container->elements);
  
  return $list;
}

sub is_list {
  my $container = shift;
  
  my $is_list;
  eval {
    $is_list = $container->isa('Rstats::Container::List');
  };

  return $is_list ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
}

sub class {
  my $self = shift;
  
  if (@_) {
    my $x_class = Rstats::Func::to_c($_[0]);
    
    $self->{class} = $x_class->values;
    
    return $self;
  }
  else {
    if (exists $self->{class}) {
      return Rstats::Func::c($self->{class});
    }
    elsif ($self->is_vector) {
      return Rstats::Func::c($self->mode);
    }
    elsif ($self->is_matrix) {
      return Rstats::Func::c('matrix');
    }
    elsif ($self->is_array) {
      return Rstats::Func::c('array');
    }
    elsif ($self->is_data_frame) {
      return Rstats::Func::c('data.frame');
    }
    elsif ($self->is_list) {
      return Rstats::Func::c('list');
    }
    else {
      Rstats::Func::NULL()
    }
  }
}

sub dim_as_array {
  my $x1 = shift;
  
  if ($x1->dim->length_value) {
    return $x1->dim;
  }
  else {
    my $length = $x1->length_value;
    return Rstats::Func::c($length);
  }
}

sub dim {
  my $self = shift;
  
  if (@_) {
    my $x_dim = Rstats::Func::to_c($_[0]);
    my $self_length = $self->length_value;
    my $self_lenght_by_dim = 1;
    $self_lenght_by_dim *= $_ for @{$x_dim->values};
    
    if ($self_length != $self_lenght_by_dim) {
      croak "dims [product $self_lenght_by_dim] do not match the length of object [$self_length]";
    }
  
    $self->{dim} = $x_dim->values;
    
    return $self;
  }
  else {
    return defined $self->{dim} ? Rstats::Func::c($self->{dim}) : Rstats::Func::NULL();
  }
}

sub mode {
  my $self = shift;
  
  if (@_) {
    my $type = $_[0];
    croak qq/Error in eval(expr, envir, enclos) : could not find function "as_$type"/
      unless $types_h{$type};
    
    if ($type eq 'numeric') {
      $self->{type} = 'double';
    }
    else {
      $self->{type} = $type;
    }
    
    return $self;
  }
  else {
    my $type = $self->{type};
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

    return Rstats::Func::c($mode);
  }
}

sub typeof {
  my $self = shift;
  
  my $type = $self->{type};
  my $x2_elements = defined $type ? $type : "NULL";
  my $x2 = Rstats::Func::c($x2_elements);
  
  return $x2;
}

sub type {
  my $self = shift;
  
  if (@_) {
    $self->{type} = $_[0];
    
    return $self;
  }
  else {
    return $self->{type};
  }
}

sub is_factor {
  my $self = shift;
  
  my $classes = $self->class->values;
  
  my $is = grep { $_ eq 'factor' } @$classes;
  
  return $is ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
}

sub is_ordered {
  my $self = shift;
  
  my $classes = $self->class->values;

  my $is = grep { $_ eq 'ordered' } @$classes;
  
  return $is ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
}

sub as_factor {
  my $self = shift;
  
  if ($self->is_factor) {
    return $self;
  }
  else {
    my $a = $self->is_character ? $self :  $self->as_character;
    my $f = Rstats::Func::factor($a);
    
    return $f;
  }
}

sub as_matrix {
  my $self = shift;
  
  my $self_dim_elements = $self->dim_as_array->values;
  my $self_dim_count = @$self_dim_elements;
  my $x2_dim_elements = [];
  my $row;
  my $col;
  if ($self_dim_count == 2) {
    $row = $self_dim_elements->[0];
    $col = $self_dim_elements->[1];
  }
  else {
    $row = 1;
    $row *= $_ for @$self_dim_elements;
    $col = 1;
  }
  
  my $x2_elements = [@{$self->elements}];
  
  return Rstats::Func::matrix($x2_elements, $row, $col);
}

sub as_array {
  my $self = shift;
  
  my $self_elements = [@{$self->elements}];
  my $self_dim_elements = [@{$self->dim_as_array->values}];
  
  return $self->array($self_elements, $self_dim_elements);
}

sub as_vector {
  my $self = shift;
  
  my $self_elements = [@{$self->elements}];
  
  return Rstats::Func::c($self_elements);
}

sub as {
  my ($self, $type) = @_;
  
  if ($type eq 'character') {
    return as_character($self);
  }
  elsif ($type eq 'complex') {
    return as_complex($self);
  }
  elsif ($type eq 'double') {
    return as_double($self);
  }
  elsif ($type eq 'numeric') {
    return as_numeric($self);
  }
  elsif ($type eq 'integer') {
    return as_integer($self);
  }
  elsif ($type eq 'logical') {
    return as_logical($self);
  }
  else {
    croak "Invalid mode is passed";
  }
}

sub as_complex {
  my $self = shift;

  my $x_tmp;
  if ($self->is_factor) {
    $x_tmp = $self->as_integer;
  }
  else {
    $x_tmp = $self;
  }

  my $x2;
  my $x_tmp_elements = $x_tmp->elements;
  my @a2_elements = map { $_->as('complex') } @$x_tmp_elements;
  $x2 = $x_tmp->clone(elements => \@a2_elements);
  $x2->{type} = 'complex';

  return $x2;
}

sub as_numeric { shift->as_double(@_) }

sub as_double {
  my $self = shift;
  
  my $x2;
  if ($self->is_factor) {
    my $x2_elements = map { $_->as_double } @{$self->elements};
    $x2 = Rstats::Func::c($self->elements);
    $x2->{type} = 'double';
  }
  else {
    my $self_elements = $self->elements;
    my @a2_elements = map { $_->as('double') } @$self_elements;
    $x2 = $self->clone(elements => \@a2_elements);
    $x2->{type} = 'double';
  }

  return $x2;
}

sub as_integer {
  my $self = shift;
  
  my $x2;
  if ($self->is_factor) {
    $x2 = Rstats::Func::c($self->elements);
    $x2->{type} = 'integer';
  }
  else {
   my $self_elements = $self->elements;
    my @a2_elements = map { $_->as_integer  } @$self_elements;
    $x2 = $self->clone(elements => \@a2_elements);
    $x2->{type} = 'integer';
  }

  return $x2;
}

sub as_logical {
  my $self = shift;
  
  my $x2;
  if ($self->is_factor) {
    $x2 = Rstats::Func::c($self->elements);
    $x2 = $x2->as_logical;
  }
  else {
    my $self_elements = $self->elements;
    my @a2_elements = map { $_->as_logical } @$self_elements;
    $x2 = $self->clone(elements => \@a2_elements);
    $x2->{type} = 'logical';
  }

  return $x2;
}

sub labels { shift->as_character(@_) }

sub as_character {
  my $self = shift;
  
  my $x2;
  if ($self->is_factor) {
    my $levels = {};
    my $x_levels = $self->levels;
    my $x_levels_elements = $x_levels->elements;
    my $levels_length = $x_levels->length->value;
    for (my $i = 1; $i <= $levels_length; $i++) {
      my $x_levels_element = $x_levels->elements->[$i - 1];
      $levels->{$i} = $x_levels_element->value;
    }

    my $self_elements =  $self->elements;
    my $x2_elements = [];
    for my $self_element (@$self_elements) {
      if ($self_element->is_na) {
        push @$x2_elements, Rstats::Func::NA();
      }
      else {
        my $value = $self_element->value;
        my $character = $levels->{$value};
        push @$x2_elements, "$character";
      }
    }
    $x2 = Rstats::Func::c($x2_elements);
  }
  else {
    my $self_elements = $self->elements;
    my @a2_elements = map { $_->as_character } @$self_elements;
    $x2 = $self->clone(elements => \@a2_elements);
    $x2->{type} = 'character';
  }

  return $x2;
}

sub values {
  my $self = shift;
  
  if (@_) {
    my @elements = map { Rstats::ElementFunc::element($_) } @{$_[0]};
    $self->{elements} = \@elements;
  }
  else {
    my @values = map { defined $_ ? $_->value : undef } @{$self->elements};
  
    return \@values;
  }
}

sub value {
  my $self = shift;
  
  my $e1 = $self->element(@_);
  
  return defined $e1 ? $e1->value : Rstats::ElementFunc::NA();
}

sub is_vector {
  my $self = shift;
  
  my $is = ref $self eq 'Rstats::Container::Array' && $self->dim->length_value == 0 ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
  return Rstats::Func::c($is);
}

sub is_matrix {
  my $self = shift;

  my $is = ref $self eq 'Rstats::Container::Array' && $self->dim->length_value == 2 ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
  return Rstats::Func::c($is);
}

sub is_numeric {
  my $self = shift;
  
  my $is = ($self->{type} || '') eq 'double' || ($self->{type} || '') eq 'integer'
    ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
  return Rstats::Func::c($is);
}

sub is_double {
  my $self = shift;
  
  my $is = ($self->{type} || '') eq 'double' ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
  return Rstats::Func::c($is);
}

sub is_integer {
  my $self = shift;
  
  my $is = ($self->{type} || '') eq 'integer' ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
  return Rstats::Func::c($is);
}

sub is_complex {
  my $self = shift;
  
  my $is = ($self->{type} || '') eq 'complex' ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
  return Rstats::Func::c($is);
}

sub is_character {
  my $self = shift;
  
  my $is = ($self->{type} || '') eq 'character' ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
  return Rstats::Func::c($is);
}

sub is_logical {
  my $self = shift;
  
  my $is = ($self->{type} || '') eq 'logical' ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
  return Rstats::Func::c($is);
}

sub is_data_frame {
  my $self = shift;
  
  return ref $self eq 'Rstats::Container::DataFrame' ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
}

sub is_array {
  my $self = shift;
  
  my $is = ref $self eq 'Rstats::Container::Array' && exists $self->{dim};
  
  return $is;
}

sub names {
  my $self = shift;
  
  if (@_) {
    my $names = Rstats::Func::to_c(shift);
    
    $names = $names->as_character unless $names->is_character;
    $self->{names} = $names->values;
    
    if ($self->is_data_frame) {
      $self->{dimnames}->[1] =[@$self->{names}];
    }
    
    return $self;
  }
  else {
    if (exists $self->{names}) {
      return Rstats::Func::c($self->{names});
    }
    else {
      return Rstats::Func::NULL();
    }
  }
}

sub dimnames {
  my $self = shift;
  
  if (@_) {
    my $dimnames_list = shift;
    if (ref $dimnames_list eq 'Rstats::Container::List') {
      my $length = $dimnames_list->length_value;
      my $dimnames = [];
      for (my $i = 0; $i < $length; $i++) {
        my $x_dimname = $dimnames_list->getin($i + 1);
        if ($x_dimname->is_character) {
          my $dimname = $x_dimname->values;
          push @$dimnames, $dimname;
        }
        else {
          croak "dimnames must be character list";
        }
      }
      $self->{dimnames} = $dimnames;

      if ($self->is_data_frame) {
        $self->{names} = [@{$self->{dimnames}->[1]}];
      }
    }
    else {
      croak "dimnames must be list";
    }
  }
  else {
    if (exists $self->{dimnames}) {
      return Rstats::Func::list(@{$self->{dimnames}});
    }
    else {
      return Rstats::Func::NULL();
    }
  }
}

sub rownames {
  my $self = shift;
  
  if (@_) {
    my $rownames = Rstats::Func::to_c(shift);
    
    if (exists $self->{dimnames}) {
      $self->{dimnames}->[0] = [@{$rownames->values}];
    }
    else {
      $self->{dimnames} = [[@{$rownames->values}], []];
    }
  }
  else {
    if (exists $self->{dimnames}) {
      return Rstats::Func::c($self->{dimnames}[0]);
    }
    else {
      return Rstats::Func::NULL()
    }
  }
}

sub colnames {
  my $self = shift;
  
  if (@_) {
    my $colnames = Rstats::Func::to_c(shift);
    
    if (exists $self->{dimnames}) {
      $self->{dimnames}->[1] = [@{$colnames->values}];
    }
    else {
      $self->{dimnames} = [[], [@{$colnames->values}]];
    }
  }
  else {
    if (exists $self->{dimnames}) {
      return Rstats::Func::c($self->{dimnames}[1]);
    }
    else {
      return Rstats::Func::NULL()
    }
  }
}

1;
