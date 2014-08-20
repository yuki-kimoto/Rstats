package Rstats::Container::DataFrame;
use Rstats::Container::List -base;

use Rstats::Function;

sub is_array { Rstats::Function::FALSE }
sub is_list { Rstats::Function::TRUE }
sub is_data_frame { Rstats::Function::TRUE }

1;
