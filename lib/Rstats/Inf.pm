package Rstats::Inf;
use Object::Simple -base;

use overload
  '""' => \&to_string,
  'neg' => \&negation,
  fallback => 1;

has 'minus';

my $Inf = Rstats::Inf->new;
my $Inf_minus = Rstats::Inf->new(minus => 1);

sub Inf { $Inf }

sub negation {
  my $self = shift;
  
  if ($self == $Inf) {
    return $Inf_minus;
  }
  else {
    return $Inf;
  }
}

sub to_string {
  my $self = shift;
  
  if ($self->{minus}) {
    return '-Inf';
  }
  else {
    return 'Inf';
  }
}

1;

