use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# reference
{
  my $x_na = r->c_logical(undef);
  ok(r->is->na($x_na));
}

# negate
{
  my $x_na1 = r->c_logical(undef);
  my $x_na2 = r->negate($x_na1);
  ok(r->is->na($x_na2));
}

# to_string
{
  my $x_na = r->c_logical(undef);
  is("$x_na", "[1] NA\n");
}

# is_na
{
  my $x_na = r->c_logical(undef);
  ok(r->is->na($x_na));
}
