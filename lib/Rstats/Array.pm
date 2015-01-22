package Rstats::Array;
use Rstats::Container -base;

use Rstats::ArrayFunc;

use overload
  '+' => sub { Rstats::ArrayFunc::add(Rstats::ArrayFunc::_fix_pos(@_)) },
  '-' => sub { Rstats::ArrayFunc::subtract(Rstats::ArrayFunc::_fix_pos(@_)) },
  '*' => sub { Rstats::ArrayFunc::multiply(Rstats::ArrayFunc::_fix_pos(@_)) },
  '/' => sub { Rstats::ArrayFunc::divide(Rstats::ArrayFunc::_fix_pos(@_)) },
  '%' => sub { Rstats::ArrayFunc::remainder(Rstats::ArrayFunc::_fix_pos(@_)) },
  '**' => sub { Rstats::ArrayFunc::pow(Rstats::ArrayFunc::_fix_pos(@_)) },
  '<' => sub { Rstats::ArrayFunc::less_than(Rstats::ArrayFunc::_fix_pos(@_)) },
  '<=' => sub { Rstats::ArrayFunc::less_than_or_equal(Rstats::ArrayFunc::_fix_pos(@_)) },
  '>' => sub { Rstats::ArrayFunc::more_than(Rstats::ArrayFunc::_fix_pos(@_)) },
  '>=' => sub { Rstats::ArrayFunc::more_than_or_equal(Rstats::ArrayFunc::_fix_pos(@_)) },
  '==' => sub { Rstats::ArrayFunc::equal(Rstats::ArrayFunc::_fix_pos(@_)) },
  '!=' => sub { Rstats::ArrayFunc::not_equal(Rstats::ArrayFunc::_fix_pos(@_)) },
  '&' => sub { Rstats::ArrayFunc::and(Rstats::ArrayFunc::_fix_pos(@_)) },
  '|' => sub { Rstats::ArrayFunc::or(Rstats::ArrayFunc::_fix_pos(@_)) },
  'x' => sub { Rstats::ArrayFunc::inner_product(Rstats::ArrayFunc::_fix_pos(@_)) },
  bool => sub { Rstats::ArrayFunc::bool(@_) },
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
