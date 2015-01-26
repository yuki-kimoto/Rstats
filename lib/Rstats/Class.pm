package Rstats::Class;

use Object::Simple -base;
require Rstats::Func;
use Carp 'croak';
use List::Util ();

has helpers => sub { {} };

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
# reorder()
# relevel()
# read.csv()
# read.csv2()
# read.delim()
# read.delim2()
# read.fwf()
# merge
# replicate
# split
# by
# aggregate
# reshape

my @func_names2 = qw/
  sin
  sweep
  set_seed
  runif
  apply
  mapply
  tapply
  lapply
  sapply
  abs
  acos
  acosh
  append
  Arg
  asin
  asinh
  atan
  atanh
  atan2
  se
  charmatch
  chartr
  cbind
  ceiling
  col
  colMeans
  colSums
  Conj
  cos
  cosh
  cummax
  cummin
  cumsum
  cumprod
  data_frame
  diag
  diff
  exp
  expm1
  factor
  F
  FALSE
  floor
  gl
  grep
  gsub
  head
  ifelse
  interaction
  is_element
  I
  Im
  Re
  intersect
  kronecker
  list
  log
  logb
  log2
  log10
  lower_tri
  match
  median
  merge
  Mod
  NA
  NaN
  na_omit
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
  ordered
  outer
  paste
  pi
  pmax
  pmin
  prod
  range
  rank
  rbind
  quantile
  read_table
  rep
  replace
  rev
  rnorm
  round
  row
  rowMeans
  rowSums
  sample
  seq
  sequence
  set_diag
  setdiff
  setequal
  sinh
  sum
  sqrt
  sort
  sub
  subset
  t
  tail
  tan
  tanh
  tolower
  toupper
  T
  TRUE
  transform
  trunc
  unique
  union
  upper_tri
  var
  which
  as_array
  is_array
  is_character
  is_complex
  is_finite
  is_infinite
  is_list
  is_matrix
  is_na
/;

my @func_names = qw/
  is_nan
  is_null
  is_numeric
  is_double
  is_integer
  is_logical
  is_vector
  is_factor
  is_ordered
  is_data_frame
  labels
  levels
  dim
  names
  nlevels
  dimnames
  colnames
  rownames
  mode
  str
  typeof
  Inf
  NaN
  NA
  TRUE
  T
  FALSE
  F
  pi
  complex
  i
  array
  c
  length
  as_character
  as_complex
  as_integer
  as_double
  as_list
  as_logical
  as_matrix
  as_numeric
  as_vector
/;


sub new {
  my $self = shift->SUPER::new(@_);
  
  for my $func_name (@func_names) {
    no strict 'refs';
    my $func = \&{"Rstats::Func::$func_name"};
    $self->helper($func_name => $func);
  }

  for my $func_name (@func_names2) {
    no strict 'refs';
    my $func = \&{"Rstats::Func::$func_name"};
    $self->helper($func_name => sub { $func->($self, @_) });
  }
  
  return $self;
}

sub AUTOLOAD {
  my $self = shift;

  my ($package, $method) = split /::(\w+)$/, our $AUTOLOAD;
  Carp::croak "Undefined subroutine &${package}::$method called"
    unless Scalar::Util::blessed $self && $self->isa(__PACKAGE__);

  # Call helper with current controller
  Carp::croak qq{Can't locate object method "$method" via package "$package"}
    unless my $helper = $self->helpers->{$method};
  return $helper->(@_);
}

sub DESTROY { }

sub helper {
  my $self = shift;
  
  # Merge
  my $helpers = ref $_[0] eq 'HASH' ? $_[0] : {@_};
  $self->helpers({%{$self->helpers}, %$helpers});
  
  return $self;
}

1;

=head1 NAME

Rstats::Class - Rstats Object-Oriented interface

=head1 SYNOPSYS
  
  use Rstats::Class;
  my $r = Rstats::Class->new;
  
  # Array
  my $v1 = $r->c([1, 2, 3]);
  my $v2 = $r->c([2, 3, 4]);
  my $v3 = $v1 + v2;
  print $v3;
