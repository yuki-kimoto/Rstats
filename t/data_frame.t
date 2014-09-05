use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# data_frame - to_string
{
  # data_frame - to_string
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    
    my $d1 = data_frame(sex => $sex, heigth => $height);
    my $got = "$d1";
    $got =~ s/\s+/ /g;
my $expected = <<"EOS";
    sex  heigth
 1    F     172
 2    M     168
 3    F     155
EOS
    $expected =~ s/\s+/ /g;
    is($got, $expected);
  }
}

# data_frame
{
  # data_frame - basic
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    
    my $d1 = data_frame(sex => $sex, heigth => $height);
    ok($d1->get(1)->is_factor);
    is_deeply($d1->get(1)->values, [1, 2, 1]);
    is_deeply($d1->get('sex')->values, [1, 2, 1]);
    is_deeply($d1->get(2)->values, [172, 168, 155]);
    is_deeply($d1->get('heigth')->values, [172, 168, 155]);
  }

  # data_frame - name duplicate
  {
    my $sex = c('a', 'b', 'c');
    my $sex1 = c('a1', 'b1', 'c1');
    my $sex2 = c('a2', 'b2', 'c2');
    
    my $d1 = data_frame(sex => $sex, sex => $sex1, sex => $sex2);
    is_deeply($d1->get('sex')->values, [1, 2, 3]);
    is_deeply($d1->get('sex')->levels->values, ['a', 'b', 'c']);
    is_deeply($d1->get('sex.1')->values, [1, 2, 3]);
    is_deeply($d1->get('sex.1')->levels->values, ['a1', 'b1', 'c1']);
    is_deeply($d1->get('sex.2')->values, [1, 2, 3]);
    is_deeply($d1->get('sex.2')->levels->values, ['a2', 'b2', 'c2']);
  }
}
