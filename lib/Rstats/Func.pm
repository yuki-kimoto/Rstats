package Rstats::Func;

use strict;
use warnings;
use Carp qw/croak carp/;

use Rstats::Array;
use Rstats::List;
use Rstats::DataFrame;
use Rstats::VectorFunc;

use List::Util;
use Math::Trig ();
use POSIX ();
use Math::Round ();
use Encode ();

sub NULL {
  
  my $x1 = Rstats::Array->new;
  $x1->vector(Rstats::Vector->new_null);
  
  return $x1;
}

sub NA { c(Rstats::VectorFunc::NA()) }

sub NaN { c(Rstats::VectorFunc::NaN()) }

sub Inf () { c(Rstats::VectorFunc::Inf()) }

sub negativeInf () { c(Rstats::VectorFunc::negativeInf()) }

sub FALSE () { c(Rstats::VectorFunc::FALSE()) }
sub F () { FALSE }

sub TRUE () { c(Rstats::VectorFunc::TRUE()) }
sub T () { TRUE }

sub pi () { c(Rstats::VectorFunc::pi()) }

sub I {
  my $x1 = shift;
  
  my $x2 = c($x1);
  $x1->copy_attrs_to($x2);
  $x2->class('AsIs');
  
  return $x2;
}

sub subset {
  my ($x1, $x_condition, $x_names)
    = args(['x1', 'condition', 'names'], @_);
  
  $x_names = Rstats::Func::NULL() unless defined $x_names;
  
  my $x2 = $x1->get($x_condition, $x_names);
  
  return $x2;
}

sub t {
  my $x1 = shift;
  
  my $x1_row = $x1->dim->values->[0];
  my $x1_col = $x1->dim->values->[1];
  
  my $x2 = matrix(0, $x1_col, $x1_row);
  
  for my $row (1 .. $x1_row) {
    for my $col (1 .. $x1_col) {
      my $element = $x1->vector_part($row, $col);
      $x2->at($col, $row);
      $x2->set($element);
    }
  }
  
  return $x2;
}

sub transform {
  my $x1 = shift;
  my @args = @_;

  my $new_names = $x1->names->values;
  my $new_elements = $x1->list;
  
  my $names = $x1->names->values;
  
  while (my ($new_name, $new_v) = splice(@args, 0, 2)) {
    if ($new_v->is_character) {
      $new_v = Rstats::Func::I($new_v);
    }

    my $found_pos = -1;
    for (my $i = 0; $i < @$names; $i++) {
      my $name = $names->[$i];
      if ($new_name eq $name) {
        $found_pos = $i;
        last;
      }
    }
    
    if ($found_pos == -1) {
      push @$new_names, $new_name;
      push @$new_elements, $new_v;
    }
    else {
      $new_elements->[$found_pos] = $new_v;
    }
  }
  
  
  my @new_args;
  for (my $i = 0; $i < @$new_names; $i++) {
    push @new_args, $new_names->[$i], $new_elements->[$i];
  }
  
  my $x2 = Rstats::Func::data_frame(@new_args);
  
  return $x2;
}

sub na_omit {
  my $x1 = shift;
  
  my @poss;
  for my $v (@{$x1->list}) {
    for (my $index = 1; $index <= $x1->{row_length}; $index++) {
      push @poss, $index if $v->vector_part($index)->is_na->value;
    }
  }
  
  my $x2 = $x1->get(-(c(\@poss)), NULL);
  
  return $x2;
}

# TODO: merge is not implemented yet
sub merge {
  die "merge is not implemented yet";
  
  my ($x1, $x2, $x_all, $x_all_x, $x_all_y, $x_by, $x_by_x, $x_by_y, $x_sort)
    = args([qw/x1 x2 all all.x all.y by by.x by.y sort/], @_);
  
  # Join way
  $x_all = FALSE unless defined $x_all;
  $x_all_x = FALSE unless defined $x_all_x;
  $x_all_y = FALSE unless defined $x_all_y;
  my $all;
  if ($x_all) {
    $all = 'both';
  }
  elsif ($x_all_x) {
    $all = 'left';
  }
  elsif ($x_all_y) {
    $all = 'rigth';
  }
  else {
    $all = 'common';
  }
  
  # ID
  $x_by = $x1->names->get(1) unless defined $x_by;
  $x_by_x = $x_by unless defined $x_by_x;
  $x_by_y = $x_by unless defined $x_by_y;
  my $by_x = $x_by_x->value;
  my $by_y = $x_by_y->value;
  
  # Sort
  my $sort = defined $x_sort ? $x_sort->value : 0;
}

# TODO
#read.table(file, header = FALSE, sep = "", quote = "\"'",
#           dec = ".", row.names, col.names,
#           as.is = !stringsAsFactors,
#           na.strings = "NA", colClasses = NA, nrows = -1,
#           skip = 0, check.names = TRUE, fill = !blank.lines.skip,
#           strip.white = FALSE, blank.lines.skip = TRUE,
#           comment.char = "#",
#           allowEscapes = FALSE, flush = FALSE,
#           stringsAsFactors = default.stringsAsFactors(),
#           encoding = "unknown")
sub read_table {
  my ($x_file, $x_sep, $x_skip, $x_nrows, $x_header, $x_comment_char, $x_row_names, $x_encoding)
    = args([qw/file sep skip nrows header comment.char row.names encoding/], @_);
  
  my $file = $x_file->value;
  open(my $fh, '<', $file)
    or croak "cannot open file '$file': $!";
  
  # Separater
  my $sep = defined $x_sep ? $x_sep->value : "\\s+";
  my $encoding = defined $x_encoding ? $x_encoding->value : 'UTF-8';
  my $skip = defined $x_skip ? $x_skip->value : 0;
  my $header_opt = defined $x_header ? $x_header->value : 0;
  
  my $type_columns;
  my $columns = [];
  my $row_size;
  my $header;
  while (my $line = <$fh>) {
    if ($skip > 0) {
      $skip--;
      next;
    }
    $line = Encode::decode($encoding, $line);
    $line =~ s/\x0D?\x0A?$//;
    
    if ($header_opt && !$header) {
      $header = [split(/$sep/, $line)];
      next;
    }
    
    my @row = split(/$sep/, $line);
    my $current_row_size = @row;
    $row_size ||= $current_row_size;
    
    # Row size different
    croak "line $. did not have $row_size elements"
      if $current_row_size != $row_size;
    
    $type_columns ||= [('logical') x $row_size];
    
    for (my $i = 0; $i < @row; $i++) {
      
      $columns->[$i] ||= [];
      push @{$columns->[$i]}, $row[$i];
      my $type;
      if (defined Rstats::Util::looks_like_na($row[$i])) {
        $type = 'logical';
      }
      elsif (defined Rstats::Util::looks_like_logical($row[$i])) {
        $type = 'logical';
      }
      elsif (defined Rstats::Util::looks_like_integer($row[$i])) {
        $type = 'integer';
      }
      elsif (defined Rstats::Util::looks_like_double($row[$i])) {
        $type = 'double';
      }
      elsif (defined Rstats::Util::looks_like_complex($row[$i])) {
        $type = 'complex';
      }
      else {
        $type = 'character';
      }
      $type_columns->[$i] = Rstats::Util::higher_type($type_columns->[$i], $type);
    }
  }
  
  my $data_frame_args = [];
  for (my $i = 0; $i < $row_size; $i++) {
    if (defined $header->[$i]) {
      push @$data_frame_args, $header->[$i];
    }
    else {
      push @$data_frame_args, "V" . ($i + 1);
    }
    my $type = $type_columns->[$i];
    if ($type eq 'character') {
      my $x1 = Rstats::Func::c($columns->[$i]);
      push @$data_frame_args, $x1->as_factor;
    }
    elsif ($type eq 'complex') {
      my $x1 = Rstats::Func::c($columns->[$i]);
      push @$data_frame_args, $x1->as_complex;
    }
    elsif ($type eq 'double') {
      my $x1 = Rstats::Func::c($columns->[$i]);
      push @$data_frame_args, $x1->as_double;
    }
    elsif ($type eq 'integer') {
      my $x1 = Rstats::Func::c($columns->[$i]);
      push @$data_frame_args, $x1->as_integer;
    }
    else {
      my $x1 = Rstats::Func::c($columns->[$i]);
      push @$data_frame_args, $x1->as_logical;
    }
  }
  
  my $d1 = Rstats::Func::data_frame(@$data_frame_args);
  
  return $d1;
}

sub interaction {
  my $opt;
  $opt = ref $_[-1] eq 'HASH' ? pop : {};
  my @xs = map { to_c($_)->as_factor } @_;
  my ($x_drop, $x_sep);
  ($x_drop, $x_sep) = args(['drop', 'sep'], $opt);
  
  $x_sep = c(".") unless defined $x_sep;
  my $sep = $x_sep->value;
  
  $x_drop = Rstats::Func::FALSE unless defined $x_drop;
  
  my $max_length;
  my $values_list = [];
  for my $x (@xs) {
    my $length = $x->length->value;
    $max_length = $length if !defined $max_length || $length > $max_length;
  }
  
  # Vector
  my $f1_elements = [];
  for (my $i = 0; $i < $max_length; $i++) {
    my $chars = [];
    for my $x (@xs) {
      my $fix_x = $x->as_character;
      my $length = $fix_x->length_value;
      push @$chars, $fix_x->value(($i % $length) + 1)
    }
    my $value = join $sep, @$chars;
    push @$f1_elements, $value;
  }
  
  # Levels
  my $f1;
  my $f1_levels_elements = [];
  if ($x_drop) {
    $f1_levels_elements = $f1_elements;
    $f1 = factor($f1_elements);
  }
  else {
    my $levels = [];
    for my $x (@xs) {
      push @$levels, $x->levels->values;
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
  my ($x_n, $x_k, $x_length, $x_labels, $x_ordered)
    = args([qw/n k length labels ordered/], @_);
  
  my $n = $x_n->value;
  my $k = $x_k->value;
  $x_length = c($n * $k) unless defined $x_length;
  my $length = $x_length->value;
  
  my $x_levels = c(1 .. $n);
  $x_levels = $x_levels->as_character;
  my $levels = $x_levels->values;
  
  my $x1_elements = [];
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
    push @$x1_elements, $level;
    $j++;
  }
  
  my $x1 = c($x1_elements);
  
  $x_labels = $x_levels unless defined $x_labels;
  $x_ordered = Rstats::Func::FALSE() unless defined $x_ordered;
  
  return factor($x1, {levels => $x_levels, labels => $x_labels, ordered => $x_ordered});
}

sub ordered {
  my $opt = ref $_[-1] eq 'HASH' ? pop : {};
  $opt->{ordered} = Rstats::Func::TRUE();
  
  factor(@_, $opt);
}

sub factor {
  my ($x1, $x_levels, $x_labels, $x_exclude, $x_ordered)
    = args([qw/x levels labels exclude ordered/], @_);

  # default - x
  $x1 = $x1->as_character unless $x1->is_character;
  
  # default - levels
  unless (defined $x_levels) {
    $x_levels = Rstats::Func::sort(unique($x1), {'na.last' => TRUE});
  }
  
  # default - exclude
  $x_exclude = NA unless defined $x_exclude;
  
  # fix levels
  if (!$x_exclude->is_na->value && $x_exclude->length->value) {
    my $new_a_levels_elements = [];
    for my $x_levels_element (@{$x_levels->decompose_elements}) {
      my $match;
      for my $x_exclude_element (@{$x_exclude->decompose_elements}) {
        my $x_levels_value = $x_levels_element->value;
        my $x_exclude_value = $x_exclude_element->value;
        if (defined $x_levels_value
          && defined $x_exclude_value
          && $x_levels_value eq $x_exclude_value)
        {
          $match = 1;
          last;
        }
      }
      push @$new_a_levels_elements, $x_levels_element unless $match;
    }
    $x_levels = c($new_a_levels_elements);
  }
  
  # default - labels
  unless (defined $x_labels) {
    $x_labels = $x_levels;
  }
  
  # default - ordered
  $x_ordered = $x1->is_ordered unless defined $x_ordered;
  
  my $x1_elements = $x1->decompose_elements;
  
  my $labels_length = $x_labels->length->value;
  my $levels_length = $x_levels->length->value;
  if ($labels_length == 1 && $x1->length_value != 1) {
    my $value = $x_labels->value;
    $x_labels = paste($value, ve("1:$levels_length"), {sep => ""});
  }
  elsif ($labels_length != $levels_length) {
    croak("Error in factor 'labels'; length $labels_length should be 1 or $levels_length");
  }
  
  # Levels hash
  my $levels;
  my $x_levels_elements = $x_levels->decompose_elements;
  for (my $i = 1; $i <= $levels_length; $i++) {
    my $x_levels_element = $x_levels_elements->[$i - 1];
    my $value = $x_levels_element->value;
    $levels->{$value} = $i;
  }
  
  my $f1_elements = [];
  for my $x1_element (@$x1_elements) {
    if ($x1_element->is_na->value) {
      push @$f1_elements, Rstats::VectorFunc::NA();
    }
    else {
      my $value = $x1_element->value;
      my $f1_element = exists $levels->{$value}
        ? Rstats::VectorFunc::new_integer($levels->{$value})
        : Rstats::VectorFunc::NA();
      push @$f1_elements, $f1_element;
    }
  }
  
  my $f1 = c($f1_elements)->as_integer;
  if ($x_ordered) {
    $f1->{class} = Rstats::VectorFunc::new_character('factor', 'ordered');
  }
  else {
    $f1->{class} = Rstats::VectorFunc::new_character('factor');
  }
  $f1->{levels} = $x_labels->vector->clone;
  
  return $f1;
}

sub length {
  my $container = shift;
  
  return $container->length;
}

sub list {
  my @elements = @_;
  
  @elements = map { ref $_ ne 'Rstats::List' ? Rstats::Func::to_c($_) : $_ } @elements;
  
  my $list = Rstats::List->new;
  $list->list(\@elements);
  
  return $list;
}

sub data_frame {
  my @data = @_;
  
  return cbind(@data) if ref $data[0] && $data[0]->is_data_frame;
  
  my $elements = [];
  
  # name count
  my $name_count = {};
  
  # count
  my $counts = [];
  my $column_names = [];
  my $row_names = [];
  my $row_count = 1;
  while (my ($name, $v) = splice(@data, 0, 2)) {
    if ($v->is_character && !grep {$_ eq 'AsIs'} @{$v->class->values}) {
      $v = $v->as_factor;
    }

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
        push @$column_names, $fix_name;
        push @$elements, splice(@{$v->decompose_elements}, 0, $count);
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
      push @$column_names, $fix_name;
      push @$elements, $v;
    }
    push @$row_names, "$row_count";
    $row_count++;
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
      my $repeat_elements = [];
      push @$repeat_elements, $elements->[$i] for (1 .. $repeat);
      $elements->[$i] = Rstats::Func::c($repeat_elements);
    }
  }
  
  # Create data frame
  my $data_frame = Rstats::DataFrame->new;
  $data_frame->{row_length} = $max_count;
  $data_frame->list($elements);
  $data_frame->dimnames(
    Rstats::Func::list(
      Rstats::Func::c($row_names),
      Rstats::Func::c($column_names)
    )
  );
  
  return $data_frame;
}

sub upper_tri {
  my ($x1_m, $x1_diag) = args(['m', 'diag'], @_);
  
  my $diag = defined $x1_diag ? $x1_diag->vector_part : FALSE;
  
  my $x2_elements = [];
  if ($x1_m->is_matrix) {
    my $x1_dim_values = $x1_m->dim->values;
    my $rows_count = $x1_dim_values->[0];
    my $cols_count = $x1_dim_values->[1];
    
    for (my $col = 0; $col < $cols_count; $col++) {
      for (my $row = 0; $row < $rows_count; $row++) {
        my $x2_element;
        if ($diag) {
          $x2_element = $col >= $row ? Rstats::VectorFunc::TRUE() : Rstats::VectorFunc::FALSE();
        }
        else {
          $x2_element = $col > $row ? Rstats::VectorFunc::TRUE() : Rstats::VectorFunc::FALSE();
        }
        push @$x2_elements, $x2_element;
      }
    }
    
    my $x2 = matrix($x2_elements, $rows_count, $cols_count);
    
    return $x2;
  }
  else {
    croak 'Not implemented';
  }
}

sub lower_tri {
  my ($x1_m, $x1_diag) = args(['m', 'diag'], @_);
  
  my $diag = defined $x1_diag ? $x1_diag->vector_part : FALSE;
  
  my $x2_elements = [];
  if ($x1_m->is_matrix) {
    my $x1_dim_values = $x1_m->dim->values;
    my $rows_count = $x1_dim_values->[0];
    my $cols_count = $x1_dim_values->[1];
    
    for (my $col = 0; $col < $cols_count; $col++) {
      for (my $row = 0; $row < $rows_count; $row++) {
        my $x2_element;
        if ($diag) {
          $x2_element = $col <= $row ? Rstats::VectorFunc::TRUE() : Rstats::VectorFunc::FALSE();
        }
        else {
          $x2_element = $col < $row ? Rstats::VectorFunc::TRUE() : Rstats::VectorFunc::FALSE();
        }
        push @$x2_elements, $x2_element;
      }
    }
    
    my $x2 = matrix($x2_elements, $rows_count, $cols_count);
    
    return $x2;
  }
  else {
    croak 'Not implemented';
  }
}

sub diag {
  my $x1 = to_c(shift);
  
  my $size;
  my $x2_elements;
  if ($x1->length_value == 1) {
    $size = $x1->value;
    $x2_elements = [];
    push @$x2_elements, Rstats::VectorFunc::new_double(1) for (1 .. $size);
  }
  else {
    $size = $x1->length_value;
    $x2_elements = $x1->decompose_elements;
  }
  
  my $x2 = matrix(0, $size, $size);
  for (my $i = 0; $i < $size; $i++) {
    $x2->at($i + 1, $i + 1);
    $x2->set($x2_elements->[$i]);
  }

  return $x2;
}

sub set_diag {
  my $x1 = to_c(shift);
  my $x2 = to_c(shift);
  
  my $x2_elements;
  my $x1_dim_values = $x1->dim->values;
  my $size = $x1_dim_values->[0] < $x1_dim_values->[1] ? $x1_dim_values->[0] : $x1_dim_values->[1];
  
  $x2 = array($x2, $size);
  $x2_elements = $x2->decompose_elements;
  
  for (my $i = 0; $i < $size; $i++) {
    $x1->at($i + 1, $i + 1);
    $x1->set($x2_elements->[$i]);
  }
  
  return $x1;
}

sub kronecker {
  my $x1 = to_c(shift);
  my $x2 = to_c(shift);
  
  ($x1, $x2) = upgrade_type($x1, $x2) if $x1->type ne $x2->type;
  
  my $x1_dim = $x1->dim;
  my $x2_dim = $x2->dim;
  my $dim_max_length
    = $x1_dim->length_value > $x2_dim->length_value ? $x1_dim->length_value : $x2_dim->length_value;
  
  my $x3_dim_values = [];
  my $x1_dim_values = $x1_dim->values;
  my $x2_dim_values = $x2_dim->values;
  for (my $i = 0; $i < $dim_max_length; $i++) {
    my $x1_dim_value = $x1_dim_values->[$i] || 1;
    my $x2_dim_value = $x2_dim_values->[$i] || 1;
    my $x3_dim_value = $x1_dim_value * $x2_dim_value;
    push @$x3_dim_values, $x3_dim_value;
  }
  
  my $x3_dim_product = 1;
  $x3_dim_product *= $_ for @{$x3_dim_values};
  
  my $x3_elements = [];
  for (my $i = 0; $i < $x3_dim_product; $i++) {
    my $x3_index = Rstats::Util::pos_to_index($i, $x3_dim_values);
    my $x1_index = [];
    my $x2_index = [];
    for (my $k = 0; $k < @$x3_index; $k++) {
      my $x3_i = $x3_index->[$k];
      
      my $x1_dim_value = $x1_dim_values->[$k] || 1;
      my $x2_dim_value = $x2_dim_values->[$k] || 1;

      my $x1_ind = int(($x3_i - 1)/$x2_dim_value) + 1;
      push @$x1_index, $x1_ind;
      my $x2_ind = $x3_i - $x2_dim_value * ($x1_ind - 1);
      push @$x2_index, $x2_ind;
    }
    my $x1_element = $x1->vector_part(@$x1_index);
    my $x2_element = $x2->vector_part(@$x2_index);
    my $x3_element = multiply($x1_element, $x2_element);
    push @$x3_elements, $x3_element;
  }

  my $x3 = array($x3_elements, c($x3_dim_values));
  
  return $x3;
}

sub outer {
  my $x1 = to_c(shift);
  my $x2 = to_c(shift);
  
  ($x1, $x2) = upgrade_type($x1, $x2) if $x1->type ne $x2->type;
  
  my $x1_dim = $x1->dim;
  my $x2_dim = $x2->dim;
  my $x3_dim = [@{$x1_dim->values}, @{$x2_dim->values}];
  
  my $indexs = [];
  for my $x3_d (@$x3_dim) {
    push @$indexs, [1 .. $x3_d];
  }
  my $poses = Rstats::Util::cross_product($indexs);
  
  my $x1_dim_length = $x1_dim->length_value;
  my $x3_elements = [];
  for my $pos (@$poses) {
    my $pos_tmp = [@$pos];
    my $x1_pos = [splice @$pos_tmp, 0, $x1_dim_length];
    my $x2_pos = $pos_tmp;
    my $x1_element = $x1->vector_part(@$x1_pos);
    my $x2_element = $x2->vector_part(@$x2_pos);
    my $x3_element = Rstats::VectorFunc::multiply($x1_element, $x2_element);
    push @$x3_elements, $x3_element;
  }
  
  my $x3 = array($x3_elements, c($x3_dim));
  
  return $x3;
}

sub Arg {
  my $x1 = to_c(shift);
  
  my @a2_elements = map { Rstats::VectorFunc::Arg($_) } @{$x1->decompose_elements};
  my $x2 = c(\@a2_elements);
  $x1->copy_attrs_to($x2);
  
  return $x2;
}

sub sub {
  my ($x1_pattern, $x1_replacement, $x1_x, $x1_ignore_case)
    = args(['pattern', 'replacement', 'x', 'ignore.case'], @_);
  
  my $pattern = $x1_pattern->value;
  my $replacement = $x1_replacement->value;
  my $ignore_case = defined $x1_ignore_case ? $x1_ignore_case->vector_part : FALSE;
  
  my $x2_elements = [];
  for my $x_e (@{$x1_x->decompose_elements}) {
    if ($x_e->is_na->value) {
      push @$x2_elements, $x_e;
    }
    else {
      my $x = $x_e->value;
      if ($ignore_case) {
        $x =~ s/$pattern/$replacement/i;
      }
      else {
        $x =~ s/$pattern/$replacement/;
      }
      push @$x2_elements, Rstats::VectorFunc::new_character($x);
    }
  }
  
  my $x2 = c($x2_elements);
  $x1_x->copy_attrs_to($x2);
  
  return $x2;
}

sub gsub {
  my ($x1_pattern, $x1_replacement, $x1_x, $x1_ignore_case)
    = args(['pattern', 'replacement', 'x', 'ignore.case'], @_);
  
  my $pattern = $x1_pattern->value;
  my $replacement = $x1_replacement->value;
  my $ignore_case = defined $x1_ignore_case ? $x1_ignore_case->vector_part : FALSE;
  
  my $x2_elements = [];
  for my $x_e (@{$x1_x->decompose_elements}) {
    if ($x_e->is_na->value) {
      push @$x2_elements, $x_e;
    }
    else {
      my $x = $x_e->value;
      if ($ignore_case) {
        $x =~ s/$pattern/$replacement/gi;
      }
      else {
        $x =~ s/$pattern/$replacement/g;
      }
      push @$x2_elements, Rstats::VectorFunc::new_character($x);
    }
  }
  
  my $x2 = c($x2_elements);
  $x1_x->copy_attrs_to($x2);
  
  return $x2;
}

sub grep {
  my ($x1_pattern, $x1_x, $x1_ignore_case) = args(['pattern', 'x', 'ignore.case'], @_);
  
  my $pattern = $x1_pattern->value;
  my $ignore_case = defined $x1_ignore_case ? $x1_ignore_case->vector_part : FALSE;
  
  my $x2_elements = [];
  my $x1_x_elements = $x1_x->decompose_elements;
  for (my $i = 0; $i < @$x1_x_elements; $i++) {
    my $x_e = $x1_x_elements->[$i];
    
    unless ($x_e->is_na->value) {
      my $x = $x_e->value;
      if ($ignore_case) {
        if ($x =~ /$pattern/i) {
          push @$x2_elements, Rstats::VectorFunc::new_double($i + 1);
        }
      }
      else {
        if ($x =~ /$pattern/) {
          push @$x2_elements, Rstats::VectorFunc::new_double($i + 1);
        }
      }
    }
  }
  
  return c($x2_elements);
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
        elsif (ref $element eq 'Rstats::Array') {
          push @$elements, @{$element->decompose_elements};
        }
        else {
          push @$elements, $element;
        }
      }
    }
    elsif (ref $elements_tmp2 eq 'Rstats::Array') {
      $elements = $elements_tmp2->decompose_elements;
    }
    else {
      $elements = [$elements_tmp2];
    }
  }
  else {
    return NA();
  }
  
  # Check elements
  my $mode_h = {};
  for my $element (@$elements) {
    
    if (!ref $element) {
      if (Rstats::Util::is_perl_number($element)) {
        $element = Rstats::VectorFunc::new_double($element);
        $mode_h->{double}++;
      }
      else {
        $element = Rstats::VectorFunc::new_character("$element");
        $mode_h->{character}++;
      }
    }
    elsif ($element->is_na->value) {
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
      $element = Rstats::VectorFunc::new_double($element->value);
      $mode_h->{double}++;
    }
    elsif ($element->is_logical) {
      $mode_h->{logical}++;
    }
  }

  # Array
  my $x1 = NULL();

  # Upgrade elements and type
  my @modes = keys %$mode_h;
  my $mode;
  if (@modes > 1) {
    if ($mode_h->{character}) {
      $elements = [map { $_->as_character } @$elements];
      $mode = 'character';
    }
    elsif ($mode_h->{complex}) {
      $elements = [map { $_->as_complex } @$elements];
      $mode = 'complex';
    }
    elsif ($mode_h->{double}) {
      $elements = [map { $_->as_double } @$elements];
      $mode = 'double';
    }
  }
  else {
    $mode = $modes[0] || 'logical';
  }
  
  my $compose_elements = Rstats::Vector->compose($mode, $elements);
  $x1->vector($compose_elements);
  
  return $x1;
}

sub ve {
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

sub col {
  my $x1 = shift;
  
  my $nrow = nrow($x1)->value;
  my $ncol = ncol($x1)->value;
  
  my @values;
  for my $col (1 .. $ncol) {
    push @values, ($col) x $nrow;
  }
  
  return array(\@values, [$nrow, $ncol]);
}

sub chartr {
  my ($x1_old, $x1_new, $x1_x) = args(['old', 'new', 'x'], @_);
  
  my $old = $x1_old->value;
  my $new = $x1_new->value;
  
  my $x2_elements = [];
  for my $x_e (@{$x1_x->decompose_elements}) {
    if ($x_e->is_na->value) {
      push @$x2_elements, $x_e;
    }
    else {
      my $x = $x_e->value;
      $old =~ s#/#\/#;
      $new =~ s#/#\/#;
      eval "\$x =~ tr/$old/$new/";
      croak $@ if $@;
      push @$x2_elements, Rstats::VectorFunc::new_character($x);
    }
  }
  
  my $x2 = c($x2_elements);
  $x1_x->copy_attrs_to($x2);
  
  return $x2;
}

sub charmatch {
  my ($x1_x, $x1_table) = args(['x', 'table'], @_);
  
  die "Not implemented"
    unless $x1_x->vector->type eq 'character' && $x1_table->vector->type eq 'character';
  
  my $x2_elements = [];
  for my $x1_x_element (@{$x1_x->decompose_elements}) {
    my $x1_x_char = $x1_x_element->value;
    my $x1_x_char_q = quotemeta($x1_x_char);
    my $match_count;
    my $match_pos;
    my $x1_table_elements = $x1_table->decompose_elements;
    for (my $k = 0; $k < $x1_table->length_value; $k++) {
      my $x1_table = $x1_table_elements->[$k];
      my $x1_table_char = $x1_table->value;
      if ($x1_table_char =~ /$x1_x_char_q/) {
        $match_count++;
        $match_pos = $k;
      }
    }
    if ($match_count == 0) {
      push @$x2_elements, Rstats::VectorFunc::NA();
    }
    elsif ($match_count == 1) {
      push @$x2_elements, Rstats::VectorFunc::new_double($match_pos + 1);
    }
    elsif ($match_count > 1) {
      push @$x2_elements, Rstats::VectorFunc::new_double(0);
    }
  }
  
  return c($x2_elements);
}

sub Conj {
  my $x1 = to_c(shift);
  
  my @a2_elements = map { Rstats::VectorFunc::Conj($_) } @{$x1->decompose_elements};
  my $x2 = c(\@a2_elements);
  $x1->copy_attrs_to($x2);
  return $x2;
}

sub Re {
  my $x1 = to_c(shift);
  
  my @a2_elements = map { Rstats::VectorFunc::Re($_) } @{$x1->decompose_elements};
  my $x2 = c(\@a2_elements);
  $x1->copy_attrs_to($x2);
  
  return $x2;
}

sub Im {
  my $x1 = to_c(shift);
  
  my @a2_elements = map { Rstats::VectorFunc::Im($_) } @{$x1->decompose_elements};
  my $x2 = c(\@a2_elements);
  $x1->copy_attrs_to($x2);
  
  return $x2;
}

sub nrow {
  my $x1 = shift;
  
  if ($x1->is_data_frame) {
    return c($x1->{row_length});
  }
  elsif ($x1->is_list) {
    return Rstats::Func::NULL();
  }
  else {
    return c($x1->dim->values->[0]);
  }
}


sub negation {
  my $x1 = shift;
  
  my $x2_elements = [map { Rstats::VectorFunc::negation($_) } @{$x1->decompose_elements}];
  my $x2 = c($x2_elements);
  $x1->copy_attrs_to($x2);
  
  return $x2;
}

sub is_element {
  my ($x1, $x2) = (to_c(shift), to_c(shift));
  
  croak "mode is diffrence" if $x1->vector->type ne $x2->vector->type;
  
  my $x1_elements = $x1->decompose_elements;
  my $x2_elements = $x2->decompose_elements;
  my $x3_elements = [];
  for my $x1_element (@$x1_elements) {
    my $match;
    for my $x2_element (@$x2_elements) {
      if (Rstats::VectorFunc::equal($x1_element, $x2_element)->value) {
        $match = 1;
        last;
      }
    }
    push @$x3_elements, $match ? Rstats::VectorFunc::TRUE() : Rstats::VectorFunc::FALSE();
  }
  
  return c($x3_elements);
}

sub setequal {
  my ($x1, $x2) = (to_c(shift), to_c(shift));
  
  croak "mode is diffrence" if $x1->vector->type ne $x2->vector->type;
  
  my $x3 = Rstats::Func::sort($x1);
  my $x4 = Rstats::Func::sort($x2);
  
  return FALSE if $x3->length_value ne $x4->length_value;
  
  my $not_equal;
  my $x3_elements = $x3->decompose_elements;
  my $x4_elements = $x4->decompose_elements;
  for (my $i = 0; $i < $x3->length_value; $i++) {
    unless (Rstats::VectorFunc::equal($x3_elements->[$i], $x4_elements->[$i])->value) {
      $not_equal = 1;
      last;
    }
  }
  
  return $not_equal ? FALSE : TRUE;
}

sub setdiff {
  my ($x1, $x2) = (to_c(shift), to_c(shift));
  
  croak "mode is diffrence" if $x1->vector->type ne $x2->vector->type;
  
  my $x1_elements = $x1->decompose_elements;
  my $x2_elements = $x2->decompose_elements;
  my $x3_elements = [];
  for my $x1_element (@$x1_elements) {
    my $match;
    for my $x2_element (@$x2_elements) {
      if (Rstats::VectorFunc::equal($x1_element, $x2_element)->value) {
        $match = 1;
        last;
      }
    }
    push @$x3_elements, $x1_element unless $match;
  }

  return c($x3_elements);
}

sub intersect {
  my ($x1, $x2) = (to_c(shift), to_c(shift));
  
  croak "mode is diffrence" if $x1->vector->type ne $x2->vector->type;
  
  my $x1_elements = $x1->decompose_elements;
  my $x2_elements = $x2->decompose_elements;
  my $x3_elements = [];
  for my $x1_element (@$x1_elements) {
    for my $x2_element (@$x2_elements) {
      if (Rstats::VectorFunc::equal($x1_element, $x2_element)->value) {
        push @$x3_elements, $x1_element;
      }
    }
  }
  
  return c($x3_elements);
}

sub union {
  my ($x1, $x2) = (to_c(shift), to_c(shift));

  croak "mode is diffrence" if $x1->vector->type ne $x2->vector->type;
  
  my $x3 = c($x1, $x2);
  my $x4 = unique($x3);
  
  return $x4;
}

sub diff {
  my $x1 = to_c(shift);
  
  my $x2_elements = [];
  my $x1_elements = $x1->decompose_elements;
  for (my $i = 0; $i < $x1->length_value - 1; $i++) {
    my $x1_element1 = $x1_elements->[$i];
    my $x1_element2 = $x1_elements->[$i + 1];
    my $x2_element = Rstats::VectorFunc::subtract($x1_element2, $x1_element1);
    push @$x2_elements, $x2_element;
  }
  my $x2 = c($x2_elements);
  $x1->copy_attrs_to($x2);
  
  return $x2;
}

sub nchar {
  my $x1 = to_c(shift);
  
  if ($x1->vector->type eq 'character') {
    my $x2_elements = [];
    for my $x1_element (@{$x1->decompose_elements}) {
      if ($x1_element->is_na->value) {
        push @$x2_elements, $x1_element;
      }
      else {
        my $x2_element = Rstats::VectorFunc::new_double(CORE::length $x1_element->value);
        push @$x2_elements, $x2_element;
      }
    }
    my $x2 = c($x2_elements);
    $x1->copy_attrs_to($x2);
    
    return $x2;
  }
  else {
    croak "Not implemented";
  }
}

sub tolower {
  my $x1 = to_c(shift);
  
  if ($x1->vector->type eq 'character') {
    my $x2_elements = [];
    for my $x1_element (@{$x1->decompose_elements}) {
      if ($x1_element->is_na->value) {
        push @$x2_elements, $x1_element;
      }
      else {
        my $x2_element = Rstats::VectorFunc::new_character(lc $x1_element->value);
        push @$x2_elements, $x2_element;
      }
    }
    my $x2 = c($x2_elements);
    $x1->copy_attrs_to($x2);
    
    return $x2;
  }
  else {
    return $x1;
  }
}

sub toupper {
  my $x1 = to_c(shift);
  
  if ($x1->vector->type eq 'character') {
    my $x2_elements = [];
    for my $x1_element (@{$x1->decompose_elements}) {
      if ($x1_element->is_na->value) {
        push @$x2_elements, $x1_element;
      }
      else {
        my $x2_element = Rstats::VectorFunc::new_character(uc $x1_element->value);
        push @$x2_elements, $x2_element;
      }
    }
    my $x2 = c($x2_elements);
    $x1->copy_attrs_to($x2);
    
    return $x2;
  }
  else {
    return $x1;
  }
}

sub match {
  my ($x1, $x2) = (to_c(shift), to_c(shift));
  
  my $x1_elements = $x1->decompose_elements;
  my $x2_elements = $x2->decompose_elements;
  my @matches;
  for my $x1_element (@$x1_elements) {
    my $i = 1;
    my $match;
    for my $x2_element (@$x2_elements) {
      if (Rstats::VectorFunc::equal($x1_element, $x2_element)->value) {
        $match = 1;
        last;
      }
      $i++;
    }
    if ($match) {
      push @matches, Rstats::VectorFunc::new_double($i);
    }
    else {
      push @matches, Rstats::VectorFunc::NA();
    }
  }
  
  return c(\@matches);
}

my %comparison_op = map { $_ => 1 } qw/
  less_than
  less_than_or_equal
  more_than
  more_than_or_equal
  equal
  not_equal
/;

my %logical_op = map { $_ => 1 } ('&&', '||');

sub operation {
  my ($op, $x1, $x2) = @_;
  
  $x1 = to_c($x1);
  $x2 = to_c($x2);
  
  # Upgrade mode if type is different
  ($x1, $x2) = upgrade_type($x1, $x2) if $x1->vector->type ne $x2->vector->type;
  
  # Upgrade length if length is defferent
  my $x1_length = $x1->length_value;
  my $x2_length = $x2->length_value;
  my $length;
  if ($x1_length > $x2_length) {
    $x2 = array($x2, $x1_length);
    $length = $x1_length;
  }
  elsif ($x1_length < $x2_length) {
    $x1 = array($x1, $x2_length);
    $length = $x2_length;
  }
  else {
    $length = $x1_length;
  }
  
  no strict 'refs';
  my $operation = "Rstats::VectorFunc::$op";
  my $x3;
  my $x3_elements = &$operation($x1->vector, $x2->vector);
  $x3 = Rstats::Func::NULL();
  $x3->vector($x3_elements);
  
  $x1->copy_attrs_to($x3);

  return $x3;
}

sub and { operation('and', @_) }

sub or { operation('or', @_) }

sub add { operation('add', @_) }

sub subtract { operation('subtract', @_)}

sub multiply { operation('multiply', @_)}

sub divide { operation('divide', @_)}

sub pow { operation('pow', @_)}

sub remainder { operation('remainder', @_)}

sub more_than { operation('more_than', @_)}

sub more_than_or_equal { operation('more_than_or_equal', @_)}

sub less_than { operation('less_than', @_)}

sub less_than_or_equal { operation('less_than_or_equal', @_)}

sub equal { operation('equal', @_)}

sub not_equal { operation('not_equal', @_)}

sub abs { process_unary(\&Rstats::VectorFunc::abs, @_) }
sub acos { process(\&Rstats::VectorFunc::acos, @_) }
sub acosh { process(\&Rstats::VectorFunc::acosh, @_) }

sub append {
  my ($x1, $x2, $x_after) = args(['x1', 'x2', 'after'], @_);
  
  # Default
  $x_after = NULL unless defined $x_after;
  
  my $x1_length = $x1->length_value;
  $x_after = c($x1_length) if $x_after->is_null;
  my $after = $x_after->value;
  
  my $x1_elements = $x1->decompose_elements;
  my $x2_elements = $x2->decompose_elements;
  my $x3_elements = [@$x1_elements];
  splice @$x3_elements, $after, 0, $x2_elements;
  
  my $x3 = c($x3_elements);
  
  return $x3;
}

sub array {
  
  # Arguments
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my ($x1, $_dim) = @_;
  $_dim = $opt->{dim} unless defined $_dim;
  
  $x1 = to_c($x1);

  # Dimention
  my $elements = $x1->decompose_elements;
  my $dim = defined $_dim ? to_c($_dim) : NULL;
  my $x1_length = $x1->length_value;
  unless ($dim->vector->length_value) {
    $dim = c($x1_length);
  }
  my $dim_product = 1;
  $dim_product *= $_ for @{$dim->values};
  
  # Fix elements
  if ($x1_length > $dim_product) {
    @$elements = splice @$elements, 0, $dim_product;
  }
  elsif ($x1_length < $dim_product) {
    my $repeat_count = int($dim_product / @$elements) + 1;
    @$elements = (@$elements) x $repeat_count;
    @$elements = splice @$elements, 0, $dim_product;
  }
  
  my $x2 = c($elements);
  $x2->dim($dim);
  
  return $x2;
}

sub asin { process(\&Rstats::VectorFunc::asin, @_) }
sub asinh { process(\&Rstats::VectorFunc::asinh, @_) }
sub atan { process(\&Rstats::VectorFunc::atan, @_) }
sub atanh { process(\&Rstats::VectorFunc::atanh, @_) }

sub cbind {
  my @xs = @_;

  return Rstats::Func::NULL() unless @xs;
  
  if ($xs[0]->is_data_frame) {
    # Check row count
    my $first_row_length;
    my $different;
    for my $x (@xs) {
      if ($first_row_length) {
        $different = 1 if $x->{row_length} != $first_row_length;
      }
      else {
        $first_row_length = $x->{row_length};
      }
    }
    croak "cbind need same row count data frame"
      if $different;
    
    # Create new data frame
    my @data_frame_args;
    for my $x (@xs) {
      my $names = $x->names->values;
      for my $name (@$names) {
        push @data_frame_args, $name, $x->getin($name);
      }
    }
    my $data_frame = data_frame(@data_frame_args);
    
    return $data_frame;
  }
  else {
    my $row_count_needed;
    my $col_count_total;
    my $x2_elements = [];
    for my $_x (@xs) {
      
      my $a1 = to_c($_x);
      my $a1_dim_elements = $a1->dim->decompose_elements;
      
      my $row_count;
      if ($a1->is_matrix) {
        $row_count = $a1_dim_elements->[0];
        $col_count_total += $a1_dim_elements->[1];
      }
      elsif ($a1->is_vector) {
        $row_count = $a1->dim_as_array->values->[0];
        $col_count_total += 1;
      }
      else {
        croak "cbind or rbind can only receive matrix and vector";
      }
      
      $row_count_needed = $row_count unless defined $row_count_needed;
      croak "Row count is different" if $row_count_needed ne $row_count;
      
      push @$x2_elements, $a1->decompose_elements;
    }
    my $matrix = matrix($x2_elements, $row_count_needed, $col_count_total);
    
    return $matrix;
  }
}

sub ceiling {
  my $_x1 = shift;
  
  my $x1 = to_c($_x1);
  my @a2_elements = map { Rstats::VectorFunc::new_double(POSIX::ceil $_->value) } @{$x1->decompose_elements};
  
  my $x2 = c(\@a2_elements);
  $x1->copy_attrs_to($x2);
  
  $x2->mode('double');
  
  return $x2;
}

sub colMeans {
  my $x1 = shift;
  
  my $dim_values = $x1->dim->values;
  if (@$dim_values == 2) {
    my $x1_values = [];
    for my $row (1 .. $dim_values->[0]) {
      my $x1_value = 0;
      $x1_value += $x1->value($row, $_) for (1 .. $dim_values->[1]);
      push @$x1_values, $x1_value / $dim_values->[1];
    }
    return c($x1_values);
  }
  else {
    croak "Can't culculate colSums";
  }
}

sub colSums {
  my $x1 = shift;
  
  my $dim_values = $x1->dim->values;
  if (@$dim_values == 2) {
    my $x1_values = [];
    for my $row (1 .. $dim_values->[0]) {
      my $x1_value = 0;
      $x1_value += $x1->value($row, $_) for (1 .. $dim_values->[1]);
      push @$x1_values, $x1_value;
    }
    return c($x1_values);
  }
  else {
    croak "Can't culculate colSums";
  }
}

sub cos { process_unary(\&Rstats::VectorFunc::cos, @_) }

sub atan2 {
  my ($x1, $x2) = (to_c(shift), to_c(shift));
  
  my $x1_elements = $x1->decompose_elements;
  my $x2_elements = $x2->decompose_elements;
  my @a3_elements;
  for (my $i = 0; $i < $x1->length_value; $i++) {
    my $element1 = $x1_elements->[$i];
    my $element2 = $x2_elements->[$i];
    my $element3 = Rstats::VectorFunc::atan2($element1, $element2);
    push @a3_elements, $element3;
  }

  my $x3 = c(\@a3_elements);
  $x1->copy_attrs_to($x3);
  
  # mode
  my $x3_mode;
  if ($x1->is_complex) {
    $x3_mode = 'complex';
  }
  else {
    $x3_mode = 'double';
  }
  $x3->mode($x3_mode);
  
  return $x3;
}

sub cosh { process_unary(\&Rstats::VectorFunc::cosh, @_) }

sub cummax {
  my $x1 = to_c(shift);
  
  unless ($x1->length_value) {
    carp 'no non-missing arguments to max; returning -Inf';
    return negativeInf;
  }
  
  my @a2_elements;
  my $x1_elements = $x1->decompose_elements;
  my $max = shift @$x1_elements;
  push @a2_elements, $max;
  for my $element (@$x1_elements) {
    
    if ($element->is_na->value) {
      return NA;
    }
    elsif ($element->is_nan->value) {
      $max = $element;
    }
    if (Rstats::VectorFunc::more_than($element, $max)->value && !$max->is_nan->value) {
      $max = $element;
    }
    push @a2_elements, $max;
  }
  
  return c(\@a2_elements);
}

sub cummin {
  my $x1 = to_c(shift);
  
  unless ($x1->length_value) {
    carp 'no non-missing arguments to max; returning -Inf';
    return negativeInf;
  }
  
  my @a2_elements;
  my $x1_elements = $x1->decompose_elements;
  my $min = shift @$x1_elements;
  push @a2_elements, $min;
  for my $element (@$x1_elements) {
    if ($element->is_na->value) {
      return NA;
    }
    elsif ($element->is_nan->value) {
      $min = $element;
    }
    if (Rstats::VectorFunc::less_than($element, $min)->value && !$min->is_nan->value) {
      $min = $element;
    }
    push @a2_elements, $min;
  }
  
  return c(\@a2_elements);
}

sub cumsum {
  my $x1 = to_c(shift);
  my $type = $x1->vector->type;
  my $total = Rstats::VectorFunc::create($type);
  my @a2_elements;
  push @a2_elements, $total = Rstats::VectorFunc::add($total, $_) for @{$x1->decompose_elements};
  
  return c(\@a2_elements);
}

sub cumprod {
  my $x1 = to_c(shift);
  my $type = $x1->vector->type;
  my $total = Rstats::VectorFunc::create($type, 1);
  my @a2_elements;
  push @a2_elements, $total = Rstats::VectorFunc::multiply($total, $_) for @{$x1->decompose_elements};
  
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
    elsif ($i < @_) {
      $arg = to_c($_[$i]);
    }
    push @args, $arg;
  }
  
  croak "unused argument ($_)" for keys %$opt;
  
  return @args;
}

sub complex {
  my ($x1_re, $x1_im, $x1_mod, $x1_arg) = args(['re', 'im', 'mod', 'arg'], @_);
  
  $x1_mod = NULL unless defined $x1_mod;
  $x1_arg = NULL unless defined $x1_arg;

  my $x2_elements = [];
  # Create complex from mod and arg
  if ($x1_mod->length_value || $x1_arg->length_value) {
    my $x1_mod_length = $x1_mod->length_value;
    my $x1_arg_length = $x1_arg->length_value;
    my $longer_length = $x1_mod_length > $x1_arg_length ? $x1_mod_length : $x1_arg_length;
    
    my $x1_mod_elements = $x1_mod->decompose_elements;
    my $x1_arg_elements = $x1_arg->decompose_elements;
    for (my $i = 0; $i < $longer_length; $i++) {
      my $mod = $x1_mod_elements->[$i];
      $mod = Rstats::VectorFunc::new_double(1) unless $mod;
      my $arg = $x1_arg_elements->[$i];
      $arg = Rstats::VectorFunc::new_double(0) unless $arg;
      
      my $re = Rstats::VectorFunc::multiply(
        $mod,
        Rstats::VectorFunc::cos($arg)
      );
      my $im = Rstats::VectorFunc::multiply(
        $mod,
        Rstats::VectorFunc::sin($arg)
      );
      
      my $x2_element = Rstats::VectorFunc::complex_double($re, $im);
      push @$x2_elements, $x2_element;
    }
  }
  # Create complex from re and im
  else {
    croak "mode should be numeric" unless $x1_re->is_numeric && $x1_im->is_numeric;
    
    my $x1_re_elements = $x1_re->decompose_elements;
    my $x1_im_elements = $x1_im->decompose_elements;
    for (my $i = 0; $i <  $x1_im->length_value; $i++) {
      my $re = $x1_re_elements->[$i] || Rstats::VectorFunc::new_double(0);
      my $im = $x1_im_elements->[$i];
      my $x2_element = Rstats::VectorFunc::complex_double($re, $im);
      push @$x2_elements, $x2_element;
    }
  }
  
  return c($x2_elements);
}

sub exp { process_unary(\&Rstats::VectorFunc::exp, @_) }

sub expm1 { process(\&Rstats::VectorFunc::expm1, @_) }

sub max_type {
  my @xs = @_;
  
  my $type_h = {};
  
  for my $x (@xs) {
    my $x_type = $x->typeof->value;
    $type_h->{$x_type}++;
    unless ($x->is_null) {
      my $element = $x->vector_part;
      my $element_type = $element->type;
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
  my $_x1 = shift;
  
  my $x1 = to_c($_x1);
  
  my @a2_elements = map { Rstats::VectorFunc::new_double(POSIX::floor $_->value) } @{$x1->decompose_elements};

  my $x2 = c(\@a2_elements);
  $x1->copy_attrs_to($x2);
  $x2->mode('double');
  
  return $x2;
}

sub head {
  my ($x1, $x_n) = args(['x1', 'n'], @_);
  
  my $n = defined $x_n ? $x_n->value : 6;
  
  if ($x1->is_data_frame) {
    my $max = $x1->{row_length} < $n ? $x1->{row_length} : $n;
    
    my $x_range = ve("1:$max");
    my $x2 = $x1->get($x_range, Rstats::Func::NULL());
    
    return $x2;
  }
  else {
    my $x1_elements = $x1->decompose_elements;
    my $max = $x1->length_value < $n ? $x1->length_value : $n;
    my @x2_elements;
    for (my $i = 0; $i < $max; $i++) {
      push @x2_elements, $x1_elements->[$i];
    }
    
    my $x2 = c(\@x2_elements);
    $x1->copy_attrs_to($x2);
  
    return $x2;
  }
}

sub i {
  my $i = Rstats::VectorFunc::new_complex({re => 0, im => 1});
  
  return c($i);
}

sub ifelse {
  my ($_x1, $value1, $value2) = @_;
  
  my $x1 = to_c($_x1);
  my $x1_values = $x1->values;
  my @x2_values;
  for my $x1_value (@$x1_values) {
    local $_ = $x1_value;
    if ($x1_value) {
      push @x2_values, $value1;
    }
    else {
      push @x2_values, $value2;
    }
  }
  
  return array(\@x2_values);
}

sub log { process_unary(\&Rstats::VectorFunc::log, @_) }
sub logb { process_unary(\&Rstats::VectorFunc::logb, @_) }
sub log2 { process_unary(\&Rstats::VectorFunc::log2, @_) }
sub log10 { process_unary(\&Rstats::VectorFunc::log10, @_) }

sub max {
  my $x1 = c(@_);
  
  unless ($x1->length_value) {
    carp 'no non-missing arguments to max; returning -Inf';
    return negativeInf;
  }
  
  my $x1_elements = $x1->decompose_elements;
  my $max = shift @$x1_elements;
  for my $element (@$x1_elements) {
    
    if ($element->is_na->value) {
      return NA;
    }
    elsif ($element->is_nan->value) {
      $max = $element;
    }
    if (!$max->is_nan->value && Rstats::VectorFunc::more_than($element, $max)->value) {
      $max = $element;
    }
  }
  
  return c($max);
}

sub mean {
  my $x1 = to_c(shift);
  
  my $x2 = divide(sum($x1), $x1->length_value);
  
  return $x2;
}

sub min {
  my $x1 = c(@_);
  
  unless ($x1->length_value) {
    carp 'no non-missing arguments to min; returning -Inf';
    return Inf;
  }
  
  my $x1_elements = $x1->decompose_elements;
  my $min = shift @$x1_elements;
  for my $element (@$x1_elements) {
    
    if ($element->is_na->value) {
      return NA;
    }
    elsif ($element->is_nan->value) {
      $min = $element;
    }
    if (!$min->is_nan->value && Rstats::VectorFunc::less_than($element, $min)->value) {
      $min = $element;
    }
  }
  
  return c($min);
}

sub order {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my @xs = map { to_c($_) } @_;
  
  my @xs_values;
  for my $x (@xs) {
    push @xs_values, $x->values;
  }

  my $decreasing = $opt->{decreasing} || FALSE;
  
  my @pos_vals;
  for my $i (0 .. @{$xs_values[0]} - 1) {
    my $pos_val = {pos => $i + 1};
    $pos_val->{val} = [];
    push @{$pos_val->{val}}, $xs_values[$_][$i] for (0 .. @xs_values);
    push @pos_vals, $pos_val;
  }
  
  my @sorted_pos_values = !$decreasing
    ? sort {
        my $comp;
        for (my $i = 0; $i < @xs_values; $i++) {
          $comp = $a->{val}[$i] <=> $b->{val}[$i];
          last if $comp != 0;
        }
        $comp;
      } @pos_vals
    : sort {
        my $comp;
        for (my $i = 0; $i < @xs_values; $i++) {
          $comp = $b->{val}[$i] <=> $a->{val}[$i];
          last if $comp != 0;
        }
        $comp;
      } @pos_vals;
  my @orders = map { $_->{pos} } @sorted_pos_values;
  
  return c(\@orders);
}

# TODO
# na.last
sub rank {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $x1 = to_c(shift);
  my $decreasing = $opt->{decreasing};
  
  my $x1_values = $x1->values;
  
  my @pos_vals;
  push @pos_vals, {pos => $_ + 1, value => $x1_values->[$_]} for (0 .. @$x1_values - 1);
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
  my $x1 = shift;
  
  my $x1_values = $x1->values;
  my $x2_values = [];
  push @$x2_values, "$str$sep$_" for @$x1_values;
  
  return c($x2_values);
}

sub pmax {
  my @vs = @_;
  
  my @maxs;
  for my $v (@vs) {
    my $elements = $v->decompose_elements;
    for (my $i = 0; $i <@$elements; $i++) {
      $maxs[$i] = $elements->[$i]
        if !defined $maxs[$i] || Rstats::VectorFunc::more_than($elements->[$i], $maxs[$i])->value
    }
  }
  
  return  c(\@maxs);
}

sub pmin {
  my @vs = @_;
  
  my @mins;
  for my $v (@vs) {
    my $elements = $v->decompose_elements;
    for (my $i = 0; $i <@$elements; $i++) {
      $mins[$i] = $elements->[$i]
        if !defined $mins[$i] || Rstats::VectorFunc::less_than($elements->[$i], $mins[$i])->value
    }
  }
  
  return c(\@mins);
}

sub prod {
  my $x1 = c(@_);
  
  my $type = $x1->vector->type;
  my $prod = Rstats::VectorFunc::create($type, 1);
  for my $element (@{$x1->decompose_elements}) {
    $prod = Rstats::VectorFunc::multiply($prod, $element);
  }

  return c($prod);
}

sub range {
  my $x1 = shift;
  
  my $min = min($x1);
  my $max = max($x1);
  
  return c($min, $max);
}

sub rbind {
  my (@xs) = @_;
  
  return Rstats::Func::NULL() unless @xs;
  
  if ($xs[0]->is_data_frame) {
    
    # Check names
    my $first_names;
    for my $x (@xs) {
      if ($first_names) {
        my $names = $x->names->values;
        my $different;
        $different = 1 if @$first_names != @$names;
        for (my $i = 0; $i < @$first_names; $i++) {
          $different = 1 if $names->[$i] ne $first_names->[$i];
        }
        croak "rbind require same names having data frame"
          if $different;
      }
      else {
        $first_names = $x->names->values;
      }
    }
    
    # Create new vectors
    my @new_vectors;
    for my $name (@$first_names) {
      my @vector_parts;
      for my $x (@xs) {
        my $v = $x->getin($name);
        if ($v->is_factor) {
          push @vector_parts, $v->as_character;
        }
        else {
          push @vector_parts, $v;
        }
      }
      my $new_vector = c(@vector_parts);
      push @new_vectors, $new_vector;
    }
    
    # Create new data frame
    my @data_frame_args;
    for (my $i = 0; $i < @$first_names; $i++) {
      push @data_frame_args, $first_names->[$i], $new_vectors[$i];
    }
    my $data_frame = data_frame(@data_frame_args);
    
    return $data_frame;
  }
  else {
    my $matrix = cbind(@xs);
    
    return t($matrix);
  }
}

sub rep {
  my ($x1, $x_times) = args(['x1', 'times'], @_);
  
  my $times = defined $x_times ? $x_times->value : 1;
  
  my $elements = [];
  push @$elements, @{$x1->decompose_elements} for 1 .. $times;
  my $x2 = c($elements);
  
  return $x2;
}

sub replace {
  my $x1 = to_c(shift);
  my $x2 = to_c(shift);
  my $v3 = to_c(shift);
  
  my $x1_elements = $x1->decompose_elements;
  my $x2_elements = $x2->decompose_elements;
  my $x2_elements_h = {};
  for my $x2_element (@$x2_elements) {
    my $x2_element_hash = Rstats::VectorFunc::hash($x2_element->as_double);
    
    $x2_elements_h->{$x2_element_hash}++;
    croak "replace second argument can't have duplicate number"
      if $x2_elements_h->{$x2_element_hash} > 1;
  }
  my $v3_elements = $v3->decompose_elements;
  my $v3_length = @{$v3_elements};
  
  my $v4_elements = [];
  my $replace_count = 0;
  for (my $i = 0; $i < @$x1_elements; $i++) {
    my $hash = Rstats::VectorFunc::hash(Rstats::VectorFunc::new_double($i + 1));
    if ($x2_elements_h->{$hash}) {
      push @$v4_elements, $v3_elements->[$replace_count % $v3_length];
      $replace_count++;
    }
    else {
      push @$v4_elements, $x1_elements->[$i];
    }
  }
  
  return array($v4_elements);
}

sub rev {
  my $x1 = shift;
  
  # Reverse elements
  my @a2_elements = reverse @{$x1->decompose_elements};
  my $x2 = c(\@a2_elements);
  $x1->copy_attrs_to($x2);
  
  return $x2;
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
  my @x1_elements;
  for (1 .. $count) {
    my ($rand1, $rand2) = (rand, rand);
    while ($rand1 == 0) { $rand1 = rand(); }
    
    my $rnorm = ($sd * sqrt(-2 * CORE::log($rand1))
      * sin(2 * Math::Trig::pi * $rand2))
      + $mean;
    
    push @x1_elements, $rnorm;
  }
  
  return c(\@x1_elements);
}

sub round {

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my ($_x1, $digits) = @_;
  $digits = $opt->{digits} unless defined $digits;
  $digits = 0 unless defined $digits;
  
  my $x1 = to_c($_x1);

  my $r = 10 ** $digits;
  my @a2_elements = map { Rstats::VectorFunc::new_double(Math::Round::round_even($_->value * $r) / $r) } @{$x1->decompose_elements};
  my $x2 = c(\@a2_elements);
  $x1->copy_attrs_to($x2);
  $x2->mode('double');
  
  return $x2;
}

sub rowMeans {
  my $x1 = shift;
  
  my $dim_values = $x1->dim->values;
  if (@$dim_values == 2) {
    my $x1_values = [];
    for my $col (1 .. $dim_values->[1]) {
      my $x1_value = 0;
      $x1_value += $x1->value($_, $col) for (1 .. $dim_values->[0]);
      push @$x1_values, $x1_value / $dim_values->[0];
    }
    return c($x1_values);
  }
  else {
    croak "Can't culculate rowMeans";
  }
}

sub rowSums {
  my $x1 = shift;
  
  my $dim_values = $x1->dim->values;
  if (@$dim_values == 2) {
    my $x1_values = [];
    for my $col (1 .. $dim_values->[1]) {
      my $x1_value = 0;
      $x1_value += $x1->value($_, $col) for (1 .. $dim_values->[0]);
      push @$x1_values, $x1_value;
    }
    return c($x1_values);
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
  my @x1_elements;
  if (defined $opt->{seed}) {
    srand $opt->{seed};
  }
  for (1 .. $count) {
    my $rand = rand($diff) + $min;
    push @x1_elements, $rand;
  }
  
  return c(\@x1_elements);
}

# TODO: prob option
sub sample {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  my ($_x1, $length) = @_;
  my $x1 = to_c($_x1);
  
  # Replace
  my $replace = $opt->{replace};
  
  my $x1_length = $x1->length_value;
  $length = $x1_length unless defined $length;
  
  croak "second argument element must be bigger than first argument elements count when you specify 'replace' option"
    if $length > $x1_length && !$replace;
  
  my @x2_elements;
  my $x1_elements = $x1->decompose_elements;
  for my $i (0 .. $length - 1) {
    my $rand_num = int(rand @$x1_elements);
    my $rand_element = splice @$x1_elements, $rand_num, 1;
    push @x2_elements, $rand_element;
    push @$x1_elements, $rand_element if $replace;
  }
  
  return c(\@x2_elements);
}

sub sequence {
  my $_x1 = shift;
  
  my $x1 = to_c($_x1);
  my $x1_values = $x1->values;
  
  my @x2_values;
  for my $x1_value (@$x1_values) {
    push @x2_values, seq(1, $x1_value)->values;
  }
  
  return c(\@x2_values);
}

sub sinh { process_unary(\&Rstats::VectorFunc::sinh, @_) }
sub sqrt { process_unary(\&Rstats::VectorFunc::sqrt, @_) }

sub sort {

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $x1 = to_c(shift);
  my $decreasing = $opt->{decreasing};
  
  my @a2_elements = grep { !$_->is_na->value && !$_->is_nan->value } @{$x1->decompose_elements};
  
  my $x3_elements = $decreasing
    ? [reverse sort { Rstats::VectorFunc::more_than($a, $b)->value ? 1 : Rstats::VectorFunc::equal($a, $b)->value ? 0 : -1 } @a2_elements]
    : [sort { Rstats::VectorFunc::more_than($a, $b)->value ? 1 : Rstats::VectorFunc::equal($a, $b)->value ? 0 : -1 } @a2_elements];

  return c($x3_elements);
}

sub tail {

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $x1 = shift;
  
  my $n = $opt->{n};
  $n = 6 unless defined $n;
  
  my $e1 = $x1->decompose_elements;
  my $max = $x1->length_value < $n ? $x1->length_value : $n;
  my @e2;
  for (my $i = 0; $i < $max; $i++) {
    unshift @e2, $e1->[$x1->length_value - ($i  + 1)];
  }
  
  my $x2 = c(\@e2);
  $x1->copy_attrs_to($x1);
  
  return $x2;
}

sub tan { process_unary(\&Rstats::VectorFunc::tan, @_) }

sub process {
  my $func = shift;
  my $x1 = to_c(shift);
  
  my @a2_elements = map { $func->($_) } @{$x1->decompose_elements};
  my $x2 = c(\@a2_elements);
  $x1->copy_attrs_to($x2);
  $x2->mode(max_type($x1, $x2));
  
  return $x2;
}

sub sin { process_unary(\&Rstats::VectorFunc::sin, @_) }

sub process_unary {
  my $func = shift;
  my $x1 = to_c(shift);
  
  my $x2_elements = $func->($x1->vector);
  my $x2 = NULL;
  $x2->vector($x2_elements);
  $x1->copy_attrs_to($x2);
  
  return $x2;
}

sub tanh { process_unary(\&Rstats::VectorFunc::tanh, @_) }

sub trunc {
  my ($_x1) = @_;
  
  my $x1 = to_c($_x1);
  
  my @a2_elements
    = map { Rstats::VectorFunc::new_double(int $_->value) } @{$x1->decompose_elements};

  my $x2 = c(\@a2_elements);
  $x1->copy_attrs_to($x2);
  $x2->mode('double');
  
  return $x2;
}

sub unique {
  my $x1 = to_c(shift);
  
  if ($x1->is_vector) {
    my $x2_elements = [];
    my $elements_count = {};
    my $na_count;
    for my $x1_element (@{$x1->decompose_elements}) {
      if ($x1_element->is_na->value) {
        unless ($na_count) {
          push @$x2_elements, $x1_element;
        }
        $na_count++;
      }
      else {
        my $str = $x1_element->to_string;
        unless ($elements_count->{$str}) {
          push @$x2_elements, $x1_element;
        }
        $elements_count->{$str}++;
      }
    }

    return c($x2_elements);
  }
  else {
    return $x1;
  }
}

sub median {
  my $x1 = to_c(shift);
  
  my $x2 = unique($x1);
  my $x3 = Rstats::Func::sort($x2);
  my $x3_length = $x3->length_value;
  
  if ($x3_length % 2 == 0) {
    my $middle = $x3_length / 2;
    my $x4 = $x3->get($middle);
    my $x5 = $x3->get($middle + 1);
    
    return ($x4 + $x5) / 2;
  }
  else {
    my $middle = int($x3_length / 2) + 1;
    return $x3->get($middle);
  }
}

sub quantile {
  my $x1 = to_c(shift);
  
  my $x2 = unique($x1);
  my $x3 = Rstats::Func::sort($x2);
  my $x3_length = $x3->length_value;
  
  my $quantile_elements = [];
  
  # Min
  push @$quantile_elements , $x3->get(1);
  
  # 1st quoter
  if ($x3_length % 4 == 0) {
    my $first_quoter = $x3_length * (1 / 4);
    my $x4 = $x3->get($first_quoter);
    my $x5 = $x3->get($first_quoter + 1);
    
    push @$quantile_elements, ((($x4 + $x5) / 2) + $x5) / 2;
  }
  else {
    my $first_quoter = int($x3_length * (1 / 4)) + 1;
    push @$quantile_elements, $x3->get($first_quoter);
  }
  
  # middle
  if ($x3_length % 2 == 0) {
    my $middle = $x3_length / 2;
    my $x4 = $x3->get($middle);
    my $x5 = $x3->get($middle + 1);
    
    push @$quantile_elements, (($x4 + $x5) / 2);
  }
  else {
    my $middle = int($x3_length / 2) + 1;
    push @$quantile_elements, $x3->get($middle);
  }
  
  # 3rd quoter
  if ($x3_length % 4 == 0) {
    my $third_quoter = $x3_length * (3 / 4);
    my $x4 = $x3->get($third_quoter);
    my $x5 = $x3->get($third_quoter + 1);
    
    push @$quantile_elements, (($x4 + (($x4 + $x5) / 2)) / 2);
  }
  else {
    my $third_quoter = int($x3_length * (3 / 4)) + 1;
    push @$quantile_elements, $x3->get($third_quoter);
  }
  
  # Max
  push @$quantile_elements , $x3->get($x3_length);
  
  my $x4 = Rstats::Func::c($quantile_elements);
  $x4->names(Rstats::Func::c(qw/0%  25%  50%  75% 100%/));
  
  return $x4;
}

sub sd {
  my $x1 = to_c(shift);
  
  my $sd = Rstats::Func::sqrt(var($x1));
  
  return $sd;
}

sub var {
  my $x1 = to_c(shift);
  
  my $var = sum(($x1 - mean($x1)) ** 2) / ($x1->length_value - 1);
  
  return $var;
}

sub which {
  my ($_x1, $cond_cb) = @_;
  
  my $x1 = to_c($_x1);
  my $x1_values = $x1->values;
  my @x2_values;
  for (my $i = 0; $i < @$x1_values; $i++) {
    local $_ = $x1_values->[$i];
    if ($cond_cb->($x1_values->[$i])) {
      push @x2_values, $i + 1;
    }
  }
  
  return c(\@x2_values);
}

sub new_vector {
  my $type = shift;
  
  if ($type eq 'character') {
    return new_character(@_);
  }
  elsif ($type eq 'complex') {
    return new_complex(@_);
  }
  elsif ($type eq 'double') {
    return new_double(@_);
  }
  elsif ($type eq 'integer') {
    return new_integer(@_);
  }
  elsif ($type eq 'logical') {
    return new_logical(@_);
  }
  else {
    croak("Invalid type $type is passed(new_vector)");
  }
}

sub new_character {
  my $x1 = Rstats::Func::NULL();
  $x1->vector(Rstats::VectorFunc::new_character(@_));
}

sub new_complex {
  my $x1 = Rstats::Func::NULL();
  $x1->vector(Rstats::VectorFunc::new_complex(@_));
}

sub new_double {
  my $x1 = Rstats::Func::NULL();
  $x1->vector(Rstats::VectorFunc::new_double(@_));
}

sub new_integer {
  my $x1 = Rstats::Func::NULL();
  $x1->vector(Rstats::VectorFunc::new_integer(@_));
}

sub new_logical {
  my $x1 = Rstats::Func::NULL();
  $x1->vector(Rstats::VectorFunc::new_logical(@_));
}

sub matrix {
  my ($x1, $x_nrow, $x_ncol, $x_byrow, $x_dirnames)
    = args(['x1', 'nrow', 'ncol', 'byrow', 'dirnames'], @_);

  croak "matrix method need data as frist argument"
    unless defined $x1;
  
  # Row count
  my $nrow;
  $nrow = $x_nrow->value if defined $x_nrow;
  
  # Column count
  my $ncol;
  $ncol = $x_ncol->value if defined $x_ncol;
  
  # By row
  my $byrow;
  $byrow = $x_byrow->value if defined $x_byrow;
  
  my $x1_values = $x1->values;
  my $x1_length = $x1->length_value;
  if (!defined $nrow && !defined $ncol) {
    $nrow = $x1_length;
    $ncol = 1;
  }
  elsif (!defined $nrow) {
    $nrow = int($x1_length / $ncol);
  }
  elsif (!defined $ncol) {
    $ncol = int($x1_length / $nrow);
  }
  my $length = $nrow * $ncol;
  
  my $dim = [$nrow, $ncol];
  my $matrix;
  my $x_matrix = Rstats::Func::NULL();
  $x_matrix->vector(Rstats::VectorFunc::new_vector($x1->vector->type, @$x1_values));
  if ($byrow) {
    $matrix = array(
      $x_matrix,
      [$dim->[1], $dim->[0]],
    );
    
    $matrix = t($matrix);
  }
  else {
    $matrix = array($x_matrix, $dim);
  }
  
  return $matrix;
}

sub Mod { Rstats::Func::abs(@_) }

sub inner_product {
  my ($x1, $x2) = @_;
  
  # Convert to matrix
  $x1 = t($x1->as_matrix) if $x1->is_vector;
  $x2 = $x2->as_matrix if $x2->is_vector;
  
  # Calculate
  if ($x1->is_matrix && $x2->is_matrix) {
    
    croak "requires numeric/complex matrix/vector arguments"
      if $x1->length_value == 0 || $x2->length_value == 0;
    croak "Error in a x b : non-conformable arguments"
      unless $x1->dim->values->[1] == $x2->dim->values->[0];
    
    my $row_max = $x1->dim->values->[0];
    my $col_max = $x2->dim->values->[1];
    
    my $x3_elements = [];
    for (my $col = 1; $col <= $col_max; $col++) {
      for (my $row = 1; $row <= $row_max; $row++) {
        my $x1_part = $x1->get($row);
        my $x2_part = $x2->get(NULL, $col);
        my $x3_part = sum($x1 * $x2);
        push @$x3_elements, $x3_part;
      }
    }
    
    my $x3 = matrix($x3_elements, $row_max, $col_max);
    
    return $x3;
  }
  else {
    croak "inner_product should be dim < 3."
  }
}

sub row {
  my $x1 = shift;
  
  my $nrow = nrow($x1)->value;
  my $ncol = ncol($x1)->value;
  
  my @values = (1 .. $nrow) x $ncol;
  
  return array(\@values, [$nrow, $ncol]);
}

sub sum {
  my $x1 = to_c(shift);
  
  my $x2 = Rstats::Array->new;
  $x2->vector(Rstats::VectorFunc::sum($x1->vector));
  
  return $x2;
}

sub ncol {
  my $x1 = shift;
  
  if ($x1->is_data_frame) {
    return c($x1->length_value);
  }
  elsif ($x1->is_list) {
    return Rstats::Func::NULL();
  }
  else {
    return c($x1->dim->values->[1]);
  }
}

sub seq {
  
  # Option
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  # Along
  my $_along = $opt->{along};
  if (defined $_along) {
    my $along = to_c($_along);
    my $length = $along->length_value;
    return seq(1, $length);
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

sub numeric {
  my $num = shift;
  
  return c((0) x $num);
}

sub to_c {
  my $_x = shift;
  
  my $is_container;
  eval {
    $is_container = $_x->isa('Rstats::Container');
  };
  my $x1 = $is_container ? $_x : c($_x);
  
  return $x1;
}

sub upgrade_type {
  my (@xs) = @_;
  
  # Check elements
  my $type_h = {};
  for my $x1 (@xs) {
    my $type = $x1->vector->type || '';
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
    $_ = $_->as($to_type) for @xs;
  }
  
  return @xs;
}

1;

=head1 NAME

Rstats::Func - Functions

