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
    is_deeply($d1->get(1)->values, ['F', 'M', 'F']);
    is_deeply($d1->get('sex')->values, ['F', 'M', 'F']);
    is_deeply($d1->get(2)->values, [172, 168, 155]);
    is_deeply($d1->get('heigth')->values, [172, 168, 155]);
  }

  # data_frame - name duplicate
  {
    my $sex = c('a', 'b', 'c');
    my $sex1 = c('a1', 'b1', 'c1');
    my $sex2 = c('a2', 'b2', 'c2');
    
    my $d1 = data_frame(sex => $sex, sex => $sex1, sex => $sex2);
    is_deeply($d1->get('sex')->values, ['a', 'b', 'c']);
    is_deeply($d1->get('sex.1')->values, ['a1', 'b1', 'c1']);
    is_deeply($d1->get('sex.2')->values, ['a2', 'b2', 'c2']);
  }
}
