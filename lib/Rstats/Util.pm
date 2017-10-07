package Rstats::Util;
use strict;
use warnings;

require Rstats;
use Scalar::Util ();
use B ();
use Carp 'croak';
use Rstats::Func;

my $NAME
  = eval { require Sub::Util; Sub::Util->can('set_subname') } || sub { $_[1] };

sub monkey_patch {
  my ($class, %patch) = @_;
  no strict 'refs';
  no warnings 'redefine';
  *{"${class}::$_"} = $NAME->("${class}::$_", $patch{$_}) for keys %patch;
}

sub parse_index {
  my $r = shift;
  
  my ($x1, $drop, $_indexs) = @_;
  my @_indexs = @$_indexs;
  
  my $x1_dim = $x1->dim_as_array->values;
  my @indexs;
  my @x2_dim;
  
  for (my $i = 0; $i < @$x1_dim; $i++) {
    my $_index = $_indexs[$i];

    my $index = defined $_index ? Rstats::Func::to_object($r, $_index) : Rstats::c_integer($r);
    my $index_values = $index->values;
    if (@$index_values) {
      my $minus_count = 0;
      for my $index_value (@$index_values) {
        if ($index_value == 0) {
          croak "0 is invalid index";
        }
        else {
          $minus_count++ if $index_value < 0;
        }
      }
      croak "Can't min minus sign and plus sign"
        if $minus_count > 0 && $minus_count != @$index_values;
      $index->{_minus} = 1 if $minus_count > 0;
    }
    
    if (!@{$index->values}) {
      my $index_values_new = [1 .. $x1_dim->[$i]];
      $index = Rstats::Func::c_integer($r, @$index_values_new);
    }
    elsif ($index->{_minus}) {
      my $index_value_new = [];
      
      for my $k (1 .. $x1_dim->[$i]) {
        push @$index_value_new, $k unless grep { $_ == -$k } @{$index->values};
      }
      $index = Rstats::Func::c_integer($r, @$index_value_new);
    }

    push @indexs, $index;

    my $count = Rstats::Func::get_length($r, $index);
    push @x2_dim, $count unless $count == 1 && $drop;
  }
  @x2_dim = (1) unless @x2_dim;
  
  my $index_values = [map { $_->values } @indexs];
  my $ords = cross_product($index_values);
  my @poss = map { Rstats::Util::index_to_pos($_, $x1_dim) } @$ords;

  return [\@poss, \@x2_dim, \@indexs];
}

=head1 NAME

Rstats::Util - Utility class

=head1 FUNCTION

=head2 looks_like_na (xs)

=head2 looks_like_double (xs)

=head2 looks_like_integer (xs)

=head2 index_to_pos (xs)

=head2 pos_to_index (xs)

=head2 cross_product (xs)

1;
