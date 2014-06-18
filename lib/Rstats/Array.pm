package Rstats::Array;
use Object::Simple -base;
use Carp 'croak';
use List::Util;
use Rstats;

use overload
  bool => sub {1},
  '+' => \&add,
  '-' => \&subtract,
  '*' => \&multiply,
  '/' => \&divide,
  'neg' => \&negation,
  '**' => \&raise,
  '""' => \&to_string,
  fallback => 1;

has 'values';
has 'type';

my $r = Rstats->new;

sub new {
  my $self = shift->SUPER::new(@_);
  
  $self->{values} ||= [];
  $self->{type} ||= 'array';
  
  return $self;
}

sub get {
  my ($self, $indexes_tmp) = @_;
  
  croak "get need one values" unless defined $indexes_tmp;
  return $self->new(values => [$self->{values}[$indexes_tmp - 1]])
    if !ref $indexes_tmp && $indexes_tmp > 0;
  
  my $indexes;
  if (ref $indexes_tmp eq 'CODE') {
    my $values1 = $self->values;
    my @values2 = grep { $indexes_tmp->(); } @$values1;
    return $self->new(values => \@values2);
  }
  elsif (ref $indexes_tmp eq 'ARRAY') {
    $indexes = $indexes_tmp;
  }
  elsif (ref $indexes_tmp eq 'Rstats::Array') {
    $indexes = $indexes_tmp->{values};
  }
  else {
    $indexes = [$indexes_tmp];
  }
  
  # Check index
  my $plus_count;
  my $minus_count;
  for my $index (@$indexes) {
    $plus_count++ if $index > 0;
    $minus_count++ if $index < 0;
    croak "You can't use both plus and minus index"
      if $plus_count && $minus_count;
    croak "0 is invalid index" if $index == 0;
  }
  
  my $values1 = $self->values;
  my @values2;
  if ($plus_count) {
    @values2 = map { $values1->[$_ - 1] } @$indexes;
  }
  else {
    my $indexes_h = {map { -$_ - 1 => 1 } @$indexes};
    for (my $i = 0; $i < @$values1; $i++) {
      push @values2, $values1->[$i] unless $indexes_h->{$i};
    }
  }
  
  return $self->new(values => \@values2);
}

sub get_b {
  my ($self, $booles_tmp) = @_;

  croak "get need one values" unless defined $booles_tmp;
  return $self->new(values => [$self->{values}[$booles_tmp - 1]])
    if !ref $booles_tmp && $booles_tmp > 0;
  
  my $booles;
  if (ref $booles_tmp eq 'ARRAY') {
    $booles = $booles_tmp;
  }
  elsif (ref $booles_tmp eq 'Rstats::Array') {
    $booles = $booles_tmp->{values};
  }
  else {
    $booles = [$booles_tmp];
  }
  
  my $values1 = $self->values;
  my @values2;
  for (my $i = 0; $i < @$booles; $i++) {
    push @values2, $values1->[$i] if $booles->[$i];
  }
  
  return $self->new(values => \@values2);
}

sub get_s {
  my ($self, $names) = @_;
  
  my $array2 = $names;
  my $array1_names = $r->names($self)->values;
  my $array2_names = $array2->values;
  
  my $array3_values = [];
  for my $array2_name (@$array2_names) {
    my $i = 0;
    for my $array1_name (@$array1_names) {
      if ($array2_name eq $array1_name) {
        push @$array3_values, $self->values->[$i];
        last;
      }
      $i++;
    }
  }
  
  my $array3 = $self->new(values => $array3_values);
  
  return $array3;
}

sub set {
  my ($self, $idx, $value) = @_;
  
  $self->{values}[$idx - 1] = $value;
  
  return $self;  
}

sub to_string {
  my $self = shift;
  
  my $str = '';
  my $names_v = $r->names($self);
  if ($names_v) {
    $str .= join(' ', @{$names_v->values}) . "\n";
  }
  
  my $values = $self->values;
  if (@$values) {
    $str .= '[1] ' . join(' ', @$values) . "\n";
  }
  
  return $str;
}

sub negation {
  my $self = shift;
  
  my $v2 = $self->new;
  my $v1_values = $self->values;
  my $v2_values = $v2->values;
  $v2_values->[$_] = -$v1_values->[$_] for (0 .. @$v1_values - 1);
  
  return $v2;
}

sub add { shift->_operation('+', @_) }
sub subtract { shift->_operation('-', @_) }
sub multiply { shift->_operation('*', @_) }
sub divide { shift->_operation('/', @_) }
sub raise { shift->_operation('**', @_) }

my $culcs = {};
my @ops = qw#+ - * / **#;
for my $op (@ops) {
   my $code = <<"EOS";
sub {
  my (\$v1_values, \$v2_values) = \@_;
   
  my \$v1_length = \@{\$v1_values};
  my \$v2_length = \@{\$v2_values};
  my \$longer_length = \$v1_length > \$v2_length ? \$v1_length : \$v2_length;

  my \@v3_values = map {
    \$v1_values->[\$_ % \$v1_length] $op \$v2_values->[\$_ % \$v2_length]
    } (0 .. \$longer_length - 1);
  
  return \@v3_values;
}
EOS
  
  $culcs->{$op} = eval $code;

  croak $@ if $@;
}

sub _operation {
  my ($self, $op, $data, $reverse) = @_;

  my $v1_values;
  my $v2_values;
  if (ref $data eq 'Rstats::Array') {
    $v1_values = $self->values;
    my $v2 = $data;
    $v2_values = $v2->values;
  }
  else {
    if ($reverse) {
      $v1_values = [$data];
      $v2_values = $self->values;
    }
    else {
      $v1_values = $self->values;
      $v2_values = [$data];
    }
  }

  my @v3_values = $culcs->{$op}->($v1_values, $v2_values);
  
  return $self->new(values => \@v3_values);
}

sub is_array {
  my $self = shift;
  
  return $self->{type} eq 'array';
}

sub is_vector {
  my $self = shift;
  
  return $self->{type} eq 'vector';
}

sub is_matrix {
  my $self = shift;
  
  return $self->{type} eq 'matrix';
}

sub as_matrix {
  my $self = shift;
  
  $self->{type} = 'matrix';
  
  return $self;
}

sub as_array {
  my $self = shift;
  
  $self->{type} = 'array';
  
  return $self;
}

sub as_vector {
  my $self = shift;
  
  $self->{type} = 'vector';
  
  return $self;
}

1;

