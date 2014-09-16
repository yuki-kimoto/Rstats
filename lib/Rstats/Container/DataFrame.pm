package Rstats::Container::DataFrame;
use Rstats::Container::List -base;

use overload '""' => \&to_string,
  fallback => 1;

use Rstats::Func;

use Text::UnicodeTable::Simple;
{
  package Text::UnicodeTable::Simple;
  no warnings 'redefine';
  sub _decide_alignment {
    # always ALIGN_RIGHT;
    return 2;
  }
}

sub get {
  my $self = shift;
  my $_row_index = shift;
  my $_col_index = shift;
  
  # Fix column index and row index
  unless (defined $_col_index) {
    $_col_index = $_row_index;
    $_row_index = [];
  }
  my $row_index = Rstats::Func::to_c($_row_index);
  my $col_index = Rstats::Func::to_c($_col_index);

  # Convert name index to number index
  my $col_index_values;
  if ($col_index->is_character) {
    $col_index_values = [];
    for my $element (@{$col_index->elements}) {
      push @$col_index_values, $self->_name_to_index($element);
    }
  }
  elsif ($col_index->is_logical) {
    for (my $i = 0; $i < @{$col_index->values}; $i++) {
      push @$col_index_values, $i + 1 if $col_index->elements->[$i];
    }
  }
  else {
    $col_index_values = $col_index->values;
  }
  
  # Extract columns
  my $elements = $self->elements;
  my $new_elements = [];
  for my $i (@{$col_index_values}) {
    push @$new_elements, $elements->[$i - 1];
  }
  
  # Extract rows
  for my $new_element (@$new_elements) {
    $new_element = $new_element->get($row_index) unless $row_index->is_null;
  }
  
  # Create new data frame
  my $data_frame = Rstats::Container::DataFrame->new;
  $data_frame->elements($new_elements);
  $self->_copy_attrs_to($data_frame, [$row_index, Rstats::Func::c($col_index_values)]);
  $data_frame->{dimnames}[0] = [1 .. $data_frame->getin(1)->length_value];
  
  return $data_frame;
}

sub to_string {
  my $self = shift;

  my $t = Text::UnicodeTable::Simple->new(border => 0);
  
  # Names
  my $column_names = $self->names->values;
  $t->set_header('', @$column_names);
  
  # columns
  my $columns = [];
  for (my $i = 1; $i <= @$column_names; $i++) {
    my $array = $self->getin($i);
    $array = $array->as_character if $array->is_factor;
    push @$columns, $array->elements;
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
