package Rstats::Func;

use strict;
use warnings;

require Rstats;

use Rstats::ArrayFunc;

sub NULL { Rstats::ArrayFunc::NULL(@_) }
sub NA { Rstats::ArrayFunc::NA(@_) }
sub NaN { Rstats::ArrayFunc::NaN(@_) }
sub Inf { Rstats::ArrayFunc::Inf(@_) }
sub FALSE { Rstats::ArrayFunc::FALSE(@_) }
sub F { Rstats::ArrayFunc::F(@_) }
sub TRUE { Rstats::ArrayFunc::TRUE(@_) }
sub T { Rstats::ArrayFunc::T(@_) }
sub pi { Rstats::ArrayFunc::pi(@_) }
sub I { Rstats::ArrayFunc::I(@_) }
sub subset { Rstats::ArrayFunc::subset(@_) }
sub t { Rstats::ArrayFunc::t(@_) }
sub transform { Rstats::ArrayFunc::transform(@_) }
sub na_omit { Rstats::ArrayFunc::na_omit(@_) }
sub merge { Rstats::ArrayFunc::merge(@_) }
sub read_table { Rstats::ArrayFunc::read_table(@_) }
sub interaction { Rstats::ArrayFunc::interaction(@_) }
sub gl { Rstats::ArrayFunc::gl(@_) }
sub ordered { Rstats::ArrayFunc::ordered(@_) }
sub factor { Rstats::ArrayFunc::factor(@_) }
sub length { Rstats::ArrayFunc::length(@_) }
sub list { Rstats::ArrayFunc::list(@_) }
sub data_frame { Rstats::ArrayFunc::data_frame(@_) }
sub upper_tri { Rstats::ArrayFunc::upper_tri(@_) }
sub lower_tri { Rstats::ArrayFunc::lower_tri(@_) }
sub diag { Rstats::ArrayFunc::diag(@_) }
sub set_diag { Rstats::ArrayFunc::set_diag(@_) }
sub kronecker { Rstats::ArrayFunc::kronecker(@_) }
sub outer { Rstats::ArrayFunc::outer(@_) }
sub Mod { Rstats::ArrayFunc::Mod(@_) }
sub Arg { Rstats::ArrayFunc::Arg(@_) }
sub sub { Rstats::ArrayFunc::sub(@_) }
sub gsub { Rstats::ArrayFunc::gsub(@_) }
sub grep { Rstats::ArrayFunc::grep(@_) }
sub se { Rstats::ArrayFunc::se(@_) }
sub col { Rstats::ArrayFunc::col(@_) }
sub chartr { Rstats::ArrayFunc::chartr(@_) }
sub charmatch { Rstats::ArrayFunc::charmatch(@_) }
sub Conj { Rstats::ArrayFunc::Conj(@_) }
sub Re { Rstats::ArrayFunc::Re(@_) }
sub Im { Rstats::ArrayFunc::Im(@_) }
sub nrow { Rstats::ArrayFunc::nrow(@_) }
sub is_element { Rstats::ArrayFunc::is_element(@_) }
sub setequal { Rstats::ArrayFunc::setequal(@_) }
sub setdiff { Rstats::ArrayFunc::setdiff(@_) }
sub intersect { Rstats::ArrayFunc::intersect(@_) }
sub union { Rstats::ArrayFunc::union(@_) }
sub diff { Rstats::ArrayFunc::diff(@_) }
sub nchar { Rstats::ArrayFunc::nchar(@_) }
sub tolower { Rstats::ArrayFunc::tolower(@_) }
sub toupper { Rstats::ArrayFunc::toupper(@_) }
sub match { Rstats::ArrayFunc::match(@_) }
sub operate_binary { Rstats::ArrayFunc::operate_binary(@_) }
sub and { Rstats::ArrayFunc::and(@_) }
sub or { Rstats::ArrayFunc::or(@_) }
sub add { Rstats::ArrayFunc::add(@_) }
sub subtract { Rstats::ArrayFunc::subtract(@_) }
sub multiply { Rstats::ArrayFunc::multiply(@_) }
sub divide { Rstats::ArrayFunc::divide(@_) }
sub pow { Rstats::ArrayFunc::pow(@_) }
sub remainder { Rstats::ArrayFunc::remainder(@_) }
sub more_than {Rstats::ArrayFunc::more_than(@_) }
sub more_than_or_equal { Rstats::ArrayFunc::more_than_or_equal(@_) }
sub less_than { Rstats::ArrayFunc::less_than(@_) }
sub less_than_or_equal { Rstats::ArrayFunc::less_than_or_equal(@_) }
sub equal { Rstats::ArrayFunc::equal(@_) }
sub not_equal { Rstats::ArrayFunc::not_equal(@_) }
sub abs { Rstats::ArrayFunc::abs(@_) }
sub acos { Rstats::ArrayFunc::acos(@_) }
sub acosh { Rstats::ArrayFunc::acosh(@_) }
sub append { Rstats::ArrayFunc::append(@_) }
sub array { Rstats::ArrayFunc::array(@_) }
sub asin { Rstats::ArrayFunc::asin(@_) }
sub asinh { Rstats::ArrayFunc::asinh(@_) }
sub atan { Rstats::ArrayFunc::atan(@_) }
sub atanh { Rstats::ArrayFunc::atanh(@_) }
sub cbind { Rstats::ArrayFunc::cbind(@_) }
sub ceiling { Rstats::ArrayFunc::ceiling(@_) }
sub colMeans { Rstats::ArrayFunc::colMeans(@_) }
sub colSums { Rstats::ArrayFunc::colSums(@_) }
sub cos { Rstats::ArrayFunc::cos(@_) }
sub atan2 { Rstats::ArrayFunc::atan2(@_) }
sub cosh { Rstats::ArrayFunc::cosh(@_) }
sub cummax { Rstats::ArrayFunc::cummax(@_) }
sub cummin { Rstats::ArrayFunc::cummin(@_) }
sub cumsum { Rstats::ArrayFunc::cumsum(@_) }
sub cumprod { Rstats::ArrayFunc::cumprod(@_) }
sub args_array { Rstats::ArrayFunc::args_array(@_) }
sub complex { Rstats::ArrayFunc::complex(@_) }
sub exp { Rstats::ArrayFunc::exp(@_) }
sub expm1 { Rstats::ArrayFunc::expm1(@_) }
sub max_type { Rstats::ArrayFunc::max_type(@_) }
sub floor { Rstats::ArrayFunc::floor(@_) }
sub head { Rstats::ArrayFunc::head(@_) }
sub i { Rstats::ArrayFunc::i(@_) }
sub ifelse { Rstats::ArrayFunc::ifelse(@_) }
sub log { Rstats::ArrayFunc::log(@_) }
sub logb { Rstats::ArrayFunc::logb(@_) }
sub log2 { Rstats::ArrayFunc::log2(@_) }
sub log10 { Rstats::ArrayFunc::log10(@_) }
sub max { Rstats::ArrayFunc::max(@_) }
sub mean { Rstats::ArrayFunc::mean(@_) }
sub min { Rstats::ArrayFunc::min(@_) }
sub order { Rstats::ArrayFunc::order(@_) }
sub rank { Rstats::ArrayFunc::rank(@_) }
sub paste { Rstats::ArrayFunc::paste(@_) }
sub pmax { Rstats::ArrayFunc::pmax(@_) }
sub pmin { Rstats::ArrayFunc::pmin(@_) }
sub prod { Rstats::ArrayFunc::prod(@_) }
sub range { Rstats::ArrayFunc::range(@_) }
sub rbind { Rstats::ArrayFunc::rbind(@_) }
sub rep { Rstats::ArrayFunc::rep(@_) }
sub replace { Rstats::ArrayFunc::replace(@_) }
sub rev { Rstats::ArrayFunc::rev(@_) }
sub rnorm { Rstats::ArrayFunc::rnorm(@_) }
sub round { Rstats::ArrayFunc::round(@_) }
sub rowMeans { Rstats::ArrayFunc::rowMeans(@_) }
sub rowSums { Rstats::ArrayFunc::rowSums(@_) }
sub runif { Rstats::ArrayFunc::runif(@_) }
sub sample { Rstats::ArrayFunc::sample(@_) }
sub sequence { Rstats::ArrayFunc::sequence(@_) }
sub sinh { Rstats::ArrayFunc::sinh(@_) }
sub sqrt { Rstats::ArrayFunc::sqrt(@_) }
sub sort { Rstats::ArrayFunc::sort(@_) }
sub tail { Rstats::ArrayFunc::tail(@_) }
sub tan { Rstats::ArrayFunc::tan(@_) }
sub operate_unary_old { Rstats::ArrayFunc::operate_unary_old(@_) }
sub sin { Rstats::ArrayFunc::sin(@_) }
sub operate_unary { Rstats::ArrayFunc::operate_unary(@_) }
sub tanh { Rstats::ArrayFunc::tanh(@_) }
sub trunc { Rstats::ArrayFunc::trunc(@_) }
sub unique { Rstats::ArrayFunc::unique(@_) }
sub median { Rstats::ArrayFunc::median(@_) }
sub quantile { Rstats::ArrayFunc::quantile(@_) }
sub sd { Rstats::ArrayFunc::sd(@_) }
sub var { Rstats::ArrayFunc::var(@_) }
sub which { Rstats::ArrayFunc::which(@_) }
sub new_vector { Rstats::ArrayFunc::new_vector(@_) }
sub new_character { Rstats::ArrayFunc::new_character(@_) }
sub new_complex { Rstats::ArrayFunc::new_complex(@_) }
sub new_double { Rstats::ArrayFunc::new_double(@_) }
sub new_integer { Rstats::ArrayFunc::new_integer(@_) }
sub new_logical { Rstats::ArrayFunc::new_logical(@_) }
sub matrix { Rstats::ArrayFunc::matrix(@_) }
sub inner_product { Rstats::ArrayFunc::inner_product(@_) }
sub row { Rstats::ArrayFunc::row(@_) }
sub sum { Rstats::ArrayFunc::sum(@_) }
sub ncol { Rstats::ArrayFunc::ncol(@_) }
sub seq { Rstats::ArrayFunc::seq(@_) }
sub numeric { Rstats::ArrayFunc::numeric(@_) }
sub args { Rstats::ArrayFunc::args(@_) }
sub to_c { Rstats::ArrayFunc::to_c(@_) }
sub c { Rstats::ArrayFunc::c(@_) }

1;

=head1 NAME

Rstats::Func - Functions

