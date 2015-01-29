package Rstats::Func;

use strict;
use warnings;

require Rstats;

use Rstats::List;
use Carp 'croak';
use Rstats::Vector;
use Rstats::Func::Array;

sub sweep {
  my $r = shift;
  
  my ($x1, $x_margin, $x2, $x_func)
    = Rstats::Func::args_array(undef(), ['x1', 'margin', 'x2', 'FUN'], @_);
  
  my $x_margin_values = $x_margin->values;
  my $func = defined $x_func ? $x_func->value : '-';
  
  my $x2_dim_values = Rstats::Func::dim(undef(), $x2)->values;
  my $x1_dim_values = Rstats::Func::dim(undef(), $x1)->values;
  
  my $x1_length = $x1->length_value;
  
  my $x_result_elements = [];
  for (my $x1_pos = 0; $x1_pos < $x1_length; $x1_pos++) {
    my $x1_index = Rstats::Util::pos_to_index($x1_pos, $x1_dim_values);
    
    my $new_index = [];
    for my $x_margin_value (@$x_margin_values) {
      push @$new_index, $x1_index->[$x_margin_value - 1];
    }
    
    my $e1 = $x2->value(@{$new_index});
    push @$x_result_elements, $e1;
  }
  my $x3 = Rstats::Func::Array::c(undef(), @$x_result_elements);
  
  my $x4;
  if ($func eq '+') {
    $x4 = $x1 + $x3;
  }
  elsif ($func eq '-') {
    $x4 = $x1 - $x3;
  }
  elsif ($func eq '*') {
    $x4 = $x1 * $x3;
  }
  elsif ($func eq '/') {
    $x4 = $x1 / $x3;
  }
  elsif ($func eq '**') {
    $x4 = $x1 ** $x3;
  }
  elsif ($func eq '%') {
    $x4 = $x1 % $x3;
  }
  
  Rstats::Func::copy_attrs_to(undef(), $x1, $x4);
  
  return $x4;
}
  
sub set_seed {
  my ($r, $seed) = @_;
  
  $r->{seed} = $seed;
}

sub runif {
  my $r = shift;

  my ($x_count, $x_min, $x_max)
    =  Rstats::Func::Array::args_array(undef(), ['count', 'min', 'max'], @_);
  
  my $count = $x_count->value;
  my $min = defined $x_min ? $x_min->value : 0;
  my $max = defined $x_max ? $x_max->value : 1;
  Carp::croak "runif third argument must be bigger than second argument"
    if $min > $max;
  
  my $diff = $max - $min;
  my @x1_elements;
  if (defined $r->{seed}) {
    srand $r->{seed};
  }
  
  for (1 .. $count) {
    my $rand = rand($diff) + $min;
    push @x1_elements, $rand;
  }
  
  $r->{seed} = undef;
  
  return Rstats::Func::Array::c(undef(), @x1_elements);
}

sub apply {
  my $r = shift;
  
  my $func_name = splice(@_, 2, 1);
  my $func = ref $func_name ? $func_name : $r->helpers->{$func_name};

  my ($x1, $x_margin)
    = Rstats::Func::args_array(undef(), ['x1', 'margin'], @_);

  my $dim_values = Rstats::Func::dim(undef(), $x1)->values;
  my $margin_values = $x_margin->values;
  my $new_dim_values = [];
  for my $i (@$margin_values) {
    push @$new_dim_values, $dim_values->[$i - 1];
  }
  
  my $x1_length = $x1->length_value;
  my $new_elements_array = [];
  for (my $i = 0; $i < $x1_length; $i++) {
    my $index = Rstats::Util::pos_to_index($i, $dim_values);
    my $e1 = $x1->value(@$index);
    my $new_index = [];
    for my $i (@$margin_values) {
      push @$new_index, $index->[$i - 1];
    }
    my $new_pos = Rstats::Util::index_to_pos($new_index, $new_dim_values);
    $new_elements_array->[$new_pos] ||= [];
    push @{$new_elements_array->[$new_pos]}, $e1;
  }
  
  my $new_elements = [];
  for my $element_array (@$new_elements_array) {
    push @$new_elements, $func->(Rstats::Func::Array::c(undef(), @$element_array));
  }

  my $x2 = Rstats::Func::NULL();
  $x2->vector(Rstats::Func::Array::c(undef(), @$new_elements)->vector);
  Rstats::Func::copy_attrs_to(undef(), $x1, $x2);
  $x2->{dim} = Rstats::Func::Vector::new_integer(@$new_dim_values);
  
  if ($x2->{dim}->length_value == 1) {
    delete $x2->{dim};
  }
  
  return $x2;

}
  
sub mapply {
  my $r = shift;
  
  my $func_name = splice(@_, 0, 1);
  my $func = ref $func_name ? $func_name : $r->helpers->{$func_name};

  my @xs = @_;
  @xs = map { Rstats::Func::Array::c(undef(), $_) } @xs;
  
  # Fix length
  my @xs_length = map { $_->length_value } @xs;
  my $max_length = List::Util::max @xs_length;
  for my $x (@xs) {
    if ($x->length_value < $max_length) {
      $x = Rstats::Func::array(undef(), $x, $max_length);
    }
  }
  
  # Apply
  my $new_xs = [];
  for (my $i = 0; $i < $max_length; $i++) {
    my @args = map { $_->value($i + 1) } @xs;
    my $x = $func->(@args);
    push @$new_xs, $x;
  }
  
  if (@$new_xs == 1) {
    return $new_xs->[0];
  }
  else {
    return Rstats::Func::list(undef(), @$new_xs);
  }
}
  
sub tapply {
  my $r = shift;
  
  my $func_name = splice(@_, 2, 1);
  my $func = ref $func_name ? $func_name : $r->helpers->{$func_name};

  my ($x1, $x2)
    = Rstats::Func::args_array(undef(), ['x1', 'x2'], @_);
  
  my $new_values = [];
  my $x1_values = $x1->values;
  my $x2_values = $x2->values;
  
  # Group values
  for (my $i = 0; $i < $x1->length_value; $i++) {
    my $x1_value = $x1_values->[$i];
    my $index = $x2_values->[$i];
    $new_values->[$index] ||= [];
    push @{$new_values->[$index]}, $x1_value;
  }
  
  # Apply
  my $new_values2 = [];
  for (my $i = 1; $i < @$new_values; $i++) {
    my $x = $func->(Rstats::Func::Array::c(undef(), @{$new_values->[$i]}));
    push @$new_values2, $x;
  }
  
  my $x4_length = @$new_values2;
  my $x4 = Rstats::Func::array(undef(), Rstats::Func::Array::c(undef(), @$new_values2), $x4_length);
  Rstats::Func::names(undef(), $x4, Rstats::Func::levels(undef(), $x2));
  
  return $x4;
}

sub lapply {
  my $r = shift;
  
  my $func_name = splice(@_, 1, 1);
  my $func = ref $func_name ? $func_name : $r->helpers->{$func_name};

  my ($x1) = Rstats::Func::args_array(undef(), ['x1'], @_);
  
  my $new_elements = [];
  for my $element (@{$x1->list}) {
    push @$new_elements, $func->($element);
  }
  
  my $x2 = Rstats::Func::list(undef(), @$new_elements);
  Rstats::Func::copy_attrs_to(undef(), $x1, $x2);
  
  return $x2;
}
  
sub sapply {
  my $r = shift;
  my $x1 = $r->lapply(@_);
  
  my $x2 = Rstats::Func::Array::c(undef(), @{$x1->list});
  
  return $x2;
}

sub to_string { Rstats::Func::Array::to_string(@_) }
sub is_finite { Rstats::Func::Array::is_finite(@_) }
sub is_infinite { Rstats::Func::Array::is_infinite(@_) }
sub is_nan { Rstats::Func::Array::is_nan(@_) }
sub is_null { Rstats::Func::Array::is_null(@_) }
sub getin { Rstats::Func::Array::getin(@_) }
sub get { Rstats::Func::Array::get(@_) }
sub _levels_h { Rstats::Func::Array::_levels_h(@_) }
sub set { Rstats::Func::Array::set(@_) }
sub bool { Rstats::Func::Array::bool(@_) }
sub value { Rstats::Func::Array::value(@_) }
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
sub sample { Rstats::Func::Array::sample(@_) }
sub sequence { Rstats::Func::Array::sequence(@_) }
sub sinh { Rstats::Func::Array::sinh(@_) }
sub sqrt { Rstats::Func::Array::sqrt(@_) }
sub sort { Rstats::Func::Array::sort(@_) }
sub tail { Rstats::Func::Array::tail(@_) }
sub tan { Rstats::Func::Array::tan(@_) }
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

sub decompose {
  my $r = shift;
  
  my $x1 = shift;
  
  if (exists $x1->{vector}) {
    return $x1->vector->decompose;
  }
  else {
    croak "Can't call decompose_elements methods from list";
  }
}

my %types_h = map { $_ => 1 } qw/character complex numeric double integer logical/;

sub copy_attrs_to {
  my $r = shift;
  
  my ($x1, $x2, $opt) = @_;
  
  $opt ||= {};
  my $new_indexes = $opt->{new_indexes};
  my $exclude = $opt->{exclude} || [];
  my %exclude_h = map { $_ => 1 } @$exclude;
  
  # dim
  $x2->{dim} = $x1->{dim}->clone if !$exclude_h{dim} && exists $x1->{dim};
  
  # class
  $x2->{class} =  $x1->{class}->clone if !$exclude_h{class} && exists $x1->{class};
  
  # levels
  $x2->{levels} = $x1->{levels}->clone if !$exclude_h{levels} && exists $x1->{levels};
  
  # names
  if (!$exclude_h{names} && exists $x1->{names}) {
    my $x2_names_values = [];
    my $index = Rstats::Func::is_data_frame(undef(), $x1) ? $new_indexes->[1] : $new_indexes->[0];
    if (defined $index) {
      my $x1_names_values = $x1->{names}->values;
      for my $i (@{$index->values}) {
        push @$x2_names_values, $x1_names_values->[$i - 1];
      }
    }
    else {
      $x2_names_values = $x1->{names}->values;
    }
    $x2->{names} = Rstats::Func::Vector::new_character(@$x2_names_values);
  }
  
  # dimnames
  if (!$exclude_h{dimnames} && exists $x1->{dimnames}) {
    my $new_dimnames = [];
    my $dimnames = $x1->{dimnames};
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
        push @$new_dimnames, Rstats::Func::Vector::new_character(@$new_dimname_values);
      }
    }
    $x2->{dimnames} = $new_dimnames;
  }
}

sub _value_to_string {
  my $r = shift;
  
  my ($x1, $value, $type, $is_factor) = @_;
  
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
  my $r = shift;
  
  my $x1 = shift;
  
  my @str;
  
  if (Rstats::Func::is_vector(undef(), $x1) || is_array(undef(), $x1)) {
    # Short type
    my $type = $x1->vector->type;
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
    my $length = $x1->length_value;
    if (exists $x1->{dim}) {
      my $dim_values = $x1->{dim}->values;
      for (my $i = 0; $i < $x1->{dim}->length_value; $i++) {
        my $d = $dim_values->[$i];
        my $d_str;
        if ($d == 1) {
          $d_str = "1";
        }
        else {
          $d_str = "1:$d";
        }
        
        if ($x1->{dim}->length_value == 1) {
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
    my $is_character = is_character(undef(), $x1);
    my $values = $x1->values;
    for (my $i = 0; $i < $max_count; $i++) {
      push @element_str, Rstats::Func::_value_to_string(undef(), $x1, $values->[$i], $type);
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
  my $r = shift;
  
  my $x1 = shift;
  
  if (@_) {
    my $x_levels = Rstats::Func::to_c(undef(), shift);
    $x_levels = Rstats::Func::as_character(undef(), $x_levels)
      unless is_character(undef(), $x_levels);
    
    $x1->{levels} = $x_levels->vector->clone;
    
    return $x1;
  }
  else {
    my $x_levels = Rstats::Func::NULL();
    if (exists $x1->{levels}) {
      $x_levels->vector($x1->{levels}->clone);
    }
    
    return $x_levels;
  }
}

sub clone {
  my $r = shift;
  
  my $x1 = shift;;
  
  my $clone = Rstats::Func::NULL();
  $clone->vector($x1->vector->clone);
  Rstats::Func::copy_attrs_to(undef(), $x1, $clone);
  
  return $clone;
}

sub at {
  my $r = shift;
  
  my $x1 = shift;
  
  if (@_) {
    $x1->{at} = [@_];
    
    return $x1;
  }
  
  return $x1->{at};
}

sub _name_to_index {
  my $r = shift;
  
  my $x1 = shift;
  my $x1_index = Rstats::Func::to_c(undef(), shift);
  
  my $e1_name = $x1_index->value;
  my $found;
  my $names = Rstats::Func::names(undef(), $x1)->values;
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
  my $r = shift;
  
  my $x1 = shift;
  
  return Rstats::Func::Array::c(undef(), Rstats::Func::levels(undef(), $x1)->length_value);
}

sub length_value {
  my $r = shift;
  
  my $x1 = shift;
  
  my $length;
  if (exists $x1->{vector}) {
    $length = $x1->vector->length_value;
  }
  else {
    $length = @{$x1->list}
  }
  
  return $length;
}

sub is_na {
  my $r = shift;
  
  my $x1 = Rstats::Func::to_c(undef(), shift);
  my $x2_values = [map { !defined $_ ? 1 : 0 } @{$x1->values}];
  my $x2 = Rstats::Func::NULL();
  $x2->vector(Rstats::Func::Vector::new_logical(@$x2_values));
  
  return $x2;
}

sub as_list {
  my $r = shift;
  
  my $x1 = shift;
  
  if (exists $x1->{list}) {
    return $x1;
  }
  else {
    my $list = Rstats::List->new;
    my $x2 = Rstats::Func::NULL();
    $x2->vector($x1->vector->clone);
    $list->list([$x2]);
    
    return $list;
  }
}

sub is_list {
  my $r = shift;
  
  my $x1 = shift;

  return exists $x1->{list} ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
}

sub class {
  my $r = shift;
  
  my $x1 = shift;
  
  if (@_) {
    my $x_class = Rstats::Func::to_c(undef(), $_[0]);
    
    $x1->{class} = $x_class->vector;
    
    return $x1;
  }
  else {
    my $x_class = Rstats::Func::NULL();
    if (exists $x1->{class}) {
      $x_class->vector($x1->{class}->clone);
    }
    elsif (Rstats::Func::is_vector(undef(), $x1)) {
      $x_class->vector(Rstats::Func::mode(undef(), $x1)->vector->clone);
    }
    elsif (is_matrix(undef(), $x1)) {
      $x_class->vector(Rstats::Func::Vector::new_character('matrix'));
    }
    elsif (is_array(undef(), $x1)) {
      $x_class->vector(Rstats::Func::Vector::new_character('array'));
    }
    elsif (Rstats::Func::is_data_frame(undef(), $x1)) {
      $x_class->vector(Rstats::Func::Vector::new_character('data.frame'));
    }
    elsif (is_list(undef(), $x1)) {
      $x_class->vector(Rstats::Func::Vector::new_character('list'));
    }
    
    return $x_class;
  }
}

sub dim_as_array {
  my $r = shift;
  
  my $x1 = shift;
  
  if (exists $x1->{dim}) {
    return Rstats::Func::dim(undef(), $x1);
  }
  else {
    my $length = $x1->length_value;
    return Rstats::Func::new_double(undef(), $length);
  }
}

sub dim {
  my $r = shift;
  
  my $x1 = shift;
  
  if (@_) {
    my $x_dim = Rstats::Func::to_c(undef(), $_[0]);
    my $x1_length = $x1->length_value;
    my $x1_lenght_by_dim = 1;
    $x1_lenght_by_dim *= $_ for @{$x_dim->values};
    
    if ($x1_length != $x1_lenght_by_dim) {
      croak "dims [product $x1_lenght_by_dim] do not match the length of object [$x1_length]";
    }
  
    $x1->{dim} = $x_dim->vector->clone;
    
    return $x1;
  }
  else {
    my $x_dim = Rstats::Func::NULL();
    if (defined $x1->{dim}) {
      $x_dim->vector($x1->{dim}->clone);
    }
    
    return $x_dim;
  }
}

sub mode {
  my $r = shift;
  
  my $x1 = shift;
  
  if (@_) {
    my $type = $_[0];
    croak qq/Error in eval(expr, envir, enclos) : could not find function "as_$type"/
      unless $types_h{$type};
    
    $x1->vector($x1->vector->as($type));
    
    return $x1;
  }
  else {
    my $type = $x1->vector->type;
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

    return Rstats::Func::Array::c(undef(), $mode);
  }
}

sub typeof {
  my $r = shift;
  
  my $x1 = shift;
  
  if (Rstats::Func::is_vector(undef(), $x1) || is_array(undef(), $x1)) {
    my $type = $x1->vector->type;
    return Rstats::Func::new_character(undef(), $type);
  }
  elsif (is_list(undef(), $x1)) {
    return Rstats::Func::new_character(undef(), 'list');
  }
  else {
    return Rstats::Func::NA();
  }
}

sub type {
  my $r = shift;
  return shift->vector->type;
}

sub is_factor {
  my $r = shift;
  
  my $x1 = shift;
  
  my $classes = $x1->class->values;
  
  my $is = grep { $_ eq 'factor' } @$classes;
  
  return $is ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
}

sub is_ordered {
  my $r = shift;
  
  my $x1 = shift;
  
  my $classes = $x1->class->values;

  my $is = grep { $_ eq 'ordered' } @$classes;
  
  return $is ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
}

sub as_factor {
  my $r = shift;
  
  my $x1 = shift;
  
  if (Rstats::Func::is_factor(undef(), $x1)) {
    return $x1;
  }
  else {
    my $a = is_character(undef(), $x1) ? $x1 :  Rstats::Func::as_character(undef(), $x1);
    my $f = Rstats::Func::Array::factor(undef(), $a);
    
    return $f;
  }
}

sub as_matrix {
  my $r = shift;
  
  my $x1 = shift;
  
  my $x1_dim_elements = $x1->dim_as_array->values;
  my $x1_dim_count = @$x1_dim_elements;
  my $x2_dim_elements = [];
  my $row;
  my $col;
  if ($x1_dim_count == 2) {
    $row = $x1_dim_elements->[0];
    $col = $x1_dim_elements->[1];
  }
  else {
    $row = 1;
    $row *= $_ for @$x1_dim_elements;
    $col = 1;
  }
  
  my $x2 = Rstats::Func::NULL();
  my $x2_vector = $x1->vector->clone;
  $x2->vector($x2_vector);
  
  return Rstats::Func::matrix(undef(), $x2, $row, $col);
}

sub as_array {
  my $r = shift;
  
  my $x1 = shift;

  my $x2 = Rstats::Func::NULL();
  my $x2_vector = $x1->vector->clone;
  $x2->vector($x2_vector);

  my $x1_dim_elements = [@{$x1->dim_as_array->values}];
  
  return array(undef(), $x1, $x2, $x1_dim_elements);
}

sub as_vector {
  my $r = shift;
  
  my $x1 = shift;
  
  my $x2 = Rstats::Func::NULL();
  my $x2_vector = $x1->vector->clone;
  $x2->vector($x2_vector);
  
  return $x2;
}

sub as {
  my $r = shift;
  
  my ($x1, $type) = @_;
  
  if ($type eq 'character') {
    return as_character(undef(), $x1);
  }
  elsif ($type eq 'complex') {
    return as_complex(undef(), $x1);
  }
  elsif ($type eq 'double') {
    return as_double(undef(), $x1);
  }
  elsif ($type eq 'numeric') {
    return as_numeric(undef(), $x1);
  }
  elsif ($type eq 'integer') {
    return as_integer(undef(), $x1);
  }
  elsif ($type eq 'logical') {
    return as_logical(undef(), $x1);
  }
  else {
    croak "Invalid mode is passed";
  }
}

sub as_complex {
  my $r = shift;
  
  my $x1 = shift;

  my $x_tmp;
  if (Rstats::Func::is_factor(undef(), $x1)) {
    $x_tmp = Rstats::Func::as_integer(undef(), $x1);
  }
  else {
    $x_tmp = $x1;
  }

  my $x2;
  $x2 = Rstats::Array->new->vector($x_tmp->vector->as_complex);
  Rstats::Func::copy_attrs_to(undef(), $x_tmp, $x2);

  return $x2;
}

sub as_numeric {
  my $r = shift;
  
  as_double(undef(), @_);
}

sub as_double {
  my $r = shift;
  
  my $x1 = shift;
  
  my $x2;
  if (Rstats::Func::is_factor(undef(), $x1)) {
    $x2 = Rstats::Array->new->vector($x1->vector->as_double);
  }
  else {
    $x2 = Rstats::Array->new->vector($x1->vector->as_double);
    Rstats::Func::copy_attrs_to(undef(), $x1, $x2);
  }

  return $x2;
}

sub as_integer {
  my $r = shift;
  
  my $x1 = shift;
  
  my $x2;
  if (Rstats::Func::is_factor(undef(), $x1)) {
    $x2 = Rstats::Array->new->vector($x1->vector->as_integer);
  }
  else {
    $x2 = Rstats::Array->new->vector($x1->vector->as_integer);
    Rstats::Func::copy_attrs_to(undef(), $x1, $x2);
  }

  return $x2;
}

sub as_logical {
  my $r = shift;
  
  my $x1 = shift;
  
  my $x2;
  if (Rstats::Func::is_factor(undef(), $x1)) {
    $x2 = Rstats::Array->new->vector($x1->vector->as_logical);
  }
  else {
    $x2 = Rstats::Array->new->vector($x1->vector->as_logical);
    Rstats::Func::copy_attrs_to(undef(), $x1, $x2);
  }

  return $x2;
}

sub labels {
  my $r = shift;
  return $r->as_character(@_);
}

sub as_character {
  my $r = shift;
  
  my $x1 = shift;
  
  my $x2;
  if (Rstats::Func::is_factor(undef(), $x1)) {
    my $levels = {};
    my $x_levels = Rstats::Func::levels(undef(), $x1);
    my $x_levels_values = $x_levels->values;
    my $levels_length = $x_levels->length_value;
    for (my $i = 1; $i <= $levels_length; $i++) {
      $levels->{$i} = $x_levels_values->[$i - 1];
    }

    my $x1_values = $x1->values;
    my $x2_values = [];
    for my $x1_value (@$x1_values) {
      if (defined $x1_value) {
        my $character = $levels->{$x1_value};
        push @$x2_values, "$character";
      }
      else {
        push @$x2_values, undef;
      }
    }
    $x2 = Rstats::Func::NULL();
    $x2->vector(Rstats::Func::Vector::new_character(@$x2_values));
    
    Rstats::Func::copy_attrs_to(undef(), $x1, $x2);
  }
  else {
    $x2 = Rstats::Array->new->vector($x1->vector->as_character);
    Rstats::Func::copy_attrs_to(undef(), $x1, $x2);
  }

  return $x2;
}

sub values {
  my $r = shift;
  
  my $x1 = shift;
  
  if (@_) {
    $x1->vector(Rstats::Func::Array::c(undef(), @{$_[0]})->vector);
  }
  else {
    my $values = $x1->vector->values;
    
    return $values;
  }
}

sub is_vector {
  my $r = shift;
  
  my $x1 = shift;
  
  my $is = ref $x1 eq 'Rstats::Array' && !exists $x1->{dim};
  
  return Rstats::Func::new_logical(undef(), $is);
}

sub is_matrix {
  my $r = shift;
  
  my $x1 = shift;

  my $x_is = ref $x1 eq 'Rstats::Array' && Rstats::Func::dim(undef(), $x1)->length_value == 2
    ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
  
  return $x_is;
}

sub is_numeric {
  my $r = shift;
  
  my $x1 = shift;
  
  my $x_is = (is_array(undef(), $x1) || Rstats::Func::is_vector(undef(), $x1)) && (($x1->vector->type || '') eq 'double' || ($x1->vector->type || '') eq 'integer')
    ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
  
  return $x_is;
}

sub is_double {
  my $r = shift;
  
  my $x1 = shift;
  
  my $x_is = (is_array(undef(), $x1) || Rstats::Func::is_vector(undef(), $x1)) && ($x1->vector->type || '') eq 'double'
    ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
  
  return $x_is;
}

sub is_integer {
  my $r = shift;
  
  my $x1 = shift;
  
  my $x_is = (is_array(undef(), $x1) || Rstats::Func::is_vector(undef(), $x1)) && ($x1->vector->type || '') eq 'integer'
    ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
  
  return $x_is;
}

sub is_complex {
  my $r = shift;
  
  my $x1 = shift;
  
  my $x_is = (is_array(undef(), $x1) || Rstats::Func::is_vector(undef(), $x1)) && ($x1->vector->type || '') eq 'complex'
    ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
  
  return $x_is;
}

sub is_character {
  my $r = shift;
  
  my $x1 = shift;
  
  my $x_is = (is_array(undef(), $x1) || Rstats::Func::is_vector(undef(), $x1)) && ($x1->vector->type || '') eq 'character'
    ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
  
  return $x_is;
}

sub is_logical {
  my $r = shift;
  
  my $x1 = shift;
  
  my $x_is = (is_array(undef(), $x1) || Rstats::Func::is_vector(undef(), $x1)) && ($x1->vector->type || '') eq 'logical'
    ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
  
  return $x_is;
}

sub is_data_frame {
  my $r = shift;
  
  my $x1 = shift;
  
  return ref $x1 eq 'Rstats::DataFrame' ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
}

sub is_array {
  my $r = shift;
  
  my $x1 = shift;
  
  my $is = ref $x1 eq 'Rstats::Array' && exists $x1->{dim};
  
  return Rstats::Func::new_logical(undef(), $is);
}

sub names {
  my $r = shift;
  
  my $x1 = shift;
  
  if (@_) {
    my $names = Rstats::Func::to_c(undef(), shift);
    
    $names = Rstats::Func::as_character(undef(), $names) unless is_character(undef(), $names);
    $x1->{names} = $names->vector->clone;
    
    if (Rstats::Func::is_data_frame(undef(), $x1)) {
      $x1->{dimnames}[1] = $x1->{names}->vector->clone;
    }
    
    return $x1;
  }
  else {
    my $x_names = Rstats::Func::NULL();
    if (exists $x1->{names}) {
      $x_names->vector($x1->{names}->clone);
    }
    return $x_names;
  }
}

sub dimnames {
  my $r = shift;
  
  my $x1 = shift;
  
  if (@_) {
    my $dimnames_list = shift;
    if (ref $dimnames_list eq 'Rstats::List') {
      my $length = $dimnames_list->length_value;
      my $dimnames = [];
      for (my $i = 0; $i < $length; $i++) {
        my $x_dimname = $dimnames_list->getin($i + 1);
        if (is_character(undef(), $x_dimname)) {
          my $dimname = $x_dimname->vector->clone;
          push @$dimnames, $dimname;
        }
        else {
          croak "dimnames must be character list";
        }
      }
      $x1->{dimnames} = $dimnames;
      
      if (Rstats::Func::is_data_frame(undef(), $x1)) {
        $x1->{names} = $x1->{dimnames}[1]->clone;
      }
    }
    else {
      croak "dimnames must be list";
    }
  }
  else {
    if (exists $x1->{dimnames}) {
      my $x_dimnames = Rstats::Func::list(undef());
      $x_dimnames->list($x1->{dimnames});
    }
    else {
      return Rstats::Func::NULL();
    }
  }
}

sub rownames {
  my $r = shift;
  
  my $x1 = shift;
  
  if (@_) {
    my $x_rownames = Rstats::Func::to_c(undef(), shift);
    
    unless (exists $x1->{dimnames}) {
      $x1->{dimnames} = [];
    }
    
    $x1->{dimnames}[0] = $x_rownames->vector->clone;
  }
  else {
    my $x_rownames = Rstats::Func::NULL();
    if (defined $x1->{dimnames}[0]) {
      $x_rownames->vector($x1->{dimnames}[0]->clone);
    }
    return $x_rownames;
  }
}


sub colnames {
  my $r = shift;
  
  my $x1 = shift;
  
  if (@_) {
    my $x_colnames = Rstats::Func::to_c(undef(), shift);
    
    unless (exists $x1->{dimnames}) {
      $x1->{dimnames} = [];
    }
    
    $x1->{dimnames}[1] = $x_colnames->vector->clone;
  }
  else {
    my $x_colnames = Rstats::Func::NULL();
    if (defined $x1->{dimnames}[1]) {
      $x_colnames->vector($x1->{dimnames}[1]->clone);
    }
    return $x_colnames;
  }
}

1;

=head1 NAME

Rstats::Func - Functions

