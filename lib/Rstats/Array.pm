package Rstats::Array;
use Rstats::Object -base;

sub bool { Rstats::ArrayFunc::bool(undef(), @_) }
sub value { Rstats::ArrayFunc::value(undef(), @_) }

1;

=head1 NAME

Rstats::Array - Array
