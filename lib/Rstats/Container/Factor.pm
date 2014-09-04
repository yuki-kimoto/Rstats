package Rstats::Container::Factor;
use Rstats::Container::Array -base;

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

1;
