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
is_na(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  I32 size = self->get_size();
  Rstats::Elements* rets = Rstats::Elements::new_logical_size(size);
  
  Rstats::Values::Integer* values = rets->get_integer_values();
  for (I32 i = 0; i < size; i++) {
    if (self->exists_na_position(i)) {
      (*values)[i] = 1;
    }
    else {
      (*values)[i] = 0;
    }
  }
  
  SV* rets_sv = my::to_perl_obj(rets, "Rstats::Elements");
  
  SV* av_ref = my::new_array_ref();
  my::array_extend(av_ref, 3);
  
  return_sv(rets_sv);
}

SV*
compose(...)
  PPCODE:
{
  SV* mode_sv = ST(1);
  SV* elements_sv = ST(2);
  I32 len = my::array_length(elements_sv);
  
  Rstats::Elements* compose_elements;
  std::vector<I32> na_positions;
  if (sv_cmp(mode_sv, my::new_scalar("character")) == 0) {
    Rstats::Values::Character* values = new Rstats::Values::Character(len);
    for (I32 i = 0; i < len; i++) {
      SV* element_sv = my::array_fetch(elements_sv, i);
      Rstats::Elements* element = my::to_c_obj<Rstats::Elements*>(element_sv);
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
        SV* value_sv = my::new_scalar("");
        (*values)[i] = SvREFCNT_inc(value_sv);
      }
      else
      {
        SV* value_sv = my::new_scalar((*element->get_character_values())[0]);
        (*values)[i] = SvREFCNT_inc(value_sv);
      }
    }
    compose_elements = Rstats::Elements::new_character(values);
  }
  else if (sv_cmp(mode_sv, my::new_scalar("complex")) == 0) {
    Rstats::Values::Complex* values = new Rstats::Values::Complex(len);
    for (I32 i = 0; i < len; i++) {
      SV* element_sv = my::array_fetch(elements_sv, i);
      Rstats::Elements* element = my::to_c_obj<Rstats::Elements*>(element_sv);
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
        (*values)[i] = std::complex<double>(0, 0);
      }
      else
      {
        (*values)[i] = (*element->get_complex_values())[0];
      }
    }
    compose_elements = Rstats::Elements::new_complex(values);
  }
  else if (sv_cmp(mode_sv, my::new_scalar("double")) == 0) {
    Rstats::Values::Double* values = new Rstats::Values::Double(len);
    for (I32 i = 0; i < len; i++) {
      SV* element_sv = my::array_fetch(elements_sv, i);
      Rstats::Elements* element = my::to_c_obj<Rstats::Elements*>(element_sv);
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
        (*values)[i] = 0;
      }
      else
      {
        (*values)[i] = (*element->get_double_values())[0];
      }
    }
    compose_elements = Rstats::Elements::new_double(values);
  }
  else if (sv_cmp(mode_sv, my::new_scalar("integer")) == 0) {
    Rstats::Values::Integer* values = new Rstats::Values::Integer(len);
    for (I32 i = 0; i < len; i++) {
      SV* element_sv = my::array_fetch(elements_sv, i);
      Rstats::Elements* element = my::to_c_obj<Rstats::Elements*>(element_sv);
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
        (*values)[i] = 0;
      }
      else
      {
        (*values)[i] = (*element->get_integer_values())[0];
      }
    }
    compose_elements = Rstats::Elements::new_integer(values);
  }
  else if (sv_cmp(mode_sv, my::new_scalar("logical")) == 0) {
    Rstats::Values::Integer* values = new Rstats::Values::Integer(len);
    for (I32 i = 0; i < len; i++) {
      SV* element_sv = my::array_fetch(elements_sv, i);
      Rstats::Elements* element = my::to_c_obj<Rstats::Elements*>(element_sv);
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
        (*values)[i] = 0;
      }
      else
      {
        (*values)[i] = (*element->get_integer_values())[0];
      }
    }
    compose_elements = Rstats::Elements::new_logical(values);
  }
  else {
    croak("Unknown type(Rstats::Elements::compose)");
  }
  
  for (I32 i = 0; i < na_positions.size(); i++) {
    compose_elements->add_na_position(na_positions[i]);
  }
  
  SV* compose_elements_sv = my::to_perl_obj(compose_elements, "Rstats::Elements");
  
  return_sv(compose_elements_sv);
}

SV*
decompose(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  SV* decompose_elements_sv = my::new_array_ref();
  
  I32 size = self->get_size();
  my::array_extend(decompose_elements_sv, size);

  Rstats::ElementsType::Enum type = self->get_type();
  
  if (type == Rstats::ElementsType::CHARACTER) {
    Rstats::Values::Character* values = self->get_character_values();
    for (I32 i = 0; i < size; i++) {
      Rstats::Elements* elements = Rstats::Elements::new_character((*values)[i]);
      if (self->exists_na_position(i)) {
        elements->add_na_position(0);
      }
      SV* elements_sv = my::to_perl_obj(elements, "Rstats::Elements");
      my::array_push(decompose_elements_sv, elements_sv);
    }
  }
  else if (type == Rstats::ElementsType::COMPLEX) {
    Rstats::Values::Complex* values = self->get_complex_values();
    for (I32 i = 0; i < size; i++) {
      Rstats::Elements* elements = Rstats::Elements::new_complex((*values)[i]);
      if (self->exists_na_position(i)) {
        elements->add_na_position(0);
      }
      SV* elements_sv = my::to_perl_obj(elements, "Rstats::Elements");
      my::array_push(decompose_elements_sv, elements_sv);
    }
  }
  else if (type == Rstats::ElementsType::DOUBLE) {
    Rstats::Values::Double* values = self->get_double_values();
    for (I32 i = 0; i < size; i++) {
      Rstats::Elements* elements = Rstats::Elements::new_double((*values)[i]);
      if (self->exists_na_position(i)) {
        elements->add_na_position(0);
      }
     SV* elements_sv = my::to_perl_obj(elements, "Rstats::Elements");
      my::array_push(decompose_elements_sv, elements_sv);
    }
  }
  else if (type == Rstats::ElementsType::INTEGER) {
    Rstats::Values::Integer* values = self->get_integer_values();
    for (I32 i = 0; i < size; i++) {
      Rstats::Elements* elements = Rstats::Elements::new_integer_iv((*values)[i]);
      if (self->exists_na_position(i)) {
        elements->add_na_position(0);
      }
      SV* elements_sv = my::to_perl_obj(elements, "Rstats::Elements");
      my::array_push(decompose_elements_sv, elements_sv);
    }
  }
  else if (type == Rstats::ElementsType::LOGICAL) {
    Rstats::Values::Integer* values = self->get_integer_values();
    for (I32 i = 0; i < size; i++) {
      Rstats::Elements* elements = Rstats::Elements::new_logical_iv((*values)[i]);
      if (self->exists_na_position(i)) {
        elements->add_na_position(0);
      }
      SV* elements_sv = my::to_perl_obj(elements, "Rstats::Elements");
      my::array_push(decompose_elements_sv, elements_sv);
    }
  }
  
  return_sv(decompose_elements_sv);
}

SV*
is_finite(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* rets = Rstats::ElementsFunc::is_finite(self);

  SV* rets_sv = my::to_perl_obj(rets, "Rstats::Elements");
  
  return_sv(rets_sv);
}

SV*
is_infinite(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  Rstats::Elements* rets = Rstats::ElementsFunc::is_infinite(self);
  
  SV* rets_sv = my::to_perl_obj(rets, "Rstats::Elements");
  
  return_sv(rets_sv);
}

SV*
is_nan(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));

  Rstats::Elements* rets = Rstats::ElementsFunc::is_nan(self);

  SV* rets_sv = my::to_perl_obj(rets, "Rstats::Elements");
  
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
    type_sv = my::new_scalar("logical");
  }
  else if (type == Rstats::ElementsType::INTEGER) {
    type_sv = my::new_scalar("integer");
  }
  else if (type == Rstats::ElementsType::DOUBLE) {
    type_sv = my::new_scalar("double");
  }
  else if (type == Rstats::ElementsType::COMPLEX) {
    type_sv = my::new_scalar("complex");
  }
  else if (type == Rstats::ElementsType::CHARACTER) {
    type_sv = my::new_scalar("character");
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
  
  return_sv(my::new_scalar_iv(iv));
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
  
  return_sv(my::new_scalar_nv(dv));
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
    str_sv = my::new_scalar("");
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
  SV* re_element_sv = my::to_perl_obj(re_element, "Rstats::Elements");

  return_sv(re_element_sv);
}

SV*
im(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  double im = ((*self->get_complex_values())[0]).imag();
  
  Rstats::Elements* im_element = Rstats::Elements::new_double(im);
  SV* im_element_sv = my::to_perl_obj(im_element, "Rstats::Elements");

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
        flag_sv = my::new_scalar("inf");
      }
      else {
        flag_sv = my::new_scalar("-inf");
      }
    }
    else if(Rstats::ElementsFunc::is_nan(self)) {
      flag_sv = my::new_scalar("nan");
    }
    else {
      flag_sv = my::new_scalar("normal");
    }
  }
  else {
    flag_sv = my::new_scalar("normal");
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
  
  SV* z_sv = my::to_perl_obj(z, "Rstats::Elements");
  
  return_sv(z_sv);
}

SV*
new_negativeInf(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_negativeInf();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_Inf(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_Inf();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_NaN(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_NaN();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_NA(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_NA();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_character(...)
  PPCODE:
{
  SV* str_sv = ST(0);
  
  Rstats::Elements* element = Rstats::Elements::new_character(str_sv);
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_complex(...)
  PPCODE:
{
  SV* re_sv = ST(0);
  SV* im_sv = ST(1);

  double re = my::get_nv(re_sv);
  double im = my::get_nv(im_sv);
  
  Rstats::Elements* element = Rstats::Elements::new_complex(re, im);
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_logical(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  I32 iv = my::get_iv(value_sv);
  
  Rstats::Elements* element = Rstats::Elements::new_logical_iv((bool)iv);
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_true(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_true();
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_false(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_false();
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_double(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  double dv = my::get_nv(value_sv);
  
  Rstats::Elements* element = Rstats::Elements::new_double(dv);
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_integer(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  I32 iv = my::get_iv(value_sv);
  
  Rstats::Elements* element = Rstats::Elements::new_integer_iv(iv);
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

MODULE = Rstats::Util PACKAGE = Rstats::Util

SV*
cross_product(...)
  PPCODE:
{
  SV* values_sv = ST(0);
  
  I32 values_length = my::array_length(values_sv);
  SV* idxs_sv = my::new_array_ref();
  for (I32 i = 0; i < values_length; i++) {
    my::array_push(idxs_sv, my::new_scalar_iv(0)); 
  }
  
  SV* idx_idx_sv = my::new_array_ref();
  for (I32 i = 0; i < values_length; i++) {
    my::array_push(idx_idx_sv, my::new_scalar_iv(i));
  }
  
  SV* x1_sv = my::new_array_ref();
  for (I32 i = 0; i < values_length; i++) {
    SV* value_sv = my::array_fetch(values_sv, i);
    my::array_push(x1_sv, my::array_fetch(value_sv, 0));
  }

  SV* result_sv = my::new_array_ref();
  my::array_push(result_sv, my::array_copy(x1_sv));
  I32 end_loop = 0;
  while (1) {
    for (I32 i = 0; i < values_length; i++) {
      
      if (my::get_iv(my::array_fetch(idxs_sv, i)) < my::array_length(my::array_fetch(values_sv, i)) - 1) {
        
        SV* idxs_tmp_sv = my::array_fetch(idxs_sv, i);
        sv_inc(idxs_tmp_sv);
        my::array_store(x1_sv, i, my::array_fetch(my::array_fetch(values_sv, i), my::get_iv(idxs_tmp_sv)));
        
        my::array_push(result_sv, my::array_copy(x1_sv));
        
        break;
      }
      
      if (i == my::get_iv(my::array_fetch(idx_idx_sv, values_length - 1))) {
        end_loop = 1;
        break;
      }
      
      my::array_store(idxs_sv, i, my::new_scalar_iv(0));
      my::array_store(x1_sv, i, my::array_fetch(my::array_fetch(values_sv, i), 0));
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
  
  SV* index_sv = my::new_array_ref();
  I32 pos = my::get_iv(pos_sv);
  I32 before_dim_product = 1;
  for (I32 i = 0; i < my::array_length(my::array_deref(dim_sv)); i++) {
    before_dim_product *= my::get_iv(my::array_fetch(dim_sv, i));
  }
  
  for (I32 i = my::array_length(my::array_deref(dim_sv)) - 1; i >= 0; i--) {
    I32 dim_product = 1;
    for (I32 k = 0; k < i; k++) {
      dim_product *= my::get_iv(my::array_fetch(dim_sv, k));
    }
    
    I32 reminder = pos % before_dim_product;
    I32 quotient = (I32)(reminder / dim_product);
    
    my::array_unshift(index_sv, my::new_scalar_iv(quotient + 1));
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
  for (U32 i = 0; i < my::array_length(my::array_deref(dim_values_sv)); i++) {
    if (i > 0) {
      U32 tmp = 1;
      for (I32 k = 0; k < i; k++) {
        tmp *= my::get_iv(my::array_fetch(dim_values_sv, k));
      }
      pos += tmp * (my::get_iv(my::array_fetch(index_sv, i)) - 1);
    }
    else {
      pos += my::get_iv(my::array_fetch(index_sv, i));
    }
  }
  
  SV* pos_sv = my::new_scalar_iv(pos - 1);
  
  return_sv(pos_sv);
}

MODULE = Rstats PACKAGE = Rstats
