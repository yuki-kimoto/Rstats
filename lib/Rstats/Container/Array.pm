package Rstats::Container::Array;
use Rstats::Container -base;

use Rstats::ElementFunc;
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
  fallback => 1;

my %types_h = map { $_ => 1 } qw/character complex numeric double integer logical/;

sub to_string {
  my $a1 = shift;

  my $elements = $a1->elements;
  
  my $dim_values = $a1->dim_as_array->values;
  
  my $dim_length = @$dim_values;
  my $dim_num = $dim_length - 1;
  my $positions = [];
  
  my $str;
  if (@$elements) {
    if ($dim_length == 1) {
      my $names = $a1->names->values;
      if (@$names) {
        $str .= join(' ', @$names) . "\n";
      }
      my @parts = map { "$_" } @$elements;
      $str .= '[1] ' . join(' ', @parts) . "\n";
    }
    elsif ($dim_length == 2) {
      $str .= '     ';
      
      my $colnames = $a1->colnames->values;
      if (@$colnames) {
        $str .= join(' ', @$colnames) . "\n";
      }
      else {
        for my $d2 (1 .. $dim_values->[1]) {
          $str .= $d2 == $dim_values->[1] ? "[,$d2]\n" : "[,$d2] ";
        }
      }
      
      my $rownames = $a1->rownames->values;
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
          push @parts, element($a1, $d1, $d2)->to_string;
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
                push @parts, element($a1, $d1, $d2, @$positions)->to_string;
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

sub typeof {
  my $a1 = shift;
  
  my $type = $a1->{type};
  my $a2_elements = defined $type ? $type : "NULL";
  my $a2 = Rstats::Func::c($a2_elements);
  
  return $a2;
}

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

    return Rstats::Func::c($mode);
  }
}

sub is_finite {
  my $_a1 = shift;

  my $a1 = Rstats::Func::to_array($_a1);
  
  my @a2_elements = map {
    !ref $_ || ref $_ eq 'Rstats::Type::Complex' || ref $_ eq 'Rstats::Logical' 
      ? Rstats::ElementFunc::TRUE()
      : Rstats::ElementFunc::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::Func::array(\@a2_elements);
  $a2->mode('logical');
  
  return $a2;
}

sub is_infinite {
  my $_a1 = shift;
  
  my $a1 = Rstats::Func::to_array($_a1);
  
  my @a2_elements = map {
    ref $_ eq 'Rstats::Inf' ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::Func::c(\@a2_elements);
  $a2->mode('logical');
  
  return $a2;
}

sub is_na {
  my $_a1 = shift;
  
  my $a1 = Rstats::Func::to_array($_a1);
  
  my @a2_elements = map {
    ref $_ eq  'Rstats::Type::NA' ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::Func::array(\@a2_elements);
  $a2->mode('logical');
  
  return $a2;
}

sub is_nan {
  my $_a1 = shift;
  
  my $a1 = Rstats::Func::to_array($_a1);
  
  my @a2_elements = map {
    ref $_ eq  'Rstats::NaN' ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE()
  } @{$a1->elements};
  my $a2 = Rstats::Func::array(\@a2_elements);
  $a2->mode('logical');
  
  return $a2;
}

sub is_null {
  my $_a1 = shift;
  
  my $a1 = Rstats::Func::to_array($_a1);
  
  my @a2_elements = [!@{$a1->elements} ? Rstats::ElementFunc::TRUE() : Rstats::ElementFunc::FALSE()];
  my $a2 = Rstats::Func::array(\@a2_elements);
  $a2->mode('logical');
  
  return $a2;
}

sub at {
  my $self = shift;
  
  if (@_) {
    $self->{at} = [@_];
    
    return $self;
  }
  
  return $self->{at};
}

sub get {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my $drop = $opt->{drop};
  $drop = 1 unless defined $drop;
  
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
  
  if (ref $_indexs->[0] eq 'CODE') {
    my @elements2 = grep { $_indexs->[0]->() } @{$self->values};
    return Rstats::Func::c(\@elements2);
  }
  
  my ($positions, $a2_dim) = Rstats::Util::parse_index($self, $drop, @$_indexs);
  
  my @a2_elements = map { $self->elements->[$_ - 1] ? $self->elements->[$_ - 1] : Rstats::ElementFunc::NA() } @$positions;
  
  return Rstats::Func::array(\@a2_elements, $a2_dim);
}

sub set {
  my ($self, $_a2) = @_;

  my $at = $self->at;
  my $_indexs = ref $at eq 'ARRAY' ? $at : [$at];
  
  my $a2 = Rstats::Func::to_array($_a2);
  
  my ($positions, $a2_dim) = Rstats::Util::parse_index($self, 0, @$_indexs);
  
  my $self_elements = $self->elements;
  my $a2_elements = $a2->elements;
  for (my $i = 0; $i < @$positions; $i++) {
    my $pos = $positions->[$i];
    $self_elements->[$pos - 1] = $a2_elements->[(($i + 1) % @$positions) - 1];
  }
  
  return $self;
}

sub dim_as_array {
  my $a1 = shift;
  
  if (@{dim($a1)->elements}) {
    return dim($a1);
  }
  else {
    my $length = @{$a1->elements};
    return Rstats::Func::c($length);
  }
}

sub dim {
  my $a1 = shift;
  
  if (@_) {
    my $a_dim = Rstats::Func::to_array($_[0]);
    my $a1_length = @{$a1->elements};
    my $a1_lenght_by_dim = 1;
    $a1_lenght_by_dim *= $_ for @{$a_dim->values};
    
    if ($a1_length != $a1_lenght_by_dim) {
      croak "dims [product $a1_lenght_by_dim] do not match the length of object [$a1_length]";
    }
  
    $a1->{dim} = $a_dim->elements;
    
    return $a1;
  }
  else {
    return Rstats::Func::c($a1->{dim});
  }
}

sub clone_without_elements {
  my ($a1, %opt) = @_;
  
  my $a2 = Rstats::Container::Array->new;
  $a2->{type} = $a1->{type};
  $a2->{names} = [@{$a1->{names} || []}];
  $a2->{dimnames} = $a1->{dimnames};

  $a2->{dim} = [@{$a1->{dim} || []}];
  $a2->{elements} = $opt{elements} ? $opt{elements} : [];
  
  return $a2;
}

sub is_array { Rstats::Func::TRUE() }

sub is_list { Rstats::Func::FALSE() }

sub is_data_frame { Rstats::Func::FALSE() }

sub length {
  my $self = shift;
  
  my $length = @{$self->elements};
  
  return Rstats::Func::c($length);
}

sub type { Rstats::Func::type(@_) }

sub bool {
  my $self = shift;
  
  my $length = @{$self->elements};
  if ($length == 0) {
    croak 'Error in if (a) { : argument is of length zero';
  }
  elsif ($length > 1) {
    carp 'In if (a) { : the condition has length > 1 and only the first element will be used';
  }
  
  my $element = element($self);
  
  return !!$element;
}

sub element { Rstats::Func::element(@_) }

sub inner_product {
  my ($self, $data, $reverse) = @_;
  
  # fix postion
  my ($a1, $a2) = $self->_fix_position($data, $reverse);
  
  return Rstats::Func::inner_product($a1, $a2);
}

sub negation { Rstats::Func::negation(@_) }

sub operation {
  my ($self, $op, $data, $reverse) = @_;
  
  # fix postion
  my ($a1, $a2) = $self->_fix_position($data, $reverse);
  
  return Rstats::Func::operation($op, $a1, $a2);
}

sub _fix_position {
  my ($self, $data, $reverse) = @_;
  
  my $a1;
  my $a2;
  if (ref $data eq 'Rstats::Container::Array') {
    $a1 = $self;
    $a2 = $data;
  }
  else {
    if ($reverse) {
      $a1 = Rstats::Func::c($data);
      $a2 = $self;
    }
    else {
      $a1 = $self;
      $a2 = Rstats::Func::c($data);
    }
  }
  
  return ($a1, $a2);
}

1;
