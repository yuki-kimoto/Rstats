package Rstats::ListFunc;
use Rstats::Object -base;

use Rstats::Func;
use Carp 'croak';

use overload '""' => \&to_string,
  fallback => 1;

sub getin {
  my ($r, $x1, $_index) = @_;
  
  unless (defined $_index) {
    $_index = $x1->at;
  }
  $x1->at($_index);
  
  my $x1_index = Rstats::Func::to_c($r, $_index);
  my $index;
  if (Rstats::Func::is_character($r, $x1_index)) {
    $index = Rstats::Func::_name_to_index($r, $x1, $x1_index);
  }
  else {
    $index = $x1_index->values->[0];
  }
  my $elements = $x1->list;
  my $element = $elements->[$index - 1];
  
  return $element;
}

sub get {
  my $r = shift;
  my $x1 = shift;
  my $x_index = Rstats::Func::to_c($r, shift);
  
  my $elements = $x1->list;
  
  my $class = ref $x1;
  my $list = Rstats::Func::list($r);;
  my $list_elements = $list->list;
  
  my $index_values;
  if (Rstats::Func::is_character($r, $x_index)) {
    $index_values = [];
    for my $value (@{$x_index->values}) {
      push @$index_values, Rstats::Func::_name_to_index($r, $x1, $value);
    }
  }
  else {
    $index_values = $x_index->values;
  }
  for my $i (@{$index_values}) {
    push @$list_elements, $elements->[$i - 1];
  }
  
  $DB::single = 1;
  Rstats::Func::copy_attrs_to(
    $r, $x1, $list, {new_indexes => [Rstats::Func::c($r, @$index_values)]}
  );

  return $list;
}

sub set {
  my $r = shift;
  my ($x1, $v1) = @_;
  
  my $_index = $x1->at;
  my $x1_index = Rstats::Func::to_c($r, @$_index);
  my $index;
  if (Rstats::Func::is_character($r, $x1_index)) {
    $index = Rstats::Func::_name_to_index($r, $x1, $x1_index);
  }
  else {
    $index = $x1_index->values->[0];
  }
  $v1 = Rstats::Func::to_c($r, $v1);
  
  if (Rstats::Func::is_null($r, $v1)) {
    splice @{$x1->list}, $index - 1, 1;
    if (exists $x1->{names}) {
      my $new_names_values = $x1->{names}->values;
      splice @$new_names_values, $index - 1, 1;
      $x1->{names} = Rstats::VectorFunc::new_character(@$new_names_values);
    }
    
    if (exists $x1->{dimnames}) {
      my $new_dimname_values = $x1->{dimnames}[1]->values;
      splice @$new_dimname_values, $index - 1, 1;
      $x1->{dimnames}[1] = Rstats::VectorFunc::new_character(@$new_dimname_values);
    }
  }
  else {
    if (Rstats::Func::is_data_frame($r, $x1)) {
      my $x1_length = $x1->length_value;
      my $v1_length = $v1->length_value;
      if ($x1_length != $v1_length) {
        croak "Error in data_frame set: replacement has $v1_length rows, data has $x1_length";
      }
    }
    
    $x1->list->[$index - 1] = $v1;
  }
  
  return $x1;
}

sub to_string {
  my $r = shift;
  my $x1 = shift;
  
  my $poses = [];
  my $str = '';
  _to_string($r, $x1, $poses, \$str);
  
  return $str;
}

sub _to_string {
  my ($r, $list, $poses, $str_ref) = @_;
  
  my $elements = $list->list;
  for (my $i = 0; $i < @$elements; $i++) {
    push @$poses, $i + 1;
    $$str_ref .= join('', map { "[[$_]]" } @$poses) . "\n";
    
    my $element = $elements->[$i];
    if (ref $element eq 'Rstats::List') {
      _to_string($r, $element, $poses, $str_ref);
    }
    else {
      $$str_ref .= Rstats::Func::to_string($r, $element) . "\n";
    }
    pop @$poses;
  }
}

1;

=head1 NAME

Rstats::List - List
