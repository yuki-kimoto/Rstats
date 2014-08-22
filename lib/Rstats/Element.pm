package Rstats::Element;
use Object::Simple -base;

use Carp 'croak';
use Rstats::ElementFunction;

has 'type';

sub value { croak "virtual method" }

sub typeof { shift->type }

sub is_character { Rstats::ElementFunction::FALSE }
sub is_complex { Rstats::ElementFunction::FALSE }
sub is_numeric { Rstats::ElementFunction::FALSE }
sub is_double { Rstats::ElementFunction::FALSE }
sub is_integer { Rstats::ElementFunction::FALSE }
sub is_logical { Rstats::ElementFunction::FALSE }
sub is_na { Rstats::ElementFunction::FALSE }

sub is_nan { Rstats::ElementFunction::FALSE }

sub is_infinite { Rstats::ElementFunction::FALSE }

sub is_positive_infinite { Rstats::ElementFunction::FALSE }

sub is_negative_infinite { Rstats::ElementFunction::FALSE }

sub is_finite { Rstats::ElementFunction::FALSE }


1;
