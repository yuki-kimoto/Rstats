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

PerlAPI* p = new PerlAPI;

MODULE = Rstats::Util PACKAGE = Rstats::Util

void
cross_product(...)
  PPCODE:
{
  SV* values_sv = ST(0);
  
  I32 values_length = p->length(values_sv);
  SV* idxs_sv = p->new_av_ref();
  for (I32 i = 0; i < values_length; i++) {
    p->push(idxs_sv, p->to_sv(0)); 
  }
  
  SV* idx_idx_sv = p->new_av_ref();
  for (I32 i = 0; i < values_length; i++) {
    p->push(idx_idx_sv, p->to_sv(i));
  }
  
  SV* x1_sv = p->new_av_ref();
  for (I32 i = 0; i < values_length; i++) {
    SV* value_sv = p->av_get(values_sv, i);
    p->push(x1_sv, p->av_get(value_sv, 0));
  }

  SV* result_sv = p->new_av_ref();
  p->push(result_sv, p->copy_av(x1_sv));
  I32 end_loop = 0;
  while (1) {
    for (I32 i = 0; i < values_length; i++) {
      
      if (p->to_iv(p->av_get(idxs_sv, i)) < p->length(p->av_get(values_sv, i)) - 1) {
        
        SV* idxs_tmp = p->av_get(idxs_sv, i);
        Perl_sv_inc(idxs_tmp);
        p->av_set(x1_sv, i, p->av_get(p->av_get(values_sv, i), p->to_iv(idxs_tmp)));
        
        p->push(result_sv, p->copy_av(x1_sv));
        
        break;
      }
      
      if (i == p->to_iv(p->av_get(idx_idx_sv, values_length - 1))) {
        end_loop = 1;
        break;
      }
      
      p->av_set(idxs_sv, i, p->to_sv(0));
      p->av_set(x1_sv, i, p->av_get(p->av_get(values_sv, i), 0));
    }
    if (end_loop) {
      break;
    }
  }

  XPUSHs(result_sv);
  XSRETURN(1);
}

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
