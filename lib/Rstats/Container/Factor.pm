package Rstats::Container::Factor;
use Rstats::Container -base;

use overload '""' => \&to_string,
  fallback => 1;

use Rstats::Func;

sub levels {
  my $self = shift;
  
  if (@_) {
    my $a1_levels = Rstats::Func::to_array(shift);
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
  my $a_labels = $self->{labels};
  
  my $a_levels_elements = $a_levels->elements;
  my $a_labels_elements = $a_labels->elements;
  my $levels_length = $a_levels->length->value;
  my $labels = {};
  for (my $i = 0; $i < $levels_length; $i++) {
    my $a_levels_element = $a_levels->elements->[$i];
    my $a_labels_element = $a_labels->elements->[$i];
    $labels->{$i} = $a_labels_element->value;
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
      my $character = $labels->{$value};
      push @str, $character;
    }
  }
  
  my $str = join(' ', @str) . "\n";
  
  $str .= join(' ', 'Levels:', @{$a_labels->values}) . "\n";
  
  return $str;
}

1;
