package Rstats::Container;
use Object::Simple -base;

use Rstats::ArrayAPI;
use Rstats::Container::List;
use Carp 'croak';

has 'elements' => sub { [] };

sub new {
  my $self = shift->SUPER::new(@_);
  
  $self->{dimnames} = [];
  
  return $self;
}

sub is_array { Rstats::ArrayAPI::FALSE() }
sub is_data_frame { Rstats::ArrayAPI::FALSE() }

sub names {
  my $self = shift;
  
  if (@_) {
    my $_names = shift;
    my $names;
    if (ref $_names eq 'Rstats::Container::Array') {
      $names = $_names->elements;
    }
    elsif (!defined $_names) {
      $names = [];
    }
    elsif (ref $_names eq 'ARRAY') {
      $names = $_names;
    }
    else {
      $names = [$_names];
    }
    
    $self->{names} = $names;
  }
  else {
    $self->{names} = [] unless exists $self->{names};
    return Rstats::ArrayAPI::c($self->{names});
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
    my $colnames = Rstats::ArrayAPI::to_array(shift);
    
    $self->dimnames->at(1)->set($colnames);
  }
  else {
    my $colnames = $self->dimnames->get(1);
    return defined $colnames ? $colnames : Rstats::ArrayAPI::NULL();
  }
}

sub rownames {
  my $self = shift;
  
  if (@_) {
    my $rownames = Rstats::ArrayAPI::to_array(shift);
    
    $self->dimnames->at(2)->set($rownames);
  }
  else {
    my $rownames = $self->dimnames->get(2);
    return defined $rownames ? $rownames : Rstats::ArrayAPI::NULL();
  }
}

1;
