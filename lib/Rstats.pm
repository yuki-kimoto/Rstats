package Rstats;
use strict;
use warnings;

our $VERSION = '0.0148';

use Object::Simple -base;
require Rstats::Func;
use Carp 'croak';
use Rstats::Util ();
use Digest::MD5 'md5_hex';
use Rstats::Object;

has helpers => sub { {} };

sub get_helper {
  my ($self, $name,) = @_;
  
  if ($self->{proxy}{$name}) {
    return bless {r => $self}, $self->{proxy}{$name};
  }
  elsif (my $h = $self->helpers->{$name}) {
    return $h;
  }

  my $found;
  my $class = 'Rstats::Helpers::' . md5_hex "$name:$self";
  my $re = $name eq '' ? qr/^(([^.]+))/ : qr/^(\Q$name\E\.([^.]+))/;
  for my $key (keys %{$self->helpers}) {
    $key =~ $re ? ($found, my $method) = (1, $2) : next;
    my $sub = $self->get_helper($1);
    Rstats::Util::monkey_patch $class, $method => sub {
      my $proxy = shift;
      return $sub->($proxy->{r}, @{$proxy->{args} || []}, @_);
    }
  }

  $found ? push @{$self->{namespaces}}, $class : return undef;
  $self->{proxy}{$name} = $class;
  return $self->get_helper($name);
}

my @func_names = qw/
  sd
  sin
  sweep
  set_seed
  runif
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
  c
  c_double
  c_integer
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
  diag
  diff
  exp
  expm1
  FALSE
  floor
  gl
  grep
  gsub
  head
  i
  ifelse
  interaction
  I
  Im
  Re
  intersect
  kronecker
  log
  logb
  log2
  log10
  lower_tri
  match
  median
  merge
  Mod
  NaN
  na_omit
  ncol
  nrow
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
  TRUE
  transform
  trunc
  unique
  union
  upper_tri
  var
  which
  str
  typeof
  pi
  array
  length
  clone
  equal
  not_equal
  less_than
  less_than_or_equal
  more_than
  more_than_or_equal
  add
  subtract
  multiply
  divide
  pow
  negate
  dim
  Inf
  NaN
  to_string
  get
  set
  getin
  value
  values
  dim_as_array
  type
  get_type
  at
  get_length
/;

sub new {
  my $self = shift->SUPER::new(@_);
  
  for my $func_name (@func_names) {
    no strict 'refs';
    my $func = \&{"Rstats::Func::$func_name"};
    $self->helper($func_name => $func);
  }

  no strict 'refs';
  $self->helper('is.array' => \&Rstats::Func::is_array);
  $self->helper('is.finite' => \&Rstats::Func::is_finite);
  $self->helper('is.infinite' => \&Rstats::Func::is_infinite);
  $self->helper('is.matrix' => \&Rstats::Func::is_matrix);
  $self->helper('is.nan' => \&Rstats::Func::is_nan);
  $self->helper('is.numeric' => \&Rstats::Func::is_numeric);
  $self->helper('is.double' => \&Rstats::Func::is_double);
  $self->helper('is.integer' => \&Rstats::Func::is_integer);
  $self->helper('is.vector' => \&Rstats::Func::is_vector);
  $self->helper('is.ordered' => \&Rstats::Func::is_ordered);
  $self->helper('is.element' => \&Rstats::Func::is_element);

  $self->helper('as.array' => \&Rstats::Func::as_array);
  $self->helper('as.integer' => \&Rstats::Func::as_integer);
  $self->helper('as.double' => \&Rstats::Func::as_double);
  $self->helper('as.matrix' => \&Rstats::Func::as_matrix);
  $self->helper('as.numeric' => \&Rstats::Func::as_numeric);
  $self->helper('as.vector' => \&Rstats::Func::as_vector);

  return $self;
}

sub AUTOLOAD {
  my $self = shift;

  my ($package, $method) = split /::(\w+)$/, our $AUTOLOAD;
  Carp::croak "Undefined subroutine &${package}::$method called"
    unless Scalar::Util::blessed $self && $self->isa(__PACKAGE__);

  # Call helper with current controller
  Carp::croak qq{Can't locate object method "$method" via package "$package"}
    unless my $helper = $self->get_helper($method);
  
  # Helper
  if (ref $helper eq 'CODE') {
    return $helper->($self, @_);
  }
  #Proxy
  else {
    return $helper;
  }
}

sub DESTROY { }

sub helper {
  my $self = shift;
  
  # Merge
  my $helpers = ref $_[0] eq 'HASH' ? $_[0] : {@_};
  $self->helpers({%{$self->helpers}, %$helpers});
  
  return $self;
}

require XSLoader;
XSLoader::load('Rstats', $VERSION);

1;

=head1 NAME

Rstats - R language build on Perl

B<Rstats is yet experimental release. Incompatible change will occur without warning.>

=head1 SYNOPSYS
  
  use Rstats;
  
  # Vector
  my $v1 = $r->c(1, 2, 3);
  my $v2 = $r->c(3, 4, 5);
  
  my $v3 = $v1 + v2;
  print $v3;
  
  # Sequence m:n
  my $v1 = $r->C("1:3");

  # Matrix
  my $m1 = $r->matrix($r->C("1:12"), 4, 3);
  
  # Array
  my $a1 = $r->array($r->C("1:24"), $r->c(4, 3, 2));

  # Complex
  my $z1 = 1 + 2 * $r->i;
  my $z2 = 3 + 4 * $r->i;
  my $z3 = $z1 * $z2;
  
  # Special value
  my $true = $r->TRUE;
  my $false = $r->FALSE;
  my $nan = $r->NaN;
  my $inf = $r->Inf;
  
  # all methods are called from r
  my $x1 = $r->sum($r->c(1, 2, 3));
  
  # Register helper
  $r->helper(my_sum => sub {
    my ($r, $x1) = @_;
    
    my $total = 0;
    for my $value (@{$x1->values}) {
      $total += $value;
    }
    
    return $r->c($total);
  });
  my $x2 = $r->my_sum($r->c(1, 2, 3));

=head1 VECTOR ACCESS

=head2 Getter

  # x1[1]
  $x1->get(1)

  # x1[1, 2]
  $x1->get(1, 2)
  
  # x1[c(1,2), c(3,4)]
  $x1->get(c(1,2), c(3,4))
  
  # x1[,2]
  $x1->get(undef, 2)
  
  # x1[-1]
  $x1->get(-1)
  
  # x1[TRUE, FALSE]
  $x1->get(TRUE, FALSE)
  
  # x1[c("id", "title")]
  $x1->get(c("id", "title"))

=head2 Setter

  # x1[1] <- x2
  $x1->at(1)->set($x2)

  # x1[1, 2] <- x2
  $x1->at(1, 2)->set($x2)
  
  # x1[c(1,2), c(3,4)] <- x2
  $x1->at(c(1,2), c(3,4))->set($x2)
  
  # x1[,2] <- x2
  $x1->at(undef, 2)->set($x2)
  
  # x1[-1] <- x2
  $x1->at(-1)->set($x2)
  
  # x1[TRUE, FALSE] <- x2
  $x1->at(TRUE, FALSE)->set($x2);
  
  # x1[c("id", "title")] <- x2
  $x1->at(c("id", "title"))->set($x2);

=head1 OPERATORS

  # x1 + x2
  $x1 + $x2
  
  # x1 - x2
  $x1 - $x2
  
  # x1 * x2
  $x1 * $x2
  
  # x1 / x2
  $x1 / $x2
  
  # x1 ^ x2 (power)
  $x1 ** $x2
  
  # x1 %% x2 (remainder)
  $x1 % $x2

  # x1 %*% x2 (vector inner product or matrix product)
  $x1 x $x2
  
  # x1 %/% x2 (integer quotient)
  $r->tranc($x1 / $x2)

=head1 METHODS

=head2 c

  # c(1, 2, 3)
  $r->c(1, 2, 3)

Create vector. C<c> method is equal to C<c> of R.

=head2 C

  # 1:24
  C("1:24")

C function is equal to C<m:n> of R.

=head2 array

  # array(1:24, c(4, 3, 2))
  $r->array($r->C("1:24"), $r->c(4, 3, 2))

=head2 TRUE

  # TRUE
  $r->TRUE

=head2 T

  # T
  $r->T

Alias of TRUE

=head2 FALSE
  
  # FALSE
  $r->FALSE

=head2 F
  
  # F
  $r->F

Alias of FALSE

=head2 NaN
  
  # NaN
  $r->NaN

=head2 Inf

  # Inf
  $r->Inf

=head2 matrix

  # matrix(1:12, 4, 3)
  $r->matrix($r->C("1:12"), 4, 3)
  
  # matrix(1:12, nrow=4, ncol=3)
  $r->matrix($r->C("1:12"), {nrow => 4, ncol => 3});
  
  # matrix(1:12, 4, 3, byrow=TRUE)
  $r->matrix($r->C("1:12"), 4, 3, {byrow => $r->TRUE});

=head2 abs

  # abs(x1)
  $r->abs($x1)

=head2 acos

  # acos(x1)
  $r->acos($x1)

=head2 acosh

  # acosh(x1)
  $r->acosh($x1)

=head2 append

=head2 Arg

=head2 array

=head2 asin

  # asin(x1)
  $r->asin($x1)

=head2 asinh

  # asinh(x1)
  $r->asinh($x1)

=head2 atan2

=head2 atan

  # atan(x1)
  $r->atan($x1)

=head2 atanh

  # atanh(x1)
  $r->atanh($x1)

=head2 c

=head2 vec

=head2 charmatch

=head2 chartr

=head2 cbind

  # cbind(c(1, 2), c(3, 4), c(5, 6))
  $r->cbind(c(1, 2), c(3, 4), c(5, 6));

=head2 ceiling

  # ceiling(x1)
  $r->ceiling($x1)

=head2 col

  # col(x1)
  $r->col($x1)

=head2 colMeans

  # colMeans(x1)
  $r->colMeans($x1)

=head2 colSums

=head2 Conj

=head2 cos

  # cos(x1)
  $r->cos($x1)

=head2 cosh

  # cosh(x1)
  $r->cosh($x1)

=head2 cummax

=head2 cummin

=head2 cumsum

=head2 cumprod

=head2 diag

=head2 diff

=head2 exp

  # exp(x1)
  $r->exp($x1)

=head2 expm1

  # expm1(x1)
  $r->expm1($x1)

=head2 F

=head2 FALSE

=head2 floor

  # floor(x1)
  $r->floor($x1)

=head2 gl

=head2 grep

=head2 gsub

=head2 head

=head2 i

=head2 ifelse

=head2 interaction

=head2 is->element

=head2 I

=head2 Im

=head2 Inf

=head2 intersect

=head2 kronecker

=head2 length

=head2 log

  # log(x1)
  $r->log($x1)

=head2 logb

  # logb(x1)
  $r->logb($x1)

=head2 log2

  # log2(x1)
  $r->log2($x1)

=head2 log10

  # log10(x1)
  $r->log10($x1)

=head2 lower_tri

=head2 match

=head2 median

=head2 merge

=head2 Mod

=head2 NaN

=head2 na_omit

=head2 ncol

  # ncol(x1)
  $r->ncol($x1)

=head2 nrow

  # nrow(x1)
  $r->nrow($x1)

=head2 numeric

=head2 matrix

=head2 max

=head2 mean

=head2 min

=head2 nchar

=head2 order

=head2 ordered

=head2 outer

=head2 paste

=head2 pi

=head2 pmax

=head2 pmin

=head2 prod

=head2 range

=head2 rank

=head2 rbind

  # rbind(c(1, 2), c(3, 4), c(5, 6))
  $r->rbind(c(1, 2), c(3, 4), c(5, 6))

=head2 Re

=head2 quantile

=head2 read->table

  # read.table(...)
  $r->read->table(...)

=head2 rep

=head2 replace

=head2 rev

=head2 rnorm

=head2 round

  # round(x1)
  $r->round($x1)

  # round(x1, digit)
  $r->round($x1, $digits)
  
  # round(x1, digits=1)
  $r->round($x1, {digits => TRUE});

=head2 row

  # row(x1)
  $r->row($x1)

=head2 rowMeans

  # rowMeans(x1)
  $r->rowMeans($x1)

=head2 rowSums

  # rowSums(x1)
  $r->rowSums($x1)

=head2 sample

=head2 seq

=head2 sequence

=head2 set_diag

=head2 setdiff

=head2 setequal

=head2 sin

  # sin(x1)
  $r->sin($x1)

=head2 sinh

  # sinh(x1)
  $r->sinh($x1)

=head2 sum

=head2 sqrt

  # sqrt(x1)
  $r->sqrt($x1)

=head2 sort

=head2 sub

=head2 subset

=head2 sweep

=head2 t

  # t
  $r->t($x1)

=head2 tail

=head2 tan

  # tan(x1)
  $r->tan($x1)

=head2 tanh

  # tanh(x1)
  $r->tanh($x1)

=head2 tolower

=head2 toupper

=head2 T

=head2 TRUE

=head2 transform

=head2 trunc

  # trunc(x1)
  $r->trunc($x1)

=head2 unique

=head2 union

=head2 upper_tri

=head2 var

=head2 which

=head2 as->array

  # as.array(x1)
  $r->as->array($x1)

=head2 as->integer

  # as.integer(x1)
  $r->as->integer($x1)

=head2 as->matrix

  # as.matrix(x1)
  $r->as->matrix($x1)

=head2 as->numeric

  # as.numeric(x1)
  $r->as->numeric($x1)

=head2 as->vector

  # as.vector(x1)
  $r->as->vector($x1)

=head2 is->array

  # is.array(x1)
  $r->is->array($x1)

=head2 is->finite

  # is.finite(x1)
  $r->is->finite($x1)

=head2 is->infinite

  # is.infinite(x1)
  $r->is->infinite($x1)

=head2 is->matrix

  # is.matrix(x1)
  $r->is->matrix($x1)

=head2 is->na

  # is.na(x1)
  $r->is->na($x1)

=head2 is->nan

  # is.nan(x1)
  $r->is->nan($x1)

=head2 is->numeric

  # is.numeric(x1)
  $r->is->numeric($x1)

=head2 is->double

  # is.double(x1)
  $r->is->double($x1)

=head2 is->integer

  # is.integer(x1)
  $r->is->integer($x1)

=head2 is->vector

  # is.vector(x1)
  $r->is->vector($x1)

=head2 dim

  # dim(x1)
  $r->dim($x1)
  
  # dim(x1) <- c(1, 2)
  $r->dim($x1 => c(1, 2))

=head2 str

  # str(x1)
  $r->str($x1)

=head2 typeof

  # typeof(x1)
  $r->typeof($x1);
