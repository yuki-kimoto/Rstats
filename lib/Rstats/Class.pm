package Rstats::Class;

use Object::Simple -base;
require Rstats::ArrayUtil;
use Rstats::Container::List;
use Rstats::Container::DataFrame;
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

my @arrayutil_methods = qw/
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

my @object_methods = qw/
  names
  dimnames
  colnames
  rownames
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
  
  for my $method (@arrayutil_methods) {
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
  
  for my $method (@object_methods) {
    my $code = "sub { shift->$method(\@_) }";
    no strict 'refs';
    $self->function($method => eval $code);
    croak $@ if $@;
  }

  return $self;
}

sub data_frame {
  my ($self, @data) = @_;
  
  my $elements = [];
  
  # count
  my $counts = [];
  my $names = [];
  while (my ($name, $v) = splice(@data, 0, 2)) {
    my $dim_values = Rstats::ArrayUtil::dim($v)->values;
    if (@$dim_values > 1) {
      my $count = $dim_values->[0];
      my $dim_product = 1;
      $dim_product *= $dim_values->[$_] for (1 .. @$dim_values - 1);
      
      for my $num (1 .. $dim_product) {
        push @$counts, $count;
        push @$names, "$name.$num";
        push @$elements, splice(@{$v->elements}, 0, $count);
      }
    }
    else {
      my $count = @{$v->elements};
      push @$counts, $count;
      push @$names, $name;
      push @$elements, $v;
    }
  }
  
  # Max count
  my $max_count = List::Util::max @$counts;
  
  # Check multiple number
  for my $count (@$counts) {
    if ($max_count % $count != 0) {
      croak "Error in data.frame: arguments imply differing number of rows: @$counts";
    }
  }
  
  # Fill vector
  for (my $i = 0; $i < @$counts; $i++) {
    my $count = $counts->[$i];
    
    my $repeat = $max_count / $count;
    if ($repeat > 1) {
      $elements->[$i] = Rstats::ArrayUtil::c(($elements->[$i]) x $repeat);
    }
  }

  my $data_frame = Rstats::Container::DataFrame->new;
  $data_frame->elements($elements);
  $data_frame->names($names);
  
  return $data_frame;
}

sub as_list {
  my ($self, $container) = @_;
  
  return $container if $self->is_list($container);

  my $list = Rstats::Container::List->new;
  $list->elements($container->elements);
  
  return $list;
}

sub is_list {
  my ($self, $container) = @_;
  
  return ref $container eq 'Rstats::Container::List' ? $self->TRUE : $self->FALSE;
}

sub list {
  my ($self, @elements) = @_;
  
  @elements = map { ref $_ ne 'Rstats::Container::List' ? Rstats::ArrayUtil::to_array($_) : $_ } @elements;
  
  my $list = Rstats::Container::List->new;
  $list->elements(\@elements);
  
  return $list;
}

sub length {
  my ($self, $container) = @_;
  
  return $container->length;
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
