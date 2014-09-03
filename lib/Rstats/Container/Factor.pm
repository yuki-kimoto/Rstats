package Rstats::Container::Factor;
use Rstats::Container -base;

use overload '""' => \&to_string,
  fallback => 1;

use Rstats::Func;

sub get {
  my $self = shift;
  
  my $opt = ref $_[-1] eq 'HASH' ? pop : {};
  my ($a_drop) = args(['drop'], $opt);
  $a_drop = Rstats::Func::FALSE() unless defined $a_drop;
  
  my $_index = shift;
  
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

sub levels {
  my $self = shift;
  
  if (@_) {
    my $a1_levels = Rstats::Func::to_c(shift);
    $a1_levels = $a1_levels->as_character unless $a1_levels->is_character;
    
    $self->{levels} = $a1_levels;
    $self->{labels} = $a1_levels;
    
    return $self;
  }
  else {
    return $self->{levels};
  }
}

sub to_string {
  my $self = shift;
  
  my $a_levels = $self->{levels};
  
  my $a_levels_elements = $a_levels->elements;
  my $levels_length = $a_levels->length->value;
  my $levels = {};
  for (my $i = 1; $i <= $levels_length; $i++) {
    my $a_levels_element = $a_levels_elements->[$i - 1];
    $levels->{$i} = $a_levels_element->value;
  }
  
  my @str;
  push @str, '[1]';
  my $elements = $self->elements;
  for my $element (@$elements) {
    if ($element->is_na) {
      push @str, '<NA>';
    }
    else {
      my $value = $element->value;
      my $character = $levels->{$value};
      push @str, $character;
    }
  }
  
  my $str = join(' ', @str) . "\n";
  
  if ($self->is_ordered) {
    $str .= 'Levels: ' . join(' < ', @{$a_levels->values}) . "\n";
  }
  else {
    $str .= 'Levels: ' . join(' ', , @{$a_levels->values}) . "\n";
  }
  
  return $str;
}

1;
