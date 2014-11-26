package Rstats::Vector;
use Object::Simple -base;

use Carp 'croak', 'carp';
use Rstats::VectorFunc;
use Rstats::Util;

use overload
  bool => \&bool,
  '+' => sub { Rstats::VectorFunc::add(shift->_fix_position(@_)) },
  '-' => sub { Rstats::VectorFunc::subtract(shift->_fix_position(@_)) },
  '*' => sub { Rstats::VectorFunc::multiply(shift->_fix_position(@_)) },
  '/' => sub { Rstats::VectorFunc::divide(shift->_fix_position(@_)) },
  '%' => sub { Rstats::VectorFunc::remainder(shift->_fix_position(@_)) },
  'neg' => sub { Rstats::VectorFunc::negation(@_) },
  '**' => sub { Rstats::VectorFunc::raise(shift->_fix_position(@_)) },
  '<' => sub { Rstats::VectorFunc::less_than(shift->_fix_position(@_)) },
  '<=' => sub { Rstats::VectorFunc::less_than_or_equal(shift->_fix_position(@_)) },
  '>' => sub { Rstats::VectorFunc::more_than(shift->_fix_position(@_)) },
  '>=' => sub { Rstats::VectorFunc::more_than_or_equal(shift->_fix_position(@_)) },
  '==' => sub { Rstats::VectorFunc::equal(shift->_fix_position(@_)) },
  '!=' => sub { Rstats::VectorFunc::not_equal(shift->_fix_position(@_)) },
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

sub as_character {
  my $self = shift;
  
  my $e2 = Rstats::VectorFunc::character("$self");
  
  return $e2;
}

sub as_numeric { as_double(@_) }

sub as {
  my ($self, $type) = @_;
  
  if ($type eq 'character') {
    return $self->as_character;
  }
  elsif ($type eq 'complex') {
    return $self->as_complex;
  }
  elsif ($type eq 'double') {
    return $self->as_double;
  }
  elsif ($type eq 'numeric') {
    return $self->as_numeric;
  }
  elsif ($type eq 'integer') {
    return $self->as_integer;
  }
  elsif ($type eq 'logical') {
    return $self->as_logical;
  }
  else {
    croak "Invalid mode is passed";
  }
}

sub to_string {
  my $self = shift;
  
  my $str;
  if ($self->is_character) {
    $str = $self->cv . "";
  }
  elsif ($self->is_complex) {
    my $re = $self->re;
    my $im = $self->im;
    
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
      $str = $self->dv . "";
    }
  }
  elsif ($self->is_integer) {
    $str = $self->iv . "";
  }
  elsif ($self->is_logical) {
    $str = $self->iv ? 'TRUE' : 'FALSE'
  }
  else {
    croak "Invalid type";
  }
  
  my $is_na = $self->is_na->iv;
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
      $is = $self->dv;
    }
  }
  elsif ($self->is_integer || $self->is_logical) {
    $is = $self->iv;
  }
  else {
    croak "Invalid type";
  }
  
  my $is_na = $self->is_na->iv;
  if ($is_na) {
    croak "Error in bool context (a) { : missing value where TRUE/FALSE needed"
  }
  
  return $is;
}

sub value {
  my $self = shift;
  
  my $value;
  if ($self->is_double) {
    if ($self->is_positive_infinite) {
      $value = 'Inf';
    }
    elsif ($self->is_negative_infinite) {
      $value = '-Inf';
    }
    elsif ($self->is_nan) {
      $value = 'NaN';
    }
    else {
      $value = $self->dv;
    }
  }
  elsif ($self->is_logical) {
    if ($self->iv) {
      $value = 1;
    }
    else {
      $value = 0;
    }
  }
  elsif ($self->is_complex) {
    $value = {
      re => $self->re->value,
      im => $self->im->value
    };
  }
  elsif ($self->is_character) {
    $value = $self->cv;
  }
  elsif ($self->is_integer) {
    $value = $self->iv;
  }
  else {
    croak "Invalid type(Rstats::Vector::value())";
  }
  
  my $is_na = $self->is_na->iv;
  if ($is_na) {
    $value = undef;
  }
  
  return $value;
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

sub is_positive_infinite {
  my $self = shift;
  
  return $self->is_infinite && $self->dv > 0;
}

sub is_negative_infinite {
  my $self = shift;
  
  return $self->is_infinite && $self->dv < 0;
}


1;

=head1 NAME

Rstats::Vector - Vector

=heaa1 METHODS

=head2 as_double

=head2 type

=head2 iv

=head2 dv

=head2 cv

=head2 re

=head2 im

=head2 flag

=head2  XS

=head2  is_nan

=head2  is_infinite

=head2  is_finite

