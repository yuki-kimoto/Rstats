package Rstats::Container;
use Object::Simple -base;

use Rstats::Func;
use Rstats::Container::List;
use Carp 'croak';

has 'elements' => sub { [] };

my %types_h = map { $_ => 1 } qw/character complex numeric double integer logical/;

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
  
  my $a1 = Rstats::Func::to_c($_a1);
  
  my @a2_elements = map {
    ref $_ eq  'Rstats::Type::NA' ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::Func::array(\@a2_elements);
  $a2->mode('logical');
  
  return $a2;
}

sub as_list {
  my $container = shift;
  
  return $container if Rstats::Func::is_list($container);

  my $list = Rstats::Container::List->new;
  $list->elements($container->elements);
  
  return $list;
}

sub class {
  my $self = shift;
  
  if (@_) {
    my $a_class = Rstats::Func::to_c($_[0]);
    
    $self->{class} = [$a_class->elements];
    
    return $self;
  }
  else {
    $self->{class} = [] unless defined $self->{class};
    return Rstats::Func::c($self->{class});
  }
}

sub dim_as_array {
  my $a1 = shift;
  
  if ($a1->dim->length_value) {
    return $a1->dim;
  }
  else {
    my $length = $a1->length_value;
    return Rstats::Func::c($length);
  }
}

sub dim {
  my $self = shift;
  
  if (@_) {
    my $a_dim = Rstats::Func::to_c($_[0]);
    my $self_length = $self->length_value;
    my $self_lenght_by_dim = 1;
    $self_lenght_by_dim *= $_ for @{$a_dim->values};
    
    if ($self_length != $self_lenght_by_dim) {
      croak "dims [product $self_lenght_by_dim] do not match the length of object [$self_length]";
    }
  
    $self->{dim} = [$a_dim->elements];
    
    return $self;
  }
  else {
    $self->{dim} = [] unless defined $self->{dim};
    return Rstats::Func::c($self->{dim});
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
  my $a2_elements = defined $type ? $type : "NULL";
  my $a2 = Rstats::Func::c($a2_elements);
  
  return $a2;
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
  my $a2_dim_elements = [];
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
  
  my $a2_elements = [@{$self->elements}];
  
  return Rstats::Func::matrix($a2_elements, $row, $col);
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

  my $a_tmp;
  if ($self->is_factor) {
    $a_tmp = $self->as_integer;
  }
  else {
    $a_tmp = $self;
  }

  my $a2;
  my $a_tmp_elements = $a_tmp->elements;
  $a2 = $a_tmp->clone_without_elements;
  my @a2_elements = map { $_->as('complex') } @$a_tmp_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'complex';

  return $a2;
}

sub as_numeric { shift->as_double(@_) }

sub as_double {
  my $self = shift;
  
  my $a2;
  if ($self->is_factor) {
    my $a2_elements = map { $_->as_double } @{$self->elements};
    $a2 = Rstats::Func::c($self->elements);
    $a2->{type} = 'double';
  }
  else {
    my $self_elements = $self->elements;
    $a2 = $self->clone_without_elements;
    my @a2_elements = map { $_->as('double') } @$self_elements;
    $a2->elements(\@a2_elements);
    $a2->{type} = 'double';
  }

  return $a2;
}

sub as_integer {
  my $self = shift;
  
  my $a2;
  if ($self->is_factor) {
    $a2 = Rstats::Func::c($self->elements);
    $a2->{type} = 'integer';
  }
  else {
   my $self_elements = $self->elements;
    $a2 = $self->clone_without_elements;
    my @a2_elements = map { $_->as_integer  } @$self_elements;
    $a2->elements(\@a2_elements);
    $a2->{type} = 'integer';
  }

  return $a2;
}

sub as_logical {
  my $self = shift;
  
  my $a2;
  if ($self->is_factor) {
    $a2 = Rstats::Func::c($self->elements);
    $a2 = $a2->as_logical;
  }
  else {
    my $self_elements = $self->elements;
    $a2 = $self->clone_without_elements;
    my @a2_elements = map { $_->as_logical } @$self_elements;
    $a2->elements(\@a2_elements);
    $a2->{type} = 'logical';
  }

  return $a2;
}

sub labels { shift->as_character(@_) }

sub as_character {
  my $self = shift;
  
  my $a2;
  if ($self->is_factor) {
    my $levels = {};
    my $a_levels = $self->levels;
    my $a_levels_elements = $a_levels->elements;
    my $levels_length = $a_levels->length->value;
    for (my $i = 1; $i <= $levels_length; $i++) {
      my $a_levels_element = $a_levels->elements->[$i - 1];
      $levels->{$i} = $a_levels_element->value;
    }

    my $self_elements =  $self->elements;
    my $a2_elements = [];
    for my $self_element (@$self_elements) {
      if ($self_element->is_na) {
        push @$a2_elements, Rstats::Funcc::NA();
      }
      else {
        my $value = $self_element->value;
        my $character = $levels->{$value};
        push @$a2_elements, "$character";
      }
    }
    $a2 = Rstats::Func::c($a2_elements);
  }
  else {
    my $self_elements = $self->elements;
    my @a2_elements = map { $_->as_character } @$self_elements;
    $a2 = $self->clone_without_elements;
    $a2->elements(\@a2_elements);
    $a2->{type} = 'character';
  }

  return $a2;
}

sub new {
  my $self = shift->SUPER::new(@_);
  
  $self->{names} ||= [];
  $self->{dimnames} ||= [];
  
  return $self;
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
  
  my $is = $self->dim->length_value == 0 ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
  return Rstats::Func::c($is);
}

sub is_matrix {
  my $self = shift;

  my $is = $self->dim->length_value == 2 ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
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

sub is_array { Rstats::Func::FALSE() }
sub is_data_frame { Rstats::Func::FALSE() }

sub names {
  my $self = shift;
  
  if (@_) {
    my $names = Rstats::Func::to_c(shift);
    
    $self->{names} = $names->elements;
    
    return $self;
  }
  else {
    return Rstats::Func::c($self->{names});
  }
}

sub dimnames {
  my $self = shift;
  
  if (@_) {
    my $dimnames = shift;
    if (ref $dimnames eq 'Rstats::Container::List') {
      my $length = $dimnames->length_value;
      for (my $i = 0; $i < $length; $i++) {
        my $self = $dimnames->get($i);
        if (!$self->is_character) {
          croak "dimnames must be character list";
        }
      }
      $self->{dimnames} = $dimnames->elements;
    }
    else {
      croak "dimnames must be list";
    }
  }
  else {
    return Rstats::Container::List->new(elements => $self->{dimnames});
  }
}

sub colnames {
  my $self = shift;
  
  if (@_) {
    my $colnames = Rstats::Func::to_c(shift);
    
    $self->dimnames->at(1)->set($colnames);
  }
  else {
    my $colnames = $self->dimnames->get(1);
    return defined $colnames ? $colnames : Rstats::Func::NULL();
  }
}

sub rownames {
  my $self = shift;
  
  if (@_) {
    my $rownames = Rstats::Func::to_c(shift);
    
    $self->dimnames->at(2)->set($rownames);
  }
  else {
    my $rownames = $self->dimnames->get(2);
    return defined $rownames ? $rownames : Rstats::Func::NULL();
  }
}

1;
