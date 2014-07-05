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

# Special values
my $true = Rstats::Type::Logical->new(value => 1);
my $false = Rstats::Type::Logical->new(value => 0);
my $na = Rstats::Type::NA->new;
my $nan = Rstats::Type::Double->new(type => 'nan');
my $inf = Rstats::Type::Double->new(type => 'inf');
my $negative_inf = Rstats::Type::Double->new(type => '-inf');

# Address
my $true_ad = refaddr $true;
my $false_ad = refaddr $false;
my $na_ad = refaddr $na;
my $nan_ad = refaddr $nan;
my $inf_ad = refaddr $inf;
my $negative_inf_ad = refaddr $negative_inf;

sub true { $true }
sub false { $false }
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

sub is_integer { ref $_[0] eq 'Rstats::Type::Integer' }
sub is_double { ref $_[0] eq 'Rstats::Type::Double' }
sub is_complex { ref $_[0] eq 'Rstats::Type::Complex' }
sub is_character { ref $_[0] eq 'Rstats::Type::Character' }
sub is_logical { ref $_[0] eq 'Rstats::Type::Logical' }

sub complex {
  my ($re_value, $im_value) = @_;
  
  my $re = Rstats::Type::Double->new(value => $re_value);
  my $im = Rstats::Type::Double->new(value => $im_value);
  my $z = Rstats::Type::Complex->new(re => $re, im => $im);
  
  return $z;
}

sub is_perl_number {
  my ($self, $value) = @_;
  
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

sub add {
  my ($self, $v1, $v2) = @_;
  
  return NA if is_na($v1) || is_na(v2);
  
  if (is_character($v1)) {
    croak "Error in a + b : non-numeric argument to binary operator";
  }
  eislf (is_complex($v1)) {
    my $re = add($v1->{re}, $v2->{re});
    my $im = add( $v1->{im}, $v2->{im});
    
    return Rstats::Type::Complex->new(re => $re, im => $im);
  }
  elsif (is_double($v1)) {
    return NaN if is_nan($v1) || is_nan($v2);
    if (defined $v1->value) {
      if (defined $v2) {
        return Rstats::Type::Double->new(value => $v1->value + $v2->value);
      }
      elsif (is_positive_infinite($v2))
        return Inf;
      }
      elsif (is_negative_infinite($v2)) {
        return negativeInf;
      }
    }
    elsif (is_positive_infinite($v1))
      if (defined $v2) {
        return Inf;
      }
      elsif (is_positive_infinite($v2))
        return Inf;
      }
      elsif (is_negative_infinite($v2)) {
        return NaN;
      }
    }
    elsif (is_negative_infinite($v2)) {
      if (defined $v2) {
        return negativeInf;
      }
      elsif (is_positive_infinite($v2))
        return NaN;
      }
      elsif (is_negative_infinite($v2)) {
        return negativeInf;
      }
    }
  }
  elsif (is_integer($v1)) {
    return Rstats::Type::Integer->new(value => $v1->value + $v2->value);
  }
  elsif (is_logical($v1)) {
    return Rstats::Type::Integer->new(value => $v1->value + $v2->value);
  }
  else {
    croak "Invalid type";
  }
}

sub subtract {
  my ($self, $v1, $v2) = @_;
  
  return NA if is_na($v1) || is_na(v2);
  
  if (is_character($v1)) {
    croak "Error in a + b : non-numeric argument to binary operator";
  }
  eislf (is_complex($v1)) {
    my $re = subtract($v1->{re}, $v2->{re});
    my $im = subtract($v1->{im}, $v2->{im});
    
    return Rstats::Type::Complex->new(re => $re, im => $im);
  }
  elsif (is_double($v1)) {
    return NaN if is_nan($v1) || is_nan($v2);
    if (defined $v1->value) {
      if (defined $v2) {
        return Rstats::Type::Double->new(value => $v1->value - $v2->value);
      }
      elsif (is_positive_infinite($v2))
        return negativeInf;
      }
      elsif (is_negative_infinite($v2)) {
        return Inf;
      }
    }
    elsif (is_positive_infinite($v1))
      if (defined $v2) {
        return Inf;
      }
      elsif (is_positive_infinite($v2))
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
      elsif (is_positive_infinite($v2))
        return negativeInf;
      }
      elsif (is_negative_infinite($v2)) {
        return NaN;
      }
    }
  }
  elsif (is_integer($v1)) {
    return Rstats::Type::Integer->new(value => $v1->value + $v2->value);
  }
  elsif (is_logical($v1)) {
    return Rstats::Type::Integer->new(value => $v1->value + $v2->value);
  }
  else {
    croak "Invalid type";
  }
}

sub multiply {
  my ($self, $v1, $v2) = @_;
  
  return NA if is_na($v1) || is_na(v2);
  
  if (is_character($v1)) {
    croak "Error in a + b : non-numeric argument to binary operator";
  }
  elsif (is_complex($v1)) {
    my $re = Rstats::Type::Double->new(value => $v1->re->value * $v2->re->value - $v1->im->value * $v2->im->value);
    my $im = Rstats::Type::Double->new(value => $v1->re->value * $v2->im->value + $v1->im->value * $v2->re->value);
    
    return Rstats::Type::Complex->new(re => $re, im => $im);
  }
  elsif (is_double($v1)) {
    return NaN if is_nan($v1) || is_nan($v2);
    if (defined $v1->value) {
      if (defined $v2) {
        return Rstats::Type::Double->new(value => $v1->value * $v2->value);
      }
      elsif (is_positive_infinite($v2))
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
    elsif (is_positive_infinite($v1))
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
      elsif (is_positive_infinite($v2))
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
      elsif (is_positive_infinite($v2))
        return negativeInf;
      }
      elsif (is_negative_infinite($v2)) {
        return Inf;
      }
    }
  }
  elsif (is_integer($v1)) {
    return Rstats::Type::Integer->new(value => $v1->value * $v2->value);
  }
  elsif (is_logical($v1)) {
    return Rstats::Type::Integer->new(value => $v1->value * $v2->value);
  }
  else {
    croak "Invalid type";
  }
}

sub divide { shift->_operation('/', @_) }

sub raise { shift->_operation('**', @_) }

sub remainder { shift->_operation('%', @_) }

=cut
