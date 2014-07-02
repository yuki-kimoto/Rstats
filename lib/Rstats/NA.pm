package Rstats::NA;
use Object::Simple -base;

use overload
  '+' => \&_operator,
  '-' => \&_operator,
  '*' => \&_operator,
  '/' => \&_operator,
  '%' => \&_operator,
  'neg' => \&_operator,
  '**' => \&_operator,
  '<' => \&_operator,
  '<=' => \&_operator,
  '>' => \&_operator,
  '>=' => \&_operator,
  '==' => \&_operator,
  '!=' => \&_operator,
  '""' => \&to_string,
  fallback => 1;

my $na = Rstats::NA->new;

sub NA { $na }

sub _operator { $na }

sub to_string { 'NA' }

sub is_na {
  my ($self, $value) = @_;
  
  return ref $value eq 'Rstats::NA' ? Rstats::Logical->TRUE : Rstats::Logical->FALSE;
}

1;
