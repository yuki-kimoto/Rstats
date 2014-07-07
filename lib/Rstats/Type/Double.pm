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

sub negation {
  my $self = shift;
  
  my $flag = $self->flag;
  
  if (!$flag) {
    return Rstats::Type::Double->new(value => -$self->value);
  }
  elsif ($flag eq 'nan') {
    return Rstats::Util::NaN();
  }
  elsif ($flag eq 'inf') {
    return Rstats::Util::negativeInf();
  }
  elsif ($flag eq '-inf') {
    return Rstats::Util::Inf();
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
