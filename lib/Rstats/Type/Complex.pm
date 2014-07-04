package Rstats::Type::Complex;
use Object::Simple -base;

use Carp 'croak';

use overload
  'bool' => \&bool,
  'neg' => \&negation,
  '""' => \&to_string;

has 're';
has 'im';

sub bool { croak 'argument is not interpretable as logical' }

sub negation {
  my $self = shift;
  
  return Rstats::Type::Complex->new(re => -$self->{re}, im => -$self->{im});
}

sub to_string {
  my $self = shift;
  
  my $re = $self->re;
  my $im = $self->im;
  
  my $str = "$re";
  $str .= '+' if $im >= 0;
  $str .= $im . 'i';
  
  return $str;
}

1;
