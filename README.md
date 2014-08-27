# Rstats

R language build on Perl (EXPERIMENTAL)

# Features

* R language build on Perl
* Support same syntax as R, as possible

# Installation

If you alrealdy install local perl by perlbrew or plenv,
you can put only the following command.

    git clone https://github.com/yuki-kimoto/Rstats.git
    tar cfz Rstats.tar.gz Rstats;
    curl -L cpanmin.us | perl - -n Rstats.tar.gz

# Usage

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
    my $a1 = array(C('1:24'), c(4, 3, 2));

    # Complex
    my $z1 = 1 + 2 * i;
    my $z2 = 3 + 4 * i;
    my $z3 = $z1 * $z2;
    
    # Special value
    my $true = TRUE;
    my $false = FALSE;
    my $na = NA;
    my $nan = Nan;
    my $inf = Inf;
    my $null = NULL;
    
    # all methods is called from r
    my $a1 = r->sum(c(1, 2, 3));

See examples in t directory to know current inplemented features.

# Corresponding to R

    # a1
    print $a1

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
    
    # FALSE
    FALSE
    
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
      r->names($a1)
    
      # names(a1) <- c("n1", "n2")
      r->names($a1 => c("n1", "n2"));
    
    # matrix
      # matrix(1:12, 4, 3)
      matrix(C('1:12'), 4, 3)
      
      # matrix(1:12, nrow=4, ncol=3)
      matrix(C('1:12'), {nrow => 4, ncol => 3});
      
      # matrix(1:12, 4, 3, byrow=TRUE)
      matrix(C('1:12'), 4, 3, {byrow => 1});
    
    # operation
      # a1 + a2
      $a1 + $a2
      
      # a1 - a2
      $a1 - $a2
      
      # a1 * a2
      $a1 * $a2
      
      # a1 / a2
      $a1 / $a2
      
      # a1 ^ a2 (power)
      $a1 ** $a2
      
      # a1 %% a2 (remainder)
      $a1 % $a2

      # a1 %*% a2 (vector inner product or matrix product)
      $a1 x $a2
      
      # a1 %/% a2 (integer quotient)
      r->tranc($a1 / $a2)
    
    # get
      # a1[1]
      $a1->get(1)

      # a1[1, 2]
      $a1->get(1, 2)
      
      # a1[c(1,2), c(3,4)]
      $a1->get(c(1,2), c(3,4))
      
      # a1[,2]
      $a1->get(NULL, 2)
      
      # a1[-1]
      $a1->get(-1)
      
      # a1[TRUE, FALSE]
      $a1->get(TRUE, FALSE)
      
      # a1[c("id", "title")]
      $a1->get(c("id", "title"))
    
    # set
      # a1[1] <- a2
      $a1->at(1)->set($a2)

      # a1[1, 2] <- a2
      $a1->at(1, 2)->set($a2)
      
      # a1[c(1,2), c(3,4)] <- a2
      $a1->at(c(1,2), c(3,4))->set($a2)
      
      # a1[,2] <- a2
      $a1->at(NULL, 2)->set($a2)
      
      # a1[-1] <- a2
      $a1->at(-1)->set($a2)
      
      # a1[TRUE, FALSE] <- a2
      $a1->at(TRUE, FALSE)->set($a2);
      
      # a1[c("id", "title")] <- a2
      $a1->at(c("id", "title"))->set($a2);

    # as.matrix(a1)
    r->as_matrix($a1)
    
    # as.vector(a1)
    r->as_vector($a1)
    
    # as.array(a1)
    r->as_array($a1)

    # is.matrix(a1)
    r->is_matrix($a1)
    
    # is.vector(a1)
    r->is_vector($a1)
    
    # is.array(a1)
    r->is_array($a1)

    # abs(a1)
    r->abs($a1)
    
    # sqrt(a1)
    r->sqrt($a1)

    # exp(a1)
    r->exp($a1)
    
    # expm1(a1)
    r->expm1($a1)
    
    # log(a1)
    r->log($a1)
    
    # logb(a1)
    r->logb($a1)
    
    # log2(a1)
    r->log2($a1)
    
    # log10(a1)
    r->log10($a1)
    
    # sin(a1)
    r->sin($a1)
    
    # cos(a1)
    r->cos($a1)
    
    # tan(a1)
    r->tan($a1)
    
    # asin(a1)
    r->asin($a1)
    
    # acos(a1)
    r->acos($a1)
    
    # atan(a1)
    r->atan($a1)
    
    # sinh(a1)
    r->sinh($a1)
    
    # sinh(a1)
    r->sinh($a1)
    
    # cosh(a1)
    r->cosh($a1)
    
    # cosh(a1)
    r->cosh($a1)
    
    # atan(a1)
    r->atan($a1)
    
    # tanh(a1)
    r->tanh($a1)
    
    # asinh(a1)
    r->asinh($a1)
    
    # acosh(a1)
    r->acosh($a1)
    
    # acosh(a1)
    r->acosh($a1)
    
    # atanh(a1)
    r->atanh($a1)
    
    # ceiling(a1)
    r->ceiling($a1)
    
    # floor(a1)
    r->floor($a1)
    
    # trunc(a1)
    r->trunc($a1)
    
    # round
      # round(a1)
      r->round($a1)

      # round(a1, digit)
      r->round($a1, $digits)
      
      # round(a1, digits=1)
      r->round($a1, {digits => 1});
    
    # t
    r->t($a1)
    
    # rownames
      # rownames(a1)
      r->rownames($a1)
      
      # rownames(a1) <- c("r1", "r2")
      r->rownames($a1 => c("r1", "r2"))
      
    # colnames
      # colnames(a1)
      r->colnames($a1)
      
      # colnames(a1) <- c("r1", "r2")
      r->colnames($a1 => c("r1", "r2"))

    # nrow(a1)
    r->nrow($a1)
    
    # ncol(a1)
    r->ncol($a1)
    
    # row(a1)
    r->row($a1)
    
    # col(a1)
    r->col($a1)

    # colMeans(a1)
    r->colMeans($a1)
    
    # rowMeans(a1)
    r->rowMeans($a1)
    
    # rowSums(a1)
    r->rowSums($a1)
    
    # rbind(c(1, 2), c(3, 4), c(5, 6))
    r->rbind(c(1, 2), c(3, 4), c(5, 6))
    
    # cbind(c(1, 2), c(3, 4), c(5, 6))
    r->cbind(c(1, 2), c(3, 4), c(5, 6));
