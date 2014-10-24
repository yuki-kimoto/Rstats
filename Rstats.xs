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

SV* new_null(...)
  PPCODE:
{
  Rstats::Elements* elements = Rstats::Elements::new_null();
  
  SV* elements_sv = my::to_perl_obj(elements, "Rstats::Elements");
  
  return_sv(elements_sv);
}

SV* length_value(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  I32 length = self->get_length();
  
  return_sv(my::new_scalar_iv(length));
}

SV* length(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  I32 length = self->get_length();
  Rstats::Elements* length_elements = Rstats::Elements::new_double(1, length);
  SV* length_elements_sv = my::to_perl_obj(length_elements, "Rstats::Elements");
  
  return_sv(length_elements_sv);
}

SV*
is_na(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  I32 length = self->get_length();
  Rstats::Elements* rets = Rstats::Elements::new_logical(length);
  
  for (I32 i = 0; i < length; i++) {
    if (self->exists_na_position(i)) {
      rets->set_integer_value(i, 1);
    }
    else {
      rets->set_integer_value(i, 0);
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
    compose_elements = Rstats::Elements::new_character(len);
    for (I32 i = 0; i < len; i++) {
      SV* element_sv = my::array_fetch(elements_sv, i);
      Rstats::Elements* element = my::to_c_obj<Rstats::Elements*>(element_sv);
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
        compose_elements->set_character_value(i, element->get_character_value(0));
      }
    }
  }
  else if (sv_cmp(mode_sv, my::new_scalar("complex")) == 0) {
    compose_elements = Rstats::Elements::new_complex(len);
    for (I32 i = 0; i < len; i++) {
      SV* element_sv = my::array_fetch(elements_sv, i);
      Rstats::Elements* element = my::to_c_obj<Rstats::Elements*>(element_sv);
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
       compose_elements->set_complex_value(i, element->get_complex_value(0));
      }
    }
  }
  else if (sv_cmp(mode_sv, my::new_scalar("double")) == 0) {
    compose_elements = Rstats::Elements::new_double(len);
    for (I32 i = 0; i < len; i++) {
      SV* element_sv = my::array_fetch(elements_sv, i);
      Rstats::Elements* element = my::to_c_obj<Rstats::Elements*>(element_sv);
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
        compose_elements->set_double_value(i, element->get_double_value(0));
      }
    }
  }
  else if (sv_cmp(mode_sv, my::new_scalar("integer")) == 0) {
    compose_elements = Rstats::Elements::new_integer(len);
    Rstats::Values::Integer* values = compose_elements->get_integer_values();
    for (I32 i = 0; i < len; i++) {
      SV* element_sv = my::array_fetch(elements_sv, i);
      Rstats::Elements* element = my::to_c_obj<Rstats::Elements*>(element_sv);
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
        compose_elements->set_integer_value(i, element->get_integer_value(0));
      }
    }
  }
  else if (sv_cmp(mode_sv, my::new_scalar("logical")) == 0) {
    compose_elements = Rstats::Elements::new_logical(len);
    Rstats::Values::Integer* values = compose_elements->get_integer_values();
    for (I32 i = 0; i < len; i++) {
      SV* element_sv = my::array_fetch(elements_sv, i);
      Rstats::Elements* element = my::to_c_obj<Rstats::Elements*>(element_sv);
      if (element->exists_na_position(0)) {
        na_positions.push_back(i);
      }
      else {
        compose_elements->set_integer_value(i, element->get_integer_value(0));
      }
    }
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
  
  I32 length = self->get_length();
  my::array_extend(decompose_elements_sv, length);

  if (self->is_character_type()) {
    for (I32 i = 0; i < length; i++) {
      Rstats::Elements* elements
        = Rstats::Elements::new_character(1, self->get_character_value(i));
      if (self->exists_na_position(i)) {
        elements->add_na_position(0);
      }
      SV* elements_sv = my::to_perl_obj(elements, "Rstats::Elements");
      my::array_push(decompose_elements_sv, elements_sv);
    }
  }
  else if (self->is_complex_type()) {
    for (I32 i = 0; i < length; i++) {
      Rstats::Elements* elements
        = Rstats::Elements::new_complex(1, self->get_complex_value(i));
      if (self->exists_na_position(i)) {
        elements->add_na_position(0);
      }
      SV* elements_sv = my::to_perl_obj(elements, "Rstats::Elements");
      my::array_push(decompose_elements_sv, elements_sv);
    }
  }
  else if (self->is_double_type()) {

    for (I32 i = 0; i < length; i++) {
      Rstats::Elements* elements
        = Rstats::Elements::new_double(1, self->get_double_value(i));
      if (self->exists_na_position(i)) {
        elements->add_na_position(0);
      }
     SV* elements_sv = my::to_perl_obj(elements, "Rstats::Elements");
      my::array_push(decompose_elements_sv, elements_sv);
    }
  }
  else if (self->is_integer_type()) {
    for (I32 i = 0; i < length; i++) {
      Rstats::Elements* elements
        = Rstats::Elements::new_integer(1, self->get_integer_value(i));
      if (self->exists_na_position(i)) {
        elements->add_na_position(0);
      }
      SV* elements_sv = my::to_perl_obj(elements, "Rstats::Elements");
      my::array_push(decompose_elements_sv, elements_sv);
    }
  }
  else if (self->is_logical_type()) {
    for (I32 i = 0; i < length; i++) {
      Rstats::Elements* elements
        = Rstats::Elements::new_logical(1, self->get_integer_value(i));
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
  
  SV* type_sv;

  if (self->is_logical_type()) {
    type_sv = my::new_scalar("logical");
  }
  else if (self->is_integer_type()) {
    type_sv = my::new_scalar("integer");
  }
  else if (self->is_double_type()) {
    type_sv = my::new_scalar("double");
  }
  else if (self->is_complex_type()) {
    type_sv = my::new_scalar("complex");
  }
  else if (self->is_character_type()) {
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
    iv = self->get_integer_value(0);
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
  
  NV dv;
  if (self->get_type() == Rstats::ElementsType::DOUBLE) {
    dv = self->get_double_value(0);
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
  if (self->is_character_type()) {
    str_sv = self->get_character_value(0);
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
  
  
  NV re = self->get_complex_value(0).real();
  
  Rstats::Elements* re_element = Rstats::Elements::new_double(1, re);
  SV* re_element_sv = my::to_perl_obj(re_element, "Rstats::Elements");

  return_sv(re_element_sv);
}

SV*
im(...)
  PPCODE:
{
  Rstats::Elements* self = my::to_c_obj<Rstats::Elements*>(ST(0));
  
  NV im = self->get_complex_value(0).imag();
  
  Rstats::Elements* im_element = Rstats::Elements::new_double(1, im);
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
      NV dv = self->get_double_value(0);
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

  delete self;
}

MODULE = Rstats::ElementsFunc PACKAGE = Rstats::ElementsFunc

SV*
complex_double (...)
  PPCODE:
{
  Rstats::Elements* re = my::to_c_obj<Rstats::Elements*>(ST(0));
  Rstats::Elements* im = my::to_c_obj<Rstats::Elements*>(ST(1));
  
  Rstats::Elements* z = Rstats::Elements::new_complex(
    1,
    std::complex<NV>(re->get_double_value(0), im->get_double_value(0))
  );
  
  SV* z_sv = my::to_perl_obj(z, "Rstats::Elements");
  
  return_sv(z_sv);
}

SV*
new_negative_inf(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_negative_inf();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_inf(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_inf();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_nan(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_nan();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_na(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_na();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_null(...)
  PPCODE:
{
  Rstats::Elements* element = Rstats::Elements::new_null();
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_character(...)
  PPCODE:
{
  SV* str_sv = ST(0);
  
  Rstats::Elements* element = Rstats::Elements::new_character(1, str_sv);
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_complex(...)
  PPCODE:
{
  SV* re_sv = ST(0);
  SV* im_sv = ST(1);

  NV re = my::get_nv(re_sv);
  NV im = my::get_nv(im_sv);
  
  Rstats::Elements* element = Rstats::Elements::new_complex(1, std::complex<NV>(re, im));
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_logical(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  I32 iv = my::get_iv(value_sv);
  
  Rstats::Elements* element = Rstats::Elements::new_logical(1, iv);
  
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
  NV dv = my::get_nv(value_sv);
  
  Rstats::Elements* element = Rstats::Elements::new_double(1, dv);
  
  SV* element_obj = my::to_perl_obj(element, "Rstats::Elements");
  
  return_sv(element_obj);
}

SV*
new_integer(...)
  PPCODE:
{
  SV* value_sv = ST(0);
  I32 iv = my::get_iv(value_sv);
  
  Rstats::Elements* element = Rstats::Elements::new_integer(1, iv);
  
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
