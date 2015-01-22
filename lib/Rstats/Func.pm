package Rstats::Func;

use strict;
use warnings;
use Carp qw/croak carp/;

use Rstats ();
use Rstats::Vector;

use Rstats::Array;
use Rstats::List;
use Rstats::DataFrame;
use Rstats::VectorFunc;
use Rstats::ArrayFunc;
use Rstats::Util;

use List::Util;
use Math::Trig ();
use POSIX ();
use Math::Round ();
use Encode ();

sub NULL { Rstats::ArrayFunc::NULL }
sub NA  () { Rstats::ArrayFunc::NA }
sub NaN () { Rstats::ArrayFunc::NaN }
sub Inf () { Rstats::ArrayFunc::Inf }
sub FALSE () { Rstats::ArrayFunc::FALSE }
sub F () { Rstats::ArrayFunc::F }
sub TRUE () { Rstats::ArrayFunc::TRUE }
sub T () { Rstats::ArrayFunc::T }
sub pi () { Rstats::ArrayFunc::pi }

sub I {
  my $x1 = shift;
  
  my $x2 = Rstats::ArrayFunc::c($x1);
  $x1->copy_attrs_to($x2);
  $x2->class('AsIs');
  
  return $x2;
}

sub subset {
  my ($x1, $x_condition, $x_names)
    = args_array(['x1', 'condition', 'names'], @_);
  
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
      my $value = $x1->value($row, $col);
      $x2->at($col, $row);
      $x2->set($value);
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
      push @poss, $index unless defined $v->value($index);
    }
  }
  
  my $x2 = $x1->get(-(c(@poss)), NULL);
  
  return $x2;
}

# TODO: merge is not implemented yet
sub merge {
  die "merge is not implemented yet";
  
  my ($x1, $x2, $x_all, $x_all_x, $x_all_y, $x_by, $x_by_x, $x_by_y, $x_sort)
    = args_array([qw/x1 x2 all all.x all.y by by.x by.y sort/], @_);
  
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
    = args_array([qw/file sep skip nrows header comment.char row.names encoding/], @_);
  
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
      my $x1 = Rstats::ArrayFunc::c(@{$columns->[$i]});
      push @$data_frame_args, $x1->as_factor;
    }
    elsif ($type eq 'complex') {
      my $x1 = Rstats::ArrayFunc::c(@{$columns->[$i]});
      push @$data_frame_args, $x1->as_complex;
    }
    elsif ($type eq 'double') {
      my $x1 = Rstats::ArrayFunc::c(@{$columns->[$i]});
      push @$data_frame_args, $x1->as_double;
    }
    elsif ($type eq 'integer') {
      my $x1 = Rstats::ArrayFunc::c(@{$columns->[$i]});
      push @$data_frame_args, $x1->as_integer;
    }
    else {
      my $x1 = Rstats::ArrayFunc::c(@{$columns->[$i]});
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
  ($x_drop, $x_sep) = args_array(['drop', 'sep'], $opt);
  
  $x_sep = Rstats::ArrayFunc::c(".") unless defined $x_sep;
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
    $f1 = factor(c(@$f1_elements));
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
    $f1 = factor(c(@$f1_elements), {levels => Rstats::ArrayFunc::c(@$f1_levels_elements)});
  }
  
  return $f1;
}

sub gl {
  my ($x_n, $x_k, $x_length, $x_labels, $x_ordered)
    = args_array([qw/n k length labels ordered/], @_);
  
  my $n = $x_n->value;
  my $k = $x_k->value;
  $x_length = Rstats::ArrayFunc::c($n * $k) unless defined $x_length;
  my $length = $x_length->value;
  
  my $x_levels = Rstats::ArrayFunc::c(1 .. $n);
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
  
  my $x1 = Rstats::ArrayFunc::c(@$x1_elements);
  
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
    = args_array([qw/x levels labels exclude ordered/], @_);

  # default - x
  $x1 = $x1->as_character unless $x1->is_character;
  
  # default - levels
  unless (defined $x_levels) {
    $x_levels = Rstats::Func::sort(unique($x1), {'na.last' => TRUE});
  }
  
  # default - exclude
  $x_exclude = NA unless defined $x_exclude;
  
  # fix levels
  if (defined $x_exclude->value && $x_exclude->length->value) {
    my $new_a_levels_values = [];
    for my $x_levels_value (@{$x_levels->values}) {
      my $match;
      for my $x_exclude_value (@{$x_exclude->values}) {
        if (defined $x_levels_value
          && defined $x_exclude_value
          && $x_levels_value eq $x_exclude_value)
        {
          $match = 1;
          last;
        }
      }
      push @$new_a_levels_values, $x_levels_value unless $match;
    }
    $x_levels = Rstats::ArrayFunc::c(@$new_a_levels_values);
  }
  
  # default - labels
  unless (defined $x_labels) {
    $x_labels = $x_levels;
  }
  
  # default - ordered
  $x_ordered = $x1->is_ordered unless defined $x_ordered;
  
  my $x1_values = $x1->values;
  
  my $labels_length = $x_labels->length->value;
  my $levels_length = $x_levels->length->value;
  if ($labels_length == 1 && $x1->length_value != 1) {
    my $value = $x_labels->value;
    $x_labels = paste($value, se("1:$levels_length"), {sep => ""});
  }
  elsif ($labels_length != $levels_length) {
    croak("Error in factor 'labels'; length $labels_length should be 1 or $levels_length");
  }
  
  # Levels hash
  my $levels;
  my $x_levels_values = $x_levels->values;
  for (my $i = 1; $i <= $levels_length; $i++) {
    my $x_levels_value = $x_levels_values->[$i - 1];
    $levels->{$x_levels_value} = $i;
  }
  
  my $f1_values = [];
  for my $x1_value (@$x1_values) {
    if (!defined $x1_value) {
      push @$f1_values, undef;
    }
    else {
      my $f1_value = exists $levels->{$x1_value}
        ? $levels->{$x1_value}
        : undef;
      push @$f1_values, $f1_value;
    }
  }
  
  my $f1 = Rstats::Func::new_integer(@$f1_values);
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
        push @$elements, splice(@{$v->values}, 0, $count);
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
      $elements->[$i] = Rstats::ArrayFunc::c(@$repeat_elements);
    }
  }
  
  # Create data frame
  my $data_frame = Rstats::DataFrame->new;
  $data_frame->{row_length} = $max_count;
  $data_frame->list($elements);
  $data_frame->dimnames(
    Rstats::Func::list(
      Rstats::ArrayFunc::c(@$row_names),
      Rstats::ArrayFunc::c(@$column_names)
    )
  );
  
  return $data_frame;
}

sub upper_tri {
  my ($x1_m, $x1_diag) = args_array(['m', 'diag'], @_);
  
  my $diag = defined $x1_diag ? $x1_diag->value : 0;
  
  my $x2_values = [];
  if ($x1_m->is_matrix) {
    my $x1_dim_values = $x1_m->dim->values;
    my $rows_count = $x1_dim_values->[0];
    my $cols_count = $x1_dim_values->[1];
    
    for (my $col = 0; $col < $cols_count; $col++) {
      for (my $row = 0; $row < $rows_count; $row++) {
        my $x2_value;
        if ($diag) {
          $x2_value = $col >= $row ? 1 : 0;
        }
        else {
          $x2_value = $col > $row ? 1 : 0;
        }
        push @$x2_values, $x2_value;
      }
    }
    
    my $x2 = matrix(Rstats::Func::new_logical(@$x2_values), $rows_count, $cols_count);
    
    return $x2;
  }
  else {
    croak 'Not implemented';
  }
}

sub lower_tri {
  my ($x1_m, $x1_diag) = args_array(['m', 'diag'], @_);
  
  my $diag = defined $x1_diag ? $x1_diag->value : 0;
  
  my $x2_values = [];
  if ($x1_m->is_matrix) {
    my $x1_dim_values = $x1_m->dim->values;
    my $rows_count = $x1_dim_values->[0];
    my $cols_count = $x1_dim_values->[1];
    
    for (my $col = 0; $col < $cols_count; $col++) {
      for (my $row = 0; $row < $rows_count; $row++) {
        my $x2_value;
        if ($diag) {
          $x2_value = $col <= $row ? 1 : 0;
        }
        else {
          $x2_value = $col < $row ? 1 : 0;
        }
        push @$x2_values, $x2_value;
      }
    }
    
    my $x2 = matrix(Rstats::Func::new_logical(@$x2_values), $rows_count, $cols_count);
    
    return $x2;
  }
  else {
    croak 'Not implemented';
  }
}

sub diag {
  my $x1 = to_c(shift);
  
  my $size;
  my $x2_values;
  if ($x1->length_value == 1) {
    $size = $x1->value;
    $x2_values = [];
    push @$x2_values, 1 for (1 .. $size);
  }
  else {
    $size = $x1->length_value;
    $x2_values = $x1->values;
  }
  
  my $x2 = matrix(0, $size, $size);
  for (my $i = 0; $i < $size; $i++) {
    $x2->at($i + 1, $i + 1);
    $x2->set($x2_values->[$i]);
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
  my $x2_values = $x2->values;
  
  for (my $i = 0; $i < $size; $i++) {
    $x1->at($i + 1, $i + 1);
    $x1->set($x2_values->[$i]);
  }
  
  return $x1;
}

sub kronecker {
  my $x1 = to_c(shift);
  my $x2 = to_c(shift);
  
  ($x1, $x2) = Rstats::ArrayFunc::upgrade_type($x1, $x2) if $x1->type ne $x2->type;
  
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
  
  my $x3_values = [];
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
    my $x1_value = $x1->value(@$x1_index);
    my $x2_value = $x2->value(@$x2_index);
    my $x3_value = multiply($x1_value, $x2_value);
    push @$x3_values, $x3_value;
  }
  
  my $x3 = array(c(@$x3_values), Rstats::ArrayFunc::c(@$x3_dim_values));
  
  return $x3;
}

sub outer {
  my $x1 = to_c(shift);
  my $x2 = to_c(shift);
  
  ($x1, $x2) = Rstats::ArrayFunc::upgrade_type($x1, $x2) if $x1->type ne $x2->type;
  
  my $x1_dim = $x1->dim;
  my $x2_dim = $x2->dim;
  my $x3_dim = [@{$x1_dim->values}, @{$x2_dim->values}];
  
  my $indexs = [];
  for my $x3_d (@$x3_dim) {
    push @$indexs, [1 .. $x3_d];
  }
  my $poses = Rstats::Util::cross_product($indexs);
  
  my $x1_dim_length = $x1_dim->length_value;
  my $x3_values = [];
  for my $pos (@$poses) {
    my $pos_tmp = [@$pos];
    my $x1_pos = [splice @$pos_tmp, 0, $x1_dim_length];
    my $x2_pos = $pos_tmp;
    my $x1_value = $x1->value(@$x1_pos);
    my $x2_value = $x2->value(@$x2_pos);
    my $x3_value = $x1_value * $x2_value;
    push @$x3_values, $x3_value;
  }
  
  my $x3 = array(c(@$x3_values), Rstats::ArrayFunc::c(@$x3_dim));
  
  return $x3;
}

sub Mod { operate_unary(\&Rstats::VectorFunc::Mod, @_) }

sub Arg { operate_unary(\&Rstats::VectorFunc::Arg, @_) }

sub sub {
  my ($x1_pattern, $x1_replacement, $x1_x, $x1_ignore_case)
    = args_array(['pattern', 'replacement', 'x', 'ignore.case'], @_);
  
  my $pattern = $x1_pattern->value;
  my $replacement = $x1_replacement->value;
  my $ignore_case = defined $x1_ignore_case ? $x1_ignore_case->value : 0;
  
  my $x2_values = [];
  for my $x (@{$x1_x->values}) {
    if (!defined $x) {
      push @$x2_values, undef;
    }
    else {
      if ($ignore_case) {
        $x =~ s/$pattern/$replacement/i;
      }
      else {
        $x =~ s/$pattern/$replacement/;
      }
      push @$x2_values, "$x";
    }
  }
  
  my $x2 = Rstats::Func::new_character(@$x2_values);
  $x1_x->copy_attrs_to($x2);
  
  return $x2;
}

sub gsub {
  my ($x1_pattern, $x1_replacement, $x1_x, $x1_ignore_case)
    = args_array(['pattern', 'replacement', 'x', 'ignore.case'], @_);
  
  my $pattern = $x1_pattern->value;
  my $replacement = $x1_replacement->value;
  my $ignore_case = defined $x1_ignore_case ? $x1_ignore_case->value : 0;
  
  my $x2_values = [];
  for my $x (@{$x1_x->values}) {
    if (!defined $x) {
      push @$x2_values, $x;
    }
    else {
      if ($ignore_case) {
        $x =~ s/$pattern/$replacement/gi;
      }
      else {
        $x =~ s/$pattern/$replacement/g;
      }
      push @$x2_values, $x;
    }
  }
  
  my $x2 = Rstats::Func::new_character(@$x2_values);
  $x1_x->copy_attrs_to($x2);
  
  return $x2;
}

sub grep {
  my ($x1_pattern, $x1_x, $x1_ignore_case) = args_array(['pattern', 'x', 'ignore.case'], @_);
  
  my $pattern = $x1_pattern->value;
  my $ignore_case = defined $x1_ignore_case ? $x1_ignore_case->value : 0;
  
  my $x2_values = [];
  my $x1_x_values = $x1_x->values;
  for (my $i = 0; $i < @$x1_x_values; $i++) {
    my $x = $x1_x_values->[$i];
    
    unless (!defined $x) {
      if ($ignore_case) {
        if ($x =~ /$pattern/i) {
          push @$x2_values, $i + 1;
        }
      }
      else {
        if ($x =~ /$pattern/) {
          push @$x2_values, $i + 1;
        }
      }
    }
  }
  
  return Rstats::Func::new_double(@$x2_values);
}

sub se {
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
  
  return array(c(@values), Rstats::ArrayFunc::c($nrow, $ncol));
}

sub chartr {
  my ($x1_old, $x1_new, $x1_x) = args_array(['old', 'new', 'x'], @_);
  
  my $old = $x1_old->value;
  my $new = $x1_new->value;
  
  my $x2_values = [];
  for my $x (@{$x1_x->values}) {
    if (!defined $x) {
      push @$x2_values, $x;
    }
    else {
      $old =~ s#/#\/#;
      $new =~ s#/#\/#;
      eval "\$x =~ tr/$old/$new/";
      croak $@ if $@;
      push @$x2_values, "$x";
    }
  }
  
  my $x2 = Rstats::Func::new_character(@$x2_values);
  $x1_x->copy_attrs_to($x2);
  
  return $x2;
}

sub charmatch {
  my ($x1_x, $x1_table) = args_array(['x', 'table'], @_);
  
  die "Not implemented"
    unless $x1_x->vector->type eq 'character' && $x1_table->vector->type eq 'character';
  
  my $x2_values = [];
  for my $x1_x_value (@{$x1_x->values}) {
    my $x1_x_char = $x1_x_value;
    my $x1_x_char_q = quotemeta($x1_x_char);
    my $match_count;
    my $match_pos;
    my $x1_table_values = $x1_table->values;
    for (my $k = 0; $k < $x1_table->length_value; $k++) {
      my $x1_table_char = $x1_table_values->[$k];
      if ($x1_table_char =~ /$x1_x_char_q/) {
        $match_count++;
        $match_pos = $k;
      }
    }
    if ($match_count == 0) {
      push @$x2_values, undef;
    }
    elsif ($match_count == 1) {
      push @$x2_values, $match_pos + 1;
    }
    elsif ($match_count > 1) {
      push @$x2_values, 0;
    }
  }
  
  return Rstats::Func::new_double(@$x2_values);
}

sub Conj { operate_unary(\&Rstats::VectorFunc::Conj, @_) }

sub Re { operate_unary(\&Rstats::VectorFunc::Re, @_) }

sub Im { operate_unary(\&Rstats::VectorFunc::Im, @_) }

sub nrow {
  my $x1 = shift;
  
  if ($x1->is_data_frame) {
    return Rstats::ArrayFunc::c($x1->{row_length});
  }
  elsif ($x1->is_list) {
    return Rstats::Func::NULL();
  }
  else {
    return Rstats::ArrayFunc::c($x1->dim->values->[0]);
  }
}

sub is_element {
  my ($x1, $x2) = (to_c(shift), to_c(shift));
  
  croak "mode is diffrence" if $x1->vector->type ne $x2->vector->type;
  
  my $type = $x1->type;
  my $x1_values = $x1->values;
  my $x2_values = $x2->values;
  my $x3_values = [];
  for my $x1_value (@$x1_values) {
    my $match;
    for my $x2_value (@$x2_values) {
      if ($type eq 'character') {
        if ($x1_value eq $x2_value) {
          $match = 1;
          last;
        }
      }
      elsif ($type eq 'double' || $type eq 'integer') {
        if ($x1_value == $x2_value) {
          $match = 1;
          last;
        }
      }
      elsif ($type eq 'complex') {
        if ($x1_value->{re} == $x2_value->{re} && $x1_value->{im} == $x2_value->{im}) {
          $match = 1;
          last;
        }
      }
    }
    push @$x3_values, $match ? 1 : 0;
  }
  
  return Rstats::Func::new_logical(@$x3_values);
}

sub setequal {
  my ($x1, $x2) = (to_c(shift), to_c(shift));
  
  croak "mode is diffrence" if $x1->vector->type ne $x2->vector->type;
  
  my $x3 = Rstats::Func::sort($x1);
  my $x4 = Rstats::Func::sort($x2);
  
  return FALSE if $x3->length_value ne $x4->length_value;
  
  my $not_equal;
  my $x3_elements = $x3->decompose;
  my $x4_elements = $x4->decompose;
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
  
  my $x1_elements = $x1->decompose;
  my $x2_elements = $x2->decompose;
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

  return Rstats::ArrayFunc::c(@$x3_elements);
}

sub intersect {
  my ($x1, $x2) = (to_c(shift), to_c(shift));
  
  croak "mode is diffrence" if $x1->vector->type ne $x2->vector->type;
  
  my $x1_elements = $x1->decompose;
  my $x2_elements = $x2->decompose;
  my $x3_elements = [];
  for my $x1_element (@$x1_elements) {
    for my $x2_element (@$x2_elements) {
      if (Rstats::VectorFunc::equal($x1_element, $x2_element)->value) {
        push @$x3_elements, $x1_element;
      }
    }
  }
  
  return Rstats::ArrayFunc::c(@$x3_elements);
}

sub union {
  my ($x1, $x2) = (to_c(shift), to_c(shift));

  croak "mode is diffrence" if $x1->vector->type ne $x2->vector->type;
  
  my $x3 = Rstats::ArrayFunc::c($x1, $x2);
  my $x4 = unique($x3);
  
  return $x4;
}

sub diff {
  my $x1 = to_c(shift);
  
  my $x2_elements = [];
  my $x1_elements = $x1->decompose;
  for (my $i = 0; $i < $x1->length_value - 1; $i++) {
    my $x1_element1 = $x1_elements->[$i];
    my $x1_element2 = $x1_elements->[$i + 1];
    my $x2_element = Rstats::VectorFunc::subtract($x1_element2, $x1_element1);
    push @$x2_elements, $x2_element;
  }
  my $x2 = Rstats::ArrayFunc::c(@$x2_elements);
  $x1->copy_attrs_to($x2);
  
  return $x2;
}

sub nchar {
  my $x1 = to_c(shift);
  
  if ($x1->vector->type eq 'character') {
    my $x2_elements = [];
    for my $x1_element (@{$x1->decompose}) {
      if ($x1_element->is_na->value) {
        push @$x2_elements, $x1_element;
      }
      else {
        my $x2_element = Rstats::VectorFunc::new_double(CORE::length $x1_element->value);
        push @$x2_elements, $x2_element;
      }
    }
    my $x2 = Rstats::ArrayFunc::c(@$x2_elements);
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
    for my $x1_element (@{$x1->decompose}) {
      if ($x1_element->is_na->value) {
        push @$x2_elements, $x1_element;
      }
      else {
        my $x2_element = Rstats::VectorFunc::new_character(lc $x1_element->value);
        push @$x2_elements, $x2_element;
      }
    }
    my $x2 = Rstats::ArrayFunc::c(@$x2_elements);
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
    for my $x1_element (@{$x1->decompose}) {
      if ($x1_element->is_na->value) {
        push @$x2_elements, $x1_element;
      }
      else {
        my $x2_element = Rstats::VectorFunc::new_character(uc $x1_element->value);
        push @$x2_elements, $x2_element;
      }
    }
    my $x2 = Rstats::ArrayFunc::c(@$x2_elements);
    $x1->copy_attrs_to($x2);
    
    return $x2;
  }
  else {
    return $x1;
  }
}

sub match {
  my ($x1, $x2) = (to_c(shift), to_c(shift));
  
  my $x1_elements = $x1->decompose;
  my $x2_elements = $x2->decompose;
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
      push @matches, $i;
    }
    else {
      push @matches, undef;
    }
  }
  
  return Rstats::Func::new_double(@matches);
}

sub operate_binary {
  my ($func, $x1, $x2) = @_;
  
  $x1 = to_c($x1);
  $x2 = to_c($x2);
  
  # Upgrade mode if type is different
  ($x1, $x2) = Rstats::ArrayFunc::upgrade_type($x1, $x2) if $x1->vector->type ne $x2->vector->type;
  
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
  my $x3;
  my $x3_elements = $func->($x1->vector, $x2->vector);
  $x3 = Rstats::Func::NULL();
  $x3->vector($x3_elements);
  
  $x1->copy_attrs_to($x3);

  return $x3;
}

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

sub abs { operate_unary(\&Rstats::VectorFunc::abs, @_) }
sub acos { operate_unary_old(\&Rstats::VectorFunc::acos, @_) }
sub acosh { operate_unary_old(\&Rstats::VectorFunc::acosh, @_) }

sub append {
  my ($x1, $x2, $x_after) = args_array(['x1', 'x2', 'after'], @_);
  
  # Default
  $x_after = NULL unless defined $x_after;
  
  my $x1_length = $x1->length_value;
  $x_after = Rstats::ArrayFunc::c($x1_length) if $x_after->is_null;
  my $after = $x_after->value;
  
  my $x1_elements = $x1->decompose;
  my $x2_elements = $x2->decompose;
  my @x3_elements = @$x1_elements;
  splice @x3_elements, $after, 0, @$x2_elements;
  
  my $x3 = Rstats::ArrayFunc::c(@x3_elements);
  
  return $x3;
}

sub array {
  my $opt = args(['x', 'dim'], @_);
  my $x1 = $opt->{x};
  
  # Dimention
  my $elements = $x1->decompose;
  my $x_dim = exists $opt->{dim} ? $opt->{dim} : NULL;
  my $x1_length = $x1->length_value;
  unless ($x_dim->vector->length_value) {
    $x_dim = Rstats::ArrayFunc::c($x1_length);
  }
  my $dim_product = 1;
  $dim_product *= $_ for @{$x_dim->values};
  
  # Fix elements
  if ($x1_length > $dim_product) {
    @$elements = splice @$elements, 0, $dim_product;
  }
  elsif ($x1_length < $dim_product) {
    my $repeat_count = int($dim_product / @$elements) + 1;
    @$elements = (@$elements) x $repeat_count;
    @$elements = splice @$elements, 0, $dim_product;
  }
  
  my $x2 = Rstats::ArrayFunc::c($elements);
  $x2->dim($x_dim);
  
  return $x2;
}

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
sub ncol {
  my $x1 = shift;
  
  if ($x1->is_data_frame) {
    return Rstats::ArrayFunc::c($x1->length_value);
  }
  elsif ($x1->is_list) {
    return Rstats::Func::NULL();
  }
  else {
    return Rstats::ArrayFunc::c($x1->dim->values->[1]);
  }
}
sub seq { Rstats::ArrayFunc::seq(@_) }
sub numeric { Rstats::ArrayFunc::numeric(@_) }
sub args { Rstats::ArrayFunc::args(@_) }
sub to_c { Rstats::ArrayFunc::to_c(@_) }
sub c { Rstats::ArrayFunc::c(@_) }

1;

=head1 NAME

Rstats::Func - Functions

