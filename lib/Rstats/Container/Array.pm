package Rstats::Container::Array;
use Rstats::Container -base;

use Rstats::API;
use Rstats::ArrayAPI;
use Rstats::Util;
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

my %types_h = map { $_ => 1 } qw/character complex numeric double integer logical/;

sub typeof {
  my $a1 = shift;
  
  my $type = $a1->{type};
  my $a2_elements = defined $type ? $type : "NULL";
  my $a2 = Rstats::ArrayAPI::c($a2_elements);
  
  return $a2;
}

sub mode {
  my $a1 = shift;
  
  if (@_) {
    my $type = $_[0];
    croak qq/Error in eval(expr, envir, enclos) : could not find function "as_$type"/
      unless $types_h{$type};
    
    if ($type eq 'numeric') {
      $a1->{type} = 'double';
    }
    else {
      $a1->{type} = $type;
    }
    
    return $a1;
  }
  else {
    my $type = $a1->{type};
    my $mode;
    if (defined $type) {
      if ($type eq 'integer' || $type eq 'double') {
        $mode = 'numeric';
      }
      else {
        $mode = $type;
      }
    }
    else {
      croak qq/could not find function "as_$type"/;
    }

    return Rstats::ArrayAPI::c($mode);
  }
}

sub is_finite {
  my $_a1 = shift;

  my $a1 = Rstats::ArrayAPI::to_array($_a1);
  
  my @a2_elements = map {
    !ref $_ || ref $_ eq 'Rstats::Type::Complex' || ref $_ eq 'Rstats::Logical' 
      ? Rstats::API::TRUE()
      : Rstats::API::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::ArrayAPI::array(\@a2_elements);
  $a2->mode('logical');
  
  return $a2;
}

sub is_infinite {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayAPI::to_array($_a1);
  
  my @a2_elements = map {
    ref $_ eq 'Rstats::Inf' ? Rstats::API::TRUE() : Rstats::API::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::ArrayAPI::c(\@a2_elements);
  $a2->mode('logical');
  
  return $a2;
}

sub is_na {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayAPI::to_array($_a1);
  
  my @a2_elements = map {
    ref $_ eq  'Rstats::Type::NA' ? Rstats::API::TRUE() : Rstats::API::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::ArrayAPI::array(\@a2_elements);
  $a2->mode('logical');
  
  return $a2;
}

sub is_nan {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayAPI::to_array($_a1);
  
  my @a2_elements = map {
    ref $_ eq  'Rstats::NaN' ? Rstats::API::TRUE() : Rstats::API::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::ArrayAPI::array(\@a2_elements);
  $a2->mode('logical');
  
  return $a2;
}

sub is_null {
  my $_a1 = shift;
  
  my $a1 = Rstats::ArrayAPI::to_array($_a1);
  
  my @a2_elements = [!@{$a1->elements} ? Rstats::API::TRUE() : Rstats::API::FALSE()];
  my $a2 = Rstats::ArrayAPI::array(\@a2_elements);
  $a2->mode('logical');
  
  return $a2;
}

sub as_matrix {
  my $a1 = shift;
  
  my $a1_dim_elements = $a1->dim_as_array->values;
  my $a1_dim_count = @$a1_dim_elements;
  my $a2_dim_elements = [];
  my $row;
  my $col;
  if ($a1_dim_count == 2) {
    $row = $a1_dim_elements->[0];
    $col = $a1_dim_elements->[1];
  }
  else {
    $row = 1;
    $row *= $_ for @$a1_dim_elements;
    $col = 1;
  }
  
  my $a2_elements = [@{$a1->elements}];
  
  return Rstats::ArrayAPI::matrix($a2_elements, $row, $col);
}

sub as_array {
  my $a1 = shift;
  
  my $a1_elements = [@{$a1->elements}];
  my $a1_dim_elements = [@{$a1->dim_as_array->values}];
  
  return $a1->array($a1_elements, $a1_dim_elements);
}

sub as_vector {
  my $a1 = shift;
  
  my $a1_elements = [@{$a1->elements}];
  
  return Rstats::ArrayAPI::c($a1_elements);
}

sub is_vector {
  my $a1 = shift;
  
  my $is = @{$a1->dim->elements} == 0 ? Rstats::API::TRUE() : Rstats::API::FALSE();
  
  return Rstats::ArrayAPI::c($is);
}

sub is_matrix {
  my $a1 = shift;

  my $is = @{$a1->dim->elements} == 2 ? Rstats::API::TRUE() : Rstats::API::FALSE();
  
  return Rstats::ArrayAPI::c($is);
}

sub is_numeric {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'double' || ($a1->{type} || '') eq 'integer'
    ? Rstats::API::TRUE() : Rstats::API::FALSE();
  
  return Rstats::ArrayAPI::c($is);
}

sub is_double {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'double' ? Rstats::API::TRUE() : Rstats::API::FALSE();
  
  return Rstats::ArrayAPI::c($is);
}

sub is_integer {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'integer' ? Rstats::API::TRUE() : Rstats::API::FALSE();
  
  return Rstats::ArrayAPI::c($is);
}

sub is_complex {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'complex' ? Rstats::API::TRUE() : Rstats::API::FALSE();
  
  return Rstats::ArrayAPI::c($is);
}

sub is_character {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'character' ? Rstats::API::TRUE() : Rstats::API::FALSE();
  
  return Rstats::ArrayAPI::c($is);
}

sub is_logical {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'logical' ? Rstats::API::TRUE() : Rstats::API::FALSE();
  
  return Rstats::ArrayAPI::c($is);
}

sub as {
  my ($a1, $type) = @_;
  
  if ($type eq 'character') {
    return as_character($a1);
  }
  elsif ($type eq 'complex') {
    return as_complex($a1);
  }
  elsif ($type eq 'double') {
    return as_double($a1);
  }
  elsif ($type eq 'numeric') {
    return as_numeric($a1);
  }
  elsif ($type eq 'integer') {
    return as_integer($a1);
  }
  elsif ($type eq 'logical') {
    return as_logical($a1);
  }
  else {
    croak "Invalid mode is passed";
  }
}

sub as_complex {
  my $a1 = shift;
  
  my $a1_elements = $a1->elements;
  my $a2 = $a1->clone_without_elements;
  my @a2_elements = map { $_->as('complex') } @$a1_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'complex';

  return $a2;
}

sub as_numeric { as_double(@_) }

sub as_double {
  my $a1 = shift;
  
  my $a1_elements = $a1->elements;
  my $a2 = $a1->clone_without_elements;
  my @a2_elements = map { $_->as('double') } @$a1_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'double';

  return $a2;
}

sub as_integer {
  my $a1 = shift;
  
  my $a1_elements = $a1->elements;
  my $a2 = $a1->clone_without_elements;
  my @a2_elements = map { $_->as_integer  } @$a1_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'integer';

  return $a2;
}

sub as_logical {
  my $a1 = shift;
  
  my $a1_elements = $a1->elements;
  my $a2 = $a1->clone_without_elements;
  my @a2_elements = map { $_->as_logical } @$a1_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'logical';

  return $a2;
}

sub as_character {
  my $a1 = shift;

  my $a1_elements = $a1->elements;
  my @a2_elements = map { $_->as_character } @$a1_elements;
  my $a2 = $a1->clone_without_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'character';

  return $a2;
}

sub at {
  my $self = shift;
  
  if (@_) {
    $self->{at} = [@_];
    
    return $self;
  }
  
  return $self->{at};
}

sub get {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $drop = $opt->{drop};
  $drop = 1 unless defined $drop;
  
  my @_indexs = @_;

  my $_indexs;
  if (@_indexs) {
    $_indexs = \@_indexs;
  }
  else {
    my $at = $self->at;
    $_indexs = ref $at eq 'ARRAY' ? $at : [$at];
  }
  $self->at($_indexs);
  
  if (ref $_indexs->[0] eq 'CODE') {
    my @elements2 = grep { $_indexs->[0]->() } @{$self->values};
    return Rstats::ArrayAPI::c(\@elements2);
  }
  
  my ($positions, $a2_dim) = Rstats::Util::parse_index($self, $drop, @$_indexs);
  
  my @a2_elements = map { $self->elements->[$_ - 1] ? $self->elements->[$_ - 1] : Rstats::API::NA() } @$positions;
  
  return Rstats::ArrayAPI::array(\@a2_elements, $a2_dim);
}

sub set {
  my ($self, $_a2) = @_;

  my $at = $self->at;
  my $_indexs = ref $at eq 'ARRAY' ? $at : [$at];

  my $a2 = Rstats::ArrayAPI::to_array($_a2);
  
  my ($positions, $a2_dim) = Rstats::Util::parse_index($self, 0, @$_indexs);
  
  my $self_elements = $self->elements;
  my $a2_elements = $a2->elements;
  for (my $i = 0; $i < @$positions; $i++) {
    my $pos = $positions->[$i];
    $self_elements->[$pos - 1] = $a2_elements->[(($i + 1) % @$positions) - 1];
  }
  
  return $self;
}

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
  
  return defined $e1 ? $e1->value : Rstats::API::NA();
}

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
