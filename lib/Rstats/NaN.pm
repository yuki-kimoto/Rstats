package Rstats::NaN;
use Object::Simple -base;

use Rstats::NA;
use Rstats::Logical;
require Rstats::Array;

use overload
  '+' => \&_numeric_operator,
  '-' => \&_numeric_operator,
  '*' => \&_numeric_operator,
  '/' => \&_numeric_operator,
  '%' => \&_numeric_operator,
  'neg' => \&_numeric_operator,
  '**' => \&_numeric_operator,
  '<' => \&_comparison_operator,
  '<=' => \&_comparison_operator,
  '>' => \&_comparison_operator,
  '>=' => \&_comparison_operator,
  '==' => \&_comparison_operator,
  '!=' => \&_comparison_operator,
  '""' => \&to_string,
  fallback => 1;

my $nan = Rstats::NaN->new;

sub is_nan {
  my ($self, $value) = @_;
  
  return ref $value eq 'Rstats::NaN' ? Rstats::Logical->TRUE : Rstats::Logical->FALSE;
}

sub _comparison_operator {
  my ($self, $value) = @_;
  
  # Character
  if (!ref $value && !Rstats::Array->_is_numeric($value)) {
    return $value eq $nan ? Rstats::Logical->TRUE : Rstats::Logical->FALSE;
  }
  # Not Character
  else {
    return Rstats::NA->NA;
  }
}

sub _numeric_operator { $nan }

sub NaN { $nan }

sub to_string { 'NaN' }

1;
