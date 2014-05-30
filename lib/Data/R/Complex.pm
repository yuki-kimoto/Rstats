package Data::R::Complex;
use Object::Simple -base;

use overload
  '+' => \&add,
  '-' => \&subtract,
  '*' => \&multiply,
  '/' => \&divide,
  'neg' => \&negation,
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
  my ($self, $data) = @_;

  my $c3 = Data::R::Complex->new;
  if (ref $data eq 'Data::R::Complex') {
    my $c2 = $data;
    $c3->re($self->re - $c2->re);
    $c3->im($self->im - $c2->im);
  }
  else {
    $c3->re($self->re - $data);
    $c3->im($self->im);
  }
  
  return $c3;
}

sub multiply {

}

sub divide {

}

sub raise {

}

1;
