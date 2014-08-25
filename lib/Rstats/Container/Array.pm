package Rstats::Container::Array;
use Rstats::Container -base;

use Rstats::ArrayAPI;
use Rstats::API;
use Carp 'croak', 'carp';

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
    return Rstats::ArrayAPI::c($length);
  }
}

sub dim {
  my $a1 = shift;
  
  if (@_) {
    my $a_dim = Rstats::ArrayAPI::to_array($_[0]);
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
    return Rstats::ArrayAPI::c($a1->{dim});
  }
}

sub clone_without_elements {
  my ($a1, %opt) = @_;
  
  my $a2 = Rstats::Container::Array->new;
  $a2->{type} = $a1->{type};
  $a2->{names} = [@{$a1->{names} || []}];
  $a2->{dimnames} = $a1->{dimnames};

  $a2->{dim} = [@{$a1->{dim} || []}];
  $a2->{elements} = $opt{elements} ? $opt{elements} : [];
  
  return $a2;
}

sub is_array { Rstats::ArrayAPI::TRUE() }

sub is_list { Rstats::ArrayAPI::FALSE() }

sub is_data_frame { Rstats::ArrayAPI::FALSE() }

sub length {
  my $self = shift;
  
  my $length = @{$self->elements};
  
  return Rstats::ArrayAPI::c($length);
}

sub type { Rstats::ArrayAPI::type(@_) }

sub bool {
  my $self = shift;
  
  my $length = @{$self->elements};
  if ($length == 0) {
    croak 'Error in if (a) { : argument is of length zero';
  }
  elsif ($length > 1) {
    carp 'In if (a) { : the condition has length > 1 and only the first element will be used';
  }
  
  my $element = element($self);
  
  return !!$element;
}

sub element { Rstats::ArrayAPI::element(@_) }

sub inner_product {
  my ($self, $data, $reverse) = @_;
  
  # fix postion
  my ($a1, $a2) = $self->_fix_position($data, $reverse);
  
  return Rstats::ArrayAPI::inner_product($a1, $a2);
}

sub to_string { Rstats::ArrayAPI::to_string(@_) }

sub negation { Rstats::ArrayAPI::negation(@_) }

sub operation {
  my ($self, $op, $data, $reverse) = @_;
  
  # fix postion
  my ($a1, $a2) = $self->_fix_position($data, $reverse);
  
  return Rstats::ArrayAPI::operation($op, $a1, $a2);
}

sub values {
  my $self = shift;
  
  if (@_) {
    my @elements = map { Rstats::API::element($_) } @{$_[0]};
    $self->{elements} = \@elements;
  }
  else {
    my @values = map { defined $_ ? $_->value : undef } @{$self->elements};
  
    return \@values;
  }
}

sub value {
  my $self = shift;
  
  my $e1 = $self->element(@_);
  
  return defined $e1 ? $e1->value : Rstats::API::NA;
}

sub at { Rstats::ArrayAPI::at(@_) }

sub get { Rstats::ArrayAPI::get(@_) }

sub set { Rstats::ArrayAPI::set(@_) }

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
      $a1 = Rstats::ArrayAPI::c($data);
      $a2 = $self;
    }
    else {
      $a1 = $self;
      $a2 = Rstats::ArrayAPI::c($data);
    }
  }
  
  return ($a1, $a2);
}

1;
