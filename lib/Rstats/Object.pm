package Rstats::Object;
use Object::Simple -base;

use overload
  '+' => sub {
    my $x1 = shift;
    my $r = $x1->r;

    return Rstats::ArrayFunc::add($r, Rstats::ArrayFunc::_fix_pos($r, $x1, @_));
  },
  '-' => sub {
    my $x1 = shift;
    my $r = $x1->r;

    return Rstats::ArrayFunc::subtract($r, Rstats::ArrayFunc::_fix_pos($r, $x1, @_));
  },
  '*' => sub {
    my $x1 = shift;
    my $r = $x1->r;

    return Rstats::ArrayFunc::multiply($r, Rstats::ArrayFunc::_fix_pos($r, $x1, @_));
  },
  '/' => sub {
    my $x1 = shift;
    my $r = $x1->r;

    Rstats::ArrayFunc::divide($r, Rstats::ArrayFunc::_fix_pos($r, $x1, @_));
  },
  '%' => sub {
    my $x1 = shift;
    my $r = $x1->r;

    return Rstats::ArrayFunc::remainder($r, Rstats::ArrayFunc::_fix_pos($r, $x1, @_));
  },
  '**' => sub {
    my $x1 = shift;
    my $r = $x1->r;

    return Rstats::ArrayFunc::pow($r, Rstats::ArrayFunc::_fix_pos($r, $x1, @_));
  },
  '<' => sub {
    my $x1 = shift;
    my $r = $x1->r;

    return Rstats::ArrayFunc::less_than($r, Rstats::ArrayFunc::_fix_pos($r, $x1, @_));
  },
  '<=' => sub {
    my $x1 = shift;
    my $r = $x1->r;

    return Rstats::ArrayFunc::less_than_or_equal($r, Rstats::ArrayFunc::_fix_pos($r, $x1, @_));
  },
  '>' => sub {
    my $x1 = shift;
    my $r = $x1->r;

    return Rstats::ArrayFunc::more_than($r, Rstats::ArrayFunc::_fix_pos($r, $x1, @_));
  },
  '>=' => sub {
    my $x1 = shift;
    my $r = $x1->r;

    return Rstats::ArrayFunc::more_than_or_equal($r, Rstats::ArrayFunc::_fix_pos($r, $x1, @_));
  },
  '==' => sub {
    my $x1 = shift;
    my $r = $x1->r;

    return Rstats::ArrayFunc::equal($r, Rstats::ArrayFunc::_fix_pos($r, $x1, @_));
  },
  '!=' => sub {
    my $x1 = shift;
    my $r = $x1->r;

    return Rstats::ArrayFunc::not_equal($r, Rstats::ArrayFunc::_fix_pos($r, $x1, @_));
  },
  '&' => sub {
    my $x1 = shift;
    my $r = $x1->r;

    return Rstats::ArrayFunc::and($r, Rstats::ArrayFunc::_fix_pos($r, $x1, @_));
  },
  '|' => sub {
    my $x1 = shift;
    my $r = $x1->r;

    return Rstats::ArrayFunc::or($r, Rstats::ArrayFunc::_fix_pos($r, $x1, @_));
  },
  'x' => sub {
    my $x1 = shift;
    my $r = $x1->r;

    return Rstats::ArrayFunc::inner_product($r, Rstats::ArrayFunc::_fix_pos($r, $x1, @_));
  },
  bool => sub {
    my $x1 = shift;
    my $r = $x1->r;
    
    return Rstats::ArrayFunc::bool($r, $x1, @_);
  },
  'neg' => sub {
    my $x1 = shift;
    my $r = $x1->r;
    
    return Rstats::ArrayFunc::negation($r, $x1, @_);
  },
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
sub dimnames { Rstats::Func::dimnames(@_) }
sub dim { Rstats::Func::dim(@_) }
sub _name_to_index { Rstats::Func::_name_to_index(undef(), @_) }

1;

=head1 NAME

Rstats::Object - Rstats object class

1;
