package Rstats::Container::List;
use Rstats::Container -base;

use overload '""' => \&to_string,
  fallback => 1;

use Rstats::ArrayFunc;

has 'elements' => sub { [] };
has 'mode' => sub { Rstats::Array::Util::c('list') };

sub is_list { Rstats::ArrayFunc::TRUE() }
sub is_data_frame { Rstats::ArrayFunc::FALSE() }

use overload '""' => \&to_string,
  fallback => 1;

use Rstats::ArrayFunc;

has 'elements' => sub { [] };
has 'names' => sub { [] };

sub at {
  my $a1 = shift;
  
  if (@_) {
    $a1->{at} = [@_];
    
    return $a1;
  }
  
  return $a1->{at};
}

sub get {
  my ($self, $_index) = @_;
  
  unless (defined $_index) {
    $_index = $self->at;
  }
  $self->at($_index);
  
  my $a1_index = Rstats::ArrayFunc::to_array($_index);
  my $index = $a1_index->values->[0];
  my $elements = $self->elements;
  my $element = $elements->[$index - 1];
  
  return $element;
}

sub get_as_list {
  my $self = shift;
  my $index = Rstats::ArrayFunc::to_array(shift);
  
  my $elements = $self->elements;
  
  my $list = Rstats::Container::List->new;
  my $list_elements = $list->elements;
  for my $i (@{$index->values}) {
    push @$list_elements, $elements->[$i - 1];
  }

  return $list;
}

sub set {
  my ($self, $element) = @_;
  
  my $_index = $self->at;
  my $a1_index = Rstats::ArrayFunc::to_array($_index);
  my $index = $a1_index->values->[0];
  $self->elements->[$index - 1] = Rstats::ArrayFunc::to_array($element);
  
  return $self;
}

sub length { Rstats::ArrayFunc::c(shift->_length) }

sub _length { scalar @{shift->elements} }

sub to_string {
  my $self = shift;
  
  my $poses = [];
  my $str = '';
  $self->_to_string($self, $poses, \$str);
  
  return $str;
}

sub _to_string {
  my ($self, $list, $poses, $str_ref) = @_;
  
  my $elements = $list->elements;
  for (my $i = 0; $i < @$elements; $i++) {
    push @$poses, $i + 1;
    $$str_ref .= join('', map { "[[$_]]" } @$poses) . "\n";
    
    my $element = $elements->[$i];
    if (ref $element eq 'Rstats::Container::List') {
      $self->_to_string($element, $poses, $str_ref);
    }
    else {
      $$str_ref .= $element->to_string . "\n";
    }
    pop @$poses;
  }
}

1;

