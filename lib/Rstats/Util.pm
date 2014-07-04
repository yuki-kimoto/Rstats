package Rstats::Util;

use strict;
use warnings;
use Carp 'croak';
use Rstats::Type::NA;
use Rstats::Type::Logical;
use Rstats::Type::Complex;
use Rstats::Type::Character;
use Rstats::Type::Integer;

my $true = Rstats::Type::Logical->new(logical => 1);
my $false = Rstats::Type::Logical->new(logical => 0);
my $na = Rstats::Type::NA->new;
my $nan = Rstats::Type::Double->new(type => 'nan');
my $inf = Rstats::Type::Double->new(type => 'inf');
my $inf_minus = Rstats::Type::Double->new(type => '-inf');

sub true { $true }
sub false { $false }
sub na { $na }
sub nan { $nan }
sub inf { $inf }
sub inf_minus { $inf_minus }

sub is_nan { $_[0] == $nan }
sub is_na { $_[0] == $na }
sub is_infinite { $_[0] == $inf }
sub is_finite {
  return is_integer($_[0]) || is_double($_[0]) && 
}
sub is_integer { ref $_[0] eq 'Rstats::Type::Integer' }
sub is_double { ref $_[0] eq 'Rstats::Type::Double' }
sub is_complex { ref $_[0] eq 'Rstats::Type::Complex' }
sub is_character { ref $_[0] eq 'Rstats::Type::Character' }
sub is_logical { ref $_[0] eq 'Rstats::Type::Logical' } 

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

sub add { shift->_operation($type, '+', @_) }

sub subtract { shift->_operation($type, '-', @_) }

sub multiply { shift->_operation($type, '*', @_) }

sub divide { shift->_operation($type, '/', @_) }

sub raise { shift->_operation($type, '**', @_) }

sub remainder { shift->_operation($type, '%', @_) }

sub add_inf {
  my ($value1, $value2) = @_;
  
  if (ref $value1 eq 'Rstats::Inf') {
    
  }
  else {
    
  }
}

sub operation {
  my ($op, $value1, $value2) = @_;
  
  if (ref $value1 eq 'Rstats::NA' || ref $value2 eq 'Rstats::NA') {
    return Rstats::NA->NA;
  }
  elsif (ref $value1 eq 'Rstats::NaN' || ref $value2 eq 'Rstats::NaN') {
    if ($numeric_ops_h{$op}) {
      return Rstats::NaN->NaN;
    }
    else {
      return Rstats::NA->NA;
    }
  }
  else {
    if ($numeric_ops_h{$op}) {
      croak "Error in a + b : non-numeric argument to binary operator"
        if $type eq 'character';
      
      if ($type eq 'logical') {
        if (ref $value1 eq 'Rstats::Logical') {
          $value1 = $value1->{logical} ? 1 : 0;
        }
        if (ref $value2 eq 'Rstats::Logical') {
          $value2 = $value2->{logical} ? 1 : 0;
        }
      }
      
      if ($type eq 'complex') {
        my $re = $value1->{re} + $value2->{re};
        my $im = $value1->{im} + $value2->{im};
        
        return Rstats::Complex->new(re => $re, im => $im);
      }
      elsif ($type eq 'numeric' || $type eq 'integer' || $type eq 'logical') {
        return $value1 + $value2;
      }
    }
    else {
      
    }
    if ($op eq '+') {
      if ($type eq 'character') {
        
      }
      elsif ($type eq 'complex') {
        
      }
      elsif ($type eq 'numeric') {
        
      }
      elsif ($type eq 'integer') {
        
      }
      elsif ($type eq 'logical') {
        
      }
    }
    elsif ($op eq '-') {
      
    }
    elsif ($op eq '*') {
      
    }
    elsif ($op eq '/') {
      
    }
    elsif ($op eq '**') {
      
    }
    elsif ($op eq '%') {
      
    }
    elsif ($op eq '==') {
      
    }
    elsif ($op eq '!=') {
      
    }
    elsif ($op eq '<') {
      
    }
    elsif ($op eq '<=') {
      
    }
    elsif ($op eq '>') {
      
    }
    elsif ($op eq '>=') {
      
    }
  }
}

sub is_na {
  my $value = shift;
  
  return ref $value eq 'Rstats::NA';
}

# Complex
sub add { shift->_operation('+', @_) }
sub subtract { shift->_operation('-', @_) }
sub multiply { shift->_operation('*', @_) }
sub divide { shift->_operation('/', @_) }
sub raise { shift->_operation('**', @_) }

sub _operation {
  my ($self, $op, $data, $reverse) = @_;

  my $z1;
  my $z2;
  if (ref $data eq 'Rstats::Complex') {
    $z1 = $self;
    $z2 = $data;
  }
  else {
    if ($reverse) {
      $z1 = Rstats::Complex->new(re => $data);
      $z2 = $self;
    }
    else {
      $z1 = $self;
      $z2 = Rstats::Complex->new(re => $data);
    }
  }
  
  my $z3 = Rstats::Complex->new;
  if ($op eq '+') {
    $z3->{re} = $z1->{re} + $z2->{re};
    $z3->{im} = $z1->{im} + $z2->{im};
  }
  elsif ($op eq '-') {
    $z3->{re} = $z1->{re} - $z2->{re};
    $z3->{im} = $z1->{im} - $z2->{im};
  }
  elsif ($op eq '*') {
    $z3->{re} = $z1->{re} * $z2->{re} - $z1->{im} * $z2->{im};
    $z3->{im} = $z1->{re} * $z2->{im} + $z1->{im} * $z2->{re};
  }
  elsif ($op eq '/') {
    $z3 = $z1 * $z2->conj;
    my $abs2 = $z2->{re} ** 2 + $z2->{im} ** 2;
    $z3->{re} = $z3->{re} / $abs2;
    $z3->{im} = $z3->{im} / $abs2;
  }
  elsif ($op eq '**') {
    my $z1_c = Math::Complex->make($z1->{re}, $z1->{im});
    my $z2_c = Math::Complex->make($z2->{re}, $z2->{im});
    my $z3_c = $z1_c ** $z2_c;
    $z3->{re} = Math::Complex::Re($z3_c);
    $z3->{im} = Math::Complex::Im($z3_c);
  }
  elsif ($op eq '==') {
    return $z1->re == $z2->re && $z1->im == $z2->im ? Rstats->TRUE : Rstats->FALSE;
  }
  elsif ($op eq '!=') {
    return $z1->re == $z2->re && $z1->im == $z2->im ? Rstats->FALSE : Rstats->TRUE;
  }
  
  return $z3;
}

sub abs {
  my $self = shift;
  
  return sqrt($self->{re} ** 2 + $self->{im} ** 2);
}

sub conj {
  my $self = shift;
  
  return Rstats::Complex->new(re => $self->{re}, im => -$self->{im});
}

# End Complex

sub is_nan {
  my $value = shift;
  
  return ref $value eq 'Rstats::NaN';
}

sub is_numeric {
  my ($self, $value) = @_;
  
  return unless defined $value;
  
  return B::svref_2object(\$value)->FLAGS & (B::SVp_IOK | B::SVp_NOK) 
        && 0 + $value eq $value
        && $value * 0 == 0
}

