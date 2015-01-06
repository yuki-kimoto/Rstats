package Rstats::Vector;
use Object::Simple -base;

use Carp 'croak', 'carp';
use Rstats::ArrayFunc;

use overload
  '""' => \&to_string,
  fallback => 1;

1;

=head1 NAME

Rstats::Vector - Vector

=heaa1 METHODS

=head2 is_positive_infinite

=head2 typeof

=head2 value

=head2 to_string

=head2 values (xs)

=head2 is_character (xs)

=head2 is_complex (xs)

=head2 is_double (xs)

=head2 is_integer (xs)

=head2 is_numeric (xs)

=head2 is_logical (xs)

=head2 as_double (xs)

=head2 as_integer (xs)

=head2 as_numeric (xs)

=head2 as_complex (xs)

=head2 as_logical (xs)

=head2 type (xs)

=head2 re (xs)

=head2 im (xs)

=head2 flag (xs)

=head2 is_nan (xs)

=head2 is_infinite (xs)

=head2 is_finite (xs)

=head2 to_string (xs)
