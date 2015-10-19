#include "Rstats.h"

// Rstats::Func
namespace Rstats {
  namespace Func {

    SV* length(SV* sv_r, SV* x1) {
      Rstats::Integer x1_length = Rstats::Func::get_length(sv_r, x1);
      Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(1, x1_length);
      SV* sv_x_out = Rstats::Func::new_vector<Rstats::Integer>(sv_r, v2);
      return sv_x_out;
    }

    SV* c_(SV* sv_r, SV* sv_elements) {
      
      // Convert to array reference
      if (SvOK(sv_elements) && !SvROK(sv_elements)) {
        SV* sv_elements_tmp = sv_elements;
        sv_elements = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_elements, sv_elements_tmp);
      }
      
      Rstats::Integer element_length = Rstats::pl_av_len(sv_elements);
      // Check type and length
      SV* sv_type_h = Rstats::pl_new_hvrv();
      Rstats::Integer length = 0;
      for (Rstats::Integer i = 0; i < element_length; i++) {
        char* type;
        SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
        
        if (to_bool(sv_r, Rstats::Func::is_vector(sv_r, sv_element)) || to_bool(sv_r, Rstats::Func::is_array(sv_r, sv_element))) {
          length += Rstats::Func::get_length(sv_r, sv_element);
          type = Rstats::Func::get_type(sv_r, sv_element);
          Rstats::pl_hv_store(sv_type_h, type, Rstats::pl_new_sv_iv(1));
        }
        else {
          if (SvOK(sv_element)) {
            if (Rstats::Util::is_perl_number(sv_element)) {
              Rstats::pl_hv_store(sv_type_h, "double", Rstats::pl_new_sv_iv(1));
            }
            else {
              Rstats::pl_hv_store(sv_type_h, "character", Rstats::pl_new_sv_iv(1));
            }
          }
          else {
            Rstats::pl_hv_store(sv_type_h, "logical", Rstats::pl_new_sv_iv(1));
          }
          length += 1;
        }
      }

      SV* sv_x1;

      // Decide type
      Rstats::Vector* v1;
      if (Rstats::pl_hv_exists(sv_type_h, "character")) {
        v1 = Rstats::VectorFunc::new_vector<Rstats::Character>(length);
        sv_x1 = Rstats::Func::new_vector<Rstats::Character>(sv_r);
      }
      else if (Rstats::pl_hv_exists(sv_type_h, "complex")) {
        v1 = Rstats::VectorFunc::new_vector<Rstats::Complex>(length);
        sv_x1 = Rstats::Func::new_vector<Rstats::Complex>(sv_r);
      }
      else if (Rstats::pl_hv_exists(sv_type_h, "double")) {
        v1 = Rstats::VectorFunc::new_vector<Rstats::Double>(length);
        sv_x1 = Rstats::Func::new_vector<Rstats::Double>(sv_r);
      }
      else if (Rstats::pl_hv_exists(sv_type_h, "integer")) {
        v1 = Rstats::VectorFunc::new_vector<Rstats::Integer>(length);
        sv_x1 = Rstats::Func::new_vector<Rstats::Integer>(sv_r);
      }
      else {
        v1 = Rstats::VectorFunc::new_vector<Rstats::Logical>(length);
        sv_x1 = Rstats::Func::new_vector<Rstats::Logical>(sv_r);
      }
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      Rstats::Integer pos = 0;
      for (Rstats::Integer i = 0; i < element_length; i++) {
        SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
        SV* sv_x_tmp;
        if (to_bool(sv_r, Rstats::Func::is_vector(sv_r, sv_element)) || to_bool(sv_r, Rstats::Func::is_array(sv_r, sv_element))) {
          
          char* tmp_type = Rstats::Func::get_type(sv_r, sv_element);
          
          if (strEQ(tmp_type, type)) {
            sv_x_tmp = sv_element;
          }
          else {
            if (strEQ(type, "character")) {
              sv_x_tmp = Rstats::Func::as_character(sv_r, sv_element);
            }
            else if (strEQ(type, "complex")) {
              sv_x_tmp = Rstats::Func::as_complex(sv_r, sv_element);
            }
            else if (strEQ(type, "double")) {
              sv_x_tmp = Rstats::Func::as_double(sv_r, sv_element);
            }
            else if (strEQ(type, "integer")) {
              sv_x_tmp = Rstats::Func::as_integer(sv_r, sv_element);
            }
            else {
              sv_x_tmp = Rstats::Func::as_logical(sv_r, sv_element);
            }
          }

          Rstats::Vector* v_tmp = Rstats::Func::get_vector(sv_r, sv_x_tmp);
          
          for (Rstats::Integer k = 0; k < Rstats::Func::get_length(sv_r, sv_x_tmp); k++) {
            if (v_tmp->exists_na_position(k)) {
              v1->add_na_position(pos);
            }
            else {
              if (strEQ(type, "character")) {
                v1->set_value<Rstats::Character>(pos, v_tmp->get_value<Rstats::Character>(k));
              }
              else if (strEQ(type, "complex")) {
                v1->set_value<Rstats::Complex>(pos, v_tmp->get_value<Rstats::Complex>(k));
              }
              else if (strEQ(type, "double")) {
                v1->set_value<Rstats::Double>(pos, v_tmp->get_value<Rstats::Double>(k));
              }
              else if (strEQ(type, "integer")) {
                v1->set_value<Rstats::Integer>(pos, v_tmp->get_value<Rstats::Integer>(k));
              }
              else {
                v1->set_value<Rstats::Integer>(pos, v_tmp->get_value<Rstats::Integer>(k));
              }
            }
            
            pos++;
          }
        }
        else {
          if (SvOK(sv_element)) {
            if (strEQ(type, "character")) {
              v1->set_value<Rstats::Character>(pos, sv_element);
            }
            else if (strEQ(type, "complex")) {
              v1->set_value<Rstats::Complex>(pos, Rstats::Complex(SvNV(sv_element), 0));
            }
            else if (strEQ(type, "double")) {
              v1->set_value<Rstats::Double>(pos, SvNV(sv_element));
            }
            else if (strEQ(type, "integer")) {
              v1->set_value<Rstats::Integer>(pos, SvIV(sv_element));
            }
            else {
              v1->set_value<Rstats::Integer>(pos, SvIV(sv_element));
            }
          }
          else {
            v1->add_na_position(pos);
          }
          pos++;
        }
      }
      
      // Array
      Rstats::Func::set_vector(sv_r, sv_x1, v1);

      return sv_x1;
    }

    Rstats::Integer get_length (SV* sv_r, SV* sv_x1) {

      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "character")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        return v1->get_values<Rstats::Character>()->size();
      }
      else if (strEQ(type, "complex")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        return v1->get_values<Rstats::Complex>()->size();
      }
      else if (strEQ(type, "double")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        return v1->get_values<Rstats::Double>()->size();
      }
      else if (strEQ(type, "integer")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        return v1->get_values<Rstats::Integer>()->size();
      }
      else if (strEQ(type, "logical")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        return v1->get_values<Rstats::Integer>()->size();
      }
      else if (strEQ(type, "list")) {
        SV* sv_list = Rstats::pl_hv_fetch(sv_x1, "list");
        Rstats::Integer length = Rstats::pl_av_len(sv_list);
        return length;
      }
      else if (strEQ(type, "NULL")) {
        return 0;
      }
      else {
        croak("Error in get_length() : default method not implemented for type '%s'", type);
      }
    }

    SV* get_length_sv (SV* sv_r, SV* sv_x1) {
      return Rstats::pl_new_sv_iv(Rstats::Func::get_length(sv_r, sv_x1));
    }
    
    SV* as_character(SV* sv_r, SV* sv_x1) {

      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      SV* sv_x_out = Rstats::Func::new_vector<Rstats::Character>(sv_r);
      if (strEQ(type, "character")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Character>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          Rstats::Character sv_value = v1->get_value<Rstats::Character>(i);
          v2->set_value<Rstats::Character>(i, sv_value);
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "complex")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Character>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          Rstats::Complex z = v1->get_value<Rstats::Complex>(i);
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

          v2->set_value<Rstats::Character>(i, sv_str);
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Character>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          Rstats::Double value = v1->get_value<Rstats::Double>(i);
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
          v2->set_value<Rstats::Character>(i, sv_str);
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "integer")) {
        // Factor
        if (to_bool(sv_r, Rstats::Func::is_factor(sv_r, sv_x1))) {
          SV* sv_levels = Rstats::pl_new_hvrv();
          SV* sv_x_levels = Rstats::Func::levels(sv_r, sv_x1);
          SV* sv_x_levels_values = Rstats::Func::values(sv_r, sv_x_levels);
          Rstats::Integer levels_length = Rstats::Func::get_length(sv_r, sv_x_levels);
          for (Rstats::Integer i = 1; i <= levels_length; i++) {
            Rstats::pl_hv_store(
              sv_levels,
              SvPV_nolen(Rstats::pl_new_sv_iv(i)),
              Rstats::pl_av_fetch(sv_x_levels_values, i - 1)
            );
          }
          
          SV* sv_x1_values = Rstats::Func::values(sv_r, sv_x1);
          SV* sv_x_out_values = Rstats::pl_new_avrv();
          Rstats::Integer x1_values_length = Rstats::pl_av_len(sv_x1_values);
          
          Rstats::Vector* v_out = Rstats::VectorFunc::new_vector<Rstats::Character>(x1_values_length);
          for (Rstats::Integer i = 0; i < x1_values_length; i++) {
            SV* sv_x1_value = Rstats::pl_av_fetch(sv_x1_values, i);
             
            if (SvOK(sv_x1_value)) {
              SV* sv_character = Rstats::pl_hv_fetch(sv_levels, SvPV_nolen(sv_x1_value));
              v_out->set_value<Rstats::Character>(i, Rstats::pl_new_sv_sv(sv_character));
            }
            else {
              v_out->add_na_position(i);
            }
          }
          sv_x_out = Rstats::Func::new_vector<Rstats::Character>(sv_r, v_out);
          
          Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
          Rstats::pl_hv_delete(sv_x_out, "levels");
          Rstats::pl_hv_delete(sv_x_out, "class");
          
          // Todo na positions
          
          return sv_x_out;
        }
        else {
          Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
          Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Character>(v1->get_length());
          for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
            v2->set_value<Rstats::Character>(
              i,
              Rstats::pl_new_sv_iv(v1->get_value<Rstats::Integer>(i))
            );
          }
          v2->merge_na_positions(v1->get_na_positions());
          Rstats::Func::set_vector(sv_r, sv_x_out, v2);
        }
      }
      else if (strEQ(type, "logical")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Character>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          if (v1->get_value<Rstats::Integer>(i)) {
            v2->set_value<Rstats::Character>(i, Rstats::pl_new_sv_pv("TRUE"));
          }
          else {
            v2->set_value<Rstats::Character>(i, Rstats::pl_new_sv_pv("FALSE"));
          }
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "NULL")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Character>(0);
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else {
        croak("Error in as->character() : default method not implemented for type '%s'", type);
      }

      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
    
    SV* as_numeric(SV* sv_r, SV* sv_x1) {
      return Rstats::Func::as_double(sv_r, sv_x1);
    }
    
    SV* as_double(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      SV* sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r);
      if (strEQ(type, "character")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          Rstats::Character sv_value = v1->get_value<Rstats::Character>(i);
          SV* sv_value_fix = Rstats::Util::looks_like_double(sv_value);
          if (SvOK(sv_value_fix)) {
            Rstats::Double value = SvNV(sv_value_fix);
            v2->set_value<Rstats::Double>(i, value);
          }
          else {
            warn("NAs introduced by coercion");
            v2->add_na_position(i);
          }
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "complex")) {
        warn("imaginary parts discarded in coercion");
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2->set_value<Rstats::Double>(i, v1->get_value<Rstats::Complex>(i).real());
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2->set_value<Rstats::Double>(i, v1->get_value<Rstats::Double>(i));
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "integer")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2->set_value<Rstats::Double>(i, v1->get_value<Rstats::Integer>(i));
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "logical")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2->set_value<Rstats::Double>(i, v1->get_value<Rstats::Integer>(i));
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "NULL")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(0);
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else {
        croak("Error in as->double() : default method not implemented for type '%s'", type);
      }

      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
        
    SV* as_complex(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out = Rstats::Func::new_vector<Rstats::Complex>(sv_r);
      if (strEQ(type, "character")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          Rstats::Character sv_value = v1->get_value<Rstats::Character>(i);
          SV* sv_z = Rstats::Util::looks_like_complex(sv_value);
          
          if (SvOK(sv_z)) {
            SV* sv_re = Rstats::pl_hv_fetch(sv_z, "re");
            SV* sv_im = Rstats::pl_hv_fetch(sv_z, "im");
            Rstats::Double re = SvNV(sv_re);
            Rstats::Double im = SvNV(sv_im);
            v2->set_value<Rstats::Complex>(i, Rstats::Complex(re, im));
          }
          else {
            warn("NAs introduced by coercion");
            v2->add_na_position(i);
          }
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "complex")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2->set_value<Rstats::Complex>(i, v1->get_value<Rstats::Complex>(i));
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          Rstats::Double value = v1->get_value<Rstats::Double>(i);
          if (std::isnan(value)) {
            v2->add_na_position(i);
          }
          else {
            v2->set_value<Rstats::Complex>(i, Rstats::Complex(v1->get_value<Rstats::Double>(i), 0));
          }
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "integer")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2->set_value<Rstats::Complex>(i, Rstats::Complex(v1->get_value<Rstats::Integer>(i), 0));
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "logical")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2->set_value<Rstats::Complex>(i, Rstats::Complex(v1->get_value<Rstats::Integer>(i), 0));
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "NULL")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(0);
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else {
        croak("Error in as->complex() : default method not implemented for type '%s'", type);
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
        
    SV* as_integer(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out = Rstats::Func::new_vector<Rstats::Integer>(sv_r);
      if (strEQ(type, "character")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          Rstats::Character sv_value = v1->get_value<Rstats::Character>(i);
          SV* sv_value_fix = Rstats::Util::looks_like_double(sv_value);
          if (SvOK(sv_value_fix)) {
            Rstats::Integer value = SvIV(sv_value_fix);
            v2->set_value<Rstats::Integer>(i, value);
          }
          else {
            warn("NAs introduced by coercion");
            v2->add_na_position(i);
          }
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "complex")) {
        warn("imaginary parts discarded in coercion");
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2->set_value<Rstats::Integer>(i, (Rstats::Integer)v1->get_value<Rstats::Complex>(i).real());
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double value;
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          value = v1->get_value<Rstats::Double>(i);
          if (std::isnan(value) || std::isinf(value)) {
            v2->add_na_position(i);
          }
          else {
            v2->set_value<Rstats::Integer>(i, (Rstats::Integer)value);
          }
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "integer")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2->set_value<Rstats::Integer>(i, v1->get_value<Rstats::Integer>(i));
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "logical")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2->set_value<Rstats::Integer>(i, v1->get_value<Rstats::Integer>(i));
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "NULL")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(0);
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else {
        croak("Error in as->integer() : default method not implemented for type '%s'", type);
      }

      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
    
    SV* as_logical(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      SV* sv_x_out = Rstats::Func::new_vector<Rstats::Logical>(sv_r);
      if (strEQ(type, "character")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Logical>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          Rstats::Character sv_value = v1->get_value<Rstats::Character>(i);
          SV* sv_logical = Rstats::Util::looks_like_logical(sv_value);
          if (SvOK(sv_logical)) {
            if (SvTRUE(sv_logical)) {
              v2->set_value<Rstats::Logical>(i, 1);
            }
            else {
              v2->set_value<Rstats::Logical>(i, 0);
            }
          }
          else {
            warn("NAs introduced by coercion");
            v2->add_na_position(i);
          }
        }
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "complex")) {
        warn("imaginary parts discarded in coercion");
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Logical>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2->set_value<Rstats::Logical>(i, v1->get_value<Rstats::Complex>(i).real() ? 1 : 0);
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "double")) {
      
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Logical>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          Rstats::Double value = v1->get_value<Rstats::Double>(i);
          if (std::isnan(value)) {
            v2->add_na_position(i);
          }
          else if (std::isinf(value)) {
            v2->set_value<Rstats::Logical>(i, 1);
          }
          else {
            v2->set_value<Rstats::Logical>(i, value ? 1 : 0);
          }
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "integer")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Logical>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2->set_value<Rstats::Logical>(i, v1->get_value<Rstats::Integer>(i) ? 1 : 0);
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "logical")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Logical>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2->set_value<Rstats::Logical>(i, v1->get_value<Rstats::Integer>(i) ? 1 : 0);
        }
        v2->merge_na_positions(v1->get_na_positions());
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else if (strEQ(type, "NULL")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Logical>(0);
        Rstats::Func::set_vector(sv_r, sv_x_out, v2);
      }
      else {
        croak("Error in as->logical() : default method not implemented for type '%s'", type);
      }

      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* create_sv_values(SV* sv_r, SV* sv_x1) {

      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);

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
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      SV* sv_value;
      Rstats::Vector* v2;
      if (strEQ(type, "character")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        if (v1->exists_na_position(pos)) {
          sv_value = &PL_sv_undef;
        }
        else {
          sv_value = v1->get_value<Rstats::Character>(pos);
        }
      }
      else if (strEQ(type, "complex")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        if (v1->exists_na_position(pos)) {
          sv_value = &PL_sv_undef;
        }
        else {
          Rstats::Complex z = v1->get_value<Rstats::Complex>(pos);
          
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
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        if (v1->exists_na_position(pos)) {
          sv_value = &PL_sv_undef;
        }
        else {
          Rstats::Double value = v1->get_value<Rstats::Double>(pos);
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
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        if (v1->exists_na_position(pos)) {
          sv_value = &PL_sv_undef;
        }
        else {
          Rstats::Integer value = v1->get_value<Rstats::Integer>(pos);
          sv_value = Rstats::pl_new_sv_iv(value);
        }
      }
      else if (strEQ(type, "logical")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        if (v1->exists_na_position(pos)) {
          sv_value = &PL_sv_undef;
        }
        else {
          Rstats::Integer value = v1->get_value<Rstats::Integer>(pos);
          sv_value = Rstats::pl_new_sv_iv(value);
        }
      }
      else {
        croak("Error in create_sv_value : default method not implemented for type '%s'", type);
      }
      
      return sv_value;
    }
        
    SV* cumprod(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(v1->get_length());
        Rstats::Complex v2_total(1);
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2_total *= v1->get_value<Rstats::Complex>(i);
          v2->set_value<Rstats::Complex>(i, v2_total);
        }
        
        v2->merge_na_positions(v1->get_na_positions());
        sv_x_out = Rstats::Func::new_vector<Rstats::Complex>(sv_r, v2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(v1->get_length());
        Rstats::Double v2_total(1);
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2_total *= v1->get_value<Rstats::Double>(i);
          v2->set_value<Rstats::Double>(i, v2_total);
        }
          
        v2->merge_na_positions(v1->get_na_positions());
        sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r, v2);
      }
      else if (strEQ(type, "integer")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(v1->get_length());
        Rstats::Double v2_total(1);
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2_total *= v1->get_value<Rstats::Integer>(i);
          v2->set_value<Rstats::Double>(i, v2_total);
        }
        
        v2->merge_na_positions(v1->get_na_positions());
        sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r, v2);
      }
      else if (strEQ(type, "logical")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(v1->get_length());
        Rstats::Double v2_total(1);
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2_total *= v1->get_value<Rstats::Logical>(i);
          v2->set_value<Rstats::Double>(i, v2_total);
        }
        
        v2->merge_na_positions(v1->get_na_positions());
        sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r, v2);
      }
      else if (strEQ(type, "NULL")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(0);
        sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r, v2);
      }
      else {
        croak("Error in cumprod() : non-numeric argument to cumprod()");
      }
      
      return sv_x_out;
    }
    
    SV* cumsum(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(v1->get_length());
        Rstats::Complex v2_total(0);
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2_total += v1->get_value<Rstats::Complex>(i);
          v2->set_value<Rstats::Complex>(i, v2_total);
        }
        
        v2->merge_na_positions(v1->get_na_positions());
        sv_x_out = Rstats::Func::new_vector<Rstats::Complex>(sv_r, v2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(v1->get_length());
        Rstats::Double v2_total(0);
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2_total += v1->get_value<Rstats::Double>(i);
          v2->set_value<Rstats::Double>(i, v2_total);
        }
          
        v2->merge_na_positions(v1->get_na_positions());
        sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r, v2);
      }
      else if (strEQ(type, "integer")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(v1->get_length());
        Rstats::Double v2_total(0);
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2_total += v1->get_value<Rstats::Integer>(i);
          v2->set_value<Rstats::Double>(i, v2_total);
        }
        
        v2->merge_na_positions(v1->get_na_positions());
        sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r, v2);
      }
      else if (strEQ(type, "logical")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(v1->get_length());
        Rstats::Double v2_total(0);
        for (Rstats::Logical i = 0; i < v1->get_length(); i++) {
          v2_total += v1->get_value<Rstats::Logical>(i);
          v2->set_value<Rstats::Double>(i, v2_total);
        }
        
        v2->merge_na_positions(v1->get_na_positions());
        sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r, v2);
      }
      else if (strEQ(type, "NULL")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(0);
        sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r, v2);
      }
      else {
        croak("Error in cumsum() : non-numeric argument to cumsum()");
      }
      
      return sv_x_out;
    }
        
    SV* sum(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(1);
        Rstats::Complex v2_total(0);
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2_total += v1->get_value<Rstats::Complex>(i);
        }
        v2->set_value<Rstats::Complex>(0, v2_total);
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          if (v1->exists_na_position(i)) {
            v2->add_na_position(0);
            break;
          }
        }
        sv_x_out = Rstats::Func::new_vector<Rstats::Complex>(sv_r, v2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(1);
        Rstats::Double v2_total(0);
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2_total += v1->get_value<Rstats::Double>(i);
        }
        v2->set_value<Rstats::Double>(0, v2_total);
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          if (v1->exists_na_position(i)) {
            v2->add_na_position(0);
            break;
          }
        }
        sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r, v2);
      }
      else if (strEQ(type, "integer")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(1);
        Rstats::Integer v2_total(0);
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          v2_total += v1->get_value<Rstats::Integer>(i);
        }
        v2->set_value<Rstats::Integer>(0, v2_total);
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          if (v1->exists_na_position(i)) {
            v2->add_na_position(0);
            break;
          }
        }
        sv_x_out = Rstats::Func::new_vector<Rstats::Integer>(sv_r, v2);
      }
      else if (strEQ(type, "logical")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(1);
        Rstats::Integer v2_total(0);
        for (Rstats::Logical i = 0; i < v1->get_length(); i++) {
          v2_total += v1->get_value<Rstats::Logical>(i);
        }
        v2->set_value<Rstats::Integer>(0, v2_total);
        for (Rstats::Logical i = 0; i < v1->get_length(); i++) {
          if (v1->exists_na_position(i)) {
            v2->add_na_position(0);
            break;
          }
        }
        sv_x_out = Rstats::Func::new_vector<Rstats::Integer>(sv_r, v2);
      }
      else if (strEQ(type, "NULL")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(1, 0);
        sv_x_out = Rstats::Func::new_vector<Rstats::Integer>(sv_r, v2);
      }
      else {
        croak("Error in sum() : non-numeric argument to sum()");
      }
      
      
      return sv_x_out;
    }

    SV* prod(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      
      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(1);
        Rstats::Complex v2_total(1);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2_total *= v1->get_value<Rstats::Complex>(i);
        }
        v2->set_value<Rstats::Complex>(0, v2_total);
        
        for (Rstats::Integer i = 0; i < length; i++) {
          if (v1->exists_na_position(i)) {
            v2->add_na_position(0);
            break;
          }
        }
        sv_x_out = Rstats::Func::new_vector<Rstats::Complex>(sv_r, v2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(1);
        Rstats::Double v2_total(1);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2_total *= v1->get_value<Rstats::Double>(i);
        }
        v2->set_value<Rstats::Double>(0, v2_total);
        for (Rstats::Integer i = 0; i < length; i++) {
          if (v1->exists_na_position(i)) {
            v2->add_na_position(0);
            break;
          }
        }
        sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r, v2);
      }
      else if (strEQ(type, "integer")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(1);
        Rstats::Double v2_total(1);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2_total *= v1->get_value<Rstats::Integer>(i);
        }
        v2->set_value<Rstats::Double>(0, v2_total);
        for (Rstats::Integer i = 0; i < length; i++) {
          if (v1->exists_na_position(i)) {
            v2->add_na_position(0);
            break;
          }
        }
        sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r, v2);
      }
      else if (strEQ(type, "logical")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(1);
        Rstats::Double v2_total(1);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2_total *= v1->get_value<Rstats::Logical>(i);
        }
        v2->set_value<Rstats::Double>(0, v2_total);
        for (Rstats::Integer i = 0; i < length; i++) {
          if (v1->exists_na_position(i)) {
            v2->add_na_position(0);
            break;
          }
        }
        sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r, v2);
      }
      else if (strEQ(type, "NULL")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(1, 1);
        sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r, v2);
      }
      else {
        croak("Error in prod() : non-numeric argument to prod()");
      }
      
      return sv_x_out;
    }
        
    SV* equal(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_object(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_x_out;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character, Rstats::Character) = &Rstats::ElementFunc::equal;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "complex")) {
        Rstats::Logical (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::equal;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::equal;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::equal;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in == : default method not implemented for type '%s'", type);
      }
      
      return sv_x_out;
    }

    SV* not_equal(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_object(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_x_out;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character, Rstats::Character) = &Rstats::ElementFunc::not_equal;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "complex")) {
        Rstats::Logical (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::not_equal;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::not_equal;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::not_equal;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in != : default method not implemented for type '%s'", type);
      }
      
      return sv_x_out;
    }

    SV* more_than(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_object(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_x_out;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character, Rstats::Character) = &Rstats::ElementFunc::more_than;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "complex")) {
        croak("Error in > operator : invalid comparison with complex values");
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::more_than;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::more_than;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in > : default method not implemented for type '%s'", type);
      }
      
      return sv_x_out;
    }

    SV* less_than(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_object(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_x_out;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character, Rstats::Character) = &Rstats::ElementFunc::less_than;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "complex")) {
        croak("Error in < operator : invalid comparison with complex values");
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::less_than;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::less_than;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in < : default method not implemented for type '%s'", type);
      }
      
      return sv_x_out;
    }

    SV* less_than_or_equal(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_object(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_x_out;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character, Rstats::Character) = &Rstats::ElementFunc::less_than_or_equal;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "complex")) {
        croak("Error in <= operator : invalid comparison with complex values");
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::less_than_or_equal;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::less_than_or_equal;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in <= : default method not implemented for type '%s'", type);
      }
      
      return sv_x_out;
    }

    SV* more_than_or_equal(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_object(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_x_out;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character, Rstats::Character) = &Rstats::ElementFunc::more_than_or_equal;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "complex")) {
        croak("Error in >= operator : invalid comparison with complex values");
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::more_than_or_equal;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::more_than_or_equal;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in >= : default method not implemented for type '%s'", type);
      }
      
      return sv_x_out;
    }

    SV* And(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_object(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_x_out;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character, Rstats::Character) = &Rstats::ElementFunc::And;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "complex")) {
        Rstats::Logical (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::And;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::And;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::And;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in & : default method not implemented for type '%s'", type);
      }
      
      return sv_x_out;
    }

    SV* Or(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_object(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_x_out;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character, Rstats::Character) = &Rstats::ElementFunc::Or;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "complex")) {
        Rstats::Logical (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::Or;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::Or;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::Or;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in | : default method not implemented for type '%s'", type);
      }
      
      return sv_x_out;
    }

    SV* add(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_object(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_x_out;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::add;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::add;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Integer (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::add;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in + : non-numeric argument to binary operator");
      }
      
      return sv_x_out;
    }
    
    SV* subtract(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_object(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_x_out;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::subtract;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::subtract;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Integer (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::subtract;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in - : non-numeric argument to binary operator");
      }
      
      return sv_x_out;
    }

    SV* remainder(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_object(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_x_out;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "complex")) {
        croak("Error in %% operator: unimplemented complex operation");
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::remainder;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::remainder;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in % operator : non-numeric argument to binary operator");
      }
      
      return sv_x_out;
    }

    SV* divide(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_object(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_x_out;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::divide;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::divide;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::divide;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in / operator : non-numeric argument to binary operator");
      }
      
      return sv_x_out;
    }

    SV* atan2(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_object(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_x_out;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::atan2;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::atan2;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::atan2;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in atan2 : non-numeric argument to atan2");
      }
      
      return sv_x_out;
    }

    SV* pow(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_object(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_x_out;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::pow;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::pow;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::pow;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in pow : non-numeric argument to v");
      }
      
      return sv_x_out;
    }
                                        
    SV* multiply(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_object(sv_r, sv_x2);
      
      // Upgrade type and length
      upgrade_type(sv_r, 2, &sv_x1, &sv_x2);
      upgrade_length(sv_r, 2, &sv_x1, &sv_x2);
      
      SV* sv_x_out;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex, Rstats::Complex) = &Rstats::ElementFunc::multiply;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double, Rstats::Double) = &Rstats::ElementFunc::multiply;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Integer (*func)(Rstats::Integer, Rstats::Integer) = &Rstats::ElementFunc::multiply;
        sv_x_out = Rstats::Func::operate_binary(sv_r, func, sv_x1, sv_x2);
      }
      else {
        croak("Error in * : non-numeric argument to binary operator");
      }
      
      return sv_x_out;
    }
                        
    SV* sin(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::sin;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::sin;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::sin;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in sin() : non-numeric argument to sin()");
      }
      
      return sv_x_out;
    }

    SV* tanh(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::tanh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::tanh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::tanh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in tanh() : non-numeric argument to tanh()");
      }
      
      return sv_x_out;
    }

    SV* cos(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::cos;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::cos;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::cos;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in cos() : non-numeric argument to cos()");
      }
      
      return sv_x_out;
    }

    SV* tan(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::tan;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::tan;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::tan;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in tan() : non-numeric argument to tan()");
      }
      
      return sv_x_out;
    }

    SV* sinh(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::sinh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::sinh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::sinh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in sinh() : non-numeric argument to sinh()");
      }
      
      return sv_x_out;
    }

    SV* cosh(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::cosh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::cosh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::cosh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in cosh() : non-numeric argument to cosh()");
      }
      
      return sv_x_out;
    }

    SV* log(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::log;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::log;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::log;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in log() : non-numeric argument to log()");
      }
      
      return sv_x_out;
    }

    SV* logb(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::logb;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::logb;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::logb;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in logb() : non-numeric argument to logb()");
      }
      
      return sv_x_out;
    }

    SV* log10(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::log10;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::log10;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::log10;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in log10() : non-numeric argument to log10()");
      }
      
      return sv_x_out;
    }

    SV* negation(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::negation;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::negation;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Integer (*func)(Rstats::Integer) = &Rstats::ElementFunc::negation;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in negation() : non-numeric argument to negation()");
      }
      
      return sv_x_out;
    }

    SV* Arg(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Double (*func)(Rstats::Complex) = &Rstats::ElementFunc::Arg;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::Arg;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::Arg;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in Arg() : non-numeric argument to Arg()");
      }
      
      return sv_x_out;
    }

    SV* abs(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Double (*func)(Rstats::Complex) = &Rstats::ElementFunc::abs;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::abs;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::abs;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in abs() : non-numeric argument to abs()");
      }
      
      return sv_x_out;
    }

    SV* Mod(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Double (*func)(Rstats::Complex) = &Rstats::ElementFunc::Mod;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::Mod;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::Mod;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in Mod() : non-numeric argument to Mod()");
      }
      
      return sv_x_out;
    }

    SV* Re(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Double (*func)(Rstats::Complex) = &Rstats::ElementFunc::Re;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::Re;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::Re;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in Re() : non-numeric argument to Re()");
      }
      
      return sv_x_out;
    }

    SV* Im(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Double (*func)(Rstats::Complex) = &Rstats::ElementFunc::Im;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::Im;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::Im;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in Im() : non-numeric argument to Im()");
      }
      
      return sv_x_out;
    }
        
    SV* log2(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::log2;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::log2;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::log2;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in log2() : non-numeric argument to log2()");
      }
      
      return sv_x_out;
    }

    SV* is_infinite(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Logical (*func)(Rstats::Complex) = &Rstats::ElementFunc::is_infinite;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double) = &Rstats::ElementFunc::is_infinite;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer) = &Rstats::ElementFunc::is_infinite;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in is_infinite() : default method not implemented for type '%s'", type);
      }
      
      return sv_x_out;
    }

    SV* is_nan(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "character")) {
        Rstats::Logical (*func)(Rstats::Character) = &Rstats::ElementFunc::is_nan;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "complex")) {
        Rstats::Logical (*func)(Rstats::Complex) = &Rstats::ElementFunc::is_nan;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double) = &Rstats::ElementFunc::is_nan;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer) = &Rstats::ElementFunc::is_nan;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in is_nan() : default method not implemented for type '%s'", type);
      }
      
      return sv_x_out;
    }
    
    SV* is_finite(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Logical (*func)(Rstats::Complex) = &Rstats::ElementFunc::is_finite;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Logical (*func)(Rstats::Double) = &Rstats::ElementFunc::is_finite;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Logical (*func)(Rstats::Integer) = &Rstats::ElementFunc::is_finite;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in is_finite() : default method not implemented for type '%s'", type);
      }
      
      return sv_x_out;
    }
    
    SV* acos(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::acos;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::acos;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::acos;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in acos() : non-numeric argument to acos()");
      }
      
      return sv_x_out;
    }

    SV* acosh(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::acosh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::acosh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::acosh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in acosh() : non-numeric argument to acosh()");
      }
      
      return sv_x_out;
    }

    SV* asinh(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::asinh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::asinh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::asinh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in asinh() : non-numeric argument to asinh()");
      }
      
      return sv_x_out;
    }

    SV* atanh(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::atanh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::atanh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::atanh;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in atanh() : non-numeric argument to atanh()");
      }
      
      return sv_x_out;
    }

    SV* Conj(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::Conj;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::Conj;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::Conj;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in Conj() : non-numeric argument to Conj()");
      }
      
      return sv_x_out;
    }
    
    SV* asin(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::asin;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::asin;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::asin;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in asin() : non-numeric argument to asin()");
      }
      
      return sv_x_out;
    }
    
    SV* atan(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::atan;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::atan;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::atan;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in atan() : non-numeric argument to atan()");
      }
      
      return sv_x_out;
    }
    
    SV* sqrt(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::sqrt;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::sqrt;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::sqrt;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in sqrt() : non-numeric argument to sqrt()");
      }
      
      return sv_x_out;
    }
    
    SV* expm1(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::expm1;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::expm1;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::expm1;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in expm1() : non-numeric argument to expm1()");
      }
      
      return sv_x_out;
    }

    SV* exp(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "complex")) {
        Rstats::Complex (*func)(Rstats::Complex) = &Rstats::ElementFunc::exp;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "double")) {
        Rstats::Double (*func)(Rstats::Double) = &Rstats::ElementFunc::exp;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else if (strEQ(type, "integer") || strEQ(type, "logical")) {
        Rstats::Double (*func)(Rstats::Integer) = &Rstats::ElementFunc::exp;
        sv_x_out = Rstats::Func::operate_unary(sv_r, func, sv_x1);
      }
      else {
        croak("Error in exp() : non-numeric argument to exp()");
      }
      
      return sv_x_out;
    }
                      
    SV* upgrade_length_avrv(SV* sv_r, SV* sv_xs) {
      
      Rstats::Integer xs_length = Rstats::pl_av_len(sv_xs);
      Rstats::Integer max_length = 0;
      for (Rstats::Integer i = 0; i < xs_length; i++) {
        SV* sv_x1 = Rstats::pl_av_fetch(sv_xs, i);
        Rstats::Integer x1_length = Rstats::Func::get_length(sv_r, sv_x1);
        
        if (x1_length > max_length) {
          max_length = x1_length;
        }
      }
      
      SV* sv_new_xs = Rstats::pl_new_avrv();;
      for (Rstats::Integer i = 0; i < xs_length; i++) {
        SV* sv_x1 = Rstats::pl_av_fetch(sv_xs, i);
        Rstats::Integer x1_length = Rstats::Func::get_length(sv_r, sv_x1);
        
        if (x1_length != max_length) {
          Rstats::Vector* v_length = Rstats::VectorFunc::new_vector<Rstats::Double>(1, max_length);
          SV* sv_x_length = Rstats::Func::new_vector<Rstats::Double>(sv_r, v_length);
          Rstats::pl_av_push(
            sv_new_xs,
            Rstats::Func::array(sv_r, sv_x1, sv_x_length)
          );
        }
        else {
          Rstats::pl_av_push(sv_new_xs, sv_x1);
        }
      }
      
      return sv_new_xs;
    }
    
    void upgrade_length(SV* sv_r, Rstats::Integer num, ...) {
      va_list args;
      
      // Optimization if args count is 2
      va_start(args, num);
      if (num == 2) {
        SV* sv_x1 = *va_arg(args, SV**);
        SV* sv_x2 = *va_arg(args, SV**);

        Rstats::Integer x1_length = Rstats::Func::get_length(sv_r, sv_x1);
        Rstats::Integer x2_length = Rstats::Func::get_length(sv_r, sv_x2);
        
        if (x1_length == x2_length) {
          return;
        }
      }
      va_end(args);
      
      SV* sv_args = Rstats::pl_new_avrv();
      va_start(args, num);
      for (Rstats::Integer i = 0; i < num; i++) {
        SV** arg = va_arg(args, SV**);
        SV* x = *arg;
        Rstats::pl_av_push(sv_args, x);
      }
      va_end(args);
      
      SV* sv_result = Rstats::Func::upgrade_length_avrv(sv_r, sv_args);
      
      va_start(args, num);
      for (Rstats::Integer i = 0; i < num; i++) {
        SV** arg = va_arg(args, SV**);
        SV* sv_x = Rstats::pl_av_fetch(sv_result, i);

        *arg = sv_x;
      }
      va_end(args);
    }
        
    void upgrade_type(SV* sv_r, Rstats::Integer num, ...) {
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
      for (Rstats::Integer i = 0; i < num; i++) {
        SV** arg = va_arg(args, SV**);
        SV* x = *arg;
        Rstats::pl_av_push(upgrade_type_args, x);
      }
      va_end(args);
      
      SV* upgrade_type_result = Rstats::Func::upgrade_type_avrv(sv_r, upgrade_type_args);
      
      va_start(args, num);
      for (Rstats::Integer i = 0; i < num; i++) {
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
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);
      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "character")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Character>(length);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2->set_value<Rstats::Character>(i, v1->get_value<Rstats::Character>(i));
        }
        v2->merge_na_positions(v1->get_na_positions());
        sv_x_out = Rstats::Func::new_vector<Rstats::Character>(sv_r, v2);
      }
      else if (strEQ(type, "complex")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Complex>(length);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2->set_value<Rstats::Complex>(i, v1->get_value<Rstats::Complex>(i));
        }
        v2->merge_na_positions(v1->get_na_positions());
        sv_x_out = Rstats::Func::new_vector<Rstats::Complex>(sv_r, v2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(length);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2->set_value<Rstats::Double>(i, v1->get_value<Rstats::Double>(i));
        }
        v2->merge_na_positions(v1->get_na_positions());
        sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r, v2);
      }
      else if (strEQ(type, "integer")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Integer>(length);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2->set_value<Rstats::Integer>(i, v1->get_value<Rstats::Integer>(i));
        }
        v2->merge_na_positions(v1->get_na_positions());
        sv_x_out = Rstats::Func::new_vector<Rstats::Integer>(sv_r, v2);
      }
      else if (strEQ(type, "logical")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Logical>(length);
        for (Rstats::Integer i = 0; i < length; i++) {
          v2->set_value<Rstats::Integer>(i, v1->get_value<Rstats::Integer>(i));
        }
        v2->merge_na_positions(v1->get_na_positions());
        sv_x_out = Rstats::Func::new_vector<Rstats::Logical>(sv_r, v2);
      }
      
      return sv_x_out;
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
        ? Rstats::pl_hv_fetch(sv_args_h, "dim") : Rstats::Func::new_NULL(sv_r);
      Rstats::Integer x1_length = Rstats::Func::get_length(sv_r, sv_x1);
      
      if (!Rstats::Func::get_length(sv_r, sv_x_dim)) {
        Rstats::Vector* v_dim = Rstats::VectorFunc::new_vector<Rstats::Integer>(1, x1_length);
        sv_x_dim = Rstats::Func::new_vector<Rstats::Integer>(sv_r, v_dim);
      }
      Rstats::Integer dim_product = 1;
      Rstats::Integer x_dim_length = Rstats::Func::get_length(sv_r, sv_x_dim);
      for (Rstats::Integer i = 0; i < x_dim_length; i++) {
        SV* sv_values = Rstats::Func::values(sv_r, sv_x_dim);
        dim_product *= SvIV(Rstats::pl_av_fetch(sv_values, i));
      }

      
      // Fix elements length
      SV* sv_elements;
      if (x1_length == dim_product) {
        sv_elements = Rstats::Func::decompose(sv_r, sv_x1);
      }
      else if (x1_length > dim_product) {
        SV* sv_elements_tmp = Rstats::Func::decompose(sv_r, sv_x1);
        sv_elements = Rstats::pl_new_avrv();
        for (Rstats::Integer i = 0; i < dim_product; i++) {
          Rstats::pl_av_push(sv_elements, Rstats::pl_av_fetch(sv_elements_tmp, i));
        }
      }
      else if (x1_length < dim_product) {
        SV* sv_elements_tmp = Rstats::Func::decompose(sv_r, sv_x1);
        Rstats::Integer elements_tmp_length = Rstats::pl_av_len(sv_elements_tmp);
        Rstats::Integer repeat_count = (Rstats::Integer)(dim_product / elements_tmp_length) + 1;
        SV* sv_elements_tmp2 = Rstats::pl_new_avrv();
        Rstats::Integer elements_tmp2_length = Rstats::pl_av_len(sv_elements_tmp2);
        for (Rstats::Integer i = 0; i < repeat_count; i++) {
          for (Rstats::Integer k = 0; k < elements_tmp_length; k++) {
            Rstats::pl_av_push(sv_elements_tmp2, Rstats::pl_av_fetch(sv_elements_tmp, k));
          }
        }
        sv_elements = Rstats::pl_new_avrv();
        for (Rstats::Integer i = 0; i < dim_product; i++) {
          Rstats::pl_av_push(sv_elements, Rstats::pl_av_fetch(sv_elements_tmp2, i));
        }
      }
      
      SV* sv_x2 = Rstats::Func::c_(sv_r, sv_elements);
      Rstats::Func::dim(sv_r, sv_x2, sv_x_dim);
      
      return sv_x2;
    }

    SV* upgrade_type_avrv(SV* sv_r, SV* sv_xs) {
      
      // Check elements
      SV* sv_type_h = Rstats::pl_new_hvrv();
      
      Rstats::Integer xs_length = Rstats::pl_av_len(sv_xs);
      for (Rstats::Integer i = 0; i < xs_length; i++) {
        SV* sv_x1 = Rstats::pl_av_fetch(sv_xs, i);
        char* type = Rstats::Func::get_type(sv_r, sv_x1);
        
        Rstats::pl_hv_store(sv_type_h, type, Rstats::pl_new_sv_iv(1));
      }

      // Upgrade elements and type if type is different
      SV* sv_new_xs = Rstats::pl_new_avrv();;
      Rstats::Integer type_length = Rstats::pl_hv_key_count(sv_type_h);

      if (type_length > 1) {
        SV* sv_to_type;
        if (Rstats::pl_hv_exists(sv_type_h, "character")) {
          sv_to_type = Rstats::pl_new_sv_pv("character");
        }
        else if (Rstats::pl_hv_exists(sv_type_h, "complex")) {
          sv_to_type = Rstats::pl_new_sv_pv("complex");
        }
        else if (Rstats::pl_hv_exists(sv_type_h, "double")) {
          sv_to_type = Rstats::pl_new_sv_pv("double");
        }
        else if (Rstats::pl_hv_exists(sv_type_h, "integer")) {
          sv_to_type = Rstats::pl_new_sv_pv("integer");
        }
        else if (Rstats::pl_hv_exists(sv_type_h, "logical")) {
          sv_to_type = Rstats::pl_new_sv_pv("logical");
        }
        
        for (Rstats::Integer i = 0; i < xs_length; i++) {
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
      sv_x_dim = Rstats::Func::to_object(sv_r, sv_x_dim);
      
      Rstats::Integer x1_length = Rstats::Func::get_length(sv_r, sv_x1);
      Rstats::Integer x1_length_by_dim = 1;
      
      SV* sv_x_dim_values = values(sv_r, sv_x_dim);
      Rstats::Integer x_dim_values_length = Rstats::pl_av_len(sv_x_dim_values);
      
      for (Rstats::Integer i = 0; i < x_dim_values_length; i++) {
        SV* sv_x_dim_value = Rstats::pl_av_fetch(sv_x_dim_values, i);
        Rstats::Integer x_dim_value = SvIV(sv_x_dim_value);
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
        sv_x_dim = Rstats::Func::new_NULL(sv_r);
      }
      
      return sv_x_dim;
    }

    SV* values(SV* sv_r, SV* sv_x1) {
      
      SV* sv_values = Rstats::Func::create_sv_values(sv_r, sv_x1);
      
      return sv_values;
    }

    SV* Typeof(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      Rstats::Vector* v_out = Rstats::VectorFunc::new_vector<Rstats::Character>(1, Rstats::pl_new_sv_pv(type));
      SV* sv_x_out = Rstats::Func::new_vector<Rstats::Character>(sv_r, v_out);
      
      return sv_x_out;
    }
    
    SV* type(SV* sv_r, SV* sv_x1) {
      
      return Rstats::pl_new_sv_pv(Rstats::Func::get_type(sv_r, sv_x1));
    }

    SV* is_null (SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "NULL");
      
      SV* sv_is = is ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
            
      return sv_is;
    }
    
    SV* is_vector (SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_object_type(sv_r, sv_x1), "array")
        && !Rstats::pl_hv_exists(sv_x1, "dim");
      
      SV* sv_is = is ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
            
      return sv_is;
    }

    SV* is_array(SV* sv_r, SV* sv_x1) {

      bool is = strEQ(Rstats::Func::get_object_type(sv_r, sv_x1), "array")
        && Rstats::pl_hv_exists(sv_x1, "dim");
      
      SV* sv_x_is = is ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
      
      return sv_x_is;
    }

    SV* is_matrix(SV* sv_r, SV* sv_x1) {

      Rstats::Logical is = strEQ(Rstats::Func::get_object_type(sv_r, sv_x1), "array")
        && Rstats::Func::get_length(sv_r, dim(sv_r, sv_x1)) == 2;
      
      SV* sv_x_is = is ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
      
      return sv_x_is;
    }

    Rstats::Logical to_bool (SV* sv_r, SV* sv_x1) {
      
      if (strEQ(Rstats::Func::get_type(sv_r, sv_x1), "logical")) {
        Rstats::Vector* v1 = get_vector(sv_r, sv_x1);
        Rstats::Logical is = v1->get_value<Rstats::Integer>(0);
        return is;
      }
      else {
        croak("to_bool receive logical array");
      }
    }

    SV* pi (SV* sv_r) {
      Rstats::Double pi = Rstats::Util::pi();
      
      Rstats::Vector* v_out = Rstats::VectorFunc::new_vector(1, pi);
      SV* sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r, v_out);
      
      return sv_x_out;
    }

    SV* c_character(SV* sv_r, SV* sv_values) {
      if (!sv_derived_from(sv_values, "ARRAY")) {
        SV* sv_values_av_ref = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_values_av_ref, sv_values);
        sv_values = sv_values_av_ref;
      }
      
      Rstats::Integer length = Rstats::pl_av_len(sv_values);
      
      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Character>(length);
      for (Rstats::Integer i = 0; i < length; i++) {
        SV* sv_value = Rstats::pl_av_fetch(sv_values, i);

        if (SvOK(sv_value)) {
          v1->set_value<Rstats::Character>(i,sv_value);
        }
        else {
          v1->add_na_position(i);
        }
      }
      
      SV* sv_x1 = Rstats::Func::new_vector<Rstats::Character>(sv_r, v1);
      
      return sv_x1;
    }

    template <>
    SV* new_vector<Rstats::Character>(SV* sv_r) {
      SV* sv_x1 = Rstats::pl_new_hvrv();
      
      sv_bless(sv_x1, gv_stashpv("Rstats::Object", 1));
      Rstats::pl_hv_store(sv_x1, "r", sv_r);
      Rstats::pl_hv_store(sv_x1, "object_type", Rstats::pl_new_sv_pv("array"));
      Rstats::pl_hv_store(sv_x1, "type", Rstats::pl_new_sv_pv("character"));
      
      return sv_x1;
    }

    template <>
    SV* new_vector<Rstats::Complex>(SV* sv_r) {
      SV* sv_x1 = Rstats::pl_new_hvrv();
      
      sv_bless(sv_x1, gv_stashpv("Rstats::Object", 1));
      Rstats::pl_hv_store(sv_x1, "r", sv_r);
      Rstats::pl_hv_store(sv_x1, "object_type", Rstats::pl_new_sv_pv("array"));
      Rstats::pl_hv_store(sv_x1, "type", Rstats::pl_new_sv_pv("complex"));
      
      return sv_x1;
    }
    
    template <>
    SV* new_vector<Rstats::Double>(SV* sv_r) {
      SV* sv_x1 = Rstats::pl_new_hvrv();
      
      sv_bless(sv_x1, gv_stashpv("Rstats::Object", 1));
      Rstats::pl_hv_store(sv_x1, "r", sv_r);
      Rstats::pl_hv_store(sv_x1, "object_type", Rstats::pl_new_sv_pv("array"));
      Rstats::pl_hv_store(sv_x1, "type", Rstats::pl_new_sv_pv("double"));
      
      return sv_x1;
    }

    template <>
    SV* new_vector<Rstats::Integer>(SV* sv_r) {
      SV* sv_x1 = Rstats::pl_new_hvrv();
      
      sv_bless(sv_x1, gv_stashpv("Rstats::Object", 1));
      Rstats::pl_hv_store(sv_x1, "r", sv_r);
      Rstats::pl_hv_store(sv_x1, "object_type", Rstats::pl_new_sv_pv("array"));
      Rstats::pl_hv_store(sv_x1, "type", Rstats::pl_new_sv_pv("integer"));
      
      return sv_x1;
    }

    template <>
    SV* new_vector<Rstats::Logical>(SV* sv_r) {
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
      
      Rstats::Integer length = Rstats::pl_av_len(sv_values);
      
      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Double>(length);
      for (Rstats::Integer i = 0; i < length; i++) {
        SV* sv_value = Rstats::pl_av_fetch(sv_values, i);

        if (SvOK(sv_value)) {
          char* sv_value_str = SvPV_nolen(sv_value);
          if (strEQ(sv_value_str, "NaN")) {
            v1->set_value<Rstats::Double>(i, NAN);
          }
          else if (strEQ(sv_value_str, "Inf")) {
            v1->set_value<Rstats::Double>(i, INFINITY);
          }
          else if (strEQ(sv_value_str, "-Inf")) {
            v1->set_value<Rstats::Double>(i, -(INFINITY));
          }
          else {
            Rstats::Double value = SvNV(sv_value);
            v1->set_value<Rstats::Double>(i, value);
          }
        }
        else {
          v1->add_na_position(i);
        }
      }
      
      SV* sv_x1 = Rstats::Func::new_vector<Rstats::Double>(sv_r, v1);
      
      return sv_x1;
    }

    SV* c_complex(SV* sv_r, SV* sv_values) {
      if (!sv_derived_from(sv_values, "ARRAY")) {
        SV* sv_values_av_ref = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_values_av_ref, sv_values);
        sv_values = sv_values_av_ref;
      }
      
      Rstats::Integer length = Rstats::pl_av_len(sv_values);
      
      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Complex>(length);
      for (Rstats::Integer i = 0; i < length; i++) {
        SV* sv_value = Rstats::pl_av_fetch(sv_values, i);
        
        if (SvOK(sv_value)) {
          SV* sv_value_re = Rstats::pl_hv_fetch(sv_value, "re");
          SV* sv_value_im = Rstats::pl_hv_fetch(sv_value, "im");

          Rstats::Double re;
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
          

          Rstats::Double im;
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
          
          v1->set_value<Rstats::Complex>(
            i,
            Rstats::Complex(re, im)
          );
        }
        else {
          v1->add_na_position(i);
        }
      }
      
      SV* sv_x1 = Rstats::Func::new_vector<Rstats::Complex>(sv_r, v1);
      
      return sv_x1;
    }

    SV* c_integer(SV* sv_r, SV* sv_values) {
      if (!sv_derived_from(sv_values, "ARRAY")) {
        SV* sv_values_av_ref = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_values_av_ref, sv_values);
        sv_values = sv_values_av_ref;
      }
      
      Rstats::Integer length = Rstats::pl_av_len(sv_values);
      
      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Integer>(length);
      for (Rstats::Integer i = 0; i < length; i++) {
        SV* sv_value = Rstats::pl_av_fetch(sv_values, i);
        
        if (SvOK(sv_value)) {
          v1->set_value<Rstats::Integer>(
            i,
            SvIV(sv_value)
          );
        }
        else {
          v1->add_na_position(i);
        }
      }
      
      SV* sv_x1 = Rstats::Func::new_vector<Rstats::Integer>(sv_r, v1);
      
      return sv_x1;
    }

    SV* c_logical(SV* sv_r, SV* sv_values) {
      if (!sv_derived_from(sv_values, "ARRAY")) {
        SV* sv_values_av_ref = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_values_av_ref, sv_values);
        sv_values = sv_values_av_ref;
      }
      
      Rstats::Integer length = Rstats::pl_av_len(sv_values);
      
      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Logical>(length);
      for (Rstats::Integer i = 0; i < length; i++) {
        SV* sv_value = Rstats::pl_av_fetch(sv_values, i);
        
        if (SvOK(sv_value)) {
          v1->set_value<Rstats::Integer>(
            i,
            SvIV(sv_value)
          );
        }
        else {
          v1->add_na_position(i);
        }
      }
      
      SV* sv_x1 = Rstats::Func::new_vector<Rstats::Logical>(sv_r, v1);
      
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

    SV* new_NULL(SV* sv_r) {
      
      SV* sv_x1 = Rstats::pl_new_hvrv();
      sv_bless(sv_x1, gv_stashpv("Rstats::Object", 1));
      Rstats::pl_hv_store(sv_x1, "r", sv_r);
      Rstats::pl_hv_store(sv_x1, "object_type", Rstats::pl_new_sv_pv("NULL"));
      Rstats::pl_hv_store(sv_x1, "type", Rstats::pl_new_sv_pv("NULL"));
      
      return sv_x1;
    }
    
    SV* new_NA(SV* sv_r) {
      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Logical>(1, 0);
      v1->add_na_position(0);

      SV* sv_x1 = Rstats::Func::new_vector<Rstats::Logical>(sv_r, v1);
      
      return sv_x1;
    }

    SV* new_NaN(SV* sv_r) {
      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Double>(1, NAN);
      
      SV* sv_x1 = Rstats::Func::new_vector<Rstats::Double>(sv_r, v1);
      
      return sv_x1;
    }

    SV* new_Inf(SV* sv_r) {
      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Double>(1, INFINITY);
      
      SV* sv_x1 = Rstats::Func::new_vector<Rstats::Double>(sv_r, v1);
      
      return sv_x1;
    }

    SV* new_FALSE(SV* sv_r) {
      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Logical>(1, 0);
      
      SV* sv_x1 = Rstats::Func::new_vector<Rstats::Logical>(sv_r, v1);
      
      return sv_x1;
    }

    SV* new_TRUE(SV* sv_r) {
      Rstats::Vector* v1 = Rstats::VectorFunc::new_vector<Rstats::Logical>(1, 1);
      
      SV* sv_x1 = Rstats::Func::new_vector<Rstats::Logical>(sv_r, v1);

      return sv_x1;
    }

    SV* to_object(SV* sv_r, SV* sv_x) {
      
      Rstats::Logical is_object = sv_isobject(sv_x) && sv_derived_from(sv_x, "Rstats::Object");
      
      SV* sv_x1;
      if (is_object) {
        sv_x1 = sv_x;
      }
      else {
        SV* sv_tmp = Rstats::pl_new_avrv();
        Rstats::pl_av_push(sv_tmp, sv_x);
        sv_x1 = Rstats::Func::c_(sv_r, sv_tmp);
      }
      
      return sv_x1;
    }

    SV* is_numeric(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "double")
        || strEQ(Rstats::Func::get_type(sv_r, sv_x1), "integer");
        
      SV* sv_x_is = is ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
      
      return sv_x_is;
    }

    SV* is_double(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "double");
        
      SV* sv_x_is = is ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
      
      return sv_x_is;
    }

    SV* is_integer(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "integer");
        
      SV* sv_x_is = is ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
      
      return sv_x_is;
    }

    SV* is_complex(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "complex");
        
      SV* sv_x_is = is ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
      
      return sv_x_is;
    }

    SV* is_character(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "character");
        
      SV* sv_x_is = is ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
      
      return sv_x_is;
    }

    SV* is_logical(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "logical");
        
      SV* sv_x_is = is ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
      
      return sv_x_is;
    }

    SV* is_data_frame(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_object_type(sv_r, sv_x1), "data.frame");
        
      SV* sv_x_is = is ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
      
      return sv_x_is;
    }

    SV* is_list(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "list");
        
      SV* sv_x_is = is ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
      
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
        
        Rstats::Vector* v2_names;
        SV* sv_x2_names;
        if (SvOK(sv_index)) {
          
          SV* sv_x1_names_values = Rstats::Func::values(sv_r, Rstats::pl_hv_fetch(sv_x1, "names"));
          SV* sv_index_values = Rstats::Func::values(sv_r, sv_index);
          Rstats::Vector* v2_names = Rstats::VectorFunc::new_vector<Rstats::Character>(Rstats::pl_av_len(sv_index_values));
          
          for (Rstats::Integer i = 0; i < Rstats::pl_av_len(sv_index_values); i++) {
            Rstats::Integer idx = SvIV(Rstats::pl_av_fetch(sv_index_values, i));
            SV* sv_x2_names_value = Rstats::pl_av_fetch(sv_x1_names_values, idx - 1);
            v2_names->set_value(i, Rstats::pl_new_sv_sv(sv_x2_names_value));
          }
          sv_x2_names = Rstats::Func::new_vector<Rstats::Character>(sv_r, v2_names);
        }
        else {
          sv_x2_names = Rstats::Func::clone(sv_r, Rstats::pl_hv_fetch(sv_x1, "names"));
        }
        Rstats::pl_hv_store(sv_x2, "names", sv_x2_names);
      }
      
      // dimnames
      if (!SvOK(Rstats::pl_hv_fetch(sv_x2, "dimnames")) && Rstats::pl_hv_exists(sv_x1, "dimnames")) {
        SV* sv_new_dimnames = Rstats::pl_new_avrv();
        SV* sv_dimnames = Rstats::pl_hv_fetch(sv_x1, "dimnames");
        Rstats::Integer length = Rstats::pl_av_len(sv_dimnames);
        for (Rstats::Integer i = 0; i < length; i++) {
          SV* sv_dimname = Rstats::pl_av_fetch(sv_dimnames, i);
          if (SvOK(sv_dimname) && Rstats::Func::get_length(sv_r, sv_dimname) > 0) {
            SV* sv_index = SvOK(sv_new_indexes) ? Rstats::pl_av_fetch(sv_new_indexes, i) : &PL_sv_undef;
            SV* sv_dimname_values = Rstats::Func::values(sv_r, sv_dimname);
            SV* sv_new_dimname_values = Rstats::pl_new_avrv();
            SV* sv_x2_dimnames;
            if (SvOK(sv_index)) {
              SV* sv_index_values = Rstats::Func::values(sv_r, sv_index);
              Rstats::Vector* v_k = Rstats::VectorFunc::new_vector<Rstats::Character>(Rstats::pl_av_len(sv_index_values));
              for (Rstats::Integer i = 0; i < Rstats::pl_av_len(sv_index_values); i++) {
                SV* sv_k = Rstats::pl_av_fetch(sv_index_values, i);
                v_k->set_value<Rstats::Character>(i, Rstats::pl_new_sv_sv(Rstats::pl_av_fetch(sv_dimname_values, SvIV(sv_k) - 1)));
              }
              sv_x2_dimnames = Rstats::Func::new_vector<Rstats::Character>(sv_r, v_k);
            }
            else {
              sv_x2_dimnames = Rstats::Func::clone(sv_r, sv_dimname);
            }
            Rstats::pl_av_push(sv_new_dimnames, sv_x2_dimnames);
          }
        }
        Rstats::pl_hv_store(sv_x2, "dimnames", sv_new_dimnames);
      }
    }

    SV* is_na(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_object(sv_r, sv_x1);

      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      SV* sv_x_out;
      if (strEQ(type, "character")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Logical>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          if (v1->exists_na_position(i)) {
            v2->set_value<Rstats::Integer>(i, 1);
          }
          else {
            v2->set_value<Rstats::Integer>(i, 0);
          }
        }
        sv_x_out = Rstats::Func::new_vector<Rstats::Logical>(sv_r, v2);
      }
      else if (strEQ(type, "complex")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Logical>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          if (v1->exists_na_position(i)) {
            v2->set_value<Rstats::Integer>(i, 1);
          }
          else {
            v2->set_value<Rstats::Integer>(i, 0);
          }
        }
        sv_x_out = Rstats::Func::new_vector<Rstats::Logical>(sv_r, v2);
      }
      else if (strEQ(type, "double")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Logical>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          if (v1->exists_na_position(i)) {
            v2->set_value<Rstats::Integer>(i, 1);
          }
          else {
            v2->set_value<Rstats::Integer>(i, 0);
          }
        }
        sv_x_out = Rstats::Func::new_vector<Rstats::Logical>(sv_r, v2);
      }
      else if (strEQ(type, "integer")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Logical>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          if (v1->exists_na_position(i)) {
            v2->set_value<Rstats::Integer>(i, 1);
          }
          else {
            v2->set_value<Rstats::Integer>(i, 0);
          }
        }
        sv_x_out = Rstats::Func::new_vector<Rstats::Logical>(sv_r, v2);
      }
      else if (strEQ(type, "logical")) {
        Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Logical>(v1->get_length());
        for (Rstats::Integer i = 0; i < v1->get_length(); i++) {
          if (v1->exists_na_position(i)) {
            v2->set_value<Rstats::Integer>(i, 1);
          }
          else {
            v2->set_value<Rstats::Integer>(i, 0);
          }
        }
        sv_x_out = Rstats::Func::new_vector<Rstats::Logical>(sv_r, v2);
      }
      else if (strEQ(type, "NULL")) {
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Logical>(0, 0);
        sv_x_out = Rstats::Func::new_vector<Rstats::Logical>(sv_r, v2);
        warn("Warning message:\nIn is->na(NULL) : is->na() applied to non-(list or vector) of type 'NULL'\n");
      }
      else if (strEQ(type, "list")) {
        sv_x_out = Rstats::Func::new_FALSE(sv_r);
      }
      else {
        croak("Error in is->na() : default method not implemented for type '%s'", type);
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* Class(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      // Set class
      sv_x2 = Rstats::Func::to_object(sv_r, sv_x2);
      Rstats::pl_hv_store(sv_x1, "class", Rstats::Func::as_vector(sv_r, sv_x2));
      
      return sv_x1;
    }

    SV* Class(SV* sv_r, SV* sv_x1) {
      
      // Get class
      SV* sv_x_class;
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      if (Rstats::pl_hv_exists(sv_x1, "class")) {
        sv_x_class = Rstats::Func::as_vector(sv_r, Rstats::pl_hv_fetch(sv_x1, "class"));
      }
      else {
        char* class_name;
        if (strEQ(type, "NULL")) {
          class_name = "NULL";
        }
        else if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_vector(sv_r, sv_x1))) {
          if (strEQ(type, "double") || strEQ(type, "integer")) {
            class_name = "numeric";
          }
          else {
            class_name = type; 
          }
        }
        else if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_matrix(sv_r, sv_x1))) {
          class_name = "matrix";
        }
        else if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_array(sv_r, sv_x1))) {
          class_name = "array";
        }
        else if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_data_frame(sv_r, sv_x1))) {
          class_name = "data.frame";
        }
        else if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_list(sv_r, sv_x1))) {
          class_name = "list";
        }
        else {
          croak("Error in class() : Invalid class");
        }
        Rstats::Vector* v_class = Rstats::VectorFunc::new_vector<Rstats::Character>(1, Rstats::pl_new_sv_pv(class_name));
        sv_x_class = Rstats::Func::new_vector<Rstats::Character>(sv_r, v_class);
      }
      
      return sv_x_class;
    }

    SV* is_factor(SV* sv_r, SV* sv_x1) {
      
      SV* sv_classes = Rstats::Func::Class(sv_r, sv_x1);
      Rstats::Vector* v_classes = Rstats::Func::get_vector(sv_r, sv_classes);
      Rstats::Integer v_classes_length = Rstats::Func::get_length(sv_r, sv_classes);
      
      Rstats::Logical match = 0;
      for (Rstats::Integer i = 0; i < v_classes_length; i++) {
        SV* sv_class = v_classes->get_value<Rstats::Character>(i);
        if (strEQ(SvPV_nolen(sv_class), "factor")) {
          match = 1;
          break;
        }
      }
      
      return match ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
    }

    SV* is_ordered(SV* sv_r, SV* sv_x1) {
      
      SV* sv_classes = Rstats::Func::Class(sv_r, sv_x1);
      Rstats::Vector* v_classes = Rstats::Func::get_vector(sv_r, sv_classes);
      Rstats::Integer v_classes_length = Rstats::Func::get_length(sv_r, sv_classes);
      
      Rstats::Logical match = 0;
      for (Rstats::Integer i = 0; i < v_classes_length; i++) {
        SV* sv_class = v_classes->get_value<Rstats::Character>(i);
        if (strEQ(SvPV_nolen(sv_class), "ordered")) {
          match = 1;
          break;
        }
      }
      
      return match ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
    }

    SV* clone(SV* sv_r, SV* sv_x1) {
      
      SV* sv_x_out = Rstats::Func::as_vector(sv_r, sv_x1);
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* dim_as_array(SV* sv_r, SV* sv_x1) {
      
      if (Rstats::pl_hv_exists(sv_x1, "dim")) {
        return Rstats::Func::dim(sv_r, sv_x1);
      }
      else {
        Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
        Rstats::Vector* v2 = Rstats::VectorFunc::new_vector<Rstats::Double>(1, length);
        SV* sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r, v2);
        return sv_x_out;
      }
    }

    SV* decompose(SV* sv_r, SV* sv_x1) {
      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      
      SV* sv_decomposed_xs = Rstats::pl_new_avrv();
      
      Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
      
      if (length > 0) {
        av_extend(Rstats::pl_av_deref(sv_decomposed_xs), length);

        if (strEQ(Rstats::Func::get_type(sv_r, sv_x1), "character")) {
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::Vector* v2
              = Rstats::VectorFunc::new_vector<Rstats::Character>(1, v1->get_value<Rstats::Character>(i));
            if (v1->exists_na_position(i)) {
              v2->add_na_position(0);
            }
            SV* sv_x_out = Rstats::Func::new_vector<Rstats::Character>(sv_r);
            Rstats::Func::set_vector(sv_r, sv_x_out, v2);
            Rstats::pl_av_push(sv_decomposed_xs, sv_x_out);
          }
        }
        else if (strEQ(Rstats::Func::get_type(sv_r, sv_x1), "complex")) {
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::Vector* v2
              = Rstats::VectorFunc::new_vector<Rstats::Complex>(1, v1->get_value<Rstats::Complex>(i));
            if (v1->exists_na_position(i)) {
              v2->add_na_position(0);
            }
            SV* sv_x_out = Rstats::Func::new_vector<Rstats::Complex>(sv_r);
            Rstats::Func::set_vector(sv_r, sv_x_out, v2);
            Rstats::pl_av_push(sv_decomposed_xs, sv_x_out);
          }
        }
        else if (strEQ(Rstats::Func::get_type(sv_r, sv_x1), "double")) {
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::Vector* v2
              = Rstats::VectorFunc::new_vector<Rstats::Double>(1, v1->get_value<Rstats::Double>(i));
            if (v1->exists_na_position(i)) {
              v2->add_na_position(0);
            }
            SV* sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r);
            Rstats::Func::set_vector(sv_r, sv_x_out, v2);
            Rstats::pl_av_push(sv_decomposed_xs, sv_x_out);
          }
        }
        else if (strEQ(Rstats::Func::get_type(sv_r, sv_x1), "integer")) {
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::Vector* v2
              = Rstats::VectorFunc::new_vector<Rstats::Integer>(1, v1->get_value<Rstats::Integer>(i));
            if (v1->exists_na_position(i)) {
              v2->add_na_position(0);
            }
            SV* sv_x_out = Rstats::Func::new_vector<Rstats::Integer>(sv_r);
            Rstats::Func::set_vector(sv_r, sv_x_out, v2);
            Rstats::pl_av_push(sv_decomposed_xs, sv_x_out);
          }
        }
        else if (strEQ(Rstats::Func::get_type(sv_r, sv_x1), "logical")) {
          for (Rstats::Integer i = 0; i < length; i++) {
            Rstats::Vector* v2
              = Rstats::VectorFunc::new_vector<Rstats::Logical>(1, v1->get_value<Rstats::Integer>(i));
            if (v1->exists_na_position(i)) {
              v2->add_na_position(0);
            }
            SV* sv_x_out = Rstats::Func::new_vector<Rstats::Logical>(sv_r);
            Rstats::Func::set_vector(sv_r, sv_x_out, v2);
            Rstats::pl_av_push(sv_decomposed_xs, sv_x_out);
          }
        }
      }
      
      return sv_decomposed_xs;
    }

    SV* compose(SV* sv_r, SV* sv_type, SV* sv_elements)
    {
      Rstats::Integer len = Rstats::pl_av_len(sv_elements);
      
      Rstats::Vector* compose_elements;
      std::vector<Rstats::Integer> na_positions;
      char* type = SvPV_nolen(sv_type);
      SV* sv_x_out;
      if (strEQ(type, "character")) {
        sv_x_out = Rstats::Func::new_vector<Rstats::Character>(sv_r);
        compose_elements = Rstats::VectorFunc::new_vector<Rstats::Character>(len);
        for (Rstats::Integer i = 0; i < len; i++) {
          SV* sv_x1 = Rstats::pl_av_fetch(sv_elements, i);
          if (!SvOK(sv_x1)) {
            sv_x1 = Rstats::Func::new_NA(sv_r);
          }
          Rstats::Vector* element = Rstats::Func::get_vector(sv_r, sv_x1);
          
          if (element->exists_na_position(0)) {
            na_positions.push_back(i);
          }
          else {
            compose_elements->set_value<Rstats::Character>(i, element->get_value<Rstats::Character>(0));
          }
        }
        for (Rstats::Integer i = 0; i < na_positions.size(); i++) {
          compose_elements->add_na_position(na_positions[i]);
        }
        Rstats::Func::set_vector(sv_r, sv_x_out, compose_elements);
      }
      else if (strEQ(type, "complex")) {
        sv_x_out = Rstats::Func::new_vector<Rstats::Complex>(sv_r);
        compose_elements = Rstats::VectorFunc::new_vector<Rstats::Complex>(len);
        for (Rstats::Integer i = 0; i < len; i++) {
          SV* sv_x1 = Rstats::pl_av_fetch(sv_elements, i);
          if (!SvOK(sv_x1)) {
            sv_x1 = Rstats::Func::new_NA(sv_r);
          }
          Rstats::Vector* element = Rstats::Func::get_vector(sv_r, sv_x1);

          if (element->exists_na_position(0)) {
            na_positions.push_back(i);
          }
          else {
           compose_elements->set_value<Rstats::Complex>(i, element->get_value<Rstats::Complex>(0));
          }
        }
        for (Rstats::Integer i = 0; i < na_positions.size(); i++) {
          compose_elements->add_na_position(na_positions[i]);
        }
        Rstats::Func::set_vector(sv_r, sv_x_out, compose_elements);
      }
      else if (strEQ(type, "double")) {
        
        sv_x_out = Rstats::Func::new_vector<Rstats::Double>(sv_r);
        compose_elements = Rstats::VectorFunc::new_vector<Rstats::Double>(len);
        for (Rstats::Integer i = 0; i < len; i++) {
          SV* sv_x1 = Rstats::pl_av_fetch(sv_elements, i);
          if (!SvOK(sv_x1)) {
            sv_x1 = Rstats::Func::new_NA(sv_r);
          }
          Rstats::Vector* element = Rstats::Func::get_vector(sv_r, sv_x1);

          if (element->exists_na_position(0)) {
            na_positions.push_back(i);
          }
          else {
            compose_elements->set_value<Rstats::Double>(i, element->get_value<Rstats::Double>(0));
          }
        }
        for (Rstats::Integer i = 0; i < na_positions.size(); i++) {
          compose_elements->add_na_position(na_positions[i]);
        }
        Rstats::Func::set_vector(sv_r, sv_x_out, compose_elements);
      }
      else if (strEQ(type, "integer")) {
        sv_x_out = Rstats::Func::new_vector<Rstats::Integer>(sv_r);
        compose_elements = Rstats::VectorFunc::new_vector<Rstats::Integer>(len);
        std::vector<Rstats::Integer>* values = compose_elements->get_values<Rstats::Integer>();
        for (Rstats::Integer i = 0; i < len; i++) {
          SV* sv_x1 = Rstats::pl_av_fetch(sv_elements, i);
          if (!SvOK(sv_x1)) {
            sv_x1 = Rstats::Func::new_NA(sv_r);
          }
          Rstats::Vector* element = Rstats::Func::get_vector(sv_r, sv_x1);

          if (element->exists_na_position(0)) {
            na_positions.push_back(i);
          }
          else {
            compose_elements->set_value<Rstats::Integer>(i, element->get_value<Rstats::Integer>(0));
          }
        }
        for (Rstats::Integer i = 0; i < na_positions.size(); i++) {
          compose_elements->add_na_position(na_positions[i]);
        }
        Rstats::Func::set_vector(sv_r, sv_x_out, compose_elements);
      }
      else if (strEQ(type, "logical")) {
        sv_x_out = Rstats::Func::new_vector<Rstats::Logical>(sv_r);
        compose_elements = Rstats::VectorFunc::new_vector<Rstats::Logical>(len);
        std::vector<Rstats::Logical>* values = compose_elements->get_values<Rstats::Logical>();
        for (Rstats::Integer i = 0; i < len; i++) {
          SV* sv_x1 = Rstats::pl_av_fetch(sv_elements, i);
          if (!SvOK(sv_x1)) {
            sv_x1 = Rstats::Func::new_NA(sv_r);
          }
          Rstats::Vector* element = Rstats::Func::get_vector(sv_r, sv_x1);

          if (element->exists_na_position(0)) {
            na_positions.push_back(i);
          }
          else {
            compose_elements->set_value<Rstats::Logical>(i, element->get_value<Rstats::Logical>(0));
          }
        }
        
        for (Rstats::Integer i = 0; i < na_positions.size(); i++) {
          compose_elements->add_na_position(na_positions[i]);
        }
        Rstats::Func::set_vector(sv_r, sv_x_out, compose_elements);
      }
      else if (strEQ(type, "NULL")) {
        // Nothing to do
      }
      else {
        croak("Unknown type(Rstats::Func::compose)");
      }
      
      return sv_x_out;
    }

    SV* args_h(SV* sv_r, SV* sv_names, SV* sv_args) {
      
      Rstats::Integer args_length = Rstats::pl_av_len(sv_args);
      SV* sv_opt;
      SV* sv_arg_last = Rstats::pl_av_fetch(sv_args, args_length - 1);
      if (!sv_isobject(sv_arg_last) && sv_derived_from(sv_arg_last, "HASH")) {
        sv_opt = Rstats::pl_av_pop(sv_args);
      }
      else {
        sv_opt = Rstats::pl_new_hvrv();
      }
      
      SV* sv_new_opt = Rstats::pl_new_hvrv();
      Rstats::Integer names_length = Rstats::pl_av_len(sv_names);
      for (Rstats::Integer i = 0; i < names_length; i++) {
        SV* sv_name = Rstats::pl_av_fetch(sv_names, i);
        if (Rstats::pl_hv_exists(sv_opt, SvPV_nolen(sv_name))) {
          Rstats::pl_hv_store(
            sv_new_opt,
            SvPV_nolen(sv_name),
            Rstats::Func::to_object(sv_r, Rstats::pl_hv_delete(sv_opt, SvPV_nolen(sv_name)))
          );
        }
        else if (i < names_length) {
          SV* sv_name = Rstats::pl_av_fetch(sv_names, i);
          SV* sv_arg = Rstats::pl_av_fetch(sv_args, i);
          if (SvOK(sv_arg)) {
            Rstats::pl_hv_store(
              sv_new_opt,
              SvPV_nolen(sv_name),
              Rstats::Func::to_object(sv_r, sv_arg)
            );
          }
        }
      }

      return sv_new_opt;
    }
    
    SV* as_array(SV* sv_r, SV* sv_x1) {
      
      SV* sv_x_out = Rstats::Func::as_vector(sv_r, sv_x1);
      SV* sv_x_out_dim = Rstats::Func::dim_as_array(sv_r, sv_x1);
      
      return Rstats::Func::array(sv_r, sv_x_out, sv_x_out_dim);
    }

    SV* levels(SV* sv_r, SV* sv_x1, SV* sv_x_class) {
      
      sv_x_class = Rstats::Func::to_object(sv_r, sv_x_class);
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
        sv_x_levels = Rstats::Func::new_NULL(sv_r);
      }
      
      return sv_x_levels;
    }

    SV* mode(SV* sv_r, SV* sv_x1, SV* sv_x_type) {
      
      sv_x_type = Rstats::Func::to_object(sv_r, sv_x_type);
      
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
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      char* mode;
      if (strEQ(type, "NULL")) {
        mode = "NULL";
      }
      else if (strEQ(type, "integer") || strEQ(type, "double")) {
        mode = "numeric";
      }
      else {
        mode = type;
      }
      
      Rstats::Vector* v_mode = Rstats::VectorFunc::new_vector<Rstats::Character>(1, Rstats::pl_new_sv_pv(mode));
      
      SV* sv_mode = Rstats::Func::new_vector<Rstats::Character>(sv_r, v_mode);
      
      return sv_mode;
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

    SV* names(SV* sv_r, SV* sv_x1, SV* sv_x_names) {
      sv_x_names = Rstats::Func::to_object(sv_r, sv_x_names);
      
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
        sv_x_names = Rstats::Func::new_NULL(sv_r);
      }
      return sv_x_names;
    }
  }
}
