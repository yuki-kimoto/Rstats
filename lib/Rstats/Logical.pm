package Rstats::Logical;
use Object::Simple -base;

use overload
  bool => \&bool,
  '==' => \&equal,
  '!=' => \&not_equal,
  '""' => \&to_string,
  fallback => 1;

has 'logical';

my $TURE = Rstats::Logical->new(logical => 1);
my $FALSE = Rstats::Logical->new(logical => 0);

sub TRUE { $TURE }

sub FALSE { $FALSE }

sub bool {
  my $self = shift;
  
  return $self->logical ? 1 : 0;
}

sub equal {
  my ($self, $logical) = @_;
  
  return $self == $logical;
}

sub not_equal {
  my ($self, $logical) = @_;
  
  return $self != $logical;
}

sub to_string {
  my $self = shift;
  
  return $self->logical ? 'TRUE' : 'FALSE';
}

1;
