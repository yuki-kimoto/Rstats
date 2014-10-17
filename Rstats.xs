/* C++ library */
#include <vector>
#include <iostream>
#include <complex>
#include <cmath>

/* Perl headers */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

/* Perl API */
#include "RstatsPerlAPI.h"

Rstats::PerlAPI* p = new Rstats::PerlAPI;

/* Rstats headers */
#include "Rstats.h"

/* avoid symbol collisions*/
#undef init_tm
#undef do_open
#undef do_close
#ifdef ENTER
#undef ENTER
#endif

using namespace std;

MODULE = Rstats::Element PACKAGE = Rstats::Element

void
is_finite(...)
  PPCODE:
{
  Rstats::Element* self = p->to_c_obj<Rstats::Element*>(ST(0));
  
  Rstats::Element* ret = Rstats::ElementFunc::is_finite(self);

  SV* ret_sv = p->to_perl_obj(ret, "Rstats::Element");
  
  return_sv(ret_sv);
}

void
is_infinite(...)
  PPCODE:
{
  Rstats::Element* self = p->to_c_obj<Rstats::Element*>(ST(0));
  
  Rstats::Element* ret = Rstats::ElementFunc::is_infinite(self);
  
  SV* ret_sv = p->to_perl_obj(ret, "Rstats::Element");
  
  return_sv(ret_sv);
}

void
is_nan(...)
  PPCODE:
{
  Rstats::Element* self = p->to_c_obj<Rstats::Element*>(ST(0));

  Rstats::Element* ret = Rstats::ElementFunc::is_nan(self);

  SV* ret_sv = p->to_perl_obj(ret, "Rstats::Element");
  
  return_sv(ret_sv);
}

void
type(...)
  PPCODE:
{
  Rstats::Element* self = p->to_c_obj<Rstats::Element*>(ST(0));
  
  // Type
  Rstats::ElementType::Enum type = self->type;
  SV* type_sv;
  if (type == Rstats::ElementType::NA) {
    type_sv = p->new_sv("na");
  }
  else if (type == Rstats::ElementType::LOGICAL) {
    type_sv = p->new_sv("logical");
  }
  else if (type == Rstats::ElementType::INTEGER) {
    type_sv = p->new_sv("integer");
  }
  else if (type == Rstats::ElementType::DOUBLE) {
    type_sv = p->new_sv("double");
  }
  else if (type == Rstats::ElementType::COMPLEX) {
    type_sv = p->new_sv("complex");
  }
  else if (type == Rstats::ElementType::CHARACTER) {
    type_sv = p->new_sv("character");
  }
  else if (type == Rstats::ElementType::UNKNOWN) {
    type_sv = p->new_sv("unknown");
  }
  
  return_sv(type_sv);
}

void
iv(...)
  PPCODE:
{
  Rstats::Element* self = p->to_c_obj<Rstats::Element*>(ST(0));
  
  I32 iv = self->iv;
  
  return_sv(p->new_sv(iv));
}

void
dv(...)
  PPCODE:
{
  Rstats::Element* self = p->to_c_obj<Rstats::Element*>(ST(0));
  
  double dv = self->dv;
  
  return_sv(p->new_sv(dv));
}

void
cv(...)
  PPCODE:
{
  Rstats::Element* self = p->to_c_obj<Rstats::Element*>(ST(0));
  
  SV* str_sv;
  if (self->type == Rstats::ElementType::CHARACTER) {
    str_sv = p->new_sv((SV*)self->pv);
  }
  else {
    str_sv = p->new_sv("");
  }
  
  return_sv(str_sv);
}

void
re(...)
  PPCODE:
{
  Rstats::Element* self = p->to_c_obj<Rstats::Element*>(ST(0));
  
  double re = ((complex<double>*)self->pv)->real();
  
  Rstats::Element* re_element = Rstats::ElementFunc::new_double(re);
  SV* re_element_sv = p->to_perl_obj(re_element, "Rstats::Element");

  return_sv(re_element_sv);
}

void
im(...)
  PPCODE:
{
  Rstats::Element* self = p->to_c_obj<Rstats::Element*>(ST(0));
  
  double im = ((complex<double>*)self->pv)->imag();
  
  Rstats::Element* im_element = Rstats::ElementFunc::new_double(im);
  SV* im_element_sv = p->to_perl_obj(im_element, "Rstats::Element");

  return_sv(im_element_sv);
}

void
flag(...)
  PPCODE:
{
  Rstats::Element* self = p->to_c_obj<Rstats::Element*>(ST(0));
  
  SV* flag_sv;
  if (self->type == Rstats::ElementType::DOUBLE) {
    if (isinf(self->dv)) {
      if (self->dv > 0) {
        flag_sv = p->new_sv("inf");
      }
      else {
        flag_sv = p->new_sv("-inf");
      }
    }
    else if(isnan(self->dv)) {
      flag_sv = p->new_sv("nan");
    }
    else {
      flag_sv = p->new_sv("normal");
    }
  }
  else {
    flag_sv = p->new_sv("normal");
  }
  
  return_sv(flag_sv);
}

void
DESTROY(...)
  PPCODE:
{
  Rstats::Element* self = p->to_c_obj<Rstats::Element*>(ST(0));
  if (self->type == Rstats::ElementType::COMPLEX) {
    delete (complex<double>*)self->pv;
  }
  else if (self->type == Rstats::ElementType::CHARACTER) {
    SvREFCNT_dec((SV*)self->pv);
  }
  delete self;
}

MODULE = Rstats::ElementFunc PACKAGE = Rstats::ElementFunc

void
complex_double (...)
  PPCODE:
{
  Rstats::Element* re = p->to_c_obj<Rstats::Element*>(ST(0));
  Rstats::Element* im = p->to_c_obj<Rstats::Element*>(ST(1));
  
  Rstats::Element* z = Rstats::ElementFunc::new_complex(re->dv, im->dv);
  
  SV* z_sv = p->to_perl_obj(z, "Rstats::Element");
  
  return_sv(z_sv);
}

void
new_negativeInf(...)
  PPCODE:
{
  Rstats::Element* element = Rstats::ElementFunc::new_negativeInf();
  SV* element_obj = p->to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

void
new_Inf(...)
  PPCODE:
{
  Rstats::Element* element = Rstats::ElementFunc::new_Inf();
  SV* element_obj = p->to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

void
new_NaN(...)
  PPCODE:
{
  Rstats::Element* element = Rstats::ElementFunc::new_NaN();
  SV* element_obj = p->to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

void
new_NA(...)
  PPCODE:
{
  Rstats::Element* element = Rstats::ElementFunc::new_NA();
  SV* element_obj = p->to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

void
new_character(...)
  PPCODE:
{
  SV* str_sv = ST(0);
  
  Rstats::Element* element = Rstats::ElementFunc::new_character(str_sv);
  
  SV* element_obj = p->to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

void
new_complex(...)
  PPCODE:
{
  SV* re_sv = ST(0);
  SV* im_sv = ST(1);

  double re = p->nv(re_sv);
  double im = p->nv(im_sv);
  
  Rstats::Element* element = Rstats::ElementFunc::new_complex(re, im);
  
  SV* element_obj = p->to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

void
new_logical(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  I32 iv = p->iv(value_sv);
  
  Rstats::Element* element = Rstats::ElementFunc::new_logical((bool)iv);
  
  SV* element_obj = p->to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

void
new_true(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  I32 iv = p->iv(value_sv);
  
  Rstats::Element* element = Rstats::ElementFunc::new_true();
  
  SV* element_obj = p->to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

void
new_false(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  I32 iv = p->iv(value_sv);
  
  Rstats::Element* element = Rstats::ElementFunc::new_false();
  
  SV* element_obj = p->to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

void
new_double(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  double dv = p->nv(value_sv);
  
  Rstats::Element* element = Rstats::ElementFunc::new_double(dv);
  
  SV* element_obj = p->to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

void
new_integer(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  int iv = p->iv(value_sv);
  
  Rstats::Element* element = Rstats::ElementFunc::new_integer(iv);
  
  SV* element_obj = p->to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

MODULE = Rstats::Util PACKAGE = Rstats::Util

void
cross_product(...)
  PPCODE:
{
  SV* values_sv = ST(0);
  
  I32 values_length = p->length(values_sv);
  SV* idxs_sv = p->new_av_ref();
  for (I32 i = 0; i < values_length; i++) {
    p->push(idxs_sv, p->new_sv((I32)0)); 
  }
  
  SV* idx_idx_sv = p->new_av_ref();
  for (I32 i = 0; i < values_length; i++) {
    p->push(idx_idx_sv, p->new_sv(i));
  }
  
  SV* x1_sv = p->new_av_ref();
  for (I32 i = 0; i < values_length; i++) {
    SV* value_sv = p->av_get(values_sv, i);
    p->push(x1_sv, p->av_get(value_sv, (I32)0));
  }

  SV* result_sv = p->new_av_ref();
  p->push(result_sv, p->copy_av(x1_sv));
  I32 end_loop = 0;
  while (1) {
    for (I32 i = 0; i < values_length; i++) {
      
      if (p->iv(p->av_get(idxs_sv, i)) < p->length(p->av_get(values_sv, i)) - 1) {
        
        SV* idxs_tmp = p->av_get(idxs_sv, i);
        sv_inc(idxs_tmp);
        p->av_set(x1_sv, i, p->av_get(p->av_get(values_sv, i), idxs_tmp));
        
        p->push(result_sv, p->copy_av(x1_sv));
        
        break;
      }
      
      if (i == p->iv(p->av_get(idx_idx_sv, values_length - 1))) {
        end_loop = 1;
        break;
      }
      
      p->av_set(idxs_sv, i, p->new_sv((I32)0));
      p->av_set(x1_sv, i, p->av_get(p->av_get(values_sv, i), (I32)0));
    }
    if (end_loop) {
      break;
    }
  }

  return_sv(result_sv);
}

void
pos_to_index(...)
  PPCODE:
{
  SV* pos_sv = ST(0);
  SV* dim_sv = ST(1);
  
  SV* index_sv = p->new_av_ref();
  I32 pos = p->iv(pos_sv);
  I32 before_dim_product = 1;
  for (I32 i = 0; i < p->length(p->av_deref(dim_sv)); i++) {
    before_dim_product *= p->iv(p->av_get(dim_sv, i));
  }
  
  for (I32 i = p->length(p->av_deref(dim_sv)) - 1; i >= 0; i--) {
    I32 dim_product = 1;
    for (I32 k = 0; k < i; k++) {
      dim_product *= p->iv(p->av_get(dim_sv, k));
    }
    
    I32 reminder = pos % before_dim_product;
    I32 quotient = (int)(reminder / dim_product);
    
    p->unshift(index_sv, p->new_sv(quotient + 1));
    before_dim_product = dim_product;
  }
  
  return_sv(index_sv);
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
        tmp *= p->uv(p->av_get(dim_values_sv, k));
      }
      pos += tmp * (p->uv(p->av_get(index_sv, i)) - 1);
    }
    else {
      pos += p->uv(p->av_get(index_sv, i));
    }
  }
  
  SV* pos_sv = p->new_sv(pos - 1);
  
  return_sv(pos_sv);
}

MODULE = Rstats PACKAGE = Rstats
