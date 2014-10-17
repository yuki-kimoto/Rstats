use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use FindBin;

# read_table
{
  # read_table - character, complex, double, integer, logical, sep default(\s+)
  {
    my $d1 = r->read_table("$FindBin::Bin/data/read.t/basic.txt");
    ok($d1->getin(1)->is_factor);
    is_deeply($d1->getin(1)->values, [qw/2 3 4 5 1/]);
    is_deeply($d1->getin(1)->levels->values, [qw/NA NB NC ND NE/]);
    ok($d1->getin(2)->is_complex);
    is_deeply($d1->getin(2)->values, [{re => 1, im => 1}, {re => 1, im => 2}, {re => 1, im => 3}, {re => 1, im => 4}, undef]);
    ok($d1->getin(3)->is_double);
    is_deeply($d1->getin(3)->values, [qw/1.1 1.2 1.3 1.4/, undef]);
    ok($d1->getin(4)->is_integer);
    is_deeply($d1->getin(4)->values, [qw/1 2 3 4/, undef]);
    ok($d1->getin(5)->is_logical);
    is_deeply($d1->getin(5)->values, [qw/1 0 1 0/, undef]);
    is_deeply($d1->names->values, [qw/V1 V2 V3 V4 V5/]);
  }
  
  # read_table - header
  {
    my $d1 = r->read_table("$FindBin::Bin/data/read.t/header.txt",{header => T});
    is_deeply($d1->names->values, [qw/a b/]);
    is_deeply($d1->getin(1)->values, [qw/1 2/]);
    is_deeply($d1->getin(2)->values, [qw/1.1 1.2/]);
  }
  
  # read_table - sep comma
  {
    my $d1 = r->read_table("$FindBin::Bin/data/read.t/comma.txt",{sep => ','});
    is_deeply($d1->getin(1)->values, [qw/1 2/]);
    is_deeply($d1->getin(2)->values, [qw/1.1 1.2/]);
  }

  # read_table - skip
  {
    my $d1 = r->read_table("$FindBin::Bin/data/read.t/skip.txt",{skip => 2});
    is_deeply($d1->getin(1)->values, [qw/2 3/]);
    is_deeply($d1->getin(2)->values, [qw/1.1 1.2/]);
  }
}

