package Rstats::Container::List;
use Rstats::Container -base;

use overload '""' => \&to_string,
  fallback => 1;

use Rstats::Func;
use Carp 'croak';

has 'elements' => sub { [] };
has 'mode' => sub { Rstats::Array::Util::c('list') };

sub is_list { Rstats::Func::TRUE() }
sub is_data_frame { Rstats::Func::FALSE() }

use overload '""' => \&to_string,
  fallback => 1;

use Rstats::Func;

has 'elements' => sub { [] };
has 'names' => sub { [] };

sub at {
  my $a1 = shift;
  
  if (@_) {
    $a1->{at} = [@_];
    
    return $a1;
  }
  
  return $a1->{at};
}

sub _name_to_index {
  my $self = shift;
  my $a1_index = Rstats::Func::to_c(shift);
  
  my $e1_name = $a1_index->element;
  my $found;
  my $names = $self->names->elements;
  my $index;
  for (my $i = 0; $i < @$names; $i++) {
    my $name = $names->[$i];
    if (Rstats::ElementFunc::equal($e1_name, $name)) {
      $index = $i + 1;
      $found = 1;
      last;
    }
  }
  croak "Not found $e1_name" unless $found;
  
  return $index;
}

sub get {
  my ($self, $_index) = @_;
  
  unless (defined $_index) {
    $_index = $self->at;
  }
  $self->at($_index);
  
  my $a1_index = Rstats::Func::to_c($_index);
  my $index;
  if ($a1_index->is_character) {
    $index = $self->_name_to_index($a1_index);
  }
  else {
    $index = $a1_index->values->[0];
  }
  my $elements = $self->elements;
  my $element = $elements->[$index - 1];
  
  return $element;
}

sub get_as_list {
  my $self = shift;
  my $index = Rstats::Func::to_c(shift);
  
  my $elements = $self->elements;
  
  my $list = Rstats::Container::List->new;
  my $list_elements = $list->elements;
  
  my $index_values;
  if ($index->is_character) {
    $index_values = [];
    for my $element (@{$index->elements}) {
      push @$index_values, $self->_name_to_index($element);
    }
  }
  else {
    $index_values = $index->values;
  }
  for my $i (@{$index_values}) {
    push @$list_elements, $elements->[$i - 1];
  }

  return $list;
}

sub set {
  my ($self, $element) = @_;
  
  my $_index = $self->at;
  my $a1_index = Rstats::Func::to_c($_index);
  my $index;
  if ($a1_index->is_character) {
    $index = $self->_name_to_index($a1_index);
  }
  else {
    $index = $a1_index->values->[0];
  }
  $self->elements->[$index - 1] = Rstats::Func::to_c($element);
  
  return $self;
}

sub length { Rstats::Func::c(shift->_length) }

sub _length { scalar @{shift->elements} }

sub to_string {
  my $self = shift;
  
  my $poses = [];
  my $str = '';
  $self->_to_string($self, $poses, \$str);
  
  return $str;
}

sub _to_string {
  my ($self, $list, $poses, $str_ref) = @_;
  
  my $elements = $list->elements;
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

