package Rstats::Container;
use Object::Simple -base;

use Rstats::ArrayAPI;

has 'elements' => sub { [] };

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
  my ($self, $l1) = @_;
  
  if (@_) {
    my $_colnames = shift;
    my $colnames;
    if (ref $_colnames eq 'Rstats::Container::Array') {
      $colnames = $_colnames->elements;
    }
    elsif (!defined $_colnames) {
      $colnames = [];
    }
    elsif (ref $_colnames eq 'ARRAY') {
      $colnames = $_colnames;
    }
    else {
      $colnames = [$_colnames];
    }

    $self->{colnames} = $colnames;
  }
  else {
    $self->{colnames} = [] unless exists $self->{colnames};
    return Rstats::ArrayAPI::c($self->{colnames});
  }
}

sub colnames {
  my $self = shift;
  
  if (@_) {
    my $_colnames = shift;
    my $colnames;
    if (ref $_colnames eq 'Rstats::Container::Array') {
      $colnames = $_colnames->elements;
    }
    elsif (!defined $_colnames) {
      $colnames = [];
    }
    elsif (ref $_colnames eq 'ARRAY') {
      $colnames = $_colnames;
    }
    else {
      $colnames = [$_colnames];
    }
    
    $self->{colnames} = $colnames;
  }
  else {
    $self->{colnames} = [] unless exists $self->{colnames};
    return Rstats::ArrayAPI::c($self->{colnames});
  }
}

sub rownames {
  my $self = shift;
  
  if (@_) {
    my $_rownames = shift;
    my $rownames;
    if (ref $_rownames eq 'Rstats::Container::Array') {
      $rownames = $_rownames->elements;
    }
    elsif (!defined $_rownames) {
      $rownames = [];
    }
    elsif (ref $_rownames eq 'ARRAY') {
      $rownames = $_rownames;
    }
    else {
      $rownames = [$_rownames];
    }
    $self->{rownames} = $rownames;
  }
  else {
    $self->{rownames} = [] unless exists $self->{rownames};
    return Rstats::ArrayAPI::c($self->{rownames});
  }
}

1;
