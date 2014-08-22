package Rstats::Element::Character;
use Rstats::Element -base;

use Rstats::ElementFunction;

has type => 'character';

sub value { shift->{value} }

sub is_character { Rstats::ElementFunction::TRUE }

1;
