package Rstats::Object;
use Object::Simple -base;


use overload
  bool => sub {
    my $x1 = shift;
    my $r = $x1->r;
    
    return Rstats::Func::bool($r, $x1, @_);
  },
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
    unless $r && (my $helper = $r->get_helper($method));
  
  # Helper
  if (ref $helper eq 'CODE') {
    return $helper->($r, $self, @_);
  }
  #Proxy
  else {
    $helper->{args} = [$self];
    return $helper;
  }
}

sub DESTROY {}

1;

=head1 NAME

Rstats::Object - Rstats object

1;
