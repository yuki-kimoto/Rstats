package Rstats::Complex;
use Object::Simple -base;
use Carp 'croak';
use Rstats::Complex;
use Math::Complex;

use overload
  'neg' => \&negation,
  '+' => \&add,
  '-' => \&subtract,
  '*' => \&multiply,
  '/' => \&divide,
  '**' => \&raise;

has 're';
has 'im';

sub new {
  my $self = shift->SUPER::new(@_);
  
  $self->{re} = 0 unless defined $self->{re};
  $self->{im} = 0 unless defined $self->{im};
  
  return $self;
}

sub negation {
  my $self = shift;
  
  return Rstats::Complex->new(re => -$self->{re}, im => -$self->{im});
}

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

1;
