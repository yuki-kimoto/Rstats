package Rstats::Container::Array;
use Rstats::Container -base;

use Rstats::Function;
use Rstats::Util;
use Carp 'croak';

our @CARP_NOT = ('Rstats');

use overload
  bool => \&bool,
  '+' => sub { shift->operation('add', @_) },
  '-' => sub { shift->operation('subtract', @_) },
  '*' => sub { shift->operation('multiply', @_) },
  '/' => sub { shift->operation('divide', @_) },
  '%' => sub { shift->operation('remainder', @_) },
  'neg' => sub { shift->negation(@_) },
  '**' => sub { shift->operation('raise', @_) },
  'x' => sub { shift->inner_product(@_) },
  '<' => sub { shift->operation('less_than', @_) },
  '<=' => sub { shift->operation('less_than_or_equal', @_) },
  '>' => sub { shift->operation('more_than', @_) },
  '>=' => sub { shift->operation('more_than_or_equal', @_) },
  '==' => sub { shift->operation('equal', @_) },
  '!=' => sub { shift->operation('not_equal', @_) },
  '""' => sub { shift->to_string(@_) },
  fallback => 1;

sub dim_as_array {
  my $a1 = shift;
  
  if (@{dim($a1)->elements}) {
    return dim($a1);
  }
  else {
    my $length = @{$a1->elements};
    return Rstats::Function::c($length);
  }
}

sub dim {
  my $a1 = shift;
  
  if (@_) {
    my $a_dim = Rstats::Function::to_array($_[0]);
    my $a1_length = @{$a1->elements};
    my $a1_lenght_by_dim = 1;
    $a1_lenght_by_dim *= $_ for @{$a_dim->values};
    
    if ($a1_length != $a1_lenght_by_dim) {
      croak "dims [product $a1_lenght_by_dim] do not match the length of object [$a1_length]";
    }
  
    $a1->{dim} = $a_dim->elements;
    
    return $a1;
  }
  else {
    return Rstats::Function::c($a1->{dim});
  }
}

sub clone_without_elements {
  my ($a1, %opt) = @_;
  
  my $a2 = Rstats::Container::Array->new;
  $a2->{type} = $a1->{type};
  $a2->{names} = [@{$a1->{names} || []}];
  $a2->{rownames} = [@{$a1->{rownames} || []}];
  $a2->{colnames} = [@{$a1->{colnames} || []}];
  $a2->{dimnames} = $a1->{dimnames};

  $a2->{dim} = [@{$a1->{dim} || []}];
  $a2->{elements} = $opt{elements} ? $opt{elements} : [];
  
  return $a2;
}

sub is_array { Rstats::Function::TRUE() }

sub is_list { Rstats::Function::FALSE() }

sub is_data_frame { Rstats::Function::FALSE() }

sub length {
  my $self = shift;
  
  my $length = @{$self->elements};
  
  return Rstats::Function::c($length);
}

sub type { Rstats::Function::type(@_) }

sub bool { Rstats::Function::bool(@_) }

sub element { Rstats::Function::element(@_) }

sub inner_product {
  my ($self, $data, $reverse) = @_;
  
  # fix postion
  my ($a1, $a2) = $self->_fix_position($data, $reverse);
  
  return Rstats::Function::inner_product($a1, $a2);
}

sub to_string { Rstats::Function::to_string(@_) }

sub negation { Rstats::Function::negation(@_) }

sub operation {
  my ($self, $op, $data, $reverse) = @_;
  
  # fix postion
  my ($a1, $a2) = $self->_fix_position($data, $reverse);
  
  return Rstats::Function::operation($op, $a1, $a2);
}

sub values {
  my $a1 = shift;
  
  if (@_) {
    my @elements = map { Rstats::Util::element($_) } @{$_[0]};
    $a1->{elements} = \@elements;
  }
  else {
    my @values = map { Rstats::Util::value($_) } @{$a1->elements};
  
    return \@values;
  }
}

sub value { Rstats::Util::value(element(@_)) }

sub at { Rstats::Function::at(@_) }

sub get { Rstats::Function::get(@_) }

sub set { Rstats::Function::set(@_) }

sub _fix_position {
  my ($self, $data, $reverse) = @_;
  
  my $a1;
  my $a2;
  if (ref $data eq 'Rstats::Container::Array') {
    $a1 = $self;
    $a2 = $data;
  }
  else {
    if ($reverse) {
      $a1 = Rstats::Function::c($data);
      $a2 = $self;
    }
    else {
      $a1 = $self;
      $a2 = Rstats::Function::c($data);
    }
  }
  
  return ($a1, $a2);
}

1;
