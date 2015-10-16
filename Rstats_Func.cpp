#include "Rstats.h"

// Rstats::Func
namespace Rstats {
  namespace Func {

    Rstats::Integer get_length (SV* sv_r, SV* sv_x1) {

      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);

      if (v1->values == NULL) {
        return 0;
      }
      
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1);
      switch (type) {
        case Rstats::Type::CHARACTER :
          return Rstats::VectorFunc::get_values<Rstats::Character>(v1)->size();
          break;
        case Rstats::Type::COMPLEX :
          return Rstats::VectorFunc::get_values<Rstats::Complex>(v1)->size();
          break;
        case Rstats::Type::DOUBLE :
          return Rstats::VectorFunc::get_values<Rstats::Double>(v1)->size();
          break;
        case Rstats::Type::INTEGER :
        case Rstats::Type::LOGICAL :
          return Rstats::VectorFunc::get_values<Rstats::Integer>(v1)->size();
          break;
      }
    }
    
    SV* as_character(SV* sv_r, SV* sv_x1) {

      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
      
      SV* sv_x2 = Rstats::Func::new_empty_vector<Rstats::Character>(sv_r);
      Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Character>(length);
      if (strEQ(type, "character")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::Character sv_value = Rstats::VectorFunc::get_value<Rstats::Character>(v1, i);
          Rstats::VectorFunc::set_value<Rstats::Character>(v2, i, sv_value);
        }
      }
      else if (strEQ(type, "complex")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::Complex z = Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i);
          Rstats::Double re = z.real();
          Rstats::Double im = z.imag();
          
          SV* sv_re = Rstats::pl_new_sv_nv(re);
          SV* sv_im = Rstats::pl_new_sv_nv(im);
          SV* sv_str = Rstats::pl_new_sv_pv("");
          
          sv_catpv(sv_str, SvPV_nolen(sv_re));
          if (im >= 0) {
            sv_catpv(sv_str, "+");
          }
          sv_catpv(sv_str, SvPV_nolen(sv_im));
          sv_catpv(sv_str, "i");

          Rstats::VectorFunc::set_value<Rstats::Character>(v2, i, sv_str);
        }
      }
      else if (strEQ(type, "double")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::Double value = Rstats::VectorFunc::get_value<Rstats::Double>(v1, i);
          SV* sv_str = Rstats::pl_new_sv_pv("");
          if (std::isinf(value) && value > 0) {
            sv_catpv(sv_str, "Inf");
          }
          else if (std::isinf(value) && value < 0) {
            sv_catpv(sv_str, "-Inf");
          }
          else if (std::isnan(value)) {
            sv_catpv(sv_str, "NaN");
          }
          else {
            sv_catpv(sv_str, SvPV_nolen(Rstats::pl_new_sv_nv(value)));
          }
          Rstats::VectorFunc::set_value<Rstats::Character>(v2, i, sv_str);
        }
      }
      else if (strEQ(type, "integer")) {
        // Factor
        if (to_bool(sv_r, Rstats::Func::is_factor(sv_r, sv_x1))) {
          SV* sv_levels = Rstats::pl_new_hvrv();
          SV* sv_x_levels = Rstats::Func::levels(sv_r, sv_x1);
          SV* sv_x_levels_values = Rstats::Func::values(sv_r, sv_x_levels);
          SV* sv_levels_length = Rstats::Func::length_value(sv_r, sv_x_levels);
          for (IV i = 1; i <= SvIV(sv_levels_length); i++) {
            Rstats::pl_hv_store(
              sv_levels,
              SvPV_nolen(Rstats::pl_new_sv_iv(i)),
              Rstats::pl_av_fetch(sv_x_levels_values, i - 1)
            );
          }
          
          SV* sv_x1_values = Rstats::Func::values(sv_r, sv_x1);
          SV* sv_x2_values = Rstats::pl_new_avrv();
          IV x1_values_length = Rstats::pl_av_len(sv_x1_values);
          for (IV i = 0; i < x1_values_length; i++) {
            SV* sv_x1_value = Rstats::pl_av_fetch(sv_x1_values, i);
             
            if (SvOK(sv_x1_value)) {
              SV* sv_character = Rstats::pl_hv_fetch(sv_levels, SvPV_nolen(sv_x1_value));
              Rstats::pl_av_push(sv_x2_values, Rstats::pl_new_sv_pv(SvPV_nolen(sv_character)));
            }
            else {
              Rstats::pl_av_push(sv_x2_values, &PL_sv_undef);
            }
          }
          sv_x2 = Rstats::Func::c_character(sv_r, sv_x2_values);
          
          Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);
          Rstats::pl_hv_delete(sv_x2, "levels");
          Rstats::pl_hv_delete(sv_x2, "class");
          
          return sv_x2;
        }
        else {
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::VectorFunc::set_value<Rstats::Character>(
              v2, 
              i,
              Rstats::pl_new_sv_iv(Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i))
            );
          }
        }
      }
      else if (strEQ(type, "logical")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          if (Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i)) {
            Rstats::VectorFunc::set_value<Rstats::Character>(v2, i, Rstats::pl_new_sv_pv("TRUE"));
          }
          else {
            Rstats::VectorFunc::set_value<Rstats::Character>(v2, i, Rstats::pl_new_sv_pv("FALSE"));
          }
        }
      }
      else if (strEQ(type, "NULL")) {
        // Nothing to do
      }
      else {
        croak("Error in as_double() : default method not implemented for type '%s'", type);
      }

      Rstats::VectorFunc::merge_na_positions(v2, v1);
      
      Rstats::Func::set_vector(sv_r, sv_x2, v2);
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);
      
      return sv_x2;
    }
    
    SV* as_numeric(SV* sv_r, SV* sv_x1) {
      return Rstats::Func::as_double(sv_r, sv_x1);
    }
    
    SV* as_double(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
      
      SV* sv_x2 = Rstats::Func::new_empty_vector<Rstats::Double>(sv_r);
      Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(length);
      if (strEQ(type, "character")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::Character sv_value = Rstats::VectorFunc::get_value<Rstats::Character>(v1, i);
          SV* sv_value_fix = Rstats::Util::looks_like_double(sv_value);
          if (SvOK(sv_value_fix)) {
            Rstats::Double value = SvNV(sv_value_fix);
            Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, value);
          }
          else {
            warn("NAs introduced by coercion");
            Rstats::VectorFunc::add_na_position(v2, i);
          }
        }
      }
      else if (strEQ(type, "complex")) {
        warn("imaginary parts discarded in coercion");
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i).real());
        }
      }
      else if (strEQ(type, "double")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, Rstats::VectorFunc::get_value<Rstats::Double>(v1, i));
        }
      }
      else if (strEQ(type, "integer")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i));
        }
      }
      else if (strEQ(type, "logical")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i));
        }
      }
      else if (strEQ(type, "NULL")) {
        // Nothing to do
      }
      else {
        croak("Error in as_double() : default method not implemented for type '%s'", type);
      }

      Rstats::VectorFunc::merge_na_positions(v2, v1);
      
      Rstats::Func::set_vector(sv_r, sv_x2, v2);
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);
      
      return sv_x2;
    }
        
    SV* as_complex(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
      
      SV* sv_x2 = Rstats::Func::new_empty_vector<Rstats::Complex>(sv_r);
      Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(length);
      if (strEQ(type, "character")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::Character sv_value = Rstats::VectorFunc::get_value<Rstats::Character>(v1, i);
          SV* sv_z = Rstats::Util::looks_like_complex(sv_value);
          
          if (SvOK(sv_z)) {
            SV* sv_re = Rstats::pl_hv_fetch(sv_z, "re");
            SV* sv_im = Rstats::pl_hv_fetch(sv_z, "im");
            Rstats::Double re = SvNV(sv_re);
            Rstats::Double im = SvNV(sv_im);
            Rstats::VectorFunc::set_value<Rstats::Complex>(v2, i, Rstats::Complex(re, im));
          }
          else {
            warn("NAs introduced by coercion");
            Rstats::VectorFunc::add_na_position(v2, i);
          }
        }
      }
      else if (strEQ(type, "complex")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Complex>(v2, i, Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i));
        }
      }
      else if (strEQ(type, "double")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::Double value = Rstats::VectorFunc::get_value<Rstats::Double>(v1, i);
          if (std::isnan(value)) {
            Rstats::VectorFunc::add_na_position(v2, i);
          }
          else {
            Rstats::VectorFunc::set_value<Rstats::Complex>(v2, i, Rstats::Complex(Rstats::VectorFunc::get_value<Rstats::Double>(v1, i), 0));
          }
        }
      }
      else if (strEQ(type, "integer")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Complex>(v2, i, Rstats::Complex(Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i), 0));
        }
      }
      else if (strEQ(type, "logical")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Complex>(v2, i, Rstats::Complex(Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i), 0));
        }
      }
      else if (strEQ(type, "NULL")) {
        // Nothing to do
      }
      else {
        croak("Error in as_integer() : default method not implemented for type '%s'", type);
      }

      Rstats::VectorFunc::merge_na_positions(v2, v1);
      
      Rstats::Func::set_vector(sv_r, sv_x2, v2);
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);
      
      return sv_x2;
    }
        
    SV* as_integer(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
      
      SV* sv_x2 = Rstats::Func::new_empty_vector<Rstats::Integer>(sv_r);
      Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(length);
      if (strEQ(type, "character")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::Character sv_value = Rstats::VectorFunc::get_value<Rstats::Character>(v1, i);
          SV* sv_value_fix = Rstats::Util::looks_like_double(sv_value);
          if (SvOK(sv_value_fix)) {
            Rstats::Integer value = SvIV(sv_value_fix);
            Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, value);
          }
          else {
            warn("NAs introduced by coercion");
            Rstats::VectorFunc::add_na_position(v2, i);
          }
        }
      }
      else if (strEQ(type, "complex")) {
        warn("imaginary parts discarded in coercion");
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, (Rstats::Integer)Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i).real());
        }
      }
      else if (strEQ(type, "double")) {
        Rstats::Double value;
        for (Rstats::Integer i = 0; i < length; i++) {
          value = Rstats::VectorFunc::get_value<Rstats::Double>(v1, i);
          if (std::isnan(value) || std::isinf(value)) {
            Rstats::VectorFunc::add_na_position(v2, i);
          }
          else {
            Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, (Rstats::Integer)value);
          }
        }
      }
      else if (strEQ(type, "integer")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i));
        }
      }
      else if (strEQ(type, "logical")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i));
        }
      }
      else if (strEQ(type, "NULL")) {
        // Nothing to do
      }
      else {
        croak("Error in as_integer() : default method not implemented for type '%s'", type);
      }

      Rstats::VectorFunc::merge_na_positions(v2, v1);
      
      Rstats::Func::set_vector(sv_r, sv_x2, v2);
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);
      
      return sv_x2;
    }
    
    SV* as_logical(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
      
      SV* sv_x2 = Rstats::Func::new_empty_vector<Rstats::Logical>(sv_r);
      Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Logical>(length);
      if (strEQ(type, "character")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::Character sv_value = Rstats::VectorFunc::get_value<Rstats::Character>(v1, i);
          SV* sv_logical = Rstats::Util::looks_like_logical(sv_value);
          if (SvOK(sv_logical)) {
            if (SvTRUE(sv_logical)) {
              Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, 1);
            }
            else {
              Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, 0);
            }
          }
          else {
            warn("NAs introduced by coercion");
            Rstats::VectorFunc::add_na_position(v2, i);
          }
        }
      }
      else if (strEQ(type, "complex")) {
        warn("imaginary parts discarded in coercion");
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i).real() ? 1 : 0);
        }
      }
      else if (strEQ(type, "double")) {
      
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::Double value = Rstats::VectorFunc::get_value<Rstats::Double>(v1, i);
          if (std::isnan(value)) {
            Rstats::VectorFunc::add_na_position(v2, i);
          }
          else if (std::isinf(value)) {
            Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, 1);
          }
          else {
            Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, value ? 1 : 0);
          }
        }
      }
      else if (strEQ(type, "integer")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i) ? 1 : 0);
        }
      }
      else if (strEQ(type, "logical")) {
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i) ? 1 : 0);
        }
      }
      else if (strEQ(type, "NULL")) {
        // Nothing to do
      }
      else {
        croak("Error in as_integer() : default method not implemented for type '%s'", type);
      }

      Rstats::VectorFunc::merge_na_positions(v2, v1);
      
      Rstats::Func::set_vector(sv_r, sv_x2, v2);
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);
      
      return sv_x2;
    }

    SV* create_sv_values(SV* sv_r, SV* sv_x1) {

      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);

      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      SV* sv_values = Rstats::pl_new_avrv();
      if (!strEQ(type, "NULL")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        
        Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
        
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::pl_av_push(sv_values, Rstats::Func::create_sv_value(sv_r, sv_x1, i));
        }
      }
      
      return sv_values;
    }
    
    SV* create_sv_value(SV* sv_r, SV* sv_x1, Rstats::Integer pos) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      
      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);

      SV* sv_value;
      Rstats::Vector* v2;
      if (strEQ(type, "character")) {
        if (Rstats::VectorFunc::exists_na_position(v1, pos)) {
          sv_value = &PL_sv_undef;
        }
        else {
          sv_value = Rstats::VectorFunc::get_value<Rstats::Character>(v1, pos);
        }
      }
      else if (strEQ(type, "complex")) {
        if (Rstats::VectorFunc::exists_na_position(v1, pos)) {
          sv_value = &PL_sv_undef;
        }
        else {
          Rstats::Complex z = Rstats::VectorFunc::get_value<Rstats::Complex>(v1, pos);
          
          Rstats::Double re = z.real();
          SV* sv_re;
          if (std::isnan(re)) {
            sv_re = Rstats::pl_new_sv_pv("NaN");
          }
          else if (std::isinf(re) && re > 0) {
            sv_re = Rstats::pl_new_sv_pv("Inf");
          }
          else if (std::isinf(re) && re < 0) {
            sv_re = Rstats::pl_new_sv_pv("-Inf");
          }
          else {
            sv_re = Rstats::pl_new_sv_nv(re);
          }
          
          Rstats::Double im = z.imag();
          SV* sv_im;
          if (std::isnan(im)) {
            sv_im = Rstats::pl_new_sv_pv("NaN");
          }
          else if (std::isinf(im) && im > 0) {
            sv_im = Rstats::pl_new_sv_pv("Inf");
          }
          else if (std::isinf(im) && im < 0) {
            sv_im = Rstats::pl_new_sv_pv("-Inf");
          }
          else {
            sv_im = Rstats::pl_new_sv_nv(im);
          }

          sv_value = Rstats::pl_new_hvrv();
          Rstats::pl_hv_store(sv_value, "re", sv_re);
          Rstats::pl_hv_store(sv_value, "im", sv_im);
        }
      }
      else if (strEQ(type, "double")) {
        if (Rstats::VectorFunc::exists_na_position(v1, pos)) {
          sv_value = &PL_sv_undef;
        }
        else {
          Rstats::Double value = Rstats::VectorFunc::get_value<Rstats::Double>(v1, pos);
          if (std::isnan(value)) {
            sv_value = Rstats::pl_new_sv_pv("NaN");
          }
          else if (std::isinf(value) && value > 0) {
            sv_value = Rstats::pl_new_sv_pv("Inf");
          }
          else if (std::isinf(value) && value < 0) {
            sv_value = Rstats::pl_new_sv_pv("-Inf");
          }
          else {
            sv_value = Rstats::pl_new_sv_nv(value);
          }
        }
      }
      else if (strEQ(type, "integer")) {
        if (Rstats::VectorFunc::exists_na_position(v1, pos)) {
          sv_value = &PL_sv_undef;
        }
        else {
          Rstats::Integer value = Rstats::VectorFunc::get_value<Rstats::Integer>(v1, pos);
          sv_value = Rstats::pl_new_sv_iv(value);
        }
      }
      else if (strEQ(type, "logical")) {
        if (Rstats::VectorFunc::exists_na_position(v1, pos)) {
          sv_value = &PL_sv_undef;
        }
        else {
          Rstats::Integer value = Rstats::VectorFunc::get_value<Rstats::Integer>(v1, pos);
          sv_value = Rstats::pl_new_sv_iv(value);
        }
      }
      else {
        croak("Error in create_sv_value : default method not implemented for type '%s'", type);
      }
      
      return sv_value;
    }
        
    SV* cumprod(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      
      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      SV* sv_x2;
      Rstats::Vector* v2;
      if (strEQ(type, "complex")) {
        v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(length);
        Rstats::Complex v2_total(1, 0);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2_total *= Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i);
          Rstats::VectorFunc::set_value<Rstats::Complex>(v2, i, v2_total);
        }
        
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Complex>(sv_r);
      }
      else if (strEQ(type, "double")) {
        v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(length);
        Rstats::Double v2_total(1);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2_total *= Rstats::VectorFunc::get_value<Rstats::Double>(v1, i);
          Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, v2_total);
        }
          
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Double>(sv_r);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(length);
        Rstats::Integer v2_total(1);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2_total *= Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i);
          Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, v2_total);
        }
        
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Integer>(sv_r);
      }
      else {
        croak("Error in cumprod() : non-numeric argument to cumprod()");
      }
      
      Rstats::VectorFunc::merge_na_positions(v2, v1);
      
      set_vector(sv_r, sv_x2, v2);
      
      return sv_x2;
    }
    
    SV* cumsum(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      
      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      SV* sv_x2;
      Rstats::Vector* v2;
      if (strEQ(type, "complex")) {
        v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(length);
        Rstats::Complex v2_total(0, 0);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2_total += Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i);
          Rstats::VectorFunc::set_value<Rstats::Complex>(v2, i, v2_total);
        }
        
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Complex>(sv_r);
      }
      else if (strEQ(type, "double")) {
        v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(length);
        Rstats::Double v2_total(0);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2_total += Rstats::VectorFunc::get_value<Rstats::Double>(v1, i);
          Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, v2_total);
        }
          
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Double>(sv_r);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(length);
        Rstats::Integer v2_total(0);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2_total += Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i);
          Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, v2_total);
        }
        
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Integer>(sv_r);
      }
      else {
        croak("Error in cumsum() : non-numeric argument to cumsum()");
      }
      
      Rstats::VectorFunc::merge_na_positions(v2, v1);
      
      set_vector(sv_r, sv_x2, v2);
      
      return sv_x2;
    }
        
    SV* sum(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      
      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      SV* sv_x2;
      Rstats::Vector* v2;
      if (strEQ(type, "complex")) {
        v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(1);
        Rstats::Complex v2_total(0, 0);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2_total += Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i);
        }
        Rstats::VectorFunc::set_value<Rstats::Complex>(v2, 0, v2_total);
        
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Complex>(sv_r);
      }
      else if (strEQ(type, "double")) {
        v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(1);
        Rstats::Double v2_total(0);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2_total += Rstats::VectorFunc::get_value<Rstats::Double>(v1, i);
        }
        Rstats::VectorFunc::set_value<Rstats::Double>(v2, 0, v2_total);
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Double>(sv_r);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(1);
        Rstats::Integer v2_total(0);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2_total += Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i);
        }
        Rstats::VectorFunc::set_value<Rstats::Integer>(v2, 0, v2_total);
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Integer>(sv_r);
      }
      else {
        croak("Error in sum() : non-numeric argument to sum()");
      }
      
      for (Rstats::Integer i = 0; i < length; i++) {
        if (Rstats::VectorFunc::exists_na_position(v1, i)) {
          Rstats::VectorFunc::add_na_position(v2, 0);
          break;
        }
      }
      
      set_vector(sv_r, sv_x2, v2);
      
      return sv_x2;
    }

    SV* prod(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      
      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      SV* sv_x2;
      Rstats::Vector* v2;
      if (strEQ(type, "complex")) {
        v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(1);
        Rstats::Complex v2_total(1, 0);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2_total *= Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i);
        }
        Rstats::VectorFunc::set_value<Rstats::Complex>(v2, 0, v2_total);
        
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Complex>(sv_r);
      }
      else if (strEQ(type, "double")) {
        v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(1);
        Rstats::Double v2_total(1);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2_total *= Rstats::VectorFunc::get_value<Rstats::Double>(v1, i);
        }
        Rstats::VectorFunc::set_value<Rstats::Double>(v2, 0, v2_total);
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Double>(sv_r);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(1);
        Rstats::Integer v2_total(1);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2_total *= Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i);
        }
        Rstats::VectorFunc::set_value<Rstats::Integer>(v2, 0, v2_total);
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Integer>(sv_r);
      }
      else {
        croak("Error in prod() : non-numeric argument to prod()");
      }
      
      for (Rstats::Integer i = 0; i < length; i++) {
        if (Rstats::VectorFunc::exists_na_position(v1, i)) {
          Rstats::VectorFunc::add_na_position(v2, 0);
          break;
        }
      }
      
      set_vector(sv_r, sv_x2, v2);
      
      return sv_x2;
    }
        
    SV* equal(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_xout;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character, Rstats::Character) = &Rstats::ElementFunc::equal;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "complex")) {
        Rstats::Logical (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::equal;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::equal;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::equal;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in == : default method not implemented for type '%s'", type);
      }
      
      return sv_xout;
    }

    SV* not_equal(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_xout;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character, Rstats::Character) = &Rstats::ElementFunc::not_equal;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "complex")) {
        Rstats::Logical (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::not_equal;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::not_equal;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::not_equal;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in != : default method not implemented for type '%s'", type);
      }
      
      return sv_xout;
    }

    SV* more_than(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_xout;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character, Rstats::Character) = &Rstats::ElementFunc::more_than;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "complex")) {
        croak("Error in > operator : invalid comparison with complex values");
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::more_than;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::more_than;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in > : default method not implemented for type '%s'", type);
      }
      
      return sv_xout;
    }

    SV* less_than(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_xout;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character, Rstats::Character) = &Rstats::ElementFunc::less_than;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "complex")) {
        croak("Error in < operator : invalid comparison with complex values");
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::less_than;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::less_than;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in < : default method not implemented for type '%s'", type);
      }
      
      return sv_xout;
    }

    SV* less_than_or_equal(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_xout;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character, Rstats::Character) = &Rstats::ElementFunc::less_than_or_equal;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "complex")) {
        croak("Error in <= operator : invalid comparison with complex values");
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::less_than_or_equal;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::less_than_or_equal;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in <= : default method not implemented for type '%s'", type);
      }
      
      return sv_xout;
    }

    SV* more_than_or_equal(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_xout;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character, Rstats::Character) = &Rstats::ElementFunc::more_than_or_equal;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "complex")) {
        croak("Error in >= operator : invalid comparison with complex values");
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::more_than_or_equal;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::more_than_or_equal;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in >= : default method not implemented for type '%s'", type);
      }
      
      return sv_xout;
    }

    SV* And(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_xout;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character, Rstats::Character) = &Rstats::ElementFunc::And;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "complex")) {
        Rstats::Logical (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::And;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::And;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::And;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in & : default method not implemented for type '%s'", type);
      }
      
      return sv_xout;
    }

    SV* Or(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_xout;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character, Rstats::Character) = &Rstats::ElementFunc::Or;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "complex")) {
        Rstats::Logical (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::Or;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::Or;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::Or;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in | : default method not implemented for type '%s'", type);
      }
      
      return sv_xout;
    }

    SV* add(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_xout;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::add;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::add;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Integer (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::add;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in + : non-numeric argument to binary operator");
      }
      
      return sv_xout;
    }
    
    SV* subtract(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_xout;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::subtract;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::subtract;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Integer (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::subtract;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in - : non-numeric argument to binary operator");
      }
      
      return sv_xout;
    }

    SV* remainder(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_xout;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "complex")) {
        croak("Error in %% operator: unimplemented complex operation");
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::remainder;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::remainder;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in % operator : non-numeric argument to binary operator");
      }
      
      return sv_xout;
    }

    SV* divide(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_xout;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::divide;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::divide;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::divide;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in / operator : non-numeric argument to binary operator");
      }
      
      return sv_xout;
    }

    SV* atan2(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_xout;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::atan2;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::atan2;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::atan2;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in atan2 : non-numeric argument to atan2");
      }
      
      return sv_xout;
    }

    SV* pow(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_xout;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::pow;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::pow;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::pow;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in pow : non-numeric argument to v");
      }
      
      return sv_xout;
    }
                                        
    SV* multiply(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_xout;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::multiply;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::multiply;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Integer (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::multiply;
        sv_xout = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in * : non-numeric argument to binary operator");
      }
      
      return sv_xout;
    }
                        
    SV* sin(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::sin;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::sin;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::sin;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in sin() : non-numeric argument to sin()");
      }
      
      return sv_x2;
    }

    SV* tanh(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::tanh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::tanh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::tanh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in tanh() : non-numeric argument to tanh()");
      }
      
      return sv_x2;
    }

    SV* cos(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::cos;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::cos;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::cos;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in cos() : non-numeric argument to cos()");
      }
      
      return sv_x2;
    }

    SV* tan(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::tan;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::tan;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::tan;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in tan() : non-numeric argument to tan()");
      }
      
      return sv_x2;
    }

    SV* sinh(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::sinh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::sinh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::sinh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in sinh() : non-numeric argument to sinh()");
      }
      
      return sv_x2;
    }

    SV* cosh(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::cosh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::cosh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::cosh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in cosh() : non-numeric argument to cosh()");
      }
      
      return sv_x2;
    }

    SV* log(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::log;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::log;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::log;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in log() : non-numeric argument to log()");
      }
      
      return sv_x2;
    }

    SV* logb(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::logb;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::logb;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::logb;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in logb() : non-numeric argument to logb()");
      }
      
      return sv_x2;
    }

    SV* log10(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::log10;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::log10;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::log10;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in log10() : non-numeric argument to log10()");
      }
      
      return sv_x2;
    }

    SV* negation(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::negation;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::negation;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Integer (*func)(Rstats::Integer) = &Rstats::ElementFunc::negation;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in negation() : non-numeric argument to negation()");
      }
      
      return sv_x2;
    }

    SV* Arg(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Double (*func)(Rstats::Complex) = &Rstats::ElementFunc::Arg;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::Arg;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::Arg;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in Arg() : non-numeric argument to Arg()");
      }
      
      return sv_x2;
    }

    SV* abs(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Double (*func)(Rstats::Complex) = &Rstats::ElementFunc::abs;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::abs;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::abs;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in abs() : non-numeric argument to abs()");
      }
      
      return sv_x2;
    }

    SV* Mod(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Double (*func)(Rstats::Complex) = &Rstats::ElementFunc::Mod;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::Mod;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::Mod;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in Mod() : non-numeric argument to Mod()");
      }
      
      return sv_x2;
    }

    SV* Re(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Double (*func)(Rstats::Complex) = &Rstats::ElementFunc::Re;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::Re;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::Re;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in Re() : non-numeric argument to Re()");
      }
      
      return sv_x2;
    }

    SV* Im(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Double (*func)(Rstats::Complex) = &Rstats::ElementFunc::Im;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::Im;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::Im;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in Im() : non-numeric argument to Im()");
      }
      
      return sv_x2;
    }
        
    SV* log2(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::log2;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::log2;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::log2;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in log2() : non-numeric argument to log2()");
      }
      
      return sv_x2;
    }

    SV* is_infinite(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Logical (*func)(Rstats::Complex) = &Rstats::ElementFunc::is_infinite;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double) = &Rstats::ElementFunc::is_infinite;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer) = &Rstats::ElementFunc::is_infinite;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in is_infinite() : default method not implemented for type '%s'", type);
      }
      
      return sv_x2;
    }

    SV* is_nan(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character) = &Rstats::ElementFunc::is_nan;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "complex")) {
        Rstats::Logical (*func)(Rstats::Complex) = &Rstats::ElementFunc::is_nan;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double) = &Rstats::ElementFunc::is_nan;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer) = &Rstats::ElementFunc::is_nan;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in is_nan() : default method not implemented for type '%s'", type);
      }
      
      return sv_x2;
    }
    
    SV* is_finite(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Logical (*func)(Rstats::Complex) = &Rstats::ElementFunc::is_finite;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double) = &Rstats::ElementFunc::is_finite;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer) = &Rstats::ElementFunc::is_finite;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in is_finite() : default method not implemented for type '%s'", type);
      }
      
      return sv_x2;
    }
    
    SV* acos(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::acos;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::acos;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::acos;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in acos() : non-numeric argument to acos()");
      }
      
      return sv_x2;
    }

    SV* acosh(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::acosh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::acosh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::acosh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in acosh() : non-numeric argument to acosh()");
      }
      
      return sv_x2;
    }

    SV* asinh(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::asinh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::asinh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::asinh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in asinh() : non-numeric argument to asinh()");
      }
      
      return sv_x2;
    }

    SV* atanh(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::atanh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::atanh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::atanh;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in atanh() : non-numeric argument to atanh()");
      }
      
      return sv_x2;
    }

    SV* Conj(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::Conj;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::Conj;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::Conj;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in Conj() : non-numeric argument to Conj()");
      }
      
      return sv_x2;
    }
    
    SV* asin(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::asin;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::asin;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::asin;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in asin() : non-numeric argument to asin()");
      }
      
      return sv_x2;
    }
    
    SV* atan(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::atan;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::atan;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::atan;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in atan() : non-numeric argument to atan()");
      }
      
      return sv_x2;
    }
    
    SV* sqrt(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::sqrt;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::sqrt;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::sqrt;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in sqrt() : non-numeric argument to sqrt()");
      }
      
      return sv_x2;
    }
    
    SV* expm1(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::expm1;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::expm1;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::expm1;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in expm1() : non-numeric argument to expm1()");
      }
      
      return sv_x2;
    }

    SV* exp(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x2;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::exp;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::exp;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::exp;
        sv_x2 = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in exp() : non-numeric argument to exp()");
      }
      
      return sv_x2;
    }
                      
    SV* upgrade_length_avrv(SV* sv_r, SV* sv_xs) {
      
      IV xs_length = Rstats::pl_av_len(sv_xs);
      IV max_length = 0;
      for (IV i = 0; i < xs_length; i++) {
        SV* sv_x1 = Rstats::pl_av_fetch(sv_xs, i);
        SV* sv_x1_length = Rstats::Func::length_value(sv_r, sv_x1);
        IV x1_length = SvIV(sv_x1_length);
        
        if (x1_length > max_length) {
          max_length = x1_length;
        }
      }
      
      SV* sv_new_xs = Rstats::pl_new_avrv();;
      for (IV i = 0; i < xs_length; i++) {
        SV* sv_x1 = Rstats::pl_av_fetch(sv_xs, i);
        SV* sv_x1_length = Rstats::Func::length_value(sv_r, sv_x1);
        IV x1_length = SvIV(sv_x1_length);
        
        if (x1_length != max_length) {
          Rstats::pl_av_push(
            sv_new_xs,
            Rstats::Func::array(sv_r, sv_x1, Rstats::Func::c_double(sv_r, Rstats::pl_new_sv_iv(max_length)))
          );
        }
        else {
          Rstats::pl_av_push(sv_new_xs, sv_x1);
        }
      }
      
      return sv_new_xs;
    }
    
    void upgrade_length(SV* sv_r, IV num, ...) {
      va_list args;
      
      // Optimization if args count is 2
      va_start(args, num);
      if (num == 2) {
        SV* sv_x1 = *va_arg(args, SV**);
        SV* sv_x2 = *va_arg(args, SV**);

        SV* sv_x1_length = Rstats::Func::length_value(sv_r, sv_x1);
        SV* sv_x2_length = Rstats::Func::length_value(sv_r, sv_x2);
        
        if (SvIV(sv_x1_length) == SvIV(sv_x2_length)) {
          return;
        }
      }
      va_end(args);
      
      SV* sv_args = Rstats::pl_new_avrv();
      va_start(args, num);
      for (IV i = 0; i < num; i++) {
        SV** arg = va_arg(args, SV**);
        SV* x = *arg;
        Rstats::pl_av_push(sv_args, x);
      }
      va_end(args);
      
      SV* sv_result = Rstats::Func::upgrade_length_avrv(sv_r, sv_args);
      
      va_start(args, num);
      for (IV i = 0; i < num; i++) {
        SV** arg = va_arg(args, SV**);
        SV* sv_x = Rstats::pl_av_fetch(sv_result, i);

        *arg = sv_x;
      }
      va_end(args);
    }
        
    void upgrade_type(SV* sv_r, IV num, ...) {
      va_list args;
      
      // Optimization if args count is 2
      va_start(args, num);
      if (num == 2) {
        SV* x1 = *va_arg(args, SV**);
        SV* x2 = *va_arg(args, SV**);
        
        if (
            strEQ(
              SvPV_nolen(Rstats::pl_hv_fetch(x1, "type")),
              SvPV_nolen(Rstats::pl_hv_fetch(x2, "type"))
            )
          )
        {
          return;
        }
      }
      va_end(args);
      
      SV* upgrade_type_args = Rstats::pl_new_avrv();
      va_start(args, num);
      for (IV i = 0; i < num; i++) {
        SV** arg = va_arg(args, SV**);
        SV* x = *arg;
        Rstats::pl_av_push(upgrade_type_args, x);
      }
      va_end(args);
      
      SV* upgrade_type_result = Rstats::Func::upgrade_type_avrv(sv_r, upgrade_type_args);
      
      va_start(args, num);
      for (IV i = 0; i < num; i++) {
        SV** arg = va_arg(args, SV**);
        SV* x = Rstats::pl_av_fetch(upgrade_type_result, i);
        *arg = x;
      }
      va_end(args);
    }
    
    SV* get_type_sv(SV* sv_r, SV* sv_x1) {
      if (sv_isobject(sv_x1) && sv_derived_from(sv_x1, "Rstats::Object")) {
        return Rstats::pl_hv_fetch(sv_x1, "type");
      }
      else {
        return Rstats::pl_new_sv_pv("");
      }
    }

    char* get_type(SV* sv_r, SV* sv_x1) {
      if (sv_isobject(sv_x1) && sv_derived_from(sv_x1, "Rstats::Object")) {
        return SvPV_nolen(Rstats::pl_hv_fetch(sv_x1, "type"));
      }
      else {
        return "";
      }
    }
    
    char* get_object_type(SV* sv_r, SV* sv_x1) {
      if (sv_isobject(sv_x1) && sv_derived_from(sv_x1, "Rstats::Object")) {
        return SvPV_nolen(Rstats::pl_hv_fetch(sv_x1, "object_type"));
      }
      else {
        return "";
      }
    }
    
    SV* as_vector(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
      
      SV* sv_x2;
      Rstats::Vector* v2;
      if (strEQ(type, "character")) {
        v2 = Rstats::VectorFunc::new_vector<Rstats::Character>(length);
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Character>(v2, i, Rstats::VectorFunc::get_value<Rstats::Character>(v1, i));
        }
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Character>(sv_r);
      }
      else if (strEQ(type, "complex")) {
        v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(length);
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Complex>(v2, i, Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i));
        }
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Complex>(sv_r);
      }
      else if (strEQ(type, "double")) {
        v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(length);
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Double>(v2, i, Rstats::VectorFunc::get_value<Rstats::Double>(v1, i));
        }
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Double>(sv_r);
      }
      else if (strEQ(type, "integer")) {
        v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(length);
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i));
        }
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Integer>(sv_r);
      }
      else if (strEQ(type, "logical")) {
        v2 = Rstats::VectorFunc::new_vector<Rstats::Logical>(length);
        for (Rstats::Integer i = 0; i < length; i++) {
          Rstats::VectorFunc::set_value<Rstats::Integer>(v2, i, Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i));
        }
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Logical>(sv_r);
      }

      Rstats::VectorFunc::merge_na_positions(v2, v1);
      Rstats::Func::set_vector(sv_r, sv_x2, v2);
      
      return sv_x2;
    }

    SV* c(SV* sv_r, SV* sv_elements) {
      
      // Convert to array reference
      if (SvOK(sv_elements) && !SvROK(sv_elements)) {
        SV* sv_elements_tmp = sv_elements;
        sv_elements = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_elements, sv_elements_tmp);
      }
      
      IV element_length = Rstats::pl_av_len(sv_elements);
      // Check type and length
      std::map<Rstats::Type::Enum, IV> type_h;
      IV length = 0;
      for (IV i = 0; i < element_length; i++) {
        Rstats::Type::Enum type;
        SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
        
        if (to_bool(sv_r, Rstats::Func::is_vector(sv_r, sv_element)) || to_bool(sv_r, Rstats::Func::is_array(sv_r, sv_element))) {
          length += Rstats::Func::get_length(sv_r, sv_element);
          type = Rstats::VectorFunc::get_type(Rstats::Func::get_vector(sv_r, sv_element));
          type_h[type] = 1;
        }
        else {
          if (SvOK(sv_element)) {
            if (Rstats::Util::is_perl_number(sv_element)) {
              type_h[Rstats::Type::DOUBLE] = 1;
            }
            else {
              type_h[Rstats::Type::CHARACTER] = 1;
            }
          }
          else {
            type_h[Rstats::Type::LOGICAL] = 1;
          }
          length += 1;
        }
      }

      SV* sv_x1;

      // Decide type
      Rstats::Vector* v1;
      if (type_h[Rstats::Type::CHARACTER]) {
        v1 = Rstats::VectorFunc::new_vector<Rstats::Character>(length);
        sv_x1 = Rstats::Func::new_empty_vector<Rstats::Character>(sv_r);
      }
      else if (type_h[Rstats::Type::COMPLEX]) {
        v1 = Rstats::VectorFunc::new_vector<Rstats::Complex>(length);
        sv_x1 = Rstats::Func::new_empty_vector<Rstats::Complex>(sv_r);
      }
      else if (type_h[Rstats::Type::DOUBLE]) {
        v1 = Rstats::VectorFunc::new_vector<Rstats::Double>(length);
        sv_x1 = Rstats::Func::new_empty_vector<Rstats::Double>(sv_r);
      }
      else if (type_h[Rstats::Type::INTEGER]) {
        v1 = Rstats::VectorFunc::new_vector<Rstats::Integer>(length);
        sv_x1 = Rstats::Func::new_empty_vector<Rstats::Integer>(sv_r);
      }
      else {
        v1 = Rstats::VectorFunc::new_vector<Rstats::Logical>(length);
        sv_x1 = Rstats::Func::new_empty_vector<Rstats::Logical>(sv_r);
      }
      
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v1);
      
      IV pos = 0;
      for (IV i = 0; i < element_length; i++) {
        SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
        SV* sv_x_tmp;
        if (to_bool(sv_r, Rstats::Func::is_vector(sv_r, sv_element)) || to_bool(sv_r, Rstats::Func::is_array(sv_r, sv_element))) {
          
          Rstats::Type::Enum tmp_type = Rstats::VectorFunc::get_type(Rstats::Func::get_vector(sv_r, sv_element));
          
          if (tmp_type == type) {
            sv_x_tmp = sv_element;
          }
          else {
            if (type == Rstats::Type::CHARACTER) {
              sv_x_tmp = Rstats::Func::as_character(sv_r, sv_element);
            }
            else if (type == Rstats::Type::COMPLEX) {
              sv_x_tmp = Rstats::Func::as_complex(sv_r, sv_element);
            }
            else if (type == Rstats::Type::DOUBLE) {
              sv_x_tmp = Rstats::Func::as_double(sv_r, sv_element);
            }
            else if (type == Rstats::Type::INTEGER) {
              sv_x_tmp = Rstats::Func::as_integer(sv_r, sv_element);
            }
            else {
              sv_x_tmp = Rstats::Func::as_logical(sv_r, sv_element);
            }
          }

          Rstats::Vector* v_tmp = Rstats::Func::get_vector(sv_r, sv_x_tmp);
          
          for (IV k = 0; k < Rstats::Func::get_length(sv_r, sv_x_tmp); k++) {
            if (Rstats::VectorFunc::exists_na_position(v_tmp, k)) {
              Rstats::VectorFunc::add_na_position(v1, pos);
            }
            else {
              if (type == Rstats::Type::CHARACTER) {
                Rstats::VectorFunc::set_value<Rstats::Character>(v1, pos, Rstats::VectorFunc::get_value<Rstats::Character>(v_tmp, k));
              }
              else if (type == Rstats::Type::COMPLEX) {
                Rstats::VectorFunc::set_value<Rstats::Complex>(v1, pos, Rstats::VectorFunc::get_value<Rstats::Complex>(v_tmp, k));
              }
              else if (type == Rstats::Type::DOUBLE) {
                Rstats::VectorFunc::set_value<Rstats::Double>(v1, pos, Rstats::VectorFunc::get_value<Rstats::Double>(v_tmp, k));
              }
              else if (type == Rstats::Type::INTEGER) {
                Rstats::VectorFunc::set_value<Rstats::Integer>(v1, pos, Rstats::VectorFunc::get_value<Rstats::Integer>(v_tmp, k));
              }
              else {
                Rstats::VectorFunc::set_value<Rstats::Integer>(v1, pos, Rstats::VectorFunc::get_value<Rstats::Integer>(v_tmp, k));
              }
            }
            
            pos++;
          }
        }
        else {
          if (SvOK(sv_element)) {
            if (type == Rstats::Type::CHARACTER) {
              Rstats::VectorFunc::set_value<Rstats::Character>(v1, pos, sv_element);
            }
            else if (type == Rstats::Type::COMPLEX) {
              Rstats::VectorFunc::set_value<Rstats::Complex>(v1, pos, std::complex<NV>(SvNV(sv_element), 0));
            }
            else if (type == Rstats::Type::DOUBLE) {
              Rstats::VectorFunc::set_value<Rstats::Double>(v1, pos, SvNV(sv_element));
            }
            else if (type == Rstats::Type::INTEGER) {
              Rstats::VectorFunc::set_value<Rstats::Integer>(v1, pos, SvIV(sv_element));
            }
            else {
              Rstats::VectorFunc::set_value<Rstats::Integer>(v1, pos, SvIV(sv_element));
            }
          }
          else {
            Rstats::VectorFunc::add_na_position(v1, pos);
          }
          pos++;
        }
      }
      
      // Array
      Rstats::Func::set_vector(sv_r, sv_x1, v1);

      return sv_x1;
    }

    SV* new_vector(SV* sv_r) {
      
      SV* sv_x1 = Rstats::pl_new_hvrv();
      sv_bless(sv_x1, gv_stashpv("Rstats::Object", 1));
      Rstats::pl_hv_store(sv_x1, "r", sv_r);
      Rstats::pl_hv_store(sv_x1, "object_type", Rstats::pl_new_sv_pv("array"));

      Rstats::Vector* v1 = Rstats::VectorFunc::new_empty_vector();
      v1->values = NULL;
      v1->type = Rstats::Type::LOGICAL;
      
      set_vector(sv_r, sv_x1, v1);
      
      return sv_x1;
    }
    
    SV* array(SV* sv_r, SV* sv_x1) {
      SV* sv_args_h = Rstats::pl_new_hvrv();
      Rstats::pl_hv_store(sv_args_h, "x", sv_x1);
      return Rstats::Func::array_with_opt(sv_r, sv_args_h);
    }
    
    SV* array(SV* sv_r, SV* sv_x1, SV* sv_dim) {
      
      SV* sv_args_h = Rstats::pl_new_hvrv();
      Rstats::pl_hv_store(sv_args_h, "x", sv_x1);
      Rstats::pl_hv_store(sv_args_h, "dim", sv_dim);
      return Rstats::Func::array_with_opt(sv_r, sv_args_h);
    }
    
    SV* array_with_opt(SV* sv_r, SV* sv_args_h) {

      SV* sv_x1 = Rstats::pl_hv_fetch(sv_args_h, "x");
     
      // Dimention
      SV* sv_x_dim = Rstats::pl_hv_exists(sv_args_h, "dim")
        ? Rstats::pl_hv_fetch(sv_args_h, "dim") : Rstats::Func::new_null(sv_r);
      SV* sv_x1_length = Rstats::Func::length_value(sv_r, sv_x1);

      
      Rstats::Func::length_value(sv_r, sv_x_dim);
      
      if (!SvIV(Rstats::Func::length_value(sv_r, sv_x_dim))) {
        sv_x_dim = Rstats::Func::c_integer(sv_r, sv_x1_length);
      }
      IV dim_product = 1;
      IV x_dim_length = SvIV(Rstats::Func::length_value(sv_r, sv_x_dim));
      for (IV i = 0; i < x_dim_length; i++) {
        SV* sv_values = Rstats::Func::values(sv_r, sv_x_dim);
        dim_product *= SvIV(Rstats::pl_av_fetch(sv_values, i));
      }

      
      // Fix elements length
      SV* sv_elements;
      if (SvIV(sv_x1_length) == dim_product) {
        sv_elements = Rstats::Func::decompose(sv_r, sv_x1);
      }
      else if (SvIV(sv_x1_length) > dim_product) {
        SV* sv_elements_tmp = Rstats::Func::decompose(sv_r, sv_x1);
        sv_elements = Rstats::pl_new_avrv();
        for (IV i = 0; i < dim_product; i++) {
          Rstats::pl_av_push(sv_elements, Rstats::pl_av_fetch(sv_elements_tmp, i));
        }
      }
      else if (SvIV(sv_x1_length) < dim_product) {
        SV* sv_elements_tmp = Rstats::Func::decompose(sv_r, sv_x1);
        IV elements_tmp_length = Rstats::pl_av_len(sv_elements_tmp);
        IV repeat_count = (IV)(dim_product / elements_tmp_length) + 1;
        SV* sv_elements_tmp2 = Rstats::pl_new_avrv();
        IV elements_tmp2_length = Rstats::pl_av_len(sv_elements_tmp2);
        for (IV i = 0; i < repeat_count; i++) {
          for (IV k = 0; k < elements_tmp_length; k++) {
            Rstats::pl_av_push(sv_elements_tmp2, Rstats::pl_av_fetch(sv_elements_tmp, k));
          }
        }
        sv_elements = Rstats::pl_new_avrv();
        for (IV i = 0; i < dim_product; i++) {
          Rstats::pl_av_push(sv_elements, Rstats::pl_av_fetch(sv_elements_tmp2, i));
        }
      }
      
      SV* sv_x2 = Rstats::Func::c(sv_r, sv_elements);
      Rstats::Func::dim(sv_r, sv_x2, sv_x_dim);
      
      return sv_x2;
    }

    SV* upgrade_type_avrv(SV* sv_r, SV* sv_xs) {
      // Check elements
      std::map<Rstats::Type::Enum, IV> type_h;
      
      IV xs_length = Rstats::pl_av_len(sv_xs);
      for (IV i = 0; i < xs_length; i++) {
        SV* sv_x1 = Rstats::pl_av_fetch(sv_xs, i);
        Rstats::Vector* x1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Type::Enum type = Rstats::VectorFunc::get_type(x1);
        
        if (type == Rstats::Type::CHARACTER) {
          type_h[Rstats::Type::CHARACTER] = 1;
        }
        else if (type == Rstats::Type::COMPLEX) {
          type_h[Rstats::Type::COMPLEX] = 1;
        }
        else if (type == Rstats::Type::DOUBLE) {
          type_h[Rstats::Type::DOUBLE] = 1;
        }
        else if (type == Rstats::Type::INTEGER) {
          type_h[Rstats::Type::INTEGER] = 1;
        }
        else if (type == Rstats::Type::LOGICAL) {
          type_h[Rstats::Type::LOGICAL] = 1;
        }
        else {
          croak("Invalid type(Rstats::Func::upgrade_type_avrv()");
        }
      }

      // Upgrade elements and type if type is different
      SV* sv_new_xs = Rstats::pl_new_avrv();;
      IV type_length = type_h.size();

      if (type_length > 1) {
        SV* sv_to_type;
        if (type_h.count(Rstats::Type::CHARACTER)) {
          sv_to_type = Rstats::pl_new_sv_pv("character");
        }
        else if (type_h.count(Rstats::Type::COMPLEX)) {
          sv_to_type = Rstats::pl_new_sv_pv("complex");
        }
        else if (type_h.count(Rstats::Type::DOUBLE)) {
          sv_to_type = Rstats::pl_new_sv_pv("double");
        }
        else if (type_h.count(Rstats::Type::INTEGER)) {
          sv_to_type = Rstats::pl_new_sv_pv("integer");
        }
        else if (type_h.count(Rstats::Type::LOGICAL)) {
          sv_to_type = Rstats::pl_new_sv_pv("logical");
        }
        
        for (IV i = 0; i < xs_length; i++) {
          SV* sv_x = Rstats::pl_av_fetch(sv_xs, i);
          Rstats::pl_av_push(sv_new_xs, Rstats::Func::as(sv_r, sv_to_type, sv_x));
        }
      }
      else {
        sv_new_xs = sv_xs;
      }
      
      return sv_new_xs;
    }
    
    SV* dim(SV* sv_r, SV* sv_x1, SV* sv_x_dim) {
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

    SV* dim(SV* sv_r, SV* sv_x1) {
      SV* sv_x_dim;
      
      if (Rstats::pl_hv_exists(sv_x1, "dim")) {
        sv_x_dim = Rstats::Func::as_vector(sv_r, Rstats::pl_hv_fetch(sv_x1, "dim"));
      }
      else {
        sv_x_dim = Rstats::Func::new_null(sv_r);
      }
      
      return sv_x_dim;
    }

    SV* values(SV* sv_r, SV* sv_x1) {
      
      SV* sv_values = Rstats::Func::create_sv_values(sv_r, sv_x1);
      
      return sv_values;
    }

    SV* length_value(SV* sv_r, SV* sv_x1) {
      SV* sv_length;
      
      if (strEQ(SvPV_nolen(Rstats::pl_hv_fetch(sv_x1, "object_type")), "NULL")) {
        sv_length = Rstats::pl_new_sv_iv(0);
      }
      else if (Rstats::pl_hv_exists(sv_x1, "vector")) {
        Rstats::Vector* x1 = get_vector(sv_r, sv_x1);
        IV length = Rstats::Func::get_length(sv_r, sv_x1);
        sv_length = Rstats::pl_new_sv_iv(length);
      }
      else {
        SV* sv_list = Rstats::pl_hv_fetch(sv_x1, "list");
        IV length = Rstats::pl_av_len(sv_list);
        sv_length = Rstats::pl_new_sv_iv(length);
      }
      
      return sv_length;
    }

    SV* Typeof(SV* sv_r, SV* sv_x1) {
      
      SV* sv_x2 = Rstats::Func::c_character(sv_r, Rstats::pl_new_sv_pv(Rstats::Func::get_type(sv_r, sv_x1)));
      
      return sv_x2;
    }
    
    SV* type(SV* sv_r, SV* sv_x1) {
      
      Rstats::Type::Enum type = get_vector(sv_r, sv_x1)->type;
      
      SV* sv_type;
      if (type == Rstats::Type::CHARACTER) {
        sv_type = Rstats::pl_new_sv_pv("character");
      }
      else if (type == Rstats::Type::COMPLEX) {
        sv_type = Rstats::pl_new_sv_pv("complex");
      }
      else if (type == Rstats::Type::DOUBLE) {
        sv_type = Rstats::pl_new_sv_pv("double");
      }
      else if (type == Rstats::Type::INTEGER) {
        sv_type = Rstats::pl_new_sv_pv("integer");
      }
      else if (type == Rstats::Type::LOGICAL) {
        sv_type = Rstats::pl_new_sv_pv("logical");
      }
      else {
        croak("Invalid type(Rstats::Func::type)"); 
      }
      
      return sv_type;
    }

    SV* is_null (SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "NULL");
      
      SV* sv_is = is ? Rstats::Func::new_true(sv_r) : Rstats::Func::new_false(sv_r);
            
      return sv_is;
    }
    
    SV* is_vector (SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_object_type(sv_r, sv_x1), "array")
        && !Rstats::pl_hv_exists(sv_x1, "dim");
      
      SV* sv_is = is ? Rstats::Func::new_true(sv_r) : Rstats::Func::new_false(sv_r);
            
      return sv_is;
    }

    SV* is_array(SV* sv_r, SV* sv_x1) {

      bool is = strEQ(Rstats::Func::get_object_type(sv_r, sv_x1), "array")
        && Rstats::pl_hv_exists(sv_x1, "dim");
      
      SV* sv_is = is ? Rstats::Func::new_true(sv_r) : Rstats::Func::new_false(sv_r);
      
      return sv_is;
    }

    SV* is_matrix(SV* sv_r, SV* sv_x1) {

      bool is = strEQ(Rstats::Func::get_object_type(sv_r, sv_x1), "array")
        && SvIV(length_value(sv_r, dim(sv_r, sv_x1))) == 2;
      
      SV* sv_is = is ? Rstats::Func::new_true(sv_r) : Rstats::Func::new_false(sv_r);
      
      return sv_is;
    }

    IV to_bool (SV* sv_r, SV* sv_x1) {
      
      Rstats::Vector* v1 = get_vector(sv_r, sv_x1);
      if (v1->type == Rstats::Type::LOGICAL) {
        IV is = Rstats::VectorFunc::get_value<Rstats::Integer>(v1, 0);
        return is;
      }
      else {
        croak("to_bool receive logical array");
      }
    }

    SV* pi (SV* sv_r) {
      SV* sv_values = Rstats::pl_new_avrv();
      NV pi = Rstats::Util::pi();
      SV* sv_pi = Rstats::pl_new_sv_nv(pi);
      Rstats::pl_av_push(sv_values, sv_pi);
      
      return c_double(sv_r, sv_values);
    }

    SV* c_character(SV* sv_r, SV* sv_values) {
      if (!sv_derived_from(sv_values, "ARRAY")) {
        SV* sv_values_av_ref = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_values_av_ref, sv_values);
        sv_values = sv_values_av_ref;
      }
      
      IV length = Rstats::pl_av_len(sv_values);
      
      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Character>(length);
      for (IV i = 0; i < length; i++) {
        SV* sv_value = Rstats::pl_av_fetch(sv_values, i);

        if (SvOK(sv_value)) {
          Rstats::VectorFunc::set_value<Rstats::Character>(
            v1,
            i,
            sv_value
          );
        }
        else {
          Rstats::VectorFunc::add_na_position(v1, i);
        }
      }
      
      SV* sv_x1 = new_empty_vector<Rstats::Character>(sv_r);
      set_vector(sv_r, sv_x1, v1);
      
      return sv_x1;
    }

    template <>
    SV* new_empty_vector<Rstats::Character>(SV* sv_r) {
      SV* sv_x1 = Rstats::pl_new_hvrv();
      
      sv_bless(sv_x1, gv_stashpv("Rstats::Object", 1));
      Rstats::pl_hv_store(sv_x1, "r", sv_r);
      Rstats::pl_hv_store(sv_x1, "object_type", Rstats::pl_new_sv_pv("array"));
      Rstats::pl_hv_store(sv_x1, "type", Rstats::pl_new_sv_pv("character"));
      
      return sv_x1;
    }

    template <>
    SV* new_empty_vector<Rstats::Complex>(SV* sv_r) {
      SV* sv_x1 = Rstats::pl_new_hvrv();
      
      sv_bless(sv_x1, gv_stashpv("Rstats::Object", 1));
      Rstats::pl_hv_store(sv_x1, "r", sv_r);
      Rstats::pl_hv_store(sv_x1, "object_type", Rstats::pl_new_sv_pv("array"));
      Rstats::pl_hv_store(sv_x1, "type", Rstats::pl_new_sv_pv("complex"));
      
      return sv_x1;
    }
    
    template <>
    SV* new_empty_vector<Rstats::Double>(SV* sv_r) {
      SV* sv_x1 = Rstats::pl_new_hvrv();
      
      sv_bless(sv_x1, gv_stashpv("Rstats::Object", 1));
      Rstats::pl_hv_store(sv_x1, "r", sv_r);
      Rstats::pl_hv_store(sv_x1, "object_type", Rstats::pl_new_sv_pv("array"));
      Rstats::pl_hv_store(sv_x1, "type", Rstats::pl_new_sv_pv("double"));
      
      return sv_x1;
    }

    template <>
    SV* new_empty_vector<Rstats::Integer>(SV* sv_r) {
      SV* sv_x1 = Rstats::pl_new_hvrv();
      
      sv_bless(sv_x1, gv_stashpv("Rstats::Object", 1));
      Rstats::pl_hv_store(sv_x1, "r", sv_r);
      Rstats::pl_hv_store(sv_x1, "object_type", Rstats::pl_new_sv_pv("array"));
      Rstats::pl_hv_store(sv_x1, "type", Rstats::pl_new_sv_pv("integer"));
      
      return sv_x1;
    }

    template <>
    SV* new_empty_vector<Rstats::Logical>(SV* sv_r) {
      SV* sv_x1 = Rstats::pl_new_hvrv();
      
      sv_bless(sv_x1, gv_stashpv("Rstats::Object", 1));
      Rstats::pl_hv_store(sv_x1, "r", sv_r);
      Rstats::pl_hv_store(sv_x1, "object_type", Rstats::pl_new_sv_pv("array"));
      Rstats::pl_hv_store(sv_x1, "type", Rstats::pl_new_sv_pv("logical"));
      
      return sv_x1;
    }
    
    SV* c_double(SV* sv_r, SV* sv_values) {
      
      if (!sv_derived_from(sv_values, "ARRAY")) {
        SV* sv_values_av_ref = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_values_av_ref, sv_values);
        sv_values = sv_values_av_ref;
      }
      
      IV length = Rstats::pl_av_len(sv_values);
      
      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Double>(length);
      for (IV i = 0; i < length; i++) {
        SV* sv_value = Rstats::pl_av_fetch(sv_values, i);

        if (SvOK(sv_value)) {
          char* sv_value_str = SvPV_nolen(sv_value);
          if (strEQ(sv_value_str, "NaN")) {
            Rstats::VectorFunc::set_value<Rstats::Double>(v1, i, NAN);
          }
          else if (strEQ(sv_value_str, "Inf")) {
            Rstats::VectorFunc::set_value<Rstats::Double>(v1, i, INFINITY);
          }
          else if (strEQ(sv_value_str, "-Inf")) {
            Rstats::VectorFunc::set_value<Rstats::Double>(v1, i, -(INFINITY));
          }
          else {
            NV value = SvNV(sv_value);
            Rstats::VectorFunc::set_value<Rstats::Double>(v1, i, value);
          }
        }
        else {
          Rstats::VectorFunc::add_na_position(v1, i);
        }
      }
      
      SV* sv_x1 = new_empty_vector<Rstats::Double>(sv_r);
      set_vector(sv_r, sv_x1, v1);
      
      return sv_x1;
    }

    SV* c_complex(SV* sv_r, SV* sv_values) {
      if (!sv_derived_from(sv_values, "ARRAY")) {
        SV* sv_values_av_ref = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_values_av_ref, sv_values);
        sv_values = sv_values_av_ref;
      }
      
      IV length = Rstats::pl_av_len(sv_values);
      
      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Complex>(length);
      for (IV i = 0; i < length; i++) {
        SV* sv_value = Rstats::pl_av_fetch(sv_values, i);
        
        if (SvOK(sv_value)) {
          SV* sv_value_re = Rstats::pl_hv_fetch(sv_value, "re");
          SV* sv_value_im = Rstats::pl_hv_fetch(sv_value, "im");

          NV re;
          if (SvOK(sv_value_re)) {
            char* sv_value_re_str = SvPV_nolen(sv_value_re);
            if (strEQ(sv_value_re_str, "NaN")) {
              re = NAN;
            }
            else if (strEQ(sv_value_re_str, "Inf")) {
              re = INFINITY;
            }
            else if (strEQ(sv_value_re_str, "-Inf")) {
              re = -(INFINITY);
            }
            else {
              re = SvNV(sv_value_re);
            }
          }
          else {
            re = 0;
          }
          

          NV im;
          if (SvOK(sv_value_im)) {
            char* sv_value_im_str = SvPV_nolen(sv_value_im);
            if (strEQ(sv_value_im_str, "NaN")) {
              im = NAN;
            }
            else if (strEQ(sv_value_im_str, "Inf")) {
              im = INFINITY;
            }
            else if (strEQ(sv_value_im_str, "-Inf")) {
              im = -(INFINITY);
            }
            else {
              im = SvNV(sv_value_im);
            }
          }
          else {
            im = 0;
          }
          
          Rstats::VectorFunc::set_value<Rstats::Complex>(
            v1,
            i,
            std::complex<NV>(re, im)
          );
        }
        else {
          Rstats::VectorFunc::add_na_position(v1, i);
        }
      }
      
      SV* sv_x1 = new_empty_vector<Rstats::Complex>(sv_r);
      set_vector(sv_r, sv_x1, v1);
      
      return sv_x1;
    }

    SV* c_integer(SV* sv_r, SV* sv_values) {
      if (!sv_derived_from(sv_values, "ARRAY")) {
        SV* sv_values_av_ref = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_values_av_ref, sv_values);
        sv_values = sv_values_av_ref;
      }
      
      IV length = Rstats::pl_av_len(sv_values);
      
      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Integer>(length);
      for (IV i = 0; i < length; i++) {
        SV* sv_value = Rstats::pl_av_fetch(sv_values, i);
        
        if (SvOK(sv_value)) {
          Rstats::VectorFunc::set_value<Rstats::Integer>(
            v1,
            i,
            SvIV(sv_value)
          );
        }
        else {
          Rstats::VectorFunc::add_na_position(v1, i);
        }
      }
      
      SV* sv_x1 = new_empty_vector<Rstats::Integer>(sv_r);
      set_vector(sv_r, sv_x1, v1);
      
      return sv_x1;
    }

    SV* c_integer(SV* sv_r, IV value) {
      return Rstats::Func::c_integer(sv_r, Rstats::pl_new_sv_iv(value));
    }

    SV* c_logical(SV* sv_r, SV* sv_values) {
      if (!sv_derived_from(sv_values, "ARRAY")) {
        SV* sv_values_av_ref = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_values_av_ref, sv_values);
        sv_values = sv_values_av_ref;
      }
      
      IV length = Rstats::pl_av_len(sv_values);
      
      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Logical>(length);
      for (IV i = 0; i < length; i++) {
        SV* sv_value = Rstats::pl_av_fetch(sv_values, i);
        
        if (SvOK(sv_value)) {
          Rstats::VectorFunc::set_value<Rstats::Integer>(
            v1,
            i,
            SvIV(sv_value)
          );
        }
        else {
          Rstats::VectorFunc::add_na_position(v1, i);
        }
      }
      
      SV* sv_x1 = new_empty_vector<Rstats::Logical>(sv_r);
      set_vector(sv_r, sv_x1, v1);
      
      return sv_x1;
    }

    void set_vector(SV* sv_r, SV* sv_a1, Rstats::Vector* v1) {
      SV* sv_vector = Rstats::pl_to_perl_obj<Rstats::Vector*>(v1, "Rstats::Vector");
      Rstats::pl_hv_store(sv_a1, "vector", sv_vector);
    }

    Rstats::Vector* get_vector(SV* sv_r, SV* sv_a1) {
      SV* sv_vector = Rstats::pl_hv_fetch(sv_a1, "vector");
      Rstats::Vector* vector = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_vector);
      return vector;
    }

    SV* new_null(SV* sv_r) {
      
      SV* sv_x1 = Rstats::pl_new_hvrv();
      sv_bless(sv_x1, gv_stashpv("Rstats::Object", 1));
      Rstats::pl_hv_store(sv_x1, "r", sv_r);
      Rstats::pl_hv_store(sv_x1, "object_type", Rstats::pl_new_sv_pv("NULL"));
      Rstats::pl_hv_store(sv_x1, "type", Rstats::pl_new_sv_pv("NULL"));

      Rstats::Vector* v1 = Rstats::VectorFunc::new_empty_vector();
      v1->values = NULL;
      v1->type = Rstats::Type::LOGICAL;

      set_vector(sv_r, sv_x1, v1);
      
      return sv_x1;
    }
    
    SV* new_na(SV* sv_r) {
      SV* sv_x1 = Rstats::Func::new_empty_vector<Rstats::Logical>(sv_r);

      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Logical>(1);
      Rstats::VectorFunc::add_na_position(v1, 0);

      set_vector(sv_r, sv_x1, v1);
      
      return sv_x1;
    }

    SV* new_nan(SV* sv_r) {
      SV* sv_x1 = Rstats::Func::new_empty_vector<Rstats::Double>(sv_r);
      
      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Double>(1, NAN);
      
      set_vector(sv_r, sv_x1, v1);
      
      return sv_x1;
    }

    SV* new_inf(SV* sv_r) {
      SV* sv_x1 = Rstats::Func::new_empty_vector<Rstats::Double>(sv_r);
      
      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Double>(1, INFINITY);
      
      set_vector(sv_r, sv_x1, v1);
      
      return sv_x1;
    }

    SV* new_false(SV* sv_r) {
      SV* sv_x1 = Rstats::Func::c_logical(sv_r, Rstats::pl_new_sv_iv(0));
      
      return sv_x1;
    }

    SV* new_true(SV* sv_r) {
      SV* sv_x1 = Rstats::Func::c_logical(sv_r, Rstats::pl_new_sv_iv(1));
      return sv_x1;
    }

    SV* to_c(SV* sv_r, SV* sv_x) {
      
      IV is_container = sv_isobject(sv_x) && sv_derived_from(sv_x, "Rstats::Object");
      
      SV* sv_x1;
      if (is_container) {
        sv_x1 = sv_x;
      }
      else {
        SV* sv_tmp = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_tmp, sv_x);
        sv_x1 = Rstats::Func::c(sv_r, sv_tmp);
      }
      
      return sv_x1;
    }

    SV* is_numeric(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "double")
        || strEQ(Rstats::Func::get_type(sv_r, sv_x1), "integer");
        
      SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
      
      return sv_x_is;
    }

    SV* is_double(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "double");
        
      SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
      
      return sv_x_is;
    }

    SV* is_integer(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "integer");
        
      SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
      
      return sv_x_is;
    }

    SV* is_complex(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "complex");
        
      SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
      
      return sv_x_is;
    }

    SV* is_character(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "character");
        
      SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
      
      return sv_x_is;
    }

    SV* is_logical(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "logical");
        
      SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
      
      return sv_x_is;
    }

    SV* is_data_frame(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_object_type(sv_r, sv_x1), "data.frame");
        
      SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
      
      return sv_x_is;
    }

    SV* is_list(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "list");
        
      SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
      
      return sv_x_is;
    }

    SV* new_data_frame(SV* sv_r) {
      SV* sv_data_frame = Rstats::pl_new_hvrv();
      Rstats::pl_sv_bless(sv_data_frame, "Rstats::Object");
      Rstats::pl_hv_store(sv_data_frame, "r", sv_r);
      Rstats::pl_hv_store(sv_data_frame, "object_type", Rstats::pl_new_sv_pv("data.frame"));
      Rstats::pl_hv_store(sv_data_frame, "type", Rstats::pl_new_sv_pv("list"));
      
      return sv_data_frame;
    }

    SV* new_list(SV* sv_r) {
      SV* sv_list = Rstats::pl_new_hvrv();
      Rstats::pl_sv_bless(sv_list, "Rstats::Object");
      Rstats::pl_hv_store(sv_list, "r", sv_r);
      Rstats::pl_hv_store(sv_list, "object_type", Rstats::pl_new_sv_pv("list"));
      Rstats::pl_hv_store(sv_list, "type", Rstats::pl_new_sv_pv("list"));
      
      return sv_list;
    }

    SV* copy_attrs_to(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2, &PL_sv_undef);
    }

    SV* copy_attrs_to(SV* sv_r, SV* sv_x1, SV* sv_x2, SV* sv_opt) {
      
      if (!SvOK(sv_opt)) {
        sv_opt = Rstats::pl_new_hvrv();
      }
      
      SV* sv_new_indexes = Rstats::pl_hv_fetch(sv_opt, "new_indexes");
      
      // type
      if (!SvOK(Rstats::pl_hv_fetch(sv_x2, "type")) && Rstats::pl_hv_exists(sv_x1, "type")) {
        Rstats::pl_hv_store(sv_x2, "type", Rstats::pl_hv_fetch(sv_x1, "type"));
      }

      // object_type
      if (!SvOK(Rstats::pl_hv_fetch(sv_x2, "object_type")) && Rstats::pl_hv_exists(sv_x1, "object_type")) {
        Rstats::pl_hv_store(sv_x2, "object_type", Rstats::pl_hv_fetch(sv_x1, "object_type"));
      }

      // dim
      if (!SvOK(Rstats::pl_hv_fetch(sv_x2, "dim")) && Rstats::pl_hv_exists(sv_x1, "dim")) {
        Rstats::pl_hv_store(sv_x2, "dim", Rstats::Func::as_vector(sv_r, Rstats::pl_hv_fetch(sv_x1, "dim")));
      }

      // class
      if (!SvOK(Rstats::pl_hv_fetch(sv_x2, "class")) && Rstats::pl_hv_exists(sv_x1, "class")) {
        Rstats::pl_hv_store(sv_x2, "class", Rstats::Func::as_vector(sv_r, Rstats::pl_hv_fetch(sv_x1, "class")));
      }
      
      // levels
      if (!SvOK(Rstats::pl_hv_fetch(sv_x2, "levels")) && Rstats::pl_hv_exists(sv_x1, "levels")) {
        Rstats::pl_hv_store(sv_x2, "levels", Rstats::Func::as_vector(sv_r, Rstats::pl_hv_fetch(sv_x1, "levels")));
      }
      
      // names
      if (!SvOK(Rstats::pl_hv_fetch(sv_x2, "names")) && Rstats::pl_hv_exists(sv_x1, "names")) {
        SV* sv_x2_names_values = Rstats::pl_new_avrv();
        SV* sv_index;
        if (SvOK(sv_new_indexes)) {
          sv_index = Rstats::Func::to_bool(sv_r, Rstats::Func::is_data_frame(sv_r, sv_x1))
            ? Rstats::pl_av_fetch(sv_new_indexes, 1) : Rstats::pl_av_fetch(sv_new_indexes, 0);
        }
        else {
          sv_index = &PL_sv_undef;
        }
        
        if (SvOK(sv_index)) {
          SV* sv_x1_names_values = Rstats::Func::values(sv_r, Rstats::pl_hv_fetch(sv_x1, "names"));
          SV* sv_index_values = Rstats::Func::values(sv_r, sv_index);
          
          for (IV i = 0; i < Rstats::pl_av_len(sv_index_values); i++) {
            IV idx = SvIV(Rstats::pl_av_fetch(sv_index_values, i));
            SV* sv_x2_names_value = Rstats::pl_av_fetch(sv_x1_names_values, idx - 1);
            Rstats::pl_av_push(sv_x2_names_values, sv_x2_names_value);
          }
        }
        else {
          sv_x2_names_values = Rstats::Func::values(sv_r, Rstats::pl_hv_fetch(sv_x1, "names"));
        }
        Rstats::pl_hv_store(sv_x2, "names", Rstats::Func::c_character(sv_r, sv_x2_names_values));
      }
      
      // dimnames
      if (!SvOK(Rstats::pl_hv_fetch(sv_x2, "dimnames")) && Rstats::pl_hv_exists(sv_x1, "dimnames")) {
        SV* sv_new_dimnames = Rstats::pl_new_avrv();
        SV* sv_dimnames = Rstats::pl_hv_fetch(sv_x1, "dimnames");
        IV length = Rstats::pl_av_len(sv_dimnames);
        for (IV i = 0; i < length; i++) {
          SV* sv_dimname = Rstats::pl_av_fetch(sv_dimnames, i);;
          if (SvOK(sv_dimname) && SvIV(Rstats::Func::length_value(sv_r, sv_dimname)) > 0) {
            SV* sv_index = SvOK(sv_new_indexes) ? Rstats::pl_av_fetch(sv_new_indexes, i) : &PL_sv_undef;
            SV* sv_dimname_values = Rstats::Func::values(sv_r, sv_dimname);
            SV* sv_new_dimname_values = Rstats::pl_new_avrv();
            if (SvOK(sv_index)) {
              SV* sv_index_values = Rstats::Func::values(sv_r, sv_index);
              for (IV i = 0; i < Rstats::pl_av_len(sv_index_values); i++) {
                SV* sv_k = Rstats::pl_av_fetch(sv_index_values, i);
                Rstats::pl_av_push(sv_new_dimname_values, Rstats::pl_av_fetch(sv_dimname_values, SvIV(sv_k) - 1));
              }
            }
            else {
              sv_new_dimname_values = sv_dimname_values;
            }
            Rstats::pl_av_push(sv_new_dimnames, Rstats::Func::c_character(sv_r, sv_new_dimname_values));
          }
        }
        Rstats::pl_hv_store(sv_x2, "dimnames", sv_new_dimnames);
      }
    }

    SV* is_na(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      Rstats::Vector* x1 = Rstats::Func::get_vector(sv_r, sv_x1);
      IV x1_length = Rstats::Func::get_length(sv_r, sv_x1);
      Rstats::Vector* x2 = Rstats::VectorFunc::new_vector<Rstats::Logical>(x1_length);
      
      for (IV i = 0; i < Rstats::Func::get_length(sv_r, sv_x1); i++) {
        if (Rstats::VectorFunc::exists_na_position(x1, i)) {
          Rstats::VectorFunc::set_value<Rstats::Integer>(x2, i, 1);
        }
        else {
          Rstats::VectorFunc::set_value<Rstats::Integer>(x2, i, 0);
        }
      }
      
      SV* sv_x2 = Rstats::Func::new_empty_vector<Rstats::Logical>(sv_r);
      Rstats::Func::set_vector(sv_r, sv_x2, x2);
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);
      
      return sv_x2;
    }

    SV* Class(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      // Set class
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);
      Rstats::pl_hv_store(sv_x1, "class", Rstats::Func::as_vector(sv_r, sv_x2));
      
      return sv_x1;
    }

    SV* Class(SV* sv_r, SV* sv_x1) {
      
      // Get class
      SV* sv_x2;
      if (Rstats::pl_hv_exists(sv_x1, "class")) {
        sv_x2 = Rstats::Func::as_vector(sv_r, Rstats::pl_hv_fetch(sv_x1, "class"));
      }
      else if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_null(sv_r, sv_x1))) {
        SV* sv_class_names = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_class_names, Rstats::pl_new_sv_pv("NULL"));
        sv_x2 = Rstats::Func::c_character(sv_r, sv_class_names);
      }
      else if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_vector(sv_r, sv_x1))) {
        SV* sv_class_names = Rstats::pl_new_avrv();
        SV* sv_class_name = Rstats::Func::type(sv_r, sv_x1);
        if (strEQ(SvPV_nolen(sv_class_name), "double") || strEQ(SvPV_nolen(sv_class_name), "integer")) {
          sv_class_name = Rstats::pl_new_sv_pv("numeric");
        }
        
        Rstats::pl_av_push(sv_class_names, sv_class_name);
        sv_x2 = Rstats::Func::c_character(sv_r, sv_class_names);
      }
      else if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_matrix(sv_r, sv_x1))) {
        SV* sv_class_names = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_class_names, Rstats::pl_new_sv_pv("matrix"));
        sv_x2 = Rstats::Func::c_character(sv_r, sv_class_names);
      }
      else if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_array(sv_r, sv_x1))) {
        SV* sv_class_names = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_class_names, Rstats::pl_new_sv_pv("array"));
        sv_x2 = Rstats::Func::c_character(sv_r, sv_class_names);
      }
      else if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_data_frame(sv_r, sv_x1))) {
        SV* sv_class_names = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_class_names, Rstats::pl_new_sv_pv("data.frame"));
        sv_x2 = Rstats::Func::c_character(sv_r, sv_class_names);
      }
      else if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_list(sv_r, sv_x1))) {
        SV* sv_class_names = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_class_names, Rstats::pl_new_sv_pv("list"));
        sv_x2 = Rstats::Func::c_character(sv_r, sv_class_names);
      }
      
      return sv_x2;
    }

    SV* is_factor(SV* sv_r, SV* sv_x1) {
      
      SV* sv_classes = Rstats::Func::Class(sv_r, sv_x1);
      Rstats::Vector* v_classes = Rstats::Func::get_vector(sv_r, sv_classes);
      IV v_classes_length = Rstats::Func::get_length(sv_r, sv_classes);
      
      IV match = 0;
      for (IV i = 0; i < v_classes_length; i++) {
        SV* sv_class = Rstats::VectorFunc::get_value<Rstats::Character>(v_classes, i);
        if (strEQ(SvPV_nolen(sv_class), "factor")) {
          match = 1;
          break;
        }
      }
      
      return match ? Rstats::Func::new_true(sv_r) : Rstats::Func::new_false(sv_r);
    }

    SV* is_ordered(SV* sv_r, SV* sv_x1) {
      
      SV* sv_classes = Rstats::Func::Class(sv_r, sv_x1);
      Rstats::Vector* v_classes = Rstats::Func::get_vector(sv_r, sv_classes);
      IV v_classes_length = Rstats::Func::get_length(sv_r, sv_classes);
      
      IV match = 0;
      for (IV i = 0; i < v_classes_length; i++) {
        SV* sv_class = Rstats::VectorFunc::get_value<Rstats::Character>(v_classes, i);
        if (strEQ(SvPV_nolen(sv_class), "ordered")) {
          match = 1;
          break;
        }
      }
      
      return match ? Rstats::Func::new_true(sv_r) : Rstats::Func::new_false(sv_r);
    }

    SV* clone(SV* sv_r, SV* sv_x1) {
      
      SV* sv_x2 = Rstats::Func::as_vector(sv_r, sv_x1);
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);
      
      return sv_x2;
    }

    SV* dim_as_array(SV* sv_r, SV* sv_x1) {
      
      if (Rstats::pl_hv_exists(sv_x1, "dim")) {
        return Rstats::Func::dim(sv_r, sv_x1);
      }
      else {
        SV* sv_length = Rstats::Func::length_value(sv_r, sv_x1);
        return Rstats::Func::c_double(sv_r, sv_length);
      }
    }

    SV* decompose(SV* sv_r, SV* sv_x1) {
      SV* sv_v1 = Rstats::pl_hv_fetch(sv_x1, "vector");
      Rstats::Vector* v1 = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_v1);
      
      SV* sv_decomposed_xs = Rstats::pl_new_avrv();
      
      IV length = Rstats::Func::get_length(sv_r, sv_x1);
      
      if (length > 0) {
        av_extend(Rstats::pl_av_deref(sv_decomposed_xs), length);

        if (strEQ(Rstats::Func::get_type(sv_r, sv_x1), "character")) {
          for (IV i = 0; i < length; i++) {
            Rstats::Vector* v2
              = Rstats::VectorFunc::new_vector<Rstats::Character>(1, Rstats::VectorFunc::get_value<Rstats::Character>(v1, i));
            if (Rstats::VectorFunc::exists_na_position(v1, i)) {
              Rstats::VectorFunc::add_na_position(v2, 0);
            }
            SV* sv_x2 = Rstats::Func::new_empty_vector<Rstats::Character>(sv_r);
            Rstats::Func::set_vector(sv_r, sv_x2, v2);
            Rstats::pl_av_push(sv_decomposed_xs, sv_x2);
          }
        }
        else if (strEQ(Rstats::Func::get_type(sv_r, sv_x1), "complex")) {
          for (IV i = 0; i < length; i++) {
            Rstats::Vector* v2
              = Rstats::VectorFunc::new_vector<Rstats::Complex>(1, Rstats::VectorFunc::get_value<Rstats::Complex>(v1, i));
            if (Rstats::VectorFunc::exists_na_position(v1, i)) {
              Rstats::VectorFunc::add_na_position(v2, 0);
            }
            SV* sv_x2 = Rstats::Func::new_empty_vector<Rstats::Complex>(sv_r);
            Rstats::Func::set_vector(sv_r, sv_x2, v2);
            Rstats::pl_av_push(sv_decomposed_xs, sv_x2);
          }
        }
        else if (strEQ(Rstats::Func::get_type(sv_r, sv_x1), "double")) {
          for (IV i = 0; i < length; i++) {
            Rstats::Vector* v2
              = Rstats::VectorFunc::new_vector<Rstats::Double>(1, Rstats::VectorFunc::get_value<Rstats::Double>(v1, i));
            if (Rstats::VectorFunc::exists_na_position(v1, i)) {
              Rstats::VectorFunc::add_na_position(v2, 0);
            }
            SV* sv_x2 = Rstats::Func::new_empty_vector<Rstats::Double>(sv_r);
            Rstats::Func::set_vector(sv_r, sv_x2, v2);
            Rstats::pl_av_push(sv_decomposed_xs, sv_x2);
          }
        }
        else if (strEQ(Rstats::Func::get_type(sv_r, sv_x1), "integer")) {
          for (IV i = 0; i < length; i++) {
            Rstats::Vector* v2
              = Rstats::VectorFunc::new_vector<Rstats::Integer>(1, Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i));
            if (Rstats::VectorFunc::exists_na_position(v1, i)) {
              Rstats::VectorFunc::add_na_position(v2, 0);
            }
            SV* sv_x2 = Rstats::Func::new_empty_vector<Rstats::Integer>(sv_r);
            Rstats::Func::set_vector(sv_r, sv_x2, v2);
            Rstats::pl_av_push(sv_decomposed_xs, sv_x2);
          }
        }
        else if (strEQ(Rstats::Func::get_type(sv_r, sv_x1), "logical")) {
          for (IV i = 0; i < length; i++) {
            Rstats::Vector* v2
              = Rstats::VectorFunc::new_vector<Rstats::Logical>(1, Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i));
            if (Rstats::VectorFunc::exists_na_position(v1, i)) {
              Rstats::VectorFunc::add_na_position(v2, 0);
            }
            SV* sv_x2 = Rstats::Func::new_empty_vector<Rstats::Logical>(sv_r);
            Rstats::Func::set_vector(sv_r, sv_x2, v2);
            Rstats::pl_av_push(sv_decomposed_xs, sv_x2);
          }
        }
      }
      
      return sv_decomposed_xs;
    }

    SV* compose(SV* sv_r, SV* sv_type, SV* sv_elements)
    {
      IV len = Rstats::pl_av_len(sv_elements);
      
      Rstats::Vector* compose_elements;
      std::vector<IV> na_positions;
      char* type = SvPV_nolen(sv_type);
      SV* sv_x2;
      if (strEQ(type, "character")) {
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Character>(sv_r);
        compose_elements = Rstats::VectorFunc::new_vector<Rstats::Character>(len);
        for (IV i = 0; i < len; i++) {
          SV* sv_x1 = Rstats::pl_av_fetch(sv_elements, i);
          if (!SvOK(sv_x1)) {
            sv_x1 = Rstats::Func::new_na(sv_r);
          }
          Rstats::Vector* element = Rstats::Func::get_vector(sv_r, sv_x1);
          
          if (Rstats::VectorFunc::exists_na_position(element, 0)) {
            na_positions.push_back(i);
          }
          else {
            Rstats::VectorFunc::set_value<Rstats::Character>(compose_elements, i, Rstats::VectorFunc::get_value<Rstats::Character>(element, 0));
          }
        }
      }
      else if (strEQ(type, "complex")) {
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Complex>(sv_r);
        compose_elements = Rstats::VectorFunc::new_vector<Rstats::Complex>(len);
        for (IV i = 0; i < len; i++) {
          SV* sv_x1 = Rstats::pl_av_fetch(sv_elements, i);
          if (!SvOK(sv_x1)) {
            sv_x1 = Rstats::Func::new_na(sv_r);
          }
          Rstats::Vector* element = Rstats::Func::get_vector(sv_r, sv_x1);

          if (Rstats::VectorFunc::exists_na_position(element, 0)) {
            na_positions.push_back(i);
          }
          else {
           Rstats::VectorFunc::set_value<Rstats::Complex>(compose_elements, i, Rstats::VectorFunc::get_value<Rstats::Complex>(element, 0));
          }
        }
      }
      else if (strEQ(type, "double")) {
        
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Double>(sv_r);
        compose_elements = Rstats::VectorFunc::new_vector<Rstats::Double>(len);
        for (IV i = 0; i < len; i++) {
          SV* sv_x1 = Rstats::pl_av_fetch(sv_elements, i);
          if (!SvOK(sv_x1)) {
            sv_x1 = Rstats::Func::new_na(sv_r);
          }
          Rstats::Vector* element = Rstats::Func::get_vector(sv_r, sv_x1);

          if (Rstats::VectorFunc::exists_na_position(element, 0)) {
            na_positions.push_back(i);
          }
          else {
            Rstats::VectorFunc::set_value<Rstats::Double>(compose_elements, i, Rstats::VectorFunc::get_value<Rstats::Double>(element, 0));
          }
        }
      }
      else if (strEQ(type, "integer")) {
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Integer>(sv_r);
        compose_elements = Rstats::VectorFunc::new_vector<Rstats::Integer>(len);
        std::vector<IV>* values = Rstats::VectorFunc::get_values<Rstats::Integer>(compose_elements);
        for (IV i = 0; i < len; i++) {
          SV* sv_x1 = Rstats::pl_av_fetch(sv_elements, i);
          if (!SvOK(sv_x1)) {
            sv_x1 = Rstats::Func::new_na(sv_r);
          }
          Rstats::Vector* element = Rstats::Func::get_vector(sv_r, sv_x1);

          if (Rstats::VectorFunc::exists_na_position(element, 0)) {
            na_positions.push_back(i);
          }
          else {
            Rstats::VectorFunc::set_value<Rstats::Integer>(compose_elements, i, Rstats::VectorFunc::get_value<Rstats::Integer>(element, 0));
          }
        }
      }
      else if (strEQ(type, "logical")) {
        sv_x2 = Rstats::Func::new_empty_vector<Rstats::Logical>(sv_r);
        compose_elements = Rstats::VectorFunc::new_vector<Rstats::Logical>(len);
        std::vector<IV>* values = Rstats::VectorFunc::get_values<Rstats::Integer>(compose_elements);
        for (IV i = 0; i < len; i++) {
          SV* sv_x1 = Rstats::pl_av_fetch(sv_elements, i);
          if (!SvOK(sv_x1)) {
            sv_x1 = Rstats::Func::new_na(sv_r);
          }
          Rstats::Vector* element = Rstats::Func::get_vector(sv_r, sv_x1);

          if (Rstats::VectorFunc::exists_na_position(element, 0)) {
            na_positions.push_back(i);
          }
          else {
            Rstats::VectorFunc::set_value<Rstats::Integer>(compose_elements, i, Rstats::VectorFunc::get_value<Rstats::Integer>(element, 0));
          }
        }
      }
      else {
        croak("Unknown type(Rstats::Func::compose)");
      }
      
      for (IV i = 0; i < na_positions.size(); i++) {
        Rstats::VectorFunc::add_na_position(compose_elements, na_positions[i]);
      }
      
      Rstats::Func::set_vector(sv_r, sv_x2, compose_elements);
      
      return sv_x2;
    }

    SV* args_h(SV* sv_r, SV* sv_names, SV* sv_args) {
      
      IV args_length = Rstats::pl_av_len(sv_args);
      SV* sv_opt;
      SV* sv_arg_last = Rstats::pl_av_fetch(sv_args, args_length - 1);
      if (!sv_isobject(sv_arg_last) && sv_derived_from(sv_arg_last, "HASH")) {
        sv_opt = Rstats::pl_av_pop(sv_args);
      }
      else {
        sv_opt = Rstats::pl_new_hvrv();
      }
      
      SV* sv_new_opt = Rstats::pl_new_hvrv();
      IV names_length = Rstats::pl_av_len(sv_names);
      for (IV i = 0; i < names_length; i++) {
        SV* sv_name = Rstats::pl_av_fetch(sv_names, i);
        if (Rstats::pl_hv_exists(sv_opt, SvPV_nolen(sv_name))) {
          Rstats::pl_hv_store(
            sv_new_opt,
            SvPV_nolen(sv_name),
            Rstats::Func::to_c(sv_r, Rstats::pl_hv_delete(sv_opt, SvPV_nolen(sv_name)))
          );
        }
        else if (i < names_length) {
          SV* sv_name = Rstats::pl_av_fetch(sv_names, i);
          SV* sv_arg = Rstats::pl_av_fetch(sv_args, i);
          if (SvOK(sv_arg)) {
            Rstats::pl_hv_store(
              sv_new_opt,
              SvPV_nolen(sv_name),
              Rstats::Func::to_c(sv_r, sv_arg)
            );
          }
        }
      }

      return sv_new_opt;
    }
    
    SV* as_array(SV* sv_r, SV* sv_x1) {
      
      SV* sv_x2 = Rstats::Func::as_vector(sv_r, sv_x1);
      SV* sv_x2_dim = Rstats::Func::dim_as_array(sv_r, sv_x1);
      
      return Rstats::Func::array(sv_r, sv_x2, sv_x2_dim);
    }

    SV* levels(SV* sv_r, SV* sv_x1, SV* sv_x_class) {
      
      sv_x_class = Rstats::Func::to_c(sv_r, sv_x_class);
      if (!Rstats::Func::to_bool(sv_r, Rstats::Func::is_character(sv_r, sv_x_class))) {
        sv_x_class = Rstats::Func::as_character(sv_r, sv_x_class);
      }
      
      Rstats::pl_hv_store(sv_x1, "levels", Rstats::Func::as_vector(sv_r, sv_x_class));
      
      return sv_x1;
    }
    
    SV* levels(SV* sv_r, SV* sv_x1) {
      SV* sv_x_levels;
      
      if (Rstats::pl_hv_exists(sv_x1, "levels")) {
        sv_x_levels = Rstats::Func::as_vector(sv_r, Rstats::pl_hv_fetch(sv_x1, "levels"));
      }
      else {
        sv_x_levels = Rstats::Func::new_null(sv_r);
      }
      
      return sv_x_levels;
    }

    SV* mode(SV* sv_r, SV* sv_x1, SV* sv_x_type) {
      
      sv_x_type = Rstats::Func::to_c(sv_r, sv_x_type);
      
      SV* sv_type = Rstats::pl_av_fetch(Rstats::Func::values(sv_r, sv_x_type), 0);
      char* type = SvPV_nolen(sv_type);
      
      if (!strEQ(type, "character")
        && !strEQ(type, "complex")
        && !strEQ(type, "numeric")
        && !strEQ(type, "double")
        && !strEQ(type, "integer")
        && !strEQ(type, "logical")
      )
      {
        croak("Error in eval(expr, envir, enclos) : could not find function \"as_%s\"", type);
      }
      
      sv_x1 = Rstats::Func::as(sv_r, sv_type, sv_x1);
      
      return sv_r;
    }
    
    SV* mode(SV* sv_r, SV* sv_x1) {
      
      SV* sv_type = Rstats::Func::type(sv_r, sv_x1);
      
      SV* sv_mode;
      if (to_bool(sv_r, Rstats::Func::is_null(sv_r, sv_x1))) {
        sv_mode = Rstats::pl_new_sv_pv("NULL");
      }
      else if (strEQ(SvPV_nolen(sv_type), "integer") || strEQ(SvPV_nolen(sv_type), "double")) {
        sv_mode = Rstats::pl_new_sv_pv("numeric");
      }
      else {
        sv_mode = sv_type;
      }
      
      return Rstats::Func::c_character(sv_r, sv_mode);
    }
    
    SV* as(SV* sv_r, SV* sv_type, SV* sv_x1) {
      
      char* type = SvPV_nolen(sv_type);
      if (strEQ(type, "character")) {
        return Rstats::Func::as_character(sv_r, sv_x1);
      }
      else if (strEQ(type, "complex")) {

        return Rstats::Func::as_complex(sv_r, sv_x1);
      }
      else if (strEQ(type, "double")) {
        return Rstats::Func::as_double(sv_r, sv_x1);
      }
      else if (strEQ(type, "numeric")) {
        return Rstats::Func::as_numeric(sv_r, sv_x1);
      }
      else if (strEQ(type, "integer")) {
        return Rstats::Func::as_integer(sv_r, sv_x1);
      }
      else if (strEQ(type, "logical")) {
        return Rstats::Func::as_logical(sv_r, sv_x1);
      }
      else {
        croak("Invalid mode %s is passed", type);
      }
    }

    SV* length(SV* sv_r, SV* sv_container) {
      if (to_bool(sv_r, Rstats::Func::is_null(sv_r, sv_container))) {
        return Rstats::Func::c_integer(sv_r, (Rstats::Integer)0);
      }
      else if (to_bool(sv_r, Rstats::Func::is_vector(sv_r, sv_container)) || to_bool(sv_r, Rstats::Func::is_array(sv_r, sv_container))) {
        return Rstats::Func::c_integer(
          sv_r,
          Rstats::Func::get_length(sv_r, sv_container)
        );
      }
      else {
        return Rstats::Func::c_integer(sv_r, Rstats::Func::length_value(sv_r, sv_container));
      }
    }

    SV* names(SV* sv_r, SV* sv_x1, SV* sv_x_names) {
      sv_x_names = Rstats::Func::to_c(sv_r, sv_x_names);
      
      if (!Rstats::Func::to_bool(sv_r, Rstats::Func::is_character(sv_r, sv_x_names))) {
        sv_x_names = Rstats::Func::as_character(sv_r, sv_x_names);
      }
      Rstats::pl_hv_store(sv_x1, "names", Rstats::Func::as_vector(sv_r, sv_x_names));
      
      if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_data_frame(sv_r, sv_x1))) {
        SV* sv_x1_dimnames = Rstats::pl_hv_fetch(sv_x1, "dimnames");
        Rstats::pl_av_store(
          sv_x1_dimnames,
          1,
          Rstats::Func::as_vector(sv_r, Rstats::pl_hv_fetch(sv_x1, "names"))
        );
      }
      
      return sv_r;
    }
    
    SV* names(SV* sv_r, SV* sv_x1) {
      SV* sv_x_names;
      if (Rstats::pl_hv_exists(sv_x1, "names")) {
        sv_x_names = Rstats::Func::as_vector(sv_r, Rstats::pl_hv_fetch(sv_x1, "names"));
      }
      else {
        sv_x_names = Rstats::Func::new_null(sv_r);
      }
      return sv_x_names;
    }
  }
}
