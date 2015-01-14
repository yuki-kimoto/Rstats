#include "Rstats.h"

SV* Rstats::ArrayFunc::new_array() {
  
  SV* sv_self = Rstats::pl_new_hv_ref();
  sv_bless(sv_self, gv_stashpv("Rstats::Array", 1));
  
  return sv_self;
}

void Rstats::ArrayFunc::set_vector(SV* sv_a1, Rstats::Vector* v1) {
  SV* sv_vector = Rstats::pl_to_perl_obj<Rstats::Vector*>(v1, "Rstats::Vector");
  Rstats::pl_hv_store(sv_a1, "vector", sv_vector);
}

Rstats::Vector* Rstats::ArrayFunc::get_vector(SV* sv_a1) {
  SV* sv_vector = Rstats::pl_hv_fetch(sv_a1, "vector");
  Rstats::Vector* vector = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_vector);
  return vector;
}

void Rstats::ArrayFunc::set_dim(SV* sv_a1, Rstats::Vector* v1) {
  SV* sv_dim = Rstats::pl_to_perl_obj<Rstats::Vector*>(v1, "Rstats::Vector");
  Rstats::pl_hv_store(sv_a1, "dim", sv_dim);
}

Rstats::Vector* Rstats::ArrayFunc::get_dim(SV* sv_a1) {
  SV* sv_dim = Rstats::pl_hv_fetch(sv_a1, "dim");
  Rstats::Vector* dim = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_dim);
  return dim;
}

SV* Rstats::ArrayFunc::c(SV* sv_elements) {

  IV element_length = Rstats::pl_av_len(sv_elements);
  // Check type and length
  std::map<Rstats::VectorType::Enum, IV> type_h;
  IV length = 0;
  for (IV i = 0; i < element_length; i++) {
    Rstats::VectorType::Enum type;
    SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
    if (sv_isobject(sv_element) && sv_derived_from(sv_element, "Rstats::Array")) {
      length += Rstats::ArrayFunc::get_vector(sv_element)->get_length();
      type = Rstats::ArrayFunc::get_vector(sv_element)->get_type();
      type_h[type] = 1;
    }
    else if (sv_isobject(sv_element) && sv_derived_from(sv_element, "Rstats::Vector")) {
      length += Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element)->get_length();
      type = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element)->get_type();
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
    v2 = Rstats::Vector::new_character(length);
  }
  else if (type_h[Rstats::VectorType::COMPLEX]) {
    v2 = Rstats::Vector::new_complex(length);
  }
  else if (type_h[Rstats::VectorType::DOUBLE]) {
    v2 = Rstats::Vector::new_double(length);
  }
  else if (type_h[Rstats::VectorType::INTEGER]) {
    v2 = Rstats::Vector::new_integer(length);
  }
  else {
    v2 = Rstats::Vector::new_logical(length);
  }
  
  Rstats::VectorType::Enum type = v2->get_type();
  
  IV pos = 0;
  for (IV i = 0; i < element_length; i++) {
    SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
    if (sv_derived_from(sv_element, "Rstats::Array") || sv_derived_from(sv_element, "Rstats::Vector")) {
      
      Rstats::Vector* v1;
      if (sv_derived_from(sv_element, "Rstats::Array")) {
        v1 = Rstats::ArrayFunc::get_vector(sv_element);
      }
      else {
        v1 = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
      }
      
      Rstats::Vector* v_tmp;
      if (v1->get_type() == type) {
        v_tmp = v1;
      }
      else {
        if (type == Rstats::VectorType::CHARACTER) {
          v_tmp = v1->as_character();
        }
        else if (type == Rstats::VectorType::COMPLEX) {
          v_tmp = v1->as_complex();
        }
        else if (type == Rstats::VectorType::DOUBLE) {
          v_tmp = v1->as_double();
        }
        else if (type == Rstats::VectorType::INTEGER) {
          v_tmp = v1->as_integer();
        }
        else {
          v_tmp = v1->as_logical();
        }
      }
      
      for (IV k = 0; k < v_tmp->get_length(); k++) {
        if (v_tmp->exists_na_position(k)) {
          v2->add_na_position(pos);
        }
        else {
          if (type == Rstats::VectorType::CHARACTER) {
            v2->set_character_value(pos, v_tmp->get_character_value(k));
          }
          else if (type == Rstats::VectorType::COMPLEX) {
            v2->set_complex_value(pos, v_tmp->get_complex_value(k));
          }
          else if (type == Rstats::VectorType::DOUBLE) {
            v2->set_double_value(pos, v_tmp->get_double_value(k));
          }
          else if (type == Rstats::VectorType::INTEGER) {
            v2->set_integer_value(pos, v_tmp->get_integer_value(k));
          }
          else {
            v2->set_integer_value(pos, v_tmp->get_integer_value(k));
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
          v2->set_character_value(pos, sv_element);
        }
        else if (type == Rstats::VectorType::COMPLEX) {
          v2->set_complex_value(pos, std::complex<NV>(SvNV(sv_element), 0));
        }
        else if (type == Rstats::VectorType::DOUBLE) {
          v2->set_double_value(pos, SvNV(sv_element));
        }
        else if (type == Rstats::VectorType::INTEGER) {
          v2->set_integer_value(pos, SvIV(sv_element));
        }
        else {
          v2->set_integer_value(pos, SvIV(sv_element));
        }
      }
      else {
        v2->add_na_position(pos);
      }
      pos++;
    }
  }
  
  // Array
  SV* sv_x1 = Rstats::ArrayFunc::new_array();
  Rstats::ArrayFunc::set_vector(sv_x1, v2);

  return sv_x1;
}

SV* Rstats::ArrayFunc::to_c(SV* sv_x) {

  IV is_container = sv_isobject(sv_x) && sv_derived_from(sv_x, "Rstats::Container");
  
  SV* sv_x1;
  if (is_container) {
    sv_x1 = sv_x;
  }
  else {
    SV* sv_tmp = Rstats::pl_new_av_ref();
    Rstats::pl_av_push(sv_tmp, sv_x);
    sv_x1 = Rstats::ArrayFunc::c(sv_tmp);
  }
  
  return sv_x1;
}

