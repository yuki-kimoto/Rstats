package Rstats::Container::Factor;
use Rstats::Container -base;

use Rstats::Func;

sub levels {
  my $self = shift;
  
  if (@_) {
    my $a1_levels = Rstats::Func::to_array(shift);
    $a1_levels = $a1_levels->as_character unless $a1_levels->is_character;
    
    my $levels = {};
    my $level_count;
    my $a1_elements = $a1_levels->elements;
    for my $a1_element (@$a1_elements) {
      my $value = $a1_element->value;
      unless ($levels->{$value}) {
        $levels->{$value} = $level_count;
        $level_count++;
      }
      $self->{levels} = $levels;
    }
    
    return $self;
  }
  else {
    my $levels = $self->{levels};
    
    my $a1_levels = Rstats::Func::c(sort keys $levels);
    
    return $a1_levels;
  }
}

1;
