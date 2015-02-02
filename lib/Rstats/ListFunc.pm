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
  
  my $x1_index = Rstats::Func::to_c($x1, $_index);
  my $index;
  if (Rstats::Func::is_character($x1, $x1_index)) {
    $index = $x1->_name_to_index($x1_index);
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
  my $index = Rstats::Func::to_c($x1, shift);
  
  my $elements = $x1->list;
  
  my $class = ref $x1;
  my $list = Rstats::Func::list($r);;
  my $list_elements = $list->list;
  
  my $index_values;
  if (Rstats::Func::is_character($x1, $index)) {
    $index_values = [];
    for my $value (@{$index->values}) {
      push @$index_values, $x1->_name_to_index($value);
    }
  }
  else {
    $index_values = $index->values;
  }
  for my $i (@{$index_values}) {
    push @$list_elements, $elements->[$i - 1];
  }
  
  $x1->copy_attrs_to($list, {new_indexes => [Rstats::ArrayFunc::c($x1, @$index_values)]});

  return $list;
}

sub set {
  my $r = shift;
  my ($x1, $v1) = @_;
  
  my $_index = $x1->at;
  my $x1_index = Rstats::Func::to_c($x1, @$_index);
  my $index;
  if (Rstats::Func::is_character($x1, $x1_index)) {
    $index = $x1->_name_to_index($x1_index);
  }
  else {
    $index = $x1_index->values->[0];
  }
  $v1 = Rstats::Func::to_c($x1, $v1);
  
  if (Rstats::Func::is_null($x1, $v1)) {
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
    if ($x1->is_data_frame) {
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
      $$str_ref .= Rstats::ArrayFunc::to_string($r, $element) . "\n";
    }
    pop @$poses;
  }
}

1;

=head1 NAME

Rstats::List - List
