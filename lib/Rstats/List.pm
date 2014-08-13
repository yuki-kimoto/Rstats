package Rstats::List;
use Object::Simple -base;

use overload '""' => \&to_string,
  fallback => 1;

use Rstats::ArrayUtil;

has 'elements' => sub { [] };

sub length {
  my $self = shift;
  
  my $length = @{$self->elements};
  
  return Rstats::ArrayUtil::c($length);
}

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
    if (ref $element eq 'Rstats::List') {
      $self->_to_string($element, $poses, $str_ref);
    }
    else {
      $$str_ref .= $element->to_string . "\n";
    }
    pop @$poses;
  }
}

1;

