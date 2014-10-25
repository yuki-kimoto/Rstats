package Rstats::Container::Array;
use Rstats::Container -base;

use Rstats::ElementsFunc;
use Rstats::Func;
use Rstats::Util;
use Carp 'croak', 'carp';

our @CARP_NOT = ('Rstats');

use overload
  bool => \&bool,
  '+' => sub { shift->operation('add', @_) },
  '-' => sub { shift->operation('subtract', @_) },
  '*' => sub { shift->operation('multiply', @_) },
  '/' => sub { shift->operation('divide', @_) },
  '%' => sub { shift->operation('remainder', @_) },
  'neg' => sub { shift->negation(@_) },
  '**' => sub { shift->operation('raise', @_) },
  'x' => sub { shift->inner_product(@_) },
  '<' => sub { shift->operation('less_than', @_) },
  '<=' => sub { shift->operation('less_than_or_equal', @_) },
  '>' => sub { shift->operation('more_than', @_) },
  '>=' => sub { shift->operation('more_than_or_equal', @_) },
  '==' => sub { shift->operation('equal', @_) },
  '!=' => sub { shift->operation('not_equal', @_) },
  '""' => sub { shift->to_string(@_) },
  '&' => sub { shift->operation('and', @_) },
  '|' => sub { shift->operation('or', @_) },
  fallback => 1;

has 'elements';

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

  my $elements = $self->decompose_elements;
  
  my $dim_values = $self->dim_as_array->values;
  
  my $dim_length = @$dim_values;
  my $dim_num = $dim_length - 1;
  my $poss = [];
  
  my $str;
  if (@$elements) {
    if ($dim_length == 1) {
      my $names = $self->names->values;
      if (@$names) {
        $str .= join(' ', @$names) . "\n";
      }
      my @parts = map { $self->_element_to_string($_, $is_character, $is_factor) } @$elements;
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
          my $part = $self->element($d1, $d2);
          push @parts, $self->_element_to_string($part, $is_character, $is_factor);
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
                my $part = $self->element($d1, $d2, @$poss);
                push @parts, $self->_element_to_string($part, $is_character, $is_factor);
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

sub is_finite {
  my $x1 = Rstats::Func::to_c(shift);
  
  my @a2_elements = map { $_->is_finite } @{$x1->decompose_elements};
  my $x2 = Rstats::Func::c(\@a2_elements);
  $x1->_copy_attrs_to($x2);
  $x2->mode('logical');
  
  return $x2;
}

sub is_infinite {
  my $x1 = Rstats::Func::to_c(shift);
  
  my @a2_elements = map { $_->is_infinite } @{$x1->decompose_elements};
  my $x2 = Rstats::Func::c(\@a2_elements);
  $x1->_copy_attrs_to($x2);
  $x2->mode('logical');
  
  return $x2;
}

sub is_nan {
  my $x1 = Rstats::Func::to_c(shift);
  
  my @a2_elements = map { $_->is_nan } @{$x1->decompose_elements};
  my $x2 = c(\@a2_elements);
  $x1->_copy_attrs_to($x2);
  $x2->mode('logical');
  
  return $x2;
}

sub is_null {
  my $x1 = Rstats::Func::to_c(shift);
  
  my @a2_elements = [!$x1->length_value ? Rstats::ElementsFunc::TRUE() : Rstats::ElementsFunc::FALSE()];
  my $x2 = Rstats::Func::c(\@a2_elements);
  $x1->_copy_attrs_to($x1);
  $x2->mode('logical');
  
  return $x2;
}

sub getin { shift->get(@_) }

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
  
  my $self_elements = $self->decompose_elements;
  my @a2_elements
    = map { defined $self_elements->[$_] ? $self_elements->[$_] : Rstats::ElementsFunc::NA() }
      @$poss;
  
  # array
  my $x2 = Rstats::Func::array(\@a2_elements, $x2_dim);
  
  # Copy attributes
  $self->_copy_attrs_to($x2, {new_indexes => $new_indexes, exclude => ['dim']});

  # level drop
  if ($level_drop) {
    $x2 = Rstats::Func::factor($x2->as_character);
  }
  
  return $x2;
}

sub _levels_h {
  my $self = shift;
  
  my $levels_h = {};
  my $levels = $self->levels->values;
  for (my $i = 1; $i <= @$levels; $i++) {
    $levels_h->{$levels->[$i - 1]} = Rstats::ElementsFunc::integer($i);
  }
  
  return $levels_h;
}

sub set {
  my $self = shift;
  my $x2 = Rstats::Func::to_c(shift);
  
  my $at = $self->at;
  my $_indexs = ref $at eq 'ARRAY' ? $at : [$at];
  
  # Upgrade mode if type is different
  if ($self->{type} ne $x2->{type}) {
    my $self_tmp;
    ($self_tmp, $x2) = Rstats::Func::upgrade_type($self, $x2);
    $self_tmp->_copy_attrs_to($self);
    $self->elements($self_tmp->elements);
  }
  
  my ($poss, $x2_dim) = Rstats::Util::parse_index($self, 0, @$_indexs);
  
  my $self_elements = $self->decompose_elements;

  if ($self->is_factor) {
    $x2 = $x2->as_character unless $x2->is_character;
    my $x2_elements = $x2->decompose_elements;
    my $levels_h = $self->_levels_h;
    for (my $i = 0; $i < @$poss; $i++) {
      my $pos = $poss->[$i];
      my $element = $x2_elements->[(($i + 1) % @$poss) - 1];
      if ($element->is_na) {
        $self_elements->[$pos] = Rstats::ElementsFunc::NA();
      }
      else {
        my $value = $element->to_string;
        if ($levels_h->{$value}) {
          $self_elements->[$pos] = $levels_h->{$value};
        }
        else {
          carp "invalid factor level, NA generated";
          $self_elements->[$pos] = Rstats::ElementsFunc::NA();
        }
      }
    }
  }
  else {
    my $x2_elements = $x2->decompose_elements;
    for (my $i = 0; $i < @$poss; $i++) {
      my $pos = $poss->[$i];
      $self_elements->[$pos] = $x2_elements->[(($i + 1) % @$poss) - 1];
    }
  }
  
  $self->elements(Rstats::Elements->compose($self->{type}, $self_elements));
  
  return $self;
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
  
  my $element = $self->element;
  
  return !!$element;
}

sub element {
  my $self = shift;

  my $dim_values = $self->dim_as_array->values;
  
  my $self_elements = $self->decompose_elements;
  if (@_) {
    if (@$dim_values == 1) {
      return $self_elements->[$_[0] - 1];
    }
    elsif (@$dim_values == 2) {
      return $self_elements->[($_[0] + $dim_values->[0] * ($_[1] - 1)) - 1];
    }
    else {
      return $self->get(@_)->decompose_elements->[0];
    }
  }
  else {
    return $self_elements->[0];
  }
}

sub inner_product {
  my ($self, $data, $reverse) = @_;
  
  # fix postion
  my ($x1, $x2) = $self->_fix_position($data, $reverse);
  
  return Rstats::Func::inner_product($x1, $x2);
}

sub negation { Rstats::Func::negation(@_) }

sub operation {
  my ($self, $op, $data, $reverse) = @_;
  
  # fix postion
  my ($x1, $x2) = $self->_fix_position($data, $reverse);
  
  return Rstats::Func::operation($op, $x1, $x2);
}

sub _fix_position {
  my ($self, $data, $reverse) = @_;
  
  my $x1;
  my $x2;
  if (ref $data eq 'Rstats::Container::Array') {
    $x1 = $self;
    $x2 = $data;
  }
  else {
    if ($reverse) {
      $x1 = Rstats::Func::c($data);
      $x2 = $self;
    }
    else {
      $x1 = $self;
      $x2 = Rstats::Func::c($data);
    }
  }
  
  return ($x1, $x2);
}

1;

=head1 NAME

Rstats::Container::Array - Array
