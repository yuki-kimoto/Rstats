package Rstats::Vector;
use Rstats::Array -base;

use overload
  '""' => \&to_string,
  fallback => 1;

use Carp 'croak';

sub new {
  my $self = shift->SUPER::new(@_);
  
  return $self;
}

sub head {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  my $n = $opt->{n};
  $n = 6 unless defined $n;
  
  my $values1 = $self->{values};
  my $max = $self->length < $n ? $self->length : $n;
  my @values2;
  for (my $i = 0; $i < $max; $i++) {
    push @values2, $values1->[$i];
  }
  
  return $self->new(values => \@values2);
}

sub tail {
  my $self = shift;

  my $opt = ref $_[-1] eq 'HASH' ? pop @_ : {};
  
  my $n = $opt->{n};
  $n = 6 unless defined $n;
  
  my $values1 = $self->{values};
  my $max = $self->length < $n ? $self->length : $n;
  my @values2;
  for (my $i = 0; $i < $max; $i++) {
    unshift @values2, $values1->[$self->length - ($i  + 1)];
  }
  
  return $self->new(values => \@values2);
}

sub names {
  my ($self, $names_v) = @_;
  
  if ($names_v) {
    if (ref $names_v eq 'ARRAY') {
      $names_v = Rstats::Vector->new(values => $names_v);
    }
    croak "names argument must be array reference or Rstats::Vector object"
      unless ref $names_v eq 'Rstats::Vector';
    my $duplication = {};
    my $names = $names_v->values;
    for my $name (@$names) {
      croak "Don't use same name in names arguments"
        if $duplication->{$name};
      $duplication->{$name}++;
    }
    $self->{names} = $names_v;
  }
  else {
    return $self->{names};
  }
}

sub to_string {
  my $self = shift;
  
  my $str = '';
  my $names_v = $self->names;
  if ($names_v) {
    $str .= join(' ', @{$names_v->values}) . "\n";
  }
  
  my $values = $self->values;
  if (@$values) {
    $str .= '[1] ' . join(' ', @$values) . "\n";
  }
  
  return $str;
}

1;
