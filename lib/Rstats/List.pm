package Rstats::List;
use Rstats::Container -base;

use Rstats::Func::List;

use overload '""' => \&to_string,
  fallback => 1;

sub getin { Rstats::Func::List::getin(@_) }
sub get { Rstats::Func::List::get(@_) }
sub set { Rstats::Func::List::set(@_) }
sub to_string { Rstats::Func::List::to_string(@_) }

1;

=head1 NAME

Rstats::List - List
