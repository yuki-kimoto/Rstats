package Rstats::Container::DataFrame;
use Rstats::Container::List -base;

use Rstats::ArrayFunc;

sub is_data_frame { Rstats::ArrayFunc::TRUE }

sub to_string {
  my $self = shift;
  
  my $names = $self->names->elements;
  my $names1 = $names->[0];
  my $a1 = $self->get(1);
  my $a1_length = $a1->_length;
  
  my $index_header_width = length $a1_length + 1;
  my $column_header_widths = [];
  
  for my $name (@{$names->elements}) {
    
  }
}

1;
