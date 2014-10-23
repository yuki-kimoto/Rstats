use Test::More 'no_plan';
use strict;
use warnings;
use FindBin;

my $rstats_h_file = "$FindBin::Bin/../Rstats.h";
my $rstats_xs_file = "$FindBin::Bin/../Rstats.xs";

# Check file
ok(-f $rstats_h_file);
ok(-f $rstats_xs_file);

# Check empty literal
my @files = ($rstats_h_file, $rstats_xs_file);


(1,

