package Rstats::ArrayUtil;

use strict;
use warnings;
use Carp qw/croak carp/;
use Rstats::Util;

my %types_h = map { $_ => 1 } qw/character complex numeric double integer logical/;

sub NULL { Rstats::Array->new(elements => [], dim => [], type => 'logical') }

sub array {
  
  # Arguments
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my ($a1, $_dim) = @_;
  $_dim = $opt->{dim} unless defined $_dim;
  
  my $array = Rstats::ArrayUtil::c($a1);

  # Dimention
  my $elements = $array->elements;
  my $dim;
  if (defined $_dim) {
    if (ref $_dim eq 'Rstats::Array') {
      $dim = $_dim->elements;
    }
    elsif (ref $_dim eq 'ARRAY') {
      $dim = $_dim;
    }
    elsif(!ref $_dim) {
      $dim = [$_dim];
    }
  }
  else {
    $dim = [scalar @$elements]
  }
  Rstats::ArrayUtil::dim($array => $dim);
  
  # Fix elements
  my $max_length = 1;
  $max_length *= $_ for @{Rstats::ArrayUtil::_real_dim_values($array) || [scalar @$elements]};
  if (@$elements > $max_length) {
    @$elements = splice @$elements, 0, $max_length;
  }
  elsif (@$elements < $max_length) {
    my $repeat_count = int($max_length / @$elements) + 1;
    @$elements = (@$elements) x $repeat_count;
    @$elements = splice @$elements, 0, $max_length;
  }
  $array->elements($elements);
  
  return $array;
}

sub matrix {
  
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};

  my ($_a1, $nrow, $ncol, $byrow, $dirnames) = @_;

  croak "matrix method need data as frist argument"
    unless defined $_a1;
  
  my $a1 = Rstats::ArrayUtil::to_array($_a1);
  
  # Row count
  $nrow = $opt->{nrow} unless defined $nrow;
  
  # Column count
  $ncol = $opt->{ncol} unless defined $ncol;
  
  # By row
  $byrow = $opt->{byrow} unless defined $byrow;
  
  my $a1_elements = $a1->elements;
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
    $matrix = Rstats::ArrayUtil::array(
      $a1_elements,
      [$dim->[1], $dim->[0]],
    );
    
    $matrix = Rstats::ArrayUtil::t($matrix);
  }
  else {
    $matrix = Rstats::ArrayUtil::array($a1_elements, $dim);
  }
  
  return $matrix;
}

sub typeof {
  my $array = shift;
  
  my $type = $array->{type};
  my $a1_elements = defined $type ? $type : "NULL";
  my $a1 = Rstats::ArrayUtil::c([$a1_elements]);
  
  return $a1;
}

sub mode {
  my $array = shift;
  
  if (@_) {
    my $type = $_[0];
    croak qq/Error in eval(expr, envir, enclos) : could not find function "as_$type"/
      unless $types_h{$type};
    
    if ($type eq 'numeric') {
      $array->{type} = 'double';
    }
    else {
      $array->{type} = $type;
    }
    
    return $array;
  }
  else {
    my $type = $array->{type};
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

    return Rstats::ArrayUtil::c([$mode]);
  }
}

sub NA { Rstats::ArrayUtil::c(Rstats::Util::NA()) }

sub NaN { Rstats::ArrayUtil::c(Rstats::Util::NaN()) }

sub inner_product {
  my ($a1, $a2) = @_;
  
  # Convert to matrix
  $a1 = Rstats::ArrayUtil::t(Rstats::ArrayUtil::as_matrix($a1)) if Rstats::ArrayUtil::is_vector($a1);
  $a2 = Rstats::ArrayUtil::as_matrix($a2) if Rstats::ArrayUtil::is_vector($a2);
  
  # Calculate
  if (Rstats::ArrayUtil::is_matrix($a1) && Rstats::ArrayUtil::is_matrix($a2)) {
    
    croak "requires numeric/complex matrix/vector arguments"
      if @{$a1->elements} == 0 || @{$a2->elements} == 0;
    croak "Error in a x b : non-conformable arguments"
      unless Rstats::ArrayUtil::dim($a1)->values->[1] == Rstats::ArrayUtil::dim($a2)->values->[0];
    
    my $row_max = Rstats::ArrayUtil::dim($a1)->values->[0];
    my $col_max = Rstats::ArrayUtil::dim($a2)->values->[1];
    
    my $a3_elements = [];
    for (my $col = 1; $col <= $col_max; $col++) {
      for (my $row = 1; $row <= $row_max; $row++) {
        my $v1 = $a1->get($row);
        my $v2 = $a2->get(Rstats::ArrayUtil::NULL, $col);
        my $v3 = Rstats::ArrayUtil::sum($a1 * $a2);
        push $a3_elements, $v3;
      }
    }
    
    my $a3 = Rstats::ArrayUtil::matrix($a3_elements, $row_max, $col_max);
    
    return $a3;
  }
  else {
    croak "inner_product should be dim < 3."
  }
}

sub row {
  my $array = shift;
  
  my $nrow = Rstats::ArrayUtil::nrow($array)->value;
  my $ncol = Rstats::ArrayUtil::ncol($array)->value;
  
  my @values = (1 .. $nrow) x $ncol;
  
  return Rstats::ArrayUtil::array(\@values, [$nrow, $ncol]);
}

sub col {
  my $array = shift;
  
  my $nrow = Rstats::ArrayUtil::nrow($array)->value;
  my $ncol = Rstats::ArrayUtil::ncol($array)->value;
  
  my @values;
  for my $col (1 .. $ncol) {
    push @values, ($col) x $nrow;
  }
  
  return Rstats::ArrayUtil::array(\@values, [$nrow, $ncol]);
}

sub nrow {
  my $array = shift;
  
  return Rstats::ArrayUtil::array(Rstats::ArrayUtil::dim($array)->values->[0]);
}

sub ncol {
  my $array = shift;
  
  return Rstats::ArrayUtil::array(Rstats::ArrayUtil::dim($array)->values->[1]);
}

sub names {
  my $array = shift;
  
  if (@_) {
    my $_names = shift;
    my $names;
    if (!defined $_names) {
      $names = [];
    }
    elsif (ref $_names eq 'ARRAY') {
      $names = $_names;
    }
    elsif (ref $_names eq 'Rstats::Array') {
      $names = $_names->elements;
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
    $array->{names} = $names;
  }
  else {
    $array->{names} = [] unless exists $array->{names};
    return Rstats::ArrayUtil::array($array->{names});
  }
}

sub colnames {
  my $array = shift;
  
  if (@_) {
    my $_colnames = shift;
    my $colnames;
    if (!defined $_colnames) {
      $colnames = [];
    }
    elsif (ref $_colnames eq 'ARRAY') {
      $colnames = $_colnames;
    }
    elsif (ref $_colnames eq 'Rstats::Array') {
      $colnames = $_colnames->elements;
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
    $array->{colnames} = $colnames;
  }
  else {
    $array->{colnames} = [] unless exists $array->{colnames};
    return Rstats::ArrayUtil::array($array->{colnames});
  }
}

sub rownames {
  my $array = shift;
  
  if (@_) {
    my $_rownames = shift;
    my $rownames;
    if (!defined $_rownames) {
      $rownames = [];
    }
    elsif (ref $_rownames eq 'ARRAY') {
      $rownames = $_rownames;
    }
    elsif (ref $_rownames eq 'Rstats::Array') {
      $rownames = $_rownames->elements;
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
    $array->{rownames} = $rownames;
  }
  else {
    $array->{rownames} = [] unless exists $array->{rownames};
    return Rstats::ArrayUtil::array($array->{rownames});
  }
}

sub dim {
  my $array = shift;
  
  if (@_) {
    my $a1 = $_[0];
    if (ref $a1 eq 'Rstats::Array') {
      $array->{dim} = $a1->elements;
    }
    elsif (ref $a1 eq 'ARRAY') {
      $array->{dim} = $a1;
    }
    elsif(!ref $a1) {
      $array->{dim} = [$a1];
    }
    else {
      croak "Invalid elements is passed to dim argument";
    }
  }
  else {
    $array->{dim} = [] unless exists $array->{dim};
    return Rstats::ArrayUtil::c($array->{dim});
  }
}

sub length {
  my $array = shift;
  
  my $length = @{$array->elements};
  
  return Rstats::ArrayUtil::c($length);
}

sub seq {
  my $array = shift;
  
  # Option
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  # Along
  my $along = $opt->{along};
  
  if ($along) {
    my $length = Rstats::Util::length($along);
    return Rstats::ArrayUtil::seq(1,$length);
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
    
    return Rstats::ArrayUtil::c($elements);
  }
}

sub c {
  my @values = @_;
  
  # Array
  my $array = Rstats::ArrayUtil::NULL();
  
  # Value
  my $elements = [];
  my $a1;
  if (@values == 0) {
    return Rstats::ArrayUtil::NULL();
  }
  elsif (@values > 1) {
    $a1 = \@values;
  }
  else {
    $a1 = $values[0];
  }
  if (defined $a1) {
    if (ref $a1 eq 'ARRAY') {
      for my $a (@$a1) {
        if (ref $a eq 'ARRAY') {
          push @$elements, @$a;
        }
        elsif (ref $a eq 'Rstats::Array') {
          push @$elements, @{$a->elements};
        }
        else {
          push @$elements, $a;
        }
      }
    }
    elsif (ref $a1 eq 'Rstats::Array') {
      $elements = $a1->elements;
    }
    else {
      $elements = [$a1];
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
      $element = Rstats::Util::double($element->value);
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

  # Upgrade elements and type
  my @modes = keys %$mode_h;
  if (@modes > 1) {
    if ($mode_h->{character}) {
      my $a1 = Rstats::ArrayUtil::as_character($a1->clone_without_elements);
      $elements = $a1->elements;
      Rstats::ArrayUtil::mode($array => 'character');
    }
    elsif ($mode_h->{complex}) {
      my $a1 = Rstats::ArrayUtil::as_complex($a1->clone_without_elements);
      $elements = $a1->elements;
      Rstats::ArrayUtil::mode($array => 'complex');
    }
    elsif ($mode_h->{double}) {
      my $a1 = Rstats::ArrayUtil::as_elements($a1->clone_without_elements);
      $elements = $a1->elements;
      Rstats::ArrayUtil::mode($array => 'double');
    }
    elsif ($mode_h->{logical}) {
      my $a1 = Rstats::ArrayUtil::as_logical($a1->clone_without_elements);
      $elements = $a1->elements;
      Rstats::ArrayUtil::mode($array => 'logical');
    }
  }
  else {
    Rstats::ArrayUtil::mode($array => $modes[0] || 'logical');
  }
  
  $array->elements($elements);
  
  return $array;
}

sub C {
  my ($array, $seq_str) = @_;

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
  
  my $vector = Rstats::ArrayUtil::seq({from => $from, to => $to, by => $by});
  
  return $vector;
}

sub _real_dim_values {
  my $array = shift;
  
  my $dim = Rstats::ArrayUtil::dim($array);
  if (@{$dim->values}) {
    return $dim->values;
  }
  else {
    if (defined $array->elements) {
      my $length = @{$array->elements};
      return [$length];
    }
    else {
      return;
    }
  }
}

sub is_numeric {
  my $array = shift;
  
  my $is = ($array->{type} || '') eq 'double' || ($array->{type} || '') eq 'integer'
    ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return Rstats::ArrayUtil::c($is);
}

sub is_double {
  my $array = shift;
  
  my $is = ($array->{type} || '') eq 'double' ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return Rstats::ArrayUtil::c($is);
}

sub is_integer {
  my $array = shift;
  
  my $is = ($array->{type} || '') eq 'integer' ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return Rstats::ArrayUtil::c($is);
}

sub is_complex {
  my $array = shift;
  
  my $is = ($array->{type} || '') eq 'complex' ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return Rstats::ArrayUtil::c($is);
}

sub is_character {
  my $array = shift;
  
  my $is = ($array->{type} || '') eq 'character' ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return Rstats::ArrayUtil::c($is);
}

sub is_logical {
  my $array = shift;
  
  my $is = ($array->{type} || '') eq 'logical' ? Rstats::Util::TRUE : Rstats::Util::FALSE;
  
  return Rstats::ArrayUtil::c($is);
}

sub as {
  my ($array, $mode) = @_;
  
  if ($mode eq 'character') {
    return Rstats::ArrayUtil::as_character($array);
  }
  elsif ($mode eq 'complex') {
    return Rstats::ArrayUtil::as_complex($array);
  }
  elsif ($mode eq 'double') {
    return Rstats::ArrayUtil::as_double($array);
  }
  elsif ($mode eq 'numeric') {
    return Rstats::ArrayUtil::as_numeric($array);
  }
  elsif ($mode eq 'integer') {
    return Rstats::ArrayUtil::as_integer($array);
  }
  elsif ($mode eq 'logical') {
    return Rstats::ArrayUtil::as_logical($array);
  }
  else {
    croak "Invalid mode is passed";
  }
}

sub as_complex {
  my $array = shift;
  
  my $a1 = $array;
  my $a1_elements = $a1->elements;
  my $a2 = $a1->clone_without_elements;
  my @a2_elements = map {
    if (Rstats::Util::is_na($_)) {
      $_;
    }
    elsif (Rstats::Util::is_character($_)) {
      my $z = Rstats::Util::looks_like_complex($_->value);
      if (defined $z) {
        Rstats::Util::complex($z->{re}, $z->{im});
      }
      else {
        carp 'NAs introduced by coercion';
        Rstats::Util::NA;
      }
    }
    elsif (Rstats::Util::is_complex($_)) {
      $_;
    }
    elsif (Rstats::Util::is_double($_)) {
      if (Rstats::Util::is_nan($_)) {
        Rstats::Util::NA;
      }
      else {
        Rstats::Util::complex_double($_, Rstats::Util::double(0));
      }
    }
    elsif (Rstats::Util::is_integer($_)) {
      Rstats::Util::complex($_->value, 0);
    }
    elsif (Rstats::Util::is_logical($_)) {
      Rstats::Util::complex($_->value ? 1 : 0, 0);
    }
    else {
      croak "unexpected type";
    }
  } @$a1_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'complex';

  return $a2;
}

sub as_numeric { as_double(@_) }

sub as_double {
  my $array = shift;
  
  my $a1 = $array;
  my $a1_elements = $a1->elements;
  my $a2 = $a1->clone_without_elements;
  my @a2_elements = map {
    if (Rstats::Util::is_na($_)) {
      $_;
    }
    elsif (Rstats::Util::is_character($_)) {
      if (my $num = Rstats::Util::looks_like_number($_->value)) {
        Rstats::Util::double($num + 0);
      }
      else {
        carp 'NAs introduced by coercion';
        Rstats::Util::NA;
      }
    }
    elsif (Rstats::Util::is_complex($_)) {
      carp "imaginary parts discarded in coercion";
      Rstats::Util::double($_->re->value);
    }
    elsif (Rstats::Util::is_double($_)) {
      $_;
    }
    elsif (Rstats::Util::is_integer($_)) {
      Rstats::Util::double($_->value);
    }
    elsif (Rstats::Util::is_logical($_)) {
      Rstats::Util::double($_->value ? 1 : 0);
    }
    else {
      croak "unexpected type";
    }
  } @$a1_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'double';

  return $a2;
}

sub as_integer {
  my $array = shift;
  
  my $a1 = $array;
  my $a1_elements = $a1->elements;
  my $a2 = $a1->clone_without_elements;
  my @a2_elements = map {
    if (Rstats::Util::is_na($_)) {
      $_;
    }
    elsif (Rstats::Util::is_character($_)) {
      if (my $num = Rstats::Util::looks_like_number($_->value)) {
        Rstats::Util::integer(int $num);
      }
      else {
        carp 'NAs introduced by coercion';
        Rstats::Util::NA;
      }
    }
    elsif (Rstats::Util::is_complex($_)) {
      carp "imaginary parts discarded in coercion";
      Rstats::Util::integer(int($_->re->value));
    }
    elsif (Rstats::Util::is_double($_)) {
      if (Rstats::Util::is_nan($_) || Rstats::Util::is_infinite($_)) {
        Rstats::Util::NA;
      }
      else {
        Rstats::Util::integer($_->value);
      }
    }
    elsif (Rstats::Util::is_integer($_)) {
      $_; 
    }
    elsif (Rstats::Util::is_logical($_)) {
      Rstats::Util::integer($_->value ? 1 : 0);
    }
    else {
      croak "unexpected type";
    }
  } @$a1_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'integer';

  return $a2;
}

sub as_logical {
  my $array = shift;
  
  my $a1 = $array;
  my $a1_elements = $a1->elements;
  my $a2 = $a1->clone_without_elements;
  my @a2_elements = map {
    if (Rstats::Util::is_na($_)) {
      $_;
    }
    elsif (Rstats::Util::is_character($_)) {
      Rstats::Util::NA;
    }
    elsif (Rstats::Util::is_complex($_)) {
      carp "imaginary parts discarded in coercion";
      my $re = $_->re->value;
      my $im = $_->im->value;
      if (defined $re && $re == 0 && defined $im && $im == 0) {
        Rstats::Util::FALSE;
      }
      else {
        Rstats::Util::TRUE;
      }
    }
    elsif (Rstats::Util::is_double($_)) {
      if (Rstats::Util::is_nan($_)) {
        Rstats::Util::NA;
      }
      elsif (Rstats::Util::is_infinite($_)) {
        Rstats::Util::TRUE;
      }
      else {
        $_->value == 0 ? Rstats::Util::FALSE : Rstats::Util::TRUE;
      }
    }
    elsif (Rstats::Util::is_integer($_)) {
      $_->value == 0 ? Rstats::Util::FALSE : Rstats::Util::TRUE;
    }
    elsif (Rstats::Util::is_logical($_)) {
      $_->value == 0 ? Rstats::Util::FALSE : Rstats::Util::TRUE;
    }
    else {
      croak "unexpected type";
    }
  } @$a1_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'logical';

  return $a2;
}

sub as_character {
  my $a1 = shift;

  my $a1_elements = $1->elements;
  my $a2 = $a1->clone_without_elements;
  my @a2_elements = map {
    Rstats::Util::character(Rstats::Util::to_string($_))
  } @$a1_elements;
  $a2->elements(\@a2_elements);
  $a2->{type} = 'character';

  return $a2;
}

sub numeric {
  my ($array, $num) = @_;
  
  return Rstats::ArrayUtil::c([(0) x $num]);
}

sub to_array {
  my $_array = shift;
  
  my $array
   = !defined $_array ? Rstats::ArrayUtil::NULL
   : ref $_array eq 'Rstats::Array' ? $_array
   : Rstats::ArrayUtil::c($_array);
  
  return $array;
}

sub parse_index {
  my ($array, $drop, @_indexs) = @_;
  
  my $a1_dim = Rstats::ArrayUtil::_real_dim_values($array);
  my @indexs;
  my @a2_dim;
  
  for (my $i = 0; $i < @$a1_dim; $i++) {
    my $_index = $_indexs[$i];
    
    my $index = Rstats::ArrayUtil::to_array($_index);
    my $index_values = $index->values;
    if (@$index_values && !Rstats::ArrayUtil::is_character($index)->value && !Rstats::ArrayUtil::is_logical($index)->value) {
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
    
    if (!@{$index->values}) {
      my $index_values_new = [1 .. $a1_dim->[$i]];
      $index = Rstats::ArrayUtil::array($index_values_new);
    }
    elsif (Rstats::ArrayUtil::is_character($index)) {
      if (Rstats::ArrayUtil::is_vector($array)) {
        my $index_new_values = [];
        for my $name (@{$index->values}) {
          my $i = 0;
          my $value;
          for my $array_name (@{Rstats::Util::ArrayUtil::names($array)->values}) {
            if ($name eq $array_name) {
              $value = $array->values->[$i];
              last;
            }
            $i++;
          }
          croak "Can't find name" unless defined $value;
          push @$index_new_values, $value;
        }
        $indexs[$i] = Rstats::ArrayUtil::array($index_new_values);
      }
      elsif (Rstats::ArrayUtil::is_matrix($array)) {
        
      }
      else {
        croak "Can't support name except vector and matrix";
      }
    }
    elsif (Rstats::ArrayUtil::is_logical($index)) {
      my $index_values_new = [];
      for (my $i = 0; $i < @{$index->values}; $i++) {
        push @$index_values_new, $i + 1 if Rstats::Util::bool($index->elements->[$i]);
      }
      $index = Rstats::ArrayUtil::array($index_values_new);
    }
    elsif ($index->{_minus}) {
      my $index_value_new = [];
      
      for my $k (1 .. $a1_dim->[$i]) {
        push @$index_value_new, $k unless grep { $_ == -$k } @{$index->values};
      }
      $index = Rstats::ArrayUtil::array($index_value_new);
    }

    push @indexs, $index;

    my $count = @{$index->elements};
    push @a2_dim, $count unless $count == 1 && $drop;
  }
  @a2_dim = (1) unless @a2_dim;
  
  my $index_values = [map { $_->values } @indexs];
  my $ords = Rstats::ArrayUtil::cross_product($index_values);
  my @positions = map { Rstats::ArrayUtil::pos($_, $a1_dim) } @$ords;
  
  return (\@positions, \@a2_dim);
}

sub cross_product {
  my ($array, $values) = @_;

  my @idxs = (0) x @$values;
  my @idx_idx = 0..(@idxs - 1);
  my @array = map { $_->[0] } @$values;
  my $result = [];
  
  push @$result, [@array];
  my $end_loop;
  while (1) {
    foreach my $i (@idx_idx) {
      if( $idxs[$i] < @{$values->[$i]} - 1 ) {
        $array[$i] = $values->[$i][++$idxs[$i]];
        push @$result, [@array];
        last;
      }
      
      if ($i == $idx_idx[-1]) {
        $end_loop = 1;
        last;
      }
      
      $idxs[$i] = 0;
      $array[$i] = $values->[$i][0];
    }
    last if $end_loop;
  }
  
  return $result;
}

sub pos {
  my ($array, $ord, $dim) = @_;
  
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

sub t {
  my ($array, $m1) = @_;
  
  my $m1_row = Rstats::ArrayUtil::dim($m1)->elements->[0];
  my $m1_col = Rstats::ArrayUtil::dim($m1)->elements->[1];
  
  my $m2 = Rstats::ArrayUtil::matrix(0, $m1_col, $m1_row);
  
  for my $row (1 .. $m1_row) {
    for my $col (1 .. $m1_col) {
      my $element = $m1->element($row, $col);
      $m2->at($col, $row);
      $m2->set($element);
    }
  }
  
  return $m2;
}

sub is_array {
  my $array = shift;
  
  return Rstats::ArrayUtil::c(Rstats::Util::TRUE());
}

sub is_vector {
  my $array = shift;
  
  my $is = @{Rstats::ArrayUtil::dim($array)->elements} == 0 ? Rstats::Util::TRUE() : Rstats::Util::FALSE();
  
  return Rstats::ArrayUtil::c($is);
}

sub is_matrix {
  my $array = shift;

  my $is = @{Rstats::ArrayUtil::dim($array)->elements} == 2 ? Rstats::Util::TRUE() : Rstats::Util::FALSE();
  
  return Rstats::ArrayUtil::c([$is]);
}

sub as_matrix {
  my $array = shift;
  
  my $a1_dim_elements = Rstats::ArrayUtil::_real_dim_values($array);
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
  
  my $a2_elements = [@{$array->elements}];
  
  return Rstats::ArrayUtil::matrix($a2_elements, $row, $col);
}

sub as_array {
  my $array = shift;
  
  my $a1_elements = [@{$array->elements}];
  my $a1_dim_elements = [@{Rstats::ArrayUtil::_real_dim_values($array)}];
  
  return $array->array($a1_elements, $a1_dim_elements);
}

sub as_vector {
  my $array = shift;
  
  my $a1_elements = [@{$array->elements}];
  
  return Rstats::ArrayUtil::c($a1_elements);
}

sub upgrade_mode {
  my (@arrays) = @_;
  
  # Check elements
  my $mode_h = {};
  for my $array (@arrays) {
    my $type = $array->{type} || '';
    if ($type eq 'character') {
      $mode_h->{character}++;
    }
    elsif ($type eq 'complex') {
      $mode_h->{complex}++;
    }
    elsif ($type eq 'double') {
      $mode_h->{double}++;
    }
    elsif ($type eq 'integer') {
      $mode_h->{integer}++;
    }
    elsif ($type eq 'logical') {
      $mode_h->{logical}++;
    }
    else {
      croak "Invalid mode";
    }
  }

  # Upgrade elements and type if mode is different
  my @modes = keys %$mode_h;
  if (@modes > 1) {
    my $to_mode;
    if ($mode_h->{character}) {
      $to_mode = 'character';
    }
    elsif ($mode_h->{complex}) {
      $to_mode = 'complex';
    }
    elsif ($mode_h->{double}) {
      $to_mode = 'double';
    }
    elsif ($mode_h->{integer}) {
      $to_mode = 'integer';
    }
    elsif ($mode_h->{logical}) {
      $to_mode = 'logical';
    }
    $_ = Rstats::ArrayUtil::as($_ => $to_mode) for @arrays;
  }
  
  return @arrays;
}

1;
