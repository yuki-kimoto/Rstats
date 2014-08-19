package Rstats::::Container::Array;
use Rstats::Container -base;

use Rstats::ArrayUtil;

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

sub clone_without_elements {
  my ($a1, %opt) = @_;
  
  my $a2 = Rstats::::Container::Array->new;
  $a2->{type} = $a1->{type};
  $a2->{names} = [@{$a1->{names} || []}];
  $a2->{rownames} = [@{$a1->{rownames} || []}];
  $a2->{colnames} = [@{$a1->{colnames} || []}];
  $a2->{dimnames} = $a1->{dimnames};

  $a2->{dim} = [@{$a1->{dim} || []}];
  $a2->{elements} = $opt{elements} ? $opt{elements} : [];
  
  return $a2;
}

sub is_array { Rstats::ArrayUtil::TRUE() }

sub is_list { Rstats::ArrayUtil::FALSE() }

sub is_data_frame { Rstats::ArrayUtil::FALSE() }

sub length {
  my $self = shift;
  
  my $length = @{$self->elements};
  
  return Rstats::ArrayUtil::c($length);
}

sub type { Rstats::ArrayUtil::type(@_) }

sub bool { Rstats::ArrayUtil::bool(@_) }

sub element { Rstats::ArrayUtil::element(@_) }

sub inner_product {
  my ($self, $data, $reverse) = @_;
  
  # fix postion
  my ($a1, $a2) = $self->_fix_position($data, $reverse);
  
  return Rstats::ArrayUtil::inner_product($a1, $a2);
}

sub to_string { Rstats::ArrayUtil::to_string(@_) }

sub negation { Rstats::ArrayUtil::negation(@_) }

sub operation {
  my ($self, $op, $data, $reverse) = @_;
  
  # fix postion
  my ($a1, $a2) = $self->_fix_position($data, $reverse);
  
  return Rstats::ArrayUtil::operation($op, $a1, $a2);
}

sub values { Rstats::ArrayUtil::values(@_) }

sub value { Rstats::ArrayUtil::value(@_) }

sub at { Rstats::ArrayUtil::at(@_) }

sub get { Rstats::ArrayUtil::get(@_) }

sub set { Rstats::ArrayUtil::set(@_) }

sub _fix_position {
  my ($self, $data, $reverse) = @_;
  
  my $a1;
  my $a2;
  if (ref $data eq 'Rstats::::Container::Array') {
    $a1 = $self;
    $a2 = $data;
  }
  else {
    if ($reverse) {
      $a1 = Rstats::ArrayUtil::c($data);
      $a2 = $self;
    }
    else {
      $a1 = $self;
      $a2 = Rstats::ArrayUtil::c($data);
    }
  }
  
  return ($a1, $a2);
}

1;
