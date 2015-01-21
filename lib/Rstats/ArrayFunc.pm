package Rstats::ArrayFunc;

use strict;
use warnings;
use Carp 'croak', 'carp';

use Rstats::Func;
use Rstats::Util;
use Rstats::VectorFunc;

sub seq {
  
  # Option
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  # Along
  my $_along = $opt->{along};
  if (defined $_along) {
    my $along = to_c($_along);
    my $length = $along->length_value;
    return seq(1, $length);
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
    
    return Rstats::ArrayFunc::c(@$elements);
  }
}

sub numeric {
  my $num = shift;
  
  return Rstats::ArrayFunc::c((0) x $num);
}

sub to_c {
  my $_x = shift;
  
  my $is_container;
  eval {
    $is_container = $_x->isa('Rstats::Container');
  };
  my $x1 = $is_container ? $_x : Rstats::ArrayFunc::c($_x);
  
  return $x1;
}

sub upgrade_type {
  my (@xs) = @_;
  
  # Check elements
  my $type_h = {};
  for my $x1 (@xs) {
    my $type = $x1->vector->type || '';
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
    $_ = $_->as($to_type) for @xs;
  }
  
  return @xs;
}

sub add { operate_binary(\&Rstats::VectorFunc::add, @_) }
sub subtract { operate_binary(\&Rstats::VectorFunc::subtract, @_) }
sub multiply { operate_binary(\&Rstats::VectorFunc::multiply, @_) }
sub divide { operate_binary(\&Rstats::VectorFunc::divide, @_) }
sub remainder { operate_binary(\&Rstats::VectorFunc::remainder, @_) }
sub pow { operate_binary(\&Rstats::VectorFunc::pow, @_) }
sub less_than { operate_binary(\&Rstats::VectorFunc::less_than, @_) }
sub less_than_or_equal { operate_binary(\&Rstats::VectorFunc::less_than_or_equal, @_) }
sub more_than { operate_binary(\&Rstats::VectorFunc::more_than, @_) }
sub more_than_or_equal { operate_binary(\&Rstats::VectorFunc::more_than_or_equal, @_) }
sub equal { operate_binary(\&Rstats::VectorFunc::equal, @_) }
sub not_equal { operate_binary(\&Rstats::VectorFunc::not_equal, @_) }
sub and { operate_binary(\&Rstats::VectorFunc::and, @_) }
sub or { operate_binary(\&Rstats::VectorFunc::or, @_) }

sub operate_unary {
  my $func = shift;
  my $x1 = to_c(shift);
  
  my $x2_elements = $func->($x1->vector);
  my $x2 = Rstats::Func::NULL();
  $x2->vector($x2_elements);
  $x1->copy_attrs_to($x2);
  
  return $x2;
}

sub negation { operate_unary(\&Rstats::VectorFunc::negation, @_) }

sub _fix_pos {
  my ($data1, $data2, $reverse) = @_;
  
  my $x1;
  my $x2;
  if (ref $data2 eq 'Rstats::Array') {
    $x1 = $data1;
    $x2 = $data2;
  }
  else {
    if ($reverse) {
      $x1 = Rstats::ArrayFunc::c($data2);
      $x2 = $data1;
    }
    else {
      $x1 = $data1;
      $x2 = Rstats::ArrayFunc::c($data2);
    }
  }
  
  return ($x1, $x2);
}

sub operate_binary {
  my ($func, $x1, $x2) = @_;
  
  $x1 = to_c($x1);
  $x2 = to_c($x2);
  
  # Upgrade mode if type is different
  ($x1, $x2) = Rstats::ArrayFunc::upgrade_type($x1, $x2) if $x1->vector->type ne $x2->vector->type;
  
  # Upgrade length if length is defferent
  my $x1_length = $x1->length_value;
  my $x2_length = $x2->length_value;
  my $length;
  if ($x1_length > $x2_length) {
    $x2 = Rstats::Func::array($x2, $x1_length);
    $length = $x1_length;
  }
  elsif ($x1_length < $x2_length) {
    $x1 = Rstats::Func::array($x1, $x2_length);
    $length = $x2_length;
  }
  else {
    $length = $x1_length;
  }
  
  no strict 'refs';
  my $x3;
  my $x3_elements = $func->($x1->vector, $x2->vector);
  $x3 = Rstats::Func::NULL();
  $x3->vector($x3_elements);
  
  $x1->copy_attrs_to($x3);

  return $x3;
}

sub operate_binary_fix_pos {
  my ($self, $func, $data, $reverse) = @_;
  
  # fix postion
  my ($x1, $x2) = Rstats::ArrayFunc::_fix_pos($self, $data, $reverse);
  
  return Rstats::Func::operate_binary($func, $x1, $x2);
}

sub inner_product {
  my ($self, $data, $reverse) = @_;
  
  # fix postion
  my ($x1, $x2) = Rstats::ArrayFunc::_fix_pos($self, $data, $reverse);
  
  return Rstats::Func::inner_product($x1, $x2);
}

sub value {
  my $self = shift;

  my $e1;
  my $dim_values = $self->dim_as_array->values;
  my $self_elements = $self->decompose;
  if (@_) {
    if (@$dim_values == 1) {
      $e1 = $self_elements->[$_[0] - 1];
    }
    elsif (@$dim_values == 2) {
      $e1 = $self_elements->[($_[0] + $dim_values->[0] * ($_[1] - 1)) - 1];
    }
    else {
      $e1 = $self->get(@_)->decompose->[0];
    }
  }
  else {
    $e1 = $self_elements->[0];
  }
  
  return defined $e1 ? $e1->value : undef;
}

sub bool {
  my $self = shift;
  
  my $length = $self->length_value;
  if ($length == 0) {
    croak 'Error in if (a) { : argument is of length zero';
  }
  elsif ($length > 1) {
    carp 'In if (a) { : the condition has length > 1 and only the first element will be used';
  }
  
  my $type = $self->type;
  my $value = $self->value;

  my $is;
  if ($type eq 'character' || $type eq 'complex') {
    croak 'Error in -a : invalid argument to unary operator ';
  }
  elsif ($type eq 'double') {
    if ($value eq 'Inf' || $value eq '-Inf') {
      $is = 1;
    }
    elsif ($value eq 'NaN') {
      croak 'argument is not interpretable as logical';
    }
    else {
      $is = $value;
    }
  }
  elsif ($type eq 'integer' || $type eq 'logical') {
    $is = $value;
  }
  else {
    croak "Invalid type";
  }
  
  if (!defined $value) {
    croak "Error in bool context (a) { : missing value where TRUE/FALSE needed"
  }

  return $is;
}

sub set {
  my $self = shift;
  my $x2 = Rstats::Func::to_c(shift);
  
  my $at = $self->at;
  my $_indexs = ref $at eq 'ARRAY' ? $at : [$at];
  my ($poss, $x2_dim) = Rstats::Util::parse_index($self, 0, @$_indexs);
  
  my $self_elements;
  if ($self->is_factor) {
    $self_elements = $self->decompose;
    $x2 = $x2->as_character unless $x2->is_character;
    my $x2_elements = $x2->decompose;
    my $levels_h = $self->_levels_h;
    for (my $i = 0; $i < @$poss; $i++) {
      my $pos = $poss->[$i];
      my $element = $x2_elements->[(($i + 1) % @$poss) - 1];
      if ($element->is_na->value) {
        $self_elements->[$pos] = Rstats::VectorFunc::new_logical(undef);
      }
      else {
        my $value = $element->to_string;
        if ($levels_h->{$value}) {
          $self_elements->[$pos] = $levels_h->{$value};
        }
        else {
          carp "invalid factor level, NA generated";
          $self_elements->[$pos] = Rstats::VectorFunc::new_logical(undef);
        }
      }
    }
  }
  else {
    # Upgrade mode if type is different
    if ($self->vector->type ne $x2->vector->type) {
      my $self_tmp;
      ($self_tmp, $x2) = Rstats::ArrayFunc::upgrade_type($self, $x2);
      $self_tmp->copy_attrs_to($self);
      $self->vector($self_tmp->vector);
    }

    $self_elements = $self->decompose;

    my $x2_elements = $x2->decompose;
    for (my $i = 0; $i < @$poss; $i++) {
      my $pos = $poss->[$i];
      $self_elements->[$pos] = $x2_elements->[(($i + 1) % @$poss) - 1];
    }
  }
  
  $self->vector(Rstats::Vector->compose($self->vector->type, $self_elements));
  
  return $self;
}

sub _levels_h {
  my $self = shift;
  
  my $levels_h = {};
  my $levels = $self->levels->values;
  for (my $i = 1; $i <= @$levels; $i++) {
    $levels_h->{$levels->[$i - 1]} = Rstats::VectorFunc::new_integer($i);
  }
  
  return $levels_h;
}

sub get {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $dim_drop;
  my $level_drop;
  if ($self->is_factor) {
    $level_drop = $opt->{drop};
  }
  else {
    $dim_drop = $opt->{drop};
  }
  
  $dim_drop = 1 unless defined $dim_drop;
  $level_drop = 0 unless defined $level_drop;
  
  my @_indexs = @_;

  my $_indexs;
  if (@_indexs) {
    $_indexs = \@_indexs;
  }
  else {
    my $at = $self->at;
    $_indexs = ref $at eq 'ARRAY' ? $at : [$at];
  }
  $self->at($_indexs);
  
  my ($poss, $x2_dim, $new_indexes) = Rstats::Util::parse_index($self, $dim_drop, @$_indexs);
  
  my $self_values = $self->values;
  my @a2_values = map { $self_values->[$_] } @$poss;
  
  # array
  my $x2 = Rstats::Func::array(
    Rstats::Func::new_vector($self->vector->type, @a2_values),
    Rstats::ArrayFunc::c(@$x2_dim)
  );
  
  # Copy attributes
  $self->copy_attrs_to($x2, {new_indexes => $new_indexes, exclude => ['dim']});

  # level drop
  if ($level_drop) {
    $x2 = Rstats::Func::factor($x2->as_character);
  }
  
  return $x2;
}

sub getin { get(@_) }

sub is_null {
  my $x1 = Rstats::Func::to_c(shift);
  
  my $x_is = $x1->length_value == 0 ? Rstats::Func::TRUE() : Rstats::Func::FALSE();
  
  return $x_is;
}

sub is_nan {
  my $x1 = Rstats::Func::to_c(shift);
  
  if (my $vector = $x1->vector) {
    my $x2 = Rstats::Func::NULL();
    $x2->vector($x1->vector->is_nan);
    $x1->copy_attrs_to($x2);
    
    return $x2;
  }
  else {
    croak "Error : is_nan is not implemented except array";
  }
}

sub is_infinite {
  my $x1 = Rstats::Func::to_c(shift);
  
  if (my $vector = $x1->vector) {
    my $x2 = Rstats::Func::NULL();
    $x2->vector($x1->vector->is_infinite);
    $x1->copy_attrs_to($x2);
    
    return $x2;
  }
  else {
    croak "Error : is_infinite is not implemented except array";
  }
}

sub is_finite {
  my $x1 = Rstats::Func::to_c(shift);
  
  if (my $vector = $x1->vector) {
    my $x2 = Rstats::Func::NULL();
    $x2->vector($x1->vector->is_finite);
    $x1->copy_attrs_to($x2);
    
    return $x2;
  }
  else {
    croak "Error : is_finite is not implemented except array";
  }
}

sub to_string {
  my $self = shift;
  
  my $is_factor = $self->is_factor;
  my $is_ordered = $self->is_ordered;
  my $levels;
  if ($is_factor) {
    $levels = $self->levels->values;
  }
  
  $self = $self->as_character if $self->is_factor;
  
  my $is_character = $self->is_character;

  my $values = $self->values;
  my $type = $self->vector->type;
  
  my $dim_values = $self->dim_as_array->values;
  
  my $dim_length = @$dim_values;
  my $dim_num = $dim_length - 1;
  my $poss = [];
  
  my $str;
  if (@$values) {
    if ($dim_length == 1) {
      my $names = $self->names->values;
      if (@$names) {
        $str .= join(' ', @$names) . "\n";
      }
      my @parts = map { $self->_value_to_string($_, $type, $is_factor) } @$values;
      $str .= '[1] ' . join(' ', @parts) . "\n";
    }
    elsif ($dim_length == 2) {
      $str .= '     ';
      
      my $colnames = $self->colnames->values;
      if (@$colnames) {
        $str .= join(' ', @$colnames) . "\n";
      }
      else {
        for my $d2 (1 .. $dim_values->[1]) {
          $str .= $d2 == $dim_values->[1] ? "[,$d2]\n" : "[,$d2] ";
        }
      }
      
      my $rownames = $self->rownames->values;
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
          my $part = $self->value($d1, $d2);
          push @parts, $self->_value_to_string($part, $type, $is_factor);
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
          unshift @$poss, $i;
          if (@dim_values > 2) {
            $dim_num--;
            $code->(@dim_values);
            $dim_num++;
          }
          else {
            $str .= '     ';
            
            my $l_dimnames = $self->dimnames;
            my $dimnames;
            if ($l_dimnames->is_null) {
              $dimnames = [];
            }
            else {
              my $x_dimnames = $l_dimnames->getin($i);
              $dimnames = defined $l_dimnames ? $l_dimnames->values : [];
            }
            
            if (@$dimnames) {
              $str .= join(' ', @$dimnames) . "\n";
            }
            else {
              for my $d2 (1 .. $dim_values[1]) {
                $str .= $d2 == $dim_values[1] ? "[,$d2]\n" : "[,$d2] ";
              }
            }

            for my $d1 (1 .. $dim_values[0]) {
              $str .= "[$d1,] ";
              
              my @parts;
              for my $d2 (1 .. $dim_values[1]) {
                my $part = $self->value($d1, $d2, @$poss);
                push @parts, $self->_value_to_string($part, $type, $is_factor);
              }
              
              $str .= join(' ', @parts) . "\n";
            }
          }
          shift @$poss;
        }
      };
      $code->(@$dim_values);
    }

    if ($is_factor) {
      if ($is_ordered) {
        $str .= 'Levels: ' . join(' < ', @$levels) . "\n";
      }
      else {
        $str .= 'Levels: ' . join(' ', , @$levels) . "\n";
      }
    }
  }
  else {
    $str = 'NULL';
  }
  
  return $str;
}

1;

=head1 NAME

Rstats::ArrayFunc - Array functions

