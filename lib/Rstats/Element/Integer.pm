package Rstats::Element::Integer;
use Rstats::Element -base;

has type => 'integer';

sub value { shift->{value} }

sub is_integer { Rstats::ElementFunction::TRUE }

sub is_numeric { Rstats::ElementFunction::TRUE }

sub is_finite { Rstats::ElementFunction::TRUE }

1;
