package Rstats::Array;
use Rstats::Container -base;

use Rstats::VectorFunc;
use Rstats::Func;
use Rstats::ArrayFunc;
use Rstats::Util;
use Carp 'croak', 'carp';

our @CARP_NOT = ('Rstats');

use overload
  bool => sub { Rstats::ArrayFunc::bool(@_) },
  '+' => sub { Rstats::ArrayFunc::add(@_) },
  '-' => sub { Rstats::ArrayFunc::subtract(@_) },
  '*' => sub { Rstats::ArrayFunc::multiply(@_) },
  '/' => sub { Rstats::ArrayFunc::divide(@_) },
  '%' => sub { Rstats::ArrayFunc::remainder(@_) },
  '**' => sub { Rstats::ArrayFunc::pow(@_) },
  '<' => sub { Rstats::ArrayFunc::less_than(@_) },
  '<=' => sub { Rstats::ArrayFunc::less_than_or_equal(@_) },
  '>' => sub { Rstats::ArrayFunc::more_than(@_) },
  '>=' => sub { Rstats::ArrayFunc::more_than_or_equal(@_) },
  '==' => sub { Rstats::ArrayFunc::equal(@_) },
  '!=' => sub { Rstats::ArrayFunc::not_equal(@_) },
  '&' => sub { Rstats::ArrayFunc::and(@_) },
  '|' => sub { Rstats::ArrayFunc::or(@_) },
  'x' => sub { Rstats::ArrayFunc::inner_product(@_) },
  'neg' => sub { Rstats::ArrayFunc::negation(@_) },
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
sub operate_binary_fix_pos { Rstats::ArrayFunc::operate_binary_fix_pos(@_) }
sub _fix_position { Rstats::ArrayFunc::_fix_position(@_) }

1;

=head1 NAME

Rstats::Array - Array
