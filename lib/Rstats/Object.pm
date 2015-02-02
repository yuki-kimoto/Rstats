package Rstats::Object;
use Object::Simple -base;

use overload
  '+' => sub { Rstats::ArrayFunc::add(undef(), Rstats::ArrayFunc::_fix_pos(undef(), @_)) },
  '-' => sub { Rstats::ArrayFunc::subtract(undef(), Rstats::ArrayFunc::_fix_pos(undef(), @_)) },
  '*' => sub { Rstats::ArrayFunc::multiply(undef(), Rstats::ArrayFunc::_fix_pos(undef(), @_)) },
  '/' => sub { Rstats::ArrayFunc::divide(undef(), Rstats::ArrayFunc::_fix_pos(undef(), @_)) },
  '%' => sub { Rstats::ArrayFunc::remainder(undef(), Rstats::ArrayFunc::_fix_pos(undef(), @_)) },
  '**' => sub { Rstats::ArrayFunc::pow(undef(), Rstats::ArrayFunc::_fix_pos(undef(), @_)) },
  '<' => sub { Rstats::ArrayFunc::less_than(undef(), Rstats::ArrayFunc::_fix_pos(undef(), @_)) },
  '<=' => sub { Rstats::ArrayFunc::less_than_or_equal(undef(), Rstats::ArrayFunc::_fix_pos(undef(), @_)) },
  '>' => sub { Rstats::ArrayFunc::more_than(undef(), Rstats::ArrayFunc::_fix_pos(undef(), @_)) },
  '>=' => sub { Rstats::ArrayFunc::more_than_or_equal(undef(), Rstats::ArrayFunc::_fix_pos(undef(), @_)) },
  '==' => sub { Rstats::ArrayFunc::equal(undef(), Rstats::ArrayFunc::_fix_pos(undef(), @_)) },
  '!=' => sub { Rstats::ArrayFunc::not_equal(undef(), Rstats::ArrayFunc::_fix_pos(undef(), @_)) },
  '&' => sub { Rstats::ArrayFunc::and(undef(), Rstats::ArrayFunc::_fix_pos(undef(), @_)) },
  '|' => sub { Rstats::ArrayFunc::or(undef(), Rstats::ArrayFunc::_fix_pos(undef(), @_)) },
  'x' => sub { Rstats::ArrayFunc::inner_product(undef(), Rstats::ArrayFunc::_fix_pos(undef(), @_)) },
  bool => sub { Rstats::ArrayFunc::bool(undef(), @_) },
  'neg' => sub { Rstats::ArrayFunc::negation(undef(), @_) },
  '""' => sub { shift->to_string },
  fallback => 1;

use Rstats::Func;

has 'r';
has list => sub { [] };
has 'vector';

sub AUTOLOAD {
  my $self = shift;

  my ($package, $method) = split /::(\w+)$/, our $AUTOLOAD;
  Carp::croak "Undefined subroutine &${package}::$method called"
    unless Scalar::Util::blessed $self && $self->isa(__PACKAGE__);

  my $r = $self->r;

  # Call helper with current controller
  Carp::croak qq{Can't locate object method "$method" via package "$package"}
    unless $r && (my $helper = $r->helpers->{$method});
  
  return $helper->($r, $self, @_);
}

sub DESTROY {}

sub decompose { Rstats::Func::decompose(@_) }
sub copy_attrs_to { Rstats::Func::copy_attrs_to(@_) }
sub class { Rstats::Func::class(undef(), @_) }
sub dimnames { Rstats::Func::dimnames(@_) }
sub dim { Rstats::Func::dim(@_) }
sub at { Rstats::Func::at(undef(), @_) }
sub _name_to_index { Rstats::Func::_name_to_index(undef(), @_) }
sub length_value { Rstats::Func::length_value(undef(), @_) }
sub dim_as_array { Rstats::Func::dim_as_array(undef(), @_) }
sub type { Rstats::Func::type(undef(), @_) }
sub values { Rstats::Func::values(undef(), @_) }


1;

=head1 NAME

Rstats::Object - Rstats object class

1;
