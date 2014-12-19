package Rstats::Vector;
use Object::Simple -base;

use Carp 'croak', 'carp';
use Rstats::VectorFunc;

use overload
  '""' => \&to_string,
  fallback => 1;

sub to_string {
  my $self = shift;
  
  my @strs;
  my $values = $self->values;
  for my $value (@$values) {
    my $str;
    if (defined $value) {
      if ($self->is_character) {
        $str = $value . "";
      }
      elsif ($self->is_complex) {
        my $re = $value->{re};
        my $im = $value->{im};
        
        $str = "$re";
        $str .= '+' if $im >= 0;
        $str .= $im . 'i';
      }
      elsif ($self->is_double) {
        $str = $value . "";
      }
      elsif ($self->is_integer) {
        $str = $value . "";
      }
      elsif ($self->is_logical) {
        $str = $value ? 'TRUE' : 'FALSE'
      }
      else {
        croak "Invalid type";
      }
    }
    else {
      $str = 'NA';
    }
    push @strs, $str;
  }
  
  my $str_all = join ' ', @strs;
  
  return $str_all;
}

1;

=head1 NAME

Rstats::Vector - Vector

=heaa1 METHODS

=head2 is_negative_infinite

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

=head2  is_nan (xs)

=head2  is_infinite (xs)

=head2  is_finite (xs)

