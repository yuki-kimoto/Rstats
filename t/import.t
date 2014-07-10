use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats::Util;

# c
{
  my $v1 = c(1, 2, 3);
  is_deeply($v1->values, [1, 2, 3]);
}

# C
{
  my $v1 = C('1:3');
  is_deeply($v1->values, [1, 2, 3]);
}

# array
{
  my $a1 = array(C('1:12'), c(4, 3));
  is_deeply($a1->values, [1 .. 12]);
  is_deeply($a1->dim->values, [4, 3]);
}

# matrix
{
  my $m1 = matrix(C('1:12'), 4, 3);
  is_deeply($m1->values, [1 .. 12]);
  is_deeply($m1->dim->values, [4, 3]);
}

# i
{
  my $v1 = i;
  is_deeply($v1->values, [{re => 0, im => 1}]);
}

# TRUE
{
  my $true = TRUE;
  is_deeply($true->values, [Rstats::Util::TRUE]);
}

# FALSE
{
  my $false = FALSE;
  is_deeply($false->values, [Rstats::Util::FALSE]);
}

# NA
{
  my $na = NA;
  is_deeply($na->values, [Rstats::Util::NA]);
}

# NaN
{
  my $nan = NaN;
  is_deeply($nan->values, [Rstats::Util::NaN]);
}

# Inf
{
  my $inf = Inf;
  is_deeply($inf->values, [Rstats::Util::Inf]);
}

# NULL
{
  my $null = NULL;
  is_deeply($null->elements, []);
  is_deeply($null->{dim}, []);
  is_deeply($null->{type}, 'logical');
}

# r
{
  my $r = r;
  my $v1 = r->c(1, 2, 3);
  is_deeply($v1->values, [1, 2, 3]);
}

