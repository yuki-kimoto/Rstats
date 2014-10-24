use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# inner product
{
  # inner product - inner product
  {
    my $v1 = c(1, 2, 3);
    my $v2 = c(4, 5, 6);
    my $v3 = $v1 x $v2;
    is_deeply($v3->values, [32]);
    is_deeply(r->dim($v3)->values, [1, 1]);
  }
  
  # innert product - size is different
  {
    my $v1 = c(1, 2, 3);
    my $v2 = c(4, 5);
    eval { my $v3 = $v1 x $v2 };
    like($@, qr/non-conformable/);
  }

  # innert product - size of first argument is zero
  {
    my $v1 = c();
    my $v2 = c(4, 5);
    eval { my $v3 = $v1 x $v2 };
    like($@, qr#requires numeric/complex matrix/vector arguments#);
  }

  # innert product - size of second argument is zero
  {
    my $v1 = c(1, 2, 3);
    my $v2 = c();
    eval { my $v3 = $v1 x $v2 };
    like($@, qr#requires numeric/complex matrix/vector arguments#);
  }
}

# names
{
  # names - get
  {
    my $v1 = c(1, 2, 3, 4);
    r->names($v1 => c('a', 'b', 'c', 'd'));
    my $v2 = $v1->get(c('b', 'd'));
    is_deeply($v2->values, [2, 4]);
  }

  # names - to_string
  {
    my $v = c(1, 2, 3);
    r->names($v => c('a', 'b', 'c'));
    is("$v", "a b c\n[1] 1 2 3\n");
  }
}

