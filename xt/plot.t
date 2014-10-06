use strict;
use warnings;

use Rstats;
use FindBin;
use Imager::Font;

r->png("$FindBin::Bin/test1.bmp", width => 400, height => 400);
r->plot(C('1:6'));
r->dev_off;

use Imager;
  print "Has truetype"      if $Imager::formats{tt};
  print "Has t1 postscript" if $Imager::formats{t1};
  print "Has Win32 fonts"   if $Imager::formats{w32};
  print "Has Freetype2"     if $Imager::formats{ft2};
