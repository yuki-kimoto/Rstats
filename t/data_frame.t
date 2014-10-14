use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# transform
{
  # transform - less elements
  {
    my $sex = c('F', 'M', 'F', 'M');
    my $height = c(172, 163, 155, 222);
    my $weight = c(5, 6, 7, 8);
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
    my $x2 = r->transform($x1, sex => c("P"));
    is_deeply($x2->names->values, [qw/sex height weight/]);
    is_deeply($x2->getin(1)->values, ["P", "P", "P", "P"]);
  }
  
  # transform - basic
  {
    my $sex = c('F', 'M', 'F', 'M');
    my $height = c(172, 163, 155, 222);
    my $weight = c(5, 6, 7, 8);
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
    my $x2 = r->transform($x1, sex => c("P", "Q", "P", "Q"), new1 => c(1, 2, 3, 4));
    is_deeply($x2->names->values, [qw/sex height weight new1/]);
    is_deeply($x2->getin(1)->values, ["P", "Q", "P", "Q"]);
    is_deeply($x2->getin(4)->values, [1, 2, 3, 4]);
  }
}

# subset
{
  # subset - row condition
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
    my $x2 = r->subset($x1, $x1->getin('height') > 160);
    ok($x2->is_data_frame);
    is_deeply($x2->names->values, ['sex', 'height', 'weight']);
    is_deeply($x2->getin(1)->as_character->values, [qw/F M/]);
    is_deeply($x2->getin(2)->values, [qw/172 168/]);
    is_deeply($x2->getin(3)->values, [qw/5 6/]);
  }
  
  # subset - row condition and column names
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
    my $x2 = r->subset($x1, $x1->getin('height') > 160, c('sex', 'weight'));
    ok($x2->is_data_frame);
    is_deeply($x2->names->values, ['sex', 'weight']);
    is_deeply($x2->getin(1)->as_character->values, [qw/F M/]);
    is_deeply($x2->getin(2)->values, [qw/5 6/]);
  }
}

# data_frame
{
  # data_frame - with I
  {
    my $sex = r->I(c('F', 'M', 'F'));
    my $height = c(172, 168, 155);
    
    my $x1 = data_frame(sex => $sex, height => $height);
    ok($x1->getin(1)->is_character);
    is_deeply($x1->getin(1)->values, ["F", "M", "F"]);
    is_deeply($x1->getin(2)->values, [172, 168, 155]);
  }
  
  # data_frame - basic
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    
    my $x1 = data_frame(sex => $sex, height => $height);
    ok($x1->getin(1)->is_factor);
    is_deeply($x1->getin(1)->values, [1, 2, 1]);
    is_deeply($x1->getin('sex')->values, [1, 2, 1]);
    is_deeply($x1->getin(2)->values, [172, 168, 155]);
    is_deeply($x1->getin('height')->values, [172, 168, 155]);
  }
  
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
    
    my $x1 = data_frame(sex => $sex, height => $height);
    ok($x1->getin(1)->is_factor);
    is_deeply($x1->getin(1)->values, [1, 2, 1]);
    is_deeply($x1->getin('sex')->values, [1, 2, 1]);
    is_deeply($x1->getin(2)->values, [172, 168, 155]);
    is_deeply($x1->getin('height')->values, [172, 168, 155]);
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

# na_omit
{
  # na_omit - minus row index
  {
    my $sex = c(NA, 'M', 'F');
    my $height = c(172, NA, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
    my $x2 = r->na_omit($x1);
    ok($x2->is_data_frame);
    is_deeply($x2->getin(1)->values, [qw/1/]);
    is_deeply($x2->getin(2)->values, [qw/155/]);
    is_deeply($x2->getin(3)->values, [qw/7/]);
  }
}

# head
{
  # head - default
  {
    my $v1 = c(1, 2, 3, 4, 5, 6, 7);
    my $v2 = c(1, 2, 3, 4, 5, 10, 11);
    
    my $x1 = data_frame(v1 => $v1, v2 => $v2);
    my $x2 = r->head($x1);
    ok($x2->is_data_frame);
    is_deeply($x2->getin(1)->values, [1, 2, 3, 4, 5, 6]);
    is_deeply($x2->getin(2)->values, [1, 2, 3, 4, 5, 10]);
  }
  
  # head - n
  {
    my $v1 = c(1, 2, 3, 4);
    my $v2 = c(1, 2, 5, 6);
    
    my $x1 = data_frame(v1 => $v1, v2 => $v2);
    my $x2 = r->head($x1, {n => 3});
    ok($x2->is_data_frame);
    is_deeply($x2->getin(1)->values, [1, 2, 3]);
    is_deeply($x2->getin(2)->values, [1, 2, 5]);
  }
}

# get
{
  # get - minus row index
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
    my $x2 = $x1->get(c(-1, -3), NULL);
    ok($x2->is_data_frame);
    is_deeply($x2->getin(1)->values, [qw/2/]);
    is_deeply($x2->getin(2)->values, [qw/168/]);
    is_deeply($x2->getin(3)->values, [qw/6/]);
  }
  
  # get - minus collum index
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
    my $x2 = $x1->get(NULL, c(-1, -3));
    ok($x2->is_data_frame);
    is_deeply($x2->names->values, ['height']);
    is_deeply($x2->getin(1)->values, [qw/172 168 155/]);
  }
  
  # get - row index and column index is null
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
    my $x2 = $x1->get(c(3, 2), NULL);
    ok($x2->is_data_frame);
    is_deeply($x2->class->values, ['data.frame']);
    is_deeply($x2->names->values, ['sex', 'height', 'weight']);
    is_deeply($x2->rownames->values, [qw/1 2/]);
    is_deeply($x2->getin(1)->as_character->values, [qw/F M/]);
    is_deeply($x2->getin(2)->values, [qw/155 168/]);
    is_deeply($x2->getin(3)->values, [qw/7 6/]);
  }
  
  # get - row index and column index is null
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
    my $x2 = $x1->get(c(3, 2), NULL);
    ok($x2->is_data_frame);
    is_deeply($x2->class->values, ['data.frame']);
    is_deeply($x2->names->values, ['sex', 'height', 'weight']);
    is_deeply($x2->rownames->values, [qw/1 2/]);
    is_deeply($x2->getin(1)->as_character->values, [qw/F M/]);
    is_deeply($x2->getin(2)->values, [qw/155 168/]);
    is_deeply($x2->getin(3)->values, [qw/7 6/]);
  }
  
  # get - row index and column index
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
    my $x2 = $x1->get(c(3, 2), c(1, 3));
    ok($x2->is_data_frame);
    is_deeply($x2->class->values, ['data.frame']);
    is_deeply($x2->names->values, ['sex', 'weight']);
    is_deeply($x2->rownames->values, [qw/1 2/]);
    is_deeply($x2->colnames->values, ['sex', 'weight']);
    is_deeply($x2->getin(1)->as_character->values, [qw/F M/]);
    is_deeply($x2->getin(2)->values, [qw/7 6/]);
  }
  
  # get - logical, logical
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
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
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
    my $x2 = $x1->get(c(T, F, T));
    ok($x2->is_data_frame);
    is_deeply($x2->class->values, ['data.frame']);
    is_deeply($x2->names->values, ['sex', 'weight']);
    is_deeply($x2->rownames->values, [qw/1 2 3/]);
    is_deeply($x2->colnames->values, ['sex', 'weight']);
    is_deeply($x2->getin(1)->as_character->values, [qw/F M F/]);
    is_deeply($x2->getin(2)->values, [qw/5 6 7/]);
  }
  
  # get - row index and name
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    my $weight = c(5, 6, 7);
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
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
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
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
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
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
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
    my $x2 = $x1->get(c(1,3));
    ok($x2->is_data_frame);
    is_deeply($x2->class->values, ['data.frame']);
    is_deeply($x2->names->values, ['sex', 'weight']);
    is_deeply($x2->dimnames->getin(2)->values, ['sex', 'weight']);
  }
}

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
  my $x1 = data_frame(sex => $sex1, height => $height1);

  my $sex2 = c('M', 'F');
  my $height2 = c(5, 6);
  my $x2 = data_frame(sex => $sex2, height => $height2);
 
  my $x3 = r->rbind($x1, $x2);
  ok($x3->getin(1)->is_factor);
  is_deeply($x3->names->values, [qw/sex height/]);
  is_deeply($x3->getin(1)->as_character->values, [qw/F M M F/]);
  is_deeply($x3->getin(2)->values, [172, 168, 5, 6]);
}

# ncol
{
  my $sex = c('F', 'M');
  my $height = c(172, 168);
  my $weight = c(5, 6);
  my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
  my $x2 = r->ncol($x1);
  ok($x2->values, [3]);
}

# nrow
{
  my $sex = c('F', 'M');
  my $height = c(172, 168);
  my $weight = c(5, 6);
  my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
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
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
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
    
    my $x1 = data_frame(sex => $sex, height => $height, weight => $weight);
    $x1->at(2)->set(c(1, 2, 3));
    is_deeply($x1->getin('height')->values, [1, 2, 3]);
  }
}

# data_frame - to_string
{
  # data_frame - to_string
  {
    my $sex = c('F', 'M', 'F');
    my $height = c(172, 168, 155);
    
    my $x1 = data_frame(sex => $sex, height => $height);
    my $got = "$x1";
    $got =~ s/\s+/ /g;
my $expected = <<"EOS";
    sex  height
 1    F     172
 2    M     168
 3    F     155
EOS
    $expected =~ s/\s+/ /g;
    is($got, $expected);
  }
}

