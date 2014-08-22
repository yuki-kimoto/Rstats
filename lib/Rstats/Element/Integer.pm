package Rstats::Element::Integer;
use Rstats::Element -base;

has type => 'integer';

sub value { shift->{value} }

1;
