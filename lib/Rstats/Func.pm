package Rstats::Func;

use strict;
use warnings;
use Carp qw/croak carp/;

use Rstats::Container::Array;
use Rstats::Container::List;
use Rstats::Container::DataFrame;
use Rstats::Container::Factor;
use Rstats::ElementFunc;

use List::Util;
use Math::Trig ();
use POSIX ();
use Math::Round ();

sub NULL { Rstats::Container::Array->new(elements => [], dim => [], type => 'logical') }

sub NA { c(Rstats::ElementFunc::NA()) }

sub NaN { c(Rstats::ElementFunc::NaN()) }

sub Inf () { c(Rstats::ElementFunc::Inf()) }

sub negativeInf () { c(Rstats::ElementFunc::negativeInf()) }

sub FALSE () { c(Rstats::ElementFunc::FALSE()) }
sub F () { FALSE }

sub TRUE () { c(Rstats::ElementFunc::TRUE()) }
sub T () { TRUE }

sub pi () { c(Rstats::ElementFunc::pi()) }

sub interaction {
  my $opt;
  $opt = ref $_[-1] eq 'HASH' ? pop : {};
  my @arrays = map { to_c($_)->as_factor } @_;
  my ($a_drop, $a_sep);
  ($a_drop, $a_sep) = args(['drop', 'sep'], $opt);
  
  $a_sep = c(".") unless defined $a_sep;
  my $sep = $a_sep->value;
  
  $a_drop = Rstats::Func::FALSE unless defined $a_drop;
  
  my $max_length;
  my $values_list = [];
  for my $array (@arrays) {
    my $length = $array->length->value;
    $max_length = $length if !defined $max_length || $length > $max_length;
  }
  
  # Elements
  my $f1_elements = [];
  for (my $i = 0; $i < $max_length; $i++) {
    my $chars = [];
    for my $array (@arrays) {
      my $fix_array = $array->as_character;
      my $length = $fix_array->length_value;
      push @$chars, $fix_array->value(($i % $length) + 1)
    }
    my $value = join $sep, @$chars;
    push @$f1_elements, $value;
  }
  
  # Levels
  my $f1;
  my $f1_levels_elements = [];
  if ($a_drop) {
    $f1_levels_elements = $f1_elements;
    $f1 = factor($f1_elements);
  }
  else {
    my $levels = [];
    for my $array (@arrays) {
      push @$levels, $array->levels->values;
    }
    my $cps = Rstats::Util::cross_product($levels);
    for my $cp (@$cps) {
      my $value = join $sep, @$cp;
      push @$f1_levels_elements, $value;
    }
    $f1_levels_elements = [sort {$a cmp $b} @$f1_levels_elements];
    $f1 = factor($f1_elements, {levels => $f1_levels_elements});
  }
  
  return $f1;
}

sub gl {
  my ($a_n, $a_k, $a_length, $a_labels, $a_ordered)
    = args([qw/n k length labels ordered/], @_);
  
  my $n = $a_n->value;
  my $k = $a_k->value;
  $a_length = c($n * $k) unless defined $a_length;
  my $length = $a_length->value;
  
  my $a_levels = c(1 .. $n);
  $a_levels = $a_levels->as_character;
  my $levels = $a_levels->values;
  
  my $a_x_elements = [];
  my $level = 1;
  my $j = 1;
  for (my $i = 0; $i < $length; $i++) {
    if ($j > $k) {
      $j = 1;
      $level++;
    }
    if ($level > @$levels) {
      $level = 1;
    }
    push @$a_x_elements, $level;
    $j++;
  }
  
  my $a_x = c($a_x_elements);
  
  $a_labels = $a_levels unless defined $a_labels;
  $a_ordered = Rstats::Func::FALSE() unless defined $a_ordered;
  
  return factor($a_x, {levels => $a_levels, labels => $a_labels, ordered => $a_ordered});
}

sub ordered {
  my $opt = ref $_[-1] eq 'HASH' ? pop : {};
  $opt->{ordered} = Rstats::Func::TRUE();
  
  factor(@_, $opt);
}

sub factor {
  my ($a_x, $a_levels, $a_labels, $a_exclude, $a_ordered)
    = args([qw/x levels labels exclude ordered/], @_);

  # default - x
  $a_x = $a_x->as_character unless $a_x->is_character;
  
  # default - levels
  unless (defined $a_levels) {
    $a_levels = Rstats::Func::sort(unique($a_x), {'na.last' => TRUE});
  }
  
  # default - exclude
  $a_exclude = NA unless defined $a_exclude;
  
  # fix levels
  if (!$a_exclude->is_na && $a_exclude->length->value) {
    my $new_a_levels_elements = [];
    for my $a_levels_element (@{$a_levels->elements}) {
      my $match;
      for my $a_exclude_element (@{$a_exclude->elements}) {
        my $is_equal = Rstats::ElementFunc::equal($a_levels_element, $a_exclude_element);
        if (!$is_equal->is_na && $is_equal) {
          $match = 1;
          last;
        }
      }
      push $new_a_levels_elements, $a_levels_element unless $match;
    }
    $a_levels = c($new_a_levels_elements);
  }
  
  # default - labels
  unless (defined $a_labels) {
    $a_labels = $a_levels;
  }
  
  # default - ordered
  $a_ordered = $a_x->is_ordered unless defined $a_ordered;
  
  my $a_x_elements = $a_x->elements;
  
  my $labels_length = $a_labels->length->value;
  my $levels_length = $a_levels->length->value;
  if ($labels_length == 1 && $a_x->length_value != 1) {
    my $value = $a_labels->value;
    $a_labels = paste($value, C("1:$levels_length"), {sep => ""});
  }
  elsif ($labels_length != $levels_length) {
    croak("Error in factor 'labels'; length $labels_length should be 1 or $levels_length");
  }
  
  # Levels hash
  my $levels;
  my $a_levels_elements = $a_levels->elements;
  for (my $i = 1; $i <= $levels_length; $i++) {
    my $a_levels_element = $a_levels_elements->[$i - 1];
    my $value = $a_levels_element->value;
    $levels->{$value} = $i;
  }
  
  my $f1_elements = [];
  for my $a_x_element (@$a_x_elements) {
    if ($a_x_element->is_na) {
      push @$f1_elements, Rstats::ElementFunc::NA();
    }
    else {
      my $value = $a_x_element->value;
      my $f1_element = exists $levels->{$value}
        ? Rstats::ElementFunc::integer($levels->{$value})
        : Rstats::ElementFunc::NA();
      push @$f1_elements, $f1_element;
    }
  }
  
  my $f1 = Rstats::Container::Array->new;
  $f1->elements($f1_elements);
  $f1->{type} = 'integer';
  if ($a_ordered) {
    $f1->{class} = ['factor', 'ordered'];
  }
  else {
    $f1->{class} = ['factor'];
  }
  $f1->{levels} = $a_labels;
  
  return $f1;
}

sub length {
  my $container = shift;
  
  return $container->length;
}

sub list {
  my @elements = @_;
  
  @elements = map { ref $_ ne 'Rstats::Container::List' ? Rstats::Func::to_c($_) : $_ } @elements;
  
  my $list = Rstats::Container::List->new;
  $list->elements(\@elements);
  
  return $list;
}

sub is_list {
  my $container = shift;
  
  return ref $container eq 'Rstats::Container::List' ? Rstats::Func::TRUE : Rstats::Func::FALSE;
}

sub data_frame {
  my @data = @_;
  
  my $elements = [];
  
  # name count
  my $name_count = {
    
  };
  
  # count
  my $counts = [];
  my $names = [];
  while (my ($name, $v) = splice(@data, 0, 2)) {
    my $dim_values = $v->dim->values;
    if (@$dim_values > 1) {
      my $count = $dim_values->[0];
      my $dim_product = 1;
      $dim_product *= $dim_values->[$_] for (1 .. @$dim_values - 1);
      
      for my $num (1 .. $dim_product) {
        push @$counts, $count;
        my $fix_name;
        if (my $count = $name_count->{$name}) {
          $fix_name = "$name.$count";
        }
        else {
          $fix_name = $name;
        }
        push @$names, $fix_name;
        push @$elements, splice(@{$v->elements}, 0, $count);
      }
    }
    else {
      my $count = $v->length_value;
      push @$counts, $count;
      my $fix_name;
      if (my $count = $name_count->{$name}) {
        $fix_name = "$name.$count";
      }
      else {
        $fix_name = $name;
      }
      push @$names, $fix_name;
      push @$elements, $v;
    }
    $name_count->{$name}++;
  }
  
  # Max count
  my $max_count = List::Util::max @$counts;
  
  # Check multiple number
  for my $count (@$counts) {
    if ($max_count % $count != 0) {
      croak "Error in data.frame: arguments imply differing number of rows: @$counts";
    }
  }
  
  # Fill vector
  for (my $i = 0; $i < @$counts; $i++) {
    my $count = $counts->[$i];
    
    my $repeat = $max_count / $count;
    if ($repeat > 1) {
      $elements->[$i] = Rstats::Func::c(($elements->[$i]) x $repeat);
    }
  }

  my $data_frame = Rstats::Container::DataFrame->new;
  $data_frame->elements($elements);
  $data_frame->names(Rstats::Func::c($names));
  
  return $data_frame;
}

sub upper_tri {
  my ($a1_m, $a1_diag) = args(['m', 'diag'], @_);
  
  my $diag = defined $a1_diag ? $a1_diag->element : FALSE;
  
  my $a2_elements = [];
  if ($a1_m->is_matrix) {
    my $a1_dim_values = $a1_m->dim->values;
    my $rows_count = $a1_dim_values->[0];
    my $cols_count = $a1_dim_values->[1];
    
    for (my $col = 0; $col < $cols_count; $col++) {
      for (my $row = 0; $row < $rows_count; $row++) {
        my $a2_element;
        if ($diag) {
          $a2_element = $col >= $row ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
        }
        else {
          $a2_element = $col > $row ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
        }
        push @$a2_elements, $a2_element;
      }
    }
    
    my $a2 = matrix($a2_elements, $rows_count, $cols_count);
    
    return $a2;
  }
  else {
    croak 'Not implemented';
  }
}

sub lower_tri {
  my ($a1_m, $a1_diag) = args(['m', 'diag'], @_);
  
  my $diag = defined $a1_diag ? $a1_diag->element : FALSE;
  
  my $a2_elements = [];
  if ($a1_m->is_matrix) {
    my $a1_dim_values = $a1_m->dim->values;
    my $rows_count = $a1_dim_values->[0];
    my $cols_count = $a1_dim_values->[1];
    
    for (my $col = 0; $col < $cols_count; $col++) {
      for (my $row = 0; $row < $rows_count; $row++) {
        my $a2_element;
        if ($diag) {
          $a2_element = $col <= $row ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
        }
        else {
          $a2_element = $col < $row ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
        }
        push @$a2_elements, $a2_element;
      }
    }
    
    my $a2 = matrix($a2_elements, $rows_count, $cols_count);
    
    return $a2;
  }
  else {
    croak 'Not implemented';
  }
}

sub diag {
  my $a1 = to_c(shift);
  
  my $size;
  my $a2_elements;
  if ($a1->length_value == 1) {
    $size = $a1->value;
    $a2_elements = [];
    push @$a2_elements, Rstats::ElementFunc::double(1) for (1 .. $size);
  }
  else {
    $size = $a1->length_value;
    $a2_elements = $a1->elements;
  }
  
  my $a2 = matrix(0, $size, $size);
  for (my $i = 0; $i < $size; $i++) {
    $a2->at($i + 1, $i + 1);
    $a2->set($a2_elements->[$i]);
  }
  
  return $a2;
}

sub set_diag {
  my $a1 = to_c(shift);
  my $a2 = to_c(shift);
  
  my $a2_elements;
  my $a1_dim_values = $a1->dim->values;
  my $size = $a1_dim_values->[0] < $a1_dim_values->[1] ? $a1_dim_values->[0] : $a1_dim_values->[1];
  
  $a2 = array($a2, $size);
  $a2_elements = $a2->elements;
  
  for (my $i = 0; $i < $size; $i++) {
    $a1->at($i + 1, $i + 1);
    $a1->set($a2_elements->[$i]);
  }
  
  return $a1;
}

sub kronecker {
  my $a1 = to_c(shift);
  my $a2 = to_c(shift);
  
  ($a1, $a2) = upgrade_type($a1, $a2) if $a1->type ne $a2->type;
  
  my $a1_dim = $a1->dim;
  my $a2_dim = $a2->dim;
  my $dim_max_length
    = $a1_dim->length_value > $a2_dim->length_value ? $a1_dim->length_value : $a2_dim->length_value;
  
  my $a3_dim_values = [];
  my $a1_dim_values = $a1_dim->values;
  my $a2_dim_values = $a2_dim->values;
  for (my $i = 0; $i < $dim_max_length; $i++) {
    my $a1_dim_value = $a1_dim_values->[$i] || 1;
    my $a2_dim_value = $a2_dim_values->[$i] || 1;
    my $a3_dim_value = $a1_dim_value * $a2_dim_value;
    push @$a3_dim_values, $a3_dim_value;
  }
  
  my $a3_dim_product = 1;
  $a3_dim_product *= $_ for @{$a3_dim_values};
  
  my $a3_elements = [];
  for (my $i = 0; $i < $a3_dim_product; $i++) {
    my $a3_index = Rstats::Util::pos_to_index($i, $a3_dim_values);
    my $a1_index = [];
    my $a2_index = [];
    for (my $k = 0; $k < @$a3_index; $k++) {
      my $a3_i = $a3_index->[$k];
      
      my $a1_dim_value = $a1_dim_values->[$k] || 1;
      my $a2_dim_value = $a2_dim_values->[$k] || 1;

      my $a1_ind = int(($a3_i - 1)/$a2_dim_value) + 1;
      push @$a1_index, $a1_ind;
      my $a2_ind = $a3_i - $a2_dim_value * ($a1_ind - 1);
      push @$a2_index, $a2_ind;
    }
    my $a1_element = $a1->element(@$a1_index);
    my $a2_element = $a2->element(@$a2_index);
    my $a3_element = multiply($a1_element, $a2_element);
    push @$a3_elements, $a3_element;
  }

  my $a3 = array($a3_elements, c($a3_dim_values));
  
  return $a3;
}

sub outer {
  my $a1 = to_c(shift);
  my $a2 = to_c(shift);
  
  ($a1, $a2) = upgrade_type($a1, $a2) if $a1->type ne $a2->type;
  
  my $a1_dim = $a1->dim;
  my $a2_dim = $a2->dim;
  my $a3_dim = [@{$a1_dim->values}, @{$a2_dim->values}];
  
  my $indexs = [];
  for my $a3_d (@$a3_dim) {
    push @$indexs, [1 .. $a3_d];
  }
  my $poses = Rstats::Util::cross_product($indexs);
  
  my $a1_dim_length = $a1_dim->length_value;
  my $a3_elements = [];
  for my $pos (@$poses) {
    my $pos_tmp = [@$pos];
    my $a1_pos = [splice @$pos_tmp, 0, $a1_dim_length];
    my $a2_pos = $pos_tmp;
    my $a1_element = $a1->element(@$a1_pos);
    my $a2_element = $a2->element(@$a2_pos);
    my $a3_element = Rstats::ElementFunc::multiply($a1_element, $a2_element);
    push @$a3_elements, $a3_element;
  }
  
  my $a3 = array($a3_elements, c($a3_dim));
  
  return $a3;
}

sub Arg {
  my $a1 = to_c(shift);
  
  my @a2_elements = map { Rstats::ElementFunc::Arg($_) } @{$a1->elements};
  my $a2 = $a1->clone(elements => \@a2_elements);
  
  return $a2;
}

sub sub {
  my ($a1_pattern, $a1_replacement, $a1_x, $a1_ignore_case)
    = args(['pattern', 'replacement', 'x', 'ignore.case'], @_);
  
  my $pattern = $a1_pattern->value;
  my $replacement = $a1_replacement->value;
  my $ignore_case = defined $a1_ignore_case ? $a1_ignore_case->element : FALSE;
  
  my $a2_elements = [];
  for my $x_e (@{$a1_x->elements}) {
    if ($x_e->is_na) {
      push @$a2_elements, $x_e;
    }
    else {
      my $x = $x_e->value;
      if ($ignore_case) {
        $x =~ s/$pattern/$replacement/i;
      }
      else {
        $x =~ s/$pattern/$replacement/;
      }
      push @$a2_elements, Rstats::ElementFunc::character($x);
    }
  }
  
  my $a2 = $a1_x->clone(elements => $a2_elements);
  
  return $a2;
}

sub gsub {
  my ($a1_pattern, $a1_replacement, $a1_x, $a1_ignore_case)
    = args(['pattern', 'replacement', 'x', 'ignore.case'], @_);
  
  my $pattern = $a1_pattern->value;
  my $replacement = $a1_replacement->value;
  my $ignore_case = defined $a1_ignore_case ? $a1_ignore_case->element : FALSE;
  
  my $a2_elements = [];
  for my $x_e (@{$a1_x->elements}) {
    if ($x_e->is_na) {
      push @$a2_elements, $x_e;
    }
    else {
      my $x = $x_e->{cv};
      if ($ignore_case) {
        $x =~ s/$pattern/$replacement/gi;
      }
      else {
        $x =~ s/$pattern/$replacement/g;
      }
      push @$a2_elements, Rstats::ElementFunc::character($x);
    }
  }
  
  my $a2 = $a1_x->clone(elements => $a2_elements);
  
  return $a2;
}

sub grep {
  my ($a1_pattern, $a1_x, $a1_ignore_case) = args(['pattern', 'x', 'ignore.case'], @_);
  
  my $pattern = $a1_pattern->value;
  my $ignore_case = defined $a1_ignore_case ? $a1_ignore_case->element : FALSE;
  
  my $a2_elements = [];
  my $a1_x_elements = $a1_x->elements;
  for (my $i = 0; $i < @$a1_x_elements; $i++) {
    my $x_e = $a1_x_elements->[$i];
    
    unless ($x_e->is_na) {
      my $x = $x_e->{cv};
      if ($ignore_case) {
        if ($x =~ /$pattern/i) {
          push $a2_elements, Rstats::ElementFunc::double($i + 1);
        }
      }
      else {
        if ($x =~ /$pattern/) {
          push $a2_elements, Rstats::ElementFunc::double($i + 1);
        }
      }
    }
  }
  
  return c($a2_elements);
}

sub chartr {
  my ($a1_old, $a1_new, $a1_x) = args(['old', 'new', 'x'], @_);
  
  my $old = $a1_old->value;
  my $new = $a1_new->value;
  
  my $a2_elements = [];
  for my $x_e (@{$a1_x->elements}) {
    if ($x_e->is_na) {
      push @$a2_elements, $x_e;
    }
    else {
      my $x = $x_e->{cv};
      $old =~ s#/#\/#;
      $new =~ s#/#\/#;
      eval "\$x =~ tr/$old/$new/";
      croak $@ if $@;
      push @$a2_elements, Rstats::ElementFunc::character($x);
    }
  }
  
  my $a2 = $a1_x->clone(elements => $a2_elements);
  
  return $a2;
}

sub charmatch {
  my ($a1_x, $a1_table) = args(['x', 'table'], @_);
  
  die "Not implemented"
    unless $a1_x->{type} eq 'character' && $a1_table->{type} eq 'character';
  
  my $a2_elements = [];
  for my $a1_x_element (@{$a1_x->elements}) {
    my $a1_x_char = $a1_x_element->value;
    my $a1_x_char_q = quotemeta($a1_x_char);
    my $match_count;
    my $match_pos;
    for (my $k = 0; $k < $a1_table->length_value; $k++) {
      my $a1_table = $a1_table->elements->[$k];
      my $a1_table_char = $a1_table->value;
      if ($a1_table_char =~ /$a1_x_char_q/) {
        $match_count++;
        $match_pos = $k;
      }
    }
    if ($match_count == 0) {
      push $a2_elements, Rstats::ElementFunc::NA();
    }
    elsif ($match_count == 1) {
      push $a2_elements, Rstats::ElementFunc::double($match_pos + 1);
    }
    elsif ($match_count > 1) {
      push $a2_elements, Rstats::ElementFunc::double(0);
    }
  }
  
  return c($a2_elements);
}

sub Re {
  my $a1 = to_c(shift);
  
  my @a2_elements = map { Rstats::ElementFunc::Re($_) } @{$a1->elements};
  my $a2 = $a1->clone(elements => \@a2_elements);
  $a2->{type} = 'double';
  
  return $a2;
}

sub Im {
  my $a1 = to_c(shift);
  
  my @a2_elements = map { Rstats::ElementFunc::Im($_) } @{$a1->elements};
  my $a2 = $a1->clone(elements => \@a2_elements);
  $a2->{type} = 'double';
  
  return $a2;
}

sub Conj {
  my $a1 = to_c(shift);
  
  my @a2_elements = map { Rstats::ElementFunc::Conj($_) } @{$a1->elements};
  my $a2 = $a1->clone(elements => \@a2_elements);
  
  return $a2;
}

sub negation {
  my $a1 = shift;
  
  my $a2_elements = [map { Rstats::ElementFunc::negation($_) } @{$a1->elements}];
  my $a2 = $a1->clone(elements => $a2_elements);
  
  return $a2;
}

sub is_element {
  my ($a1, $a2) = (to_c(shift), to_c(shift));
  
  croak "mode is diffrence" if $a1->{type} ne $a2->{type};
  
  my $a3_elements = [];
  for my $a1_element (@{$a1->elements}) {
    my $match;
    for my $a2_element (@{$a2->elements}) {
      if (Rstats::ElementFunc::equal($a1_element, $a2_element)) {
        $match = 1;
        last;
      }
    }
    push @$a3_elements, $match ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE();
  }
  
  return c($a3_elements);
}

sub setequal {
  my ($a1, $a2) = (to_c(shift), to_c(shift));
  
  croak "mode is diffrence" if $a1->{type} ne $a2->{type};
  
  my $a3 = Rstats::Func::sort($a1);
  my $a4 = Rstats::Func::sort($a2);
  
  return FALSE if $a3->length_value ne $a4->length_value;
  
  my $not_equal;
  for (my $i = 0; $i < $a3->length_value; $i++) {
    unless (Rstats::ElementFunc::equal($a3->elements->[$i], $a4->elements->[$i])) {
      $not_equal = 1;
      last;
    }
  }
  
  return $not_equal ? FALSE : TRUE;
}

sub setdiff {
  my ($a1, $a2) = (to_c(shift), to_c(shift));
  
  croak "mode is diffrence" if $a1->{type} ne $a2->{type};
  
  my $a3_elements = [];
  for my $a1_element (@{$a1->elements}) {
    my $match;
    for my $a2_element (@{$a2->elements}) {
      if (Rstats::ElementFunc::equal($a1_element, $a2_element)) {
        $match = 1;
        last;
      }
    }
    push @$a3_elements, $a1_element unless $match;
  }

  return c($a3_elements);
}

sub intersect {
  my ($a1, $a2) = (to_c(shift), to_c(shift));
  
  croak "mode is diffrence" if $a1->{type} ne $a2->{type};
  
  my $a3_elements = [];
  for my $a1_element (@{$a1->elements}) {
    for my $a2_element (@{$a2->elements}) {
      if (Rstats::ElementFunc::equal($a1_element, $a2_element)) {
        push @$a3_elements, $a1_element;
      }
    }
  }
  
  return c($a3_elements);
}

sub union {
  my ($a1, $a2) = (to_c(shift), to_c(shift));

  croak "mode is diffrence" if $a1->{type} ne $a2->{type};
  
  my $a3 = c($a1, $a2);
  my $a4 = unique($a3);
  
  return $a4;
}

sub diff {
  my $a1 = to_c(shift);
  
  my $a2_elements = [];
  for (my $i = 0; $i < $a1->length_value - 1; $i++) {
    my $a1_element1 = $a1->elements->[$i];
    my $a1_element2 = $a1->elements->[$i + 1];
    my $a2_element = Rstats::ElementFunc::subtract($a1_element2, $a1_element1);
    push @$a2_elements, $a2_element;
  }
  my $a2 = $a1->clone(elements => $a2_elements);
    
  return $a2;
}

sub nchar {
  my $a1 = to_c(shift);
  
  if ($a1->{type} eq 'character') {
    my $a2_elements = [];
    for my $a1_element (@{$a1->elements}) {
      if ($a1_element->is_na) {
        push $a2_elements, $a1_element;
      }
      else {
        my $a2_element = Rstats::ElementFunc::double(CORE::length $a1_element->value);
        push $a2_elements, $a2_element;
      }
    }
    my $a2 = $a1->clone(elements => $a2_elements);
    
    return $a2;
  }
  else {
    croak "Not implemented";
  }
}

sub tolower {
  my $a1 = to_c(shift);
  
  if ($a1->{type} eq 'character') {
    my $a2_elements = [];
    for my $a1_element (@{$a1->elements}) {
      if ($a1_element->is_na) {
        push $a2_elements, $a1_element;
      }
      else {
        my $a2_element = Rstats::ElementFunc::character(lc $a1_element->value);
        push $a2_elements, $a2_element;
      }
    }
    my $a2 = $a1->clone(elements => $a2_elements);
    
    return $a2;
  }
  else {
    return $a1;
  }
}

sub toupper {
  my $a1 = to_c(shift);
  
  if ($a1->{type} eq 'character') {
    my $a2_elements = [];
    for my $a1_element (@{$a1->elements}) {
      if ($a1_element->is_na) {
        push $a2_elements, $a1_element;
      }
      else {
        my $a2_element = Rstats::ElementFunc::character(uc $a1_element->value);
        push $a2_elements, $a2_element;
      }
    }
    my $a2 = $a1->clone(elements => $a2_elements);
      
    return $a2;
  }
  else {
    return $a1;
  }
}

sub match {
  my ($a1, $a2) = (to_c(shift), to_c(shift));
  
  my @matches;
  for my $a1_element (@{$a1->elements}) {
    my $i = 1;
    my $match;
    for my $a2_element (@{$a2->elements}) {
      if (Rstats::ElementFunc::equal($a1_element, $a2_element)) {
        $match = 1;
        last;
      }
      $i++;
    }
    if ($match) {
      push @matches, Rstats::ElementFunc::double($i);
    }
    else {
      push @matches, Rstats::ElementFunc::NA();
    }
  }
  
  return c(\@matches);
}

sub operation {
  my ($op, $a1, $a2) = @_;
  
  $a1 = to_c($a1);
  $a2 = to_c($a2);
  
  # Upgrade mode if type is different
  ($a1, $a2) = upgrade_type($a1, $a2) if $a1->{type} ne $a2->{type};
  
  # Calculate
  my $a1_length = $a1->length_value;
  my $a2_length = $a2->length_value;
  my $longer_length = $a1_length > $a2_length ? $a1_length : $a2_length;
  
  no strict 'refs';
  my $operation = "Rstats::ElementFunc::$op";
  my @a3_elements = map {
    &$operation($a1->elements->[$_ % $a1_length], $a2->elements->[$_ % $a2_length])
  } (0 .. $longer_length - 1);
  
  my $a3 = $a1->clone(elements => \@a3_elements);
  if ($op eq '/') {
    $a3->{type} = 'double';
  }
  else {
    $a3->{type} = $a1->{type};
  }
  
  return $a3;
}

sub add { operation('add', @_) }

sub subtract { operation('subtract', @_)}

sub multiply { operation('multiply', @_)}

sub divide { operation('divide', @_)}

sub raise { operation('raise', @_)}

sub remainder { operation('remainder', @_)}

sub more_than { operation('more_than', @_)}

sub more_than_or_equal { operation('more_than_or_equal', @_)}

sub less_than { operation('less_than', @_)}

sub less_than_or_equal { operation('less_than_or_equal', @_)}

sub equal { operation('equal', @_)}

sub not_equal { operation('not_equal', @_)}

sub abs {
  my $a1 = to_c(shift);
  
  my @a2_elements = map { Rstats::ElementFunc::abs($_) } @{$a1->elements};
  
  my $a2 = $a1->clone(elements => \@a2_elements);
  $a2->mode('double');
  
  return $a2;
}

sub acos { process(\&Rstats::ElementFunc::acos, @_) }

sub acosh { process(\&Rstats::ElementFunc::acosh, @_) }

sub append {
  my ($a1, $a2, $a_after) = args(['a1', 'a2', 'after'], @_);
  
  # Default
  $a_after = NULL unless defined $a_after;
  
  my $a1_length = $a1->length_value;
  $a_after = c($a1_length) if $a_after->is_null;
  my $after = $a_after->value;
  
  if (ref $a2 eq 'Rstats::Container::Array') {
    splice @{$a1->elements}, $after, 0, @{$a2->elements};
  }
  else {
    splice @{$a1->elements}, $after, 0, $a2;
  }
  
  return $a1
}

sub array {
  
  # Arguments
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my ($a1, $_dim) = @_;
  $_dim = $opt->{dim} unless defined $_dim;
  
  $a1 = c($a1);

  # Dimention
  my $elements = $a1->elements;
  my $dim = defined $_dim ? to_c($_dim) : NULL;
  my $a1_length = $a1->length_value;
  unless (@{$dim->elements}) {
    $dim = c($a1_length);
  }
  my $dim_product = 1;
  $dim_product *= $_ for @{$dim->values};
  
  # Fix elements
  if ($a1_length > $dim_product) {
    @$elements = splice @$elements, 0, $dim_product;
  }
  elsif ($a1_length < $dim_product) {
    my $repeat_count = int($dim_product / @$elements) + 1;
    @$elements = (@$elements) x $repeat_count;
    @$elements = splice @$elements, 0, $dim_product;
  }
  $a1->elements($elements);
  $a1->dim($dim);
  
  return $a1;
}

sub asin { process(\&Rstats::ElementFunc::asin, @_) }

sub asinh { process(\&Rstats::ElementFunc::asinh, @_) }

sub atan { process(\&Rstats::ElementFunc::atan, @_) }

sub atanh { process(\&Rstats::ElementFunc::atanh, @_) }

sub cbind {
  my @arrays = @_;
  
  my $row_count_needed;
  my $col_count_total;
  my $a2_elements = [];
  for my $_a (@arrays) {
    
    my $a = to_c($_a);
    
    my $row_count;
    if ($a->is_matrix) {
      $row_count = $a->dim->elements->[0];
      $col_count_total += $a->dim->elements->[1];
    }
    elsif ($a->is_vector) {
      $row_count = $a->dim_as_array->values->[0];
      $col_count_total += 1;
    }
    else {
      croak "cbind or rbind can only receive matrix and vector";
    }
    
    $row_count_needed = $row_count unless defined $row_count_needed;
    croak "Row count is different" if $row_count_needed ne $row_count;
    
    push @$a2_elements, $a->elements;
  }
  my $matrix = matrix($a2_elements, $row_count_needed, $col_count_total);
  
  return $matrix;
}

sub ceiling {
  my $_a1 = shift;
  
  my $a1 = to_c($_a1);
  my @a2_elements = map { Rstats::ElementFunc::double(POSIX::ceil $_->value) } @{$a1->elements};
  
  my $a2 = $a1->clone(elements => \@a2_elements);
  $a2->mode('double');
  
  return $a2;
}

sub colMeans {
  my $a1 = shift;
  
  my $dim_values = $a1->dim->values;
  if (@$dim_values == 2) {
    my $v1_values = [];
    for my $row (1 .. $dim_values->[0]) {
      my $v1_value = 0;
      $v1_value += $a1->value($row, $_) for (1 .. $dim_values->[1]);
      push @$v1_values, $v1_value / $dim_values->[1];
    }
    return c($v1_values);
  }
  else {
    croak "Can't culculate colSums";
  }
}

sub colSums {
  my $a1 = shift;
  
  my $dim_values = $a1->dim->values;
  if (@$dim_values == 2) {
    my $v1_values = [];
    for my $row (1 .. $dim_values->[0]) {
      my $v1_value = 0;
      $v1_value += $a1->value($row, $_) for (1 .. $dim_values->[1]);
      push @$v1_values, $v1_value;
    }
    return c($v1_values);
  }
  else {
    croak "Can't culculate colSums";
  }
}

sub cos { process(\&Rstats::ElementFunc::cos, @_) }

sub atan2 {
  my ($a1, $a2) = (to_c(shift), to_c(shift));
  
  my @a3_elements;
  for (my $i = 0; $i < $a1->length_value; $i++) {
    my $element1 = $a1->elements->[$i];
    my $element2 = $a2->elements->[$i];
    my $element3 = Rstats::ElementFunc::atan2($element1, $element2);
    push @a3_elements, $element3;
  }

  my $a3 = $a1->clone(elements => \@a3_elements);

  # mode
  my $a3_mode;
  if ($a1->is_complex) {
    $a3_mode = 'complex';
  }
  else {
    $a3_mode = 'double';
  }
  $a3->mode($a3_mode);
  
  return $a3;
}

sub cosh { process(\&Rstats::ElementFunc::cosh, @_) }

sub cummax {
  my $a1 = to_c(shift);
  
  unless ($a1->length_value) {
    carp 'no non-missing arguments to max; returning -Inf';
    return negativeInf;
  }
  
  my @a2_elements;
  my $a1_elements = $a1->elements;
  my $max = shift @$a1_elements;
  push @a2_elements, $max;
  for my $element (@$a1_elements) {
    
    if ($element->is_na) {
      return NA;
    }
    elsif ($element->is_nan) {
      $max = $element;
    }
    if (Rstats::ElementFunc::more_than($element, $max) && !$max->is_nan) {
      $max = $element;
    }
    push @a2_elements, $max;
  }
  
  return c(\@a2_elements);
}

sub cummin {
  my $a1 = to_c(shift);
  
  unless ($a1->length_value) {
    carp 'no non-missing arguments to max; returning -Inf';
    return negativeInf;
  }
  
  my @a2_elements;
  my $a1_elements = $a1->elements;
  my $min = shift @$a1_elements;
  push @a2_elements, $min;
  for my $element (@$a1_elements) {
    if ($element->is_na) {
      return NA;
    }
    elsif ($element->is_nan) {
      $min = $element;
    }
    if (Rstats::ElementFunc::less_than($element, $min) && !$min->is_nan) {
      $min = $element;
    }
    push @a2_elements, $min;
  }
  
  return c(\@a2_elements);
}

sub cumsum {
  my $a1 = to_c(shift);
  my $type = $a1->{type};
  my $total = Rstats::ElementFunc::create($type);
  my @a2_elements;
  push @a2_elements, $total = Rstats::ElementFunc::add($total, $_) for @{$a1->elements};
  
  return c(\@a2_elements);
}

sub cumprod {
  my $a1 = to_c(shift);
  my $type = $a1->{type};
  my $total = Rstats::ElementFunc::create($type, 1);
  my @a2_elements;
  push @a2_elements, $total = Rstats::ElementFunc::multiply($total, $_) for @{$a1->elements};
  
  return c(\@a2_elements);
}

sub args {
  my $names = shift;
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my @args;
  for (my $i = 0; $i < @$names; $i++) {
    my $name = $names->[$i];
    my $arg;
    if (exists $opt->{$name}) {
      $arg = to_c(delete $opt->{$name});
    }
    elsif (exists $_[$i]) {
      $arg = to_c($_[$i]);
    }
    push @args, $arg;
  }
  
  croak "unused argument ($_)" for keys %$opt;
  
  return @args;
}

sub complex {
  my ($a1_re, $a1_im, $a1_mod, $a1_arg) = args(['re', 'im', 'mod', 'arg'], @_);

  $a1_mod = NULL unless defined $a1_mod;
  $a1_arg = NULL unless defined $a1_arg;

  my $a2_elements = [];
  # Create complex from mod and arg
  if ($a1_mod->length_value || $a1_arg->length_value) {
    my $a1_mod_length = $a1_mod->length_value;
    my $a1_arg_length = $a1_arg->length_value;
    my $longer_length = $a1_mod_length > $a1_arg_length ? $a1_mod_length : $a1_arg_length;
    
    for (my $i = 0; $i < $longer_length; $i++) {
      my $mod = $a1_mod->elements->[$i];
      $mod = Rstats::ElementFunc::double(1) unless $mod;
      my $arg = $a1_arg->elements->[$i];
      $arg = Rstats::ElementFunc::double(0) unless $arg;
      
      my $re = Rstats::ElementFunc::multiply(
        $mod,
        Rstats::ElementFunc::cos($arg)
      );
      my $im = Rstats::ElementFunc::multiply(
        $mod,
        Rstats::ElementFunc::sin($arg)
      );
      
      my $a2_element = Rstats::ElementFunc::complex_double($re, $im);
      push @$a2_elements, $a2_element;
    }
  }
  # Create complex from re and im
  else {
    croak "mode should be numeric" unless $a1_re->is_numeric && $a1_im->is_numeric;
    
    for (my $i = 0; $i <  $a1_im->length_value; $i++) {
      my $re = $a1_re->elements->[$i] || Rstats::ElementFunc::double(0);
      my $im = $a1_im->elements->[$i];
      my $a2_element = Rstats::ElementFunc::complex_double($re, $im);
      push @$a2_elements, $a2_element;
    }
  }
  
  return c($a2_elements);
}

sub exp { process(\&Rstats::ElementFunc::exp, @_) }

sub expm1 { process(\&Rstats::ElementFunc::expm1, @_) }

sub max_type {
  my @arrays = @_;
  
  my $type_h = {};
  
  for my $array (@arrays) {
    my $array_type = $array->typeof->value;
    $type_h->{$array_type}++;
    unless ($array->is_null) {
      my $element = $array->element;
      my $element_type = $element->typeof;
      $type_h->{$element_type}++;
    }
  }
  
  if ($type_h->{character}) {
    return 'character';
  }
  elsif ($type_h->{complex}) {
    return 'complex';
  }
  elsif ($type_h->{double}) {
    return 'double';
  }
  elsif ($type_h->{integer}) {
    return 'integer';
  }
  else {
    return 'logical';
  }
}

sub floor {
  my $_a1 = shift;
  
  my $a1 = to_c($_a1);
  
  my @a2_elements = map { Rstats::ElementFunc::double(POSIX::floor $_->value) } @{$a1->elements};

  my $a2 = $a1->clone(elements => \@a2_elements);
  $a2->mode('double');
  
  return $a2;
}

sub head {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $v1 = shift;
  
  my $n = $opt->{n};
  $n = 6 unless defined $n;
  
  my $elements1 = $v1->{elements};
  my $max = $v1->length_value < $n ? $v1->length_value : $n;
  my @elements2;
  for (my $i = 0; $i < $max; $i++) {
    push @elements2, $elements1->[$i];
  }
  
  return $v1->new(elements => \@elements2);
}

sub i {
  my $i = Rstats::ElementFunc::complex(0, 1);
  
  return c($i);
}

sub ifelse {
  my ($_v1, $value1, $value2) = @_;
  
  my $v1 = to_c($_v1);
  my $v1_values = $v1->values;
  my @v2_values;
  for my $v1_value (@$v1_values) {
    local $_ = $v1_value;
    if ($v1_value) {
      push @v2_values, $value1;
    }
    else {
      push @v2_values, $value2;
    }
  }
  
  return array(\@v2_values);
}

sub log { process(\&Rstats::ElementFunc::log, @_) }

sub logb { Rstats::Func::log(@_) }

sub log2 { process(\&Rstats::ElementFunc::log2, @_) }

sub log10 { process(\&Rstats::ElementFunc::log10, @_) }

sub max {
  my $a1 = c(@_);
  
  unless ($a1->length_value) {
    carp 'no non-missing arguments to max; returning -Inf';
    return negativeInf;
  }
  
  my $a1_elements = $a1->elements;
  my $max = shift @$a1_elements;
  for my $element (@$a1_elements) {
    
    if ($element->is_na) {
      return NA;
    }
    elsif ($element->is_nan) {
      $max = $element;
    }
    if (!$max->is_nan && Rstats::ElementFunc::more_than($element, $max)) {
      $max = $element;
    }
  }
  
  return c($max);
}

sub mean {
  my $a1 = to_c(shift);
  
  my $a2 = divide(sum($a1), $a1->length_value);
  
  return $a2;
}

sub min {
  my $a1 = c(@_);
  
  unless ($a1->length_value) {
    carp 'no non-missing arguments to min; returning -Inf';
    return Inf;
  }
  
  my $a1_elements = $a1->elements;
  my $min = shift @$a1_elements;
  for my $element (@$a1_elements) {
    
    if ($element->is_na) {
      return NA;
    }
    elsif ($element->is_nan) {
      $min = $element;
    }
    if (!$min->is_nan && Rstats::ElementFunc::less_than($element, $min)) {
      $min = $element;
    }
  }
  
  return c($min);
}

sub order {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $v1 = to_c(shift);
  my $decreasing = $opt->{decreasing} || FALSE;
  
  my $v1_values = $v1->values;
  
  my @pos_vals;
  push @pos_vals, {pos => $_ + 1, val => $v1_values->[$_]} for (0 .. @$v1_values - 1);
  my @sorted_pos_values = !$decreasing
    ? sort { $a->{val} <=> $b->{val} } @pos_vals
    : sort { $b->{val} <=> $a->{val} } @pos_vals;
  my @orders = map { $_->{pos} } @sorted_pos_values;
  
  return c(\@orders);
}

# TODO
# na.last
sub rank {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $v1 = to_c(shift);
  my $decreasing = $opt->{decreasing};
  
  my $v1_values = $v1->values;
  
  my @pos_vals;
  push @pos_vals, {pos => $_ + 1, value => $v1_values->[$_]} for (0 .. @$v1_values - 1);
  my @sorted_pos_values = sort { $a->{value} <=> $b->{value} } @pos_vals;
  
  # Rank
  for (my $i = 0; $i < @sorted_pos_values; $i++) {
    $sorted_pos_values[$i]{rank} = $i + 1;
  }
  
  # Average rank
  my $element_info = {};
  for my $sorted_pos_value (@sorted_pos_values) {
    my $value = $sorted_pos_value->{value};
    $element_info->{$value} ||= {};
    $element_info->{$value}{rank_total} += $sorted_pos_value->{rank};
    $element_info->{$value}{rank_count}++;
  }
  
  for my $sorted_pos_value (@sorted_pos_values) {
    my $value = $sorted_pos_value->{value};
    $sorted_pos_value->{rank_average}
      = $element_info->{$value}{rank_total} / $element_info->{$value}{rank_count};
  }
  
  my @sorted_pos_values2 = sort { $a->{pos} <=> $b->{pos} } @sorted_pos_values;
  my @rank = map { $_->{rank_average} } @sorted_pos_values2;
  
  return c(\@rank);
}

sub paste {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $sep = $opt->{sep};
  $sep = ' ' unless defined $sep;
  
  my $str = shift;
  my $v1 = shift;
  
  my $v1_values = $v1->values;
  my $v2_values = [];
  push @$v2_values, "$str$sep$_" for @$v1_values;
  
  return c($v2_values);
}

sub pmax {
  my @vs = @_;
  
  my @maxs;
  for my $v (@vs) {
    my $elements = $v->elements;
    for (my $i = 0; $i <@$elements; $i++) {
      $maxs[$i] = $elements->[$i]
        if !defined $maxs[$i] || Rstats::ElementFunc::more_than($elements->[$i], $maxs[$i])
    }
  }
  
  return  c(\@maxs);
}

sub pmin {
  my @vs = @_;
  
  my @mins;
  for my $v (@vs) {
    my $elements = $v->elements;
    for (my $i = 0; $i <@$elements; $i++) {
      $mins[$i] = $elements->[$i]
        if !defined $mins[$i] || Rstats::ElementFunc::less_than($elements->[$i], $mins[$i])
    }
  }
  
  return c(\@mins);
}

sub prod {
  my $a1 = c(@_);
  
  my $type = $a1->{type};
  my $prod = Rstats::ElementFunc::create($type, 1);
  for my $element (@{$a1->elements}) {
    $prod = Rstats::ElementFunc::multiply($prod, $element);
  }

  return c($prod);
}

sub range {
  my $a1 = shift;
  
  my $min = min($a1);
  my $max = max($a1);
  
  return c($min, $max);
}

sub rbind {
  my (@arrays) = @_;
  
  my $matrix = cbind(@arrays);
  
  return t($matrix);
}

sub rep {

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  my $v1 = shift;
  my $times = $opt->{times} || 1;
  
  my $elements = [];
  push @$elements, @{$v1->elements} for 1 .. $times;
  my $v2 = c($elements);
  
  return $v2;
}

sub replace {
  my $v1 = to_c(shift);
  my $v2 = to_c(shift);
  my $v3 = to_c(shift);
  
  my $v1_elements = $v1->elements;
  my $v2_elements = $v2->elements;
  my $v2_elements_h = {};
  for my $v2_element (@$v2_elements) {
    my $v2_element_hash = Rstats::ElementFunc::hash($v2_element->as_double);
    
    $v2_elements_h->{$v2_element_hash}++;
    croak "replace second argument can't have duplicate number"
      if $v2_elements_h->{$v2_element_hash} > 1;
  }
  my $v3_elements = $v3->elements;
  my $v3_length = @{$v3_elements};
  
  my $v4_elements = [];
  my $replace_count = 0;
  for (my $i = 0; $i < @$v1_elements; $i++) {
    my $hash = Rstats::ElementFunc::hash(Rstats::ElementFunc::double($i + 1));
    if ($v2_elements_h->{$hash}) {
      push @$v4_elements, $v3_elements->[$replace_count % $v3_length];
      $replace_count++;
    }
    else {
      push @$v4_elements, $v1_elements->[$i];
    }
  }
  
  return array($v4_elements);
}

sub rev {
  my $a1 = shift;
  
  # Reverse elements
  my @a2_elements = reverse @{$a1->elements};
  my $a2 = $a1->clone(elements => \@a2_elements);
  
  return $a2;
}

sub rnorm {
  
  # Option
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  # Count
  my ($count, $mean, $sd) = @_;
  croak "rnorm count should be bigger than 0"
    if $count < 1;
  
  # Mean
  $mean = 0 unless defined $mean;
  
  # Standard deviation
  $sd = 1 unless defined $sd;
  
  # Random numbers(standard deviation)
  my @v1_elements;
  for (1 .. $count) {
    my ($rand1, $rand2) = (rand, rand);
    while ($rand1 == 0) { $rand1 = rand(); }
    
    my $rnorm = ($sd * sqrt(-2 * CORE::log($rand1))
      * sin(2 * Math::Trig::pi * $rand2))
      + $mean;
    
    push @v1_elements, $rnorm;
  }
  
  return c(\@v1_elements);
}

sub round {

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my ($_a1, $digits) = @_;
  $digits = $opt->{digits} unless defined $digits;
  $digits = 0 unless defined $digits;
  
  my $a1 = to_c($_a1);

  my $r = 10 ** $digits;
  my @a2_elements = map { Rstats::ElementFunc::double(Math::Round::round_even($_->value * $r) / $r) } @{$a1->elements};
  my $a2 = $a1->clone(elements => \@a2_elements);
  $a2->mode('double');
  
  return $a2;
}

sub rowMeans {
  my $a1 = shift;
  
  my $dim_values = $a1->dim->values;
  if (@$dim_values == 2) {
    my $v1_values = [];
    for my $col (1 .. $dim_values->[1]) {
      my $v1_value = 0;
      $v1_value += $a1->value($_, $col) for (1 .. $dim_values->[0]);
      push @$v1_values, $v1_value / $dim_values->[0];
    }
    return c($v1_values);
  }
  else {
    croak "Can't culculate rowMeans";
  }
}

sub rowSums {
  my $a1 = shift;
  
  my $dim_values = $a1->dim->values;
  if (@$dim_values == 2) {
    my $v1_values = [];
    for my $col (1 .. $dim_values->[1]) {
      my $v1_value = 0;
      $v1_value += $a1->value($_, $col) for (1 .. $dim_values->[0]);
      push @$v1_values, $v1_value;
    }
    return c($v1_values);
  }
  else {
    croak "Can't culculate rowSums";
  }
}

sub runif {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};

  my ($count, $min, $max) = @_;
  
  $min = 0 unless defined $min;
  $max = 1 unless defined $max;
  croak "runif third argument must be bigger than second argument"
    if $min > $max;
  
  my $diff = $max - $min;
  my @v1_elements;
  if (defined $opt->{seed}) {
    srand $opt->{seed};
  }
  for (1 .. $count) {
    my $rand = rand($diff) + $min;
    push @v1_elements, $rand;
  }
  
  return c(\@v1_elements);
}

# TODO: prob option
sub sample {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  my ($_v1, $length) = @_;
  my $v1 = to_c($_v1);
  
  # Replace
  my $replace = $opt->{replace};
  
  my $v1_length = $v1->length_value;
  $length = $v1_length unless defined $length;
  
  croak "second argument element must be bigger than first argument elements count when you specify 'replace' option"
    if $length > $v1_length && !$replace;
  
  my @v2_elements;
  my $v1_elements = $v1->elements;
  for my $i (0 .. $length - 1) {
    my $rand_num = int(rand @$v1_elements);
    my $rand_element = splice @$v1_elements, $rand_num, 1;
    push @v2_elements, $rand_element;
    push @$v1_elements, $rand_element if $replace;
  }
  
  return c(\@v2_elements);
}

sub sequence {
  my $_v1 = shift;
  
  my $v1 = to_c($_v1);
  my $v1_values = $v1->values;
  
  my @v2_values;
  for my $v1_value (@$v1_values) {
    push @v2_values, seq(1, $v1_value)->values;
  }
  
  return c(\@v2_values);
}

sub sin { process(\&Rstats::ElementFunc::sin, @_) }

sub sinh { process(\&Rstats::ElementFunc::sinh, @_) }

sub sqrt {
  my $a1 = to_c(shift);
  
  my @a2_elements = map { Rstats::ElementFunc::sqrt($_) } @{$a1->elements};
  
  my $a2 = $a1->clone(elements => \@a2_elements);
  $a2->mode('double');
  
  return $a2;
}

sub sort {

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $a1 = to_c(shift);
  my $decreasing = $opt->{decreasing};
  
  my @a2_elements = grep { !$_->is_na && !$_->is_nan } @{$a1->elements};
  
  my $a3_elements = $decreasing
    ? [reverse sort { Rstats::ElementFunc::more_than($a, $b) ? 1 : Rstats::ElementFunc::equal($a, $b) ? 0 : -1 } @a2_elements]
    : [sort { Rstats::ElementFunc::more_than($a, $b) ? 1 : Rstats::ElementFunc::equal($a, $b) ? 0 : -1 } @a2_elements];

  return c($a3_elements);
}

sub tail {

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $v1 = shift;
  
  my $n = $opt->{n};
  $n = 6 unless defined $n;
  
  my $elements1 = $v1->{elements};
  my $max = $v1->length_value < $n ? $v1->length_value : $n;
  my @elements2;
  for (my $i = 0; $i < $max; $i++) {
    unshift @elements2, $elements1->[$v1->length_value - ($i  + 1)];
  }
  
  return $v1->new(elements => \@elements2);
}

sub tan { process(\&Rstats::ElementFunc::tan, @_) }

sub process {
  my $func = shift;
  my $a1 = to_c(shift);
  
  my @a2_elements = map { $func->($_) } @{$a1->elements};
  my $a2 = $a1->clone(elements => \@a2_elements);
  $a2->mode(max_type($a1, $a2));
  
  return $a2;
}

sub tanh { process(\&Rstats::ElementFunc::tanh, @_) }

sub trunc {
  my ($_a1) = @_;
  
  my $a1 = to_c($_a1);
  
  my @a2_elements = map { Rstats::ElementFunc::double(int $_->value) } @{$a1->elements};

  my $a2 = $a1->clone(elements => \@a2_elements);
  $a2->mode('double');
  
  return $a2;
}

sub unique {
  my $a1 = to_c(shift);
  
  if ($a1->is_vector) {
    my $a2_elements = [];
    my $elements_count = {};
    my $na_count;
    for my $a1_element (@{$a1->elements}) {
      if ($a1_element->is_na) {
        unless ($na_count) {
          push @$a2_elements, $a1_element;
        }
        $na_count++;
      }
      else {
        my $str = $a1_element->to_string;
        unless ($elements_count->{$str}) {
          push @$a2_elements, $a1_element;
        }
        $elements_count->{$str}++;
      }
    }

    return c($a2_elements);
  }
  else {
    return $a1;
  }
}

sub median {
  my $a1 = to_c(shift);
  
  my $a2 = unique($a1);
  my $a3 = Rstats::Func::sort($a2);
  my $a3_length = $a3->length_value;
  
  if ($a3_length % 2 == 0) {
    my $middle = $a3_length / 2;
    my $a4 = $a3->get($middle);
    my $a5 = $a3->get($middle + 1);
    
    return ($a4 + $a5) / 2;
  }
  else {
    my $middle = int($a3_length / 2) + 1;
    return $a3->get($middle);
  }
}

sub sd {
  my $a1 = to_c(shift);
  
  my $sd = Rstats::Func::sqrt(var($a1));
  
  return $sd;
}

sub var {
  my $a1 = to_c(shift);

  my $var = sum(($a1 - mean($a1)) ** 2) / ($a1->length_value - 1);
  
  return $var;
}

sub which {
  my ($_v1, $cond_cb) = @_;
  
  my $v1 = to_c($_v1);
  my $v1_values = $v1->values;
  my @v2_values;
  for (my $i = 0; $i < @$v1_values; $i++) {
    local $_ = $v1_values->[$i];
    if ($cond_cb->($v1_values->[$i])) {
      push @v2_values, $i + 1;
    }
  }
  
  return c(\@v2_values);
}

sub matrix {
  
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};

  my ($_a1, $nrow, $ncol, $byrow, $dirnames) = @_;

  croak "matrix method need data as frist argument"
    unless defined $_a1;
  
  my $a1 = to_c($_a1);
  
  # Row count
  $nrow = $opt->{nrow} unless defined $nrow;
  
  # Column count
  $ncol = $opt->{ncol} unless defined $ncol;
  
  # By row
  $byrow = $opt->{byrow} unless defined $byrow;
  
  my $a1_elements = $a1->elements;
  my $a1_length = @$a1_elements;
  if (!defined $nrow && !defined $ncol) {
    $nrow = $a1_length;
    $ncol = 1;
  }
  elsif (!defined $nrow) {
    $nrow = int($a1_length / $ncol);
  }
  elsif (!defined $ncol) {
    $ncol = int($a1_length / $nrow);
  }
  my $length = $nrow * $ncol;
  
  my $dim = [$nrow, $ncol];
  my $matrix;
  if ($byrow) {
    $matrix = array(
      $a1_elements,
      [$dim->[1], $dim->[0]],
    );
    
    $matrix = t($matrix);
  }
  else {
    $matrix = array($a1_elements, $dim);
  }
  
  return $matrix;
}

sub Mod { Rstats::Func::abs(@_) }

sub inner_product {
  my ($a1, $a2) = @_;
  
  # Convert to matrix
  $DB::single = 1;
  $a1 = t($a1->as_matrix) if $a1->is_vector;
  $a2 = $a2->as_matrix if $a2->is_vector;
  
  # Calculate
  if ($a1->is_matrix && $a2->is_matrix) {
    
    croak "requires numeric/complex matrix/vector arguments"
      if $a1->length_value == 0 || $a2->length_value == 0;
    croak "Error in a x b : non-conformable arguments"
      unless $a1->dim->values->[1] == $a2->dim->values->[0];
    
    my $row_max = $a1->dim->values->[0];
    my $col_max = $a2->dim->values->[1];
    
    my $a3_elements = [];
    for (my $col = 1; $col <= $col_max; $col++) {
      for (my $row = 1; $row <= $row_max; $row++) {
        my $v1 = $a1->get($row);
        my $v2 = $a2->get(NULL, $col);
        my $v3 = sum($a1 * $a2);
        push $a3_elements, $v3;
      }
    }
    
    my $a3 = matrix($a3_elements, $row_max, $col_max);
    
    return $a3;
  }
  else {
    croak "inner_product should be dim < 3."
  }
}

sub row {
  my $a1 = shift;
  
  my $nrow = nrow($a1)->value;
  my $ncol = ncol($a1)->value;
  
  my @values = (1 .. $nrow) x $ncol;
  
  return array(\@values, [$nrow, $ncol]);
}

sub sum {
  my $a1 = to_c(shift);
  
  my $type = $a1->{type};
  my $sum = Rstats::ElementFunc::create($type);
  $sum = Rstats::ElementFunc::add($sum, $_) for @{$a1->elements};
  
  return c($sum);
}

sub col {
  my $a1 = shift;
  
  my $nrow = nrow($a1)->value;
  my $ncol = ncol($a1)->value;
  
  my @values;
  for my $col (1 .. $ncol) {
    push @values, ($col) x $nrow;
  }
  
  return array(\@values, [$nrow, $ncol]);
}

sub nrow {
  my $a1 = shift;
  
  return c($a1->dim->values->[0]);
}

sub ncol {
  my $a1 = shift;
  
  return c($a1->dim->values->[1]);
}

sub seq {
  
  # Option
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  # Along
  my $_along = $opt->{along};
  if ($_along) {
    my $along = to_c($_along);
    my $length = $along->length_value;
    return seq(1,$length);
  }
  else {
    my ($from, $to) = @_;
    
    # From
    $from = $opt->{from} unless defined $from;
    croak "seq function need from option" unless defined $from;
    
    # To
    $to = $opt->{to} unless defined $to;
    croak "seq function need to option" unless defined $to;

    # Length
    my $length = $opt->{length};
    
    # By
    my $by = $opt->{by};
    
    if (defined $length && defined $by) {
      croak "Can't use by option and length option as same time";
    }
    
    unless (defined $by) {
      if ($to >= $from) {
        $by = 1;
      }
      else {
        $by = -1;
      }
    }
    croak "by option should be except for 0" if $by == 0;
    
    $to = $from unless defined $to;
    
    if (defined $length && $from ne $to) {
      $by = ($to - $from) / ($length - 1);
    }
    
    my $elements = [];
    if ($to == $from) {
      $elements->[0] = $to;
    }
    elsif ($to > $from) {
      if ($by < 0) {
        croak "by option is invalid number(seq function)";
      }
      
      my $element = $from;
      while ($element <= $to) {
        push @$elements, $element;
        $element += $by;
      }
    }
    else {
      if ($by > 0) {
        croak "by option is invalid number(seq function)";
      }
      
      my $element = $from;
      while ($element >= $to) {
        push @$elements, $element;
        $element += $by;
      }
    }
    
    return c($elements);
  }
}

sub c {
  my @elements_tmp1 = @_;
  
  # Fix elements
  my $elements_tmp2;
  if (@elements_tmp1 == 0) {
    return NULL();
  }
  elsif (@elements_tmp1 > 1) {
    $elements_tmp2 = \@elements_tmp1;
  }
  else {
    $elements_tmp2 = $elements_tmp1[0];
  }

  my $elements = [];
  if (defined $elements_tmp2) {
    if (ref $elements_tmp2 eq 'ARRAY') {
      for my $element (@$elements_tmp2) {
        if (ref $element eq 'ARRAY') {
          push @$elements, @$element;
        }
        elsif (ref $element eq 'Rstats::Container::Array') {
          push @$elements, @{$element->elements};
        }
        else {
          push @$elements, $element;
        }
      }
    }
    elsif (ref $elements_tmp2 eq 'Rstats::Container::Array') {
      $elements = $elements_tmp2->elements;
    }
    else {
      $elements = [$elements_tmp2];
    }
  }
  else {
    croak "Invalid first argument";
  }
  
  # Check elements
  my $mode_h = {};
  for my $element (@$elements) {
    
    if (!ref $element) {
      if (Rstats::Util::is_perl_number($element)) {
        $element = Rstats::ElementFunc::double($element);
        $mode_h->{double}++;
      }
      else {
        $element = Rstats::ElementFunc::character("$element");
        $mode_h->{character}++;
      }
    }
    elsif ($element->is_na) {
      next;
    }
    elsif ($element->is_character) {
      $mode_h->{character}++;
    }
    elsif ($element->is_complex) {
      $mode_h->{complex}++;
    }
    elsif ($element->is_double) {
      $mode_h->{double}++;
    }
    elsif ($element->is_integer) {
      $element = Rstats::ElementFunc::double($element->value);
      $mode_h->{double}++;
    }
    elsif ($element->is_logical) {
      $mode_h->{logical}++;
    }
  }

  # Array
  my $a1 = NULL();
  $a1->elements($elements);

  # Upgrade elements and type
  my @modes = keys %$mode_h;
  if (@modes > 1) {
    if ($mode_h->{character}) {
      $a1 = $a1->as_character;
    }
    elsif ($mode_h->{complex}) {
      $a1 = $a1->as_complex;
    }
    elsif ($mode_h->{double}) {
      $a1 = $a1->as_double;
    }
  }
  else {
    $a1->mode($modes[0] || 'logical');
  }
  
  return $a1;
}

sub C {
  my $seq_str = shift;

  my $by;
  my $mode;
  if ($seq_str =~ s/^(.+)\*//) {
    $by = $1;
  }
  
  my $from;
  my $to;
  if ($seq_str =~ /([^\:]+)(?:\:(.+))?/) {
    $from = $1;
    $to = $2;
    $to = $from unless defined $to;
  }
  
  my $vector = seq({from => $from, to => $to, by => $by});
  
  return $vector;
}

sub numeric {
  my $num = shift;
  
  return c((0) x $num);
}

sub to_c {
  my $_array = shift;
  
  my $is_container;
  eval {
    $is_container = $_array->isa('Rstats::Container');
  };
  my $a1 = $is_container ? $_array : c($_array);
  
  return $a1;
}

sub t {
  my $a1 = shift;
  
  my $a1_row = $a1->dim->values->[0];
  my $a1_col = $a1->dim->values->[1];
  
  my $a2 = matrix(0, $a1_col, $a1_row);
  
  for my $row (1 .. $a1_row) {
    for my $col (1 .. $a1_col) {
      my $element = $a1->element($row, $col);
      $a2->at($col, $row);
      $a2->set($element);
    }
  }
  
  return $a2;
}

sub upgrade_type {
  my (@arrays) = @_;
  
  # Check elements
  my $type_h = {};
  for my $a1 (@arrays) {
    my $type = $a1->{type} || '';
    if ($type eq 'character') {
      $type_h->{character}++;
    }
    elsif ($type eq 'complex') {
      $type_h->{complex}++;
    }
    elsif ($type eq 'double') {
      $type_h->{double}++;
    }
    elsif ($type eq 'integer') {
      $type_h->{integer}++;
    }
    elsif ($type eq 'logical') {
      $type_h->{logical}++;
    }
    else {
      croak "Invalid type";
    }
  }

  # Upgrade elements and type if type is different
  my @types = keys %$type_h;
  if (@types > 1) {
    my $to_type;
    if ($type_h->{character}) {
      $to_type = 'character';
    }
    elsif ($type_h->{complex}) {
      $to_type = 'complex';
    }
    elsif ($type_h->{double}) {
      $to_type = 'double';
    }
    elsif ($type_h->{integer}) {
      $to_type = 'integer';
    }
    elsif ($type_h->{logical}) {
      $to_type = 'logical';
    }
    $_ = $_->as($to_type) for @arrays;
  }
  
  return @arrays;
}

1;
