package Rstats::Util;

use strict;
use warnings;
use Carp 'croak';

require Rstats::Type::NA;
require Rstats::Type::Logical;
require Rstats::Type::Complex;
require Rstats::Type::Character;
require Rstats::Type::Integer;
require Rstats::Type::Double;
use Scalar::Util 'refaddr';
use B;
use Math::Complex;
use POSIX ();

# Special values
my $na = Rstats::Type::NA->new;
my $nan = Rstats::Type::Double->new(flag => 'nan');
my $inf = Rstats::Type::Double->new(flag => 'inf');
my $negative_inf = Rstats::Type::Double->new(flag => '-inf');
my $true = logical(1);
my $false = logical(0);

# Address
my $true_ad = refaddr $true;
my $false_ad = refaddr $false;
my $na_ad = refaddr $na;
my $nan_ad = refaddr $nan;
my $inf_ad = refaddr $inf;
my $negative_inf_ad = refaddr $negative_inf;

sub TRUE { $true }
sub FALSE { $false }
sub NA { $na }
sub NaN { $nan }
sub Inf { $inf }
sub negativeInf { $negative_inf }

sub is_nan { ref $_[0] && (refaddr $_[0] == $nan_ad) }
sub is_na { ref $_[0] && (refaddr $_[0] == $na_ad) }
sub is_infinite { is_positive_infinite($_[0]) || is_negative_infinite($_[0]) }
sub is_positive_infinite { ref $_[0] && (refaddr $_[0] == $inf_ad) }
sub is_negative_infinite { ref $_[0] && (refaddr $_[0] == $negative_inf_ad) }
sub is_finite {
  return is_integer($_[0]) || (is_double($_[0]) && defined $_[0]->value);
}

sub is_character { ref $_[0] eq 'Rstats::Type::Character' }
sub is_complex { ref $_[0] eq 'Rstats::Type::Complex' }
sub is_double { ref $_[0] eq 'Rstats::Type::Double' }
sub is_integer { ref $_[0] eq 'Rstats::Type::Integer' }
sub is_logical { ref $_[0] eq 'Rstats::Type::Logical' }

sub character { Rstats::Type::Character->new(value => shift) }
sub complex {
  my ($re_value, $im_value) = @_;
  
  my $re = double($re_value);
  my $im = double($im_value);
  my $z = complex_double($re, $im);
  
  return $z;
}
sub complex_double {
  my ($re, $im) = @_;
  
  my $z = Rstats::Type::complex->new(re => $re, $im => $im);
}
sub double { Rstats::Type::Double->new(value => shift, flag => shift || 'normal') }
sub integer { Rstats::Type::Integer->new(value => shift) }
sub logical { Rstats::Type::Logical->new(value => shift) }

sub value {
  my $element = shift;
  
  if (is_character($element)) {
    return $element->value;
  }
  elsif (is_complex($element)) {
    my $hash = {
      re => $element->re->value,
      im => $element->im->value
    };
    
    return $hash;
  }
  elsif (is_double($element)) {
    return $element->value;
  }
  elsif (is_integer($element)) {
    return $element->value;
  }
  elsif (is_logical($element)) {
    return $element->value;
  }
}

sub is_perl_number {
  my ($value) = @_;
  
  return unless defined $value;
  
  return B::svref_2object(\$value)->FLAGS & (B::SVp_IOK | B::SVp_NOK) 
        && 0 + $value eq $value
        && $value * 0 == 0
}

my %numeric_ops_h = map { $_ => 1} (qw#+ - * / ** %#);
my %comparison_ops_h = map { $_ => 1} (qw/< <= > >= == !=/);
my @ops = (keys %numeric_ops_h, keys %comparison_ops_h);
my %character_comparison_ops = (
  '<' => 'lt',
  '<=' => 'le',
  '>' => 'gt',
  '>=' => 'ge',
  '==' => 'eq',
  '!=' => 'ne'
);

sub to_string {
  my $v1 = shift;
  
  if (is_na($v1)) {
    return 'NA';
  }
  elsif (is_character($v1)) {
    return $v1->value;
  }
  elsif (is_complex($v1)) {
    my $re = $v1->re;
    my $im = $v1->im;
    
    my $str = "$re";
    $str .= '+' if $im >= 0;
    $str .= $im . 'i';
  }
  elsif (is_double($v1)) {
    
    my $flag = $v1->flag;
    
    if (defined $v1->value) {
      return $v1->value . "";
    }
    elsif ($flag eq 'nan') {
      return 'NaN';
    }
    elsif ($flag eq 'inf') {
      return 'Inf';
    }
    elsif ($flag eq '-inf') {
      return '-Inf';
    }
  }
  elsif (is_integer($v1)) {
    return $v1->value . "";
  }
  elsif (is_logical($v1)) {
    return $v1->value ? 'TRUE' : 'FALSE'
  }
  else {
    croak "Invalid type";
  }
}

sub negation {
  my $v1 = shift;
  
  if (is_na($v1)) {
    return NA;
  }
  elsif (is_character($v1)) {
    croak 'argument is not interpretable as logical'
  }
  elsif (is_complex($v1)) {
    return complex(-$v1->re->value, im => -$v1->im->value);
  }
  elsif (is_double($v1)) {
    
    my $flag = $v1->flag;
    if (defined $v1->value) {
      return double(-$v1->value);
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
  elsif (is_integer($v1) || is_logical($v1)) {
    return integer(-$v1->value);
  }
  else {
    croak "Invalid type";
  }  
}

sub bool {
  my $v1 = shift;
  
  if (is_na($v1)) {
    croak "Error in bool context (a) { : missing value where TRUE/FALSE needed"
  }
  elsif (is_character($v1) || is_complex($v1)) {
    croak 'Error in -a : invalid argument to unary operator ';
  }
  elsif (is_double($v1)) {

    if (defined $v1->value) {
      return $v1->value;
    }
    else {
      if (is_infinite($v1)) {
        1;
      }
      # NaN
      else {
        croak 'argument is not interpretable as logical'
      }
    }
  }
  elsif (is_integer($v1) || is_logical($v1)) {
    return $v1->value;
  }
  else {
    croak "Invalid type";
  }  
}


sub add {
  my ($v1, $v2) = @_;
  
  return NA if is_na($v1) || is_na(v2);
  
  if (is_character($v1)) {
    croak "Error in a + b : non-numeric argument to binary operator";
  }
  elsif (is_complex($v1)) {
    my $re = add($v1->{re}, $v2->{re});
    my $im = add($v1->{im}, $v2->{im});
    
    return complex($re->value, $im->value);
  }
  elsif (is_double($v1)) {
    return NaN if is_nan($v1) || is_nan($v2);
    if (defined $v1->value) {
      if (defined $v2) {
        return double($v1->value + $v2->value);
      }
      elsif (is_positive_infinite($v2)) {
        return Inf;
      }
      elsif (is_negative_infinite($v2)) {
        return negativeInf;
      }
    }
    elsif (is_positive_infinite($v1)) {
      if (defined $v2) {
        return Inf;
      }
      elsif (is_positive_infinite($v2)) {
        return Inf;
      }
      elsif (is_negative_infinite($v2)) {
        return NaN;
      }
    }
    elsif (is_negative_infinite($v1)) {
      if (defined $v2) {
        return negativeInf;
      }
      elsif (is_positive_infinite($v2)) {
        return NaN;
      }
      elsif (is_negative_infinite($v2)) {
        return negativeInf;
      }
    }
  }
  elsif (is_integer($v1)) {
    return integer($v1->value + $v2->value);
  }
  elsif (is_logical($v1)) {
    return integer($v1->value + $v2->value);
  }
  else {
    croak "Invalid type";
  }
}

sub subtract {
  my ($v1, $v2) = @_;
  
  return NA if is_na($v1) || is_na(v2);
  
  if (is_character($v1)) {
    croak "Error in a + b : non-numeric argument to binary operator";
  }
  elsif (is_complex($v1)) {
    my $re = subtract($v1->{re}, $v2->{re});
    my $im = subtract($v1->{im}, $v2->{im});
    
    return complex_double($re, $im);
  }
  elsif (is_double($v1)) {
    return NaN if is_nan($v1) || is_nan($v2);
    if (defined $v1->value) {
      if (defined $v2) {
        return double($v1->value - $v2->value);
      }
      elsif (is_positive_infinite($v2)) {
        return negativeInf;
      }
      elsif (is_negative_infinite($v2)) {
        return Inf;
      }
    }
    elsif (is_positive_infinite($v1)) {
      if (defined $v2) {
        return Inf;
      }
      elsif (is_positive_infinite($v2)) {
        return NaN;
      }
      elsif (is_negative_infinite($v2)) {
        return Inf;
      }
    }
    elsif (is_negative_infinite($v1)) {
      if (defined $v2) {
        return negativeInf;
      }
      elsif (is_positive_infinite($v2)) {
        return negativeInf;
      }
      elsif (is_negative_infinite($v2)) {
        return NaN;
      }
    }
  }
  elsif (is_integer($v1)) {
    return integer($v1->value + $v2->value);
  }
  elsif (is_logical($v1)) {
    return integer($v1->value + $v2->value);
  }
  else {
    croak "Invalid type";
  }
}

sub multiply {
  my ($v1, $v2) = @_;
  
  return NA if is_na($v1) || is_na(v2);
  
  if (is_character($v1)) {
    croak "Error in a + b : non-numeric argument to binary operator";
  }
  elsif (is_complex($v1)) {
    my $re = double($v1->re->value * $v2->re->value - $v1->im->value * $v2->im->value);
    my $im = double($v1->re->value * $v2->im->value + $v1->im->value * $v2->re->value);
    
    return complex_double($re, $im);
  }
  elsif (is_double($v1)) {
    return NaN if is_nan($v1) || is_nan($v2);
    if (defined $v1->value) {
      if (defined $v2) {
        return double($v1->value * $v2->value);
      }
      elsif (is_positive_infinite($v2)) {
        if ($v1->value == 0) {
          return NaN;
        }
        elsif ($v1->value > 0) {
          return Inf;
        }
        elsif ($v1->value < 0) {
          return negativeInf;
        }
      }
      elsif (is_negative_infinite($v2)) {
        if ($v1->value == 0) {
          return NaN;
        }
        elsif ($v1->value > 0) {
          return negativeInf;
        }
        elsif ($v1->value < 0) {
          return Inf;
        }
      }
    }
    elsif (is_positive_infinite($v1)) {
      if (defined $v2) {
        if ($v2->value == 0) {
          return NaN;
        }
        elsif ($v2->value > 0) {
          return Inf;
        }
        elsif ($v2->value < 0) {
          return negativeInf;
        }
      }
      elsif (is_positive_infinite($v2)) {
        return Inf;
      }
      elsif (is_negative_infinite($v2)) {
        return negativeInf;
      }
    }
    elsif (is_negative_infinite($v1)) {
      if (defined $v2) {
        if ($v2->value == 0) {
          return NaN;
        }
        elsif ($v2->value > 0) {
          return negativeInf;
        }
        elsif ($v2->value < 0) {
          return Inf;
        }
      }
      elsif (is_positive_infinite($v2)) {
        return negativeInf;
      }
      elsif (is_negative_infinite($v2)) {
        return Inf;
      }
    }
  }
  elsif (is_integer($v1)) {
    return integer($v1->value * $v2->value);
  }
  elsif (is_logical($v1)) {
    return integer($v1->value * $v2->value);
  }
  else {
    croak "Invalid type";
  }
}

sub divide {
  my ($v1, $v2) = @_;
  
  return NA if is_na($v1) || is_na(v2);
  
  if (is_character($v1)) {
    croak "Error in a + b : non-numeric argument to binary operator";
  }
  elsif (is_complex($v1)) {
    my $v3 = $v1 * conj($v2);
    my $abs2 = double($v2->re->value ** 2 + $v2->im->value ** 2);
    my $re = $v3->re / $abs2;
    my $im = $v3->im / $abs2;
    
    return complex_double($re, $im);
  }
  elsif (is_double($v1)) {
    return NaN if is_nan($v1) || is_nan($v2);
    if (defined $v1->value) {
      if ($v1->value == 0) {
        if (defined $v2) {
          if ($v2->value == 0) {
            return NaN;
          }
          else {
            return double(0)
          }
        }
        elsif (is_infinite($v2)) {
          return double(0);
        }
      }
      elsif ($v1->value > 0) {
        if (defined $v2) {
          if ($v2->value == 0) {
            return Inf;
          }
          else {
            return double($v1->value / $v2->value);
          }
        }
        elsif (is_infinite($v2)) {
          return double(0);
        }
      }
      elsif ($v1->value < 0) {
        if (defined $v2) {
          if ($v2->value == 0) {
            return negativeInf;
          }
          else {
            return double($v1->value / $v2->value);
          }
        }
        elsif (is_infinite($v2)) {
          return double(0);
        }
      }
    }
    elsif (is_positive_infinite($v1)) {
      if (defined $v2) {
        if ($v2->value >= 0) {
          return Inf;
        }
        elsif ($v2->value < 0) {
          return negativeInf;
        }
      }
      elsif (is_infinite($v2)) {
        return NaN;
      }
    }
    elsif (is_negative_infinite($v1)) {
      if (defined $v2) {
        if ($v2->value >= 0) {
          return negativeInf;
        }
        elsif ($v2->value < 0) {
          return Inf;
        }
      }
      elsif (is_infinite($v2)) {
        return NaN;
      }
    }
  }
  elsif (is_integer($v1)) {
    if ($v1->value == 0) {
      if ($v2->value == 0) {
        return NaN;
      }
      else {
        return double(0);
      }
    }
    elsif ($v1->value > 0) {
      if ($v2->value == 0) {
        return Inf;
      }
      else  {
        return double($v1->value / $v2->value);
      }
    }
    elsif ($v1->value < 0) {
      if ($v2->value == 0) {
        return negativeInf;
      }
      else {
        return double($v1->value / $v2->value);
      }
    }
  }
  elsif (is_logical($v1)) {
    if ($v1->value == 0) {
      if ($v2->value == 0) {
        return NaN;
      }
      elsif ($v2->value == 1) {
        return double(0);
      }
    }
    elsif ($v1->value == 1) {
      if ($v2->value == 0) {
        return Inf;
      }
      elsif ($v2->value == 1)  {
        return double(1);
      }
    }
  }
  else {
    croak "Invalid type";
  }
}

sub raise {
  my ($v1, $v2) = @_;
  
  return NA if is_na($v1) || is_na(v2);
  
  if (is_character($v1)) {
    croak "Error in a + b : non-numeric argument to binary operator";
  }
  elsif (is_complex($v1)) {
    my $v1_c = Math::Complex->make($v1->re->value, $v1->im->value);
    my $v2_c = Math::Complex->make($v2->re->value, $v2->im->value);
    
    my $v3_c = $v1_c ** $v2_c;
    my $re = Math::Complex::Re($v3_c);
    my $im = Math::Complex::Im($v3_c);
    
    return complex($re, $im);
  }
  elsif (is_double($v1)) {
    return NaN if is_nan($v1) || is_nan($v2);
    if (defined $v1->value) {
      if ($v1->value == 0) {
        if (defined $v2) {
          if ($v2->value == 0) {
            return double(1);
          }
          elsif ($v2->value > 0) {
            return double(0);
          }
          elsif ($v2->value < 0) {
            return Inf;
          }
        }
        elsif (is_positive_infinite($v2)) {
          return double(0);
        }
        elsif (is_negative_infinite($v2)) {
          return Inf
        }
      }
      elsif ($v1->value > 0) {
        if (defined $v2) {
          if ($v2->value == 0) {
            return double(1);
          }
          else {
            return double($v1->value ** $v2->value);
          }
        }
        elsif (is_positive_infinite($v2)) {
          if ($v1->value < 1) {
            return double(0);
          }
          elsif ($v1->value == 1) {
            return double(1);
          }
          elsif ($v1->value > 1) {
            return Inf;
          }
        }
        elsif (is_negative_infinite($v2)) {
          if ($v1->value < 1) {
            return double(0);
          }
          elsif ($v1->value == 1) {
            return double(1);
          }
          elsif ($v1->value > 1) {
            return double(0);
          }
        }
      }
      elsif ($v1->value < 0) {
        if (defined $v2) {
          if ($v2->value == 0) {
            return double(-1);
          }
          else {
            return double($v1->value ** $v2->value);
          }
        }
        elsif (is_positive_infinite($v2)) {
          if ($v1->value > -1) {
            return double(0);
          }
          elsif ($v1->value == -1) {
            return double(-1);
          }
          elsif ($v1->value < -1) {
            return negativeInf;
          }
        }
        elsif (is_negative_infinite($v2)) {
          if ($v1->value > -1) {
            return Inf;
          }
          elsif ($v1->value == -1) {
            return double(-1);
          }
          elsif ($v1->value < -1) {
            return double(0);
          }
        }
      }
    }
    elsif (is_positive_infinite($v1)) {
      if (defined $v2) {
        if ($v2->value == 0) {
          return double(1);
        }
        elsif ($v2->value > 0) {
          return Inf;
        }
        elsif ($v2->value < 0) {
          return double(0);
        }
      }
      elsif (is_positive_infinite($v2)) {
        return Inf;
      }
      elsif (is_negative_infinite($v2)) {
        return double(0);
      }
    }
    elsif (is_negative_infinite($v1)) {
      if (defined $v2) {
        if ($v2->value == 0) {
          return double(-1);
        }
        elsif ($v2->value > 0) {
          return negativeInf;
        }
        elsif ($v2->value < 0) {
          return double(0);
        }
      }
      elsif (is_positive_infinite($v2)) {
        return negativeInf;
      }
      elsif (is_negative_infinite($v2)) {
        return double(0);
      }
    }
  }
  elsif (is_integer($v1)) {
    if ($v1->value == 0) {
      if ($v2->value == 0) {
        return double(1);
      }
      elsif ($v2->value > 0) {
        return double(0);
      }
      elsif ($v2->value < 0) {
        return Inf;
      }
    }
    elsif ($v1->value > 0) {
      if ($v2->value == 0) {
        return double(1);
      }
      else {
        return double($v1->value ** $v2->value);
      }
    }
    elsif ($v1->value < 0) {
      if ($v2->value == 0) {
        return double(-1);
      }
      else {
        return double($v1->value ** $v2->value);
      }
    }
  }
  elsif (is_logical($v1)) {
    if ($v1->value == 0) {
      if ($v2->value == 0) {
        return double(1);
      }
      elsif ($v2->value == 1) {
        return double(0);
      }
    }
    elsif ($v1->value ==  1) {
      if ($v2->value == 0) {
        return double(1);
      }
      elsif ($v2->value == 1) {
        return double(1);
      }
    }
  }
  else {
    croak "Invalid type";
  }
}

sub remainder {
  my ($v1, $v2) = @_;
  
  return NA if is_na($v1) || is_na(v2);
  
  if (is_character($v1)) {
    croak "Error in a + b : non-numeric argument to binary operator";
  }
  elsif (is_complex($v1)) {
    croak "unimplemented complex operation";
  }
  elsif (is_double($v1)) {
    return NaN if is_nan($v1) || is_nan($v2) || is_infinite($v1) || is_infinite($v2);
    
    if ($v2->value == 0) {
      return NaN;
    }
    else {
      my $v3_value = $v1->value - POSIX::floor($v1->value/$v2->value) * $v2->value;
      return double($v3_value);
    }
  }
  elsif (is_integer($v1)) {
    if ($v2->value == 0) {
      return NaN;
    }
    else {
      return double($v1 % $v2);
    }
  }
  elsif (is_logical($v1)) {
    if ($v2->value == 0) {
      return NaN;
    }
    else {
      return double($v1->value % $v2->value);
    }
  }
  else {
    croak "Invalid type";
  }
}

sub conj {
  my $val = shift;
  
  if (is_complex($val)) {
    return complex($val->re, Rstats::Util::negation($val->im));
  }
  else {
    croak 'Invalid type';
  }
}

sub more_than {
  my ($v1, $v2) = @_;
  
  return NA if is_na($v1) || is_na(v2);
  
  if (is_character($v1)) {
    return $v1->value gt $v2->value ? TRUE : FALSE;
  }
  elsif (is_complex($v1)) {
    croak "invalid comparison with complex values";
  }
  elsif (is_double($v1)) {
    return NA if is_nan($v1) || is_nan($v2);
    if (defined $v1->value) {
      if (defined $v2) {
        return $v1->value > $v2->value ? TRUE : FALSE;
      }
      elsif (is_positive_infinite($v2)) {
        return FALSE;
      }
      elsif (is_negative_infinite($v2)) {
        return TRUE;
      }
    }
    elsif (is_positive_infinite($v1)) {
      if (defined $v2) {
        return TRUE;
      }
      elsif (is_positive_infinite($v2)) {
        return FALSE;
      }
      elsif (is_negative_infinite($v2)) {
        return TRUE;
      }
    }
    elsif (is_negative_infinite($v1)) {
      if (defined $v2) {
        return FALSE;
      }
      elsif (is_positive_infinite($v2)) {
        return FALSE;
      }
      elsif (is_negative_infinite($v2)) {
        return FALSE;
      }
    }
  }
  elsif (is_integer($v1)) {
    return $v1->value > $v2->value ? TRUE : FALSE;
  }
  elsif (is_logical($v1)) {
    return $v1->value > $v2->value ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

sub more_than_or_equal {
  my ($v1, $v2) = @_;
  
  return NA if is_na($v1) || is_na(v2);
  
  if (is_character($v1)) {
    return $v1->value ge $v2->value ? TRUE : FALSE;
  }
  elsif (is_complex($v1)) {
    croak "invalid comparison with complex values";
  }
  elsif (is_double($v1)) {
    return NA if is_nan($v1) || is_nan($v2);
    if (defined $v1->value) {
      if (defined $v2) {
        return $v1->value >= $v2->value ? TRUE : FALSE;
      }
      elsif (is_positive_infinite($v2)) {
        return FALSE;
      }
      elsif (is_negative_infinite($v2)) {
        return TRUE;
      }
    }
    elsif (is_positive_infinite($v1)) {
      if (defined $v2) {
        return TRUE;
      }
      elsif (is_positive_infinite($v2)) {
        return TRUE;
      }
      elsif (is_negative_infinite($v2)) {
        return TRUE;
      }
    }
    elsif (is_negative_infinite($v1)) {
      if (defined $v2) {
        return FALSE;
      }
      elsif (is_positive_infinite($v2)) {
        return FALSE;
      }
      elsif (is_negative_infinite($v2)) {
        return TRUE;
      }
    }
  }
  elsif (is_integer($v1)) {
    return $v1->value >= $v2->value ? TRUE : FALSE;
  }
  elsif (is_logical($v1)) {
    return $v1->value >= $v2->value ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

sub less_than {
  my ($v1, $v2) = @_;
  
  return NA if is_na($v1) || is_na(v2);
  
  if (is_character($v1)) {
    return $v1->value lt $v2->value ? TRUE : FALSE;
  }
  elsif (is_complex($v1)) {
    croak "invalid comparison with complex values";
  }
  elsif (is_double($v1)) {
    return NA if is_nan($v1) || is_nan($v2);
    if (defined $v1->value) {
      if (defined $v2) {
        return $v1->value < $v2->value ? TRUE : FALSE;
      }
      elsif (is_positive_infinite($v2)) {
        return TRUE;
      }
      elsif (is_negative_infinite($v2)) {
        return FALSE;
      }
    }
    elsif (is_positive_infinite($v1)) {
      if (defined $v2) {
        return FALSE;
      }
      elsif (is_positive_infinite($v2)) {
        return TRUE;
      }
      elsif (is_negative_infinite($v2)) {
        return FALSE;
      }
    }
    elsif (is_negative_infinite($v1)) {
      if (defined $v2) {
        return TRUE;
      }
      elsif (is_positive_infinite($v2)) {
        return TRUE;
      }
      elsif (is_negative_infinite($v2)) {
        return FALSE;
      }
    }
  }
  elsif (is_integer($v1)) {
    return $v1->value < $v2->value ? TRUE : FALSE;
  }
  elsif (is_logical($v1)) {
    return $v1->value < $v2->value ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

sub less_than_or_equal {
  my ($v1, $v2) = @_;
  
  return NA if is_na($v1) || is_na(v2);
  
  if (is_character($v1)) {
    return $v1->value le $v2->value ? TRUE : FALSE;
  }
  elsif (is_complex($v1)) {
    croak "invalid comparison with complex values";
  }
  elsif (is_double($v1)) {
    return NA if is_nan($v1) || is_nan($v2);
    if (defined $v1->value) {
      if (defined $v2) {
        return $v1->value <= $v2->value ? TRUE : FALSE;
      }
      elsif (is_positive_infinite($v2)) {
        return TRUE;
      }
      elsif (is_negative_infinite($v2)) {
        return FALSE;
      }
    }
    elsif (is_positive_infinite($v1)) {
      if (defined $v2) {
        return FALSE;
      }
      elsif (is_positive_infinite($v2)) {
        return TRUE;
      }
      elsif (is_negative_infinite($v2)) {
        return FALSE;
      }
    }
    elsif (is_negative_infinite($v1)) {
      if (defined $v2) {
        return TRUE;
      }
      elsif (is_positive_infinite($v2)) {
        return TRUE;
      }
      elsif (is_negative_infinite($v2)) {
        return TRUE;
      }
    }
  }
  elsif (is_integer($v1)) {
    return $v1->value <= $v2->value ? TRUE : FALSE;
  }
  elsif (is_logical($v1)) {
    return $v1->value <= $v2->value ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

sub equal {
  my ($v1, $v2) = @_;
  
  return NA if is_na($v1) || is_na(v2);
  
  if (is_character($v1)) {
    return $v1->value eq $v2->value ? TRUE : FALSE;
  }
  elsif (is_complex($v1)) {
    return $v1->re->value == $v2->re->value && $v2->im->value == $v2->im->value;
  }
  elsif (is_double($v1)) {
    return NA if is_nan($v1) || is_nan($v2);
    if (defined $v1->value) {
      if (defined $v2) {
        return $v1->value == $v2->value;
      }
      elsif (is_positive_infinite($v2)) {
        return FALSE;
      }
      elsif (is_negative_infinite($v2)) {
        return FALSE;
      }
    }
    elsif (is_positive_infinite($v1)) {
      if (defined $v2) {
        return FALSE;
      }
      elsif (is_positive_infinite($v2)) {
        return TRUE;
      }
      elsif (is_negative_infinite($v2)) {
        return FALSE;
      }
    }
    elsif (is_negative_infinite($v1)) {
      if (defined $v2) {
        return FALSE;
      }
      elsif (is_positive_infinite($v2)) {
        return FALSE;
      }
      elsif (is_negative_infinite($v2)) {
        return TRUE;
      }
    }
  }
  elsif (is_integer($v1)) {
    return $v1->value == $v2->value ? TRUE : FALSE;
  }
  elsif (is_logical($v1)) {
    return $v1->value == $v2->value ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

sub not_equal {
  my ($v1, $v2) = @_;
  
  return NA if is_na($v1) || is_na(v2);
  
  if (is_character($v1)) {
    return $v1->value ne $v2->value ? TRUE : FALSE;
  }
  elsif (is_complex($v1)) {
    return !($v1->re->value == $v2->re->value && $v2->im->value == $v2->im->value);
  }
  elsif (is_double($v1)) {
    return NA if is_nan($v1) || is_nan($v2);
    if (defined $v1->value) {
      if (defined $v2) {
        return $v1->value != $v2->value;
      }
      elsif (is_positive_infinite($v2)) {
        return TRUE;
      }
      elsif (is_negative_infinite($v2)) {
        return TRUE;
      }
    }
    elsif (is_positive_infinite($v1)) {
      if (defined $v2) {
        return TRUE;
      }
      elsif (is_positive_infinite($v2)) {
        return FALSE;
      }
      elsif (is_negative_infinite($v2)) {
        return TRUE;
      }
    }
    elsif (is_negative_infinite($v1)) {
      if (defined $v2) {
        return TRUE;
      }
      elsif (is_positive_infinite($v2)) {
        return TRUE;
      }
      elsif (is_negative_infinite($v2)) {
        return FALSE;
      }
    }
  }
  elsif (is_integer($v1)) {
    return $v1->value != $v2->value ? TRUE : FALSE;
  }
  elsif (is_logical($v1)) {
    return $v1->value != $v2->value ? TRUE : FALSE;
  }
  else {
    croak "Invalid type";
  }
}

1;
