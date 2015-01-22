package Rstats::Func;

use strict;
use warnings;

require Rstats;

use Rstats::List;
use Carp 'croak';
use Rstats::Vector;
use Rstats::ArrayFunc;

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
sub negation { Rstats::ArrayFunc::negation(@_) }
sub _fix_pos { Rstats::ArrayFunc::_fix_pos(@_) }
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

sub decompose {
  my $self = shift;
  
  if (exists $self->{vector}) {
    return $self->vector->decompose;
  }
  else {
    croak "Can't call decompose_elements methods from list";
  }
}

my %types_h = map { $_ => 1 } qw/character complex numeric double integer logical/;

sub copy_attrs_to {
  my ($self, $x2, $opt) = @_;
  
  $opt ||= {};
  my $new_indexes = $opt->{new_indexes};
  my $exclude = $opt->{exclude} || [];
  my %exclude_h = map { $_ => 1 } @$exclude;
  
  # dim
  $x2->{dim} = $self->{dim}->clone if !$exclude_h{dim} && exists $self->{dim};
  
  # class
  $x2->{class} =  $self->{class}->clone if !$exclude_h{class} && exists $self->{class};
  
  # levels
  $x2->{levels} = $self->{levels}->clone if !$exclude_h{levels} && exists $self->{levels};
  
  # names
  if (!$exclude_h{names} && exists $self->{names}) {
    my $x2_names_values = [];
    my $index = $self->is_data_frame ? $new_indexes->[1] : $new_indexes->[0];
    if (defined $index) {
      my $self_names_values = $self->{names}->values;
      for my $i (@{$index->values}) {
        push @$x2_names_values, $self_names_values->[$i - 1];
      }
    }
    else {
      $x2_names_values = $self->{names}->values;
    }
    $x2->{names} = Rstats::VectorFunc::new_character(@$x2_names_values);
  }
  
  # dimnames
  if (!$exclude_h{dimnames} && exists $self->{dimnames}) {
    my $new_dimnames = [];
    my $dimnames = $self->{dimnames};
    my $length = @$dimnames;
    for (my $i = 0; $i < $length; $i++) {
      my $dimname = $dimnames->[$i];
      if (defined $dimname && $dimname->length_value) {
        my $index = $new_indexes->[$i];
        my $dimname_values = $dimname->values;
        my $new_dimname_values = [];
        if (defined $index) {
          for my $k (@{$index->values}) {
            push @$new_dimname_values, $dimname_values->[$k - 1];
          }
        }
        else {
          $new_dimname_values = $dimname_values;
        }
        push @$new_dimnames, Rstats::VectorFunc::new_character(@$new_dimname_values);
      }
    }
    $x2->{dimnames} = $new_dimnames;
  }
}

sub _value_to_string {
  my ($self, $value, $type, $is_factor) = @_;
  
  my $string;
  if ($is_factor) {
    if (!defined $value) {
      $string = '<NA>';
    }
    else {
      $string = "$value";
    }
  }
  else {
    if (!defined $value) {
      $string = 'NA';
    }
    elsif ($type eq 'complex') {
      my $re = $value->{re} || 0;
      my $im = $value->{im} || 0;
      $string = "$re";
      $string .= $im > 0 ? "+$im" : $im;
      $string .= 'i';
    }
    elsif ($type eq 'character') {
      $string = '"' . $value . '"';
    }
    elsif ($type eq 'logical') {
      $string = $value ? 'TRUE' : 'FALSE';
    }
    else {
      $string = "$value";
    }
  }
  
  return $string;
}

sub str {
  my $self = shift;
  
  my @str;
  
  if ($self->is_vector || $self->is_array) {
    # Short type
    my $type = $self->vector->type;
    my $short_type;
    if ($type eq 'character') {
      $short_type = 'chr';
    }
    elsif ($type eq 'complex') {
      $short_type = 'cplx';
    }
    elsif ($type eq 'double') {
      $short_type = 'num';
    }
    elsif ($type eq 'integer') {
      $short_type = 'int';
    }
    elsif ($type eq 'logical') {
      $short_type = 'logi';
    }
    else {
      $short_type = 'Unkonown';
    }
    push @str, $short_type;
    
    # Dimention
    my @dim_str;
    my $length = $self->length_value;
    if (exists $self->{dim}) {
      my $dim_values = $self->{dim}->values;
      for (my $i = 0; $i < $self->{dim}->length_value; $i++) {
        my $d = $dim_values->[$i];
        my $d_str;
        if ($d == 1) {
          $d_str = "1";
        }
        else {
          $d_str = "1:$d";
        }
        
        if ($self->{dim}->length_value == 1) {
          $d_str .= "(" . ($i + 1) . "d)";
        }
        push @dim_str, $d_str;
      }
    }
    else {
      if ($length != 1) {
        push @dim_str, "1:$length";
      }
    }
    if (@dim_str) {
      my $dim_str = join(', ', @dim_str);
      push @str, "[$dim_str]";
    }
    
    # Vector
    my @element_str;
    my $max_count = $length > 10 ? 10 : $length;
    my $is_character = $self->is_character;
    my $values = $self->values;
    for (my $i = 0; $i < $max_count; $i++) {
      push @element_str, $self->_value_to_string($values->[$i], $type);
    }
    if ($length > 10) {
      push @element_str, '...';
    }
    my $element_str = join(' ', @element_str);
    push @str, $element_str;
  }
  
  my $str = join(' ', @str);
  
  return $str;
}

sub levels {
  my $self = shift;
  
  if (@_) {
    my $x_levels = Rstats::Func::to_c(shift);
    $x_levels = $x_levels->as_character unless $x_levels->is_character;
    
    $self->{levels} = $x_levels->vector->clone;
    
    return $self;
  }
  else {
    my $x_levels = Rstats::Func::NULL();
    if (exists $self->{levels}) {
      $x_levels->vector($self->{levels}->clone);
    }
    
    return $x_levels;
  }
}

sub clone {
  my $self = shift;;
  
  my $clone = Rstats::Func::NULL();
  $clone->vector($self->vector->clone);
  $self->copy_attrs_to($clone);
  
  return $clone;
}

sub at {
  my $x1 = shift;
  
  if (@_) {
    $x1->{at} = [@_];
    
    return $x1;
  }
  
  return $x1->{at};
}

sub _name_to_index {
  my $self = shift;
  my $x1_index = Rstats::Func::to_c(shift);
  
  my $e1_name = $x1_index->value;
  my $found;
  my $names = $self->names->values;
  my $index;
  for (my $i = 0; $i < @$names; $i++) {
    my $name = $names->[$i];
    if ($e1_name eq $name) {
      $index = $i + 1;
      $found = 1;
      last;
    }
  }
  croak "Not found $e1_name" unless $found;
  
  return $index;
}

sub nlevels {
  my $self = shift;
  
  return Rstats::ArrayFunc::c($self->levels->length_value);
}

sub length_value {
  my $self = shift;
  
  my $length;
  if (exists $self->{vector}) {
    $length = $self->vector->length_value;
  }
  else {
    $length = @{$self->list}
  }
  
  return $length;
}

sub is_na {
  my $_a1 = shift;
  
  my $x1 = Rstats::Func::to_c($_a1);
  my $x2_values = [map { !defined $_ ? 1 : 0 } @{$x1->values}];
  my $x2 = Rstats::Func::NULL();
  $x2->vector(Rstats::VectorFunc::new_logical(@$x2_values));
  
  return $x2;
}

sub as_list {
  my $self = shift;
  
  if (exists $self->{list}) {
    return $self;
  }
  else {
    my $list = Rstats::List->new;
    my $x2 = Rstats::Func::NULL();
    $x2->vector($self->vector->clone);
    $list->list([$x2]);
    
    return $list;
  }
}

sub is_list {
  my $self = shift;

  return exists $self->{list} ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
}

sub class {
  my $self = shift;
  
  if (@_) {
    my $x_class = Rstats::Func::to_c($_[0]);
    
    $self->{class} = $x_class->vector;
    
    return $self;
  }
  else {
    my $x_class = Rstats::Func::NULL();
    if (exists $self->{class}) {
      $x_class->vector($self->{class}->clone);
    }
    elsif ($self->is_vector) {
      $x_class->vector($self->mode->vector->clone);
    }
    elsif ($self->is_matrix) {
      $x_class->vector(Rstats::VectorFunc::new_character('matrix'));
    }
    elsif ($self->is_array) {
      $x_class->vector(Rstats::VectorFunc::new_character('array'));
    }
    elsif ($self->is_data_frame) {
      $x_class->vector(Rstats::VectorFunc::new_character('data.frame'));
    }
    elsif ($self->is_list) {
      $x_class->vector(Rstats::VectorFunc::new_character('list'));
    }
    
    return $x_class;
  }
}

sub dim_as_array {
  my $x1 = shift;
  
  if (exists $x1->{dim}) {
    return $x1->dim;
  }
  else {
    my $length = $x1->length_value;
    return Rstats::Func::new_double($length);
  }
}

sub dim {
  my $self = shift;
  
  if (@_) {
    my $x_dim = Rstats::Func::to_c($_[0]);
    my $self_length = $self->length_value;
    my $self_lenght_by_dim = 1;
    $self_lenght_by_dim *= $_ for @{$x_dim->values};
    
    if ($self_length != $self_lenght_by_dim) {
      croak "dims [product $self_lenght_by_dim] do not match the length of object [$self_length]";
    }
  
    $self->{dim} = $x_dim->vector->clone;
    
    return $self;
  }
  else {
    my $x_dim = Rstats::Func::NULL();
    if (defined $self->{dim}) {
      $x_dim->vector($self->{dim}->clone);
    }
    
    return $x_dim;
  }
}

sub mode {
  my $self = shift;
  
  if (@_) {
    my $type = $_[0];
    croak qq/Error in eval(expr, envir, enclos) : could not find function "as_$type"/
      unless $types_h{$type};
    
    $self->vector($self->vector->as($type));
    
    return $self;
  }
  else {
    my $type = $self->vector->type;
    my $mode;
    if (defined $type) {
      if ($type eq 'integer' || $type eq 'double') {
        $mode = 'numeric';
      }
      else {
        $mode = $type;
      }
    }
    else {
      croak qq/could not find function "as_$type"/;
    }

    return Rstats::ArrayFunc::c($mode);
  }
}

sub typeof {
  my $self = shift;
  
  if ($self->is_vector || $self->is_array) {
    my $type = $self->vector->type;
    return Rstats::Func::new_character($type);
  }
  elsif ($self->is_list) {
    return Rstats::Func::new_character('list');
  }
  else {
    return Rstats::Func::NA();
  }
}

sub type {
  return shift->vector->type;
}

sub is_factor {
  my $self = shift;
  
  my $classes = $self->class->values;
  
  my $is = grep { $_ eq 'factor' } @$classes;
  
  return $is ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
}

sub is_ordered {
  my $self = shift;
  
  my $classes = $self->class->values;

  my $is = grep { $_ eq 'ordered' } @$classes;
  
  return $is ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
}

sub as_factor {
  my $self = shift;
  
  if ($self->is_factor) {
    return $self;
  }
  else {
    my $a = $self->is_character ? $self :  $self->as_character;
    my $f = Rstats::Func::factor($a);
    
    return $f;
  }
}

sub as_matrix {
  my $self = shift;
  
  my $self_dim_elements = $self->dim_as_array->values;
  my $self_dim_count = @$self_dim_elements;
  my $x2_dim_elements = [];
  my $row;
  my $col;
  if ($self_dim_count == 2) {
    $row = $self_dim_elements->[0];
    $col = $self_dim_elements->[1];
  }
  else {
    $row = 1;
    $row *= $_ for @$self_dim_elements;
    $col = 1;
  }
  
  my $x2 = Rstats::Func::NULL();
  my $x2_vector = $self->vector->clone;
  $x2->vector($x2_vector);
  
  return Rstats::Func::matrix($x2, $row, $col);
}

sub as_array {
  my $self = shift;

  my $x2 = Rstats::Func::NULL();
  my $x2_vector = $self->vector->clone;
  $x2->vector($x2_vector);

  my $self_dim_elements = [@{$self->dim_as_array->values}];
  
  return $self->array($x2, $self_dim_elements);
}

sub as_vector {
  my $self = shift;
  
  my $x2 = Rstats::Func::NULL();
  my $x2_vector = $self->vector->clone;
  $x2->vector($x2_vector);
  
  return $x2;
}

sub as {
  my ($self, $type) = @_;
  
  if ($type eq 'character') {
    return as_character($self);
  }
  elsif ($type eq 'complex') {
    return as_complex($self);
  }
  elsif ($type eq 'double') {
    return as_double($self);
  }
  elsif ($type eq 'numeric') {
    return as_numeric($self);
  }
  elsif ($type eq 'integer') {
    return as_integer($self);
  }
  elsif ($type eq 'logical') {
    return as_logical($self);
  }
  else {
    croak "Invalid mode is passed";
  }
}

sub as_complex {
  my $self = shift;

  my $x_tmp;
  if ($self->is_factor) {
    $x_tmp = $self->as_integer;
  }
  else {
    $x_tmp = $self;
  }

  my $x2;
  $x2 = Rstats::Array->new->vector($x_tmp->vector->as_complex);
  $x_tmp->copy_attrs_to($x2);

  return $x2;
}

sub as_numeric { shift->as_double(@_) }

sub as_double {
  my $self = shift;
  
  my $x2;
  if ($self->is_factor) {
    $x2 = Rstats::Array->new->vector($self->vector->as_double);
  }
  else {
    $x2 = Rstats::Array->new->vector($self->vector->as_double);
    $self->copy_attrs_to($x2);
  }

  return $x2;
}

sub as_integer {
  my $self = shift;
  
  my $x2;
  if ($self->is_factor) {
    $x2 = Rstats::Array->new->vector($self->vector->as_integer);
  }
  else {
    $x2 = Rstats::Array->new->vector($self->vector->as_integer);
    $self->copy_attrs_to($x2);
  }

  return $x2;
}

sub as_logical {
  my $self = shift;
  
  my $x2;
  if ($self->is_factor) {
    $x2 = Rstats::Array->new->vector($self->vector->as_logical);
  }
  else {
    $x2 = Rstats::Array->new->vector($self->vector->as_logical);
    $self->copy_attrs_to($x2);
  }

  return $x2;
}

sub labels { shift->as_character(@_) }

sub as_character {
  my $self = shift;
  
  my $x2;
  if ($self->is_factor) {
    my $levels = {};
    my $x_levels = $self->levels;
    my $x_levels_values = $x_levels->values;
    my $levels_length = $x_levels->length_value;
    for (my $i = 1; $i <= $levels_length; $i++) {
      $levels->{$i} = $x_levels_values->[$i - 1];
    }

    my $self_values = $self->values;
    my $x2_values = [];
    for my $self_value (@$self_values) {
      if (defined $self_value) {
        my $character = $levels->{$self_value};
        push @$x2_values, "$character";
      }
      else {
        push @$x2_values, undef;
      }
    }
    $x2 = Rstats::Func::NULL();
    $x2->vector(Rstats::VectorFunc::new_character(@$x2_values));
    
    $self->copy_attrs_to($x2)
  }
  else {
    $x2 = Rstats::Array->new->vector($self->vector->as_character);
    $self->copy_attrs_to($x2);
  }

  return $x2;
}

sub values {
  my $self = shift;
  
  if (@_) {
    $self->vector(Rstats::ArrayFunc::c(@{$_[0]})->vector);
  }
  else {
    my $values = $self->vector->values;
    
    return $values;
  }
}

sub is_vector {
  my $self = shift;
  
  my $is = ref $self eq 'Rstats::Array' && !exists $self->{dim};
  
  return Rstats::Func::new_logical($is);
}

sub is_matrix {
  my $self = shift;

  my $x_is = ref $self eq 'Rstats::Array' && $self->dim->length_value == 2
    ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
  
  return $x_is;
}

sub is_numeric {
  my $self = shift;
  
  my $x_is = ($self->is_array || $self->is_vector) && (($self->vector->type || '') eq 'double' || ($self->vector->type || '') eq 'integer')
    ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
  
  return $x_is;
}

sub is_double {
  my $self = shift;
  
  my $x_is = ($self->is_array || $self->is_vector) && ($self->vector->type || '') eq 'double'
    ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
  
  return $x_is;
}

sub is_integer {
  my $self = shift;
  
  my $x_is = ($self->is_array || $self->is_vector) && ($self->vector->type || '') eq 'integer'
    ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
  
  return $x_is;
}

sub is_complex {
  my $self = shift;
  
  my $x_is = ($self->is_array || $self->is_vector) && ($self->vector->type || '') eq 'complex'
    ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
  
  return $x_is;
}

sub is_character {
  my $self = shift;
  
  my $x_is = ($self->is_array || $self->is_vector) && ($self->vector->type || '') eq 'character'
    ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
  
  return $x_is;
}

sub is_logical {
  my $self = shift;
  
  my $x_is = ($self->is_array || $self->is_vector) && ($self->vector->type || '') eq 'logical'
    ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
  
  return $x_is;
}

sub is_data_frame {
  my $self = shift;
  
  return ref $self eq 'Rstats::DataFrame' ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
}

sub is_array {
  my $self = shift;
  
  my $is = ref $self eq 'Rstats::Array' && exists $self->{dim};
  
  return Rstats::Func::new_logical($is);
}

sub names {
  my $self = shift;
  
  if (@_) {
    my $names = Rstats::Func::to_c(shift);
    
    $names = $names->as_character unless $names->is_character;
    $self->{names} = $names->vector->clone;
    
    if ($self->is_data_frame) {
      $self->{dimnames}[1] = $self->{names}->vector->clone;
    }
    
    return $self;
  }
  else {
    my $x_names = Rstats::Func::NULL();
    if (exists $self->{names}) {
      $x_names->vector($self->{names}->clone);
    }
    return $x_names;
  }
}

sub dimnames {
  my $self = shift;
  
  if (@_) {
    my $dimnames_list = shift;
    if (ref $dimnames_list eq 'Rstats::List') {
      my $length = $dimnames_list->length_value;
      my $dimnames = [];
      for (my $i = 0; $i < $length; $i++) {
        my $x_dimname = $dimnames_list->getin($i + 1);
        if ($x_dimname->is_character) {
          my $dimname = $x_dimname->vector->clone;
          push @$dimnames, $dimname;
        }
        else {
          croak "dimnames must be character list";
        }
      }
      $self->{dimnames} = $dimnames;
      
      if ($self->is_data_frame) {
        $self->{names} = $self->{dimnames}[1]->clone;
      }
    }
    else {
      croak "dimnames must be list";
    }
  }
  else {
    if (exists $self->{dimnames}) {
      my $x_dimnames = Rstats::Func::list();
      $x_dimnames->list($self->{dimnames});
    }
    else {
      return Rstats::Func::NULL();
    }
  }
}

sub rownames {
  my $self = shift;
  
  if (@_) {
    my $x_rownames = Rstats::Func::to_c(shift);
    
    unless (exists $self->{dimnames}) {
      $self->{dimnames} = [];
    }
    
    $self->{dimnames}[0] = $x_rownames->vector->clone;
  }
  else {
    my $x_rownames = Rstats::Func::NULL();
    if (defined $self->{dimnames}[0]) {
      $x_rownames->vector($self->{dimnames}[0]->clone);
    }
    return $x_rownames;
  }
}


sub colnames {
  my $self = shift;
  
  if (@_) {
    my $x_colnames = Rstats::Func::to_c(shift);
    
    unless (exists $self->{dimnames}) {
      $self->{dimnames} = [];
    }
    
    $self->{dimnames}[1] = $x_colnames->vector->clone;
  }
  else {
    my $x_colnames = Rstats::Func::NULL();
    if (defined $self->{dimnames}[1]) {
      $x_colnames->vector($self->{dimnames}[1]->clone);
    }
    return $x_colnames;
  }
}

1;

=head1 NAME

Rstats::Func - Functions

