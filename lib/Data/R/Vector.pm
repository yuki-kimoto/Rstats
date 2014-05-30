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
  for (my $i = 0; $i < @$v1_values; $i++) {
    $v2_values->[$i] = -$v1_values->[$i];
  }
  
  return $v2;
}

sub add {
  my ($self, $v2) = @_;

  my $v3 = Data::R::Vector->new;
  if (ref $v2) {
    my $v1_values = $self->values;
    my $v2_values = $v2->values;
    my $v3_values = $v3->values;
    
    for (my $i = 0; $i < @$v1_values; $i++) {
      $v3_values->[$i] = $v1_values->[$i] + $v2_values->[$i];
    }
  }
  else {
    my $v1_values = $self->values;
    my $v3_values = $v3->values;
    
    for (my $i = 0; $i < @$v1_values; $i++) {
      $v3_values->[$i] = $v1_values->[$i] + $v2;
    }
  }
  
  return $v3;
}

sub subtract {
  my ($self, $v2) = @_;

  my $v3 = Data::R::Vector->new;
  if (ref $v2) {
    my $v1_values = $self->values;
    my $v2_values = $v2->values;
    my $v3_values = $v3->values;
    
    for (my $i = 0; $i < @$v1_values; $i++) {
      $v3_values->[$i] = $v1_values->[$i] - $v2_values->[$i];
    }
  }
  else {
    my $v1_values = $self->values;
    my $v3_values = $v3->values;
    
    for (my $i = 0; $i < @$v1_values; $i++) {
      $v3_values->[$i] = $v1_values->[$i] - $v2;
    }
  }
  
  return $v3;
}

sub multiply {
  my ($self, $v2) = @_;

  my $v3 = Data::R::Vector->new;
  if (ref $v2) {
    my $v1_values = $self->values;
    my $v2_values = $v2->values;
    my $v3_values = $v3->values;
    
    for (my $i = 0; $i < @$v1_values; $i++) {
      $v3_values->[$i] = $v1_values->[$i] * $v2_values->[$i];
    }
  }
  else {
    my $v1_values = $self->values;
    my $v3_values = $v3->values;
    
    for (my $i = 0; $i < @$v1_values; $i++) {
      $v3_values->[$i] = $v1_values->[$i] * $v2;
    }
  }
  
  return $v3;
}

sub divide {
  my ($self, $v2) = @_;

  my $v3 = Data::R::Vector->new;
  if (ref $v2) {
    my $v1_values = $self->values;
    my $v2_values = $v2->values;
    my $v3_values = $v3->values;
    
    for (my $i = 0; $i < @$v1_values; $i++) {
      $v3_values->[$i] = $v1_values->[$i] / $v2_values->[$i];
    }
  }
  else {
    my $v1_values = $self->values;
    my $v3_values = $v3->values;
    
    for (my $i = 0; $i < @$v1_values; $i++) {
      $v3_values->[$i] = $v1_values->[$i] / $v2;
    }
  }
  
  return $v3;
}

sub raise {
  my ($self, $v2) = @_;
  
  my $v3 = Data::R::Vector->new;
  if (ref $v2) {
    croak 'Not implemented';
  }
  else {
    my $v1_values = $self->values;
    my $v3_values = $v3->values;
    
    for (my $i = 0; $i < @$v1_values; $i++) {
      $v3_values->[$i] = $v1_values->[$i] ** $v2;
    }
    
    return $v3;
  }
}

1;
