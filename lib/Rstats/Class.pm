package Rstats::Class;

use Object::Simple -base;
require Rstats::ArrayUtil;

# TODO
#   logp1x
#   gamma
#   lgamma
#   complete_cases
#   cor

my @methods = qw/
  abs
  acos
  acosh
  append
  array
  asin
  asinh
  as_array
  as_character
  as_complex
  as_integer
  as_logical
  as_matrix
  as_numeric
  as_vector
  atan
  atanh
  c
  C
  cbind
  ceiling
  col
  colMeans
  colnames
  colSums
  cos
  cosh
  cumsum
  complex
  dim
  exp
  expm1
  F
  FALSE
  floor
  head
  i
  ifelse
  Inf
  is_array
  is_character
  is_complex
  is_finite
  is_infinite
  is_matrix
  is_na
  is_nan
  is_null
  is_numeric
  is_double
  is_integer
  is_logical
  is_vector
  length
  log
  logb
  log2
  log10
  median
  mode
  NA
  names
  NaN
  ncol
  nrow
  NULL
  numeric
  matrix
  max
  mean
  min
  order
  paste
  pmax
  pmin
  prod
  range
  rbind
  rep
  replace
  rev
  rnorm
  round
  row
  rowMeans
  rownames
  rowSums
  sample
  seq
  sequence
  sin
  sinh
  sum
  sqrt
  sort
  t
  tail
  tan
  tanh
  typeof
  T
  TRUE
  trunc
  unique
  var
  which
/;

sub new {
  my $self = shift->SUPER::new(@_);
  
  for my $method (@methods) {
    my $function = "Rstats::ArrayUtil::$method";
    my $code = "sub { $function(\@_) }";

    no strict 'refs';
    $self->function($method => eval $code);
    croak $@ if $@;
  }

  return $self;
}

sub runif {
  my $self = shift;
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  $opt->{seed} = $self->{seed};

  my $a1 = Rstats::ArrayUtil::runif(@_, $opt);
  $self->{seed} = undef;
  
  return $a1;
}

sub set_seed {
  my ($self, $seed) = @_;
  
  $self->{seed} = $seed;
}

has functions => sub { {} };

sub AUTOLOAD {
  my $self = shift;

  my ($package, $method) = split /::(\w+)$/, our $AUTOLOAD;
  Carp::croak "Undefined subroutine &${package}::$method called"
    unless Scalar::Util::blessed $self && $self->isa(__PACKAGE__);

  # Call helper with current controller
  Carp::croak qq{Can't locate object method "$method" via package "$package"}
    unless my $function = $self->functions->{$method};
  return $function->(@_);
}

sub DESTROY { }

sub function {
  my $self = shift;
  
  # Merge
  my $functions = ref $_[0] eq 'HASH' ? $_[0] : {@_};
  $self->functions({%{$self->functions}, %$functions});
  
  return $self;
}

1;

=head1 NAME

Rstats::Class - Rstats class interface

=head1 SYNOPSYS
  
  use Rstats::Class;
  my $r = Rstats::Class->new;
  
  # Array
  my $v1 = $r->c([1, 2, 3]);
  my $v2 = $r->c([2, 3, 4]);
  my $v3 = $v1 + v2;
  print $v3;
