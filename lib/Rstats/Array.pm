package Rstats::Array;
use Rstats::Container -base;

use overload
  '+' => sub { Rstats::Func::Array::add(undef(), Rstats::Func::Array::_fix_pos(undef(), @_)) },
  '-' => sub { Rstats::Func::Array::subtract(undef(), Rstats::Func::Array::_fix_pos(undef(), @_)) },
  '*' => sub { Rstats::Func::Array::multiply(undef(), Rstats::Func::Array::_fix_pos(undef(), @_)) },
  '/' => sub { Rstats::Func::Array::divide(undef(), Rstats::Func::Array::_fix_pos(undef(), @_)) },
  '%' => sub { Rstats::Func::Array::remainder(undef(), Rstats::Func::Array::_fix_pos(undef(), @_)) },
  '**' => sub { Rstats::Func::Array::pow(undef(), Rstats::Func::Array::_fix_pos(undef(), @_)) },
  '<' => sub { Rstats::Func::Array::less_than(undef(), Rstats::Func::Array::_fix_pos(undef(), @_)) },
  '<=' => sub { Rstats::Func::Array::less_than_or_equal(undef(), Rstats::Func::Array::_fix_pos(undef(), @_)) },
  '>' => sub { Rstats::Func::Array::more_than(undef(), Rstats::Func::Array::_fix_pos(undef(), @_)) },
  '>=' => sub { Rstats::Func::Array::more_than_or_equal(undef(), Rstats::Func::Array::_fix_pos(undef(), @_)) },
  '==' => sub { Rstats::Func::Array::equal(undef(), Rstats::Func::Array::_fix_pos(undef(), @_)) },
  '!=' => sub { Rstats::Func::Array::not_equal(undef(), Rstats::Func::Array::_fix_pos(undef(), @_)) },
  '&' => sub { Rstats::Func::Array::and(undef(), Rstats::Func::Array::_fix_pos(undef(), @_)) },
  '|' => sub { Rstats::Func::Array::or(undef(), Rstats::Func::Array::_fix_pos(undef(), @_)) },
  'x' => sub { Rstats::Func::Array::inner_product(undef(), Rstats::Func::Array::_fix_pos(undef(), @_)) },
  bool => sub { Rstats::Func::Array::bool(undef(), @_) },
  'neg' => sub { Rstats::Func::Array::negation(undef(), @_) },
  '""' => sub { Rstats::Func::Array::to_string(undef(), @_) },
  fallback => 1;

sub set { Rstats::Func::Array::set(undef(), @_) }
sub bool { Rstats::Func::Array::bool(undef(), @_) }
sub value { Rstats::Func::Array::value(undef(), @_) }
sub getin { Rstats::Func::Array::getin(undef(), @_) }
sub get { Rstats::Func::Array::get(undef(), @_) }
sub to_string { Rstats::Func::Array::to_string(undef(), @_) }

sub is_finite { Rstats::Func::Array::is_finite(@_) }
sub is_infinite { Rstats::Func::Array::is_infinite(@_) }
sub is_nan { Rstats::Func::Array::is_nan(@_) }
sub is_null { Rstats::Func::Array::is_null(@_) }
sub _levels_h { Rstats::Func::Array::_levels_h(@_) }
sub negation { Rstats::Func::Array::negation(@_) }
sub _fix_pos { Rstats::Func::Array::_fix_pos(@_) }
sub NULL { Rstats::Func::Array::NULL(@_) }
sub NA { Rstats::Func::Array::NA(@_) }
sub NaN { Rstats::Func::Array::NaN(@_) }
sub Inf { Rstats::Func::Array::Inf(@_) }
sub FALSE { Rstats::Func::Array::FALSE(@_) }
sub F { Rstats::Func::Array::F(@_) }
sub TRUE { Rstats::Func::Array::TRUE(@_) }
sub T { Rstats::Func::Array::T(@_) }
sub pi { Rstats::Func::Array::pi(@_) }
sub I { Rstats::Func::Array::I(@_) }
sub subset { Rstats::Func::Array::subset(@_) }
sub t { Rstats::Func::Array::t(@_) }
sub transform { Rstats::Func::Array::transform(@_) }
sub na_omit { Rstats::Func::Array::na_omit(@_) }
sub merge { Rstats::Func::Array::merge(@_) }
sub read_table { Rstats::Func::Array::read_table(@_) }
sub interaction { Rstats::Func::Array::interaction(@_) }
sub gl { Rstats::Func::Array::gl(@_) }
sub ordered { Rstats::Func::Array::ordered(@_) }
sub factor { Rstats::Func::Array::factor(@_) }
sub length { Rstats::Func::Array::length(@_) }
sub list { Rstats::Func::Array::list(@_) }
sub data_frame { Rstats::Func::Array::data_frame(@_) }
sub upper_tri { Rstats::Func::Array::upper_tri(@_) }
sub lower_tri { Rstats::Func::Array::lower_tri(@_) }
sub diag { Rstats::Func::Array::diag(@_) }
sub set_diag { Rstats::Func::Array::set_diag(@_) }
sub kronecker { Rstats::Func::Array::kronecker(@_) }
sub outer { Rstats::Func::Array::outer(@_) }
sub Mod { Rstats::Func::Array::Mod(@_) }
sub Arg { Rstats::Func::Array::Arg(@_) }
sub sub { Rstats::Func::Array::sub(@_) }
sub gsub { Rstats::Func::Array::gsub(@_) }
sub grep { Rstats::Func::Array::grep(@_) }
sub se { Rstats::Func::Array::se(@_) }
sub col { Rstats::Func::Array::col(@_) }
sub chartr { Rstats::Func::Array::chartr(@_) }
sub charmatch { Rstats::Func::Array::charmatch(@_) }
sub Conj { Rstats::Func::Array::Conj(@_) }
sub Re { Rstats::Func::Array::Re(@_) }
sub Im { Rstats::Func::Array::Im(@_) }
sub nrow { Rstats::Func::Array::nrow(@_) }
sub is_element { Rstats::Func::Array::is_element(@_) }
sub setequal { Rstats::Func::Array::setequal(@_) }
sub setdiff { Rstats::Func::Array::setdiff(@_) }
sub intersect { Rstats::Func::Array::intersect(@_) }
sub union { Rstats::Func::Array::union(@_) }
sub diff { Rstats::Func::Array::diff(@_) }
sub nchar { Rstats::Func::Array::nchar(@_) }
sub tolower { Rstats::Func::Array::tolower(@_) }
sub toupper { Rstats::Func::Array::toupper(@_) }
sub match { Rstats::Func::Array::match(@_) }
sub operate_binary { Rstats::Func::Array::operate_binary(@_) }
sub and { Rstats::Func::Array::and(@_) }
sub or { Rstats::Func::Array::or(@_) }
sub add { Rstats::Func::Array::add(@_) }
sub subtract { Rstats::Func::Array::subtract(@_) }
sub multiply { Rstats::Func::Array::multiply(@_) }
sub divide { Rstats::Func::Array::divide(@_) }
sub pow { Rstats::Func::Array::pow(@_) }
sub remainder { Rstats::Func::Array::remainder(@_) }
sub more_than {Rstats::Func::Array::more_than(@_) }
sub more_than_or_equal { Rstats::Func::Array::more_than_or_equal(@_) }
sub less_than { Rstats::Func::Array::less_than(@_) }
sub less_than_or_equal { Rstats::Func::Array::less_than_or_equal(@_) }
sub equal { Rstats::Func::Array::equal(@_) }
sub not_equal { Rstats::Func::Array::not_equal(@_) }
sub abs { Rstats::Func::Array::abs(@_) }
sub acos { Rstats::Func::Array::acos(@_) }
sub acosh { Rstats::Func::Array::acosh(@_) }
sub append { Rstats::Func::Array::append(@_) }
sub array { Rstats::Func::Array::array(@_) }
sub asin { Rstats::Func::Array::asin(@_) }
sub asinh { Rstats::Func::Array::asinh(@_) }
sub atan { Rstats::Func::Array::atan(@_) }
sub atanh { Rstats::Func::Array::atanh(@_) }
sub cbind { Rstats::Func::Array::cbind(@_) }
sub ceiling { Rstats::Func::Array::ceiling(@_) }
sub colMeans { Rstats::Func::Array::colMeans(@_) }
sub colSums { Rstats::Func::Array::colSums(@_) }
sub cos { Rstats::Func::Array::cos(@_) }
sub atan2 { Rstats::Func::Array::atan2(@_) }
sub cosh { Rstats::Func::Array::cosh(@_) }
sub cummax { Rstats::Func::Array::cummax(@_) }
sub cummin { Rstats::Func::Array::cummin(@_) }
sub cumsum { Rstats::Func::Array::cumsum(@_) }
sub cumprod { Rstats::Func::Array::cumprod(@_) }
sub args_array { Rstats::Func::Array::args_array(@_) }
sub complex { Rstats::Func::Array::complex(@_) }
sub exp { Rstats::Func::Array::exp(@_) }
sub expm1 { Rstats::Func::Array::expm1(@_) }
sub max_type { Rstats::Func::Array::max_type(@_) }
sub floor { Rstats::Func::Array::floor(@_) }
sub head { Rstats::Func::Array::head(@_) }
sub i { Rstats::Func::Array::i(@_) }
sub ifelse { Rstats::Func::Array::ifelse(@_) }
sub log { Rstats::Func::Array::log(@_) }
sub logb { Rstats::Func::Array::logb(@_) }
sub log2 { Rstats::Func::Array::log2(@_) }
sub log10 { Rstats::Func::Array::log10(@_) }
sub max { Rstats::Func::Array::max(@_) }
sub mean { Rstats::Func::Array::mean(@_) }
sub min { Rstats::Func::Array::min(@_) }
sub order { Rstats::Func::Array::order(@_) }
sub rank { Rstats::Func::Array::rank(@_) }
sub paste { Rstats::Func::Array::paste(@_) }
sub pmax { Rstats::Func::Array::pmax(@_) }
sub pmin { Rstats::Func::Array::pmin(@_) }
sub prod { Rstats::Func::Array::prod(@_) }
sub range { Rstats::Func::Array::range(@_) }
sub rbind { Rstats::Func::Array::rbind(@_) }
sub rep { Rstats::Func::Array::rep(@_) }
sub replace { Rstats::Func::Array::replace(@_) }
sub rev { Rstats::Func::Array::rev(@_) }
sub rnorm { Rstats::Func::Array::rnorm(@_) }
sub round { Rstats::Func::Array::round(@_) }
sub rowMeans { Rstats::Func::Array::rowMeans(@_) }
sub rowSums { Rstats::Func::Array::rowSums(@_) }
sub runif { Rstats::Func::Array::runif(@_) }
sub sample { Rstats::Func::Array::sample(@_) }
sub sequence { Rstats::Func::Array::sequence(@_) }
sub sinh { Rstats::Func::Array::sinh(@_) }
sub sqrt { Rstats::Func::Array::sqrt(@_) }
sub sort { Rstats::Func::Array::sort(@_) }
sub tail { Rstats::Func::Array::tail(@_) }
sub tan { Rstats::Func::Array::tan(@_) }
sub operate_unary_old { Rstats::Func::Array::operate_unary_old(@_) }
sub sin { Rstats::Func::Array::sin(@_) }
sub operate_unary { Rstats::Func::Array::operate_unary(@_) }
sub tanh { Rstats::Func::Array::tanh(@_) }
sub trunc { Rstats::Func::Array::trunc(@_) }
sub unique { Rstats::Func::Array::unique(@_) }
sub median { Rstats::Func::Array::median(@_) }
sub quantile { Rstats::Func::Array::quantile(@_) }
sub sd { Rstats::Func::Array::sd(@_) }
sub var { Rstats::Func::Array::var(@_) }
sub which { Rstats::Func::Array::which(@_) }
sub new_vector { Rstats::Func::Array::new_vector(@_) }
sub new_character { Rstats::Func::Array::new_character(@_) }
sub new_complex { Rstats::Func::Array::new_complex(@_) }
sub new_double { Rstats::Func::Array::new_double(@_) }
sub new_integer { Rstats::Func::Array::new_integer(@_) }
sub new_logical { Rstats::Func::Array::new_logical(@_) }
sub matrix { Rstats::Func::Array::matrix(@_) }
sub inner_product { Rstats::Func::Array::inner_product(@_) }
sub row { Rstats::Func::Array::row(@_) }
sub sum { Rstats::Func::Array::sum(@_) }
sub ncol { Rstats::Func::Array::ncol(@_) }
sub seq { Rstats::Func::Array::seq(@_) }
sub numeric { Rstats::Func::Array::numeric(@_) }
sub args { Rstats::Func::Array::args(@_) }
sub to_c { Rstats::Func::Array::to_c(@_) }
sub c { Rstats::Func::Array::c(@_) }

1;

=head1 NAME

Rstats::Array - Array
