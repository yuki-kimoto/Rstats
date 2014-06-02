package Data::R;

our $VERSION = '0.01';

use Object::Simple -base;

use Data::R::Vector;
use List::Util;
use Math::Trig ();
use Carp 'croak';
use Data::R::Complex;

sub paste {
  my $self = shift;

  # Option
  my $opt;
  if (ref $_[-1] eq 'HASH') {
    $opt = pop @_;
  }
  $opt ||= {};
  
  my $sep = $opt->{sep};
  $sep = ' ' unless defined $sep;
  
  my $str = shift;
  my $v1 = shift;
  
  my $v1_values = $v1->values;
  my $v2 = Data::R::Vector->new;
  my $v2_values = $v2->values;
  for my $v1_value (@$v1_values) {
    push @$v2_values, "$str$sep$v1_value";
  }
  
  return $v2;
}

sub c {
  my ($self, $data) = @_;
  
  if (ref $data eq 'Data::R::Vector') {
    return $data;
  }
  elsif (ref $data eq 'ARRAY') {
    return Data::R::Vector->new(values => $data);
  }
  else {
    my $str = $data;
    my $by;
    if ($str =~ s/^(.+)\*//) {
      $by = $1;
    }
    
    my $from;
    my $to;
    if ($str =~ /(.+?):(.+)/) {
      $from = $1;
      $to = $2;
    }
    
    return $self->seq({from => $from, to => $to, by => $by});
  }
}

sub seq {
  my $self = shift;
  
  # Option
  my $opt;
  if (ref $_[-1] eq 'HASH') {
    $opt = pop @_;
  }
  $opt ||= {};
  
  # From
  my $from = shift;
  $from = $opt->{from} unless defined $from;
  croak "seq function need from option" unless defined $from;
  
  # To
  my $to = shift;
  $to = $opt->{to} unless defined $to;
  
  # By
  my $by = $opt->{by};
  unless (defined $by) {
    if ($to >= $from) {
      $by = 1;
    }
    else {
      $by = -1;
    }
  }
  croak "by option should be except for 0" if $by == 0;
  
  # Length
  my $length = $opt->{length};
  
  if (defined $length) {
    my $values = [];
    for my $num (0 .. $length - 1) {
      my $value = $from + $num * $by;
      push @$values, $value;
    }
    return Data::R::Vector->new(values => $values);
  }
  elsif (defined $to) {
    my $values = [];
    if ($to == $from) {
      return Data::R::Vector->new(values => [$to]);
    }
    elsif ($to > $from) {
      if ($by < 0) {
        croak "by option is invalid number(seq function)";
      }
      
      my $value = $from;
      while ($value <= $to) {
        push @$values, $value;
        $value += $by;
      }
      return Data::R::Vector->new(values => $values);
    }
    else {
      if ($by > 0) {
        croak "by option is invalid number(seq function)";
      }
      
      my $value = $from;
      while ($value >= $to) {
        push @$values, $value;
        $value += $by;
      }
      return Data::R::Vector->new(values => $values);
    }
  }
  else {
    croak "seq function need to option or length option";
  }
}

sub rep {
  my $self = shift;

  # Option
  my $opt;
  if (ref $_[-1] eq 'HASH') {
    $opt = pop @_;
  }
  $opt ||= {};
  
  my $v1 = shift;
  my $times = $opt->{times} || 1;
  
  my $values = [];
  push @$values, @{$v1->values} for 1 .. $times;
  my $v2 = Data::R::Vector->new(values => $values);
  
  return $v2;
}

sub max {
  my ($self, @vs) = @_;
  
  my @all_values = map { @{$_->values} } @vs;
  my $max = List::Util::max(@all_values);
  return $max;
}

sub min {
  my ($self, @vs) = @_;
  
  my @all_values = map { @{$_->values} } @vs;
  my $min = List::Util::min(@all_values);
  return $min;
}

sub pmax {
  my ($self, @vs) = @_;
  
  my @maxs;
  for my $v (@vs) {
    my $values = $v->values;
    for (my $i = 0; $i <@$values; $i++) {
      $maxs[$i] = $values->[$i]
        if !defined $maxs[$i] || $values->[$i] > $maxs[$i]
    }
  }
  
  my $v_max = Data::R::Vector->new(values => \@maxs);
  
  return $v_max;
}

sub pmin {
  my ($self, @vs) = @_;
  
  my @mins;
  for my $v (@vs) {
    my $values = $v->values;
    for (my $i = 0; $i <@$values; $i++) {
      $mins[$i] = $values->[$i]
        if !defined $mins[$i] || $values->[$i] < $mins[$i]
    }
  }
  
  my $v_min = Data::R::Vector->new(values => \@mins);
  
  return $v_min;
}

sub sum {
  my ($self, $data) = @_;
  
  if (ref $data eq 'Data::R::Vector') {
    my $sum;
    my $v = $data;
    my $v_values = $v->values;
    $sum = List::Util::sum(@$v_values);
    return $sum;
  }
  else {
    croak 'Not implemented';
  }
}

sub prod {
  my ($self, $data) = @_;
  
  if (ref $data eq 'Data::R::Vector') {
    my $prod;
    my $v = $data;
    my $v_values = $v->values;
    $prod = List::Util::product(@$v_values);
    return $prod;
  }
  else {
    croak 'Not implemented';
  }
}

sub mean {
  my ($self, $data) = @_;
  
  if (ref $data eq 'Data::R::Vector') {
    my $v = $data;
    my $mean = $self->sum($v) / $self->length($v);
    return $mean;
  }
  else {
    croak 'Not implemented';
  }
}

sub var {
  my ($self, $data) = @_;

  if (ref $data eq 'Data::R::Vector') {
    my $v = $data;
    
    my $var = $self->sum(($v - $self->mean($v)) ** 2) / ($self->length($v) - 1);
    return $var;
  }
  else {
    croak 'Not implemented';
  }
}

sub length {
  my ($self, $data) = @_;
  
  my $length;
  if (ref $data eq 'Data::R::Vector') {
    my $v = $data;
    my $v_values = $v->values;
    $length = @$v_values;
    return $length;
  }
  else {
    croak 'Not implemented';
  }
}

sub sort {
  my ($self, $data) = @_;
  
  if (ref $data eq 'Data::R::Vector') {
    my $v2 = Data::R::Vector->new;
    my $sort;
    my $v1 = $data;
    my $v1_values = $v1->values;
    my $v1_values_sorted = [sort(@$v1_values)];
    $v2->values($v1_values_sorted);
    return $v2;
  }
  else {
    croak 'Not implemented';
  }
}

sub log {
  my ($self, $data) = @_;
  
  if (ref $data eq 'Data::R::Vector') {
    my $v1 = $data;
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
  my ($self, $data) = @_;
  
  if (ref $data eq 'Data::R::Vector') {
    my $v1 = $data;
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
  my ($self, $data) = @_;
  
  if (ref $data eq 'Data::R::Vector') {
    my $v1 = $data;
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
  my ($self, $data) = @_;
  
  if (ref $data eq 'Data::R::Vector') {
    my $v1 = $data;
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
  my ($self, $data) = @_;
  
  if (ref $data eq 'Data::R::Vector') {
    my $v1 = $data;
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
  my ($self, $data) = @_;
  
  if (ref $data eq 'Data::R::Vector') {
    my $v1 = $data;
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
  my ($self, $data) = @_;
  
  if (ref $data eq 'Data::R::Vector') {
    my $v1 = $data;
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

sub i {
  my $self = shift;
  
  my $i = Data::R::Complex->new(re => 0, im => 1);
  
  return $i;
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
