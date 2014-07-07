use Test::More 'no_plan';
use strict;
use warnings;

use Rstats::Util;
use Scalar::Util 'refaddr';

# reference
{
  my $nan = Rstats::Util::NaN;
  is(ref $nan, 'Rstats::Type::Double');
}

# singleton
{
  my $nan1 = Rstats::Util::NaN;
  my $nan2 = Rstats::Util::NaN;
  is(refaddr $nan1, refaddr $nan2);
}

# negation
{
  my $nan1 = Rstats::Util::NaN;
  my $nan2 = -$nan1;
  ok(Rstats::Util::is_nan($nan2));
}

# boolean
{
  my $nan = Rstats::Util::NaN;
  eval { if ($nan) { 1 } };
  like($@, qr/logical/);
}

# to_string
{
  my $nan = Rstats::Util::NaN;
  is("$nan", 'NaN');
}

