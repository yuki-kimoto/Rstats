package Rstats::Vector;
use Rstats::Array -base;

use Rstats;

use overload
  '""' => \&to_string,
  fallback => 1;

use Carp 'croak';

my $r = Rstats->new;

sub new {
  my $self = shift->SUPER::new(@_);
  
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

1;
