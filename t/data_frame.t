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

# data_frame,get
{
  # data_frame,get - name
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $d1 = data_frame(sex => $sex, heigth => $height, weight => $weight);
    my $d2 = $d1->get("weight");
    ok($d2->is_data_frame);
    is_deeply($d2->class->values, ['data.frame']);
    is_deeply($d2->names->values, ['weight']);
  }
  
  # data_frame,get - multiple elements
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $d1 = data_frame(sex => $sex, heigth => $height, weight => $weight);
    my $d2 = $d1->get(c(1,3));
    ok($d2->is_data_frame);
    is_deeply($d2->class->values, ['data.frame']);
    is_deeply($d2->names->values, ['sex', 'weight']);
    is_deeply($d2->dimnames->getin(2)->values, ['sex', 'weight']);
  }
}

# data_frame
{
  # data_frame - basic
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    
    my $d1 = data_frame(sex => $sex, heigth => $height);
    ok($d1->getin(1)->is_factor);
    is_deeply($d1->getin(1)->values, [1, 2, 1]);
    is_deeply($d1->getin('sex')->values, [1, 2, 1]);
    is_deeply($d1->getin(2)->values, [172, 168, 155]);
    is_deeply($d1->getin('heigth')->values, [172, 168, 155]);
  }

  # data_frame - name duplicate
  {
    my $sex = c('a', 'b', 'c');
    my $sex1 = c('a1', 'b1', 'c1');
    my $sex2 = c('a2', 'b2', 'c2');
    
    my $d1 = data_frame(sex => $sex, sex => $sex1, sex => $sex2);
    is_deeply($d1->getin('sex')->values, [1, 2, 3]);
    is_deeply($d1->getin('sex')->levels->values, ['a', 'b', 'c']);
    is_deeply($d1->getin('sex.1')->values, [1, 2, 3]);
    is_deeply($d1->getin('sex.1')->levels->values, ['a1', 'b1', 'c1']);
    is_deeply($d1->getin('sex.2')->values, [1, 2, 3]);
    is_deeply($d1->getin('sex.2')->levels->values, ['a2', 'b2', 'c2']);
  }
}
