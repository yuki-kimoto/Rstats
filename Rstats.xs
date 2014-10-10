#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

/* avoid symbol collisions*/
#undef init_tm
#undef do_open
#undef do_close
#ifdef ENTER
#undef ENTER
#endif

/* C library */
#include <math.h>

/* C++ library */
#include <vector>
#include <iostream>

#include "PerlAPI.h"
#include "Rstats.h"

/*
sub pos_to_index {
  my ($pos, $dim) = @_;
  
  my $index = [];
  my $before_dim_product = 1;
  $before_dim_product *= $dim->[$_] for (0 .. @$dim - 1);
  for (my $i = @{$dim} - 1; $i >= 0; $i--) {
    my $dim_product = 1;
    $dim_product *= $dim->[$_] for (0 .. $i - 1);
    my $reminder = $pos % $before_dim_product;
    my $quotient = int ($reminder / $dim_product);
    unshift @$index, $quotient + 1;
    $before_dim_product = $dim_product;
  }
  
  return $index;
}
*/

PerlAPI* p = new PerlAPI;

MODULE = Rstats::Util PACKAGE = Rstats::Util

void
pos_to_index(...)
  PPCODE:
{
  SV* pos_sv = ST(0);
  SV* dim_sv = ST(1);
  
  SV* index_sv = p->new_av_ref();
  I32 pos = p->to_iv(pos_sv);
  I32 before_dim_product = 1;
  for (I32 i = 0; i < p->length(p->av_deref(dim_sv)); i++) {
    before_dim_product *= p->to_iv(p->av_get(dim_sv, i));
  }
  
  for (I32 i = p->length(p->av_deref(dim_sv)) - 1; i >= 0; i--) {
    I32 dim_product = 1;
    for (I32 k = 0; k < i; k++) {
      dim_product *= p->to_iv(p->av_get(dim_sv, k));
    }
    
    I32 reminder = pos % before_dim_product;
    I32 quotient = (int)(reminder / dim_product);
    
    p->unshift(index_sv, p->to_sv(quotient + 1));
    before_dim_product = dim_product;
  }
  
  XPUSHs(index_sv);
  XSRETURN(1);
}

void
index_to_pos(...)
  PPCODE :
{
  SV* index_sv =ST(0);
  SV* dim_values_sv = ST(1);
  
  U32 pos = 0;
  for (U32 i = 0; i < p->length(p->av_deref(dim_values_sv)); i++) {
    if (i > 0) {
      U32 tmp = 1;
      for (U32 k = 0; k < i; k++) {
        tmp *= p->to_uv(p->av_get(dim_values_sv, k));
      }
      pos += tmp * (p->to_uv(p->av_get(index_sv, i)) - 1);
    }
    else {
      pos += p->to_uv(p->av_get(index_sv, i));
    }
  }
  
  SV* pos_sv = p->to_sv(pos - 1);
  
  XPUSHs(pos_sv);
  XSRETURN(1);
}

MODULE = Rstats PACKAGE = Rstats
