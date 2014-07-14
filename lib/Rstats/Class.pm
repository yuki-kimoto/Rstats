package Rstats::Class;

use Object::Simple -base;
require Rstats::ArrayUtil;

# TODO
#   logp1x
#   gamma
#   lgamma
#   complete_cases

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
  TRUE
  trunc
  var
  which
/;

for my $method (@methods) {
  my $function = "Rstats::ArrayUtil::$method";
  my $code = "sub { shift; $function(\@_) }";

  no strict 'refs';
  *{"Rstats::Class::$method"} = eval $code;
  croak $@ if $@;
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
