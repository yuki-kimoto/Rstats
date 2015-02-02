package Rstats::List;
use Rstats::Object -base;

use Rstats::ListFunc;

sub getin { Rstats::ListFunc::getin(undef(), @_) }
sub set { Rstats::ListFunc::set(undef(), @_) }

1;

=head1 NAME

Rstats::List - List
