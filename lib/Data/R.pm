package Data::R;

our $VERSION = '0.01';

use Object::Simple -base;

use Data::R::Vector;

sub c {
  my ($self, $values) = @_;
  
  my $vector = Data::R::Vector->new(values => $values);
  
  return $vector;
}

1;

=head1 NAME

Data::R - R-like statistical library
