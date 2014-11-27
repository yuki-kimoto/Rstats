package Rstats::Vector;
use Object::Simple -base;

use Carp 'croak', 'carp';
use Rstats::VectorFunc;
use Rstats::Util;

use overload
  bool => \&bool,
  '""' => \&to_string,
  fallback => 1;

sub _fix_position {
  my ($self, $data, $reverse) = @_;
  
  my $e1;
  my $e2;
  if (ref $data eq 'Rstats::Vector') {
    $e1 = $self;
    $e2 = $data;
  }
  else {
    if ($reverse) {
      $e1 = Rstats::VectorFunc::element($data);
      $e2 = $self;
    }
    else {
      $e1 = $self;
      $e2 = Rstats::VectorFunc::element($data);
    }
  }
  
  return ($e1, $e2);
}

sub to_string {
  my $self = shift;
  
  my $str;
  if ($self->is_character) {
    $str = $self->value . "";
  }
  elsif ($self->is_complex) {
    my $re = $self->value->{re};
    my $im = $self->value->{im};
    
    $str = "$re";
    $str .= '+' if $im >= 0;
    $str .= $im . 'i';
  }
  elsif ($self->is_double) {
  
    if ($self->is_positive_infinite) {
      $str = 'Inf';
    }
    elsif ($self->is_negative_infinite) {
      $str = '-Inf';
    }
    elsif ($self->is_nan) {
      $str = 'NaN';
    }
    else {
      $str = $self->value . "";
    }
  }
  elsif ($self->is_integer) {
    $str = $self->value . "";
  }
  elsif ($self->is_logical) {
    $str = $self->value ? 'TRUE' : 'FALSE'
  }
  else {
    croak "Invalid type";
  }
  
  my $is_na = $self->is_na->value;
  if ($is_na) {
    $str = 'NA';
  }
  
  return $str;
}

sub bool {
  my $self = shift;
  
  my $is;
  if ($self->is_character || $self->is_complex) {
    croak 'Error in -a : invalid argument to unary operator ';
  }
  elsif ($self->is_double) {
    if ($self->is_infinite) {
      $is = 1;
    }
    elsif ($self->is_nan) {
      croak 'argument is not interpretable as logical';
    }
    else {
      $is = $self->value;
    }
  }
  elsif ($self->is_integer || $self->is_logical) {
    $is = $self->value;
  }
  else {
    croak "Invalid type";
  }
  
  my $is_na = $self->is_na->value;
  if ($is_na) {
    croak "Error in bool context (a) { : missing value where TRUE/FALSE needed"
  }
  
  return $is;
}

sub value { shift->values->[0] }

sub typeof { shift->type }

sub is_positive_infinite {
  my $self = shift;
  
  return $self->is_infinite && $self->value > 0;
}

sub is_negative_infinite {
  my $self = shift;
  
  return $self->is_infinite && $self->value < 0;
}

1;

=head1 NAME

Rstats::Vector - Vector

=heaa1 METHODS

=head2 values (xs)

=head2 is_character (xs)

=head2 is_complex (xs)

=head2 is_double (xs)

=head2 is_integer (xs)

=head2 is_numeric (xs)

=head2 is_logical (xs)

=head2 as_double (xs)

=head2 as_integer (xs)

=head2 as_numeric (xs)

=head2 as_complex (xs)

=head2 as_logical (xs)

=head2 type

=head2 re

=head2 im

=head2 flag

=head2  is_nan

=head2  is_infinite

=head2  is_finite

