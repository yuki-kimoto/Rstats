package Rstats::Element;
use Object::Simple -base;

use Carp 'croak';

has 'type';
has 'iv';
has 'cv';
has 're';
has 'im';

sub value {
  my $self = shift;
  
  if ($self->is_na) {
    return undef;
  }
  elsif ($self->is_positive_infinite) {
    return '__Inf__';
  }
  elsif ($self->is_negative_infinite) {
    return '__-Inf__';
  }
  elsif ($self->is_nan) {
    return '__NaN__';
  }
  elsif ($self->is_logical) {
    if ($self->{value}) {
      return '__TRUE__';
    }
    else {
      return '__FALSE__';
    }
  }
  elsif ($self->is_complex) {
    return {
      re => $self->re->value,
      im => $self->im->value
    };
  }
  elsif ($self->is_character) {
    return $self->{cv};
  }
  elsif ($self->is_integer || $self->is_double) {
    return $self->{value};
  }
  else {
    croak "Invalid type";
  }
}

sub typeof { shift->type }

sub is_character { shift->type eq 'character' }
sub is_complex { shift->type eq 'complex' }
sub is_numeric {
  my $self = shift;
  return $self->is_double || $self->is_integer;
}
sub is_double { shift->type eq 'double' }
sub is_integer { shift->type eq 'integer' }
sub is_logical { shift->type eq 'logical' }
sub is_na { shift->type eq 'na' }

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
  
  return $self->is_integer || ($self->is_double && defined $self->{value});
}

1;
