use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# cbind
{
  my $sex = c('F', 'M', 'F');
  my $height = c(172, 168, 155);
  my $weight = c(5, 6, 7);
  
  my $x1 = data_frame(sex => $sex, height => $height);
  my $x2 = data_frame(weight => $weight);
  my $x3 = r->cbind($x1, $x2);
  
  ok($x3->is_data_frame);
  is_deeply($x3->class->values, ['data.frame']);
  is_deeply($x3->names->values, ['sex', 'height', 'weight']);
  ok($x3->getin(1)->is_factor);
  is_deeply($x3->getin(1)->as_character->values, [qw/F M F/]);
  is_deeply($x3->getin(2)->values, [172, 168, 155]);
  is_deeply($x3->getin(3)->values, [5, 6, 7]);
}

# rbind
{
  my $sex1 = c('F', 'M');
  my $height1 = c(172, 168);
  my $x1 = data_frame(sex => $sex1, heigth => $height1);

  my $sex2 = c('M', 'F');
  my $height2 = c(5, 6);
  my $x2 = data_frame(sex => $sex2, heigth => $height2);
 
  my $x3 = r->rbind($x1, $x2);
  ok($x3->getin(1)->is_factor);
  is_deeply($x3->names->values, [qw/sex heigth/]);
  is_deeply($x3->getin(1)->as_character->values, [qw/F M M F/]);
  is_deeply($x3->getin(2)->values, [172, 168, 5, 6]);
}

# ncol
{
  my $sex = c('F', 'M');
  my $height = c(172, 168);
  my $weight = c(5, 6);
  my $x1 = data_frame(sex => $sex, heigth => $height, weight => $weight);
  my $x2 = r->ncol($x1);
  ok($x2->values, [3]);
}

# nrow
{
  my $sex = c('F', 'M');
  my $height = c(172, 168);
  my $weight = c(5, 6);
  my $x1 = data_frame(sex => $sex, heigth => $height, weight => $weight);
  my $x2 = r->nrow($x1);
  ok($x2->values, [2]);
}

# set
{
  # set - NULL
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, heigth => $height, weight => $weight);
    $x1->at(2)->set(NULL);
    is_deeply($x1->getin(1)->as_character->values, ['F', 'M', 'F']);
    is_deeply($x1->getin(2)->values, [5, 6, 7]);
    is_deeply($x1->names->values, ['sex', 'weight']);
    is_deeply($x1->colnames->values, ['sex', 'weight']);
  }
  
  # set - index
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, heigth => $height, weight => $weight);
    $x1->at(2)->set(c(1, 2, 3));
    is_deeply($x1->getin('heigth')->values, [1, 2, 3]);
  }
}

# get
{
  # get - logical, logical
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, heigth => $height, weight => $weight);
    my $x2 = $x1->get(c(T, F, T), c(T, F, T));
    ok($x2->is_data_frame);
    is_deeply($x2->class->values, ['data.frame']);
    is_deeply($x2->names->values, ['sex', 'weight']);
    is_deeply($x2->rownames->values, [qw/1 2/]);
    is_deeply($x2->colnames->values, ['sex', 'weight']);
    is_deeply($x2->getin(1)->as_character->values, [qw/F F/]);
    is_deeply($x2->getin(2)->values, [qw/5 7/]);
  }
  
  # get - logical
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, heigth => $height, weight => $weight);
    my $x2 = $x1->get(c(T, F, T));
    ok($x2->is_data_frame);
    is_deeply($x2->class->values, ['data.frame']);
    is_deeply($x2->names->values, ['sex', 'weight']);
    is_deeply($x2->rownames->values, [qw/1 2 3/]);
    is_deeply($x2->colnames->values, ['sex', 'weight']);
    is_deeply($x2->getin(1)->as_character->values, [qw/F M F/]);
    is_deeply($x2->getin(2)->values, [qw/5 6 7/]);
  }
  
  # get - row index and name, reverse
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, heigth => $height, weight => $weight);
    my $x2 = $x1->get(c(3, 2), c(1, 3));
    ok($x2->is_data_frame);
    is_deeply($x2->class->values, ['data.frame']);
    is_deeply($x2->names->values, ['sex', 'weight']);
    is_deeply($x2->rownames->values, [qw/1 2/]);
    is_deeply($x2->colnames->values, ['sex', 'weight']);
    is_deeply($x2->getin(1)->as_character->values, [qw/F M/]);
    is_deeply($x2->getin(2)->values, [qw/7 6/]);
  }
  
  # get - row index and name
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, heigth => $height, weight => $weight);
    my $x2 = $x1->get(c(2, 3), c(1, 3));
    ok($x2->is_data_frame);
    is_deeply($x2->class->values, ['data.frame']);
    is_deeply($x2->names->values, ['sex', 'weight']);
    is_deeply($x2->rownames->values, [qw/1 2/]);
    is_deeply($x2->colnames->values, ['sex', 'weight']);
    is_deeply($x2->getin(1)->as_character->values, [qw/M F/]);
    is_deeply($x2->getin(2)->values, [qw/6 7/]);
  }
  
  # get - row index
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, heigth => $height, weight => $weight);
    my $x2 = $x1->get(NULL, c(1, 3));
    ok($x2->is_data_frame);
    is_deeply($x2->class->values, ['data.frame']);
    is_deeply($x2->names->values, ['sex', 'weight']);
    is_deeply($x2->rownames->values, [qw/1 2 3/]);
    is_deeply($x2->colnames->values, ['sex', 'weight']);
    is_deeply($x2->getin(1)->as_character->values, [qw/F M F/]);
    is_deeply($x2->getin(2)->values, [qw/5 6 7/]);
  }
  
  # get - name
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, heigth => $height, weight => $weight);
    my $x2 = $x1->get("weight");
    ok($x2->is_data_frame);
    is_deeply($x2->class->values, ['data.frame']);
    is_deeply($x2->names->values, ['weight']);
  }
  
  # get - multiple elements
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, heigth => $height, weight => $weight);
    my $x2 = $x1->get(c(1,3));
    ok($x2->is_data_frame);
    is_deeply($x2->class->values, ['data.frame']);
    is_deeply($x2->names->values, ['sex', 'weight']);
    is_deeply($x2->dimnames->getin(2)->values, ['sex', 'weight']);
  }
}

# data_frame - to_string
{
  # data_frame - to_string
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    
    my $x1 = data_frame(sex => $sex, heigth => $height);
    my $got = "$x1";
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
  # data_frame - alias for cbind
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, height => $height);
    my $x2 = data_frame(weight => $weight);
    my $x3 = data_frame($x1, $x2);
    
    ok($x3->is_data_frame);
    is_deeply($x3->class->values, ['data.frame']);
    is_deeply($x3->names->values, ['sex', 'height', 'weight']);
    ok($x3->getin(1)->is_factor);
    is_deeply($x3->getin(1)->as_character->values, [qw/F M F/]);
    is_deeply($x3->getin(2)->values, [172, 168, 155]);
    is_deeply($x3->getin(3)->values, [5, 6, 7]);
  }
  
  # data_frame - basic
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    
    my $x1 = data_frame(sex => $sex, heigth => $height);
    ok($x1->getin(1)->is_factor);
    is_deeply($x1->getin(1)->values, [1, 2, 1]);
    is_deeply($x1->getin('sex')->values, [1, 2, 1]);
    is_deeply($x1->getin(2)->values, [172, 168, 155]);
    is_deeply($x1->getin('heigth')->values, [172, 168, 155]);
  }

  # data_frame - name duplicate
  {
    my $sex = c('a', 'b', 'c');
    my $sex1 = c('a1', 'b1', 'c1');
    my $sex2 = c('a2', 'b2', 'c2');
    
    my $x1 = data_frame(sex => $sex, sex => $sex1, sex => $sex2);
    is_deeply($x1->getin('sex')->values, [1, 2, 3]);
    is_deeply($x1->getin('sex')->levels->values, ['a', 'b', 'c']);
    is_deeply($x1->getin('sex.1')->values, [1, 2, 3]);
    is_deeply($x1->getin('sex.1')->levels->values, ['a1', 'b1', 'c1']);
    is_deeply($x1->getin('sex.2')->values, [1, 2, 3]);
    is_deeply($x1->getin('sex.2')->levels->values, ['a2', 'b2', 'c2']);
  }
}
