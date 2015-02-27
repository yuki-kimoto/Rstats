#include "Rstats.h"

SV* Rstats::Func::is_matrix(SV* sv_r, SV* sv_x1) {

  bool is = sv_isobject(sv_x1)
    && sv_derived_from(sv_x1, "Rstats::Array")
    && SvIV(length_value(sv_r, get_dim(sv_r, sv_x1))) == 2;
  
  SV* sv_is = is ? Rstats::Func::new_true(sv_r) : Rstats::Func::new_false(sv_r);
  
  return sv_is;
}

SV* Rstats::Func::set_dim(SV* sv_r, SV* sv_x1, SV* sv_x_dim) {
  sv_x_dim = Rstats::Func::to_c(sv_r, sv_x_dim);
  
  SV* sv_x1_length = Rstats::Func::length_value(sv_r, sv_x1);
  IV x1_length = SvIV(sv_x1_length);
  IV x1_length_by_dim = 1;
  
  SV* sv_x_dim_values = values(sv_r, sv_x_dim);
  IV x_dim_values_length = Rstats::pl_av_len(sv_x_dim_values);
  
  for (IV i = 0; i < x_dim_values_length; i++) {
    SV* sv_x_dim_value = Rstats::pl_av_fetch(sv_x_dim_values, i);
    IV x_dim_value = SvIV(sv_x_dim_value);
    x1_length_by_dim *= x_dim_value;
  }
  
  if (x1_length != x1_length_by_dim) {
    croak("dims [product %d] do not match the length of object [%d]", x1_length_by_dim, x1_length);
  }
  
  Rstats::pl_hv_store(sv_x1, "dim", Rstats::Func::as_vector(sv_r, sv_x_dim));
  
  return sv_r;
}

SV* Rstats::Func::get_dim(SV* sv_r, SV* sv_x1) {
  SV* sv_x_dim;
  
  if (Rstats::pl_hv_exists(sv_x1, "dim")) {
    sv_x_dim = Rstats::Func::as_vector(sv_r, Rstats::pl_hv_fetch(sv_x1, "dim"));
  }
  else {
    sv_x_dim = Rstats::Func::new_null(sv_r);
  }
  
  return sv_x_dim;
}

SV* Rstats::Func::values(SV* sv_r, SV* sv_x1) {
  Rstats::Vector* x1 = get_vector(sv_r, sv_x1);
  
  SV* sv_values = Rstats::VectorFunc::get_values(x1);
  
  return sv_values;
}

SV* Rstats::Func::length_value(SV* sv_r, SV* sv_x1) {
  SV* sv_length;
  if (Rstats::pl_hv_exists(sv_x1, "vector")) {
    Rstats::Vector* x1 = get_vector(sv_r, sv_x1);
    IV length = Rstats::VectorFunc::get_length(x1);
    sv_length = Rstats::pl_new_sv_iv(length);
  }
  else {
    SV* sv_list = Rstats::pl_hv_fetch(sv_x1, "list");
    IV length = Rstats::pl_av_len(sv_list);
    sv_length = Rstats::pl_new_sv_iv(length);
  }
  
  return sv_length;
}

SV* Rstats::Func::type(SV* sv_r, SV* sv_x1) {
  
  Rstats::VectorType::Enum type = get_vector(sv_r, sv_x1)->type;
  
  SV* sv_type;
  if (type == Rstats::VectorType::CHARACTER) {
    sv_type = Rstats::pl_new_sv_pv("character");
  }
  else if (type == Rstats::VectorType::COMPLEX) {
    sv_type = Rstats::pl_new_sv_pv("complex");
  }
  else if (type == Rstats::VectorType::DOUBLE) {
    sv_type = Rstats::pl_new_sv_pv("double");
  }
  else if (type == Rstats::VectorType::INTEGER) {
    sv_type = Rstats::pl_new_sv_pv("integer");
  }
  else if (type == Rstats::VectorType::LOGICAL) {
    sv_type = Rstats::pl_new_sv_pv("logical");
  }
  else {
    croak("Invalid type(Rstats::Func::type)"); 
  }
  
  return sv_type;
}

SV* Rstats::Func::is_vector (SV* sv_r, SV* sv_x1) {
  
  bool is =
    sv_isobject(sv_x1)
    && sv_derived_from(sv_x1, "Rstats::Array")
    && !Rstats::pl_hv_exists(sv_x1, "dim");
  
  SV* sv_is = is ? Rstats::pl_new_sv_iv(1) : Rstats::pl_new_sv_iv(0);
  
  SV* sv_values = Rstats::pl_new_av_ref();
  Rstats::pl_av_push(sv_values, sv_is);
  
  return Rstats::Func::new_logical(sv_r, sv_values);
}

IV Rstats::Func::to_bool (SV* sv_r, SV* sv_x1) {
  
  Rstats::Vector* v1 = get_vector(sv_r, sv_x1);
  if (v1->type == Rstats::VectorType::LOGICAL) {
    IV is = Rstats::VectorFunc::get_integer_value(v1, 0);
    return is;
  }
  else {
    croak("to_bool receive logical array");
  }
}

SV* Rstats::Func::is_array(SV* sv_r, SV* sv_x1) {

  bool is = sv_isobject(sv_x1)
    && sv_derived_from(sv_x1, "Rstats::Array")
    && Rstats::pl_hv_exists(sv_x1, "dim");
  
  SV* sv_is = is ? Rstats::Func::new_true(sv_r) : Rstats::Func::new_false(sv_r);
  
  return sv_is;
}

SV* Rstats::Func::pi (SV* sv_r) {
  SV* sv_values = Rstats::pl_new_av_ref();
  NV pi = Rstats::Util::pi();
  SV* sv_pi = Rstats::pl_new_sv_nv(pi);
  Rstats::pl_av_push(sv_values, sv_pi);
  
  return new_double(sv_r, sv_values);
}

SV* Rstats::Func::new_array(SV* sv_r) {
  
  SV* sv_array = Rstats::pl_new_hv_ref();
  sv_bless(sv_array, gv_stashpv("Rstats::Array", 1));
  Rstats::pl_hv_store(sv_array, "r", sv_r);
  
  return sv_array;
}

SV* Rstats::Func::new_character(SV* sv_r, SV* sv_values) {
  SV* sv_x1 = new_null(sv_r);
  I32 length = Rstats::pl_av_len(sv_values);
  
  Rstats::Vector* v1 = Rstats::VectorFunc::new_character(length);
  for (I32 i = 0; i < length; i++) {
    SV* sv_value = Rstats::pl_av_fetch(sv_values, i);

    if (SvOK(sv_value)) {
      Rstats::VectorFunc::set_character_value(
        v1,
        i,
        sv_value
      );
    }
    else {
      Rstats::VectorFunc::add_na_position(v1, i);
    }
  }
  
  set_vector(sv_r, sv_x1, v1);
  
  return sv_x1;
}

SV* Rstats::Func::new_double(SV* sv_r, SV* sv_values) {
  SV* sv_x1 = new_null(sv_r);
  I32 length = Rstats::pl_av_len(sv_values);
  
  Rstats::Vector* v1 = Rstats::VectorFunc::new_double(length);
  for (I32 i = 0; i < length; i++) {
    SV* sv_value = Rstats::pl_av_fetch(sv_values, i);
    
    if (SvOK(sv_value)) {
      Rstats::VectorFunc::set_double_value(
        v1,
        i,
        SvNV(sv_value)
      );
    }
    else {
      Rstats::VectorFunc::add_na_position(v1, i);
    }
  }
  
  set_vector(sv_r, sv_x1, v1);
  
  return sv_x1;
}

SV* Rstats::Func::new_complex(SV* sv_r, SV* sv_values) {
  SV* sv_x1 = new_null(sv_r);
  I32 length = Rstats::pl_av_len(sv_values);
  
  Rstats::Vector* v1 = Rstats::VectorFunc::new_complex(length);
  for (I32 i = 0; i < length; i++) {
    SV* sv_value = Rstats::pl_av_fetch(sv_values, i);
    
    if (SvOK(sv_value)) {
      SV* sv_value_re = Rstats::pl_hv_fetch(sv_value, "re");
      SV* sv_value_im = Rstats::pl_hv_fetch(sv_value, "im");
      NV re = SvNV(sv_value_re);
      NV im = SvNV(sv_value_im);
      
      Rstats::VectorFunc::set_complex_value(
        v1,
        i,
        std::complex<NV>(re, im)
      );
    }
    else {
      Rstats::VectorFunc::add_na_position(v1, i);
    }
  }
  
  set_vector(sv_r, sv_x1, v1);
  
  return sv_x1;
}

SV* Rstats::Func::new_integer(SV* sv_r, SV* sv_values) {
  SV* sv_x1 = new_null(sv_r);
  I32 length = Rstats::pl_av_len(sv_values);
  
  Rstats::Vector* v1 = Rstats::VectorFunc::new_integer(length);
  for (I32 i = 0; i < length; i++) {
    SV* sv_value = Rstats::pl_av_fetch(sv_values, i);
    
    if (SvOK(sv_value)) {
      Rstats::VectorFunc::set_integer_value(
        v1,
        i,
        SvIV(sv_value)
      );
    }
    else {
      Rstats::VectorFunc::add_na_position(v1, i);
    }
  }
  
  set_vector(sv_r, sv_x1, v1);
  
  return sv_x1;
}

SV* Rstats::Func::new_logical(SV* sv_r, SV* sv_values) {
  SV* sv_x1 = new_null(sv_r);
  I32 length = Rstats::pl_av_len(sv_values);
  
  Rstats::Vector* v1 = Rstats::VectorFunc::new_logical(length);
  for (I32 i = 0; i < length; i++) {
    SV* sv_value = Rstats::pl_av_fetch(sv_values, i);
    
    if (SvOK(sv_value)) {
      Rstats::VectorFunc::set_integer_value(
        v1,
        i,
        SvIV(sv_value)
      );
    }
    else {
      Rstats::VectorFunc::add_na_position(v1, i);
    }
  }
  
  set_vector(sv_r, sv_x1, v1);
  
  return sv_x1;
}

void Rstats::Func::set_vector(SV* sv_r, SV* sv_a1, Rstats::Vector* v1) {
  SV* sv_vector = Rstats::pl_to_perl_obj<Rstats::Vector*>(v1, "Rstats::Vector");
  Rstats::pl_hv_store(sv_a1, "vector", sv_vector);
}

Rstats::Vector* Rstats::Func::get_vector(SV* sv_r, SV* sv_a1) {
  SV* sv_vector = Rstats::pl_hv_fetch(sv_a1, "vector");
  Rstats::Vector* vector = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_vector);
  return vector;
}

SV* Rstats::Func::new_null(SV* sv_r) {
  
  SV* sv_x1 = Rstats::Func::new_array(sv_r);;
  set_vector(sv_r, sv_x1, Rstats::VectorFunc::new_null());
  
  return sv_x1;
}

SV* Rstats::Func::new_na(SV* sv_r) {
  SV* sv_x1 = Rstats::Func::new_array(sv_r);;
  set_vector(sv_r, sv_x1, Rstats::VectorFunc::new_na());
  
  return sv_x1;
}

SV* Rstats::Func::new_nan(SV* sv_r) {
  SV* sv_x1 = Rstats::Func::new_array(sv_r);;
  set_vector(sv_r, sv_x1, Rstats::VectorFunc::new_nan());
  
  return sv_x1;
}

SV* Rstats::Func::new_inf(SV* sv_r) {
  SV* sv_x1 = Rstats::Func::new_array(sv_r);;
  set_vector(sv_r, sv_x1, Rstats::VectorFunc::new_inf());
  
  return sv_x1;
}

SV* Rstats::Func::new_false(SV* sv_r) {
  SV* sv_x1 = Rstats::Func::new_array(sv_r);;
  set_vector(sv_r, sv_x1, Rstats::VectorFunc::new_false());
  
  return sv_x1;
}

SV* Rstats::Func::new_true(SV* sv_r) {
  SV* sv_x1 = Rstats::Func::new_array(sv_r);;
  set_vector(sv_r, sv_x1, Rstats::VectorFunc::new_true());
  
  return sv_x1;
}

SV* Rstats::Func::c(SV* sv_r, SV* sv_elements) {

  IV element_length = Rstats::pl_av_len(sv_elements);
  // Check type and length
  std::map<Rstats::VectorType::Enum, IV> type_h;
  IV length = 0;
  for (IV i = 0; i < element_length; i++) {
    Rstats::VectorType::Enum type;
    SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
    if (sv_isobject(sv_element) && sv_derived_from(sv_element, "Rstats::Array")) {
      length += Rstats::VectorFunc::get_length(Rstats::Func::get_vector(sv_r, sv_element));
      type = Rstats::VectorFunc::get_type(Rstats::Func::get_vector(sv_r, sv_element));
      type_h[type] = 1;
    }
    else if (sv_isobject(sv_element) && sv_derived_from(sv_element, "Rstats::Vector")) {
      length += Rstats::VectorFunc::get_length(Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element));
      type = Rstats::VectorFunc::get_type(Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element));
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
    v2 = Rstats::VectorFunc::new_character(length);
  }
  else if (type_h[Rstats::VectorType::COMPLEX]) {
    v2 = Rstats::VectorFunc::new_complex(length);
  }
  else if (type_h[Rstats::VectorType::DOUBLE]) {
    v2 = Rstats::VectorFunc::new_double(length);
  }
  else if (type_h[Rstats::VectorType::INTEGER]) {
    v2 = Rstats::VectorFunc::new_integer(length);
  }
  else {
    v2 = Rstats::VectorFunc::new_logical(length);
  }
  
  Rstats::VectorType::Enum type = Rstats::VectorFunc::get_type(v2);
  
  IV pos = 0;
  for (IV i = 0; i < element_length; i++) {
    SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
    if (sv_derived_from(sv_element, "Rstats::Array") || sv_derived_from(sv_element, "Rstats::Vector")) {
      
      Rstats::Vector* v1;
      if (sv_derived_from(sv_element, "Rstats::Array")) {
        v1 = Rstats::Func::get_vector(sv_r, sv_element);
      }
      else {
        v1 = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_element);
      }
      
      Rstats::Vector* v_tmp;
      if (Rstats::VectorFunc::get_type(v1) == type) {
        v_tmp = v1;
      }
      else {
        if (type == Rstats::VectorType::CHARACTER) {
          v_tmp = Rstats::VectorFunc::as_character(v1);
        }
        else if (type == Rstats::VectorType::COMPLEX) {
          v_tmp = Rstats::VectorFunc::as_complex(v1);
        }
        else if (type == Rstats::VectorType::DOUBLE) {
          v_tmp = Rstats::VectorFunc::as_double(v1);
        }
        else if (type == Rstats::VectorType::INTEGER) {
          v_tmp = Rstats::VectorFunc::as_integer(v1);
        }
        else {
          v_tmp = Rstats::VectorFunc::as_logical(v1);
        }
      }
      
      for (IV k = 0; k < Rstats::VectorFunc::get_length(v_tmp); k++) {
        if (Rstats::VectorFunc::exists_na_position(v_tmp, k)) {
          Rstats::VectorFunc::add_na_position(v2, pos);
        }
        else {
          if (type == Rstats::VectorType::CHARACTER) {
            Rstats::VectorFunc::set_character_value(v2, pos, Rstats::VectorFunc::get_character_value(v_tmp, k));
          }
          else if (type == Rstats::VectorType::COMPLEX) {
            Rstats::VectorFunc::set_complex_value(v2, pos, Rstats::VectorFunc::get_complex_value(v_tmp, k));
          }
          else if (type == Rstats::VectorType::DOUBLE) {
            Rstats::VectorFunc::set_double_value(v2, pos, Rstats::VectorFunc::get_double_value(v_tmp, k));
          }
          else if (type == Rstats::VectorType::INTEGER) {
            Rstats::VectorFunc::set_integer_value(v2, pos, Rstats::VectorFunc::get_integer_value(v_tmp, k));
          }
          else {
            Rstats::VectorFunc::set_integer_value(v2, pos, Rstats::VectorFunc::get_integer_value(v_tmp, k));
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
          Rstats::VectorFunc::set_character_value(v2, pos, sv_element);
        }
        else if (type == Rstats::VectorType::COMPLEX) {
          Rstats::VectorFunc::set_complex_value(v2, pos, std::complex<NV>(SvNV(sv_element), 0));
        }
        else if (type == Rstats::VectorType::DOUBLE) {
          Rstats::VectorFunc::set_double_value(v2, pos, SvNV(sv_element));
        }
        else if (type == Rstats::VectorType::INTEGER) {
          Rstats::VectorFunc::set_integer_value(v2, pos, SvIV(sv_element));
        }
        else {
          Rstats::VectorFunc::set_integer_value(v2, pos, SvIV(sv_element));
        }
      }
      else {
        Rstats::VectorFunc::add_na_position(v2, pos);
      }
      pos++;
    }
  }
  
  // Array
  SV* sv_x1 = Rstats::Func::new_array(sv_r);
  Rstats::Func::set_vector(sv_r, sv_x1, v2);

  return sv_x1;
}

SV* Rstats::Func::to_c(SV* sv_r, SV* sv_x) {

  IV is_container = sv_isobject(sv_x) && sv_derived_from(sv_x, "Rstats::Object");
  
  SV* sv_x1;
  if (is_container) {
    sv_x1 = sv_x;
  }
  else {
    SV* sv_tmp = Rstats::pl_new_av_ref();
    Rstats::pl_av_push(sv_tmp, sv_x);
    sv_x1 = Rstats::Func::c(sv_r, sv_tmp);
  }
  
  return sv_x1;
}

SV* Rstats::Func::is_numeric(SV* sv_r, SV* sv_x1) {
  
  bool is = (to_bool(sv_r, is_array(sv_r, sv_x1)) || to_bool(sv_r, is_vector(sv_r, sv_x1)))
    && (strEQ(SvPV_nolen(type(sv_r, sv_x1)), "double") || strEQ(SvPV_nolen(type(sv_r, sv_x1)), "integer"));
    
  SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
  
  return sv_x_is;
}

SV* Rstats::Func::is_double(SV* sv_r, SV* sv_x1) {
  
  bool is = (to_bool(sv_r, is_array(sv_r, sv_x1)) || to_bool(sv_r, is_vector(sv_r, sv_x1)))
    && strEQ(SvPV_nolen(type(sv_r, sv_x1)), "double");
    
  SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
  
  return sv_x_is;
}

SV* Rstats::Func::is_integer(SV* sv_r, SV* sv_x1) {
  
  bool is = (to_bool(sv_r, is_array(sv_r, sv_x1)) || to_bool(sv_r, is_vector(sv_r, sv_x1)))
    && strEQ(SvPV_nolen(type(sv_r, sv_x1)), "integer");
    
  SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
  
  return sv_x_is;
}

SV* Rstats::Func::is_complex(SV* sv_r, SV* sv_x1) {
  
  bool is = (to_bool(sv_r, is_array(sv_r, sv_x1)) || to_bool(sv_r, is_vector(sv_r, sv_x1)))
    && strEQ(SvPV_nolen(type(sv_r, sv_x1)), "complex");
    
  SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
  
  return sv_x_is;
}

SV* Rstats::Func::is_character(SV* sv_r, SV* sv_x1) {
  
  bool is = (to_bool(sv_r, is_array(sv_r, sv_x1)) || to_bool(sv_r, is_vector(sv_r, sv_x1)))
    && strEQ(SvPV_nolen(type(sv_r, sv_x1)), "character");
    
  SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
  
  return sv_x_is;
}

SV* Rstats::Func::is_logical(SV* sv_r, SV* sv_x1) {
  
  bool is = (to_bool(sv_r, is_array(sv_r, sv_x1)) || to_bool(sv_r, is_vector(sv_r, sv_x1)))
    && strEQ(SvPV_nolen(type(sv_r, sv_x1)), "logical");
    
  SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
  
  return sv_x_is;
}

SV* Rstats::Func::is_data_frame(SV* sv_r, SV* sv_x1) {
  
  bool is = sv_isobject(sv_x1)
    && sv_derived_from(sv_x1, "Rstats::DataFrame");
    
  SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
  
  return sv_x_is;
}

SV* Rstats::Func::is_list(SV* sv_r, SV* sv_x1) {
  
  bool is = sv_isobject(sv_x1)
    && sv_derived_from(sv_x1, "Rstats::List");
    
  SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
  
  return sv_x_is;
}

SV* Rstats::Func::as_vector(SV* sv_r, SV* sv_x1) {
  
  SV* sv_v1 = Rstats::pl_hv_fetch(sv_x1, "vector");
  
  Rstats::Vector* v1 = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_v1);
  
  Rstats::Vector* v2 = Rstats::VectorFunc::clone(v1);
  
  SV* sv_v2 = Rstats::pl_to_perl_obj<Rstats::Vector*>(v2, "Rstats::Vector");
  
  SV* sv_x2 = Rstats::Func::new_null(sv_r);
  Rstats::pl_hv_store(sv_x2, "vector", sv_v2);
  
  return sv_x2;
}

SV* Rstats::Func::new_data_frame(SV* sv_r) {
  SV* sv_data_frame = Rstats::pl_new_hv_ref();
  Rstats::pl_sv_bless(sv_data_frame, "Rstats::DataFrame");
  Rstats::pl_hv_store(sv_data_frame, "r", sv_r);
  
  return sv_data_frame;
}

SV* Rstats::Func::new_list(SV* sv_r) {
  SV* sv_data_frame = Rstats::pl_new_hv_ref();
  Rstats::pl_sv_bless(sv_data_frame, "Rstats::List");
  Rstats::pl_hv_store(sv_data_frame, "r", sv_r);
  
  return sv_data_frame;
}

