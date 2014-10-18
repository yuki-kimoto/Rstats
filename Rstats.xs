/* Libraries */
#include "Rstats_include.h"

/* Perl headers */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

/* Rstats headers */
#include "Rstats.h"

/* aSV* symbol collisions*/
#undef init_tm
#undef do_open
#undef do_close
#ifdef ENTER
#undef ENTER
#endif

/* Shortcut of return sv */
#define return_sv(x) XPUSHs(x); XSRETURN(1)

namespace my = Rstats::Perl;

MODULE = Rstats::Element PACKAGE = Rstats::Element

SV*
is_finite(...)
  PPCODE:
{
  Rstats::Element* self = my::to_c_obj<Rstats::Element*>(ST(0));
  
  Rstats::Element* ret = Rstats::ElementFunc::is_finite(self);

  SV* ret_sv = my::to_perl_obj(ret, "Rstats::Element");
  
  return_sv(ret_sv);
}

SV*
is_infinite(...)
  PPCODE:
{
  Rstats::Element* self = my::to_c_obj<Rstats::Element*>(ST(0));
  
  Rstats::Element* ret = Rstats::ElementFunc::is_infinite(self);
  
  SV* ret_sv = my::to_perl_obj(ret, "Rstats::Element");
  
  return_sv(ret_sv);
}

SV*
is_nan(...)
  PPCODE:
{
  Rstats::Element* self = my::to_c_obj<Rstats::Element*>(ST(0));

  Rstats::Element* ret = Rstats::ElementFunc::is_nan(self);

  SV* ret_sv = my::to_perl_obj(ret, "Rstats::Element");
  
  return_sv(ret_sv);
}

SV*
type(...)
  PPCODE:
{
  Rstats::Element* self = my::to_c_obj<Rstats::Element*>(ST(0));
  
  // Type
  Rstats::ElementType::Enum type = self->type;
  SV* type_sv;
  if (type == Rstats::ElementType::NA) {
    type_sv = my::new_sv("na");
  }
  else if (type == Rstats::ElementType::LOGICAL) {
    type_sv = my::new_sv("logical");
  }
  else if (type == Rstats::ElementType::INTEGER) {
    type_sv = my::new_sv("integer");
  }
  else if (type == Rstats::ElementType::DOUBLE) {
    type_sv = my::new_sv("double");
  }
  else if (type == Rstats::ElementType::COMPLEX) {
    type_sv = my::new_sv("complex");
  }
  else if (type == Rstats::ElementType::CHARACTER) {
    type_sv = my::new_sv("character");
  }
  else if (type == Rstats::ElementType::UNKNOWN) {
    type_sv = my::new_sv("unknown");
  }
  
  return_sv(type_sv);
}

SV*
iv(...)
  PPCODE:
{
  Rstats::Element* self = my::to_c_obj<Rstats::Element*>(ST(0));
  
  I32 iv = self->iv;
  
  return_sv(my::new_sv(iv));
}

SV*
dv(...)
  PPCODE:
{
  Rstats::Element* self = my::to_c_obj<Rstats::Element*>(ST(0));
  
  double dv = self->dv;
  
  return_sv(my::new_sv(dv));
}

SV*
cv(...)
  PPCODE:
{
  Rstats::Element* self = my::to_c_obj<Rstats::Element*>(ST(0));
  
  SV* str_sv;
  if (self->type == Rstats::ElementType::CHARACTER) {
    str_sv = my::new_sv((SV*)self->pv);
  }
  else {
    str_sv = my::new_sv("");
  }
  
  return_sv(str_sv);
}

SV*
re(...)
  PPCODE:
{
  Rstats::Element* self = my::to_c_obj<Rstats::Element*>(ST(0));
  
  double re = ((std::complex<double>*)self->pv)->real();
  
  Rstats::Element* re_element = Rstats::ElementFunc::new_double(re);
  SV* re_element_sv = my::to_perl_obj(re_element, "Rstats::Element");

  return_sv(re_element_sv);
}

SV*
im(...)
  PPCODE:
{
  Rstats::Element* self = my::to_c_obj<Rstats::Element*>(ST(0));
  
  double im = ((std::complex<double>*)self->pv)->imag();
  
  Rstats::Element* im_element = Rstats::ElementFunc::new_double(im);
  SV* im_element_sv = my::to_perl_obj(im_element, "Rstats::Element");

  return_sv(im_element_sv);
}

SV*
flag(...)
  PPCODE:
{
  Rstats::Element* self = my::to_c_obj<Rstats::Element*>(ST(0));
  
  SV* flag_sv;
  if (self->type == Rstats::ElementType::DOUBLE) {
    if (Rstats::ElementFunc::is_infinite(self)) {
      if (self->dv > 0) {
        flag_sv = my::new_sv("inf");
      }
      else {
        flag_sv = my::new_sv("-inf");
      }
    }
    else if(Rstats::ElementFunc::is_nan(self)) {
      flag_sv = my::new_sv("nan");
    }
    else {
      flag_sv = my::new_sv("normal");
    }
  }
  else {
    flag_sv = my::new_sv("normal");
  }
  
  return_sv(flag_sv);
}

SV*
DESTROY(...)
  PPCODE:
{
  Rstats::Element* self = my::to_c_obj<Rstats::Element*>(ST(0));
  if (self->type == Rstats::ElementType::COMPLEX) {
    delete (std::complex<double>*)self->pv;
  }
  else if (self->type == Rstats::ElementType::CHARACTER) {
    SvREFCNT_dec((SV*)self->pv);
  }
  delete self;
}

MODULE = Rstats::ElementFunc PACKAGE = Rstats::ElementFunc

SV*
complex_double (...)
  PPCODE:
{
  Rstats::Element* re = my::to_c_obj<Rstats::Element*>(ST(0));
  Rstats::Element* im = my::to_c_obj<Rstats::Element*>(ST(1));
  
  Rstats::Element* z = Rstats::ElementFunc::new_complex(re->dv, im->dv);
  
  SV* z_sv = my::to_perl_obj(z, "Rstats::Element");
  
  return_sv(z_sv);
}

SV*
new_negativeInf(...)
  PPCODE:
{
  Rstats::Element* element = Rstats::ElementFunc::new_negativeInf();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

SV*
new_Inf(...)
  PPCODE:
{
  Rstats::Element* element = Rstats::ElementFunc::new_Inf();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

SV*
new_NaN(...)
  PPCODE:
{
  Rstats::Element* element = Rstats::ElementFunc::new_NaN();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

SV*
new_NA(...)
  PPCODE:
{
  Rstats::Element* element = Rstats::ElementFunc::new_NA();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

SV*
new_character(...)
  PPCODE:
{
  SV* str_sv = ST(0);
  
  Rstats::Element* element = Rstats::ElementFunc::new_character(str_sv);
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

SV*
new_complex(...)
  PPCODE:
{
  SV* re_sv = ST(0);
  SV* im_sv = ST(1);

  double re = my::nv(re_sv);
  double im = my::nv(im_sv);
  
  Rstats::Element* element = Rstats::ElementFunc::new_complex(re, im);
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

SV*
new_logical(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  I32 iv = my::iv(value_sv);
  
  Rstats::Element* element = Rstats::ElementFunc::new_logical((bool)iv);
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

SV*
new_true(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  I32 iv = my::iv(value_sv);
  
  Rstats::Element* element = Rstats::ElementFunc::new_true();
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

SV*
new_false(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  I32 iv = my::iv(value_sv);
  
  Rstats::Element* element = Rstats::ElementFunc::new_false();
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

SV*
new_double(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  double dv = my::nv(value_sv);
  
  Rstats::Element* element = Rstats::ElementFunc::new_double(dv);
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

SV*
new_integer(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  int iv = my::iv(value_sv);
  
  Rstats::Element* element = Rstats::ElementFunc::new_integer(iv);
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Element");
  
  return_sv(element_obj);
}

MODULE = Rstats::Util PACKAGE = Rstats::Util

SV*
cross_product(...)
  PPCODE:
{
  SV* values_sv = ST(0);
  
  I32 values_length = my::length(values_sv);
  SV* idxs_sv = my::new_av_ref();
  for (I32 i = 0; i < values_length; i++) {
    my::push(idxs_sv, my::new_sv(0)); 
  }
  
  SV* idx_idx_sv = my::new_av_ref();
  for (I32 i = 0; i < values_length; i++) {
    my::push(idx_idx_sv, my::new_sv(i));
  }
  
  SV* x1_sv = my::new_av_ref();
  for (I32 i = 0; i < values_length; i++) {
    SV* value_sv = my::av_get(values_sv, i);
    my::push(x1_sv, my::av_get(value_sv, 0));
  }

  SV* result_sv = my::new_av_ref();
  my::push(result_sv, my::av_copy(x1_sv));
  I32 end_loop = 0;
  while (1) {
    for (I32 i = 0; i < values_length; i++) {
      
      if (my::iv(my::av_get(idxs_sv, i)) < my::length(my::av_get(values_sv, i)) - 1) {
        
        SV* idxs_tmp = my::av_get(idxs_sv, i);
        sv_inc(idxs_tmp);
        my::av_set(x1_sv, i, my::av_get(my::av_get(values_sv, i), idxs_tmp));
        
        my::push(result_sv, my::av_copy(x1_sv));
        
        break;
      }
      
      if (i == my::iv(my::av_get(idx_idx_sv, values_length - 1))) {
        end_loop = 1;
        break;
      }
      
      my::av_set(idxs_sv, i, my::new_sv(0));
      my::av_set(x1_sv, i, my::av_get(my::av_get(values_sv, i), 0));
    }
    if (end_loop) {
      break;
    }
  }

  return_sv(result_sv);
}

SV*
pos_to_index(...)
  PPCODE:
{
  SV* pos_sv = ST(0);
  SV* dim_sv = ST(1);
  
  SV* index_sv = my::new_av_ref();
  I32 pos = my::iv(pos_sv);
  I32 before_dim_product = 1;
  for (I32 i = 0; i < my::length(my::av_deref(dim_sv)); i++) {
    before_dim_product *= my::iv(my::av_get(dim_sv, i));
  }
  
  for (I32 i = my::length(my::av_deref(dim_sv)) - 1; i >= 0; i--) {
    I32 dim_product = 1;
    for (I32 k = 0; k < i; k++) {
      dim_product *= my::iv(my::av_get(dim_sv, k));
    }
    
    I32 reminder = pos % before_dim_product;
    I32 quotient = (int)(reminder / dim_product);
    
    my::unshift(index_sv, my::new_sv(quotient + 1));
    before_dim_product = dim_product;
  }
  
  return_sv(index_sv);
}

SV*
index_to_pos(...)
  PPCODE :
{
  SV* index_sv = ST(0);
  SV* dim_values_sv = ST(1);
  
  U32 pos = 0;
  for (U32 i = 0; i < my::length(my::av_deref(dim_values_sv)); i++) {
    if (i > 0) {
      U32 tmp = 1;
      for (U32 k = 0; k < i; k++) {
        tmp *= my::uv(my::av_get(dim_values_sv, k));
      }
      pos += tmp * (my::uv(my::av_get(index_sv, i)) - 1);
    }
    else {
      pos += my::uv(my::av_get(index_sv, i));
    }
  }
  
  SV* pos_sv = my::new_sv(pos - 1);
  
  return_sv(pos_sv);
}

MODULE = Rstats PACKAGE = Rstats
