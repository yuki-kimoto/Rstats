package Rstats::Elements;
use Object::Simple -base;

use Carp 'croak', 'carp';
use Rstats::ElementsFunc;
use Rstats::Util;

use overload
  bool => \&bool,
  '+' => sub { Rstats::ElementsFunc::add(shift->_fix_position(@_)) },
  '-' => sub { Rstats::ElementsFunc::subtract(shift->_fix_position(@_)) },
  '*' => sub { Rstats::ElementsFunc::multiply(shift->_fix_position(@_)) },
  '/' => sub { Rstats::ElementsFunc::divide(shift->_fix_position(@_)) },
  '%' => sub { Rstats::ElementsFunc::remainder(shift->_fix_position(@_)) },
  'neg' => sub { Rstats::ElementsFunc::negation(@_) },
  '**' => sub { Rstats::ElementsFunc::raise(shift->_fix_position(@_)) },
  '<' => sub { Rstats::ElementsFunc::less_than(shift->_fix_position(@_)) },
  '<=' => sub { Rstats::ElementsFunc::less_than_or_equal(shift->_fix_position(@_)) },
  '>' => sub { Rstats::ElementsFunc::more_than(shift->_fix_position(@_)) },
  '>=' => sub { Rstats::ElementsFunc::more_than_or_equal(shift->_fix_position(@_)) },
  '==' => sub { Rstats::ElementsFunc::equal(shift->_fix_position(@_)) },
  '!=' => sub { Rstats::ElementsFunc::not_equal(shift->_fix_position(@_)) },
  '""' => \&to_string,
  fallback => 1;

sub _fix_position {
  my ($self, $data, $reverse) = @_;
  
  my $e1;
  my $e2;
  if (ref $data eq 'Rstats::Elements') {
    $e1 = $self;
    $e2 = $data;
  }
  else {
    if ($reverse) {
      $e1 = Rstats::ElementsFunc::element($data);
      $e2 = $self;
    }
    else {
      $e1 = $self;
      $e2 = Rstats::ElementsFunc::element($data);
    }
  }
  
  return ($e1, $e2);
}

# has 'type';
# has 'iv';
# has 'dv';
# has 'cv';
# has 're';
# has 'im';
# has 'flag';

sub as_character {
  my $self = shift;
  
  my $e2 = Rstats::ElementsFunc::character("$self");
  
  return $e2;
}

sub as_complex {
  my $self = shift;

  if ($self->is_na) {
    return $self;
  }
  elsif ($self->is_character) {
    my $z = Rstats::Util::looks_like_complex($self->cv);
    if (defined $z) {
      return Rstats::ElementsFunc::complex($z->{re}, $z->{im});
    }
    else {
      carp 'NAs introduced by coercion';
      return Rstats::ElementsFunc::NA();
    }
  }
  elsif ($self->is_complex) {
    return $self;
  }
  elsif ($self->is_double) {
    if ($self->is_nan) {
      return Rstats::ElementsFunc::NA();
    }
    else {
      return Rstats::ElementsFunc::complex_double($self, Rstats::ElementsFunc::double(0));
    }
  }
  elsif ($self->is_integer) {
    return Rstats::ElementsFunc::complex($self->iv, 0);
  }
  elsif ($self->is_logical) {
    return Rstats::ElementsFunc::complex($self->iv ? 1 : 0, 0);
  }
  else {
    croak "unexpected type";
  }
}

sub as_numeric { as_double(@_) }

sub as_double {
  my $self = shift;

  if ($self->is_na) {
    return $self;
  }
  elsif ($self->is_character) {
    if (my $num = Rstats::Util::looks_like_number($self->cv)) {
      return Rstats::ElementsFunc::double($num + 0);
    }
    else {
      carp 'NAs introduced by coercion';
      return Rstats::ElementsFunc::NA();
    }
  }
  elsif ($self->is_complex) {
    carp "imaginary parts discarded in coercion";
    return Rstats::ElementsFunc::double($self->re->value);
  }
  elsif ($self->is_double) {
    return $self;
  }
  elsif ($self->is_integer) {
    return Rstats::ElementsFunc::double($self->iv);
  }
  elsif ($self->is_logical) {
    return Rstats::ElementsFunc::double($self->iv ? 1 : 0);
  }
  else {
    croak "unexpected type";
  }
}

sub as_integer {
  my $self = shift;

  if ($self->is_na) {
    return $self;
  }
  elsif ($self->is_character) {
    if (my $num = Rstats::Util::looks_like_number($self->cv)) {
      return Rstats::ElementsFunc::integer(int $num);
    }
    else {
      carp 'NAs introduced by coercion';
      return Rstats::ElementsFunc::NA();
    }
  }
  elsif ($self->is_complex) {
    carp "imaginary parts discarded in coercion";
    return Rstats::ElementsFunc::integer(int($self->re->value));
  }
  elsif ($self->is_double) {
    if ($self->is_nan || $self->is_infinite) {
      return Rstats::ElementsFunc::NA();
    }
    else {
      return Rstats::ElementsFunc::integer($self->dv);
    }
  }
  elsif ($self->is_integer) {
    return $self; 
  }
  elsif ($self->is_logical) {
    return Rstats::ElementsFunc::integer($self->iv ? 1 : 0);
  }
  else {
    croak "unexpected type";
  }
}

sub as_logical {
  my $self = shift;
  
  if ($self->is_na) {
    return $self;
  }
  elsif ($self->is_character) {
    my $value = $self->value;
    
    if (defined (my $e1 = Rstats::Util::looks_like_logical($value))) {
      return $e1;
    }
    else {
      return Rstats::ElementsFunc::NA();
    }
  }
  elsif ($self->is_complex) {
    carp "imaginary parts discarded in coercion";
    my $re = $self->re->value;
    my $im = $self->im->value;
    if (defined $re && $re == 0 && defined $im && $im == 0) {
      return Rstats::ElementsFunc::FALSE();
    }
    else {
      return Rstats::ElementsFunc::TRUE();
    }
  }
  elsif ($self->is_double) {
    if ($self->is_nan) {
      return Rstats::ElementsFunc::NA();
    }
    elsif ($self->is_infinite) {
      return Rstats::ElementsFunc::TRUE();
    }
    else {
      return $self->dv == 0 ? Rstats::ElementsFunc::FALSE() : Rstats::ElementsFunc::TRUE();
    }
  }
  elsif ($self->is_integer) {
    return $self->iv == 0 ? Rstats::ElementsFunc::FALSE() : Rstats::ElementsFunc::TRUE();
  }
  elsif ($self->is_logical) {
    return $self->iv == 0 ? Rstats::ElementsFunc::FALSE() : Rstats::ElementsFunc::TRUE();
  }
  else {
    croak "unexpected type";
  }
}

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
  
  if ($self->is_na) {
    return 'NA';
  }
  elsif ($self->is_character) {
    return $self->cv . "";
  }
  elsif ($self->is_complex) {
    my $re = $self->re;
    my $im = $self->im;
    
    my $str = "$re";
    $str .= '+' if $im >= 0;
    $str .= $im . 'i';
  }
  elsif ($self->is_double) {
  
    if ($self->is_positive_infinite) {
      return 'Inf';
    }
    elsif ($self->is_negative_infinite) {
      return '-Inf';
    }
    elsif ($self->is_nan) {
      return 'NaN';
    }
    else {
      $self->dv . "";
    }
  }
  elsif ($self->is_integer) {
    return $self->iv . "";
  }
  elsif ($self->is_logical) {
    return $self->iv ? 'TRUE' : 'FALSE'
  }
  else {
    croak "Invalid type";
  }
}

sub bool {
  my $self = shift;
  
  if ($self->is_na) {
    croak "Error in bool context (a) { : missing value where TRUE/FALSE needed"
  }
  elsif ($self->is_character || $self->is_complex) {
    croak 'Error in -a : invalid argument to unary operator ';
  }
  elsif ($self->is_double) {
    if ($self->is_infinite) {
      return 1;
    }
    elsif ($self->is_nan) {
      croak 'argument is not interpretable as logical';
    }
    else {
      return $self->dv;
    }
  }
  elsif ($self->is_integer || $self->is_logical) {
    return $self->iv;
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
  elsif ($self->is_double) {
    if ($self->is_positive_infinite) {
      return 'Inf';
    }
    elsif ($self->is_negative_infinite) {
      return '-Inf';
    }
    elsif ($self->is_nan) {
      return 'NaN';
    }
    else {
      return $self->dv;
    }
  }
  elsif ($self->is_logical) {
    if ($self->iv) {
      return 1;
    }
    else {
      return 0;
    }
  }
  elsif ($self->is_complex) {
    return {
      re => $self->re->value,
      im => $self->im->value
    };
  }
  elsif ($self->is_character) {
    return $self->cv;
  }
  elsif ($self->is_integer) {
    return $self->iv;
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

sub is_positive_infinite {
  my $self = shift;
  
  return $self->is_infinite && $self->dv > 0;
}

sub is_negative_infinite {
  my $self = shift;
  
  return $self->is_infinite && $self->dv < 0;
}

# XS
# is_nan
# is_infinite
# is_finite

1;

=head1 NAME

Rstats::Elements - Elements
