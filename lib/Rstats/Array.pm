package Rstats::Array;
use Object::Simple -base;

use Carp 'croak', 'carp';
use List::Util;
use Rstats;
use B;
use Scalar::Util 'looks_like_number';
use Rstats::Type::NA;
use Rstats::Type::Logical;
use Rstats::Type::Character;

our @CARP_NOT = ('Rstats');

my %types_h = map { $_ => 1 } qw/character complex numeric double integer logical/;

use overload
  bool => sub { shift->_operation('bool', @_) },
  '+' => sub { shift->_operation('add', @_) },
  '-' => sub { shift->_operation('subtract', @_) },
  '*' => sub { shift->_operation('multiply', @_) },
  '/' => sub { shift->_operation('divide', @_) },
  '%' => sub { shift->_operation('reminder', @_) },
  'neg' => sub { shift->_operation('negation', @_) },
  '**' => sub { shift->_operation('raise', @_) },
  '<' => sub { shift->_operation('less_than', @_) },
  '<=' => sub { shift->_operation('less_than_or_equal', @_) },
  '>' => sub { shift->_operation('more_than', @_) },
  '>=' => sub { shift->_operation('more_than_or_equal', @_) },
  '==' => sub { shift->_operation('equal', @_) },
  '!=' => sub { shift->_operation('not_equal', @_) },
  '""' => sub { shift->_operation('to_string', @_) },
  fallback => 1;

has 'contents';

sub values {
  my $self = shift;
  
  my @values = map { Rstats::Util::value($_) } @{$self->contents};
  
  return \@values;
}

sub value { Rstats::Util::value(shift->content(@_)) }

sub typeof {
  my $self = shift;
  
  my $type = $self->{type};
  my $a1_contents = defined $type ? $type : "NULL";
  my $a1 = Rstats::Array->c([$a1_contents]);
  
  return $a1;
}

sub mode {
  my $self = shift;
  
  if (@_) {
    my $type = $_[0];
    croak qq/Error in eval(expr, envir, enclos) : could not find function "as_$type"/
      unless $types_h{$type};
    
    if ($type eq 'numeric') {
      $self->{type} = 'double';
    }
    else {
      $self->{type} = $type;
    }
    
    return $self;
  }
  else {
    my $type = $self->{type};
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

    my $a1 = Rstats::Array->c([$mode]);

    return $a1;
  }
}

sub bool {
  my $self = shift;
  
  my $length = @{$self->contents};
  if ($length == 0) {
    croak 'Error in if (a) { : argument is of length zero';
  }
  elsif ($length > 1) {
    carp 'In if (a) { : the condition has length > 1 and only the first element will be used';
  }
  
  my $content = $self->content;
  my $a1 = Rstats::Array->array([$content]);
  my $a2 = $a1->as_logical;
  my $a2_content = $a2->content;
  
  return $a2_content ? 1 : 0;
}

sub clone_without_contents {
  my ($self, %opt) = @_;
  
  my $array = Rstats::Array->new;
  $array->{type} = $self->{type};
  $array->{names} = [@{$self->{names} || []}];
  $array->{rownames} = [@{$self->{rownames} || []}];
  $array->{colnames} = [@{$self->{colnames} || []}];
  $array->{dim} = [@{$self->{dim} || []}];
  $array->{contents} = $opt{contents} ? $opt{contents} : [];
  
  return $array;
}

sub row {
  my $self = shift;
  
  my $nrow = $self->nrow->content;
  my $ncol = $self->ncol->content;
  
  my @contents = (1 .. $nrow) x $ncol;
  
  return Rstats::Array->array(\@contents, [$nrow, $ncol]);
}

sub col {
  my $self = shift;
  
  my $nrow = $self->nrow->content;
  my $ncol = $self->ncol->content;
  
  my @contents;
  for my $col (1 .. $ncol) {
    push @contents, ($col) x $nrow;
  }
  
  return Rstats::Array->array(\@contents, [$nrow, $ncol]);
}

sub nrow {
  my $self = shift;
  
  return Rstats::Array->array($self->dim->contents->[0]);
}

sub ncol {
  my $self = shift;
  
  return Rstats::Array->array($self->dim->contents->[1]);
}

sub names {
  my $self = shift;
  
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
      $names = $_names->contents;
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
    $self->{names} = $names;
  }
  else {
    $self->{names} = [] unless exists $self->{names};
    return Rstats::Array->array($self->{names});
  }
}

sub colnames {
  my $self = shift;
  
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
      $colnames = $_colnames->contents;
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
    $self->{colnames} = $colnames;
  }
  else {
    $self->{colnames} = [] unless exists $self->{colnames};
    return Rstats::Array->array($self->{colnames});
  }
}

sub rownames {
  my $self = shift;
  
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
      $rownames = $_rownames->contents;
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
    $self->{rownames} = $rownames;
  }
  else {
    $self->{rownames} = [] unless exists $self->{rownames};
    return Rstats::Array->array($self->{rownames});
  }
}

sub dim {
  my $self = shift;
  
  if (@_) {
    my $a1 = $_[0];
    if (ref $a1 eq 'Rstats::Array') {
      $self->{dim} = $a1->contents;
    }
    elsif (ref $a1 eq 'ARRAY') {
      $self->{dim} = $a1;
    }
    elsif(!ref $a1) {
      $self->{dim} = [$a1];
    }
    else {
      croak "Invalid contents is passed to dim argument";
    }
  }
  else {
    $self->{dim} = [] unless exists $self->{dim};
    return Rstats::Array->new(contents => $self->{dim});
  }
}

sub length {
  my $self = shift;
  
  my $length = @{$self->contents};
  
  return $length;
}

sub seq {
  my $self = shift;
  
  # Option
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  # Along
  my $along = $opt->{along};
  
  if ($along) {
    my $length = $along->length;
    return $self->seq([1,$length]);
  }
  else {
    my $from_to = shift;
    my $from;
    my $to;
    if (ref $from_to eq 'ARRAY') {
      $from = $from_to->[0];
      $to = $from_to->[1];
    }
    elsif (defined $from_to) {
      $from = 1;
      $to = $from_to;
    }
    
    # From
    $from = $opt->{from} unless defined $from;
    croak "seq function need from option" unless defined $from;
    
    # To
    $to = $opt->{to} unless defined $to;

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
    
    my $contents = [];
    if ($to == $from) {
      $contents->[0] = $to;
    }
    elsif ($to > $from) {
      if ($by < 0) {
        croak "by option is invalid number(seq function)";
      }
      
      my $content = $from;
      while ($content <= $to) {
        push @$contents, $content;
        $content += $by;
      }
    }
    else {
      if ($by > 0) {
        croak "by option is invalid number(seq function)";
      }
      
      my $content = $from;
      while ($content >= $to) {
        push @$contents, $content;
        $content += $by;
      }
    }
    
    my $a1 = $self->array($contents);
  }
}

sub _parse_seq_str {
  my ($self, $seq_str) = @_;
  
  my $by;
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
  
  my $array = $self->seq({from => $from, to => $to, by => $by});
  
  return $array;
}

sub _is_numeric {
  my ($self, $content) = @_;
  
  return unless defined $content;
  
  return B::svref_2object(\$content)->FLAGS & (B::SVp_IOK | B::SVp_NOK) 
        && 0 + $content eq $content
        && $content * 0 == 0
}

sub array {
  my $self = shift;
  
  # Arguments
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  my ($a1, $_dim) = @_;
  $_dim = $opt->{dim} unless defined $_dim;
  
  # Array
  my $array = Rstats::Array->new;
  
  # Value
  my $contents = [];
  if (defined $a1) {
    if (ref $a1 eq 'ARRAY') {
      for my $a (@$a1) {
        if (ref $a eq 'ARRAY') {
          push @$contents, @$a;
        }
        elsif (ref $a eq 'Rstats::Array') {
          push @$contents, @{$a->contents};
        }
        else {
          push @$contents, $a;
        }
      }
    }
    elsif (ref $a1 eq 'Rstats::Array') {
      $contents = $a1->contents;
    }
    elsif(!ref $a1) {
      $contents = $self->_parse_seq_str($a1)->contents;
    }
  }
  else {
    croak "Invalid first argument";
  }
  
  # Dimention
  my $dim;
  if (defined $_dim) {
    if (ref $_dim eq 'Rstats::Array') {
      $dim = $_dim->contents;
    }
    elsif (ref $_dim eq 'ARRAY') {
      $dim = $_dim;
    }
    elsif(!ref $_dim) {
      $dim = [$_dim];
    }
  }
  else {
    $dim = [scalar @$contents]
  }
  $array->dim($dim);
  
  # Check contents
  my $mode_h = {};
  for my $content (@$contents) {
    if (!defined $content) {
      croak "undef is invalid content";
    }
    elsif (ref $content eq 'Rstats::Type::Character') {
      $mode_h->{character}++;
    }
    elsif (ref $content eq 'Rstats::Type::Complex') {
      $mode_h->{complex}++;
    }
    elsif (ref $content eq 'Rstats::Type::Double') {
      $mode_h->{numeric}++;
    }
    elsif (ref $content eq 'Rstats::Type::Integer') {
      $content = Rstats::Util::double($content->content);
      $mode_h->{numeric}++;
    }
    elsif (ref $content eq 'Rstats::Type::Logical') {
      $mode_h->{logical}++;
    }
    elsif (Rstats::Util::is_perl_number($content)) {
      $content = Rstats::Util::double($content);
      $mode_h->{numeric}++;
    }
    else {
      $content = Rstats::Util::character("$content");
      $mode_h->{character}++;
    }
  }

  # Upgrade contents and type
  my @modes = keys %$mode_h;
  if (@modes > 1) {
    if ($mode_h->{character}) {
      my $a1 = Rstats::Array->new(contents => $contents)->as_character;
      $contents = $a1->contents;
      $array->mode('character');
    }
    elsif ($mode_h->{complex}) {
      my $a1 = Rstats::Array->new(contents => $contents)->as_complex;
      $contents = $a1->contents;
      $array->mode('complex');
    }
    elsif ($mode_h->{numeric}) {
      my $a1 = Rstats::Array->new(contents => $contents)->as_numeric;
      $contents = $a1->contents;
      $array->mode('numeric');
    }
    elsif ($mode_h->{logical}) {
      my $a1 = Rstats::Array->new(contents => $contents)->as_logical;
      $contents = $a1->contents;
      $array->mode('logical');
    }
  }
  else {
    $array->mode($modes[0] || 'logical');
  }
  
  # Fix contents
  my $max_length = 1;
  $max_length *= $_ for @{$array->_real_dim_contents || [scalar @$contents]};
  if (@$contents > $max_length) {
    @$contents = splice @$contents, 0, $max_length;
  }
  elsif (@$contents < $max_length) {
    my $repeat_count = int($max_length / @$contents) + 1;
    @$contents = (@$contents) x $repeat_count;
    @$contents = splice @$contents, 0, $max_length;
  }
  $array->contents($contents);
  
  return $array;
}

sub _real_dim_contents {
  my $self = shift;
  
  my $dim = $self->dim;
  my $dim_contents = $dim->contents;
  if (@$dim_contents) {
    return $dim_contents;
  }
  else {
    if (defined $self->contents) {
      my $length = @{$self->contents};
      return [$length];
    }
    else {
      return;
    }
  }
}

sub at {
  my $self = shift;
  
  if (@_) {
    $self->{at} = [@_];
    
    return $self;
  }
  
  return $self->{at};
}

sub content {
  my $self = shift;
  
  my $dim_contents = $self->_real_dim_contents;
  
  if (@_) {
    if (@$dim_contents == 1) {
      return $self->{contents}[$_[0] - 1];
    }
    elsif (@$dim_contents == 2) {
      return $self->{contents}[($_[0] + $dim_contents->[0] * ($_[1] - 1)) - 1];
    }
    else {
      return $self->get(@_)->content;
    }
  }
  else {
    return $self->{contents}[0];
  }
}

sub is_numeric {
  my $self = shift;
  
  my $is = ($self->{type} || '') eq 'numeric' ? 1 : 0;
  
  return $self->c([$is]);
}

sub is_integer {
  my $self = shift;
  
  my $is = ($self->{type} || '') eq 'integer' ? 1 : 0;
  
  return $self->c([$is]);
}

sub is_complex {
  my $self = shift;
  
  my $is = ($self->{type} || '') eq 'complex' ? 1 : 0;
  
  return $self->c([$is]);
}

sub is_character {
  my $self = shift;
  
  my $is = ($self->{type} || '') eq 'character' ? 1 : 0;
  
  return $self->c([$is]);
}

sub is_logical {
  my $self = shift;
  
  my $is = ($self->{type} || '') eq 'logical' ? 1 : 0;
  
  return $self->c([$is]);
}

sub _looks_like_complex {
  my ($self, $content) = @_;
  
  return if !defined $content || !CORE::length $content;
  $content =~ s/^ +//;
  $content =~ s/ +$//;
  
  my $re;
  my $im;
  
  if ($content =~ /^([\+\-]?[^\+\-]+)i$/) {
    $re = 0;
    $im = $1;
  }
  elsif($content =~ /^([\+\-]?[^\+\-]+)([\+\-][^\+\-i]+)i?$/) {
    $re = $1;
    $im = $2;
  }
  else {
    return;
  }
  
  if (looks_like_number $re && looks_like_number $im) {
    return ($re, $im);
  }
  else {
    return;
  }
}

sub _looks_like_number {
  my ($self, $content) = @_;
  
  return if !defined $content || !CORE::length $content;
  $content =~ s/^ +//;
  $content =~ s/ +$//;
  
  if (looks_like_number $content) {
    return ($content);
  }
  else {
    return;
  }
}

sub _as {
  my ($self, $mode) = @_;
  
  if ($mode eq 'character') {
    return $self->as_character;
  }
  elsif ($mode eq 'complex') {
    return $self->as_complex;
  }
  elsif ($mode eq 'numeric') {
    return $self->as_numeric;
  }
  elsif ($mode eq 'integer') {
    return $self->as_integer;
  }
  elsif ($mode eq 'logical') {
    return $self->as_logical;
  }
  else {
    croak "Invalid mode is passed";
  }
}

sub as_complex {
  my $self = shift;
  
  my $a1 = $self;
  my $a1_contents = $a1->contents;
  my $a2 = $self->clone_without_contents;
  my @a2_contents = map {
    if (ref $_ eq 'Rstats::Type::NA') {
      $_;
    }
    elsif (ref $_ eq 'Rstats::Type::Character') {
      if (my @nums = $self->_looks_like_complex($_)) {
        Rstats::Util::complex(@nums);
      }
      else {
        carp 'NAs introduced by coercion';
        Rstats::Util::NA;
      }
    }
    elsif (ref $_ eq 'Rstats::Type::Complex') {
      $_;
    }
    elsif (ref $_ eq 'Rstats::Type::Double') {
      if (Rstats::Util::is_nan($_)) {
        Rstats::Util::NA;
      }
      else {
        Rstats::Util::complex($_, 0);
      }
    }
    elsif (ref $_ eq 'Rstats::Type::Integer') {
      Rstats::Util::complex($_, 0);
    }
    elsif (ref $_ eq 'Rstats::Type::Logical') {
      Rstats::Util::complex($_->content ? 1 : 0, 0);
    }
    else {
      croak "unexpected type";
    }
  } @$a1_contents;
  $a2->contents(\@a2_contents);
  $a2->{type} = 'complex';

  return $a2;
}

sub as_numeric {
  my $self = shift;
  
  my $a1 = $self;
  my $a1_contents = $a1->contents;
  my $a2 = $self->clone_without_contents;
  my @a2_contents = map {
    if (ref $_ eq 'Rstats::Type::NA') {
      $_;
    }
    elsif (ref $_ eq 'Rstats::Type::Character') {
      if ($self->_looks_like_number($_)) {
        Rstats::Util::double($_ + 0);
      }
      else {
        carp 'NAs introduced by coercion';
        Rstats::Util::NA;
      }
    }
    elsif (ref $_ eq 'Rstats::Type::Complex') {
      carp "imaginary parts discarded in coercion";
      Rstats::Util::double($_->re);
    }
    elsif (ref $_ eq 'Rstats::Type::Double') {
      $_;
    }
    elsif (ref $_ eq 'Rstats::Type::Integer') {
      Rstats::Util::double($_->content);
    }
    elsif (ref $_ eq 'Rstats::Type::Logical') {
      Rstats::Util::double($_ ? 1 : 0);
    }
    else {
      croak "unexpected type";
    }
  } @$a1_contents;
  $a2->contents(\@a2_contents);
  $a2->{type} = 'numeric';

  return $a2;
}

sub as_integer {
  my $self = shift;
  
  my $a1 = $self;
  my $a1_contents = $a1->contents;
  my $a2 = $self->clone_without_contents;
  my @a2_contents = map {
    if (ref $_ eq 'Rstats::Type::NA') {
      $_;
    }
    elsif (ref $_ eq 'Rstats::Type::Character') {
      if ($self->_looks_like_number($_)) {
        Rstats::Util::integer(int($_ + 0));
      }
      else {
        carp 'NAs introduced by coercion';
        Rstats::Util::NA;
      }
    }
    elsif (ref $_ eq 'Rstats::Type::Complex') {
      carp "imaginary parts discarded in coercion";
      Rstats::Util::integer(int($_->re));
    }
    elsif (ref $_ eq 'Rstats::Type::Double') {
      if (Rstats::Util::is_nan($_) || Rstats::Util::is_infinite($_)) {
        Rstats::Util::NA;
      }
      else {
        $_ == 0 ? Rstats::Util::FALSE : Rstats::Util::TRUE;
      }
    }
    elsif (ref $_ eq 'Rstats::Type::Integer') {
      $_; 
    }
    elsif (ref $_ eq 'Rstats::Type::Logical') {
      Rstats::Util::integer($_ ? 1 : 0);
    }
    else {
      croak "unexpected type";
    }
  } @$a1_contents;
  $a2->contents(\@a2_contents);
  $a2->{type} = 'integer';

  return $a2;
}

sub as_logical {
  my $self = shift;
  
  my $a1 = $self;
  my $a1_contents = $a1->contents;
  my $a2 = $self->clone_without_contents;
  my @a2_contents = map {
    if (ref $_ eq 'Rstats::Type::NA') {
      $_;
    }
    elsif (ref $_ eq 'Rstats::Type::Character') {
      if ($self->_looks_like_number($_)) {
        $_ ? Rstats::Util::TRUE : Rstats::Util::FALSE;
      }
      else {
        carp 'NAs introduced by coercion';
        Rstats::Util::NA;
      }
    }
    elsif (ref $_ eq 'Rstats::Type::Complex') {
      carp "imaginary parts discarded in coercion";
      my $re = $_->re->content;
      my $im = $_->im->content;
      if (defined $re && $re == 0 && defined $im && $im == 0) {
        Rstats::Util::FALSE;
      }
      else {
        Rstats::Util::TRUE;
      }
    }
    elsif (ref $_ eq 'Rstats::Type::Double') {
      if (Rstats::Util::is_nan($_)) {
        Rstats::Util::NA;
      }
      elsif (Rstats::Util::is_infinite($_)) {
        Rstats::Util::TRUE;
      }
      else {
        $_ == 0 ? Rstats::Util::FALSE : Rstats::Util::TRUE;
      }
    }
    elsif (ref $_ eq 'Rstats::Type::Integer') {
      $_->content == 0 ? Rstats::Util::FALSE : Rstats::Util::TRUE;
    }
    elsif (ref $_ eq 'Rstats::Type::Logical') {
      $_;
    }
    else {
      croak "unexpected type";
    }
  } @$a1_contents;
  $a2->contents(\@a2_contents);
  $a2->{type} = 'logical';

  return $a2;
}

sub as_character {
  my $self = shift;

  my $a1_contents = $self->contents;
  my $a2 = $self->clone_without_contents;
  my @a2_contents = map { Rstats::Util::character("$_") } @$a1_contents;
  $a2->contents(\@a2_contents);
  $a2->{type} = 'character';

  return $a2;
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
    my $a1_contents = $self->contents;
    my @contents2 = grep { $_indexs->[0]->() } @$a1_contents;
    return Rstats::Array->array(\@contents2);
  }

  my ($positions, $a2_dim) = $self->_parse_index($drop, @$_indexs);
  
  my @a2_contents = map { $self->contents->[$_ - 1] } @$positions;
  
  return Rstats::Array->array(\@a2_contents, $a2_dim);
}

sub NULL {
  my $self = shift;
  
  return Rstats::Array->numeric(0);
}

sub numeric {
  my ($self, $num) = @_;
  
  return Rstats::Array->c([(0) x $num]);
}

sub _to_a {
  my ($self, $data) = @_;
  
  croak "undef content is invalid" unless defined $data;
  my $v;
  if (ref $data eq 'ARRAY') {
    $v = Rstats::Array->c($data);
  }
  elsif (ref $data eq 'Rstats::Array') {
    $v = $data;
  }
  elsif (!ref $data) {
    if ($data eq '') {
      $v = Rstats::Array->NULL;
    }
    else {
      $v = Rstats::Array->c($data);
    }
  }
  else {
    croak "Invalid data is passed";
  }
  
  return $v;
}

sub c {
  my ($self, $data) = @_;
  
  my $vector = Rstats::Array->array($data, []);
  
  return $vector;
}

sub set {
  my ($self, $_array) = @_;

  my $at = $self->at;
  my $_indexs = ref $at eq 'ARRAY' ? $at : [$at];

  my $code;
  my $array;
  if (ref $_array eq 'CODE') {
    $code = $_array;
  }
  else {
    $array = Rstats::Array->_to_a($_array);
  }
  
  my ($positions, $a2_dim) = $self->_parse_index(0, @$_indexs);
  
  my $self_contents = $self->contents;
  if ($code) {
    for (my $i = 0; $i < @$positions; $i++) {
      my $pos = $positions->[$i];
      local $_ = $self_contents->[$pos - 1];
      $self_contents->[$pos - 1] = $code->();
    }    
  }
  else {
    my $array_contents = $array->contents;
    for (my $i = 0; $i < @$positions; $i++) {
      my $pos = $positions->[$i];
      $self_contents->[$pos - 1] = $array_contents->[(($i + 1) % @$positions) - 1];
    }
  }
  
  return $self;
}


sub _parse_index {
  my ($self, $drop, @_indexs) = @_;
  
  my $a1_contents = $self->contents;
  my $a1_dim = $self->_real_dim_contents;
  
  my @indexs;
  my @a2_dim;
  
  for (my $i = 0; $i < @$a1_dim; $i++) {
    my $_index = $_indexs[$i];
    
    $_index = '' unless defined $_index;
    
    my $index = Rstats::Array->_to_a($_index);
    my $index_contents = $index->contents;
    if (@$index_contents && !$index->is_character->content && !$index->is_logical->content) {
      my $minus_count = 0;
      for my $index_content (@$index_contents) {
        if ($index_content == 0) {
          croak "0 is invalid index";
        }
        else {
          $minus_count++ if $index_content < 0;
        }
      }
      croak "Can't min minus sign and plus sign"
        if $minus_count > 0 && $minus_count != @$index_contents;
      $index->{_minus} = 1 if $minus_count > 0;
    }
    
    push @indexs, $index;
    
    if (!@{$index->contents}) {
      my $index_content_new = [1 .. $a1_dim->[$i]];
      $index->contents($index_content_new);
    }
    elsif ($index->is_character->content) {
      if ($self->is_vector) {
        my $index_new_contents = [];
        for my $name (@{$index->contents}) {
          my $i = 0;
          my $content;
          for my $self_name (@{$self->names->contents}) {
            if ($name eq $self_name) {
              $content = $self->contents->[$i];
              last;
            }
            $i++;
          }
          croak "Can't find name" unless defined $content;
          push @$index_new_contents, $content;
        }
        $indexs[$i]->contents($index_new_contents);
      }
      elsif ($self->is_matrix) {
        
      }
      else {
        croak "Can't support name except vector and matrix";
      }
    }
    elsif ($index->is_logical->content) {
      my $index_contents_new = [];
      for (my $i = 0; $i < @{$index->contents}; $i++) {
        push @$index_contents_new, $i + 1 if $index->contents->[$i];
      }
      $index->contents($index_contents_new);
    }
    elsif ($index->{_minus}) {
      my $index_content_new = [];
      
      for my $k (1 .. $a1_dim->[$i]) {
        push @$index_content_new, $k unless grep { $_ == -$k } @{$index->contents};
      }
      $index->contents($index_content_new);
      delete $index->{_minus};
    }
    
    my $count = @{$index->contents};
    push @a2_dim, $count unless $count == 1 && $drop;
  }
  @a2_dim = (1) unless @a2_dim;
  
  my $index_contents = [map { $_->contents } @indexs];
  my $ords = $self->_cross_product($index_contents);
  my @positions = map { $self->_pos($_, $a1_dim) } @$ords;
  
  return (\@positions, \@a2_dim);
}

sub _cross_product {
  my ($self, $contents) = @_;

  my @idxs = (0) x @$contents;
  my @idx_idx = 0..(@idxs - 1);
  my @array = map { $_->[0] } @$contents;
  my $result = [];
  
  push @$result, [@array];
  my $end_loop;
  while (1) {
    foreach my $i (@idx_idx) {
      if( $idxs[$i] < @{$contents->[$i]} - 1 ) {
        $array[$i] = $contents->[$i][++$idxs[$i]];
        push @$result, [@array];
        last;
      }
      
      if ($i == $idx_idx[-1]) {
        $end_loop = 1;
        last;
      }
      
      $idxs[$i] = 0;
      $array[$i] = $contents->[$i][0];
    }
    last if $end_loop;
  }
  
  return $result;
}

sub _pos {
  my ($self, $ord, $dim) = @_;
  
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

sub to_string {
  my $self = shift;

  my $contents = $self->contents;
  
  my $dim_contents = $self->_real_dim_contents;
  
  my $dim_length = @$dim_contents;
  my $dim_num = $dim_length - 1;
  my $positions = [];
  
  my $str;
  if (@$contents) {
    if ($dim_length == 1) {
      my $names = $self->names->contents;
      if (@$names) {
        $str .= join(' ', @$names) . "\n";
      }
      $str .= '[1] ' . join(' ', @$contents) . "\n";
    }
    elsif ($dim_length == 2) {
      $str .= '     ';
      
      my $colnames = $self->colnames->contents;
      if (@$colnames) {
        $str .= join(' ', @$colnames) . "\n";
      }
      else {
        for my $d2 (1 .. $dim_contents->[1]) {
          $str .= $d2 == $dim_contents->[1] ? "[,$d2]\n" : "[,$d2] ";
        }
      }
      
      my $rownames = $self->rownames->contents;
      my $use_rownames = @$rownames ? 1 : 0;
      for my $d1 (1 .. $dim_contents->[0]) {
        if ($use_rownames) {
          my $rowname = $rownames->[$d1 - 1];
          $str .= "$rowname ";
        }
        else {
          $str .= "[$d1,] ";
        }
        
        my @contents;
        for my $d2 (1 .. $dim_contents->[1]) {
          push @contents, $self->content($d1, $d2);
        }
        
        $str .= join(' ', @contents) . "\n";
      }
    }
    else {
      my $code;
      $code = sub {
        my (@dim_contents) = @_;
        my $dim_content = pop @dim_contents;
        
        for (my $i = 1; $i <= $dim_content; $i++) {
          $str .= (',' x $dim_num) . "$i" . "\n";
          unshift @$positions, $i;
          if (@dim_contents > 2) {
            $dim_num--;
            $code->(@dim_contents);
            $dim_num++;
          }
          else {
            $str .= '     ';
            for my $d2 (1 .. $dim_contents[1]) {
              $str .= $d2 == $dim_contents[1] ? "[,$d2]\n" : "[,$d2] ";
            }
            for my $d1 (1 .. $dim_contents[0]) {
              $str .= "[$d1,] ";
              
              my @contents;
              for my $d2 (1 .. $dim_contents[1]) {
                push @contents, $self->content($d1, $d2, @$positions);
              }
              
              $str .= join(' ', @contents) . "\n";
            }
          }
          shift @$positions;
        }
      };
      $code->(@$dim_contents);
    }
  }
  else {
    $str = 'NULL';
  }
  
  return $str;
}

sub negation {
  my $self = shift;
  
  my $a1 = $self->clone_without_contents;
  my $a1_contents = [];
  $a1_contents->[$_] = Rstats::Util::negation($a1_contents->[$_]) for (0 .. @$a1_contents - 1);
  $a1->contents($a1_contents);
  
  return $a1;
}

sub _operation {
  my ($self, $op, $data, $reverse) = @_;
  
  my $a1;
  my $a2;
  if (ref $data eq 'Rstats::Array') {
    $a1 = $self;
    $a2 = $data;
  }
  else {
    if ($reverse) {
      $a1 = Rstats::Array->array([$data]);
      $a2 = $self;
    }
    else {
      $a1 = $self;
      $a2 = Rstats::Array->array([$data]);
    }
  }
  
  # Upgrade mode if mode is different
  ($a1, $a2) = $self->_upgrade_mode($a1, $a2)
    if $a1->{type} ne $a2->{type};
  
  # Calculate
  my $a1_length = @{$a1->contents};
  my $a2_length = @{$a2->contents};
  my $longer_length = $a1_length > $a2_length ? $a1_length : $a2_length;
  
  no strict 'refs';
  my $operation = "Rstats::Util::$op";
  my @a3_contents = map {
    &$operation($a1->contents->[$_ % $a1_length], $a2->contents->[$_ % $a2_length])
  } (0 .. $longer_length - 1);
  
  my $a3 = Rstats::Array->array(\@a3_contents);
  
  return $a3;
}

sub _upgrade_mode {
  my ($self, @arrays) = @_;
  
  # Check contents
  my $mode_h = {};
  for my $array (@arrays) {
    my $type = $array->{type} || '';
    if ($type eq 'character') {
      $mode_h->{character}++;
    }
    elsif ($type eq 'complex') {
      $mode_h->{complex}++;
    }
    elsif ($type eq 'numeric') {
      $mode_h->{numeric}++;
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

  # Upgrade contents and type if mode is different
  my @modes = keys %$mode_h;
  if (@modes > 1) {
    my $to_mode;
    if ($mode_h->{character}) {
      $to_mode = 'character';
    }
    elsif ($mode_h->{complex}) {
      $to_mode = 'complex';
    }
    elsif ($mode_h->{numeric}) {
      $to_mode = 'numeric';
    }
    elsif ($mode_h->{integer}) {
      $to_mode = 'integer';
    }
    elsif ($mode_h->{logical}) {
      $to_mode = 'logical';
    }
    $_ = $_->_as($to_mode) for @arrays;
  }
  
  return @arrays;
}


sub matrix {
  my $self = shift;
  
  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};

  my ($_a1, $nrow, $ncol, $byrow, $dirnames) = @_;

  croak "matrix method need data as frist argument"
    unless defined $_a1;
  
  my $a1 = Rstats::Array->_to_a($_a1);
  
  # Row count
  $nrow = $opt->{nrow} unless defined $nrow;
  
  # Column count
  $ncol = $opt->{ncol} unless defined $ncol;
  
  # By row
  $byrow = $opt->{byrow} unless defined $byrow;
  
  my $a1_contents = $a1->contents;
  my $a1_length = @$a1_contents;
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
    $matrix = $self->array(
      $a1_contents,
      [$dim->[1], $dim->[0]],
    );
    
    $matrix = $self->t($matrix);
  }
  else {
    $matrix = $self->array($a1_contents, $dim);
  }
  
  return $matrix;
}

sub t {
  my ($self, $m1) = @_;
  
  my $m1_row = $m1->dim->contents->[0];
  my $m1_col = $m1->dim->contents->[1];
  
  my $m2 = $self->matrix(0, $m1_col, $m1_row);
  
  for my $row (1 .. $m1_row) {
    for my $col (1 .. $m1_col) {
      my $content = $m1->content($row, $col);
      $m2->at($col, $row)->set($content);
    }
  }
  
  return $m2;
}

sub is_array {
  my $self = shift;
  
  return $self->c([Rstats::Util::TRUE()]);
}

sub is_vector {
  my $self = shift;
  
  my $is = @{$self->dim->contents} == 0 ? Rstats::Util::TRUE() : Rstats::Util::FALSE();
  
  return $self->c([$is]);
}

sub is_matrix {
  my $self = shift;

  my $is = @{$self->dim->contents} == 2 ? Rstats::Util::TRUE() : Rstats::Util::FALSE();
  
  return $self->c([$is]);
}

sub as_matrix {
  my $self = shift;
  
  my $a1_dim_contents = $self->_real_dim_contents;
  my $a1_dim_count = @$a1_dim_contents;
  my $a2_dim_contents = [];
  my $row;
  my $col;
  if ($a1_dim_count == 2) {
    $row = $a1_dim_contents->[0];
    $col = $a1_dim_contents->[1];
  }
  else {
    $row = 1;
    $row *= $_ for @$a1_dim_contents;
    $col = 1;
  }
  
  my $a2_contents = [@{$self->contents}];
  
  return $self->matrix($a2_contents, $row, $col);
}

sub as_array {
  my $self = shift;
  
  my $a1_contents = [@{$self->contents}];
  my $a1_dim_contents = [@{$self->_real_dim_contents}];
  
  return $self->array($a1_contents, $a1_dim_contents);
}

sub as_vector {
  my $self = shift;
  
  my $a1_contents = [@{$self->contents}];
  
  return $self->c($a1_contents);
}

1;

