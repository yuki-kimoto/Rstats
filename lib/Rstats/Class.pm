package Rstats::Class;

use Object::Simple -base;
require Rstats::Func;
use Carp 'croak';

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

my @funcs = qw/
  abs
  acos
  acosh
  append
  apply
  Arg
  array
  asin
  asinh
  atan2
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
  colSums
  Conj
  cos
  cosh
  cummax
  cummin
  cumsum
  cumprod
  complex
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
  i
  ifelse
  interaction
  is_element
  Im
  Inf
  intersect
  kronecker
  length
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
  Re
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
  sin
  sinh
  sum
  sqrt
  sort
  sub
  sweep
  t
  tail
  tan
  tanh
  tolower
  toupper
  T
  TRUE
  trunc
  unique
  union
  upper_tri
  var
  which
/;

my @object_methods = qw/
  as_array
  as_character
  as_complex
  as_integer
  as_list
  as_logical
  as_matrix
  as_numeric
  as_vector
  is_array
  is_character
  is_complex
  is_finite
  is_infinite
  is_list
  is_matrix
  is_na
  is_nan
  is_null
  is_numeric
  is_double
  is_integer
  is_logical
  is_vector
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

sub new {
  my $self = shift->SUPER::new(@_);
  
  for my $func (@funcs) {
    my $function = "Rstats::Func::$func";
    my $code;
    if ($no_args_methods_h{$func}) {
      $code = "sub { $function() }";
    }
    else {
      $code = "sub { $function(\@_) }";
    }

    no strict 'refs';
    $self->function($func => eval $code);
    croak $@ if $@;
  }
  
  for my $method (@object_methods) {
    my $code = "sub { shift->$method(\@_) }";
    no strict 'refs';
    $self->function($method => eval $code);
    croak $@ if $@;
  }
  
  $self->function(runif => sub { $self->_runif(@_) });
  $self->function(set_seed => sub { $self->_set_seed(@_) });

  return $self;
}

sub _runif {
  my $self = shift;
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  $opt->{seed} = $self->{seed};

  my $x1 = Rstats::Func::runif(@_, $opt);
  $self->{seed} = undef;
  
  return $x1;
}

sub _set_seed {
  my ($self, $seed) = @_;
  
  $self->{seed} = $seed;
}

sub sapply {
  my $x1 = shift->lapply(@_);
  
  my $x2 = Rstats::Func::c($x1->elements);
  
  return $x2;
}

sub lapply {
  my $self = shift;
  my $func_name = splice(@_, 1, 1);
  my ($x1)
    = Rstats::Func::args(['x1'], @_);
  
  my $func = ref $func_name ? $func_name : $self->functions->{$func_name};
  
  my $new_elements = [];
  for my $element (@{$x1->elements}) {
    push @$new_elements, $func->($element);
  }
  
  my $x2 = $x1->clone(elements => $new_elements);
  
  return $x2;
}

sub apply {
  my $self = shift;
  my $func_name = splice(@_, 2, 1);
  my ($x1, $x_margin)
    = Rstats::Func::args(['x1', 'margin'], @_);
  
  my $func = ref $func_name ? $func_name : $self->functions->{$func_name};

  my $dim_values = $x1->dim->values;
  my $margin_values = $x_margin->values;
  my $new_dim_values = [];
  for my $i (@$margin_values) {
    push @$new_dim_values, $dim_values->[$i - 1];
  }
  
  my $x1_length = $x1->length_value;
  my $new_elements_array = [];
  for (my $i = 0; $i < $x1_length; $i++) {
    my $index = Rstats::Util::pos_to_index($i, $dim_values);
    my $e1 = $x1->element(@$index);
    my $new_index = [];
    for my $i (@$margin_values) {
      push @$new_index, $index->[$i - 1];
    }
    my $new_pos = Rstats::Util::index_to_pos($new_index, $new_dim_values);
    $new_elements_array->[$new_pos] ||= [];
    push @{$new_elements_array->[$new_pos]}, $e1;
  }
  
  my $new_elements = [];
  for my $element_array (@$new_elements_array) {
    push @$new_elements, $func->($element_array);
  }

  my $x2 = $x1->clone(elements => $new_elements);
  $x2->{dim} = $new_dim_values;
  
  if (@{$x2->{dim}} == 1) {
    delete $x2->{dim};
  }
  
  return $x2;
}

sub sweep {
  my $self = shift;

  my ($x1, $x_margin, $x2, $x_func)
    = Rstats::Func::args(['x1', 'margin', 'x2', 'FUN'], @_);
  
  my $x_margin_values = $x_margin->values;
  my $func = defined $x_func ? $x_func->value : '-';
  
  my $x2_dim_values = $x2->dim->values;
  my $x1_dim_values = $x1->dim->values;
  
  my $x1_length = $x1->length_value;
  
  my $x_result_elements = [];
  for (my $x1_pos = 0; $x1_pos < $x1_length; $x1_pos++) {
    my $x1_index = Rstats::Util::pos_to_index($x1_pos, $x1_dim_values);
    
    my $new_index = [];
    for my $x_margin_value (@$x_margin_values) {
      push $new_index, $x1_index->[$x_margin_value - 1];
    }
    
    my $e1 = $x2->element(@{$new_index});
    push @$x_result_elements, $e1;
  }
  my $x3 = $x1->clone(elements => $x_result_elements);
  
  my $x4;
  if ($func eq '+') {
    $x4 = $x1 + $x3;
  }
  elsif ($func eq '-') {
    $x4 = $x1 - $x3;
  }
  elsif ($func eq '*') {
    $x4 = $x1 * $x3;
  }
  elsif ($func eq '/') {
    $x4 = $x1 / $x3;
  }
  elsif ($func eq '**') {
    $x4 = $x1 ** $x3;
  }
  elsif ($func eq '%') {
    $x4 = $x1 % $x3;
  }
  
  return $x4;
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
