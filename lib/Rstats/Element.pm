package Rstats::Element;
use Object::Simple -base;

use Carp 'croak';

use overload 'bool' => \&bool,
  '""' => \&to_string,
  fallback => 1;

has 'type';
has 'iv';
has 'cv';
has 're';
has 'im';
has 'flag';

sub to_string {
  my $e1 = shift;
  
  if ($e1->is_na) {
    return 'NA';
  }
  elsif ($e1->is_character) {
    return $e1->{cv} . "";
  }
  elsif ($e1->is_complex) {
    my $re = $e1->re->to_string;
    my $im = $e1->im->to_string;
    
    my $str = "$re";
    $str .= '+' if $im >= 0;
    $str .= $im . 'i';
  }
  elsif ($e1->is_double) {
    
    my $flag = $e1->flag;
    
    if (defined $e1->{re}) {
      return $e1->{re} . "";
    }
    elsif ($flag eq 'nan') {
      return 'NaN';
    }
    elsif ($flag eq 'inf') {
      return 'Inf';
    }
    elsif ($flag eq '-inf') {
      return '-Inf';
    }
  }
  elsif ($e1->is_integer) {
    return $e1->{value} . "";
  }
  elsif ($e1->is_logical) {
    return $e1->{value} ? 'TRUE' : 'FALSE'
  }
  else {
    croak "Invalid type";
  }
}

sub bool {
  my $e1 = shift;
  
  if ($e1->is_na) {
    croak "Error in bool context (a) { : missing value where TRUE/FALSE needed"
  }
  elsif ($e1->is_character || $e1->is_complex) {
    croak 'Error in -a : invalid argument to unary operator ';
  }
  elsif ($e1->is_double) {

    if (defined $e1->{re}) {
      return $e1->{re};
    }
    else {
      if ($e1->is_infinite) {
        1;
      }
      # NaN
      else {
        croak 'argument is not interpretable as logical'
      }
    }
  }
  elsif ($e1->is_integer || $e1->is_logical) {
    return $e1->{value};
  }
  else {
    croak "Invalid type";
  }  
}

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
  elsif ($self->is_integer) {
    return $self->{value};
  }
  elsif ($self->is_double) {
    return $self->{re};
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
  
  return $self->is_integer || ($self->is_double && defined $self->{re});
}

1;
