package Rstats::Element::Logical;
use Rstats::Element -base;

use overload 'bool' => sub { shift->{value} },
  fallback => 1;

has type => 'logical';

sub value {
  my $self = shift;
  
  if ($self->{value}) {
    return '__TRUE__';
  }
  else {
    return '__FALSE__';
  }
}
1;
