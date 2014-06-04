package Data::R::Vector;

use Object::Simple -base;
use overload
  '+' => \&add,
  '-' => \&subtract,
  '*' => \&multiply,
  '/' => \&divide,
  'neg' => \&negation,
  '**' => \&raise;
use Carp 'croak';
use List::Util;

has values => sub { [] };

sub negation {
  my $self = shift;
  
  my $v2 = Data::R::Vector->new;
  my $v1_values = $self->values;
  my $v2_values = $v2->values;
  $v2_values->[$_] = -$v1_values->[$_] for (0 .. @$v1_values - 1);
  
  return $v2;
}

sub add {
  my ($self, $data) = @_;

  my $v3 = Data::R::Vector->new;
  if (ref $data eq 'Data::R::Vector') {
    my $v1_values = $self->values;
    my $v2 = $data;
    my $v2_values = $v2->values;
    my $v3_values = $v3->values;
    
    $v3_values->[$_] = $v1_values->[$_] + $v2_values->[$_] for (0 .. @$v1_values - 1);
  }
  else {
    my $v1_values = $self->values;
    my $v3_values = $v3->values;
    
    $v3_values->[$_] = $v1_values->[$_] + $data for (0 .. @$v1_values - 1);
  }
  
  return $v3;
}

sub subtract {
  my ($self, $data, $reverse) = @_;

  my $v3 = Data::R::Vector->new;
  if (ref $data eq 'Data::R::Vector') {
    my $v1_values = $self->values;
    my $v2 = $data;
    my $v2_values = $v2->values;
    my $v3_values = $v3->values;
    
    $v3_values->[$_] = $v1_values->[$_] - $v2_values->[$_] for (0 .. @$v1_values - 1);
  }
  else {
    my $v1_values = $self->values;
    my $v3_values = $v3->values;

    if ($reverse) {
      $v3_values->[$_] = $data - $v1_values->[$_] for (0 .. @$v1_values - 1);
    }
    else {
      $v3_values->[$_] = $v1_values->[$_] - $data for (0 .. @$v1_values - 1);
    }
  }
  
  return $v3;
}

sub multiply {
  my ($self, $data) = @_;

  my $v3 = Data::R::Vector->new;
  if (ref $data eq 'Data::R::Vector') {
    my $v1_values = $self->values;
    my $v2 = $data;
    my $v2_values = $v2->values;
    my $v3_values = $v3->values;
    
    $v3_values->[$_] = $v1_values->[$_] * $v2_values->[$_] for (0 .. @$v1_values - 1);
  }
  else {
    my $v1_values = $self->values;
    my $v3_values = $v3->values;
    
    $v3_values->[$_] = $v1_values->[$_] * $data for (0 .. @$v1_values - 1);
  }
  
  return $v3;
}

sub divide {
  my ($self, $data, $reverse) = @_;

  my $v3 = Data::R::Vector->new;
  if (ref $data eq 'Data::R::Vector') {
    my $v1_values = $self->values;
    my $v2 = $data;
    my $v2_values = $v2->values;
    my $v3_values = $v3->values;
    
    $v3_values->[$_] = $v1_values->[$_] / $v2_values->[$_] for (0 .. @$v1_values - 1);
  }
  else {
    my $v1_values = $self->values;
    my $v3_values = $v3->values;
    
    if ($reverse) {
      $v3_values->[$_] = $data / $v1_values->[$_] for (0 .. @$v1_values - 1);
    }
    else {
      $v3_values->[$_] = $v1_values->[$_] / $data for (0 .. @$v1_values - 1);
    }
  }
  
  return $v3;
}

sub raise {
  my ($self, $data, $reverse) = @_;
  
  my $v3 = Data::R::Vector->new;
  if (ref $data eq 'Data::R::Vector') {
    croak 'Not implemented';
  }
  else {
    if ($reverse) {
      croak "Not implemented";
    }
    else {
      my $v1_values = $self->values;
      my $v3_values = $v3->values;
      
      $v3_values->[$_] = $v1_values->[$_] ** $data for (0 .. @$v1_values - 1);
    }
    
    return $v3;
  }
}

1;
