package Data::R;

our $VERSION = '0.01';

use Object::Simple -base;

use Data::R::Vector;
use List::Util;
use Carp 'croak';

sub c {
  my ($self, $values) = @_;
  
  my $vector = Data::R::Vector->new(values => $values);
  
  return $vector;
}

sub max {
  my ($self, $value) = @_;
  
  my $max;
  if (ref $value eq 'Data::R::Vector') {
    my $v = $value;
    my $v_values = $v->values;
    $max = List::Util::max(@$v_values);
  }
  else {
    croak 'Not implemented';
  }
  
  return $max;
}

sub min {
  my ($self, $value) = @_;
  
  my $min;
  if (ref $value eq 'Data::R::Vector') {
    my $v = $value;
    my $v_values = $v->values;
    $min = List::Util::min(@$v_values);
  }
  else {
    croak 'Not implemented';
  }
  
  return $min;
}

1;

=head1 NAME

Data::R - R-like statistical library

=head1 SYNOPSYS

  my $r = Data::R->new;
  
  # Vector
  my $v1 = $r->c([1, 2, 3]);
  my $v2 = $r->c([2, 3, 4]);
  my $v3 = $v1 + v2;
