package Rstats::Container::DataFrame;
use Rstats::Container::List -base;

use Rstats::ArrayAPI;

sub is_data_frame { Rstats::ArrayAPI::TRUE }

1;
