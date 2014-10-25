package Rstats::Container::List;
use Rstats::Container -base;

use Rstats::Func;
use Carp 'croak';

use overload '""' => \&to_string,
  fallback => 1;

has list => sub { [] };
has mode => sub { Rstats::Func::c('list') };

sub getin {
  my ($self, $_index) = @_;
  
  unless (defined $_index) {
    $_index = $self->at;
  }
  $self->at($_index);
  
  my $x1_index = Rstats::Func::to_c($_index);
  my $index;
  if ($x1_index->is_character) {
    $index = $self->_name_to_index($x1_index);
  }
  else {
    $index = $x1_index->values->[0];
  }
  my $elements = $self->list;
  my $element = $elements->[$index - 1];
  
  return $element;
}

sub get {
  my $self = shift;
  my $index = Rstats::Func::to_c(shift);
  
  my $elements = $self->list;
  
  my $class = ref $self;
  my $list = $class->new;
  my $list_elements = $list->list;
  
  my $index_values;
  if ($index->is_character) {
    $index_values = [];
    for my $element (@{$index->decompose_elements}) {
      push @$index_values, $self->_name_to_index($element);
    }
  }
  else {
    $index_values = $index->values;
  }
  for my $i (@{$index_values}) {
    push @$list_elements, $elements->[$i - 1];
  }

  $self->_copy_attrs_to($list, {new_indexes => [Rstats::Func::to_c($index_values)]});

  return $list;
}

sub set {
  my ($self, $v1) = @_;
  
  my $_index = $self->at;
  my $x1_index = Rstats::Func::to_c($_index);
  my $index;
  if ($x1_index->is_character) {
    $index = $self->_name_to_index($x1_index);
  }
  else {
    $index = $x1_index->values->[0];
  }
  $v1 = Rstats::Func::to_c($v1);
  
  if ($v1->is_null) {
    splice @{$self->list}, $index - 1, 1;
    if (exists $self->{names}) {
      splice @{$self->{names}}, $index - 1, 1;
    }
    
    if (exists $self->{dimnames}) {
      splice @{$self->{dimnames}[1]}, $index - 1, 1;
    }
  }
  else {
    if ($self->is_data_frame) {
      my $self_length = $self->length_value;
      my $v1_length = $v1->length_value;
      if ($self_length != $v1_length) {
        croak "Error in data_frame set: replacement has $v1_length rows, data has $self_length";
      }
    }
    
    $self->list->[$index - 1] = $v1;
  }
  
  return $self;
}

sub to_string {
  my $self = shift;
  
  my $poses = [];
  my $str = '';
  $self->_to_string($self, $poses, \$str);
  
  return $str;
}

sub _to_string {
  my ($self, $list, $poses, $str_ref) = @_;
  
  my $elements = $list->list;
  for (my $i = 0; $i < @$elements; $i++) {
    push @$poses, $i + 1;
    $$str_ref .= join('', map { "[[$_]]" } @$poses) . "\n";
    
    my $element = $elements->[$i];
    if (ref $element eq 'Rstats::Container::List') {
      $self->_to_string($element, $poses, $str_ref);
    }
    else {
      $$str_ref .= $element->to_string . "\n";
    }
    pop @$poses;
  }
}

1;

=head1 NAME

Rstats::Container::List - List
