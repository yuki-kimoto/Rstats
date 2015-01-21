package Rstats::Array;
use Rstats::Container -base;

use Rstats::VectorFunc;
use Rstats::Func;
use Rstats::ArrayFunc;
use Rstats::Util;
use Carp 'croak', 'carp';

our @CARP_NOT = ('Rstats');

use overload
  bool => \&bool,
  '+' => sub { shift->operate_binary(\&Rstats::VectorFunc::add, @_) },
  '-' => sub { shift->operate_binary(\&Rstats::VectorFunc::subtract, @_) },
  '*' => sub { shift->operate_binary(\&Rstats::VectorFunc::multiply, @_) },
  '/' => sub { shift->operate_binary(\&Rstats::VectorFunc::divide, @_) },
  '%' => sub { shift->operate_binary(\&Rstats::VectorFunc::remainder, @_) },
  'neg' => sub { Rstats::ArrayFunc::negation(@_) },
  '**' => sub { shift->operate_binary(\&Rstats::VectorFunc::pow, @_) },
  'x' => sub { shift->inner_product(@_) },
  '<' => sub { shift->operate_binary(\&Rstats::VectorFunc::less_than, @_) },
  '<=' => sub { shift->operate_binary(\&Rstats::VectorFunc::less_than_or_equal, @_) },
  '>' => sub { shift->operate_binary(\&Rstats::VectorFunc::more_than, @_) },
  '>=' => sub { shift->operate_binary(\&Rstats::VectorFunc::more_than_or_equal, @_) },
  '==' => sub { shift->operate_binary(\&Rstats::VectorFunc::equal, @_) },
  '!=' => sub { shift->operate_binary(\&Rstats::VectorFunc::not_equal, @_) },
  '&' => sub { shift->operate_binary(\&Rstats::VectorFunc::and, @_) },
  '|' => sub { shift->operate_binary(\&Rstats::VectorFunc::or, @_) },
  '""' => sub { Rstats::ArrayFunc::to_string(@_) },
  fallback => 1;

sub to_string { Rstats::ArrayFunc::to_string(@_) }
sub is_finite { Rstats::ArrayFunc::is_finite(@_) }
sub is_infinite { Rstats::ArrayFunc::is_infinite(@_) }
sub is_nan { Rstats::ArrayFunc::is_nan(@_) }
sub is_null { Rstats::ArrayFunc::is_null(@_) }
sub getin { Rstats::ArrayFunc::getin(@_) }
sub get { Rstats::ArrayFunc::get(@_) }
sub _levels_h { Rstats::ArrayFunc::_levels_h(@_) }
sub set { Rstats::ArrayFunc::set(@_) }
sub bool { Rstats::ArrayFunc::bool(@_) }
sub value { Rstats::ArrayFunc::value(@_) }
sub inner_product { Rstats::ArrayFunc::inner_product(@_) }
sub negation { Rstats::ArrayFunc::negation(@_) }
sub operate_binary { Rstats::ArrayFunc::operate_binary(@_) }
sub _fix_position { Rstats::ArrayFunc::_fix_position(@_) }

1;

=head1 NAME

Rstats::Array - Array
