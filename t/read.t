use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use FindBin;

# read_table
{
  # read_table - basic
  my $d1 = r->read_table("$FindBin::Bin/tdata/read/basic.txt");
  1;
}
