package Rstats::Func;

use strict;
use warnings;

require Rstats;

use Rstats::List;
use Carp 'croak';
use Rstats::Vector;
use Rstats::ArrayFunc;

sub sweep {
  my $r = shift;
  
  my ($x1, $x_margin, $x2, $x_func)
    = Rstats::Func::args_array(['x1', 'margin', 'x2', 'FUN'], @_);
  
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
  my $x3 = Rstats::ArrayFunc::c(undef(), @$x_result_elements);
  
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
    =  Rstats::ArrayFunc::args_array(['count', 'min', 'max'], @_);
  
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
  
  return Rstats::ArrayFunc::c(undef(), @x1_elements);
}

sub apply {
  my $r = shift;
  
  my $func_name = splice(@_, 2, 1);
  my $func = ref $func_name ? $func_name : $r->helpers->{$func_name};

  my ($x1, $x_margin)
    = Rstats::Func::args_array(['x1', 'margin'], @_);

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
    push @$new_elements, $func->(Rstats::ArrayFunc::c(undef(), @$element_array));
  }

  my $x2 = Rstats::Func::NULL();
  $x2->vector(Rstats::ArrayFunc::c(undef(), @$new_elements)->vector);
  Rstats::Func::copy_attrs_to(undef(), $x1, $x2);
  $x2->{dim} = Rstats::VectorFunc::new_integer(@$new_dim_values);
  
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
  @xs = map { Rstats::ArrayFunc::c(undef(), $_) } @xs;
  
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
    = Rstats::Func::args_array(['x1', 'x2'], @_);
  
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
    my $x = $func->(Rstats::ArrayFunc::c(undef(), @{$new_values->[$i]}));
    push @$new_values2, $x;
  }
  
  my $x4_length = @$new_values2;
  my $x4 = Rstats::Func::array(undef(), Rstats::ArrayFunc::c(undef(), @$new_values2), $x4_length);
  Rstats::Func::names(undef(), $x4, Rstats::Func::levels(undef(), $x2));
  
  return $x4;
}

sub lapply {
  my $r = shift;
  
  my $func_name = splice(@_, 1, 1);
  my $func = ref $func_name ? $func_name : $r->helpers->{$func_name};

  my ($x1) = Rstats::Func::args_array(['x1'], @_);
  
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
  
  my $x2 = Rstats::ArrayFunc::c(undef(), @{$x1->list});
  
  return $x2;
}

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
    $x2->{names} = Rstats::VectorFunc::new_character(@$x2_names_values);
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
        push @$new_dimnames, Rstats::VectorFunc::new_character(@$new_dimname_values);
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
    my $x_levels = Rstats::Func::to_c(shift);
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
  my $x1 = shift;
  
  if (@_) {
    $x1->{at} = [@_];
    
    return $x1;
  }
  
  return $x1->{at};
}

sub _name_to_index {
  my $x1 = shift;
  my $x1_index = Rstats::Func::to_c(shift);
  
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
  
  return Rstats::ArrayFunc::c(undef(), Rstats::Func::levels(undef(), $x1)->length_value);
}

sub length_value {
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
  
  my $x1 = Rstats::Func::to_c(shift);
  my $x2_values = [map { !defined $_ ? 1 : 0 } @{$x1->values}];
  my $x2 = Rstats::Func::NULL();
  $x2->vector(Rstats::VectorFunc::new_logical(@$x2_values));
  
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
  my $x1 = shift;
  
  if (@_) {
    my $x_class = Rstats::Func::to_c($_[0]);
    
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
      $x_class->vector(Rstats::VectorFunc::new_character('matrix'));
    }
    elsif (is_array(undef(), $x1)) {
      $x_class->vector(Rstats::VectorFunc::new_character('array'));
    }
    elsif (Rstats::Func::is_data_frame(undef(), $x1)) {
      $x_class->vector(Rstats::VectorFunc::new_character('data.frame'));
    }
    elsif (is_list(undef(), $x1)) {
      $x_class->vector(Rstats::VectorFunc::new_character('list'));
    }
    
    return $x_class;
  }
}

sub dim_as_array {
  my $x1 = shift;
  
  if (exists $x1->{dim}) {
    return Rstats::Func::dim(undef(), $x1);
  }
  else {
    my $length = $x1->length_value;
    return Rstats::Func::new_double($length);
  }
}

sub dim {
  my $r = shift;
  
  my $x1 = shift;
  
  if (@_) {
    my $x_dim = Rstats::Func::to_c($_[0]);
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

    return Rstats::ArrayFunc::c(undef(), $mode);
  }
}

sub typeof {
  my $r = shift;
  
  my $x1 = shift;
  
  if (Rstats::Func::is_vector(undef(), $x1) || is_array(undef(), $x1)) {
    my $type = $x1->vector->type;
    return Rstats::Func::new_character($type);
  }
  elsif (is_list(undef(), $x1)) {
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
    my $f = Rstats::ArrayFunc::factor(undef(), $a);
    
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

sub as_numeric { as_double(@_) }

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
    $x2->vector(Rstats::VectorFunc::new_character(@$x2_values));
    
    Rstats::Func::copy_attrs_to(undef(), $x1, $x2);
  }
  else {
    $x2 = Rstats::Array->new->vector($x1->vector->as_character);
    Rstats::Func::copy_attrs_to(undef(), $x1, $x2);
  }

  return $x2;
}

sub values {
  my $x1 = shift;
  
  if (@_) {
    $x1->vector(Rstats::ArrayFunc::c(undef(), @{$_[0]})->vector);
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
  
  return Rstats::Func::new_logical($is);
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
  
  return Rstats::Func::new_logical($is);
}

sub names {
  my $r = shift;
  
  my $x1 = shift;
  
  if (@_) {
    my $names = Rstats::Func::to_c(shift);
    
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
    my $x_rownames = Rstats::Func::to_c(shift);
    
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
    my $x_colnames = Rstats::Func::to_c(shift);
    
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

