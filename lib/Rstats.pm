package Rstats;
use strict;
use warnings;

our $VERSION = '0.01';

use Rstats::Class;

sub import {
  my $self = shift;
  
  my $class = caller;
  
  my $r = Rstats::Class->new;
  
  # Export primary methods
  no strict 'refs';
  my @methods = qw/c C array matrix list data_frame factor ordered/;
  for my $method (@methods) {
    *{"${class}::$method"} = sub { $r->$method(@_) }
  }
  *{"${class}::r"} = sub { $r };
  
  # Export none argument methods
  my @methods_no_args = qw/i T TRUE F FALSE NA NaN Inf NULL pi/;
  for my $method (@methods_no_args) {
    *{"${class}::$method"} = sub () { $r->$method };
  }
  
  warnings->unimport('ambiguous');
}

1;

=head1 NAME

Rstats - R language build on Perl

=head1 SYNOPSYS
  
  use Rstats;
  
  # Vector
  my $v1 = c(1, 2, 3);
  my $v2 = c(3, 4, 5);
  
  my $v3 = $v1 + v2;
  print $v3;
  
  # Sequence m:n
  my $v1 = C('1:3');

  # Matrix
  my $m1 = matrix(C('1:12'), 4, 3);
  
  # Array
  my $x1 = array(C(1:24), c(4, 3, 2));

  # Complex
  my $z1 = 1 + 2 * i;
  my $z2 = 3 + 4 * i;
  my $z3 = $z1 * $z2;
  
  # Special value
  my $true = TRUE;
  my $false = FALSE;
  my $na = NA;
  my $nan = NaN;
  my $inf = Inf;
  my $null = NULL;
  
  # all methods is called from r
  my $x1 = r->sum(c(1, 2, 3));
  
  # Register function
  r->function(my_sum => sub {
    my ($self, $x1) = @_;
    
    my $total = 0;
    for my $value ($x1->values) {
      $total += $value;
    }
    
    return c($total);
  });
  my $x2 = r->my_sum(c(1, 2, 3));

=head1 Corresponding to R

  # a1
  print $x1

  # c(1, 2, 3)
  c(1, 2, 3)

  # 1:24
  C('1:24')

  # array(1:24, c(4, 3, 2))
  array(C('1:24'), c(4, 3, 2))

  # 3 + 2i
  3 + 2*i
  
  # TRUE
  TRUE
  
  # T
  T
  
  # FALSE
  FALSE
  
  # F
  F
  
  # NA
  NA
  
  # NaN
  NaN
  
  # Inf
  Inf
  
  # NULL
  NULL
  
  # names
    # names(a1)
    r->names($x1)
  
    # names(a1) <- c("n1", "n2")
    r->names($x1, c("n1", "n2"));
  
  # matrix
    # matrix(1:12, 4, 3)
    matrix(C('1:12'), 4, 3)
    
    # matrix(1:12, nrow=4, ncol=3)
    matrix(C('1:12'), {nrow => 4, ncol => 3});
    
    # matrix(1:12, 4, 3, byrow=TRUE)
    matrix(C('1:12'), 4, 3, {byrow => 1});
  
  # operation
    # a1 + a2
    $x1 + $x2
    
    # a1 - a2
    $x1 - $x2
    
    # a1 * a2
    $x1 * $x2
    
    # a1 / a2
    $x1 / $x2
    
    # a1 ^ a2 (power)
    $x1 ** $x2
    
    # a1 %% a2 (remainder)
    $x1 % $x2

    # a1 %*% a2 (vector inner product or matrix product)
    $x1 x $x2
    
    # a1 %/% a2 (integer quotient)
    r->tranc($x1 / $x2)
  
  # get
    # a1[1]
    $x1->get(1)

    # a1[1, 2]
    $x1->get(1, 2)
    
    # a1[c(1,2), c(3,4)]
    $x1->get(c(1,2), c(3,4))
    
    # a1[,2]
    $x1->get(NULL, 2)
    
    # a1[-1]
    $x1->get(-1)
    
    # a1[TRUE, FALSE]
    $x1->get(TRUE, FALSE)
    
    # a1[c("id", "title")]
    $x1->get(c("id", "title"))
  
  # set
    # a1[1] <- a2
    $x1->at(1)->set($x2)

    # a1[1, 2] <- a2
    $x1->at(1, 2)->set($x2)
    
    # a1[c(1,2), c(3,4)] <- a2
    $x1->at(c(1,2), c(3,4))->set($x2)
    
    # a1[,2] <- a2
    $x1->at(NULL, 2)->set($x2)
    
    # a1[-1] <- a2
    $x1->at(-1)->set($x2)
    
    # a1[TRUE, FALSE] <- a2
    $x1->at(TRUE, FALSE)->set($x2);
    
    # a1[c("id", "title")] <- a2
    $x1->at(c("id", "title"))->set($x2);

  # as.matrix(a1)
  r->as_matrix($x1)
  
  # as.vector(a1)
  r->as_vector($x1)
  
  # as.array(a1)
  r->as_array($x1)

  # is.matrix(a1)
  r->is_matrix($x1)
  
  # is.vector(a1)
  r->is_vector($x1)
  
  # is.array(a1)
  r->is_array($x1)

  # abs(a1)
  r->abs($x1)
  
  # sqrt(a1)
  r->sqrt($x1)

  # exp(a1)
  r->exp($x1)
  
  # expm1(a1)
  r->expm1($x1)
  
  # log(a1)
  r->log($x1)
  
  # logb(a1)
  r->logb($x1)
  
  # log2(a1)
  r->log2($x1)
  
  # log10(a1)
  r->log10($x1)
  
  # sin(a1)
  r->sin($x1)
  
  # cos(a1)
  r->cos($x1)
  
  # tan(a1)
  r->tan($x1)
  
  # asin(a1)
  r->asin($x1)
  
  # acos(a1)
  r->acos($x1)
  
  # atan(a1)
  r->atan($x1)
  
  # sinh(a1)
  r->sinh($x1)
  
  # sinh(a1)
  r->sinh($x1)
  
  # cosh(a1)
  r->cosh($x1)
  
  # cosh(a1)
  r->cosh($x1)
  
  # atan(a1)
  r->atan($x1)
  
  # tanh(a1)
  r->tanh($x1)
  
  # asinh(a1)
  r->asinh($x1)
  
  # acosh(a1)
  r->acosh($x1)
  
  # acosh(a1)
  r->acosh($x1)
  
  # atanh(a1)
  r->atanh($x1)
  
  # ceiling(a1)
  r->ceiling($x1)
  
  # floor(a1)
  r->floor($x1)
  
  # trunc(a1)
  r->trunc($x1)
  
  # round
    # round(a1)
    r->round($x1)

    # round(a1, digit)
    r->round($x1, $digits)
    
    # round(a1, digits=1)
    r->round($x1, {digits => 1});
  
  # t
  r->t($x1)
  
  # rownames
    # rownames(a1)
    r->rownames($x1)
    
    # rownames(a1) = c("r1", "r2")
    r->rownames($x1, c("r1", "r2"))
    
  # colnames
    # colnames(a1)
    r->colnames($x1)
    
    # colnames(a1) = c("r1", "r2")
    r->colnames($x1, c("r1", "r2"))

  # nrow(a1)
  r->nrow($x1)
  
  # ncol(a1)
  r->ncol($x1)
  
  # row(a1)
  r->row($x1)
  
  # col(a1)
  r->col($x1)

  # colMeans(a1)
  r->colMeans($x1)
  
  # rowMeans(a1)
  r->rowMeans($x1)
  
  # rowSums(a1)
  r->rowSums($x1)
  
  # rbind(c(1, 2), c(3, 4), c(5, 6))
  r->rbind(c(1, 2), c(3, 4), c(5, 6))
  
  # cbind(c(1, 2), c(3, 4), c(5, 6))
  r->cbind(c(1, 2), c(3, 4), c(5, 6));
