use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;

my $r = Rstats->new;

# logical
{
  # TRUE
  ok(!!$r->TRUE);
  
  # FALSE
  ok(!$r->FALSE);
  
  # to_string, TURE
  my $true = $r->TRUE;
  is("$true", 'TRUE');
  
  # to_string, FALSE
  my $false = $r->FALSE;
  is("$false", "FALSE");
}

