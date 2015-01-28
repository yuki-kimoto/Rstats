package Rstats::Func::List;

use strict;
use warnings;

use Rstats::Func;
use Carp 'croak';

sub getin {
  my ($r, $_index) = @_;
  
  unless (defined $_index) {
    $_index = $r->at;
  }
  $r->at($_index);
  
  my $x1_index = Rstats::Func::to_c($r, $_index);
  my $index;
  if (Rstats::Func::is_character($r, $x1_index)) {
    $index = $r->_name_to_index($x1_index);
  }
  else {
    $index = $x1_index->values->[0];
  }
  my $elements = $r->list;
  my $element = $elements->[$index - 1];
  
  return $element;
}

sub get {
  my $r = shift;
  my $index = Rstats::Func::to_c($r, shift);
  
  my $elements = $r->list;
  
  my $class = ref $r;
  my $list = $class->new;
  my $list_elements = $list->list;
  
  my $index_values;
  if (Rstats::Func::is_character($r, $index)) {
    $index_values = [];
    for my $value (@{$index->values}) {
      push @$index_values, $r->_name_to_index($value);
    }
  }
  else {
    $index_values = $index->values;
  }
  for my $i (@{$index_values}) {
    push @$list_elements, $elements->[$i - 1];
  }
  
  $r->copy_attrs_to($list, {new_indexes => [Rstats::Func::Array::c($r, @$index_values)]});

  return $list;
}

sub set {
  my ($r, $v1) = @_;
  
  my $_index = $r->at;
  my $x1_index = Rstats::Func::to_c($r, @$_index);
  my $index;
  if (Rstats::Func::is_character($r, $x1_index)) {
    $index = $r->_name_to_index($x1_index);
  }
  else {
    $index = $x1_index->values->[0];
  }
  $v1 = Rstats::Func::to_c($r, $v1);
  
  if (Rstats::Func::is_null($r, $v1)) {
    splice @{$r->list}, $index - 1, 1;
    if (exists $r->{names}) {
      my $new_names_values = $r->{names}->values;
      splice @$new_names_values, $index - 1, 1;
      $r->{names} = Rstats::VectorFunc::new_character(@$new_names_values);
    }
    
    if (exists $r->{dimnames}) {
      my $new_dimname_values = $r->{dimnames}[1]->values;
      splice @$new_dimname_values, $index - 1, 1;
      $r->{dimnames}[1] = Rstats::VectorFunc::new_character(@$new_dimname_values);
    }
  }
  else {
    if ($r->is_data_frame) {
      my $r_length = $r->length_value;
      my $v1_length = $v1->length_value;
      if ($r_length != $v1_length) {
        croak "Error in data_frame set: replacement has $v1_length rows, data has $r_length";
      }
    }
    
    $r->list->[$index - 1] = $v1;
  }
  
  return $r;
}

sub to_string {
  my $r = shift;
  
  my $poses = [];
  my $str = '';
  _to_string($r, $r, $poses, \$str);
  
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
      $$str_ref .= $element->to_string . "\n";
    }
    pop @$poses;
  }
}

1;

=head1 NAME

Rstats::Func::List

