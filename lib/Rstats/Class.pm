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

my @func_names = qw/
  double_xs
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
  I
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
  subset
  sweep
  t
  tail
  tan
  tanh
  tapply
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
  
  for my $func_name (@func_names) {
    no strict 'refs';
    my $func = \&{"Rstats::Func::$func_name"};
    $self->helper($func_name => $func);
  }
  
  # set_seed
  $self->helper(set_seed => sub {
    my $seed = shift;
    
    $self->{seed} = $seed;
  });
  
  # runif
  $self->helper(runif => sub {
    my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
    $opt->{seed} = $self->{seed} if defined $self->{seed};

    my $x1 = Rstats::Func::runif(@_, $opt);
    $self->{seed} = undef;
    
    return $x1;
  });
  
  # apply
  $self->helper(apply => sub {
    my @args = @_;
    my $func_name = $args[2];
    my $func = ref $func_name ? $func_name : $self->helpers->{$func_name};
    $args[2] = $func;
    return Rstats::Func::apply(@args);
  });

  return $self;
}

sub sapply {
  my $x1 = shift->lapply(@_);
  
  my $x2 = Rstats::ArrayFunc::c(@{$x1->list});
  
  return $x2;
}

sub lapply {
  my $self = shift;
  my $func_name = splice(@_, 1, 1);
  my ($x1)
    = Rstats::Func::args_array(['x1'], @_);
  
  my $func = ref $func_name ? $func_name : $self->helpers->{$func_name};
  
  my $new_elements = [];
  for my $element (@{$x1->list}) {
    push @$new_elements, $func->($element);
  }
  
  my $x2 = Rstats::Func::list(@$new_elements);
  $x1->copy_attrs_to($x2);
  
  return $x2;
}

sub tapply {
  my $self = shift;

  my $func_name = splice(@_, 2, 1);
  my ($x1, $x2)
    = Rstats::Func::args_array(['x1', 'x2'], @_);
  
  my $func = ref $func_name ? $func_name : $self->helpers->{$func_name};
  
  my $new_values = [];
  my $x1_values = $x1->values;
  my $x2_values = $x2->values;
  
  # Group values
  for (my $i = 0; $i < $x1->length_value; $i++) {
    my $x1_value = $x1_values->[$i];
    my $index = $x2_values->[$i];
    $new_values->[$index] ||= [];
    push @{$new_values->[$index]}, $x1_value;
  }
  
  # Apply
  my $new_values2 = [];
  for (my $i = 1; $i < @$new_values; $i++) {
    my $x = $func->(Rstats::ArrayFunc::c(@{$new_values->[$i]}));
    push @$new_values2, $x;
  }
  
  my $x4_length = @$new_values2;
  my $x4 = Rstats::Func::array(Rstats::ArrayFunc::c(@$new_values2), $x4_length);
  $x4->names($x2->levels);
  
  return $x4;
}

sub mapply {
  my $self = shift;
  my $func_name = splice(@_, 0, 1);
  my $func = ref $func_name ? $func_name : $self->helpers->{$func_name};

  my @xs = @_;
  @xs = map { Rstats::ArrayFunc::c($_) } @xs;
  
  # Fix length
  my @xs_length = map { $_->length_value } @xs;
  my $max_length = List::Util::max @xs_length;
  for my $x (@xs) {
    if ($x->length_value < $max_length) {
      $x = Rstats::Func::array($x, $max_length);
    }
  }
  
  # Apply
  my $new_xs = [];
  for (my $i = 0; $i < $max_length; $i++) {
    my @args = map { $_->value($i + 1) } @xs;
    my $x = $func->(@args);
    push @$new_xs, $x;
  }
  
  if (@$new_xs == 1) {
    return $new_xs->[0];
  }
  else {
    return Rstats::Func::list(@$new_xs);
  }
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
