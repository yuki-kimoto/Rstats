package Data::R::Complex;
use Object::Simple -base;
use Carp 'croak';
use Math::Complex ();

use overload
  'neg' => \&negation,
  '+' => \&add,
  '-' => \&subtract,
  '*' => \&multiply,
  '/' => \&divide,
  '**' => \&raise;

has data => sub { Math::Complex->make(0, 0) };

sub make {
  my $self = shift->SUPER::new;
  my ($re, $im) = @_;
  
  $re = 0 unless defined $re;
  $im = 0 unless defined $im;
  
  $self->data(Math::Complex->make($re, $im));
  
  return $self;
}

sub re { Math::Complex::Re(shift->data) }

sub im { Math::Complex::Im(shift->data) }

sub negation {
  my $self = shift;
  
  my $data1 = $self->data;
  my $data2 = -$data1;
  
  my $z = Data::R::Complex->new(data => $data2);
  
  return $z;
}

sub add {
  my ($self, $z2) = @_;
  
  my $data1 = $self->data;
  my $data2 = ref $z2 eq 'Data::R::Complex' ? $z2->data : $z2;
  
  my $data3 = $data1 + $data2;
  my $z3 = Data::R::Complex->new(data => $data3);
  
  return $z3;
}

sub subtract {
  my ($self, $z2, $reverse) = @_;
  
  my $data1 = $self->data;
  my $data2 = ref $z2 eq 'Data::R::Complex' ? $z2->data : $z2;
  
  my $data3;
  if ($reverse) {
    $data3 = $data2 - $data1;
  }
  else {
    $data3 = $data1 - $data2;
  }
  
  my $z3 = Data::R::Complex->new(data => $data3);
  
  return $z3;
}

sub multiply {
  my ($self, $z2) = @_;
  
  my $data1 = $self->data;
  my $data2 = ref $z2 eq 'Data::R::Complex' ? $z2->data : $z2;
  
  my $data3 = $data1 * $data2;
  my $z3 = Data::R::Complex->new(data => $data3);
  
  return $z3;
}

sub divide {
  my ($self, $z2, $reverse) = @_;
  
  my $data1 = $self->data;
  my $data2 = ref $z2 eq 'Data::R::Complex' ? $z2->data : $z2;
  
  my $data3;
  if ($reverse) {
    $data3 = $data2 / $data1;
  }
  else {
    $data3 = $data1 / $data2;
  }
  
  my $z3 = Data::R::Complex->new(data => $data3);
  
  return $z3;
}

sub raise {
  my ($self, $z2, $reverse) = @_;
  
  my $data1 = $self->data;
  my $data2 = ref $z2 eq 'Data::R::Complex' ? $z2->data : $z2;
  
  my $data3;
  if ($reverse) {
    $data3 = $data2 ** $data1;
  }
  else {
    $data3 = $data1 ** $data2;
  }
  
  my $z3 = Data::R::Complex->new(data => $data3);
  
  return $z3;
}


1;
