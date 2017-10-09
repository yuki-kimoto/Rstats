use Test::More 'no_plan';
use strict;
use warnings;

use Rstats;
use Rstats;

my $r = Rstats->new;

# outer
{
  # outer - basic
  my $x1 = $r->array($r->C('1:2'), $r->c([1, 2]));
  my $x2 = $r->array($r->C('1:24'), $r->c([3, 4]));
  my $x3 = $r->outer($x1, $x2);
  is_deeply($x3->values, [qw/1  2  2  4  3  6  4  8  5 10  6 12  7 14  8 16  9 18 10 20 11 22 12 24/]);
  is_deeply($r->dim($x3)->values, [1, 2, 3, 4]);
}

# diag
{
  # diag - unit matrix
  {
    my $x1 = $r->diag($r->c(3));
    is_deeply($x1->values, [1, 0, 0, 0, 1, 0, 0, 0, 1]);
    is_deeply($r->dim($x1)->values, [3, 3]);
  }

  # diag - basic
  {
    my $x1 = $r->diag($r->c([1, 2, 3]));
    is_deeply($x1->values, [1, 0, 0, 0, 2, 0, 0, 0, 3]);
    is_deeply($r->dim($x1)->values, [3, 3]);
  }  
}

# kronecker
{
  # kronecker - basic
  {
    my $x1 = $r->array($r->C('1:12'), $r->c([3, 4]));
    my $x2 = $r->array($r->C('1:24'), $r->c([4, 3, 2]));
    my $x3 = $r->kronecker($x1, $x2);
    is_deeply($x3->values, [
      qw/
     1   2   3   4   2   4   6   8   3   6   9  12   5   6   7   8  10  12  14  16  15  18  21
    24   9  10  11  12  18  20  22  24  27  30  33  36   4   8  12  16   5  10  15  20   6  12
    18  24  20  24  28  32  25  30  35  40  30  36  42  48  36  40  44  48  45  50  55  60  54
    60  66  72   7  14  21  28   8  16  24  32   9  18  27  36  35  42  49  56  40  48  56  64
    45  54  63  72  63  70  77  84  72  80  88  96  81  90  99 108  10  20  30  40  11  22  33
    44  12  24  36  48  50  60  70  80  55  66  77  88  60  72  84  96  90 100 110 120  99 110
   121 132 108 120 132 144  13  14  15  16  26  28  30  32  39  42  45  48  17  18  19  20  34
    36  38  40  51  54  57  60  21  22  23  24  42  44  46  48  63  66  69  72  52  56  60  64
    65  70  75  80  78  84  90  96  68  72  76  80  85  90  95 100 102 108 114 120  84  88  92
    96 105 110 115 120 126 132 138 144  91  98 105 112 104 112 120 128 117 126 135 144 119 126
   133 140 136 144 152 160 153 162 171 180 147 154 161 168 168 176 184 192 189 198 207 216 130
   140 150 160 143 154 165 176 156 168 180 192 170 180 190 200 187 198 209 220 204 216 228 240
   210 220 230 240 231 242 253 264 252 264 276 288
      /]);
    is_deeply($r->dim($x3)->values, [12, 12, 2]);
  }

  # kronecker - reverse
  {
    my $x1 = $r->array($r->C('1:24'), $r->c([4, 3, 2]));
    my $x2 = $r->array($r->C('1:12'), $r->c([3, 4]));
    my $x3 = $r->kronecker($x1, $x2);
    is_deeply($x3->values, [
      qw/
 1   2   3   2   4   6   3   6   9   4   8  12   4   5   6   8  10  12  12  15  18  16  20
 24   7   8   9  14  16  18  21  24  27  28  32  36  10  11  12  20  22  24  30  33  36  40
 44  48   5  10  15   6  12  18   7  14  21   8  16  24  20  25  30  24  30  36  28  35  42
 32  40  48  35  40  45  42  48  54  49  56  63  56  64  72  50  55  60  60  66  72  70  77
 84  80  88  96   9  18  27  10  20  30  11  22  33  12  24  36  36  45  54  40  50  60  44
 55  66  48  60  72  63  72  81  70  80  90  77  88  99  84  96 108  90  99 108 100 110 120
110 121 132 120 132 144  13  26  39  14  28  42  15  30  45  16  32  48  52  65  78  56  70
 84  60  75  90  64  80  96  91 104 117  98 112 126 105 120 135 112 128 144 130 143 156 140
154 168 150 165 180 160 176 192  17  34  51  18  36  54  19  38  57  20  40  60  68  85 102
 72  90 108  76  95 114  80 100 120 119 136 153 126 144 162 133 152 171 140 160 180 170 187
204 180 198 216 190 209 228 200 220 240  21  42  63  22  44  66  23  46  69  24  48  72  84
105 126  88 110 132  92 115 138  96 120 144 147 168 189 154 176 198 161 184 207 168 192 216
210 231 252 220 242 264 230 253 276 240 264 288
      /]);
    is_deeply($r->dim($x3)->values, [12, 12, 2]);
  }
}