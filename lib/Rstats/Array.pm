package Rstats::Array;
use Object::Simple -base;

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

sub elements { Rstats::ArrayUtil::elements(@_) }

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

sub clone_without_elements { Rstats::ArrayUtil::clone_without_elements(@_) }

sub values { Rstats::ArrayUtil::values(@_) }

sub value { Rstats::ArrayUtil::value(@_) }

sub at { Rstats::ArrayUtil::at(@_) }

sub get { Rstats::ArrayUtil::get(@_) }

sub set { Rstats::ArrayUtil::set(@_) }

sub _fix_position {
  my ($self, $data, $reverse) = @_;
  
  my $a1;
  my $a2;
  if (ref $data eq 'Rstats::Array') {
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

