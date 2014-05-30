package Data::R;

our $VERSION = '0.01';

use Object::Simple -base;

use Data::R::Vector;
use List::Util;
use Math::Trig ();
use Carp 'croak';

sub c {
  my ($self, $values) = @_;
  
  my $vector = Data::R::Vector->new(values => $values);
  
  return $vector;
}

sub max {
  my ($self, $value) = @_;
  
  if (ref $value eq 'Data::R::Vector') {
    my $max;
    my $v = $value;
    my $v_values = $v->values;
    $max = List::Util::max(@$v_values);
    return $max;
  }
  else {
    croak 'Not implemented';
  }
}

sub min {
  my ($self, $value) = @_;
  
  if (ref $value eq 'Data::R::Vector') {
    my $min;
    my $v = $value;
    my $v_values = $v->values;
    $min = List::Util::min(@$v_values);
    return $min;
  }
  else {
    croak 'Not implemented';
  }
}

sub sum {
  my ($self, $value) = @_;
  
  if (ref $value eq 'Data::R::Vector') {
    my $sum;
    my $v = $value;
    my $v_values = $v->values;
    $sum = List::Util::sum(@$v_values);
    return $sum;
  }
  else {
    croak 'Not implemented';
  }
}

sub length {
  my ($self, $value) = @_;
  
  my $length;
  if (ref $value eq 'Data::R::Vector') {
    my $v = $value;
    my $v_values = $v->values;
    $length = @$v_values;
    return $length;
  }
  else {
    croak 'Not implemented';
  }
}

sub log {
  my ($self, $value) = @_;
  
  if (ref $value eq 'Data::R::Vector') {
    my $v1 = $value;
    my $v2 = Data::R::Vector->new;
    my $v1_values = $v1->values;
    my $v2_values = $v2->values;
    for (my $i = 0; $i < @$v1_values; $i++) {
      $v2_values->[$i] = log $v1_values->[$i];
    }
    return $v2;
  }
  else {
    croak 'Not implemented';
  }
}

sub exp {
  my ($self, $value) = @_;
  
  if (ref $value eq 'Data::R::Vector') {
    my $v1 = $value;
    my $v2 = Data::R::Vector->new;
    my $v1_values = $v1->values;
    my $v2_values = $v2->values;
    for (my $i = 0; $i < @$v1_values; $i++) {
      $v2_values->[$i] = exp $v1_values->[$i];
    }
    return $v2;
  }
  else {
    croak 'Not implemented';
  }
}

sub sin {
  my ($self, $value) = @_;
  
  if (ref $value eq 'Data::R::Vector') {
    my $v1 = $value;
    my $v2 = Data::R::Vector->new;
    my $v1_values = $v1->values;
    my $v2_values = $v2->values;
    for (my $i = 0; $i < @$v1_values; $i++) {
      $v2_values->[$i] = sin $v1_values->[$i];
    }
    return $v2;
  }
  else {
    croak 'Not implemented';
  }
}

sub cos {
  my ($self, $value) = @_;
  
  if (ref $value eq 'Data::R::Vector') {
    my $v1 = $value;
    my $v2 = Data::R::Vector->new;
    my $v1_values = $v1->values;
    my $v2_values = $v2->values;
    for (my $i = 0; $i < @$v1_values; $i++) {
      $v2_values->[$i] = cos $v1_values->[$i];
    }
    return $v2;
  }
  else {
    croak 'Not implemented';
  }
}

sub tan {
  my ($self, $value) = @_;
  
  if (ref $value eq 'Data::R::Vector') {
    my $v1 = $value;
    my $v2 = Data::R::Vector->new;
    my $v1_values = $v1->values;
    my $v2_values = $v2->values;
    for (my $i = 0; $i < @$v1_values; $i++) {
      $v2_values->[$i] = Math::Trig::tan $v1_values->[$i];
    }
    return $v2;
  }
  else {
    croak 'Not implemented';
  }
}

sub sqrt {
  my ($self, $value) = @_;
  
  if (ref $value eq 'Data::R::Vector') {
    my $v1 = $value;
    my $v2 = Data::R::Vector->new;
    my $v1_values = $v1->values;
    my $v2_values = $v2->values;
    for (my $i = 0; $i < @$v1_values; $i++) {
      $v2_values->[$i] = sqrt $v1_values->[$i];
    }
    return $v2;
  }
  else {
    croak 'Not implemented';
  }
}

sub range {
  my ($self, $value) = @_;
  
  if (ref $value eq 'Data::R::Vector') {
    my $v1 = $value;
    my $v2 = Data::R::Vector->new;
    my $v1_values = $v1->values;
    my $v2_values = $v2->values;
    my $min = $self->min($v1);
    my $max = $self->max($v1);
    $v2->values([$min, $max]);

    return $v2;
  }
  else {
    croak 'Not implemented';
  }
}


1;

=head1 NAME

Data::R - R-like statistical library

=head1 SYNOPSYS

  my $r = Data::R->new;
  
  # Vector
  my $v1 = $r->c([1, 2, 3]);
  my $v2 = $r->c([2, 3, 4]);
  my $v3 = $v1 + v2;
