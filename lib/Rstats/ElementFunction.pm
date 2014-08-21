package Rstats::ElementFunction;

use strict;
use warnings;
use Carp 'croak', 'carp';

require Rstats::Element::NA;
require Rstats::Element::Logical;
require Rstats::Element::Complex;
require Rstats::Element::Integer;
use Scalar::Util ();
use B ();
use Math::Complex ();
use POSIX ();
use Math::Trig ();

# Perl infinite values(this is value is only valid as return value)
my $perl_inf_result = 9 ** 9 ** 9;
my $perl_negative_inf_result = -9 ** 9 ** 9;

# Special values
my $na = Rstats::Element::NA->new;
my $nan = Rstats::Element->new(type => 'double', flag => 'nan');
my $inf = Rstats::Element->new(type => 'double', flag => 'inf');
my $negative_inf = Rstats::Element->new(type => 'double', flag => '-inf');
my $true = logical(1);
my $false = logical(0);
my $pi = double(Math::Trig::pi);

# Address
my $true_ad = Scalar::Util::refaddr $true;
my $false_ad = Scalar::Util::refaddr $false;
my $na_ad = Scalar::Util::refaddr $na;
my $nan_ad = Scalar::Util::refaddr $nan;
my $inf_ad = Scalar::Util::refaddr $inf;
my $negative_inf_ad = Scalar::Util::refaddr $negative_inf;

sub TRUE () { $true }
sub FALSE () { $false }
sub NA () { $na }
sub NaN () { $nan }
sub Inf () { $inf }
sub negativeInf () { $negative_inf }
sub pi () { $pi }

sub character { Rstats::Element->new(cv => shift, type => 'character') }

sub complex {
  my ($re_value, $im_value) = @_;
  
  my $re = double($re_value);
  my $im = double($im_value);
  my $z = complex_double($re, $im);
  
  return $z;
}
sub complex_double {
  my ($re, $im) = @_;
  
  my $z = Rstats::Element::Complex->new(re => $re, im => $im);
}
sub double { Rstats::Element->new(re => shift, type => 'double', flag => shift || 'normal') }
sub integer { Rstats::Element::Integer->new(value => int(shift)) }
sub logical { Rstats::Element::Logical->new(value => shift) }

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
        Rstats::ElementFunction::log(
          divide(
            add(complex(1, 0), $e1),
            subtract(complex(1, 0), $e1)
          )
        )
      );
    }
  }
  elsif ($e1->is_numeric || $e1->is_logical) {
    $e1 = Rstats::ElementFunction::as_double($e1);
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
      elsif (less_than(Rstats::ElementFunction::abs($e1), double(1))) {
        $e2 = divide(
          Rstats::ElementFunction::log(
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
      Rstats::ElementFunction::sqrt(
        subtract(
          multiply($e1, $e1),
          complex(1, 0)
        ),
      ),
      $e1
    );
    my $e2_u = Rstats::ElementFunction::log($e2_t);
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
    $e1 = Rstats::ElementFunction::as_double($e1);
    return $e1 if $e1->is_nan;
    
    if ($e1->is_infinite) {
        $e2 = NaN;
        carp "In acosh() : NaNs produced";
    }
    else {
      if (more_than_or_equal($e1, double(1))) {
        $e2 = Rstats::ElementFunction::log(
          add(
            $e1,
            Rstats::ElementFunction::sqrt(
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
      Rstats::ElementFunction::sqrt(
        add(
          multiply($e1, $e1),
          complex(1, 0)
        )
      ),
      $e1
    );
    
    $e2 = Rstats::ElementFunction::log($e2_t);
  }
  elsif ($e1->is_numeric || $e1->is_logical) {
    $e1 = Rstats::ElementFunction::as_double($e1);
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
        Rstats::ElementFunction::sqrt(
          add(
            multiply($e1, $e1),
            double(1)
          )
        )
      );
      
      $e2 = Rstats::ElementFunction::log($e2_t);
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
    $e1 = Rstats::ElementFunction::as_double($e1);
    
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
    
    my $e2_cy = Rstats::ElementFunction::cos($e1_y);
    my $e2_sy = Rstats::ElementFunction::sin($e1_y);
    my $e2_ex = Rstats::ElementFunction::exp($e1_x);
    
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
    $e1 = Rstats::ElementFunction::as_double($e1);
    return $e1 if $e1->is_nan;
    
    my $e2_ex = Rstats::ElementFunction::exp($e1);
    
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
    
    my $e2_cy = Rstats::ElementFunction::cos($e1_y);
    my $e2_sy = Rstats::ElementFunction::sin($e1_y);
    my $e2_ex = Rstats::ElementFunction::exp($e1_x);
    
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
    $e1 = Rstats::ElementFunction::as_double($e1);
    return $e1 if $e1->is_nan;
    
    return double(0) if equal($e1, double(0));
    my $e2_ex = Rstats::ElementFunction::exp($e1);
    
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
      my $e2_log = Rstats::ElementFunction::log(
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
    $e2 = Rstats::ElementFunction::atan2(as_double($e1), double(1));
  }
  else {
    croak "Not implemented";
  }
  
  return $e2;
}


sub atan2 {
  my ($e1, $e2) = @_;
  
  croak "argument x is missing" unless defined $e2;
  return Rstats::ElementFunction::NA if $e1->is_na || $e2->is_na;
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
        Rstats::ElementFunction::log(
          divide(
            $e3_r,
            Rstats::ElementFunction::sqrt($e3_s)
          )
        )
      );
    }
  }
  elsif ($e1->is_numeric || $e1->is_logical) {
    $e1 = as_double($e1) unless $e1->is_double;
    $e2 = as_double($e2) unless $e2->is_double;

    my $value1;
    my $value2;
    
    if ($e1->is_nan || $e2->is_nan) {
      $e3 = Rstats::ElementFunction::NaN;
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
      my $value1 = $e1->{re};
      if ($value1 >= 0) {
        $e3 = double(3.14159265358979);
      }
      else {
        $e3 = double(-3.14159265358979);
      }
    }
    else {
      my $value1 = $e1->{re};
      my $value2 = $e2->{re};
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
    Rstats::ElementFunction::log($e1),
    $e1->is_complex ? Rstats::ElementFunction::log(complex(2, 0)) : Rstats::ElementFunction::log(double(2))
  );
  
  return $e2;
}

sub log10 {
  my $e1 = shift;
  
  my $e2 = divide(
    Rstats::ElementFunction::log($e1),
    $e1->is_complex ? Rstats::ElementFunction::log(complex(10, 0)) : Rstats::ElementFunction::log(double(10))
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
      
      $e2 = complex_double(Rstats::ElementFunction::log($e1_r), $e1_t);
    }
  }
  elsif ($e1->is_numeric || $e1->is_logical) {
    $e1 = as_double($e1) unless $e1->is_double;
    my $value = $e1->{re};
    
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

sub Mod { Rstats::ElementFunction::abs(@_) }

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
  
  my $e2 = divide(Rstats::ElementFunction::sin($e1), Rstats::ElementFunction::cos($e1));
  
  return $e2;
}

sub cos {
  my $e1 = shift;
  
  return $e1 if $e1->is_na;
  
  my $e2;
  if ($e1->is_complex) {
    
    my $e1_re = $e1->re;
    my $e1_im = $e1->im;
    
    my $e2_eim = Rstats::ElementFunction::exp($e1_im);
    my $e2_sre = Rstats::ElementFunction::sin($e1_re);
    my $e2_cre = Rstats::ElementFunction::cos($e1_re);
    
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
    $e1 = as_double($e1) unless $e1->is_double;
    my $value = $e1->{re};
    
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
    
    my $e2_mod = Rstats::ElementFunction::exp($e1_re);
    my $e2_arg = $e1_im;

    my $e2_re = Rstats::ElementFunction::multiply(
      $e2_mod,
      Rstats::ElementFunction::cos($e2_arg)
    );
    my $e2_im = Rstats::ElementFunction::multiply(
      $e2_mod,
      Rstats::ElementFunction::sin($e2_arg)
    );
    
    $e2 = complex_double($e2_re, $e2_im);
  }
  elsif ($e1->is_double || $e1->is_integer || $e1->is_logical) {
    $e1 = as_double($e1) unless $e1->is_double;
    
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
      my $value = $e1->{re};
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
      $e2 = Rstats::ElementFunction::subtract(Rstats::ElementFunction::exp($e1), double(1));
    }
  }
  elsif ($e1->is_integer || $e1->is_logical) {
    $e2 = Rstats::ElementFunction::subtract(Rstats::ElementFunction::exp($e1), double(1));
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
      my $e2_t1 = Rstats::ElementFunction::sqrt(
        add(
          multiply(
            add($e1_re, double(1)),
            add($e1_re, double(1))
          ),
          multiply($e1_im, $e1_im)
        )
      );
      my $e2_t2 = Rstats::ElementFunction::sqrt(
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
      
      my $e2_u =  Rstats::ElementFunction::atan2(
        Rstats::ElementFunction::sqrt(
          subtract(
            double(1),
            multiply($e2_beta, $e2_beta)
          )
        ),
        $e2_beta
      );
      
      my $e2_v = Rstats::ElementFunction::log(
        add(
          $e2_alpha,
          Rstats::ElementFunction::sqrt(
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
      $e1 = as_double($e1);
      if (less_than_or_equal(Rstats::ElementFunction::abs($e1), double(1))) {
        $e2 = Rstats::ElementFunction::atan2(
          Rstats::ElementFunction::sqrt(
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
      my $e2_t1 = Rstats::ElementFunction::sqrt(
        add(
          multiply(
            add($e1_re, double(1)),
            add($e1_re, double(1))
          ),
          multiply($e1_im, $e1_im)
        )
      );
      my $e2_t2 = Rstats::ElementFunction::sqrt(
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
      
      my $e2_u =  Rstats::ElementFunction::atan2(
        $e2_beta,
        Rstats::ElementFunction::sqrt(
          subtract(
            double(1),
            multiply($e2_beta, $e2_beta)
          )
        )
      );
      
      my $e2_v = negation(
        Rstats::ElementFunction::log(
          add(
            $e2_alpha,
            Rstats::ElementFunction::sqrt(
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
      $e1 = as_double($e1);
      if (less_than_or_equal(Rstats::ElementFunction::abs($e1), double(1))) {
        $e2 = Rstats::ElementFunction::atan2(
          $e1,
          Rstats::ElementFunction::sqrt(
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
    
    my $e2_eim = Rstats::ElementFunction::exp($e1_im);
    my $e2_sre = Rstats::ElementFunction::sin($e1_re);
    my $e2_cre = Rstats::ElementFunction::cos($e1_re);
    
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
    $e1 = as_double($e1) unless $e1->is_double;
    my $value = $e1->{re};
    
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
    return logical($value ? Rstats::ElementFunction::TRUE : Rstats::ElementFunction::FALSE);
  }
  else {
    croak 'Invalid type';
  }
}

sub looks_like_number {
  my $value = shift;
  
  return if !defined $value || !CORE::length $value;
  $value =~ s/^ +//;
  $value =~ s/ +$//;
  
  if (Scalar::Util::looks_like_number $value) {
    return $value + 0;
  }
  else {
    return;
  }
}

sub looks_like_complex {
  my $value = shift;
  
  return if !defined $value || !CORE::length $value;
  $value =~ s/^ +//;
  $value =~ s/ +$//;
  
  my $re;
  my $im;
  
  if ($value =~ /^([\+\-]?[^\+\-]+)i$/) {
    $re = 0;
    $im = $1;
  }
  elsif($value =~ /^([\+\-]?[^\+\-]+)(?:([\+\-][^\+\-i]+)i)?$/) {
    $re = $1;
    $im = $2;
    $im = 0 unless defined $im;
  }
  else {
    return;
  }
  
  if (defined Rstats::ElementFunction::looks_like_number($re) && defined Rstats::ElementFunction::looks_like_number($im)) {
    return {re => $re + 0, im => $im + 0};
  }
  else {
    return;
  }
}

sub element {
  my $value = shift;
  
  return ref $value ? $value
    : is_perl_number($value) ? double($value)
    : character($value);

}

sub is_perl_number {
  my ($value) = @_;
  
  return unless defined $value;
  
  return B::svref_2object(\$value)->FLAGS & (B::SVp_IOK | B::SVp_NOK) 
        && 0 + $value eq $value
        && $value * 0 == 0
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
    if (defined $e1->{re}) {
      return double(-$e1->{re});
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
    return integer(-$e1->{value});
  }
  else {
    croak "Invalid type";
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
    if (defined $e1->{re}) {
      if (defined $e2->{re}) {
        my $value = $e1->{re} + $e2->{re};
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
      if (defined $e2->{re}) {
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
      if (defined $e2->{re}) {
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
    return integer($e1->{value} + $e2->{value});
  }
  elsif ($e1->is_logical) {
    return integer($e1->{value} + $e2->{value});
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
    if (defined $e1->{re}) {
      if (defined $e2->{re}) {
        my $value = $e1->{re} - $e2->{re};
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
      if (defined $e2->{re}) {
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
      if (defined $e2->{re}) {
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
    return integer($e1->{value} + $e2->{value});
  }
  elsif ($e1->is_logical) {
    return integer($e1->{value} + $e2->{value});
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
    if (defined $e1->{re}) {
      if (defined $e2->{re}) {
        my $value = $e1->{re} * $e2->{re};
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
        if ($e1->{re} == 0) {
          return NaN;
        }
        elsif ($e1->{re} > 0) {
          return Inf;
        }
        elsif ($e1->{re} < 0) {
          return negativeInf;
        }
      }
      elsif ($e2->is_negative_infinite) {
        if ($e1->{re} == 0) {
          return NaN;
        }
        elsif ($e1->{re} > 0) {
          return negativeInf;
        }
        elsif ($e1->{re} < 0) {
          return Inf;
        }
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->{re}) {
        if ($e2->{re} == 0) {
          return NaN;
        }
        elsif ($e2->{re} > 0) {
          return Inf;
        }
        elsif ($e2->{re} < 0) {
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
      if (defined $e2->{re}) {
        if ($e2->{re} == 0) {
          return NaN;
        }
        elsif ($e2->{re} > 0) {
          return negativeInf;
        }
        elsif ($e2->{re} < 0) {
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
    return integer($e1->{value} * $e2->{value});
  }
  elsif ($e1->is_logical) {
    return integer($e1->{value} * $e2->{value});
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
    if (defined $e1->{re}) {
      if ($e1->{re} == 0) {
        if (defined $e2->{re}) {
          if ($e2->{re} == 0) {
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
      elsif ($e1->{re} > 0) {
        if (defined $e2->{re}) {
          if ($e2->{re} == 0) {
            return Inf;
          }
          else {
            my $value = $e1->{re} / $e2->{re};
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
      elsif ($e1->{re} < 0) {
        if (defined $e2->{re}) {
          if ($e2->{re} == 0) {
            return negativeInf;
          }
          else {
            return double($e1->{re} / $e2->{re});
          }
        }
        elsif ($e2->is_infinite) {
          return double(0);
        }
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->{re}) {
        if ($e2->{re} >= 0) {
          return Inf;
        }
        elsif ($e2->{re} < 0) {
          return negativeInf;
        }
      }
      elsif ($e2->is_infinite) {
        return NaN;
      }
    }
    elsif ($e1->is_negative_infinite) {
      if (defined $e2->{re}) {
        if ($e2->{re} >= 0) {
          return negativeInf;
        }
        elsif ($e2->{re} < 0) {
          return Inf;
        }
      }
      elsif ($e2->is_infinite) {
        return NaN;
      }
    }
  }
  elsif ($e1->is_integer) {
    if ($e1->{value} == 0) {
      if ($e2->{value} == 0) {
        return NaN;
      }
      else {
        return double(0);
      }
    }
    elsif ($e1->{value} > 0) {
      if ($e2->{value} == 0) {
        return Inf;
      }
      else  {
        return double($e1->{value} / $e2->{value});
      }
    }
    elsif ($e1->{value} < 0) {
      if ($e2->{value} == 0) {
        return negativeInf;
      }
      else {
        return double($e1->{value} / $e2->{value});
      }
    }
  }
  elsif ($e1->is_logical) {
    if ($e1->{value} == 0) {
      if ($e2->{value} == 0) {
        return NaN;
      }
      elsif ($e2->{value} == 1) {
        return double(0);
      }
    }
    elsif ($e1->{value} == 1) {
      if ($e2->{value} == 0) {
        return Inf;
      }
      elsif ($e2->{value} == 1)  {
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
    if (defined $e1->{re}) {
      if ($e1->{re} == 0) {
        if (defined $e2->{re}) {
          if ($e2->{re} == 0) {
            return double(1);
          }
          elsif ($e2->{re} > 0) {
            return double(0);
          }
          elsif ($e2->{re} < 0) {
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
      elsif ($e1->{re} > 0) {
        if (defined $e2->{re}) {
          if ($e2->{re} == 0) {
            return double(1);
          }
          else {
            my $value = $e1->{re} ** $e2->{re};
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
          if ($e1->{re} < 1) {
            return double(0);
          }
          elsif ($e1->{re} == 1) {
            return double(1);
          }
          elsif ($e1->{re} > 1) {
            return Inf;
          }
        }
        elsif ($e2->is_negative_infinite) {
          if ($e1->{re} < 1) {
            return double(0);
          }
          elsif ($e1->{re} == 1) {
            return double(1);
          }
          elsif ($e1->{re} > 1) {
            return double(0);
          }
        }
      }
      elsif ($e1->{re} < 0) {
        if (defined $e2->{re}) {
          if ($e2->{re} == 0) {
            return double(-1);
          }
          else {
            return double($e1->{re} ** $e2->{re});
          }
        }
        elsif ($e2->is_positive_infinite) {
          if ($e1->{re} > -1) {
            return double(0);
          }
          elsif ($e1->{re} == -1) {
            return double(-1);
          }
          elsif ($e1->{re} < -1) {
            return negativeInf;
          }
        }
        elsif ($e2->is_negative_infinite) {
          if ($e1->{re} > -1) {
            return Inf;
          }
          elsif ($e1->{re} == -1) {
            return double(-1);
          }
          elsif ($e1->{re} < -1) {
            return double(0);
          }
        }
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->{re}) {
        if ($e2->{re} == 0) {
          return double(1);
        }
        elsif ($e2->{re} > 0) {
          return Inf;
        }
        elsif ($e2->{re} < 0) {
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
      if (defined $e2->{re}) {
        if ($e2->{re} == 0) {
          return double(-1);
        }
        elsif ($e2->{re} > 0) {
          return negativeInf;
        }
        elsif ($e2->{re} < 0) {
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
    if ($e1->{value} == 0) {
      if ($e2->{value} == 0) {
        return double(1);
      }
      elsif ($e2->{value} > 0) {
        return double(0);
      }
      elsif ($e2->{value} < 0) {
        return Inf;
      }
    }
    elsif ($e1->{value} > 0) {
      if ($e2->{value} == 0) {
        return double(1);
      }
      else {
        return double($e1->{value} ** $e2->{value});
      }
    }
    elsif ($e1->{value} < 0) {
      if ($e2->{value} == 0) {
        return double(-1);
      }
      else {
        return double($e1->{value} ** $e2->{value});
      }
    }
  }
  elsif ($e1->is_logical) {
    if ($e1->{value} == 0) {
      if ($e2->{value} == 0) {
        return double(1);
      }
      elsif ($e2->{value} == 1) {
        return double(0);
      }
    }
    elsif ($e1->{value} ==  1) {
      if ($e2->{value} == 0) {
        return double(1);
      }
      elsif ($e2->{value} == 1) {
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
    
    if ($e2->{re} == 0) {
      return NaN;
    }
    else {
      my $v3_value = $e1->{re} - POSIX::floor($e1->{re} / $e2->{re}) * $e2->{re};
      return double($v3_value);
    }
  }
  elsif ($e1->is_integer) {
    if ($e2->{value} == 0) {
      return NaN;
    }
    else {
      return double($e1 % $e2);
    }
  }
  elsif ($e1->is_logical) {
    if ($e2->{value} == 0) {
      return NaN;
    }
    else {
      return double($e1->{value} % $e2->{value});
    }
  }
  else {
    croak "Invalid type";
  }
}

sub Conj {
  my $e1 = shift;
  
  if ($e1->is_complex) {
    return complex_double($e1->re, Rstats::ElementFunction::negation($e1->im));
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
    my $zero = Rstats::ElementFunction::create($type);
    if (more_than($e1, $zero)) {
      return $e1;
    }
    else {
      return negation($e1);
    }
  }
  elsif ($e1->is_logical) {
    my $zero = Rstats::ElementFunction::create('logical');
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
    return integer($e1->{value});
  }
  else {
    return $e1;
  }
}

sub as_character {
  my $e1 = shift;
  
  my $e2 = character("$e1");
  
  return $e2;
}

sub as_complex {
  my $e1 = shift;

  if ($e1->is_na) {
    return $e1;
  }
  elsif ($e1->is_character) {
    my $z = looks_like_complex($e1->{cv});
    if (defined $z) {
      return complex($z->{re}, $z->{im});
    }
    else {
      carp 'NAs introduced by coercion';
      return NA;
    }
  }
  elsif ($e1->is_complex) {
    return $e1;
  }
  elsif ($e1->is_double) {
    if ($e1->is_nan) {
      return NA;
    }
    else {
      return complex_double($e1, double(0));
    }
  }
  elsif ($e1->is_integer) {
    return complex($e1->{value}, 0);
  }
  elsif ($e1->is_logical) {
    return complex($e1->{value} ? 1 : 0, 0);
  }
  else {
    croak "unexpected type";
  }
}

sub as_numeric { as_double(@_) }

sub as_double {
  my $e1 = shift;

  if ($e1->is_na) {
    return $e1;
  }
  elsif ($e1->is_character) {
    if (my $num = Rstats::ElementFunction::looks_like_number($e1->{cv})) {
      return double($num + 0);
    }
    else {
      carp 'NAs introduced by coercion';
      return NA;
    }
  }
  elsif ($e1->is_complex) {
    carp "imaginary parts discarded in coercion";
    return double($e1->re->value);
  }
  elsif ($e1->is_double) {
    return $e1;
  }
  elsif ($e1->is_integer) {
    return double($e1->{value});
  }
  elsif ($e1->is_logical) {
    return double($e1->{value} ? 1 : 0);
  }
  else {
    croak "unexpected type";
  }
}

sub as_integer {
  my $e1 = shift;

  if ($e1->is_na) {
    return $e1;
  }
  elsif ($e1->is_character) {
    if (my $num = Rstats::ElementFunction::looks_like_number($e1->{cv})) {
      return Rstats::ElementFunction::integer(int $num);
    }
    else {
      carp 'NAs introduced by coercion';
      return NA;
    }
  }
  elsif ($e1->is_complex) {
    carp "imaginary parts discarded in coercion";
    return integer(int($e1->re->value));
  }
  elsif ($e1->is_double) {
    if ($e1->is_nan || $e1->is_infinite) {
      return NA;
    }
    else {
      return Rstats::ElementFunction::integer($e1->{re});
    }
  }
  elsif ($e1->is_integer) {
    return $e1; 
  }
  elsif ($e1->is_logical) {
    return integer($e1->{value} ? 1 : 0);
  }
  else {
    croak "unexpected type";
  }
}

sub as_logical {
  my $e1 = shift;
  
  if ($e1->is_na) {
    return $e1;
  }
  elsif ($e1->is_character) {
    return NA;
  }
  elsif ($e1->is_complex) {
    carp "imaginary parts discarded in coercion";
    my $re = $e1->re->value;
    my $im = $e1->im->value;
    if (defined $re && $re == 0 && defined $im && $im == 0) {
      return FALSE;
    }
    else {
      return TRUE;
    }
  }
  elsif ($e1->is_double) {
    if ($e1->is_nan) {
      return NA;
    }
    elsif ($e1->is_infinite) {
      return TRUE;
    }
    else {
      return $e1->{re} == 0 ? FALSE : TRUE;
    }
  }
  elsif ($e1->is_integer) {
    return $e1->{value} == 0 ? FALSE : TRUE;
  }
  elsif ($e1->is_logical) {
    return $e1->{value} == 0 ? FALSE : TRUE;
  }
  else {
    croak "unexpected type";
  }
}

sub as {
  my ($type, $e1) = @_;
  
  if ($type eq 'character') {
    return as_character($e1);
  }
  elsif ($type eq 'complex') {
    return as_complex($e1);
  }
  elsif ($type eq 'double') {
    return as_double($e1);
  }
  elsif ($type eq 'numeric') {
    return as_numeric($e1);
  }
  elsif ($type eq 'integer') {
    return as_integer($e1);
  }
  elsif ($type eq 'logical') {
    return as_logical($e1);
  }
  else {
    croak "Invalid mode is passed";
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
    return $e1->{cv} gt $e2->{cv} ? TRUE : FALSE;
  }
  elsif ($e1->is_complex) {
    croak "invalid comparison with complex values";
  }
  elsif ($e1->is_double) {
    return NA if $e1->is_nan || $e2->is_nan;
    if (defined $e1->{re}) {
      if (defined $e2->{re}) {
        return $e1->{re} > $e2->{re} ? TRUE : FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return FALSE;
      }
      elsif ($e2->is_negative_infinite) {
        return TRUE;
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->{re}) {
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
      if (defined $e2->{re}) {
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
    return $e1->{value} > $e2->{value} ? TRUE : FALSE;
  }
  elsif ($e1->is_logical) {
    return $e1->{value} > $e2->{value} ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

sub more_than_or_equal {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  if ($e1->is_character) {
    return $e1->{cv} ge $e2->{cv} ? TRUE : FALSE;
  }
  elsif ($e1->is_complex) {
    croak "invalid comparison with complex values";
  }
  elsif ($e1->is_double) {
    return NA if $e1->is_nan || $e2->is_nan;
    if (defined $e1->{re}) {
      if (defined $e2->{re}) {
        return $e1->{re} >= $e2->{re} ? TRUE : FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return FALSE;
      }
      elsif ($e2->is_negative_infinite) {
        return TRUE;
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->{re}) {
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
      if (defined $e2->{re}) {
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
    return $e1->{value} >= $e2->{value} ? TRUE : FALSE;
  }
  elsif ($e1->is_logical) {
    return $e1->{value} >= $e2->{value} ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

sub less_than {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  if ($e1->is_character) {
    return $e1->{cv} lt $e2->{cv} ? TRUE : FALSE;
  }
  elsif ($e1->is_complex) {
    croak "invalid comparison with complex values";
  }
  elsif ($e1->is_double) {
    return NA if $e1->is_nan || $e2->is_nan;
    if (defined $e1->{re}) {
      if (defined $e2->{re}) {
        return $e1->{re} < $e2->{re} ? TRUE : FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return TRUE;
      }
      elsif ($e2->is_negative_infinite) {
        return FALSE;
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->{re}) {
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
      if (defined $e2->{re}) {
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
    return $e1->{value} < $e2->{value} ? TRUE : FALSE;
  }
  elsif ($e1->is_logical) {
    return $e1->{value} < $e2->{value} ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

sub less_than_or_equal {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  if ($e1->is_character) {
    return $e1->{cv} le $e2->{cv} ? TRUE : FALSE;
  }
  elsif ($e1->is_complex) {
    croak "invalid comparison with complex values";
  }
  elsif ($e1->is_double) {
    return NA if $e1->is_nan || $e2->is_nan;
    if (defined $e1->{re}) {
      if (defined $e2->{re}) {
        return $e1->{re} <= $e2->{re} ? TRUE : FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return TRUE;
      }
      elsif ($e2->is_negative_infinite) {
        return FALSE;
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->{re}) {
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
      if (defined $e2->{re}) {
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
    return $e1->{value} <= $e2->{value} ? TRUE : FALSE;
  }
  elsif ($e1->is_logical) {
    return $e1->{value} <= $e2->{value} ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

sub equal {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  if ($e1->is_character) {
    return $e1->{cv} eq $e2->{cv} ? TRUE : FALSE;
  }
  elsif ($e1->is_complex) {
    return $e1->re->value == $e2->re->value && $e1->im->value == $e2->im->value ? TRUE : FALSE;
  }
  elsif ($e1->is_double) {
    return NA if $e1->is_nan || $e2->is_nan;
    if (defined $e1->{re}) {
      if (defined $e2->{re}) {
        return $e1->{re} == $e2->{re} ? TRUE : FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return FALSE;
      }
      elsif ($e2->is_negative_infinite) {
        return FALSE;
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->{re}) {
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
      if (defined $e2->{re}) {
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
    return $e1->{value} == $e2->{value} ? TRUE : FALSE;
  }
  elsif ($e1->is_logical) {
    return $e1->{value} == $e2->{value} ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

sub not_equal {
  my ($e1, $e2) = @_;
  
  return NA if $e1->is_na || $e2->is_na;
  
  if ($e1->is_character) {
    return $e1->{cv} ne $e2->{cv} ? TRUE : FALSE;
  }
  elsif ($e1->is_complex) {
    return !($e1->re->value == $e2->re->value && $e1->im->value == $e2->im->value) ? TRUE : FALSE;
  }
  elsif ($e1->is_double) {
    return NA if $e1->is_nan || $e2->is_nan;
    if (defined $e1->{re}) {
      if (defined $e2->{re}) {
        return $e1->{re} != $e2->{re} ? TRUE : FALSE;
      }
      elsif ($e2->is_positive_infinite) {
        return TRUE;
      }
      elsif ($e2->is_negative_infinite) {
        return TRUE;
      }
    }
    elsif ($e1->is_positive_infinite) {
      if (defined $e2->{re}) {
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
      if (defined $e2->{re}) {
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
    return $e1->{value} != $e2->{value} ? TRUE : FALSE;
  }
  elsif ($e1->is_logical) {
    return $e1->{value} != $e2->{value} ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

1;
