package Rstats::Class;

use Object::Simple -base;
require Rstats::ArrayUtil;
use Rstats::List;

# TODO
# logp1x
# gamma
# lgamma
# complete_cases
# cor
# pmatch regexpr
# substr substring
# strsplit  strwrap
# outer(x, y, f)

my @methods = qw/
  abs
  acos
  acosh
  append
  Arg
  array
  asin
  asinh
  atan2
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
  charmatch
  chartr
  cbind
  ceiling
  col
  colMeans
  colnames
  colSums
  Conj
  cos
  cosh
  cummax
  cummin
  cumsum
  cumprod
  complex
  diag
  diff
  dim
  exp
  expm1
  F
  FALSE
  floor
  grep
  gsub
  head
  i
  ifelse
  is_element
  Im
  Inf
  intersect
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
  kronecker
  log
  logb
  log2
  log10
  lower_tri
  match
  median
  Mod
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
  nchar
  order
  outer
  paste
  pi
  pmax
  pmin
  prod
  range
  rank
  rbind
  Re
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
  set_diag
  setdiff
  setequal
  sin
  sinh
  sum
  sqrt
  sort
  sub
  t
  tail
  tan
  tanh
  tolower
  toupper
  typeof
  T
  TRUE
  trunc
  unique
  union
  upper_tri
  var
  which
/;

my %no_args_methods_h = map {$_ => 1} qw/
  Inf
  NaN
  NA
  TRUE
  T
  FALSE
  F
  pi
/;

sub as_list {
  my ($self, $container) = @_;
  
  return $container if $self->is_list($container);

  my $list = Rstats::List->new;
  $list->elements($container->elements);
  
  return $list;
}

sub is_list {
  my ($self, $container) = @_;
  
  return ref $container eq 'Rstats::List' ? $self->TRUE : $self->FALSE;
}

sub list {
  my ($self, @elements) = @_;
  
  @elements = map { ref $_ ne 'Rstats::List' ? Rstats::ArrayUtil::to_array($_) : $_ } @elements;
  
  my $list = Rstats::List->new;
  $list->elements(\@elements);
  
  return $list;
}

sub length {
  my ($self, $container) = @_;
  
  return $container->length;
}

sub new {
  my $self = shift->SUPER::new(@_);
  
  for my $method (@methods) {
    my $function = "Rstats::ArrayUtil::$method";
    my $code;
    if ($no_args_methods_h{$method}) {
      $code = "sub { $function() }";
    }
    else {
      $code = "sub { $function(\@_) }";
    }

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
