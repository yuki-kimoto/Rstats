package Data::R::Vector;

use Object::Simple -base;
use overload
  bool => sub {1},
  '+' => \&add,
  '-' => \&subtract,
  '*' => \&multiply,
  '/' => \&divide,
  'neg' => \&negation,
  '**' => \&raise,
  fallback => 1;

use Carp 'croak';
use List::Util;

has values => sub { [] };

sub grep {
  my ($self, $condition) = @_;
  
  if (ref (my $cb = $condition) eq 'CODE') {
    my $v1_values = $self->values;
    my $v2_values = [grep { $cb->($_) } @$v1_values];
    my $v2 = Data::R::Vector->new(values => $v2_values);
    return $v2;
  }
  elsif (ref (my $v2 = $condition) eq 'Data::R::Vector') {
    my $v1_names = $self->names->values;
    my $v2_names = $v2->values;
    
    my $v3_values = [];
    for my $v2_name (@$v2_names) {
      my $i = 0;
      for my $v1_name (@$v1_names) {
        if ($v2_name eq $v1_name) {
          push @$v3_values, $self->values->[$i];
          last;
        }
        $i++;
      }
    }
    
    my $v3 = Data::R::Vector->new(values => $v3_values);
    
    return $v3;
  }
}

sub names {
  my ($self, $names_v) = @_;
  
  if ($names_v) {
    croak "names argument must be vector object"
      unless ref $names_v eq 'Data::R::Vector';
    my $duplication = {};
    my $names = $names_v->values;
    for my $name (@$names) {
      croak "Don't use same name in names arguments"
        if $duplication->{$name};
      $duplication->{$name}++;
    }
    $self->{names} = $names_v;
  }
  else {
    return $self->{names};
  }
}

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
