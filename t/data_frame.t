use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# data_frame
{
  # data_frame - basic
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    
    my $d1 = data_frame(sex => $sex, heigth => $height);
    
    1;
  }
}
