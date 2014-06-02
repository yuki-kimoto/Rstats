package Data::R::Complex;
use Object::Simple -base;
use Carp 'croak';

use overload
  'neg' => \&negation,
  '+' => \&add,
  '-' => \&subtract,
  '*' => \&multiply,
  '/' => \&divide,
  '**' => \&raise;

has 're';
has 'im';

sub negation {
  my $self = shift;
  
  my $c2 = Data::R::Complex->new(re => - $self->re, im => - $self->im);
  
  return $c2;
}

sub add {
  my ($self, $data) = @_;

  my $c3 = Data::R::Complex->new;
  if (ref $data eq 'Data::R::Complex') {
    my $c2 = $data;
    $c3->re($self->re + $c2->re);
    $c3->im($self->im + $c2->im);
  }
  else {
    $c3->re($self->re + $data);
    $c3->im($self->im);
  }
  
  return $c3;
}

sub subtract {
  my ($self, $data, $reverse) = @_;

  my $c3 = Data::R::Complex->new;
  if (ref $data eq 'Data::R::Complex') {
    my $c2 = $data;
    $c3->re($self->re - $c2->re);
    $c3->im($self->im - $c2->im);
  }
  else {
    if ($reverse) {
      $c3->re($data - $self->re);
      $c3->im(-$self->im);
    }
    else {
      $c3->re($self->re - $data);
      $c3->im($self->im);
    }
  }
  
  return $c3;
}

sub multiply {
  my ($self, $data) = @_;

  my $c3 = Data::R::Complex->new;
  if (ref $data eq 'Data::R::Complex') {
    my $c2 = $data;
    
    my $re = $self->re * $c2->re - $self->im * $c2->im;
    my $im = $self->re * $c2->im + $c2->re * $self->im;
    $c3->re($re);
    $c3->im($im);
  }
  else {
    $c3->re($self->re * $data);
    $c3->im($self->im * $data);
  }
  
  return $c3;
}

sub divide {
  my ($self, $data, $reverse) = @_;

  my $c3 = Data::R::Complex->new;
  if (ref $data eq 'Data::R::Complex') {
    my $c2 = $data;
    
    my $re = ($self->re * $c2->re + $self->im * $c2->im)
      / ($c2->re ** 2 + $c2->im ** 2);
    
    my $im = ($self->im * $c2->re - $self->re * $c2->im)
      / ($c2->re ** 2 + $c2->im ** 2);
    
    $c3->re($re);
    $c3->im($im);
  }
  else {
    if ($reverse) {
      $c3->re(($data * $self->re) / ($self->re ** 2 + $self->im ** 2));
      $c3->im((-$data * $self->im) / ($self->re ** 2 + $self->im ** 2));
    }
    else {
      $c3->re($self->re / $data);
      $c3->im($self->im / $data);
    }
  }
  
  return $c3;
}

sub raise {
  my ($self, $data, $reverse) = @_;
  
  if (ref $data eq 'Data::R::Complex') {
    croak 'Not implemented';
  }
  else {
    if ($reverse) {
      croak 'Not implemented';
    }
    else {
      my $c2 = $self;
      if ($data > 1) {
        for (1 .. $data - 1) {
          $c2 = $c2 * $self;
        }
      }
      
      return $c2;
    }
  }
}

1;
