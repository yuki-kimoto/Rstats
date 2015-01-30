package Rstats::List;
use Rstats::Object -base;

use Rstats::ListFunc;

use overload '""' => \&to_string,
  fallback => 1;

sub getin { Rstats::ListFunc::getin(undef(), @_) }
sub get { Rstats::ListFunc::get(undef(), @_) }
sub set { Rstats::ListFunc::set(undef(), @_) }
sub to_string { Rstats::ListFunc::to_string(undef(), @_) }

1;

=head1 NAME

Rstats::List - List
