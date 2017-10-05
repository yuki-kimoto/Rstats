package Rstats::V2::Object;

use Object::Simple -base;

use Rstats::V2::Func;

has 'r';
has 'type';
has 'dim';
has 'vector';
has 'object_type';

sub to_string {
  my $x1 = shift;
  my $r = $x1->r;
  
  return Rstats::V2::Func::to_string($r, $x1, @_);
}

1;
