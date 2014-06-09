package Data::R::Array;
use Object::Simple -base;

has 'values';
has 'dim';

sub new {
  my $self = shift->SUPER::new(@_);
  
  $self->{values} ||= [];
  
  return $self;
}

sub get {
  my ($self, $idx) = @_;
  
  my $value = $self->{values}[$idx - 1];
  
  return $value;
}

sub set {
  my ($self, $idx, $value) = @_;
  
  $self->{values}[$idx - 1] = $value;
  
  return $self;  
}

sub to_string {
  
}

1;

