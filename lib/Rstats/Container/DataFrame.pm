package Rstats::Container::DataFrame;
use Rstats::Container::List -base;

use Rstats::ArrayAPI;

sub is_array { Rstats::ArrayAPI::FALSE }
sub is_list { Rstats::ArrayAPI::TRUE }
sub is_data_frame { Rstats::ArrayAPI::TRUE }

1;
