package Rstats::Container;
use Object::Simple -base;

use Rstats::Func;

has 'r';
has list => sub { [] };
has 'vector';

sub at { Rstats::Func::at(undef(), @_) }
sub _name_to_index { Rstats::Func::_name_to_index(undef(), @_) }
sub length_value { Rstats::Func::length_value(undef(), @_) }

sub decompose { Rstats::Func::decompose(@_) }
sub copy_attrs_to { Rstats::Func::copy_attrs_to(@_) }
sub _value_to_string { Rstats::Func::_value_to_string(@_) }
sub str { Rstats::Func::str(@_) }
sub levels { Rstats::Func::levels(@_) }
sub clone { Rstats::Func::clone(@_) }
sub nlevels { Rstats::Func::nlevels(@_) }
sub length { Rstats::Func::length(@_) }
sub is_na { Rstats::Func::is_na(@_) }
sub as_list { Rstats::Func::as_list(@_) }
sub is_list { Rstats::Func::is_list(@_) }
sub class { Rstats::Func::class(@_) }
sub dim_as_array { Rstats::Func::dim_as_array(@_) }
sub dim { Rstats::Func::dim(@_) }
sub mode { Rstats::Func::mode(@_) }
sub typeof { Rstats::Func::typeof(@_) }
sub type { Rstats::Func::type(@_) }
sub is_factor { Rstats::Func::is_factor(@_) }
sub is_ordered { Rstats::Func::is_ordered(@_) }
sub as_factor { Rstats::Func::as_factor(@_) }
sub as_matrix { Rstats::Func::as_matrix(@_) }
sub as_array { Rstats::Func::as_array(@_) }
sub as_vector { Rstats::Func::as_vector(@_) }
sub as { Rstats::Func::as(@_) }
sub as_complex { Rstats::Func::as_complex(@_) }
sub as_numeric { Rstats::Func::as_numeric(@_) }
sub as_double { Rstats::Func::as_double(@_) }
sub as_integer { Rstats::Func::as_integer(@_) }
sub as_logical { Rstats::Func::as_logical(@_) }
sub labels { Rstats::Func::labels(@_) }
sub as_character { Rstats::Func::as_character(@_) }
sub values { Rstats::Func::values(@_) }
sub is_vector { Rstats::Func::is_vector(@_) }
sub is_matrix { Rstats::Func::is_matrix(@_) }
sub is_numeric { Rstats::Func::is_numeric(@_) }
sub is_double { Rstats::Func::is_double(@_) }
sub is_integer { Rstats::Func::is_integer(@_) }
sub is_complex { Rstats::Func::is_complex(@_) }
sub is_character { Rstats::Func::is_character(@_) }
sub is_logical { Rstats::Func::is_logical(@_) }
sub is_data_frame { Rstats::Func::is_data_frame(@_) }
sub is_array { Rstats::Func::is_array(@_) }
sub names { Rstats::Func::names(@_) }
sub dimnames { Rstats::Func::dimnames(@_) }
sub rownames { Rstats::Func::rownames(@_) }
sub colnames { Rstats::Func::colnames(@_) }

1;

=head1 NAME

Rstats::Container - Container base class

1;
