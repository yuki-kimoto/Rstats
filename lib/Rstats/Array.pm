package Rstats::Array;
use Rstats::Object -base;

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
  fallback => 1;

sub set {Rstats::ArrayFunc::set(undef(), @_) }
sub bool { Rstats::ArrayFunc::bool(undef(), @_) }
sub value { Rstats::ArrayFunc::value(undef(), @_) }
sub getin { Rstats::ArrayFunc::getin(undef(), @_) }

1;

=head1 NAME

Rstats::Array - Array
