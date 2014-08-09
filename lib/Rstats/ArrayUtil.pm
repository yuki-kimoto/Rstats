package Rstats::ArrayUtil;

use strict;
use warnings;
use Carp qw/croak carp/;
use Rstats::Array;
use Rstats::Util;
use List::Util;
use Math::Trig ();
use POSIX ();;
use Math::Round ();

sub Inf () { c(Rstats::Util::Inf) }

sub negativeInf () { c(Rstats::Util::negativeInf) }

sub FALSE () { c(Rstats::Util::FALSE) }
sub F () { FALSE }

sub TRUE () { c(Rstats::Util::TRUE) }
sub T () { TRUE }

sub pi () { c(Rstats::Util::pi) }

sub kronecker {
  my $a1 = to_array(shift);
  my $a2 = to_array(shift);
  
  ($a1, $a2) = upgrade_type($a1, $a2) if $a1->type ne $a2->type;
  
  my $a1_dim = dim($a1);
  my $a2_dim = dim($a2);
  my $dim_max_length
    = @{$a1_dim->elements} > @{$a2_dim->elements} ? @{$a1_dim->elements} : @{$a2_dim->elements};
  
  my $a3_dim_values = [];
  my $a1_dim_values = $a1_dim->values;
  my $a2_dim_values = $a2_dim->values;
  for (my $i = 0; $i < $dim_max_length; $i++) {
    my $a1_dim_value = $a1_dim_values->[$i] || 1;
    my $a2_dim_value = $a2_dim_values->[$i] || 1;
    my $a3_dim_value = $a1_dim_value * $a2_dim_value;
    push @$a3_dim_values, $a3_dim_value;
  }
  
  my $a3_dim_product = 1;
  $a3_dim_product *= $_ for @{$a3_dim_values};
  
  my $a3_elements = [];
  for (my $i = 0; $i < $a3_dim_product; $i++) {
    my $a3_index = pos_to_index($i, $a3_dim_values);
    my $a1_index = [];
    my $a2_index = [];
    for (my $k = 0; $k < @$a3_index; $k++) {
      my $a3_i = $a3_index->[$k];
      
      my $a1_dim_value = $a1_dim_values->[$k] || 1;
      my $a2_dim_value = $a2_dim_values->[$k] || 1;

      my $a1_ind = int(($a3_i - 1)/$a2_dim_value) + 1;
      push @$a1_index, $a1_ind;
      my $a2_ind = $a3_i - $a2_dim_value * ($a1_ind - 1);
      push @$a2_index, $a2_ind;
    }
    my $a1_element = element($a1, @$a1_index);
    my $a2_element = element($a2, @$a2_index);
    my $a3_element = multiply($a1_element, $a2_element);
    push @$a3_elements, $a3_element;
  }

  my $a3 = array($a3_elements, c($a3_dim_values));
  
  return $a3;
}

sub outer {
  my $a1 = to_array(shift);
  my $a2 = to_array(shift);
  
  ($a1, $a2) = upgrade_type($a1, $a2) if $a1->type ne $a2->type;
  
  my $a1_dim = dim($a1);
  my $a2_dim = dim($a2);
  my $a3_dim = [@{$a1_dim->values}, @{$a2_dim->values}];
  
  my $indexs = [];
  for my $a3_d (@$a3_dim) {
    push @$indexs, [1 .. $a3_d];
  }
  my $poses = cross_product($indexs);
  
  my $a1_dim_length = @{$a1_dim->elements};
  my $a3_elements = [];
  for my $pos (@$poses) {
    my $pos_tmp = [@$pos];
    my $a1_pos = [splice @$pos_tmp, 0, $a1_dim_length];
    my $a2_pos = $pos_tmp;
    my $a1_element = element($a1, @$a1_pos);
    my $a2_element = element($a2, @$a2_pos);
    my $a3_element = Rstats::Util::multiply($a1_element, $a2_element);
    push @$a3_elements, $a3_element;
  }
  
  my $a3 = array($a3_elements, c($a3_dim));
  
  return $a3;
}

sub Arg {
  my $a1 = to_array(shift);
  
  my @a2_elements = map { Rstats::Util::Arg($_) } @{elements($a1)};
  my $a2 = clone_without_elements($a1);
  elements($a2, \@a2_elements);
  
  return $a2;
}

sub sub {
  my ($a1_pattern, $a1_replacement, $a1_x, $a1_ignore_case)
    = args(['pattern', 'replacement', 'x', 'ignore.case'], @_);
  
  my $pattern = value($a1_pattern);
  my $replacement = value($a1_replacement);
  my $ignore_case = value($a1_ignore_case);
  
  my $a2_elements = [];
  for my $x (@{Rstats::ArrayUtil::values($a1_x)}) {
    if (Rstats::Util::is_na($x)) {
      push @$a2_elements, Rstats::Util::character($x);
    }
    else {
      if ($ignore_case) {
        $x =~ s/$pattern/$replacement/i;
      }
      else {
        $x =~ s/$pattern/$replacement/;
      }
      push @$a2_elements, Rstats::Util::character($x);
    }
  }
  
  my $a2 = clone_without_elements($a1_x);
  elements($a2, $a2_elements);
  
  return $a2;
}

sub gsub {
  my ($a1_pattern, $a1_replacement, $a1_x, $a1_ignore_case)
    = args(['pattern', 'replacement', 'x', 'ignore.case'], @_);
  
  my $pattern = value($a1_pattern);
  my $replacement = value($a1_replacement);
  my $ignore_case = value($a1_ignore_case);
  
  my $a2_elements = [];
  for my $x (@{Rstats::ArrayUtil::values($a1_x)}) {
    if (Rstats::Util::is_na($x)) {
      push @$a2_elements, Rstats::Util::character($x);
    }
    else {
      if ($ignore_case) {
        $x =~ s/$pattern/$replacement/gi;
      }
      else {
        $x =~ s/$pattern/$replacement/g;
      }
      push @$a2_elements, Rstats::Util::character($x);
    }
  }
  
  my $a2 = clone_without_elements($a1_x);
  elements($a2, $a2_elements);
  
  return $a2;
}

sub grep {
  my ($a1_pattern, $a1_x, $a1_ignore_case) = args(['pattern', 'x', 'ignore.case'], @_);
  
  my $pattern = value($a1_pattern);
  my $ignore_case = value($a1_ignore_case);
  
  my $a2_elements = [];
  my $a1_x_values = Rstats::ArrayUtil::values($a1_x);
  for (my $i = 0; $i < @$a1_x_values; $i++) {
    my $x = $a1_x_values->[$i];
    
    unless (Rstats::Util::is_na($x)) {
      if ($ignore_case) {
        if ($x =~ /$pattern/i) {
          push $a2_elements, Rstats::Util::double($i + 1);
        }
      }
      else {
        if ($x =~ /$pattern/) {
          push $a2_elements, Rstats::Util::double($i + 1);
        }
      }
    }
  }
  
  return c($a2_elements);
}

sub chartr {
  my ($a1_old, $a1_new, $a1_x) = args(['old', 'new', 'x'], @_);
  
  my $old = value($a1_old);
  my $new = value($a1_new);
  
  my $a2_elements = [];
  for my $x (@{Rstats::ArrayUtil::values($a1_x)}) {
    unless (Rstats::Util::is_na($x)) {
      $old =~ s#/#\/#;
      $new =~ s#/#\/#;
      eval "\$x =~ tr/$old/$new/";
      croak $@ if $@;
    }
    push @$a2_elements, Rstats::Util::character($x);
  }
  
  my $a2 = clone_without_elements($a1_x);
  elements($a2, $a2_elements);
  
  return $a2;
}

sub charmatch {
  my ($a1_x, $a1_table) = args(['x', 'table'], @_);
  
  die "Not implemented"
    unless $a1_x->{type} eq 'character' && $a1_table->{type} eq 'character';
  
  my $a2_elements = [];
  for my $a1_x_element (@{$a1_x->elements}) {
    my $a1_x_char = Rstats::Util::value($a1_x_element);
    my $a1_x_char_q = quotemeta($a1_x_char);
    my $match_count;
    my $match_pos;
    for (my $k = 0; $k < @{$a1_table->elements}; $k++) {
      my $a1_table = $a1_table->elements->[$k];
      my $a1_table_char = Rstats::Util::value($a1_table);
      if ($a1_table_char =~ /$a1_x_char_q/) {
        $match_count++;
        $match_pos = $k;
      }
    }
    if ($match_count == 0) {
      push $a2_elements, Rstats::Util::NA;
    }
    elsif ($match_count == 1) {
      push $a2_elements, Rstats::Util::double($match_pos + 1);
    }
    elsif ($match_count > 1) {
      push $a2_elements, Rstats::Util::double(0);
    }
  }
  
  return c($a2_elements);
}

sub Re {
  my $a1 = to_array(shift);
  
  my @a2_elements = map { Rstats::Util::Re($_) } @{$a1->elements};
  my $a2 = clone_without_elements($a1);
  $a2->{type} = 'double';
  elements($a2, \@a2_elements);
  
  return $a2;
}

sub Im {
  my $a1 = to_array(shift);
  
  my @a2_elements = map { Rstats::Util::Im($_) } @{$a1->elements};
  my $a2 = clone_without_elements($a1);
  $a2->{type} = 'double';
  elements($a2, \@a2_elements);
  
  return $a2;
}

sub elements {
  my $a1 = shift;
  
  if (@_) {
    $a1->{elements} = $_[0];
    
    return $a1;
  }
  else {
    return $a1->{elements};
  }
}

sub type {
  my $a1 = shift;
  
  if (@_) {
    $a1->{type} = $_[0];
    
    return $a1;
  }
  else {
    return $a1->{type};
  }
}

sub bool {
  my $a1 = shift;
  
  my $length = @{elements($a1)};
  if ($length == 0) {
    croak 'Error in if (a) { : argument is of length zero';
  }
  elsif ($length > 1) {
    carp 'In if (a) { : the condition has length > 1 and only the first element will be used';
  }
  
  my $element = element($a1);
  
  return Rstats::Util::bool($element);
}

sub element {
  my $a1 = shift;
  
  my $dim_values = Rstats::ArrayUtil::values(dim_as_array($a1));
  
  if (@_) {
    if (@$dim_values == 1) {
      return elements($a1)->[$_[0] - 1];
    }
    elsif (@$dim_values == 2) {
      return elements($a1)->[($_[0] + $dim_values->[0] * ($_[1] - 1)) - 1];
    }
    else {
      return elements(get($a1, @_))->[0];
    }
  }
  else {
    return elements($a1)->[0];
  }
}

sub Conj {
  my $a1 = to_array(shift);
  
  my @a2_elements = map { Rstats::Util::Conj($_) } @{$a1->elements};
  my $a2 = clone_without_elements($a1);
  $a2->elements(\@a2_elements);
  
  return $a2;
}

sub to_string {
  my $a1 = shift;

  my $elements = elements($a1);
  
  my $dim_values = Rstats::ArrayUtil::values(dim_as_array($a1));
  
  my $dim_length = @$dim_values;
  my $dim_num = $dim_length - 1;
  my $positions = [];
  
  my $str;
  if (@$elements) {
    if ($dim_length == 1) {
      my $names = Rstats::ArrayUtil::values(names($a1));
      if (@$names) {
        $str .= join(' ', @$names) . "\n";
      }
      my @parts = map { Rstats::Util::to_string($_) } @$elements;
      $str .= '[1] ' . join(' ', @parts) . "\n";
    }
    elsif ($dim_length == 2) {
      $str .= '     ';
      
      my $colnames = Rstats::ArrayUtil::values(colnames($a1));
      if (@$colnames) {
        $str .= join(' ', @$colnames) . "\n";
      }
      else {
        for my $d2 (1 .. $dim_values->[1]) {
          $str .= $d2 == $dim_values->[1] ? "[,$d2]\n" : "[,$d2] ";
        }
      }
      
      my $rownames = Rstats::ArrayUtil::values(rownames($a1));
      my $use_rownames = @$rownames ? 1 : 0;
      for my $d1 (1 .. $dim_values->[0]) {
        if ($use_rownames) {
          my $rowname = $rownames->[$d1 - 1];
          $str .= "$rowname ";
        }
        else {
          $str .= "[$d1,] ";
        }
        
        my @parts;
        for my $d2 (1 .. $dim_values->[1]) {
          push @parts, Rstats::Util::to_string(element($a1, $d1, $d2));
        }
        
        $str .= join(' ', @parts) . "\n";
      }
    }
    else {
      my $code;
      $code = sub {
        my (@dim_values) = @_;
        my $dim_value = pop @dim_values;
        
        for (my $i = 1; $i <= $dim_value; $i++) {
          $str .= (',' x $dim_num) . "$i" . "\n";
          unshift @$positions, $i;
          if (@dim_values > 2) {
            $dim_num--;
            $code->(@dim_values);
            $dim_num++;
          }
          else {
            $str .= '     ';
            for my $d2 (1 .. $dim_values[1]) {
              $str .= $d2 == $dim_values[1] ? "[,$d2]\n" : "[,$d2] ";
            }
            for my $d1 (1 .. $dim_values[0]) {
              $str .= "[$d1,] ";
              
              my @parts;
              for my $d2 (1 .. $dim_values[1]) {
                push @parts, Rstats::Util::to_string(element($a1, $d1, $d2, @$positions));
              }
              
              $str .= join(' ', @parts) . "\n";
            }
          }
          shift @$positions;
        }
      };
      $code->(@$dim_values);
    }
  }
  else {
    $str = 'NULL';
  }
  
  return $str;
}

sub negation {
  my $a1 = shift;
  
  my $a2_elements = [map { Rstats::Util::negation($_) } @{elements($a1)}];
  my $a2 = clone_without_elements($a1);
  elements($a2, $a2_elements);
  
  return $a2;
}

sub clone_without_elements {
  my ($a1, %opt) = @_;
  
  my $a2 = Rstats::Array->new;
  $a2->{type} = $a1->{type};
  $a2->{names} = [@{$a1->{names} || []}];
  $a2->{rownames} = [@{$a1->{rownames} || []}];
  $a2->{colnames} = [@{$a1->{colnames} || []}];
  $a2->{dim} = [@{$a1->{dim} || []}];
  $a2->{elements} = $opt{elements} ? $opt{elements} : [];
  
  return $a2;
}

sub values {
  my $a1 = shift;
  
  if (@_) {
    my @elements = map { Rstats::Util::element($_) } @{$_[0]};
    $a1->{elements} = \@elements;
  }
  else {
    my @values = map { Rstats::Util::value($_) } @{elements($a1)};
  
    return \@values;
  }
}

sub value { Rstats::Util::value(element(@_)) }

sub at {
  my $a1 = shift;
  
  if (@_) {
    $a1->{at} = [@_];
    
    return $a1;
  }
  
  return $a1->{at};
}

sub get {
  my $a1 = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $drop = $opt->{drop};
  $drop = 1 unless defined $drop;
  
  my @_indexs = @_;

  my $_indexs;
  if (@_indexs) {
    $_indexs = \@_indexs;
  }
  else {
    my $at = $a1->at;
    $_indexs = ref $at eq 'ARRAY' ? $at : [$at];
  }
  $a1->at($_indexs);
  
  if (ref $_indexs->[0] eq 'CODE') {
    my @elements2 = grep { $_indexs->[0]->() } @{Rstats::ArrayUtil::values($a1)};
    return c(\@elements2);
  }

  my ($positions, $a2_dim) = parse_index($a1, $drop, @$_indexs);
  
  my @a2_elements = map { elements($a1)->[$_ - 1] ? elements($a1)->[$_ - 1] : Rstats::Util::NA } @$positions;
  
  return array(\@a2_elements, $a2_dim);
}

sub set {
  my ($a1, $_a2) = @_;

  my $at = $a1->at;
  my $_indexs = ref $at eq 'ARRAY' ? $at : [$at];

  my $a2 = to_array($_a2);
  
  my ($positions, $a2_dim) = Rstats::ArrayUtil::parse_index($a1, 0, @$_indexs);
  
  my $a1_elements = elements($a1);
  my $a2_elements = elements($a2);
  for (my $i = 0; $i < @$positions; $i++) {
    my $pos = $positions->[$i];
    $a1_elements->[$pos - 1] = $a2_elements->[(($i + 1) % @$positions) - 1];
  }
  
  return $a1;
}

sub is_element {
  my ($a1, $a2) = (to_array(shift), to_array(shift));
  
  croak "mode is diffrence" if $a1->{type} ne $a2->{type};
  
  my $a3_elements = [];
  for my $a1_element (@{elements($a1)}) {
    my $match;
    for my $a2_element (@{elements($a2)}) {
      if (Rstats::Util::equal($a1_element, $a2_element)) {
        $match = 1;
        last;
      }
    }
    push @$a3_elements, $match ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  }
  
  return c($a3_elements);
}

sub setequal {
  my ($a1, $a2) = (to_array(shift), to_array(shift));
  
  croak "mode is diffrence" if $a1->{type} ne $a2->{type};
  
  my $a3 = Rstats::ArrayUtil::sort($a1);
  my $a4 = Rstats::ArrayUtil::sort($a2);
  
  return FALSE if @{elements($a3)} ne @{elements($a4)};
  
  my $not_equal;
  for (my $i = 0; $i < @{elements($a3)}; $i++) {
    unless (Rstats::Util::equal(elements($a3)->[$i], elements($a4)->[$i])) {
      $not_equal = 1;
      last;
    }
  }
  
  return $not_equal ? FALSE : TRUE;
}

sub setdiff {
  my ($a1, $a2) = (to_array(shift), to_array(shift));
  
  croak "mode is diffrence" if $a1->{type} ne $a2->{type};
  
  my $a3_elements = [];
  for my $a1_element (@{elements($a1)}) {
    my $match;
    for my $a2_element (@{elements($a2)}) {
      if (Rstats::Util::equal($a1_element, $a2_element)) {
        $match = 1;
        last;
      }
    }
    push @$a3_elements, $a1_element unless $match;
  }

  return c($a3_elements);
}

sub intersect {
  my ($a1, $a2) = (to_array(shift), to_array(shift));
  
  croak "mode is diffrence" if $a1->{type} ne $a2->{type};
  
  my $a3_elements = [];
  for my $a1_element (@{elements($a1)}) {
    for my $a2_element (@{elements($a2)}) {
      if (Rstats::Util::equal($a1_element, $a2_element)) {
        push @$a3_elements, $a1_element;
      }
    }
  }
  
  return c($a3_elements);
}

sub union {
  my ($a1, $a2) = (to_array(shift), to_array(shift));

  croak "mode is diffrence" if $a1->{type} ne $a2->{type};
  
  my $a3 = c($a1, $a2);
  my $a4 = unique($a3);
  
  return $a4;
}

sub diff {
  my $a1 = to_array(shift);
  
  my $a2_elements = [];
  for (my $i = 0; $i < @{elements($a1)} - 1; $i++) {
    my $a1_element1 = elements($a1)->[$i];
    my $a1_element2 = elements($a1)->[$i + 1];
    my $a2_element = Rstats::Util::subtract($a1_element2, $a1_element1);
    push @$a2_elements, $a2_element;
  }
  my $a2 = clone_without_elements($a1);
  elements($a2, $a2_elements);
  
  return $a2;
}

sub nchar {
  my $a1 = to_array(shift);
  
  if ($a1->{type} eq 'character') {
    my $a2 = clone_without_elements($a1);
    my $a2_elements = [];
    for my $a1_element (@{elements($a1)}) {
      if (Rstats::Util::is_na($a1_element)) {
        push $a2_elements, $a1_element;
      }
      else {
        my $a2_element = Rstats::Util::double(length Rstats::Util::value($a1_element));
        push $a2_elements, $a2_element;
      }
    }
    elements($a2, $a2_elements);
    
    return $a2;
  }
  else {
    croak "Not implemented";
  }
}

sub tolower {
  my $a1 = to_array(shift);
  
  if ($a1->{type} eq 'character') {
    my $a2 = clone_without_elements($a1);
    my $a2_elements = [];
    for my $a1_element (@{elements($a1)}) {
      if (Rstats::Util::is_na($a1_element)) {
        push $a2_elements, $a1_element;
      }
      else {
        my $a2_element = Rstats::Util::character(lc Rstats::Util::value($a1_element));
        push $a2_elements, $a2_element;
      }
    }
    elements($a2, $a2_elements);
      
    return $a2;
  }
  else {
    return $a1;
  }
}

sub toupper {
  my $a1 = to_array(shift);
  
  if ($a1->{type} eq 'character') {
    my $a2 = clone_without_elements($a1);
    my $a2_elements = [];
    for my $a1_element (@{elements($a1)}) {
      if (Rstats::Util::is_na($a1_element)) {
        push $a2_elements, $a1_element;
      }
      else {
        my $a2_element = Rstats::Util::character(uc Rstats::Util::value($a1_element));
        push $a2_elements, $a2_element;
      }
    }
    elements($a2, $a2_elements);
      
    return $a2;
  }
  else {
    return $a1;
  }
}

sub match {
  my ($a1, $a2) = (to_array(shift), to_array(shift));
  
  my @matches;
  for my $a1_element (@{elements($a1)}) {
    my $i = 1;
    my $match;
    for my $a2_element (@{elements($a2)}) {
      if (Rstats::Util::equal($a1_element, $a2_element)) {
        $match = 1;
        last;
      }
      $i++;
    }
    if ($match) {
      push @matches, Rstats::Util::double($i);
    }
    else {
      push @matches, Rstats::Util::NA;
    }
  }
  
  return c(\@matches);
}

sub NULL { Rstats::Array->new(elements => [], dim => [], type => 'logical') }

sub NA { c(Rstats::Util::NA) }

sub NaN { c(Rstats::Util::NaN) }

sub operation {
  my ($op, $a1, $a2) = @_;
  
  $a1 = to_array($a1);
  $a2 = to_array($a2);
  
  # Upgrade mode if type is different
  ($a1, $a2) = upgrade_type($a1, $a2) if $a1->{type} ne $a2->{type};
  
  # Calculate
  my $a1_length = @{elements($a1)};
  my $a2_length = @{elements($a2)};
  my $longer_length = $a1_length > $a2_length ? $a1_length : $a2_length;
  
  no strict 'refs';
  my $operation = "Rstats::Util::$op";
  my @a3_elements = map {
    &$operation(elements($a1)->[$_ % $a1_length], elements($a2)->[$_ % $a2_length])
  } (0 .. $longer_length - 1);
  
  my $a3 = clone_without_elements($a1);
  elements($a3, \@a3_elements);
  if ($op eq '/') {
    $a3->{type} = 'double';
  }
  else {
    $a3->{type} = $a1->{type};
  }
  
  return $a3;
}

sub add { operation('add', @_) }

sub subtract { operation('subtract', @_)}

sub multiply { operation('multiply', @_)}

sub divide { operation('divide', @_)}

sub raise { operation('raise', @_)}

sub remainder { operation('remainder', @_)}

sub more_than { operation('more_than', @_)}

sub more_than_or_equal { operation('more_than_or_equal', @_)}

sub less_than { operation('less_than', @_)}

sub less_than_or_equal { operation('less_than_or_equal', @_)}

sub equal { operation('equal', @_)}

sub not_equal { operation('not_equal', @_)}

sub abs {
  my $a1 = to_array(shift);
  
  my @a2_elements = map { Rstats::Util::abs($_) } @{elements($a1)};
  
  my $a2 = clone_without_elements($a1);
  elements($a2, \@a2_elements);
  mode($a2 => 'double');
  
  return $a2;
}

sub acos { process(\&Rstats::Util::acos, @_) }

sub acosh { process(\&Rstats::Util::acosh, @_) }

sub append {
  my ($a1, $a2, $a_after) = args(['a1', 'a2', 'after'], @_);
  
  my $a1_length = @{elements($a1)};
  $a_after = c($a1_length) if is_null($a_after);
  my $after = value($a_after);
  
  if (ref $a2 eq 'Rstats::Array') {
    splice @{elements($a1)}, $after, 0, @{elements($a2)};
  }
  else {
    splice @{elements($a1)}, $after, 0, $a2;
  }
  
  return $a1
}

sub array {
  
  # Arguments
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my ($a1, $_dim) = @_;
  $_dim = $opt->{dim} unless defined $_dim;
  
  $a1 = c($a1);

  # Dimention
  my $elements = elements($a1);
  my $dim = to_array($_dim);
  my $a1_length = @{$a1->elements};
  unless (@{$dim->elements}) {
    $dim = c($a1_length);
  }
  my $dim_product = 1;
  $dim_product *= $_ for @{$dim->values};
  
  # Fix elements
  if ($a1_length > $dim_product) {
    @$elements = splice @$elements, 0, $dim_product;
  }
  elsif ($a1_length < $dim_product) {
    my $repeat_count = int($dim_product / @$elements) + 1;
    @$elements = (@$elements) x $repeat_count;
    @$elements = splice @$elements, 0, $dim_product;
  }
  elements($a1, $elements);
  dim($a1, $dim);
  
  return $a1;
}

sub asin { process(\&Rstats::Util::asin, @_) }

sub asinh { process(\&Rstats::Util::asinh, @_) }

sub atan { process(\&Rstats::Util::atan, @_) }

sub atanh { process(\&Rstats::Util::atanh, @_) }

sub cbind {
  my @arrays = @_;
  
  my $row_count_needed;
  my $col_count_total;
  my $a2_elements = [];
  for my $_a (@arrays) {
    
    my $a = to_array($_a);
    
    my $row_count;
    if (is_matrix($a)) {
      $row_count = elements(dim($a))->[0];
      $col_count_total += elements(dim($a))->[1];
    }
    elsif (is_vector($a)) {
      $row_count = Rstats::ArrayUtil::values(dim_as_array($a))->[0];
      $col_count_total += 1;
    }
    else {
      croak "cbind or rbind can only receive matrix and vector";
    }
    
    $row_count_needed = $row_count unless defined $row_count_needed;
    croak "Row count is different" if $row_count_needed ne $row_count;
    
    push @$a2_elements, elements($a);
  }
  my $matrix = matrix($a2_elements, $row_count_needed, $col_count_total);
  
  return $matrix;
}

sub ceiling {
  my $_a1 = shift;
  
  my $a1 = to_array($_a1);
  my @a2_elements = map { Rstats::Util::double(POSIX::ceil Rstats::Util::value($_)) } @{elements($a1)};
  
  my $a2 = clone_without_elements($a1);
  elements($a2, \@a2_elements);
  mode($a2 => 'double');
  
  return $a2;
}

sub colMeans {
  my $m1 = shift;
  
  my $dim_values = Rstats::ArrayUtil::values(dim($m1));
  if (@$dim_values == 2) {
    my $v1_values = [];
    for my $row (1 .. $dim_values->[0]) {
      my $v1_value = 0;
      $v1_value += value($m1, $row, $_) for (1 .. $dim_values->[1]);
      push @$v1_values, $v1_value / $dim_values->[1];
    }
    return c($v1_values);
  }
  else {
    croak "Can't culculate colSums";
  }
}

sub colSums {
  my $m1 = shift;
  
  my $dim_values = Rstats::ArrayUtil::values(dim($m1));
  if (@$dim_values == 2) {
    my $v1_values = [];
    for my $row (1 .. $dim_values->[0]) {
      my $v1_value = 0;
      $v1_value += value($m1, $row, $_) for (1 .. $dim_values->[1]);
      push @$v1_values, $v1_value;
    }
    return c($v1_values);
  }
  else {
    croak "Can't culculate colSums";
  }
}

sub cos { process(\&Rstats::Util::cos, @_) }

sub atan2 {
  my ($a1, $a2) = (to_array(shift), to_array(shift));
  
  my @a3_elements;
  for (my $i = 0; $i < @{$a1->elements}; $i++) {
    my $element1 = $a1->elements->[$i];
    my $element2 = $a2->elements->[$i];
    my $element3 = Rstats::Util::atan2($element1, $element2);
    push @a3_elements, $element3;
  }

  my $a3 = clone_without_elements($a1);
  elements($a3, \@a3_elements);

  # mode
  my $a3_mode;
  if (is_complex($a1)) {
    $a3_mode = 'complex';
  }
  else {
    $a3_mode = 'double';
  }
  mode($a3 => $a3_mode);
  
  return $a3;
}

sub cosh { process(\&Rstats::Util::cosh, @_) }

sub cummax {
  my $a1 = to_array(shift);
  
  unless (@{elements($a1)}) {
    carp 'no non-missing arguments to max; returning -Inf';
    return negativeInf;
  }
  
  my @a2_elements;
  my $max = shift @{elements($a1)};
  push @a2_elements, $max;
  for my $element (@{elements($a1)}) {
    
    if (Rstats::Util::is_na($element)) {
      return NA;
    }
    elsif (Rstats::Util::is_nan($element)) {
      $max = $element;
    }
    if (Rstats::Util::more_than($element, $max) && !Rstats::Util::is_nan($max)) {
      $max = $element;
    }
    push @a2_elements, $max;
  }
  
  return c(\@a2_elements);
}

sub cummin {
  my $a1 = to_array(shift);
  
  unless (@{elements($a1)}) {
    carp 'no non-missing arguments to max; returning -Inf';
    return negativeInf;
  }
  
  my @a2_elements;
  my $min = shift @{elements($a1)};
  push @a2_elements, $min;
  for my $element (@{elements($a1)}) {
    if (Rstats::Util::is_na($element)) {
      return NA;
    }
    elsif (Rstats::Util::is_nan($element)) {
      $min = $element;
    }
    if (Rstats::Util::less_than($element, $min) && !Rstats::Util::is_nan($min)) {
      $min = $element;
    }
    push @a2_elements, $min;
  }
  
  return c(\@a2_elements);
}

sub cumsum {
  my $a1 = to_array(shift);
  my $type = $a1->{type};
  my $total = Rstats::Util::create($type);
  my @a2_elements;
  push @a2_elements, $total = Rstats::Util::add($total, $_) for @{elements($a1)};
  
  return c(\@a2_elements);
}

sub cumprod {
  my $a1 = to_array(shift);
  my $type = $a1->{type};
  my $total = Rstats::Util::create($type, 1);
  my @a2_elements;
  push @a2_elements, $total = Rstats::Util::multiply($total, $_) for @{elements($a1)};
  
  return c(\@a2_elements);
}

sub args {
  my $names = shift;
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my @args;
  for (my $i = 0; $i < @$names; $i++) {
    my $name = $names->[$i];
    my $arg = delete $opt->{$name};
    $arg = $_[$i] unless defined $arg;
    $arg = to_array($arg);
    push @args, $arg;
  }
  
  croak "unused argument ($_)" for keys %$opt;
  
  return @args;
}

sub complex {
  my ($a1_re, $a1_im, $a1_mod, $a1_arg) = args(['re', 'im', 'mod', 'arg'], @_);

  my $a2_elements = [];
  # Create complex from mod and arg
  if (@{$a1_mod->elements} || @{$a1_arg->elements}) {
    my $a1_mod_length = @{$a1_mod->elements};
    my $a1_arg_length = @{$a1_arg->elements};
    my $longer_length = $a1_mod_length > $a1_arg_length ? $a1_mod_length : $a1_arg_length;
    
    for (my $i = 0; $i < $longer_length; $i++) {
      my $mod = $a1_mod->elements->[$i];
      $mod = Rstats::Util::double(1) unless $mod;
      my $arg = $a1_arg->elements->[$i];
      $arg = Rstats::Util::double(0) unless $arg;
      
      my $re = Rstats::Util::multiply(
        $mod,
        Rstats::Util::cos($arg)
      );
      my $im = Rstats::Util::multiply(
        $mod,
        Rstats::Util::sin($arg)
      );
      
      my $a2_element = Rstats::Util::complex_double($re, $im);
      push @$a2_elements, $a2_element;
    }
  }
  # Create complex from re and im
  else {
    croak "mode should be numeric" unless is_numeric($a1_re) && is_numeric($a1_im);
    
    for (my $i = 0; $i <  @{elements($a1_im)}; $i++) {
      my $re = elements($a1_re)->[$i] || Rstats::Util::double(0);
      my $im = elements($a1_im)->[$i];
      my $a2_element = Rstats::Util::complex_double($re, $im);
      push @$a2_elements, $a2_element;
    }
  }
  
  return c($a2_elements);
}

sub exp { process(\&Rstats::Util::exp, @_) }

sub expm1 { process(\&Rstats::Util::expm1, @_) }

sub max_type {
  my @arrays = @_;
  
  my $type_h = {};
  
  for my $array (@arrays) {
    my $array_type = value(typeof($array));
    $type_h->{$array_type}++;
    unless (is_null($array)) {
      my $element = element($array);
      my $element_type = Rstats::Util::typeof($element);
      $type_h->{$element_type}++;
    }
  }
  
  if ($type_h->{character}) {
    return 'character';
  }
  elsif ($type_h->{complex}) {
    return 'complex';
  }
  elsif ($type_h->{double}) {
    return 'double';
  }
  elsif ($type_h->{integer}) {
    return 'integer';
  }
  else {
    return 'logical';
  }
}

sub floor {
  my $_a1 = shift;
  
  my $a1 = to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(POSIX::floor Rstats::Util::value($_)) } @{elements($a1)};

  my $a2 = clone_without_elements($a1);
  elements($a2, \@a2_elements);
  mode($a2 => 'double');
  
  return $a2;
}

sub head {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $v1 = shift;
  
  my $n = $opt->{n};
  $n = 6 unless defined $n;
  
  my $elements1 = $v1->{elements};
  my $max = @{elements($v1)} < $n ? @{elements($v1)} : $n;
  my @elements2;
  for (my $i = 0; $i < $max; $i++) {
    push @elements2, $elements1->[$i];
  }
  
  return $v1->new(elements => \@elements2);
}

sub i {
  my $i = Rstats::Util::complex(0, 1);
  
  return c($i);
}

sub ifelse {
  my ($_v1, $value1, $value2) = @_;
  
  my $v1 = to_array($_v1);
  my $v1_values = Rstats::ArrayUtil::values($v1);
  my @v2_values;
  for my $v1_value (@$v1_values) {
    local $_ = $v1_value;
    if ($v1_value) {
      push @v2_values, $value1;
    }
    else {
      push @v2_values, $value2;
    }
  }
  
  return array(\@v2_values);
}

sub is_finite {
  my $_a1 = shift;

  my $a1 = to_array($_a1);
  
  my @a2_elements = map {
    !ref $_ || ref $_ eq 'Rstats::Type::Complex' || ref $_ eq 'Rstats::Logical' 
      ? Rstats::Util::TRUE()
      : Rstats::Util::FALSE()
  } @{elements($a1)};
  my $a2 = array(\@a2_elements);
  mode($a2 => 'logical');
  
  return $a2;
}

sub is_infinite {
  my $_a1 = shift;
  
  my $a1 = to_array($_a1);
  
  my @a2_elements = map {
    ref $_ eq 'Rstats::Inf' ? Rstats::Util::TRUE() : Rstats::Util::FALSE()
  } @{elements($a1)};
  my $a2 = c(\@a2_elements);
  mode($a2 => 'logical');
  
  return $a2;
}

sub is_na {
  my $_a1 = shift;
  
  my $a1 = to_array($_a1);
  
  my @a2_elements = map {
    ref $_ eq  'Rstats::Type::NA' ? Rstats::Util::TRUE() : Rstats::Util::FALSE()
  } @{elements($a1)};
  my $a2 = array(\@a2_elements);
  mode($a2 => 'logical');
  
  return $a2;
}

sub is_nan {
  my $_a1 = shift;
  
  my $a1 = to_array($_a1);
  
  my @a2_elements = map {
    ref $_ eq  'Rstats::NaN' ? Rstats::Util::TRUE() : Rstats::Util::FALSE()
  } @{elements($a1)};
  my $a2 = array(\@a2_elements);
  mode($a2 => 'logical');
  
  return $a2;
}

sub is_null {
  my $_a1 = shift;
  
  my $a1 = to_array($_a1);
  
  my @a2_elements = [!@{elements($a1)} ? Rstats::Util::TRUE() : Rstats::Util::FALSE()];
  my $a2 = array(\@a2_elements);
  mode($a2 => 'logical');
  
  return $a2;
}

sub log { process(\&Rstats::Util::log, @_) }

sub logb { Rstats::ArrayUtil::log(@_) }

sub log2 { process(\&Rstats::Util::log2, @_) }

sub log10 { process(\&Rstats::Util::log10, @_) }

sub max {
  my $a1 = c(@_);
  
  unless (@{elements($a1)}) {
    carp 'no non-missing arguments to max; returning -Inf';
    return negativeInf;
  }
  
  my $max = shift @{elements($a1)};
  for my $element (@{elements($a1)}) {
    
    if (Rstats::Util::is_na($element)) {
      return NA;
    }
    elsif (Rstats::Util::is_nan($element)) {
      $max = $element;
    }
    if (Rstats::Util::more_than($element, $max) && !Rstats::Util::is_nan($max)) {
      $max = $element;
    }
  }
  
  return c($max);
}

sub mean {
  my $a1 = to_array(shift);
  
  my $a2 = divide(sum($a1), scalar @{elements($a1)});
  
  return $a2;
}

sub min {
  my $a1 = c(@_);
  
  unless (@{elements($a1)}) {
    carp 'no non-missing arguments to min; returning -Inf';
    return Inf;
  }
  
  my $min = shift @{elements($a1)};
  for my $element (@{elements($a1)}) {
    
    if (Rstats::Util::is_na($element)) {
      return NA;
    }
    elsif (Rstats::Util::is_nan($element)) {
      $min = $element;
    }
    if (Rstats::Util::less_than($element, $min) && !Rstats::Util::is_nan($min)) {
      $min = $element;
    }
  }
  
  return c($min);
}

sub order {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $v1 = to_array(shift);
  my $decreasing = $opt->{decreasing} || FALSE;
  
  my $v1_values = Rstats::ArrayUtil::values($v1);
  
  my @pos_vals;
  push @pos_vals, {pos => $_ + 1, val => $v1_values->[$_]} for (0 .. @$v1_values - 1);
  my @sorted_pos_values = !$decreasing
    ? sort { $a->{val} <=> $b->{val} } @pos_vals
    : sort { $b->{val} <=> $a->{val} } @pos_vals;
  my @orders = map { $_->{pos} } @sorted_pos_values;
  
  return c(\@orders);
}

# TODO
# na.last
sub rank {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $v1 = to_array(shift);
  my $decreasing = $opt->{decreasing};
  
  my $v1_values = Rstats::ArrayUtil::values($v1);
  
  my @pos_vals;
  push @pos_vals, {pos => $_ + 1, value => $v1_values->[$_]} for (0 .. @$v1_values - 1);
  my @sorted_pos_values = sort { $a->{value} <=> $b->{value} } @pos_vals;
  
  # Rank
  for (my $i = 0; $i < @sorted_pos_values; $i++) {
    $sorted_pos_values[$i]{rank} = $i + 1;
  }
  
  # Average rank
  my $element_info = {};
  for my $sorted_pos_value (@sorted_pos_values) {
    my $value = $sorted_pos_value->{value};
    $element_info->{$value} ||= {};
    $element_info->{$value}{rank_total} += $sorted_pos_value->{rank};
    $element_info->{$value}{rank_count}++;
  }
  
  for my $sorted_pos_value (@sorted_pos_values) {
    my $value = $sorted_pos_value->{value};
    $sorted_pos_value->{rank_average}
      = $element_info->{$value}{rank_total} / $element_info->{$value}{rank_count};
  }
  
  my @sorted_pos_values2 = sort { $a->{pos} <=> $b->{pos} } @sorted_pos_values;
  my @rank = map { $_->{rank_average} } @sorted_pos_values2;
  
  return c(\@rank);
}

sub paste {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $sep = $opt->{sep};
  $sep = ' ' unless defined $sep;
  
  my $str = shift;
  my $v1 = shift;
  
  my $v1_values = Rstats::ArrayUtil::values($v1);
  my $v2_values = [];
  push @$v2_values, "$str$sep$_" for @$v1_values;
  
  return c($v2_values);
}

sub pmax {
  my @vs = @_;
  
  my @maxs;
  for my $v (@vs) {
    my $elements = elements($v);
    for (my $i = 0; $i <@$elements; $i++) {
      $maxs[$i] = $elements->[$i]
        if !defined $maxs[$i] || Rstats::Util::more_than($elements->[$i], $maxs[$i])
    }
  }
  
  return  c(\@maxs);
}

sub pmin {
  my @vs = @_;
  
  my @mins;
  for my $v (@vs) {
    my $elements = elements($v);
    for (my $i = 0; $i <@$elements; $i++) {
      $mins[$i] = $elements->[$i]
        if !defined $mins[$i] || Rstats::Util::less_than($elements->[$i], $mins[$i])
    }
  }
  
  return c(\@mins);
}

sub prod {
  my $a1 = c(@_);
  
  my $type = $a1->{type};
  my $prod = Rstats::Util::create($type, 1);
  for my $element (@{elements($a1)}) {
    $prod = Rstats::Util::multiply($prod, $element);
  }

  return c($prod);
}

sub range {
  my $a1 = shift;
  
  my $min = min($a1);
  my $max = max($a1);
  
  return c($min, $max);
}

sub rbind {
  my (@arrays) = @_;
  
  my $matrix = cbind(@arrays);
  
  return t($matrix);
}

sub rep {

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  my $v1 = shift;
  my $times = $opt->{times} || 1;
  
  my $elements = [];
  push @$elements, @{elements($v1)} for 1 .. $times;
  my $v2 = c($elements);
  
  return $v2;
}

sub replace {
  my $v1 = to_array(shift);
  my $v2 = to_array(shift);
  my $v3 = to_array(shift);
  
  my $v1_elements = elements($v1);
  my $v2_elements = elements($v2);
  my $v2_elements_h = {};
  for my $v2_element (@$v2_elements) {
    my $v2_element_hash = Rstats::Util::hash(Rstats::Util::as_double($v2_element));
    
    $v2_elements_h->{$v2_element_hash}++;
    croak "replace second argument can't have duplicate number"
      if $v2_elements_h->{$v2_element_hash} > 1;
  }
  my $v3_elements = elements($v3);
  my $v3_length = @{$v3_elements};
  
  my $v4_elements = [];
  my $replace_count = 0;
  for (my $i = 0; $i < @$v1_elements; $i++) {
    my $hash = Rstats::Util::hash(Rstats::Util::double($i + 1));
    if ($v2_elements_h->{$hash}) {
      push @$v4_elements, $v3_elements->[$replace_count % $v3_length];
      $replace_count++;
    }
    else {
      push @$v4_elements, $v1_elements->[$i];
    }
  }
  
  return array($v4_elements);
}

sub rev {
  my $a1 = shift;
  
  # Reverse elements
  my $a2 = clone_without_elements($a1);
  my @a2_elements = reverse @{elements($a1)};
  elements($a2, \@a2_elements);
  
  return $a2;
}

sub rnorm {
  
  # Option
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  # Count
  my ($count, $mean, $sd) = @_;
  croak "rnorm count should be bigger than 0"
    if $count < 1;
  
  # Mean
  $mean = 0 unless defined $mean;
  
  # Standard deviation
  $sd = 1 unless defined $sd;
  
  # Random numbers(standard deviation)
  my @v1_elements;
  for (1 .. $count) {
    my ($rand1, $rand2) = (rand, rand);
    while ($rand1 == 0) { $rand1 = rand(); }
    
    my $rnorm = ($sd * sqrt(-2 * CORE::log($rand1))
      * sin(2 * Math::Trig::pi * $rand2))
      + $mean;
    
    push @v1_elements, $rnorm;
  }
  
  return c(\@v1_elements);
}

sub round {

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my ($_a1, $digits) = @_;
  $digits = $opt->{digits} unless defined $digits;
  $digits = 0 unless defined $digits;
  
  my $a1 = to_array($_a1);

  my $r = 10 ** $digits;
  my @a2_elements = map { Rstats::Util::double(Math::Round::round_even(Rstats::Util::value($_) * $r) / $r) } @{elements($a1)};
  my $a2 = clone_without_elements($a1);
  elements($a2, \@a2_elements);
  mode($a2 => 'double');
  
  return $a2;
}

sub rowMeans {
  my $m1 = shift;
  
  my $dim_values = Rstats::ArrayUtil::values(dim($m1));
  if (@$dim_values == 2) {
    my $v1_values = [];
    for my $col (1 .. $dim_values->[1]) {
      my $v1_value = 0;
      $v1_value += value($m1, $_, $col) for (1 .. $dim_values->[0]);
      push @$v1_values, $v1_value / $dim_values->[0];
    }
    return c($v1_values);
  }
  else {
    croak "Can't culculate rowSums";
  }
}

sub rowSums {
  my $m1 = shift;
  
  my $dim_values = Rstats::ArrayUtil::values(dim($m1));
  if (@$dim_values == 2) {
    my $v1_values = [];
    for my $col (1 .. $dim_values->[1]) {
      my $v1_value = 0;
      $v1_value += value($m1, $_, $col) for (1 .. $dim_values->[0]);
      push @$v1_values, $v1_value;
    }
    return c($v1_values);
  }
  else {
    croak "Can't culculate rowSums";
  }
}

sub runif {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};

  my ($count, $min, $max) = @_;
  
  $min = 0 unless defined $min;
  $max = 1 unless defined $max;
  croak "runif third argument must be bigger than second argument"
    if $min > $max;
  
  my $diff = $max - $min;
  my @v1_elements;
  if (defined $opt->{seed}) {
    srand $opt->{seed};
  }
  for (1 .. $count) {
    my $rand = rand($diff) + $min;
    push @v1_elements, $rand;
  }
  
  return c(\@v1_elements);
}

# TODO: prob option
sub sample {
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  my ($_v1, $length) = @_;
  my $v1 = to_array($_v1);
  
  # Replace
  my $replace = $opt->{replace};
  
  my $v1_length = @{elements($v1)};
  $length = $v1_length unless defined $length;
  
  croak "second argument element must be bigger than first argument elements count when you specify 'replace' option"
    if $length > $v1_length && !$replace;
  
  my @v2_elements;
  for my $i (0 .. $length - 1) {
    my $rand_num = int(rand @{elements($v1)});
    my $rand_element = splice @{elements($v1)}, $rand_num, 1;
    push @v2_elements, $rand_element;
    push @{elements($v1)}, $rand_element if $replace;
  }
  
  return c(\@v2_elements);
}

sub sequence {
  my $_v1 = shift;
  
  my $v1 = to_array($_v1);
  my $v1_values = Rstats::ArrayUtil::values($v1);
  
  my @v2_values;
  for my $v1_value (@$v1_values) {
    push @v2_values, Rstats::ArrayUtil::values(seq(1, $v1_value));
  }
  
  return c(\@v2_values);
}

sub sin { process(\&Rstats::Util::sin, @_) }

sub sinh { process(\&Rstats::Util::sinh, @_) }

sub sqrt {
  my $a1 = to_array(shift);
  
  my @a2_elements = map { Rstats::Util::sqrt($_) } @{elements($a1)};
  
  my $a2 = clone_without_elements($a1);
  elements($a2, \@a2_elements);
  mode($a2 => 'double');
  
  return $a2;
}

sub sort {

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $a1 = to_array(shift);
  my $decreasing = $opt->{decreasing};
  
  my @a2_elements = grep { !Rstats::Util::is_na($_) && !Rstats::Util::is_nan($_) } @{elements($a1)};
  
  my $a3_elements = $decreasing
    ? [reverse sort { Rstats::Util::more_than($a, $b) ? 1 : Rstats::Util::equal($a, $b) ? 0 : -1 } @a2_elements]
    : [sort { Rstats::Util::more_than($a, $b) ? 1 : Rstats::Util::equal($a, $b) ? 0 : -1 } @a2_elements];

  return c($a3_elements);
}

sub tail {

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $v1 = shift;
  
  my $n = $opt->{n};
  $n = 6 unless defined $n;
  
  my $elements1 = $v1->{elements};
  my $max = @{elements($v1)} < $n ? @{elements($v1)} : $n;
  my @elements2;
  for (my $i = 0; $i < $max; $i++) {
    unshift @elements2, $elements1->[@{elements($v1)} - ($i  + 1)];
  }
  
  return $v1->new(elements => \@elements2);
}

sub tan { process(\&Rstats::Util::tan, @_) }

sub process {
  my $func = shift;
  my $a1 = to_array(shift);
  
  my @a2_elements = map { $func->($_) } @{elements($a1)};
  my $a2 = clone_without_elements($a1);
  elements($a2, \@a2_elements);
  mode($a2 => max_type($a1, $a2));
  
  return $a2;
}

sub tanh { process(\&Rstats::Util::tanh, @_) }

sub trunc {
  my ($_a1) = @_;
  
  my $a1 = to_array($_a1);
  
  my @a2_elements = map { Rstats::Util::double(int Rstats::Util::value($_)) } @{elements($a1)};

  my $a2 = clone_without_elements($a1);
  elements($a2, \@a2_elements);
  mode($a2 => 'double');
  
  return $a2;
}

sub unique {
  my $a1 = to_array(shift);
  
  if (is_vector($a1)) {
    my $a2_elements = [];
    my $elements_count = {};
    my $na_count;
    for my $a1_element (@{elements($a1)}) {
      if (Rstats::Util::is_na($a1_element)) {
        unless ($na_count) {
          push @$a2_elements, $a1_element;
        }
        $na_count++;
      }
      else {
        my $str = Rstats::Util::to_string($a1_element);
        unless ($elements_count->{$str}) {
          push @$a2_elements, $a1_element;
        }
        $elements_count->{$str}++;
      }
    }

    return c($a2_elements);
  }
  else {
    return $a1;
  }
}

sub median {
  my $a1 = to_array(shift);
  
  my $a2 = unique($a1);
  my $a3 = Rstats::ArrayUtil::sort($a2);
  my $a3_length = @{elements($a3)};
  
  if ($a3_length % 2 == 0) {
    my $middle = $a3_length / 2;
    my $a4 = $a3->get($middle);
    my $a5 = $a3->get($middle + 1);
    
    return ($a4 + $a5) / 2;
  }
  else {
    my $middle = int($a3_length / 2) + 1;
    return $a3->get($middle);
  }
}

sub sd {
  my $a1 = to_array(shift);
  
  my $sd = Rstats::ArrayUtil::sqrt(var($a1));
  
  return $sd;
}

sub var {
  my $a1 = to_array(shift);

  my $var = sum(($a1 - mean($a1)) ** 2) / (@{elements($a1)} - 1);
  
  return $var;
}

sub which {
  my ($_v1, $cond_cb) = @_;
  
  my $v1 = to_array($_v1);
  my $v1_values = Rstats::ArrayUtil::values($v1);
  my @v2_values;
  for (my $i = 0; $i < @$v1_values; $i++) {
    local $_ = $v1_values->[$i];
    if ($cond_cb->($v1_values->[$i])) {
      push @v2_values, $i + 1;
    }
  }
  
  return c(\@v2_values);
}

sub matrix {
  
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};

  my ($_a1, $nrow, $ncol, $byrow, $dirnames) = @_;

  croak "matrix method need data as frist argument"
    unless defined $_a1;
  
  my $a1 = to_array($_a1);
  
  # Row count
  $nrow = $opt->{nrow} unless defined $nrow;
  
  # Column count
  $ncol = $opt->{ncol} unless defined $ncol;
  
  # By row
  $byrow = $opt->{byrow} unless defined $byrow;
  
  my $a1_elements = elements($a1);
  my $a1_length = @$a1_elements;
  if (!defined $nrow && !defined $ncol) {
    $nrow = $a1_length;
    $ncol = 1;
  }
  elsif (!defined $nrow) {
    $nrow = int($a1_length / $ncol);
  }
  elsif (!defined $ncol) {
    $ncol = int($a1_length / $nrow);
  }
  my $length = $nrow * $ncol;
  
  my $dim = [$nrow, $ncol];
  my $matrix;
  if ($byrow) {
    $matrix = array(
      $a1_elements,
      [$dim->[1], $dim->[0]],
    );
    
    $matrix = t($matrix);
  }
  else {
    $matrix = array($a1_elements, $dim);
  }
  
  return $matrix;
}

sub typeof {
  my $a1 = shift;
  
  my $type = $a1->{type};
  my $a2_elements = defined $type ? $type : "NULL";
  my $a2 = c($a2_elements);
  
  return $a2;
}

my %types_h = map { $_ => 1 } qw/character complex numeric double integer logical/;

sub Mod { Rstats::ArrayUtil::abs(@_) }

sub mode {
  my $a1 = shift;
  
  if (@_) {
    my $type = $_[0];
    croak qq/Error in eval(expr, envir, enclos) : could not find function "as_$type"/
      unless $types_h{$type};
    
    if ($type eq 'numeric') {
      $a1->{type} = 'double';
    }
    else {
      $a1->{type} = $type;
    }
    
    return $a1;
  }
  else {
    my $type = $a1->{type};
    my $mode;
    if (defined $type) {
      if ($type eq 'integer' || $type eq 'double') {
        $mode = 'numeric';
      }
      else {
        $mode = $type;
      }
    }
    else {
      croak qq/could not find function "as_$type"/;
    }

    return c($mode);
  }
}

sub inner_product {
  my ($a1, $a2) = @_;
  
  # Convert to matrix
  $a1 = t(as_matrix($a1)) if is_vector($a1);
  $a2 = as_matrix($a2) if is_vector($a2);
  
  # Calculate
  if (is_matrix($a1) && is_matrix($a2)) {
    
    croak "requires numeric/complex matrix/vector arguments"
      if @{elements($a1)} == 0 || @{elements($a2)} == 0;
    croak "Error in a x b : non-conformable arguments"
      unless Rstats::ArrayUtil::values(dim($a1))->[1] == Rstats::ArrayUtil::values(dim($a2))->[0];
    
    my $row_max = Rstats::ArrayUtil::values(dim($a1))->[0];
    my $col_max = Rstats::ArrayUtil::values(dim($a2))->[1];
    
    my $a3_elements = [];
    for (my $col = 1; $col <= $col_max; $col++) {
      for (my $row = 1; $row <= $row_max; $row++) {
        my $v1 = $a1->get($row);
        my $v2 = $a2->get(NULL, $col);
        my $v3 = sum($a1 * $a2);
        push $a3_elements, $v3;
      }
    }
    
    my $a3 = matrix($a3_elements, $row_max, $col_max);
    
    return $a3;
  }
  else {
    croak "inner_product should be dim < 3."
  }
}

sub row {
  my $a1 = shift;
  
  my $nrow = value(nrow($a1));
  my $ncol = value(ncol($a1));
  
  my @values = (1 .. $nrow) x $ncol;
  
  return array(\@values, [$nrow, $ncol]);
}

sub sum {
  my $a1 = to_array(shift);
  
  my $type = $a1->{type};
  my $sum = Rstats::Util::create($type);
  $sum = Rstats::Util::add($sum, $_) for @{elements($a1)};
  
  return c($sum);
}

sub col {
  my $a1 = shift;
  
  my $nrow = value(nrow($a1));
  my $ncol = value(ncol($a1));
  
  my @values;
  for my $col (1 .. $ncol) {
    push @values, ($col) x $nrow;
  }
  
  return array(\@values, [$nrow, $ncol]);
}

sub nrow {
  my $a1 = shift;
  
  return c(Rstats::ArrayUtil::values(dim($a1))->[0]);
}

sub ncol {
  my $a1 = shift;
  
  return c(Rstats::ArrayUtil::values(dim($a1))->[1]);
}

sub names {
  my $a1 = shift;
  
  if (@_) {
    my $_names = shift;
    my $names;
    if (ref $_names eq 'Rstats::Array') {
      $names = elements($_names);
    }
    elsif (!defined $_names) {
      $names = [];
    }
    elsif (ref $_names eq 'ARRAY') {
      $names = $_names;
    }
    else {
      $names = [$_names];
    }
    
    my $duplication = {};
    for my $name (@$names) {
      croak "Don't use same name in names arguments"
        if $duplication->{$name};
      $duplication->{$name}++;
    }
    $a1->{names} = $names;
  }
  else {
    $a1->{names} = [] unless exists $a1->{names};
    return array($a1->{names});
  }
}

sub colnames {
  my $a1 = shift;
  
  if (@_) {
    my $_colnames = shift;
    my $colnames;
    if (ref $_colnames eq 'Rstats::Array') {
      $colnames = elements($_colnames);
    }
    elsif (!defined $_colnames) {
      $colnames = [];
    }
    elsif (ref $_colnames eq 'ARRAY') {
      $colnames = $_colnames;
    }
    else {
      $colnames = [$_colnames];
    }
    
    my $duplication = {};
    for my $name (@$colnames) {
      croak "Don't use same name in colnames arguments"
        if $duplication->{$name};
      $duplication->{$name}++;
    }
    $a1->{colnames} = $colnames;
  }
  else {
    $a1->{colnames} = [] unless exists $a1->{colnames};
    return array($a1->{colnames});
  }
}

sub rownames {
  my $a1 = shift;
  
  if (@_) {
    my $_rownames = shift;
    my $rownames;
    if (ref $_rownames eq 'Rstats::Array') {
      $rownames = elements($_rownames);
    }
    elsif (!defined $_rownames) {
      $rownames = [];
    }
    elsif (ref $_rownames eq 'ARRAY') {
      $rownames = $_rownames;
    }
    else {
      $rownames = [$_rownames];
    }
    
    my $duplication = {};
    for my $name (@$rownames) {
      croak "Don't use same name in rownames arguments"
        if $duplication->{$name};
      $duplication->{$name}++;
    }
    $a1->{rownames} = $rownames;
  }
  else {
    $a1->{rownames} = [] unless exists $a1->{rownames};
    return array($a1->{rownames});
  }
}

sub dim {
  my $a1 = shift;
  
  if (@_) {
    my $a_dim = to_array($_[0]);
    my $a1_length = @{$a1->elements};
    my $a1_lenght_by_dim = 1;
    $a1_lenght_by_dim *= $_ for @{$a_dim->values};
    
    if ($a1_length != $a1_lenght_by_dim) {
      croak "dims [product $a1_lenght_by_dim] do not match the length of object [$a1_length]";
    }
  
    $a1->{dim} = elements($a_dim);
    
    return $a1;
  }
  else {
    return c($a1->{dim});
  }
}

sub length {
  my $a1 = shift;
  
  my $length = @{elements($a1)};
  
  return c($length);
}

sub seq {
  
  # Option
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  # Along
  my $_along = $opt->{along};
  if ($_along) {
    my $along = to_array($_along);
    my $length = @{elements($along)};
    return seq(1,$length);
  }
  else {
    my ($from, $to) = @_;
    
    # From
    $from = $opt->{from} unless defined $from;
    croak "seq function need from option" unless defined $from;
    
    # To
    $to = $opt->{to} unless defined $to;
    croak "seq function need to option" unless defined $to;

    # Length
    my $length = $opt->{length};
    
    # By
    my $by = $opt->{by};
    
    if (defined $length && defined $by) {
      croak "Can't use by option and length option as same time";
    }
    
    unless (defined $by) {
      if ($to >= $from) {
        $by = 1;
      }
      else {
        $by = -1;
      }
    }
    croak "by option should be except for 0" if $by == 0;
    
    $to = $from unless defined $to;
    
    if (defined $length && $from ne $to) {
      $by = ($to - $from) / ($length - 1);
    }
    
    my $elements = [];
    if ($to == $from) {
      $elements->[0] = $to;
    }
    elsif ($to > $from) {
      if ($by < 0) {
        croak "by option is invalid number(seq function)";
      }
      
      my $element = $from;
      while ($element <= $to) {
        push @$elements, $element;
        $element += $by;
      }
    }
    else {
      if ($by > 0) {
        croak "by option is invalid number(seq function)";
      }
      
      my $element = $from;
      while ($element >= $to) {
        push @$elements, $element;
        $element += $by;
      }
    }
    
    return c($elements);
  }
}

sub c {
  my @elements_tmp1 = @_;
  
  # Fix elements
  my $elements_tmp2;
  if (@elements_tmp1 == 0) {
    return NULL();
  }
  elsif (@elements_tmp1 > 1) {
    $elements_tmp2 = \@elements_tmp1;
  }
  else {
    $elements_tmp2 = $elements_tmp1[0];
  }

  my $elements = [];
  if (defined $elements_tmp2) {
    if (ref $elements_tmp2 eq 'ARRAY') {
      for my $element (@$elements_tmp2) {
        if (ref $element eq 'ARRAY') {
          push @$elements, @$element;
        }
        elsif (ref $element eq 'Rstats::Array') {
          push @$elements, @{elements($element)};
        }
        else {
          push @$elements, $element;
        }
      }
    }
    elsif (ref $elements_tmp2 eq 'Rstats::Array') {
      $elements = elements($elements_tmp2);
    }
    else {
      $elements = [$elements_tmp2];
    }
  }
  else {
    croak "Invalid first argument";
  }
  
  # Check elements
  my $mode_h = {};
  for my $element (@$elements) {
    next if Rstats::Util::is_na($element);
    
    if (Rstats::Util::is_character($element)) {
      $mode_h->{character}++;
    }
    elsif (Rstats::Util::is_complex($element)) {
      $mode_h->{complex}++;
    }
    elsif (Rstats::Util::is_double($element)) {
      $mode_h->{double}++;
    }
    elsif (Rstats::Util::is_integer($element)) {
      $element = Rstats::Util::double(value($element));
      $mode_h->{double}++;
    }
    elsif (Rstats::Util::is_logical($element)) {
      $mode_h->{logical}++;
    }
    elsif (Rstats::Util::is_perl_number($element)) {
      $element = Rstats::Util::double($element);
      $mode_h->{double}++;
    }
    else {
      $element = Rstats::Util::character("$element");
      $mode_h->{character}++;
    }
  }

  # Array
  my $a1 = NULL();
  elements($a1, $elements);

  # Upgrade elements and type
  my @modes = keys %$mode_h;
  if (@modes > 1) {
    if ($mode_h->{character}) {
      $a1 = as_character($a1);
    }
    elsif ($mode_h->{complex}) {
      $a1 = as_complex($a1);
    }
    elsif ($mode_h->{double}) {
      $a1 = as_double($a1);
    }
  }
  else {
    mode($a1 => $modes[0] || 'logical');
  }
  
  return $a1;
}

sub C {
  my $seq_str = shift;

  my $by;
  my $mode;
  if ($seq_str =~ s/^(.+)\*//) {
    $by = $1;
  }
  
  my $from;
  my $to;
  if ($seq_str =~ /([^\:]+)(?:\:(.+))?/) {
    $from = $1;
    $to = $2;
    $to = $from unless defined $to;
  }
  
  my $vector = seq({from => $from, to => $to, by => $by});
  
  return $vector;
}

sub dim_as_array {
  my $a1 = shift;
  
  if (@{elements(dim($a1))}) {
    return dim($a1);
  }
  else {
    my $length = @{elements($a1)};
    return c($length);
  }
}

sub is_numeric {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'double' || ($a1->{type} || '') eq 'integer'
    ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return c($is);
}

sub is_double {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'double' ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return c($is);
}

sub is_integer {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'integer' ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return c($is);
}

sub is_complex {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'complex' ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return c($is);
}

sub is_character {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'character' ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return c($is);
}

sub is_logical {
  my $a1 = shift;
  
  my $is = ($a1->{type} || '') eq 'logical' ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return c($is);
}

sub as {
  my ($type, $a1) = @_;
  
  if ($type eq 'character') {
    return as_character($a1);
  }
  elsif ($type eq 'complex') {
    return as_complex($a1);
  }
  elsif ($type eq 'double') {
    return as_double($a1);
  }
  elsif ($type eq 'numeric') {
    return as_numeric($a1);
  }
  elsif ($type eq 'integer') {
    return as_integer($a1);
  }
  elsif ($type eq 'logical') {
    return as_logical($a1);
  }
  else {
    croak "Invalid mode is passed";
  }
}

sub as_complex {
  my $a1 = shift;
  
  my $a1_elements = elements($a1);
  my $a2 = clone_without_elements($a1);
  my @a2_elements = map { Rstats::Util::as('complex', $_) } @$a1_elements;
  elements($a2, \@a2_elements);
  $a2->{type} = 'complex';

  return $a2;
}

sub as_numeric { as_double(@_) }

sub as_double {
  my $a1 = shift;
  
  my $a1_elements = elements($a1);
  my $a2 = clone_without_elements($a1);
  my @a2_elements = map { Rstats::Util::as('double', $_) } @$a1_elements;
  elements($a2, \@a2_elements);
  $a2->{type} = 'double';

  return $a2;
}

sub as_integer {
  my $a1 = shift;
  
  my $a1_elements = elements($a1);
  my $a2 = clone_without_elements($a1);
  my @a2_elements = map { Rstats::Util::as('integer', $_)  } @$a1_elements;
  elements($a2, \@a2_elements);
  $a2->{type} = 'integer';

  return $a2;
}

sub as_logical {
  my $a1 = shift;
  
  my $a1_elements = elements($a1);
  my $a2 = clone_without_elements($a1);
  my @a2_elements = map { Rstats::Util::as('logical', $_) } @$a1_elements;
  elements($a2, \@a2_elements);
  $a2->{type} = 'logical';

  return $a2;
}

sub as_character {
  my $a1 = shift;

  my $a1_elements = elements($a1);
  my @a2_elements = map { Rstats::Util::as('character', $_) } @$a1_elements;
  my $a2 = clone_without_elements($a1);
  elements($a2, \@a2_elements);
  $a2->{type} = 'character';

  return $a2;
}

sub numeric {
  my $num = shift;
  
  return c((0) x $num);
}

sub to_array {
  my $_array = shift;
  
  my $a1
   = !defined $_array ? NULL
   : ref $_array eq 'Rstats::Array' ? $_array
   : c($_array);
  
  return $a1;
}

sub parse_index {
  my ($a1, $drop, @_indexs) = @_;
  
  my $a1_dim = Rstats::ArrayUtil::values(dim_as_array($a1));
  my @indexs;
  my @a2_dim;
  
  for (my $i = 0; $i < @$a1_dim; $i++) {
    my $_index = $_indexs[$i];
    
    my $index = to_array($_index);
    my $index_values = Rstats::ArrayUtil::values($index);
    if (@$index_values && !is_character($index) && !is_logical($index)) {
      my $minus_count = 0;
      for my $index_value (@$index_values) {
        if ($index_value == 0) {
          croak "0 is invalid index";
        }
        else {
          $minus_count++ if $index_value < 0;
        }
      }
      croak "Can't min minus sign and plus sign"
        if $minus_count > 0 && $minus_count != @$index_values;
      $index->{_minus} = 1 if $minus_count > 0;
    }
    
    if (!@{Rstats::ArrayUtil::values($index)}) {
      my $index_values_new = [1 .. $a1_dim->[$i]];
      $index = array($index_values_new);
    }
    elsif (is_character($index)) {
      if (is_vector($a1)) {
        my $index_new_values = [];
        for my $name (@{Rstats::ArrayUtil::values($index)}) {
          my $i = 0;
          my $value;
          for my $a1_name (@{Rstats::ArrayUtil::values(names($a1))}) {
            if ($name eq $a1_name) {
              $value = Rstats::ArrayUtil::values($a1)->[$i];
              last;
            }
            $i++;
          }
          croak "Can't find name" unless defined $value;
          push @$index_new_values, $value;
        }
        $indexs[$i] = array($index_new_values);
      }
      elsif (is_matrix($a1)) {
        
      }
      else {
        croak "Can't support name except vector and matrix";
      }
    }
    elsif (is_logical($index)) {
      my $index_values_new = [];
      for (my $i = 0; $i < @{Rstats::ArrayUtil::values($index)}; $i++) {
        push @$index_values_new, $i + 1 if Rstats::Util::bool(elements($index)->[$i]);
      }
      $index = array($index_values_new);
    }
    elsif ($index->{_minus}) {
      my $index_value_new = [];
      
      for my $k (1 .. $a1_dim->[$i]) {
        push @$index_value_new, $k unless grep { $_ == -$k } @{Rstats::ArrayUtil::values($index)};
      }
      $index = array($index_value_new);
    }

    push @indexs, $index;

    my $count = @{elements($index)};
    push @a2_dim, $count unless $count == 1 && $drop;
  }
  @a2_dim = (1) unless @a2_dim;
  
  my $index_values = [map { Rstats::ArrayUtil::values($_) } @indexs];
  my $ords = cross_product($index_values);
  my @positions = map { Rstats::ArrayUtil::pos($_, $a1_dim) } @$ords;
  
  return (\@positions, \@a2_dim);
}

sub cross_product {
  my $values = shift;

  my @idxs = (0) x @$values;
  my @idx_idx = 0..(@idxs - 1);
  my @a1 = map { $_->[0] } @$values;
  my $result = [];
  
  push @$result, [@a1];
  my $end_loop;
  while (1) {
    foreach my $i (@idx_idx) {
      if( $idxs[$i] < @{$values->[$i]} - 1 ) {
        $a1[$i] = $values->[$i][++$idxs[$i]];
        push @$result, [@a1];
        last;
      }
      
      if ($i == $idx_idx[-1]) {
        $end_loop = 1;
        last;
      }
      
      $idxs[$i] = 0;
      $a1[$i] = $values->[$i][0];
    }
    last if $end_loop;
  }
  
  return $result;
}

sub pos {
  my ($ord, $dim) = @_;
  
  my $pos = 0;
  for (my $d = 0; $d < @$dim; $d++) {
    if ($d > 0) {
      my $tmp = 1;
      $tmp *= $dim->[$_] for (0 .. $d - 1);
      $pos += $tmp * ($ord->[$d] - 1);
    }
    else {
      $pos += $ord->[$d];
    }
  }
  
  return $pos;
}

sub pos_to_index {
  my ($pos, $dim) = @_;
  
  my $index = [];
  my $before_dim_product = 1;
  $before_dim_product *= $dim->[$_] for (0 .. @$dim - 1);
  for (my $i = @{$dim} - 1; $i >= 0; $i--) {
    my $dim_product = 1;
    $dim_product *= $dim->[$_] for (0 .. $i - 1);
    my $reminder = $pos % $before_dim_product;
    my $quotient = int ($reminder / $dim_product);
    unshift @$index, $quotient + 1;
    $before_dim_product = $dim_product;
  }
  
  return $index;
}

sub t {
  my $m1 = shift;
  
  my $m1_row = Rstats::ArrayUtil::values(dim($m1))->[0];
  my $m1_col = Rstats::ArrayUtil::values(dim($m1))->[1];
  
  my $m2 = matrix(0, $m1_col, $m1_row);
  
  for my $row (1 .. $m1_row) {
    for my $col (1 .. $m1_col) {
      my $element = element($m1, $row, $col);
      $m2->at($col, $row);
      $m2->set($element);
    }
  }
  
  return $m2;
}

sub is_array {
  my $a1 = shift;
  
  return c(Rstats::Util::TRUE());
}

sub is_vector {
  my $a1 = shift;
  
  my $is = @{elements(dim($a1))} == 0 ? Rstats::Util::TRUE() : Rstats::Util::FALSE();
  
  return c($is);
}

sub is_matrix {
  my $a1 = shift;

  my $is = @{elements(dim($a1))} == 2 ? Rstats::Util::TRUE() : Rstats::Util::FALSE();
  
  return c($is);
}

sub as_matrix {
  my $a1 = shift;
  
  my $a1_dim_elements = Rstats::ArrayUtil::values(dim_as_array($a1));
  my $a1_dim_count = @$a1_dim_elements;
  my $a2_dim_elements = [];
  my $row;
  my $col;
  if ($a1_dim_count == 2) {
    $row = $a1_dim_elements->[0];
    $col = $a1_dim_elements->[1];
  }
  else {
    $row = 1;
    $row *= $_ for @$a1_dim_elements;
    $col = 1;
  }
  
  my $a2_elements = [@{elements($a1)}];
  
  return matrix($a2_elements, $row, $col);
}

sub as_array {
  my $a1 = shift;
  
  my $a1_elements = [@{elements($a1)}];
  my $a1_dim_elements = [@{Rstats::ArrayUtil::values(dim_as_array($a1))}];
  
  return $a1->array($a1_elements, $a1_dim_elements);
}

sub as_vector {
  my $a1 = shift;
  
  my $a1_elements = [@{elements($a1)}];
  
  return c($a1_elements);
}

sub upgrade_type {
  my (@arrays) = @_;
  
  # Check elements
  my $type_h = {};
  for my $a1 (@arrays) {
    my $type = $a1->{type} || '';
    if ($type eq 'character') {
      $type_h->{character}++;
    }
    elsif ($type eq 'complex') {
      $type_h->{complex}++;
    }
    elsif ($type eq 'double') {
      $type_h->{double}++;
    }
    elsif ($type eq 'integer') {
      $type_h->{integer}++;
    }
    elsif ($type eq 'logical') {
      $type_h->{logical}++;
    }
    else {
      croak "Invalid type";
    }
  }

  # Upgrade elements and type if type is different
  my @types = keys %$type_h;
  if (@types > 1) {
    my $to_type;
    if ($type_h->{character}) {
      $to_type = 'character';
    }
    elsif ($type_h->{complex}) {
      $to_type = 'complex';
    }
    elsif ($type_h->{double}) {
      $to_type = 'double';
    }
    elsif ($type_h->{integer}) {
      $to_type = 'integer';
    }
    elsif ($type_h->{logical}) {
      $to_type = 'logical';
    }
    $_ = as($to_type, $_) for @arrays;
  }
  
  return @arrays;
}

1;
