package Rstats::Type::Double;
use Object::Simple -base;

use Carp 'croak';
require Rstats::Util;

use overload
  'bool' => \&bool,
  'neg' => \&negation,
  '""' => \&to_string;

has 'value';
has 'type';

sub bool { croak 'argument is not interpretable as logical' }

sub negation {
  my $self = shift;
  
  my $type = $self->type;
  
  if (!$type) {
    return Rstats::Type::Double->new(value => -$self->value);
  }
  elsif ($type eq 'nan') {
    return Rstats::Util::nan();
  }
  elsif ($type eq 'inf') {
    return Rstats::Util::inf_minus();
  }
  elsif ($type eq '-inf') {
    return Rstats::Util::inf();
  }
}

sub to_string {
  my $self = shift;
  
  my $type = $self->type;
  
  if (!$type) {
    return $self->value . "";
  }
  elsif ($type eq 'nan') {
    return 'NaN';
  }
  elsif ($type eq 'inf') {
    return 'Inf';
  }
  elsif ($type eq '-inf') {
    return '-Inf';
  }
}

1;
