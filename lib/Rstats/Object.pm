package Rstats::Object;
use Object::Simple -base;

use overload
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

sub class { Rstats::Func::class(undef(), @_) }
sub dimnames { Rstats::Func::dimnames(@_) }
sub dim { Rstats::Func::dim(@_) }
sub at { Rstats::Func::at(undef(), @_) }
sub _name_to_index { Rstats::Func::_name_to_index(undef(), @_) }
sub length_value { Rstats::Func::length_value(undef(), @_) }
sub dim_as_array { Rstats::Func::dim_as_array(undef(), @_) }
sub type { Rstats::Func::type(undef(), @_) }
sub values { Rstats::Func::values(undef(), @_) }

sub decompose { Rstats::Func::decompose(@_) }
sub copy_attrs_to { Rstats::Func::copy_attrs_to(@_) }

1;

=head1 NAME

Rstats::Object - Rstats object class

1;
