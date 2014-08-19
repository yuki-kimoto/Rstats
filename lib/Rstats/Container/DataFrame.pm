package Rstats::Container::DataFrame;
use Rstats::Container::List -base;

use Rstats::ArrayUtil;

sub is_array { Rstats::ArrayUtil::FALSE }
sub is_list { Rstats::ArrayUtil::TRUE }
sub is_data_frame { Rstats::ArrayUtil::TRUE }

1;
