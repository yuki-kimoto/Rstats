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

MODULE = Rstats::Elements PACKAGE = Rstats::Elements

SV*
decompose(...)
  PPCODE:
{
  /*
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::ElementsType::Enum type = self->get_type();
  std::map<I32, I32>* na_positions = self->na_positions;
    Rstats::Elements* elements = self->values;
  
  SV* de_elements = my::new_av_ref();
  for (I32 i = 0; i < self->get_size(); i++) {
    
  }
  */
  
  XSRETURN(0);
}

SV*
is_finite(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* rets = Rstats::ElementsFunc::is_finite(self);

  SV* rets_sv = my::to_perl_obj(rets, (char*)"Rstats::Elements");
  
  return_sv(rets_sv);
}

SV*
is_infinite(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* rets = Rstats::ElementsFunc::is_infinite(self);
  
  SV* rets_sv = my::to_perl_obj(rets, (char*)"Rstats::Elements");
  
  return_sv(rets_sv);
}

SV*
is_nan(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));

  Rstats::Elements* rets = Rstats::ElementsFunc::is_nan(self);

  SV* rets_sv = my::to_perl_obj(rets, (char*)"Rstats::Elements");
  
  return_sv(rets_sv);
}

SV*
type(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  // Type
  Rstats::ElementsType::Enum type = self->get_type();
  SV* type_sv;

  if (type == Rstats::ElementsType::LOGICAL) {
    if(self->exists_na_position((I32)0)) {
      type_sv = my::new_sv((char*)"na");
    }
    else {
      type_sv = my::new_sv((char*)"logical");
    }
  }
  else if (type == Rstats::ElementsType::INTEGER) {
    type_sv = my::new_sv((char*)"integer");
  }
  else if (type == Rstats::ElementsType::DOUBLE) {
    type_sv = my::new_sv((char*)"double");
  }
  else if (type == Rstats::ElementsType::COMPLEX) {
    type_sv = my::new_sv((char*)"complex");
  }
  else if (type == Rstats::ElementsType::CHARACTER) {
    type_sv = my::new_sv((char*)"character");
  }
  
  return_sv(type_sv);
}

SV*
iv(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  I32 iv;
  if (self->get_type() == Rstats::ElementsType::INTEGER || self->get_type() == Rstats::ElementsType::LOGICAL) {
    iv = (*self->get_integer_values())[0];
  }
  else {
    iv = 0;
  }
  
  return_sv(my::new_sv(iv));
}

SV*
dv(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  double dv;
  if (self->get_type() == Rstats::ElementsType::DOUBLE) {
    dv = (*self->get_double_values())[0];
  }
  else {
    dv = 0;
  }
  
  return_sv(my::new_sv(dv));
}

SV*
cv(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  SV* str_sv;
  if (self->get_type() == Rstats::ElementsType::CHARACTER) {
    str_sv = (*self->get_character_values())[0];
  }
  else {
    str_sv = my::new_sv((char*)"");
  }
  
  return_sv(str_sv);
}

SV*
re(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  
  double re = ((*self->get_complex_values())[0]).real();
  
  Rstats::Elements* re_element = Rstats::Elements::new_double(re);
  SV* re_element_sv = my::to_perl_obj(re_element, (char*)"Rstats::Elements");

  return_sv(re_element_sv);
}

SV*
im(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  double im = ((*self->get_complex_values())[0]).imag();
  
  Rstats::Elements* im_element = Rstats::Elements::new_double(im);
  SV* im_element_sv = my::to_perl_obj(im_element, (char*)"Rstats::Elements");

  return_sv(im_element_sv);
}

SV*
flag(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  SV* flag_sv;
  if (self->get_type() == Rstats::ElementsType::DOUBLE) {
    if (Rstats::ElementsFunc::is_infinite(self)) {
      double dv = (*self->get_double_values())[0];
      if (dv > 0) {
        flag_sv = my::new_sv((char*)"inf");
      }
      else {
        flag_sv = my::new_sv((char*)"-inf");
      }
    }
    else if(Rstats::ElementsFunc::is_nan(self)) {
      flag_sv = my::new_sv((char*)"nan");
    }
    else {
      flag_sv = my::new_sv((char*)"normal");
    }
  }
  else {
    flag_sv = my::new_sv((char*)"normal");
  }
  
  return_sv(flag_sv);
}

SV*
DESTROY(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  I32 size = self->get_size();
  if (self->get_type() == Rstats::ElementsType::INTEGER || self->get_type() == Rstats::ElementsType::LOGICAL) {
    Rstats::Values::Integer* values = self->get_integer_values();
    delete values;
  }
  else if (self->get_type() == Rstats::ElementsType::DOUBLE) {
    Rstats::Values::Double* values = self->get_double_values();
    delete values;
  }
  else if (self->get_type() == Rstats::ElementsType::COMPLEX) {
    Rstats::Values::Complex* values = self->get_complex_values();
    delete values;
  }
  else if (self->get_type() == Rstats::ElementsType::CHARACTER) {
    Rstats::Values::Character* values = self->get_character_values();
    for (I32 i = 0; i < size; i++) {
      SvREFCNT_dec((*values)[i]);
    }
  }
  delete self;
}

MODULE = Rstats::ElementsFunc PACKAGE = Rstats::ElementsFunc

SV*
complex_double (...)
  PPCODE:
{
  Rstats::Elements* re = my::to_c_obj<Rstats::Elements*>(ST(0));
  Rstats::Elements* im = my::to_c_obj<Rstats::Elements*>(ST(1));
  
  Rstats::Values::Double* re_values = re->get_double_values();
  Rstats::Values::Double* im_values = im->get_double_values();
  
  Rstats::Elements* z = Rstats::Elements::new_complex((*re_values)[0], (*im_values)[0]);
  
  SV* z_sv = my::to_perl_obj(z, (char*)"Rstats::Elements");
  
  return_sv(z_sv);
}

SV*
new_negativeInf(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_negativeInf();
  SV* element_obj = my::to_perl_obj(element, (char*)"Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_Inf(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_Inf();
  SV* element_obj = my::to_perl_obj(element, (char*)"Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_NaN(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_NaN();
  SV* element_obj = my::to_perl_obj(element, (char*)"Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_NA(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_NA();
  SV* element_obj = my::to_perl_obj(element, (char*)"Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_character(...)
  PPCODE:
{
  SV* str_sv = ST(0);
  
  Rstats::Elements* element = Rstats::Elements::new_character(str_sv);
  
  SV* element_obj = my::to_perl_obj(element, (char*)"Rstats::Elements");
  
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
  
  Rstats::Elements* element = Rstats::Elements::new_complex(re, im);
  
  SV* element_obj = my::to_perl_obj(element, (char*)"Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_logical(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  I32 iv = my::iv(value_sv);
  
  Rstats::Elements* element = Rstats::Elements::new_logical((bool)iv);
  
  SV* element_obj = my::to_perl_obj(element, (char*)"Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_true(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_true();
  
  SV* element_obj = my::to_perl_obj(element, (char*)"Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_false(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_false();
  
  SV* element_obj = my::to_perl_obj(element, (char*)"Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_double(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  double dv = my::nv(value_sv);
  
  Rstats::Elements* element = Rstats::Elements::new_double(dv);
  
  SV* element_obj = my::to_perl_obj(element, (char*)"Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_integer(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  I32 iv = my::iv(value_sv);
  
  Rstats::Elements* element = Rstats::Elements::new_integer(iv);
  
  SV* element_obj = my::to_perl_obj(element, (char*)"Rstats::Elements");
  
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
    my::push(idxs_sv, my::new_sv((I32)0)); 
  }
  
  SV* idx_idx_sv = my::new_av_ref();
  for (I32 i = 0; i < values_length; i++) {
    my::push(idx_idx_sv, my::new_sv(i));
  }
  
  SV* x1_sv = my::new_av_ref();
  for (I32 i = 0; i < values_length; i++) {
    SV* value_sv = my::av_get(values_sv, i);
    my::push(x1_sv, my::av_get(value_sv, (I32)0));
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
      
      my::av_set(idxs_sv, i, my::new_sv((I32)0));
      my::av_set(x1_sv, i, my::av_get(my::av_get(values_sv, i), (I32)0));
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
    I32 quotient = (I32)(reminder / dim_product);
    
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
