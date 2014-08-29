package Rstats::Container;
use Object::Simple -base;

use Rstats::Func;
use Rstats::Container::List;
use Carp 'croak';

has 'elements' => sub { [] };

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
  my $a1 = shift;
  
  my $is = defined $a1->{ordered} ? $a1->{ordered} : Rstats::Func::FALSE();
  
  return $is;
}

sub is_vector {
  my $a1 = shift;
  
  my $is = @{$a1->dim->elements} == 0 ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
  return Rstats::Func::c($is);
}

sub is_matrix {
  my $a1 = shift;

  my $is = @{$a1->dim->elements} == 2 ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
  return Rstats::Func::c($is);
}

sub is_numeric {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'double' || ($a1->{type} || '') eq 'integer'
    ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
  return Rstats::Func::c($is);
}

sub is_double {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'double' ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
  return Rstats::Func::c($is);
}

sub is_integer {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'integer' ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
  return Rstats::Func::c($is);
}

sub is_complex {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'complex' ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
  return Rstats::Func::c($is);
}

sub is_character {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'character' ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
  return Rstats::Func::c($is);
}

sub is_logical {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'logical' ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  
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
        my $a1 = $dimnames->get($i);
        if (!$a1->is_character) {
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
