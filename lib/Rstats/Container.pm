package Rstats::Container;
use Object::Simple -base;

use Rstats::Func;
use Rstats::Container::List;
use Carp 'croak';

has 'elements' => sub { [] };

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
  
  my $self_elements = $self->elements;
  my $a2 = $self->clone_without_elements;
  my @a2_elements = map { $_->as('complex') } @$self_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'complex';

  return $a2;
}

sub as_numeric { as_double(@_) }

sub as_double {
  my $self = shift;
  
  my $self_elements = $self->elements;
  my $a2 = $self->clone_without_elements;
  my @a2_elements = map { $_->as('double') } @$self_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'double';

  return $a2;
}

sub as_integer {
  my $self = shift;
  
  my $self_elements = $self->elements;
  my $a2 = $self->clone_without_elements;
  my @a2_elements = map { $_->as_integer  } @$self_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'integer';

  return $a2;
}

sub as_logical {
  my $self = shift;
  
  my $self_elements = $self->elements;
  my $a2 = $self->clone_without_elements;
  my @a2_elements = map { $_->as_logical } @$self_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'logical';

  return $a2;
}

sub as_character {
  my $self = shift;

  my $self_elements = $self->elements;
  my @a2_elements = map { $_->as_character } @$self_elements;
  my $a2 = $self->clone_without_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'character';

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

sub is_ordered {
  my $self = shift;
  
  my $is = defined $self->{ordered} ? $self->{ordered} : Rstats::Func::FALSE();
  
  return $is;
}

sub is_vector {
  my $self = shift;
  
  my $is = @{$self->dim->elements} == 0 ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
  return Rstats::Func::c($is);
}

sub is_matrix {
  my $self = shift;

  my $is = @{$self->dim->elements} == 2 ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
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
    my $names = Rstats::Func::to_array(shift);
    
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
      my $length = $dimnames->_length;
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
    my $colnames = Rstats::Func::to_array(shift);
    
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
    my $rownames = Rstats::Func::to_array(shift);
    
    $self->dimnames->at(2)->set($rownames);
  }
  else {
    my $rownames = $self->dimnames->get(2);
    return defined $rownames ? $rownames : Rstats::Func::NULL();
  }
}

1;
