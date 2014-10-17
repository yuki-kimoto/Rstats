package Rstats::ElementFunc;

use strict;
use warnings;
use Carp 'croak', 'carp';

require Rstats;
use Rstats::Element;
use Scalar::Util ();
use Math::Complex ();
use Math::Trig ();
use POSIX ();

# Perl infinite values(this is value is only valid as return value)
my $perl_inf_result = 9 ** 9 ** 9;
my $perl_negative_inf_result = -9 ** 9 ** 9;

sub TRUE () { new_logical(1) }
sub FALSE () { new_logical(0) }
sub NA () { new_NA() }
sub NaN () { new_NaN() }
sub Inf () { new_Inf() }
sub negativeInf () { new_negativeInf() }
sub pi () { new_double(Math::Trig::pi) }

sub character { new_character(@_) }

sub complex { new_complex(@_) }

sub double { new_double(shift) }
sub integer { new_integer(shift) }
sub logical { new_logical(shift) }

sub atanh {
  my $e1 = shift;
  
  return $e1 if $e1->is_na;
  
  my $e2;
  if ($e1->is_complex) {
    if (equal($e1, complex(1, 0))) {
      $e2 = complex_double(Inf, NaN);
      carp("In atanh() : NaNs produced");
    }
    elsif (equal($e1, complex(-1, 0))) {
      $e2 = complex_double(negativeInf, NaN);
      carp("In atanh() : NaNs produced");
    }
    else {
      $e2 = multiply(
        complex(0.5, 0),
        Rstats::ElementFunc::log(
          divide(
            add(complex(1, 0), $e1),
            subtract(complex(1, 0), $e1)
          )
        )
      );
    }
  }
  elsif ($e1->is_numeric || $e1->is_logical) {
    $e1 = $e1->as_double;
    return $e1 if $e1->is_nan;
    
    if ($e1->is_infinite) {
        $e2 = NaN;
        carp "In acosh() : NaNs produced";
    }
    else {
      if (equal($e1, double(1))) {
        $e2 = Inf;
      }
      elsif (equal($e1, double(-1))) {
        $e2 = negativeInf;
      }
      elsif (less_than(Rstats::ElementFunc::abs($e1), double(1))) {
        $e2 = divide(
          Rstats::ElementFunc::log(
            divide(
              add(double(1), $e1),
              subtract(double(1), $e1)
            )
          ),
          double(2)
        );
      }
      else {
        $e2 = NaN;
        carp "In acosh() : NaNs produced";
      }
    }
  }
  else {
    croak "Not implemented";
  }
  
  return $e2;
}

sub acosh {
  my $e1 = shift;
  
  return $e1 if $e1->is_na;
  
  my $e2;
  if ($e1->is_complex) {
    my $e1_re = $e1->re;
    my $e1_im = $e1->im;

    my $e2_t = add(
      Rstats::ElementFunc::sqrt(
        subtract(
          multiply($e1, $e1),
          complex(1, 0)
        ),
      ),
      $e1
    );
    my $e2_u = Rstats::ElementFunc::log($e2_t);
    my $e2_re = Re($e2_u);
    my $e2_im = Im($e2_u);
    
    if (less_than($e1_re, double(0)) && equal($e1_im, double(0))) {
      $e2 = complex_double($e2_re, negation($e2_im));
    }
    else {
      $e2 = complex_double($e2_re, $e2_im);
    }
    
    if (less_than($e1_re, double(0))) {
      $e2 = negation($e2);
    }
  }
  elsif ($e1->is_numeric || $e1->is_logical) {
    $e1 = $e1->as_double;
    return $e1 if $e1->is_nan;
    
    if ($e1->is_infinite) {
        $e2 = NaN;
        carp "In acosh() : NaNs produced";
    }
    else {
      if (more_than_or_equal($e1, double(1))) {
        $e2 = Rstats::ElementFunc::log(
          add(
            $e1,
            Rstats::ElementFunc::sqrt(
              subtract(
                multiply($e1, $e1),
                double(1)
              )
            )
          )
        );
      }
      else {
        $e2 = NaN;
        carp "In acosh() : NaNs produced";
      }
    }
  }
  else {
    croak "Not implemented";
  }
  
  return $e2;
}

sub asinh {
  my $e1 = shift;
  
  return $e1 if $e1->is_na;
  
  my $e2;
  if ($e1->is_complex) {
  
    my $e2_t = add(
      Rstats::ElementFunc::sqrt(
        add(
          multiply($e1, $e1),
          complex(1, 0)
        )
      ),
      $e1
    );
    
    $e2 = Rstats::ElementFunc::log($e2_t);
  }
  elsif ($e1->is_numeric || $e1->is_logical) {
    $e1 = $e1->as_double;
    return $e1 if $e1->is_nan;
    
    if ($e1->is_positive_infinite) {
      $e2 = Inf;
    }
    elsif ($e1->is_negative_infinite) {
      $e2 = negativeInf;
    }
    else {
      my $e2_t = add(
        $e1,
        Rstats::ElementFunc::sqrt(
          add(
            multiply($e1, $e1),
            double(1)
          )
        )
      );
      
      $e2 = Rstats::ElementFunc::log($e2_t);
    }
  }
  else {
    croak "Not implemented";
  }
  
  return $e2;
}

sub tanh {
  my $e1 = shift;
  
  return $e1 if $e1->is_na;
  
  my $e2;
  if ($e1->is_complex) {
    if ($e1->im->is_infinite) {
      $e2 = complex_double(NaN, NaN);
    }
    elsif ($e1->re->is_positive_infinite) {
      $e2 = complex(1, 0);
    }
    elsif ($e1->re->is_negative_infinite) {
      $e2 = complex(-1, 0);
    }
    else {
      $e2 = divide(sinh($e1), cosh($e1));
    }
  }
  elsif ($e1->is_numeric || $e1->is_logical) {
    $e1 = $e1->as_double;
    
    return $e1 if $e1->is_nan;
    
    if ($e1->is_positive_infinite) {
      $e2 = double(1);
    }
    elsif ($e1->is_negative_infinite) {
      $e2 = double(-1);
    }
    else {
      $e2 = divide(sinh($e1), cosh($e1));
    }
  }
  else {
    croak "Not implemented";
  }
  
  return $e2;
}

sub cosh {
  my $e1 = shift;
  
  return $e1 if $e1->is_na;
  
  my $e2;
  if ($e1->is_complex) {
    my $e1_x = $e1->re;
    my $e1_y = $e1->im;
    
    my $e2_cy = Rstats::ElementFunc::cos($e1_y);
    my $e2_sy = Rstats::ElementFunc::sin($e1_y);
    my $e2_ex = Rstats::ElementFunc::exp($e1_x);
    
    my $e2_ex_1 = not_equal($e2_ex, double(0)) ? divide(double(1), $e2_ex) : Inf;

    my $e2_x = divide(
      multiply(
        $e2_cy,
        add($e2_ex, $e2_ex_1)
      ),
      double(2)
    );
    my $e2_y = divide(
      multiply(
        $e2_sy,
        subtract($e2_ex, $e2_ex_1)
      ),
      double(2)
    );
    
    $e2 = complex_double($e2_x, $e2_y);
  }
  elsif ($e1->is_numeric || $e1->is_logical) {
    $e1 = $e1->as_double;
    return $e1 if $e1->is_nan;
    
    my $e2_ex = Rstats::ElementFunc::exp($e1);
    
    if (not_equal($e2_ex, double(0))) {
      if ($e2_ex->is_positive_infinite) {
        $e2 = Inf;
      }
      else {
        $e2 = divide(
          add(
            $e2_ex,
            divide(double(1), $e2_ex)
          ),
          double(2)
        )
      }
    }
    else {
      $e2 = Inf;
    }
  }
  else {
    croak "Not implemented";
  }
  
  return $e2;
}

sub sinh {
  my $e1 = shift;
  
  return $e1 if $e1->is_na;
  
  my $e2;
  if ($e1->is_complex) {
    my $e1_x = $e1->re;
    my $e1_y = $e1->im;
    
    my $e2_cy = Rstats::ElementFunc::cos($e1_y);
    my $e2_sy = Rstats::ElementFunc::sin($e1_y);
    my $e2_ex = Rstats::ElementFunc::exp($e1_x);
    
    my $e2_ex_1 = not_equal($e2_ex, double(0)) ? divide(double(1), $e2_ex) : Inf;

    my $e2_x = divide(
      multiply(
        $e2_cy,
        subtract($e2_ex, $e2_ex_1)
      ),
      double(2)
    );
    my $e2_y = divide(
      multiply(
        $e2_sy,
        add($e2_ex, $e2_ex_1)
      ),
      double(2)
    );
    
    $e2 = complex_double($e2_x, $e2_y);
  }
  elsif ($e1->is_numeric || $e1->is_logical) {
    $e1 = $e1->as_double;
    return $e1 if $e1->is_nan;
    
    return double(0) if equal($e1, double(0));
    my $e2_ex = Rstats::ElementFunc::exp($e1);
    
    if (not_equal($e2_ex, double(0))) {
      if ($e2_ex->is_positive_infinite) {
        $e2 = Inf;
      }
      else {
        $e2 = divide(
          subtract(
            $e2_ex,
            divide(double(1), $e2_ex)
          ),
          double(2)
        )
      }
    }
    else {
      $e2 = negativeInf;
    }
  }
  else {
    croak "Not implemented";
  }
  
  return $e2;
}

sub atan {
  my $e1 = shift;
  
  return $e1 if $e1->is_na;
  
  my $e2;
  if ($e1->is_complex) {
    
    if (equal($e1, complex(0, 0))) {
      $e2 = complex(0, 0);
    }
    elsif (equal($e1, complex(0, 1))) {
      $e2 = complex_double(double(0), Inf);
    }
    elsif (equal($e1, complex(0, -1))) {
      $e2 = complex_double(double(0), negativeInf);
    }
    else {
      my $e2_i = complex(0, 1);
      my $e2_log = Rstats::ElementFunc::log(
        divide(
          add($e2_i, $e1),
          subtract($e2_i, $e1)
        )
      );
      
      $e2 = multiply(
        divide($e2_i, complex(2, 0)),
        $e2_log
      );
    }
  }
  elsif ($e1->is_numeric || $e1->is_logical) {
    $e2 = Rstats::ElementFunc::atan2($e1->as_double, double(1));
  }
  else {
    croak "Not implemented";
  }
  
  return $e2;
}


sub atan2 {
  my ($e1, $e2) = @_;
  
  croak "argument x is missing" unless defined $e2;
  return Rstats::ElementFunc::NA if $e1->is_na || $e2->is_na;
  croak "two element should be same type" unless $e1->type eq $e2->type;
  
  my $e3;
  if ($e1->is_complex) {
    
    my $e3_s = add(multiply($e1, $e1), multiply($e2, $e2));
    if (equal($e3_s, complex(0, 0))) {
      $e3 = complex(0, 0);
    }
    else {
      my $e3_i = complex(0, 1);
      my $e3_r = add($e2, multiply($e1, $e3_i));
      $e3 = multiply(
        negation($e3_i),
        Rstats::ElementFunc::log(
          divide(
            $e3_r,
            Rstats::ElementFunc::sqrt($e3_s)
          )
        )
      );
    }
  }
  elsif ($e1->is_numeric || $e1->is_logical) {
    $e1 = $e1->as_double unless $e1->is_double;
    $e2 = $e2->as_double unless $e2->is_double;

    my $value1;
    my $value2;
    
    if ($e1->is_nan || $e2->is_nan) {
      $e3 = Rstats::ElementFunc::NaN;
    }
    elsif ($e1->is_positive_infinite && $e2->is_positive_infinite) {
      $e3 = double(0.785398163397448);
    }
    elsif ($e1->is_positive_infinite && $e2->is_negative_infinite) {
      $e3 = double(2.35619449019234);
    }
    elsif ($e1->is_negative_infinite && $e2->is_positive_infinite) {
      $e3 = double(-0.785398163397448);
    }
    elsif ($e1->is_negative_infinite && $e2->is_negative_infinite) {
      $e3 = double(-2.35619449019234);
    }
    elsif ($e1->is_positive_infinite) {
      $e3 = double(1.5707963267949);
    }
    elsif ($e2->is_positive_infinite) {
      $e3 = double(0)
    }
    elsif ($e1->is_negative_infinite) {
      $e3 = double(-1.5707963267949);
    }
    elsif ($e2->is_negative_infinite) {
      my $value1 = $e1->dv;
      if ($value1 >= 0) {
        $e3 = double(3.14159265358979);
      }
      else {
        $e3 = double(-3.14159265358979);
      }
    }
    else {
      my $value1 = $e1->dv;
      my $value2 = $e2->dv;
      $e3 = double(CORE::atan2($value1, $value2));
    }
  }
  else {
    croak "Not implemented";
  }
  
  return $e3;
}

sub log2 {
  my $e1 = shift;
  
  my $e2 = divide(
    Rstats::ElementFunc::log($e1),
    $e1->is_complex ? Rstats::ElementFunc::log(complex(2, 0)) : Rstats::ElementFunc::log(double(2))
  );
  
  return $e2;
}

sub log10 {
  my $e1 = shift;
  
  my $e2 = divide(
    Rstats::ElementFunc::log($e1),
    $e1->is_complex ? Rstats::ElementFunc::log(complex(10, 0)) : Rstats::ElementFunc::log(double(10))
  );
  
  return $e2;
}

sub log {
  my $e1 = shift;
  
  return $e1 if $e1->is_na;
  
  my $e2;
  if ($e1->is_complex) {
    
    my $e1_r = Mod($e1);
    my $e1_t = Arg($e1);
    
    if (equal($e1_r, double(0))) {
      $e2 = negativeInf;
    }
    else {
      if (more_than($e1_t, pi)) {
        $e1_t = subtract(
          $e1_t,
          multiply(
            pi,
            pi
          )
        )
      }
      elsif (less_than_or_equal($e1_t, negation(pi))) {
        $e1_t = add(
          $e1_t,
          multiply(
            pi,
            pi
          )
        )
      }
      
      $e2 = complex_double(Rstats::ElementFunc::log($e1_r), $e1_t);
    }
  }
  elsif ($e1->is_numeric || $e1->is_logical) {
    $e1 = $e1->as_double unless $e1->is_double;
    my $value = $e1->dv;
    
    if ($e1->is_infinite) {
      carp "In cos : NaNs produced";
      $e2 = NaN;
    }
    elsif ($e1->is_nan) {
      $e2 = $e1;
    }
    else {
      if ($value < 0) {
        carp "In log : NaNs produced";
        $e2 = NaN
      }
      elsif ($value == 0) {
        $e2 = negativeInf;
      }
      else {
        $e2 = double(log($value));
      }
    }
  }
  else {
    croak "Not implemented";
  }
  
  return $e2;
}

sub Mod { Rstats::ElementFunc::abs(@_) }

sub Arg {
  my $e1 = shift;
  
  if ($e1->is_complex) {
    my $e1_re = $e1->re;
    my $e1_im = $e1->im;
    my $re = $e1_re->value;
    my $im = $e1_im->value;
    
    my $e2;
    if ($re == 0 && $im == 0) {
      $e2 = double(0);
    }
    else {
      $e2 = double(CORE::atan2($im, $re));
    }
    
    return $e2;
  }
  else {
    croak "Not implemented";
  }
}

sub hash {
  my $e1 = shift;
  
  my $hash = $e1->type . '-' . "$e1";
  
  return $hash;
}

sub tan {
  my $e1 = shift;
  
  my $e2 = divide(Rstats::ElementFunc::sin($e1), Rstats::ElementFunc::cos($e1));
  
  return $e2;
}

sub cos {
  my $e1 = shift;
  
  return $e1 if $e1->is_na;
  
  my $e2;
  if ($e1->is_complex) {
    
    my $e1_re = $e1->re;
    my $e1_im = $e1->im;
    
    my $e2_eim = Rstats::ElementFunc::exp($e1_im);
    my $e2_sre = Rstats::ElementFunc::sin($e1_re);
    my $e2_cre = Rstats::ElementFunc::cos($e1_re);
    
    my $e2_eim_1 = divide(double(1), $e2_eim);
    
    my $e2_re = divide(
      multiply(
        $e2_cre,
        add(
          $e2_eim,
          $e2_eim_1
        )
      ),
      double(2)
    );
    
    my $e2_im = divide(
      multiply(
        $e2_sre,
        subtract(
          $e2_eim_1,
          $e2_eim
        )
      ),
      double(2)
    );
    
    $e2 = complex_double($e2_re, $e2_im);
  }
  elsif ($e1->is_numeric || $e1->is_logical) {
    $e1 = $e1->as_double unless $e1->is_double;
    my $value = $e1->dv;
    
    if ($e1->is_infinite) {
      carp "In cos : NaNs produced";
      $e2 = NaN;
    }
    elsif ($e1->is_nan) {
      $e2 = $e1;
    }
    else {
      $e2 = double(cos($value));
    }
  }
  else {
    croak "Not implemented";
  }
  
  return $e2;
}

sub exp {
  my $e1 = shift;
  
  return $e1 if $e1->is_na;
  
  my $e2;
  if ($e1->is_complex) {
    
    my $e1_re = $e1->re;
    my $e1_im = $e1->im;
    
    my $e2_mod = Rstats::ElementFunc::exp($e1_re);
    my $e2_arg = $e1_im;

    my $e2_re = Rstats::ElementFunc::multiply(
      $e2_mod,
      Rstats::ElementFunc::cos($e2_arg)
    );
    my $e2_im = Rstats::ElementFunc::multiply(
      $e2_mod,
      Rstats::ElementFunc::sin($e2_arg)
    );
    
    $e2 = complex_double($e2_re, $e2_im);
  }
  elsif ($e1->is_double || $e1->is_integer || $e1->is_logical) {
    $e1 = $e1->as_double unless $e1->is_double;
    
    if ($e1->is_positive_infinite) {
      $e2 = Inf;
    }
    elsif ($e1->is_negative_infinite) {
      $e2 = double(0);
    }
    elsif ($e1->is_nan) {
      $e2 = $e1;
    }
    else {
      my $value = $e1->dv;
      $e2 = double(exp($value));
    }
  }
  else {
    croak "Not implemented";
  }
  
  return $e2;
}

sub expm1 {
  my $e1 = shift;
  
  return $e1 if $e1->is_na;
  
  my $e2;
  if ($e1->is_complex) {
    croak 'Error in expm1 : unimplemented complex function';
  }
  elsif ($e1->is_double) {
    return $e1 if $e1->is_nan;
    if (less_than($e1, double(1e-5)) && more_than($e1, negativeInf)) {
      $e2 = add(
        $e1,
        multiply(
          double(0.5),
          multiply(
            $e1,
            $e1
          )
        )
      );
    }
    else {
      $e2 = Rstats::ElementFunc::subtract(Rstats::ElementFunc::exp($e1), double(1));
    }
  }
  elsif ($e1->is_integer || $e1->is_logical) {
    $e2 = Rstats::ElementFunc::subtract(Rstats::ElementFunc::exp($e1), double(1));
  }
  else {
    croak 'Not implemented';
  }
}

sub acos {
  my $e1 = shift;

  return $e1 if $e1->is_na;
  
  my $e2;
  if ($e1->is_complex) {

    my $e1_re = $e1->re;
    my $e1_im = $e1->im;
    
    if (equal($e1_re, double(1)) && equal($e1_im, double(0))) {
      $e2 = complex(0, 0);
    }
    else {
      my $e2_t1 = Rstats::ElementFunc::sqrt(
        add(
          multiply(
            add($e1_re, double(1)),
            add($e1_re, double(1))
          ),
          multiply($e1_im, $e1_im)
        )
      );
      my $e2_t2 = Rstats::ElementFunc::sqrt(
        add(
          multiply(
            subtract($e1_re, double(1)),
            subtract($e1_re, double(1))
          ),
          multiply($e1_im, $e1_im)
        )
      );
      
      my $e2_alpha = divide(
        add($e2_t1,  $e2_t2),
        double(2)
      );
      
      my $e2_beta  = divide(
        subtract($e2_t1, $e2_t2),
        double(2)
      );
      
      if (less_than($e2_alpha, double(1))) {
        $e2_alpha = double(1);
      }
      
      if (more_than($e2_beta,double(1))) {
        $e2_beta =  double(1);
      }
      elsif (less_than($e2_beta, double(-1))) {
        $e2_beta = double(-1);
      }
      
      my $e2_u =  Rstats::ElementFunc::atan2(
        Rstats::ElementFunc::sqrt(
          subtract(
            double(1),
            multiply($e2_beta, $e2_beta)
          )
        ),
        $e2_beta
      );
      
      my $e2_v = Rstats::ElementFunc::log(
        add(
          $e2_alpha,
          Rstats::ElementFunc::sqrt(
            subtract(
              multiply($e2_alpha, $e2_alpha),
              double(1)
            )
          )
        )
      );
      
      if (more_than($e1_im, double(0)) || (equal($e1_im, double(0)) && less_than($e1_re, double(-1)))) {
        $e2_v = negation($e2_v);
      }
      
      $e2 = complex_double($e2_u, $e2_v);
    }
  }
  elsif ($e1->is_numeric || $e1->is_logical) {
    if ($e1->is_infinite) {
      carp "In sin : NaNs produced";
      $e2 = NaN;
    }
    elsif ($e1->is_nan) {
      $e2 = $e1;
    }
    else {
      $e1 = $e1->as_double;
      if (less_than_or_equal(Rstats::ElementFunc::abs($e1), double(1))) {
        $e2 = Rstats::ElementFunc::atan2(
          Rstats::ElementFunc::sqrt(
            subtract(
              double(1),
              multiply($e1, $e1)
            )
          ),
          $e1
        );
      }
      else {
        carp 'In asin : NaNs produced';
        $e2 = NaN;
      }
    }
  }
  else {
    croak "Not implemented";
  }
  
  return $e2;
}

sub asin {
  my $e1 = shift;

  return $e1 if $e1->is_na;
  
  my $e2;
  if ($e1->is_complex) {

    my $e1_re = $e1->re;
    my $e1_im = $e1->im;
    
    if (equal($e1_re, double(0)) && equal($e1_im, double(0))) {
      $e2 = complex(0, 0);
    }
    else {
      my $e2_t1 = Rstats::ElementFunc::sqrt(
        add(
          multiply(
            add($e1_re, double(1)),
            add($e1_re, double(1))
          ),
          multiply($e1_im, $e1_im)
        )
      );
      my $e2_t2 = Rstats::ElementFunc::sqrt(
        add(
          multiply(
            subtract($e1_re, double(1)),
            subtract($e1_re, double(1))
          ),
          multiply($e1_im, $e1_im)
        )
      );
      
      my $e2_alpha = divide(
        add($e2_t1,  $e2_t2),
        double(2)
      );
      
      my $e2_beta  = divide(
        subtract($e2_t1, $e2_t2),
        double(2)
      );
      
      if (less_than($e2_alpha, double(1))) {
        $e2_alpha = double(1);
      }
      
      if (more_than($e2_beta,double(1))) {
        $e2_beta =  double(1);
      }
      elsif (less_than($e2_beta, double(-1))) {
        $e2_beta = double(-1);
      }
      
      my $e2_u =  Rstats::ElementFunc::atan2(
        $e2_beta,
        Rstats::ElementFunc::sqrt(
          subtract(
            double(1),
            multiply($e2_beta, $e2_beta)
          )
        )
      );
      
      my $e2_v = negation(
        Rstats::ElementFunc::log(
          add(
            $e2_alpha,
            Rstats::ElementFunc::sqrt(
              subtract(
                multiply($e2_alpha, $e2_alpha),
                double(1)
              )
            )
          )
        )
      );
      
      if (more_than($e1_im, double(0)) || (equal($e1_im, double(0)) && less_than($e1_re, double(-1)))) {
        $e2_v = negation($e2_v);
      }
      
      $e2 = complex_double($e2_u, $e2_v);
    }
  }
  elsif ($e1->is_numeric || $e1->is_logical) {
    if ($e1->is_infinite) {
      carp "In sin : NaNs produced";
      $e2 = NaN;
    }
    elsif ($e1->is_nan) {
      $e2 = $e1;
    }
    else {
      $e1 = $e1->as_double;
      if (less_than_or_equal(Rstats::ElementFunc::abs($e1), double(1))) {
        $e2 = Rstats::ElementFunc::atan2(
          $e1,
          Rstats::ElementFunc::sqrt(
            subtract(
              double(1),
              multiply($e1, $e1)
            )
          )
        );
      }
      else {
        carp 'In asin : NaNs produced';
        $e2 = NaN;
      }
    }
  }
  else {
    croak "Not implemented";
  }
  
  return $e2;
}

sub sin {
  my $e1 = shift;
  
  return $e1 if $e1->is_na;
  
  my $e2;
  if ($e1->is_complex) {
    
    my $e1_re = $e1->re;
    my $e1_im = $e1->im;
    
    my $e2_eim = Rstats::ElementFunc::exp($e1_im);
    my $e2_sre = Rstats::ElementFunc::sin($e1_re);
    my $e2_cre = Rstats::ElementFunc::cos($e1_re);
    
    my $e2_eim_1 = divide(double(1), $e2_eim);
    
    my $e2_re = divide(
      multiply(
        $e2_sre,
        add(
          $e2_eim,
          $e2_eim_1
        )
      ),
      double(2)
    );
    
    my $e2_im = divide(
      multiply(
        $e2_cre,
        subtract(
          $e2_eim,
          $e2_eim_1
        )
      ),
      double(2)
    );
    
    $e2 = complex_double($e2_re, $e2_im);
  }
  elsif ($e1->is_numeric || $e1->is_logical) {
    $e1 = $e1->as_double unless $e1->is_double;
    my $value = $e1->dv;
    
    if ($e1->is_infinite) {
      carp "In sin : NaNs produced";
      $e2 = NaN;
    }
    elsif ($e1->is_nan) {
      $e2 = $e1;
    }
    else {
      $e2 = double(sin($value));
    }
  }
  else {
    croak "Not implemented";
  }
  
  return $e2;
}

sub create {
  my ($type, $value) = @_;
  
  $value = 0 unless defined $value;

  if ($type eq 'character') {
    return character("$value");
  }
  elsif ($type eq 'complex') {
    return complex($value, 0);
  }
  elsif ($type eq 'double') {
    return double($value);
  }
  elsif ($type eq 'integer') {
    return integer($value);
  }
  elsif ($type eq 'logical') {
    return logical($value ? Rstats::ElementFunc::TRUE : Rstats::ElementFunc::FALSE);
  }
  else {
    croak 'Invalid type';
  }
}

sub element {
  my $value = shift;
  
  return ref $value ? $value
    : Rstats::Util::is_perl_number($value) ? double($value)
    : character($value);

}

sub negation {
  my $e1 = shift;
  
  if ($e1->is_na) {
    return NA;
  }
  elsif ($e1->is_character) {
    croak 'argument is not interpretable as logical'
  }
  elsif ($e1->is_complex) {
    return complex_double(negation($e1->re), negation($e1->im));
  }
  elsif ($e1->is_double) {
    
    my $flag = $e1->flag;
    if (defined $e1->dv) {
      return double(-$e1->dv);
    }
    elsif ($flag eq 'nan') {
      return NaN;
    }
    elsif ($flag eq 'inf') {
      return negativeInf;
    }
    elsif ($flag eq '-inf') {
      return Inf;
    }
  }
  elsif ($e1->is_integer || $e1->is_logical) {
    return integer(-$e1->iv);
  }
  else {
    croak "Invalid type";
  }  
}

sub and {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  $e1 = $e1->as_logical unless $e1->is_logical;
  $e2 = $e2->as_logical unless $e2->is_logical;
  
  if ($e1->iv && $e2->iv) {
    return TRUE;
  }
  else {
    return FALSE;
  }
}

sub or {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  $e1 = $e1->as_logical unless $e1->is_logical;
  $e2 = $e2->as_logical unless $e2->is_logical;
  
  if ($e1->iv || $e2->iv) {
    return TRUE;
  }
  else {
    return FALSE;
  }
}

sub add {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  if ($e1->is_character) {
    croak "Error in a + b : non-numeric argument to binary operator";
  }
  elsif ($e1->is_complex) {
    my $re = add($e1->re, $e2->re);
    my $im = add($e1->im, $e2->im);
    
    return complex_double($re, $im);
  }
  elsif ($e1->is_double) {
    return NaN if $e1->is_nan || $e2->is_nan;
    if (defined $e1->dv) {
      if (defined $e2->dv) {
        my $value = $e1->dv + $e2->dv;
        if ($value == $perl_inf_result) {
          return Inf;
        }
        elsif ($value == $perl_negative_inf_result) {
          return negativeInf;
        }
        else {
          return double($value)
        }
      }
      elsif ($e2->is_positive_infinite) {
        return Inf;
      }
      elsif ($e2->is_negative_infinite) {
        return negativeInf;
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->dv) {
        return Inf;
      }
      elsif ($e2->is_positive_infinite) {
        return Inf;
      }
      elsif ($e2->is_negative_infinite) {
        return NaN;
      }
    }
    elsif ($e1->is_negative_infinite) {
      if (defined $e2->dv) {
        return negativeInf;
      }
      elsif ($e2->is_positive_infinite) {
        return NaN;
      }
      elsif ($e2->is_negative_infinite) {
        return negativeInf;
      }
    }
  }
  elsif ($e1->is_integer) {
    return integer($e1->iv + $e2->iv);
  }
  elsif ($e1->is_logical) {
    return integer($e1->iv + $e2->iv);
  }
  else {
    croak "Invalid type";
  }
}

sub subtract {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  if ($e1->is_character) {
    croak "Error in a + b : non-numeric argument to binary operator";
  }
  elsif ($e1->is_complex) {
    my $re = subtract($e1->re, $e2->re);
    my $im = subtract($e1->im, $e2->im);
    
    return complex_double($re, $im);
  }
  elsif ($e1->is_double) {
    return NaN if $e1->is_nan || $e2->is_nan;
    if (defined $e1->dv) {
      if (defined $e2->dv) {
        my $value = $e1->dv - $e2->dv;
        if ($value == $perl_inf_result) {
          return Inf;
        }
        elsif ($value == $perl_negative_inf_result) {
          return negativeInf;
        }
        else {
          return double($value)
        }
      }
      elsif ($e2->is_positive_infinite) {
        return negativeInf;
      }
      elsif ($e2->is_negative_infinite) {
        return Inf;
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->dv) {
        return Inf;
      }
      elsif ($e2->is_positive_infinite) {
        return NaN;
      }
      elsif ($e2->is_negative_infinite) {
        return Inf;
      }
    }
    elsif ($e1->is_negative_infinite) {
      if (defined $e2->dv) {
        return negativeInf;
      }
      elsif ($e2->is_positive_infinite) {
        return negativeInf;
      }
      elsif ($e2->is_negative_infinite) {
        return NaN;
      }
    }
  }
  elsif ($e1->is_integer) {
    return integer($e1->iv + $e2->iv);
  }
  elsif ($e1->is_logical) {
    return integer($e1->iv + $e2->iv);
  }
  else {
    croak "Invalid type";
  }
}

sub multiply {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  if ($e1->is_character) {
    croak "Error in a + b : non-numeric argument to binary operator";
  }
  elsif ($e1->is_complex) {
    my $re = subtract(multiply($e1->re, $e2->re), multiply($e1->im, $e2->im));
    my $im = add(multiply($e1->re, $e2->im), multiply($e1->im, $e2->re));
    
    return complex_double($re, $im);
  }
  elsif ($e1->is_double) {
    return NaN if $e1->is_nan || $e2->is_nan;
    if (defined $e1->dv) {
      if (defined $e2->dv) {
        my $value = $e1->dv * $e2->dv;
        if ($value == $perl_inf_result) {
          return Inf;
        }
        elsif ($value == $perl_negative_inf_result) {
          return negativeInf;
        }
        else {
          return double($value)
        }
      }
      elsif ($e2->is_positive_infinite) {
        if ($e1->dv == 0) {
          return NaN;
        }
        elsif ($e1->dv > 0) {
          return Inf;
        }
        elsif ($e1->dv < 0) {
          return negativeInf;
        }
      }
      elsif ($e2->is_negative_infinite) {
        if ($e1->dv == 0) {
          return NaN;
        }
        elsif ($e1->dv > 0) {
          return negativeInf;
        }
        elsif ($e1->dv < 0) {
          return Inf;
        }
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->dv) {
        if ($e2->dv == 0) {
          return NaN;
        }
        elsif ($e2->dv > 0) {
          return Inf;
        }
        elsif ($e2->dv < 0) {
          return negativeInf;
        }
      }
      elsif ($e2->is_positive_infinite) {
        return Inf;
      }
      elsif ($e2->is_negative_infinite) {
        return negativeInf;
      }
    }
    elsif ($e1->is_negative_infinite) {
      if (defined $e2->dv) {
        if ($e2->dv == 0) {
          return NaN;
        }
        elsif ($e2->dv > 0) {
          return negativeInf;
        }
        elsif ($e2->dv < 0) {
          return Inf;
        }
      }
      elsif ($e2->is_positive_infinite) {
        return negativeInf;
      }
      elsif ($e2->is_negative_infinite) {
        return Inf;
      }
    }
  }
  elsif ($e1->is_integer) {
    return integer($e1->iv * $e2->iv);
  }
  elsif ($e1->is_logical) {
    return integer($e1->iv * $e2->iv);
  }
  else {
    croak "Invalid type";
  }
}

sub divide {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  if ($e1->is_character) {
    croak "Error in a + b : non-numeric argument to binary operator";
  }
  elsif ($e1->is_complex) {
    my $v3 = multiply($e1, Conj($e2));
    my $abs2 = double($e2->re->value ** 2 + $e2->im->value ** 2);
    my $re = divide($v3->re, $abs2);
    my $im = divide($v3->im, $abs2);
    
    return complex_double($re, $im);
  }
  elsif ($e1->is_double) {
    return NaN if $e1->is_nan || $e2->is_nan;
    if (defined $e1->dv) {
      if ($e1->dv == 0) {
        if (defined $e2->dv) {
          if ($e2->dv == 0) {
            return NaN;
          }
          else {
            return double(0)
          }
        }
        elsif ($e2->is_infinite) {
          return double(0);
        }
      }
      elsif ($e1->dv > 0) {
        if (defined $e2->dv) {
          if ($e2->dv == 0) {
            return Inf;
          }
          else {
            my $value = $e1->dv / $e2->dv;
            if ($value == $perl_inf_result) {
              return Inf;
            }
            elsif ($value == $perl_negative_inf_result) {
              return negativeInf;
            }
            else {
              return double($value)
            }
          }
        }
        elsif ($e2->is_infinite) {
          return double(0);
        }
      }
      elsif ($e1->dv < 0) {
        if (defined $e2->dv) {
          if ($e2->dv == 0) {
            return negativeInf;
          }
          else {
            return double($e1->dv / $e2->dv);
          }
        }
        elsif ($e2->is_infinite) {
          return double(0);
        }
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->dv) {
        if ($e2->dv >= 0) {
          return Inf;
        }
        elsif ($e2->dv < 0) {
          return negativeInf;
        }
      }
      elsif ($e2->is_infinite) {
        return NaN;
      }
    }
    elsif ($e1->is_negative_infinite) {
      if (defined $e2->dv) {
        if ($e2->dv >= 0) {
          return negativeInf;
        }
        elsif ($e2->dv < 0) {
          return Inf;
        }
      }
      elsif ($e2->is_infinite) {
        return NaN;
      }
    }
  }
  elsif ($e1->is_integer) {
    if ($e1->iv == 0) {
      if ($e2->iv == 0) {
        return NaN;
      }
      else {
        return double(0);
      }
    }
    elsif ($e1->iv > 0) {
      if ($e2->iv == 0) {
        return Inf;
      }
      else  {
        return double($e1->iv / $e2->iv);
      }
    }
    elsif ($e1->iv < 0) {
      if ($e2->iv == 0) {
        return negativeInf;
      }
      else {
        return double($e1->iv / $e2->iv);
      }
    }
  }
  elsif ($e1->is_logical) {
    if ($e1->iv == 0) {
      if ($e2->iv == 0) {
        return NaN;
      }
      elsif ($e2->iv == 1) {
        return double(0);
      }
    }
    elsif ($e1->iv == 1) {
      if ($e2->iv == 0) {
        return Inf;
      }
      elsif ($e2->iv == 1)  {
        return double(1);
      }
    }
  }
  else {
    croak "Invalid type";
  }
}

sub raise {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  if ($e1->is_character) {
    croak "Error in a + b : non-numeric argument to binary operator";
  }
  elsif ($e1->is_complex) {
    my $e1_c = Math::Complex->make($e1->re->value, $e1->im->value);
    my $e2_c = Math::Complex->make($e2->re->value, $e2->im->value);
    
    my $v3_c;
    if ($e2->re->value == 1/2 && $e2->im->value == 0) {
      $v3_c = Math::Complex::sqrt($e1_c);
    }
    else {
      $v3_c = $e1_c ** $e2_c;
    }
    my $re = Math::Complex::Re($v3_c);
    my $im = Math::Complex::Im($v3_c);
    
    return complex($re, $im);
  }
  elsif ($e1->is_double) {
    return NaN if $e1->is_nan || $e2->is_nan;
    if (defined $e1->dv) {
      if ($e1->dv == 0) {
        if (defined $e2->dv) {
          if ($e2->dv == 0) {
            return double(1);
          }
          elsif ($e2->dv > 0) {
            return double(0);
          }
          elsif ($e2->dv < 0) {
            return Inf;
          }
        }
        elsif ($e2->is_positive_infinite) {
          return double(0);
        }
        elsif ($e2->is_negative_infinite) {
          return Inf
        }
      }
      elsif ($e1->dv > 0) {
        if (defined $e2->dv) {
          if ($e2->dv == 0) {
            return double(1);
          }
          else {
            my $value = $e1->dv ** $e2->dv;
            if ($value == $perl_inf_result) {
              return Inf;
            }
            elsif ($value == $perl_negative_inf_result) {
              return negativeInf;
            }
            else {
              return double($value)
            }
          }
        }
        elsif ($e2->is_positive_infinite) {
          if ($e1->dv < 1) {
            return double(0);
          }
          elsif ($e1->dv == 1) {
            return double(1);
          }
          elsif ($e1->dv > 1) {
            return Inf;
          }
        }
        elsif ($e2->is_negative_infinite) {
          if ($e1->dv < 1) {
            return double(0);
          }
          elsif ($e1->dv == 1) {
            return double(1);
          }
          elsif ($e1->dv > 1) {
            return double(0);
          }
        }
      }
      elsif ($e1->dv < 0) {
        if (defined $e2->dv) {
          if ($e2->dv == 0) {
            return double(-1);
          }
          else {
            return double($e1->dv ** $e2->dv);
          }
        }
        elsif ($e2->is_positive_infinite) {
          if ($e1->dv > -1) {
            return double(0);
          }
          elsif ($e1->dv == -1) {
            return double(-1);
          }
          elsif ($e1->dv < -1) {
            return negativeInf;
          }
        }
        elsif ($e2->is_negative_infinite) {
          if ($e1->dv > -1) {
            return Inf;
          }
          elsif ($e1->dv == -1) {
            return double(-1);
          }
          elsif ($e1->dv < -1) {
            return double(0);
          }
        }
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->dv) {
        if ($e2->dv == 0) {
          return double(1);
        }
        elsif ($e2->dv > 0) {
          return Inf;
        }
        elsif ($e2->dv < 0) {
          return double(0);
        }
      }
      elsif ($e2->is_positive_infinite) {
        return Inf;
      }
      elsif ($e2->is_negative_infinite) {
        return double(0);
      }
    }
    elsif ($e1->is_negative_infinite) {
      if (defined $e2->dv) {
        if ($e2->dv == 0) {
          return double(-1);
        }
        elsif ($e2->dv > 0) {
          return negativeInf;
        }
        elsif ($e2->dv < 0) {
          return double(0);
        }
      }
      elsif ($e2->is_positive_infinite) {
        return negativeInf;
      }
      elsif ($e2->is_negative_infinite) {
        return double(0);
      }
    }
  }
  elsif ($e1->is_integer) {
    if ($e1->iv == 0) {
      if ($e2->iv == 0) {
        return double(1);
      }
      elsif ($e2->iv > 0) {
        return double(0);
      }
      elsif ($e2->iv < 0) {
        return Inf;
      }
    }
    elsif ($e1->iv > 0) {
      if ($e2->iv == 0) {
        return double(1);
      }
      else {
        return double($e1->iv ** $e2->iv);
      }
    }
    elsif ($e1->iv < 0) {
      if ($e2->iv == 0) {
        return double(-1);
      }
      else {
        return double($e1->iv ** $e2->iv);
      }
    }
  }
  elsif ($e1->is_logical) {
    if ($e1->iv == 0) {
      if ($e2->iv == 0) {
        return double(1);
      }
      elsif ($e2->iv == 1) {
        return double(0);
      }
    }
    elsif ($e1->iv ==  1) {
      if ($e2->iv == 0) {
        return double(1);
      }
      elsif ($e2->iv == 1) {
        return double(1);
      }
    }
  }
  else {
    croak "Invalid type";
  }
}

sub remainder {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  if ($e1->is_character) {
    croak "Error in a + b : non-numeric argument to binary operator";
  }
  elsif ($e1->is_complex) {
    croak "unimplemented complex operation";
  }
  elsif ($e1->is_double) {
    return NaN if $e1->is_nan || $e2->is_nan || $e1->is_infinite || $e2->is_infinite;
    
    if ($e2->dv == 0) {
      return NaN;
    }
    else {
      my $v3_value = $e1->dv - POSIX::floor($e1->dv / $e2->dv) * $e2->dv;
      return double($v3_value);
    }
  }
  elsif ($e1->is_integer) {
    if ($e2->iv == 0) {
      return NaN;
    }
    else {
      return double($e1 % $e2);
    }
  }
  elsif ($e1->is_logical) {
    if ($e2->iv == 0) {
      return NaN;
    }
    else {
      return double($e1->iv % $e2->iv);
    }
  }
  else {
    croak "Invalid type";
  }
}

sub Conj {
  my $e1 = shift;
  
  if ($e1->is_complex) {
    return complex_double($e1->re, Rstats::ElementFunc::negation($e1->im));
  }
  else {
    croak 'Invalid type';
  }
}

sub Re {
  my $e1 = shift;
  
  if ($e1->is_complex) {
    return $e1->re;
  }
  else {
    'Not implemented';
  }
}

sub Im {
  my $e1 = shift;
  
  if ($e1->is_complex) {
    return $e1->im;
  }
  else {
    'Not implemented';
  }
}

sub abs {
  my $e1 = shift;
  
  if ($e1->is_complex) {
    return raise(add(raise($e1->re, double(2)), raise($e1->im, double(2))), double(1/2));
  }
  elsif ($e1->is_double || $e1->is_integer) {
    my $type = $e1->type;
    my $zero = Rstats::ElementFunc::create($type);
    if (more_than($e1, $zero)) {
      return $e1;
    }
    else {
      return negation($e1);
    }
  }
  elsif ($e1->is_logical) {
    my $zero = Rstats::ElementFunc::create('logical');
    if (more_than($e1, $zero)) {
      return logical_to_integer($e1);
    }
    else {
      return negation(logical_to_integer($e1));
    }
  }
  else {
    croak 'non-numeric argument to mathematical function';
  }
}

sub logical_to_integer {
  my $e1 = shift;
  
  if ($e1->is_logical) {
    return integer($e1->iv);
  }
  else {
    return $e1;
  }
}

sub sqrt {
  my $e1 = shift;
  
  my $type = $e1->type;
  my $e2 = create($type, 1/2);
  
  return raise($e1, $e2);
}

sub more_than {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  if ($e1->is_character) {
    return $e1->cv gt $e2->cv ? TRUE : FALSE;
  }
  elsif ($e1->is_complex) {
    croak "invalid comparison with complex values";
  }
  elsif ($e1->is_double) {
    return NA if $e1->is_nan || $e2->is_nan;
    if (defined $e1->dv) {
      if (defined $e2->dv) {
        return $e1->dv > $e2->dv ? TRUE : FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return FALSE;
      }
      elsif ($e2->is_negative_infinite) {
        return TRUE;
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->dv) {
        return TRUE;
      }
      elsif ($e2->is_positive_infinite) {
        return FALSE;
      }
      elsif ($e2->is_negative_infinite) {
        return TRUE;
      }
    }
    elsif ($e1->is_negative_infinite) {
      if (defined $e2->dv) {
        return FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return FALSE;
      }
      elsif ($e2->is_negative_infinite) {
        return FALSE;
      }
    }
  }
  elsif ($e1->is_integer) {
    return $e1->iv > $e2->iv ? TRUE : FALSE;
  }
  elsif ($e1->is_logical) {
    return $e1->iv > $e2->iv ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

sub more_than_or_equal {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  if ($e1->is_character) {
    return $e1->cv ge $e2->cv ? TRUE : FALSE;
  }
  elsif ($e1->is_complex) {
    croak "invalid comparison with complex values";
  }
  elsif ($e1->is_double) {
    return NA if $e1->is_nan || $e2->is_nan;
    if (defined $e1->dv) {
      if (defined $e2->dv) {
        return $e1->dv >= $e2->dv ? TRUE : FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return FALSE;
      }
      elsif ($e2->is_negative_infinite) {
        return TRUE;
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->dv) {
        return TRUE;
      }
      elsif ($e2->is_positive_infinite) {
        return TRUE;
      }
      elsif ($e2->is_negative_infinite) {
        return TRUE;
      }
    }
    elsif ($e1->is_negative_infinite) {
      if (defined $e2->dv) {
        return FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return FALSE;
      }
      elsif ($e2->is_negative_infinite) {
        return TRUE;
      }
    }
  }
  elsif ($e1->is_integer) {
    return $e1->iv >= $e2->iv ? TRUE : FALSE;
  }
  elsif ($e1->is_logical) {
    return $e1->iv >= $e2->iv ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

sub less_than {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  if ($e1->is_character) {
    return $e1->cv lt $e2->cv ? TRUE : FALSE;
  }
  elsif ($e1->is_complex) {
    croak "invalid comparison with complex values";
  }
  elsif ($e1->is_double) {
    return NA if $e1->is_nan || $e2->is_nan;
    if (defined $e1->dv) {
      if (defined $e2->dv) {
        return $e1->dv < $e2->dv ? TRUE : FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return TRUE;
      }
      elsif ($e2->is_negative_infinite) {
        return FALSE;
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->dv) {
        return FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return TRUE;
      }
      elsif ($e2->is_negative_infinite) {
        return FALSE;
      }
    }
    elsif ($e1->is_negative_infinite) {
      if (defined $e2->dv) {
        return TRUE;
      }
      elsif ($e2->is_positive_infinite) {
        return TRUE;
      }
      elsif ($e2->is_negative_infinite) {
        return FALSE;
      }
    }
  }
  elsif ($e1->is_integer) {
    return $e1->iv < $e2->iv ? TRUE : FALSE;
  }
  elsif ($e1->is_logical) {
    return $e1->iv < $e2->iv ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

sub less_than_or_equal {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  if ($e1->is_character) {
    return $e1->cv le $e2->cv ? TRUE : FALSE;
  }
  elsif ($e1->is_complex) {
    croak "invalid comparison with complex values";
  }
  elsif ($e1->is_double) {
    return NA if $e1->is_nan || $e2->is_nan;
    if (defined $e1->dv) {
      if (defined $e2->dv) {
        return $e1->dv <= $e2->dv ? TRUE : FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return TRUE;
      }
      elsif ($e2->is_negative_infinite) {
        return FALSE;
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->dv) {
        return FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return TRUE;
      }
      elsif ($e2->is_negative_infinite) {
        return FALSE;
      }
    }
    elsif ($e1->is_negative_infinite) {
      if (defined $e2->dv) {
        return TRUE;
      }
      elsif ($e2->is_positive_infinite) {
        return TRUE;
      }
      elsif ($e2->is_negative_infinite) {
        return TRUE;
      }
    }
  }
  elsif ($e1->is_integer) {
    return $e1->iv <= $e2->iv ? TRUE : FALSE;
  }
  elsif ($e1->is_logical) {
    return $e1->iv <= $e2->iv ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

sub equal {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  if ($e1->is_character) {
    return $e1->cv eq $e2->cv ? TRUE : FALSE;
  }
  elsif ($e1->is_complex) {
    return $e1->re->value == $e2->re->value && $e1->im->value == $e2->im->value ? TRUE : FALSE;
  }
  elsif ($e1->is_double) {
    return NA if $e1->is_nan || $e2->is_nan;
    if (defined $e1->dv) {
      if (defined $e2->dv) {
        return $e1->dv == $e2->dv ? TRUE : FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return FALSE;
      }
      elsif ($e2->is_negative_infinite) {
        return FALSE;
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->dv) {
        return FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return TRUE;
      }
      elsif ($e2->is_negative_infinite) {
        return FALSE;
      }
    }
    elsif ($e1->is_negative_infinite) {
      if (defined $e2->dv) {
        return FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return FALSE;
      }
      elsif ($e2->is_negative_infinite) {
        return TRUE;
      }
    }
  }
  elsif ($e1->is_integer) {
    return $e1->iv == $e2->iv ? TRUE : FALSE;
  }
  elsif ($e1->is_logical) {
    return $e1->iv == $e2->iv ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

sub not_equal {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  if ($e1->is_character) {
    return $e1->cv ne $e2->cv ? TRUE : FALSE;
  }
  elsif ($e1->is_complex) {
    return !($e1->re->value == $e2->re->value && $e1->im->value == $e2->im->value) ? TRUE : FALSE;
  }
  elsif ($e1->is_double) {
    return NA if $e1->is_nan || $e2->is_nan;
    if (defined $e1->dv) {
      if (defined $e2->dv) {
        return $e1->dv != $e2->dv ? TRUE : FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return TRUE;
      }
      elsif ($e2->is_negative_infinite) {
        return TRUE;
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->dv) {
        return TRUE;
      }
      elsif ($e2->is_positive_infinite) {
        return FALSE;
      }
      elsif ($e2->is_negative_infinite) {
        return TRUE;
      }
    }
    elsif ($e1->is_negative_infinite) {
      if (defined $e2->dv) {
        return TRUE;
      }
      elsif ($e2->is_positive_infinite) {
        return TRUE;
      }
      elsif ($e2->is_negative_infinite) {
        return FALSE;
      }
    }
  }
  elsif ($e1->is_integer) {
    return $e1->iv != $e2->iv ? TRUE : FALSE;
  }
  elsif ($e1->is_logical) {
    return $e1->iv != $e2->iv ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

=head1 NAME

Rstats::ElementFunc - Element functions

1;
