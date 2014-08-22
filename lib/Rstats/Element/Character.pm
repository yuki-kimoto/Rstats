package Rstats::Element::Character;
use Rstats::Element -base;

has type => 'character';

sub value { shift->{value} }

1;
