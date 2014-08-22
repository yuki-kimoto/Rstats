package Rstats::Element::Double;
use Rstats::Element -base;

has type => 'double';
has 'flag';

sub value {
  my $self = shift;
  
  if ($self->is_positive_infinite) {
    return '__Inf__';
  }
  elsif ($self->is_negative_infinite) {
    return '__-Inf__';
  }
  elsif ($self->is_nan) {
    return '__NaN__';
  }
  else {
    $self->{value};
  }
}

1;
