package Rstats::Type::Double;
use Object::Simple -base;

use Carp 'croak';
require Rstats::Util;

use overload
  'bool' => \&bool,
  'neg' => \&negation,
  '""' => \&to_string;

has 'value';
has 'flag';

sub bool {
  my $self = shift;
  
  my $value = $self->value;
  if (defined $value) {
    $value == 0 ? 0 : 1;
  }
  else {
    # Inf, -Inf
    if (Rstats::Util::is_infinite($self)) {
      1;
    }
    # NaN
    else {
      croak 'argument is not interpretable as logical'
    }
  }
}

sub negation {
  my $self = shift;
  
  my $flag = $self->flag;
  
  if (!$flag) {
    return Rstats::Type::Double->new(value => -$self->value);
  }
  elsif ($flag eq 'nan') {
    return Rstats::Util::nan();
  }
  elsif ($flag eq 'inf') {
    return Rstats::Util::inf_minus();
  }
  elsif ($flag eq '-inf') {
    return Rstats::Util::inf();
  }
}

sub to_string {
  my $self = shift;
  
  my $flag = $self->flag;
  
  if (!$flag) {
    return $self->value . "";
  }
  elsif ($flag eq 'nan') {
    return 'NaN';
  }
  elsif ($flag eq 'inf') {
    return 'Inf';
  }
  elsif ($flag eq '-inf') {
    return '-Inf';
  }
}

1;
