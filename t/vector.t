use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;


# names
{
  # names - get
  {
    NA;
    
    my $x1 = c(1, 2, 3, 4);
    r->names($x1 => c('a', 'b', 'c', 'd'));
    my $x2 = $x1->get(c('b', 'd'));
    is_deeply($x2->values, [2, 4]);
  }

  # names - to_string
  {
    my $x1 = c(1, 2, 3);
    r->names($x1 => c('a', 'b', 'c'));
    is("$x1", "a b c\n[1] 1 2 3\n");
  }
}

# inner product
{
  # inner product - inner product
  {
    my $x1 = c(1, 2, 3);
    my $x2 = c(4, 5, 6);
    my $x3 = $x1 x $x2;
    is_deeply($x3->values, [32]);
    is_deeply(r->dim($x3)->values, [1, 1]);
  }
  
  # innert product - size is different
  {
    my $x1 = c(1, 2, 3);
    my $x2 = c(4, 5);
    eval { my $x3 = $x1 x $x2 };
    like($@, qr/non-conformable/);
  }

  # innert product - size of first argument is zero
  {
    my $x1 = c();
    my $x2 = c(4, 5);
    eval { my $x3 = $x1 x $x2 };
    like($@, qr#requires numeric/complex matrix/vector arguments#);
  }

  # innert product - size of second argument is zero
  {
    my $x1 = c(1, 2, 3);
    my $x2 = c();
    eval { my $x3 = $x1 x $x2 };
    like($@, qr#requires numeric/complex matrix/vector arguments#);
  }
}
