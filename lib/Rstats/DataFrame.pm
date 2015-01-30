package Rstats::DataFrame;
use Rstats::List -base;

use overload '""' => \&to_string,
  fallback => 1;

use Carp 'croak';
use Rstats::Func;

use Text::UnicodeTable::Simple;

sub get {
  my $x1 = shift;
  my $_row_index = shift;
  my $_col_index = shift;
  
  # Fix column index and row index
  unless (defined $_col_index) {
    $_col_index = $_row_index;
    $_row_index = Rstats::Func::NULL();
  }
  my $row_index = Rstats::Func::to_c($x1, $_row_index);
  my $col_index = Rstats::Func::to_c($x1, $_col_index);
  
  # Convert name index to number index
  my $col_index_values;
  if (Rstats::Func::is_null($x1, $col_index)) {
    $col_index_values = [1 .. Rstats::Func::names($x1, $x1)->length_value];
  }
  elsif (Rstats::Func::is_character($x1, $col_index)) {
    $col_index_values = [];
    for my $col_index_value (@{$col_index->values}) {
      push @$col_index_values, $x1->_name_to_index($col_index_value);
    }
  }
  elsif (Rstats::Func::is_logical($x1, $col_index)) {
    my $tmp_col_index_values = $col_index->values;
    for (my $i = 0; $i < @$tmp_col_index_values; $i++) {
      push @$col_index_values, $i + 1 if $tmp_col_index_values->[$i];
    }
  }
  else {
    my $col_index_values_tmp = $col_index->values;
    
    if ($col_index_values_tmp->[0] < 0) {
      my $delete_col_index_values_h = {};
      for my $index (@$col_index_values_tmp) {
        croak "Can't contain both plus and minus index" if $index > 0;
        $delete_col_index_values_h->{-$index} = 1;
      }
      
      $col_index_values = [];
      for (my $index = 1; $index <= Rstats::Func::names($x1, $x1)->length_value; $index++) {
        push @$col_index_values, $index unless $delete_col_index_values_h->{$index};
      }
    }
    else {
      $col_index_values = $col_index_values_tmp;
    }
  }
  
  # Extract columns
  my $elements = $x1->list;
  my $new_elements = [];
  for my $i (@{$col_index_values}) {
    push @$new_elements, $elements->[$i - 1];
  }
  
  # Extract rows
  for my $new_element (@$new_elements) {
    $new_element = $new_element->get($row_index)
      unless Rstats::Func::is_null($x1, $row_index);
  }
  
  # Create new data frame
  my $data_frame = Rstats::DataFrame->new;
  $data_frame->list($new_elements);
  Rstats::Func::copy_attrs_to($x1, $x1, $data_frame, {new_indexes => [$row_index, Rstats::ArrayFunc::c($x1, @$col_index_values)]});
  $data_frame->{dimnames}[0] = Rstats::VectorFunc::new_character(1 .. $data_frame->getin(1)->length_value);
  
  return $data_frame;
}

sub to_string {
  my $x1 = shift;

  my $t = Text::UnicodeTable::Simple->new(border => 0, alignment => 'right');
  
  # Names
  my $column_names = Rstats::Func::names($x1, $x1)->values;
  $t->set_header('', @$column_names);
  
  # columns
  my $columns = [];
  for (my $i = 1; $i <= @$column_names; $i++) {
    my $x = $x1->getin($i);
    $x = Rstats::Func::as_character($x1, $x) if Rstats::Func::is_factor($x1, $x);
    push @$columns, $x->values;
  }
  my $col_count = @{$columns};
  my $row_count = @{$columns->[0]};
  
  for (my $i = 0; $i < $row_count; $i++) {
    my @row;
    push @row, $i + 1;
    for (my $k = 0; $k < $col_count; $k++) {
      push @row, $columns->[$k][$i];
    }
    $t->add_row(@row);
  }
  
  return "$t";
}

1;

=head1 NAME

Rstats::DataFrame - Data frame

