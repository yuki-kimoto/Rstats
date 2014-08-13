package Rstats::List;
use Object::Simple -base;

use overload '""' => \&to_string,
  fallback => 1;

use Rstats::ArrayUtil;

has 'elements' => sub { [] };

sub at {
  my $a1 = shift;
  
  if (@_) {
    $a1->{at} = [@_];
    
    return $a1;
  }
  
  return $a1->{at};
}

sub get {
  my ($self, @indexes) = @_;
  
  unless (@indexes) {
    @indexes = @{$self->at};
  }
  $self->at(\@indexes);
  
  my $index = shift @indexes;
  $index = $index->values->[0] if ref $index;
  my $elements = $self->elements;
  my $current_element = $elements->[$index - 1];

  for my $index (@indexes) {
    $index = $index->values->[0] if ref $index;
    
    $current_element = $current_element->elements->[$index - 1];
  }
  
  return $current_element;
}

sub get_list {
  my $self = shift;
  my $index = Rstats::ArrayUtil::to_array(shift);
  
  my $elements = $self->elements;
  
  my $list = Rstats::List->new;
  my $list_elements = $list->elements;
  for my $i (@{$index->values}) {
    push @$list_elements, $elements->[$i - 1];
  }

  return $list;
}

sub set {
  my ($self, $element) = @_;
  
  $element = Rstats::ArrayUtil::to_array($element);
  
  my @indexes = @{$self->at};
  
  my $index = shift @indexes;
  $index = $index->values->[0] if ref $index;
  my $elements = $self->elements;
  my $current_element;
  if (@indexes) {
    $current_element = $elements->[$index - 1];
  }
  else {
    $elements->[$index - 1] = $element;
    return;
  }

  for (my $k = 0; $k < @indexes; $k++) {
    my $index = $indexes[$k];
    $index = $index->values->[0] if ref $index;
    
    if ($k == @indexes - 1) {
      $current_element->elements->[$index - 1] = $element;
    }
    else {
      $current_element = $current_element->elements->[$index - 1];
    }
  }
}

sub length {
  my $self = shift;
  
  my $length = @{$self->elements};
  
  return Rstats::ArrayUtil::c($length);
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
  
  my $elements = $list->elements;
  for (my $i = 0; $i < @$elements; $i++) {
    push @$poses, $i + 1;
    $$str_ref .= join('', map { "[[$_]]" } @$poses) . "\n";
    
    my $element = $elements->[$i];
    if (ref $element eq 'Rstats::List') {
      $self->_to_string($element, $poses, $str_ref);
    }
    else {
      $$str_ref .= $element->to_string . "\n";
    }
    pop @$poses;
  }
}

1;

