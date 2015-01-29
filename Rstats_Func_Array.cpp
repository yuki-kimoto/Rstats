#include "Rstats.h"

SV* Rstats::Func::Array::new_array(SV* sv_r) {
  
  SV* sv_self = Rstats::pl_new_hv_ref();
  sv_bless(sv_self, gv_stashpv("Rstats::Array", 1));
  
  return sv_self;
}

void Rstats::Func::Array::set_vector(SV* sv_r, SV* sv_a1, Rstats::Vector* v1) {
  SV* sv_vector = Rstats::pl_to_perl_obj<Rstats::Vector*>(v1, "Rstats::Vector");
  Rstats::pl_hv_store(sv_a1, "vector", sv_vector);
}

Rstats::Vector* Rstats::Func::Array::get_vector(SV* sv_r, SV* sv_a1) {
  SV* sv_vector = Rstats::pl_hv_fetch(sv_a1, "vector");
  Rstats::Vector* vector = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_vector);
  return vector;
}

void Rstats::Func::Array::set_dim(SV* sv_r, SV* sv_a1, Rstats::Vector* v1) {
  SV* sv_dim = Rstats::pl_to_perl_obj<Rstats::Vector*>(v1, "Rstats::Vector");
  Rstats::pl_hv_store(sv_a1, "dim", sv_dim);
}

Rstats::Vector* Rstats::Func::Array::get_dim(SV* sv_r, SV* sv_a1) {
  SV* sv_dim = Rstats::pl_hv_fetch(sv_a1, "dim");
  Rstats::Vector* dim = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_dim);
  return dim;
}

SV* Rstats::Func::Array::c(SV* r, SV* sv_elements) {

  IV element_length = Rstats::pl_av_len(sv_elements);
  // Check type and length
  std::map<Rstats::VectorType::Enum, IV> type_h;
  IV length = 0;
  for (IV i = 0; i < element_length; i++) {
    Rstats::VectorType::Enum type;
    SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
    if (sv_isobject(sv_element) && sv_derived_from(sv_element, "Rstats::Array")) {
      length += Rstats::Func::Vector::get_length(Rstats::Func::Array::get_vector(&PL_sv_undef, sv_element));
      type = Rstats::Func::Vector::get_type(Rstats::Func::Array::get_vector(&PL_sv_undef, sv_element));
      type_h[type] = 1;
    }
    else if (sv_isobject(sv_element) && sv_derived_from(sv_element, "Rstats::Vector")) {
      length += Rstats::Func::Vector::get_length(Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element));
      type = Rstats::Func::Vector::get_type(Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element));
      type_h[type] = 1;
    }
    else {
      if (SvOK(sv_element)) {
        if (Rstats::Util::is_perl_number(sv_element)) {
          type_h[Rstats::VectorType::DOUBLE] = 1;
        }
        else {
          type_h[Rstats::VectorType::CHARACTER] = 1;
        }
      }
      else {
        type_h[Rstats::VectorType::LOGICAL] = 1;
      }
      length += 1;
    }
  }

  // Decide type
  Rstats::Vector* v2;
  if (type_h[Rstats::VectorType::CHARACTER]) {
    v2 = Rstats::Func::Vector::new_character(length);
  }
  else if (type_h[Rstats::VectorType::COMPLEX]) {
    v2 = Rstats::Func::Vector::new_complex(length);
  }
  else if (type_h[Rstats::VectorType::DOUBLE]) {
    v2 = Rstats::Func::Vector::new_double(length);
  }
  else if (type_h[Rstats::VectorType::INTEGER]) {
    v2 = Rstats::Func::Vector::new_integer(length);
  }
  else {
    v2 = Rstats::Func::Vector::new_logical(length);
  }
  
  Rstats::VectorType::Enum type = Rstats::Func::Vector::get_type(v2);
  
  IV pos = 0;
  for (IV i = 0; i < element_length; i++) {
    SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
    if (sv_derived_from(sv_element, "Rstats::Array") || sv_derived_from(sv_element, "Rstats::Vector")) {
      
      Rstats::Vector* v1;
      if (sv_derived_from(sv_element, "Rstats::Array")) {
        v1 = Rstats::Func::Array::get_vector(&PL_sv_undef, sv_element);
      }
      else {
        v1 = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
      }
      
      Rstats::Vector* v_tmp;
      if (Rstats::Func::Vector::get_type(v1) == type) {
        v_tmp = v1;
      }
      else {
        if (type == Rstats::VectorType::CHARACTER) {
          v_tmp = Rstats::Func::Vector::as_character(v1);
        }
        else if (type == Rstats::VectorType::COMPLEX) {
          v_tmp = Rstats::Func::Vector::as_complex(v1);
        }
        else if (type == Rstats::VectorType::DOUBLE) {
          v_tmp = Rstats::Func::Vector::as_double(v1);
        }
        else if (type == Rstats::VectorType::INTEGER) {
          v_tmp = Rstats::Func::Vector::as_integer(v1);
        }
        else {
          v_tmp = Rstats::Func::Vector::as_logical(v1);
        }
      }
      
      for (IV k = 0; k < Rstats::Func::Vector::get_length(v_tmp); k++) {
        if (Rstats::Func::Vector::exists_na_position(v_tmp, k)) {
          Rstats::Func::Vector::add_na_position(v2, pos);
        }
        else {
          if (type == Rstats::VectorType::CHARACTER) {
            Rstats::Func::Vector::set_character_value(v2, pos, Rstats::Func::Vector::get_character_value(v_tmp, k));
          }
          else if (type == Rstats::VectorType::COMPLEX) {
            Rstats::Func::Vector::set_complex_value(v2, pos, Rstats::Func::Vector::get_complex_value(v_tmp, k));
          }
          else if (type == Rstats::VectorType::DOUBLE) {
            Rstats::Func::Vector::set_double_value(v2, pos, Rstats::Func::Vector::get_double_value(v_tmp, k));
          }
          else if (type == Rstats::VectorType::INTEGER) {
            Rstats::Func::Vector::set_integer_value(v2, pos, Rstats::Func::Vector::get_integer_value(v_tmp, k));
          }
          else {
            Rstats::Func::Vector::set_integer_value(v2, pos, Rstats::Func::Vector::get_integer_value(v_tmp, k));
          }
        }
        
        pos++;
      }
      
      if (v_tmp != v1) {
        delete v_tmp;
      }
    }
    else {
      if (SvOK(sv_element)) {
        if (type == Rstats::VectorType::CHARACTER) {
          Rstats::Func::Vector::set_character_value(v2, pos, sv_element);
        }
        else if (type == Rstats::VectorType::COMPLEX) {
          Rstats::Func::Vector::set_complex_value(v2, pos, std::complex<NV>(SvNV(sv_element), 0));
        }
        else if (type == Rstats::VectorType::DOUBLE) {
          Rstats::Func::Vector::set_double_value(v2, pos, SvNV(sv_element));
        }
        else if (type == Rstats::VectorType::INTEGER) {
          Rstats::Func::Vector::set_integer_value(v2, pos, SvIV(sv_element));
        }
        else {
          Rstats::Func::Vector::set_integer_value(v2, pos, SvIV(sv_element));
        }
      }
      else {
        Rstats::Func::Vector::add_na_position(v2, pos);
      }
      pos++;
    }
  }
  
  // Array
  SV* sv_x1 = Rstats::Func::Array::new_array(&PL_sv_undef);
  Rstats::Func::Array::set_vector(&PL_sv_undef, sv_x1, v2);

  return sv_x1;
}

SV* Rstats::Func::Array::to_c(SV* sv_r, SV* sv_x) {

  IV is_container = sv_isobject(sv_x) && sv_derived_from(sv_x, "Rstats::Container");
  
  SV* sv_x1;
  if (is_container) {
    sv_x1 = sv_x;
  }
  else {
    SV* sv_tmp = Rstats::pl_new_av_ref();
    Rstats::pl_av_push(sv_tmp, sv_x);
    sv_x1 = Rstats::Func::Array::c(&PL_sv_undef, sv_tmp);
  }
  
  return sv_x1;
}
