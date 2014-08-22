package Rstats::Element::Double;
use Rstats::Element -base;

has type => 'double';
has 'flag';

sub value {
  my $self = shift;
  
  if ($self->is_positive_infinite) {
    return '__Inf__';
  }
  elsif ($self->is_negative_infinite) {
    return '__-Inf__';
  }
  elsif ($self->is_nan) {
    return '__NaN__';
  }
  else {
    $self->{value};
  }
}

sub is_nan {
  my $self = shift;
  
  return $self->type eq 'double' && $self->flag eq 'nan';
}

sub is_infinite {
  my $self = shift;
  return $self->is_positive_infinite || $self->is_negative_infinite;
}

sub is_positive_infinite {
  my $self = shift;
  
  return $self->type eq 'double' && $self->flag eq 'inf';
}

sub is_negative_infinite {
  my $self = shift;
  
  return $self->type eq 'double' && $self->flag eq '-inf';
}

sub is_finite {
  my $self = shift;
  
  return !$self->is_infinite;
}

sub is_double { Rstats::ElementFunction::TRUE }
sub is_numeric { Rstats::ElementFunction::TRUE }

1;
