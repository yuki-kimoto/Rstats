package Rstats::ElementsFunc;

use strict;
use warnings;
use Carp 'croak', 'carp';

require Rstats;
use Rstats::Elements;
use Scalar::Util ();
use Math::Trig ();
use POSIX ();

sub TRUE () { new_true() }
sub FALSE () { new_false() }
sub NA () { new_na() }
sub NaN () { new_nan() }
sub Inf () { new_inf() }
sub negativeInf () { new_negative_inf() }
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
        Rstats::ElementsFunc::log(
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
      elsif (less_than(Rstats::ElementsFunc::abs($e1), double(1))) {
        $e2 = divide(
          Rstats::ElementsFunc::log(
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
      Rstats::ElementsFunc::sqrt(
        subtract(
          multiply($e1, $e1),
          complex(1, 0)
        ),
      ),
      $e1
    );
    my $e2_u = Rstats::ElementsFunc::log($e2_t);
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
        $e2 = Rstats::ElementsFunc::log(
          add(
            $e1,
            Rstats::ElementsFunc::sqrt(
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
      Rstats::ElementsFunc::sqrt(
        add(
          multiply($e1, $e1),
          complex(1, 0)
        )
      ),
      $e1
    );
    
    $e2 = Rstats::ElementsFunc::log($e2_t);
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
        Rstats::ElementsFunc::sqrt(
          add(
            multiply($e1, $e1),
            double(1)
          )
        )
      );
      
      $e2 = Rstats::ElementsFunc::log($e2_t);
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
      my $e2_log = Rstats::ElementsFunc::log(
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
    $e2 = Rstats::ElementsFunc::atan2($e1->as_double, double(1));
  }
  else {
    croak "Not implemented";
  }
  
  return $e2;
}


sub atan2 {
  my ($e1, $e2) = @_;
  
  croak "argument x is missing" unless defined $e2;
  return Rstats::ElementsFunc::NA if $e1->is_na || $e2->is_na;
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
        Rstats::ElementsFunc::log(
          divide(
            $e3_r,
            Rstats::ElementsFunc::sqrt($e3_s)
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
      $e3 = Rstats::ElementsFunc::NaN;
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

sub Mod { Rstats::ElementsFunc::abs(@_) }

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
      $e2 = Rstats::ElementsFunc::subtract(Rstats::ElementsFunc::exp($e1), double(1));
    }
  }
  elsif ($e1->is_integer || $e1->is_logical) {
    $e2 = Rstats::ElementsFunc::subtract(Rstats::ElementsFunc::exp($e1), double(1));
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
      my $e2_t1 = Rstats::ElementsFunc::sqrt(
        add(
          multiply(
            add($e1_re, double(1)),
            add($e1_re, double(1))
          ),
          multiply($e1_im, $e1_im)
        )
      );
      my $e2_t2 = Rstats::ElementsFunc::sqrt(
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
      
      my $e2_u =  Rstats::ElementsFunc::atan2(
        Rstats::ElementsFunc::sqrt(
          subtract(
            double(1),
            multiply($e2_beta, $e2_beta)
          )
        ),
        $e2_beta
      );
      
      my $e2_v = Rstats::ElementsFunc::log(
        add(
          $e2_alpha,
          Rstats::ElementsFunc::sqrt(
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
      if (less_than_or_equal(Rstats::ElementsFunc::abs($e1), double(1))) {
        $e2 = Rstats::ElementsFunc::atan2(
          Rstats::ElementsFunc::sqrt(
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
      my $e2_t1 = Rstats::ElementsFunc::sqrt(
        add(
          multiply(
            add($e1_re, double(1)),
            add($e1_re, double(1))
          ),
          multiply($e1_im, $e1_im)
        )
      );
      my $e2_t2 = Rstats::ElementsFunc::sqrt(
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
      
      my $e2_u =  Rstats::ElementsFunc::atan2(
        $e2_beta,
        Rstats::ElementsFunc::sqrt(
          subtract(
            double(1),
            multiply($e2_beta, $e2_beta)
          )
        )
      );
      
      my $e2_v = negation(
        Rstats::ElementsFunc::log(
          add(
            $e2_alpha,
            Rstats::ElementsFunc::sqrt(
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
      if (less_than_or_equal(Rstats::ElementsFunc::abs($e1), double(1))) {
        $e2 = Rstats::ElementsFunc::atan2(
          $e1,
          Rstats::ElementsFunc::sqrt(
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
    return logical($value ? Rstats::ElementsFunc::TRUE : Rstats::ElementsFunc::FALSE);
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
    return complex_double($e1->re, Rstats::ElementsFunc::negation($e1->im));
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

Rstats::ElementsFunc - Elements functions

1;
