use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

# reference
{
  my $x_na = r->new_logical(undef);
  ok(r->is_na($x_na));
}

# negation
{
  my $x_na1 = r->new_logical(undef);
  my $x_na2 = r->negation($x_na1);
  ok(r->is_na($x_na2));
}

# to_string
{
  my $x_na = r->new_logical(undef);
  is("$x_na", "[1] NA\n");
}

# is_na
{
  my $x_na = r->new_logical(undef);
  ok(r->is_na($x_na));
}
