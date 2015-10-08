#include "Rstats.h"

// Rstats::Func
namespace Rstats {
  namespace Func {

    SV* sin(SV* sv_r, SV* sv_x1) {

      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      SV* sv_x2 = Rstats::Func::operate_unary(sv_r, &Rstats::VectorFunc::sin, sv_x1);
      
      return sv_x2;
    }

    SV* operate_unary(SV* sv_r, Rstats::Vector* (*func)(Rstats::Vector*), SV* sv_x1) {
      
      Rstats::Vector* x2_elements = (*func)(get_vector(sv_r, sv_x1));
      SV* sv_x2 = Rstats::Func::new_null(sv_r);
      set_vector(sv_r, sv_x2, x2_elements);
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);
      
      return sv_x2;
    }
    
    SV* atan2(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);
      
      SV* sv_x3 = Rstats::Func::operate_binary(sv_r, &Rstats::VectorFunc::atan2, sv_x1, sv_x2);
      
      return sv_x3;
    }

    SV* operate_binary(SV* sv_r, Rstats::Vector* (*func)(Rstats::Vector*, Rstats::Vector*), SV* sv_x1, SV* sv_x2) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      sv_x2 = Rstats::Func::to_c(sv_r, sv_x2);

      
      // Upgrade mode if type is different
      SV* upgrade_type_args = Rstats::pl_new_av_ref();
      Rstats::pl_av_push(upgrade_type_args, sv_x1);
      Rstats::pl_av_push(upgrade_type_args, sv_x2);
      
      SV* upgrade_type_result = Rstats::Func::upgrade_type(sv_r, upgrade_type_args);
      
      if (Rstats::VectorFunc::get_type(Rstats::Func::get_vector(sv_r, sv_x1))
        != Rstats::VectorFunc::get_type(Rstats::Func::get_vector(sv_r, sv_x2)))
      {
        sv_x1 = Rstats::pl_av_fetch(upgrade_type_result, 0);
        sv_x2 = Rstats::pl_av_fetch(upgrade_type_result, 1);
      }
      
      // Upgrade length if length is defferent
      SV* sv_x1_length = Rstats::Func::length_value(sv_r, sv_x1);
      SV* sv_x2_length = Rstats::Func::length_value(sv_r, sv_x2);
      SV* sv_length;
      if (SvIV(sv_x1_length) > SvIV(sv_x2_length)) {
        sv_x2 = Rstats::Func::array(sv_r, sv_x2, Rstats::Func::c(sv_r, sv_x1_length));
      }
      else if (SvIV(sv_x1_length) < SvIV(sv_x2_length)) {
        sv_x1 = Rstats::Func::array(sv_r, sv_x1, Rstats::Func::c(sv_r, sv_x2_length));
      }

      Rstats::Vector* x3_elements
        = (*func)(Rstats::Func::get_vector(sv_r, sv_x1), Rstats::Func::get_vector(sv_r, sv_x2));
      
      SV* sv_x3 = Rstats::Func::new_null(sv_r);
      Rstats::Func::set_vector(sv_r, sv_x3, x3_elements);
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x3);
      
      return sv_x3;
    }

    SV* c(SV* sv_r, SV* sv_elements) {
      
      if (SvOK(sv_elements) && !SvROK(sv_elements)) {
        SV* sv_elements_tmp = sv_elements;
        sv_elements = Rstats::pl_new_av_ref();
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
          length += Rstats::VectorFunc::get_length(Rstats::Func::get_vector(sv_r, sv_element));
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

      // Decide type
      Rstats::Vector* v2;
      if (type_h[Rstats::Type::CHARACTER]) {
        v2 = Rstats::VectorFunc::new_character(length);
      }
      else if (type_h[Rstats::Type::COMPLEX]) {
        v2 = Rstats::VectorFunc::new_complex(length);
      }
      else if (type_h[Rstats::Type::DOUBLE]) {
        v2 = Rstats::VectorFunc::new_double(length);
      }
      else if (type_h[Rstats::Type::INTEGER]) {
        v2 = Rstats::VectorFunc::new_integer(length);
      }
      else {
        v2 = Rstats::VectorFunc::new_logical(length);
      }
      
      Rstats::Type::Enum type = Rstats::VectorFunc::get_type(v2);
      
      IV pos = 0;
      for (IV i = 0; i < element_length; i++) {
        SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);
        if (to_bool(sv_r, Rstats::Func::is_vector(sv_r, sv_element)) || to_bool(sv_r, Rstats::Func::is_array(sv_r, sv_element))) {
          
          Rstats::Vector* v1;
          if (to_bool(sv_r, Rstats::Func::is_vector(sv_r, sv_element)) || to_bool(sv_r, Rstats::Func::is_array(sv_r, sv_element))) {
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
            if (type == Rstats::Type::CHARACTER) {
              v_tmp = Rstats::VectorFunc::as_character(v1);
            }
            else if (type == Rstats::Type::COMPLEX) {
              v_tmp = Rstats::VectorFunc::as_complex(v1);
            }
            else if (type == Rstats::Type::DOUBLE) {
              v_tmp = Rstats::VectorFunc::as_double(v1);
            }
            else if (type == Rstats::Type::INTEGER) {
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
              if (type == Rstats::Type::CHARACTER) {
                Rstats::VectorFunc::set_character_value(v2, pos, Rstats::VectorFunc::get_character_value(v_tmp, k));
              }
              else if (type == Rstats::Type::COMPLEX) {
                Rstats::VectorFunc::set_complex_value(v2, pos, Rstats::VectorFunc::get_complex_value(v_tmp, k));
              }
              else if (type == Rstats::Type::DOUBLE) {
                Rstats::VectorFunc::set_double_value(v2, pos, Rstats::VectorFunc::get_value<Rstats::Double>(v_tmp, k));
              }
              else if (type == Rstats::Type::INTEGER) {
                Rstats::VectorFunc::set_integer_value(v2, pos, Rstats::VectorFunc::get_value<Rstats::Integer>(v_tmp, k));
              }
              else {
                Rstats::VectorFunc::set_integer_value(v2, pos, Rstats::VectorFunc::get_value<Rstats::Integer>(v_tmp, k));
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
            if (type == Rstats::Type::CHARACTER) {
              Rstats::VectorFunc::set_character_value(v2, pos, sv_element);
            }
            else if (type == Rstats::Type::COMPLEX) {
              Rstats::VectorFunc::set_complex_value(v2, pos, std::complex<NV>(SvNV(sv_element), 0));
            }
            else if (type == Rstats::Type::DOUBLE) {
              Rstats::VectorFunc::set_double_value(v2, pos, SvNV(sv_element));
            }
            else if (type == Rstats::Type::INTEGER) {
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
    
    SV* array(SV* sv_r, SV* sv_x1) {
      SV* sv_args_h = Rstats::pl_new_hv_ref();
      Rstats::pl_hv_store(sv_args_h, "x", sv_x1);
      return Rstats::Func::array_with_opt(sv_r, sv_args_h);
    }
    
    SV* array(SV* sv_r, SV* sv_x1, SV* sv_dim) {
      
      SV* sv_args_h = Rstats::pl_new_hv_ref();
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
        sv_x_dim = Rstats::Func::new_integer(sv_r, sv_x1_length);
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
        sv_elements = Rstats::pl_new_av_ref();
        for (IV i = 0; i < dim_product; i++) {
          Rstats::pl_av_push(sv_elements, Rstats::pl_av_fetch(sv_elements_tmp, i));
        }
      }
      else if (SvIV(sv_x1_length) < dim_product) {
        SV* sv_elements_tmp = Rstats::Func::decompose(sv_r, sv_x1);
        IV elements_tmp_length = Rstats::pl_av_len(sv_elements_tmp);
        IV repeat_count = (IV)(dim_product / elements_tmp_length) + 1;
        SV* sv_elements_tmp2 = Rstats::pl_new_av_ref();
        IV elements_tmp2_length = Rstats::pl_av_len(sv_elements_tmp2);
        for (IV i = 0; i < repeat_count; i++) {
          for (IV k = 0; k < elements_tmp_length; k++) {
            Rstats::pl_av_push(sv_elements_tmp2, Rstats::pl_av_fetch(sv_elements_tmp, k));
          }
        }
        sv_elements = Rstats::pl_new_av_ref();
        for (IV i = 0; i < dim_product; i++) {
          Rstats::pl_av_push(sv_elements, Rstats::pl_av_fetch(sv_elements_tmp2, i));
        }
      }
      
      SV* sv_x2 = Rstats::Func::c(sv_r, sv_elements);
      Rstats::Func::dim(sv_r, sv_x2, sv_x_dim);
      
      return sv_x2;
    }
    
    SV* upgrade_type(SV* sv_r, SV* sv_xs) {
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
          croak("Invalid type(Rstats::Func::upgrade_type()");
        }
      }

      // Upgrade elements and type if type is different
      SV* sv_new_xs = Rstats::pl_new_av_ref();;
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
    
    SV* is_matrix(SV* sv_r, SV* sv_x1) {

      bool is = sv_isobject(sv_x1)
        && sv_derived_from(sv_x1, "Rstats::Object")
        && SvIV(length_value(sv_r, dim(sv_r, sv_x1))) == 2;
      
      SV* sv_is = is ? Rstats::Func::new_true(sv_r) : Rstats::Func::new_false(sv_r);
      
      return sv_is;
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
      Rstats::Vector* v1 = get_vector(sv_r, sv_x1);
      
      SV* sv_values = Rstats::VectorFunc::create_sv_values(v1);
      
      return sv_values;
    }

    SV* length_value(SV* sv_r, SV* sv_x1) {
      SV* sv_length;

      Rstats::pl_hv_exists(sv_x1, "vector");
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

    SV* is_vector (SV* sv_r, SV* sv_x1) {
      
      bool is =
        sv_isobject(sv_x1)
        && sv_derived_from(sv_x1, "Rstats::Object")
        && strEQ(SvPV_nolen(Rstats::pl_hv_fetch(sv_x1, "object_type")), "array")
        && !Rstats::pl_hv_exists(sv_x1, "dim");
      
      SV* sv_is = is ? Rstats::pl_new_sv_iv(1) : Rstats::pl_new_sv_iv(0);
      
      SV* sv_values = Rstats::pl_new_av_ref();
      Rstats::pl_av_push(sv_values, sv_is);
      
      return Rstats::Func::new_logical(sv_r, sv_values);
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

    SV* is_array(SV* sv_r, SV* sv_x1) {

      bool is = sv_isobject(sv_x1)
        && sv_derived_from(sv_x1, "Rstats::Object")
        && strEQ(SvPV_nolen(Rstats::pl_hv_fetch(sv_x1, "object_type")), "array")
        && Rstats::pl_hv_exists(sv_x1, "dim");
      
      SV* sv_is = is ? Rstats::Func::new_true(sv_r) : Rstats::Func::new_false(sv_r);
      
      return sv_is;
    }

    SV* pi (SV* sv_r) {
      SV* sv_values = Rstats::pl_new_av_ref();
      NV pi = Rstats::Util::pi();
      SV* sv_pi = Rstats::pl_new_sv_nv(pi);
      Rstats::pl_av_push(sv_values, sv_pi);
      
      return new_double(sv_r, sv_values);
    }

    SV* new_array(SV* sv_r) {
      
      SV* sv_array = Rstats::pl_new_hv_ref();
      sv_bless(sv_array, gv_stashpv("Rstats::Object", 1));
      Rstats::pl_hv_store(sv_array, "r", sv_r);
      Rstats::pl_hv_store(sv_array, "object_type", Rstats::pl_new_sv_pv("array"));
      
      return sv_array;
    }

    SV* new_character(SV* sv_r, SV* sv_values) {
      SV* sv_x1 = new_null(sv_r);
      
      if (!sv_derived_from(sv_values, "ARRAY")) {
        SV* sv_values_av_ref = Rstats::pl_new_av_ref();
        Rstats::pl_av_push(sv_values_av_ref, sv_values);
        sv_values = sv_values_av_ref;
      }
      
      IV length = Rstats::pl_av_len(sv_values);
      
      Rstats::Vector* v1 = Rstats::VectorFunc::new_character(length);
      for (IV i = 0; i < length; i++) {
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

    SV* new_double(SV* sv_r, SV* sv_values) {
      SV* sv_x1 = new_null(sv_r);
      
      if (!sv_derived_from(sv_values, "ARRAY")) {
        SV* sv_values_av_ref = Rstats::pl_new_av_ref();
        Rstats::pl_av_push(sv_values_av_ref, sv_values);
        sv_values = sv_values_av_ref;
      }
      
      IV length = Rstats::pl_av_len(sv_values);
      
      Rstats::Vector* v1 = Rstats::VectorFunc::new_double(length);
      for (IV i = 0; i < length; i++) {
        SV* sv_value = Rstats::pl_av_fetch(sv_values, i);

        if (SvOK(sv_value)) {
          char* sv_value_str = SvPV_nolen(sv_value);
          if (strEQ(sv_value_str, "NaN")) {
            Rstats::VectorFunc::set_double_value(v1, i, NAN);
          }
          else if (strEQ(sv_value_str, "Inf")) {
            Rstats::VectorFunc::set_double_value(v1, i, INFINITY);
          }
          else if (strEQ(sv_value_str, "-Inf")) {
            Rstats::VectorFunc::set_double_value(v1, i, -(INFINITY));
          }
          else {
            NV value = SvNV(sv_value);
            Rstats::VectorFunc::set_double_value(v1, i, value);
          }
        }
        else {
          Rstats::VectorFunc::add_na_position(v1, i);
        }
      }
      
      set_vector(sv_r, sv_x1, v1);
      
      return sv_x1;
    }

    SV* new_complex(SV* sv_r, SV* sv_values) {
      SV* sv_x1 = new_null(sv_r);
      
      if (!sv_derived_from(sv_values, "ARRAY")) {
        SV* sv_values_av_ref = Rstats::pl_new_av_ref();
        Rstats::pl_av_push(sv_values_av_ref, sv_values);
        sv_values = sv_values_av_ref;
      }
      
      IV length = Rstats::pl_av_len(sv_values);
      
      Rstats::Vector* v1 = Rstats::VectorFunc::new_complex(length);
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

    SV* new_integer(SV* sv_r, SV* sv_values) {
      SV* sv_x1 = new_null(sv_r);
      
      if (!sv_derived_from(sv_values, "ARRAY")) {
        SV* sv_values_av_ref = Rstats::pl_new_av_ref();
        Rstats::pl_av_push(sv_values_av_ref, sv_values);
        sv_values = sv_values_av_ref;
      }
      
      IV length = Rstats::pl_av_len(sv_values);
      
      Rstats::Vector* v1 = Rstats::VectorFunc::new_integer(length);
      for (IV i = 0; i < length; i++) {
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

    SV* new_integer(SV* sv_r, IV value) {
      return Rstats::Func::new_integer(sv_r, Rstats::pl_new_sv_iv(value));
    }

    SV* new_logical(SV* sv_r, SV* sv_values) {
      SV* sv_x1 = new_null(sv_r);
      
      if (!sv_derived_from(sv_values, "ARRAY")) {
        SV* sv_values_av_ref = Rstats::pl_new_av_ref();
        Rstats::pl_av_push(sv_values_av_ref, sv_values);
        sv_values = sv_values_av_ref;
      }
      
      IV length = Rstats::pl_av_len(sv_values);
      
      Rstats::Vector* v1 = Rstats::VectorFunc::new_logical(length);
      for (IV i = 0; i < length; i++) {
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
      
      SV* sv_x1 = Rstats::Func::new_array(sv_r);;
      set_vector(sv_r, sv_x1, Rstats::VectorFunc::new_null());
      
      return sv_x1;
    }

    SV* new_na(SV* sv_r) {
      SV* sv_x1 = Rstats::Func::new_array(sv_r);;
      set_vector(sv_r, sv_x1, Rstats::VectorFunc::new_na());
      
      return sv_x1;
    }

    SV* new_nan(SV* sv_r) {
      SV* sv_x1 = Rstats::Func::new_array(sv_r);;
      set_vector(sv_r, sv_x1, Rstats::VectorFunc::new_nan());
      
      return sv_x1;
    }

    SV* new_inf(SV* sv_r) {
      SV* sv_x1 = Rstats::Func::new_array(sv_r);;
      set_vector(sv_r, sv_x1, Rstats::VectorFunc::new_inf());
      
      return sv_x1;
    }

    SV* new_false(SV* sv_r) {
      SV* sv_x1 = Rstats::Func::new_array(sv_r);;
      set_vector(sv_r, sv_x1, Rstats::VectorFunc::new_false());
      
      return sv_x1;
    }

    SV* new_true(SV* sv_r) {
      SV* sv_x1 = Rstats::Func::new_array(sv_r);;
      set_vector(sv_r, sv_x1, Rstats::VectorFunc::new_true());
      
      return sv_x1;
    }

    SV* to_c(SV* sv_r, SV* sv_x) {
      
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

    SV* is_numeric(SV* sv_r, SV* sv_x1) {
      
      bool is = (to_bool(sv_r, is_array(sv_r, sv_x1)) || to_bool(sv_r, is_vector(sv_r, sv_x1)))
        && (strEQ(SvPV_nolen(type(sv_r, sv_x1)), "double") || strEQ(SvPV_nolen(type(sv_r, sv_x1)), "integer"));
        
      SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
      
      return sv_x_is;
    }

    SV* is_double(SV* sv_r, SV* sv_x1) {
      
      bool is = (to_bool(sv_r, is_array(sv_r, sv_x1)) || to_bool(sv_r, is_vector(sv_r, sv_x1)))
        && strEQ(SvPV_nolen(type(sv_r, sv_x1)), "double");
        
      SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
      
      return sv_x_is;
    }

    SV* is_integer(SV* sv_r, SV* sv_x1) {
      
      bool is = (to_bool(sv_r, is_array(sv_r, sv_x1)) || to_bool(sv_r, is_vector(sv_r, sv_x1)))
        && strEQ(SvPV_nolen(type(sv_r, sv_x1)), "integer");
        
      SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
      
      return sv_x_is;
    }

    SV* is_complex(SV* sv_r, SV* sv_x1) {
      
      bool is = (to_bool(sv_r, is_array(sv_r, sv_x1)) || to_bool(sv_r, is_vector(sv_r, sv_x1)))
        && strEQ(SvPV_nolen(type(sv_r, sv_x1)), "complex");
        
      SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
      
      return sv_x_is;
    }

    SV* is_character(SV* sv_r, SV* sv_x1) {
      
      bool is = (to_bool(sv_r, is_array(sv_r, sv_x1)) || to_bool(sv_r, is_vector(sv_r, sv_x1)))
        && strEQ(SvPV_nolen(type(sv_r, sv_x1)), "character");
        
      SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
      
      return sv_x_is;
    }

    SV* is_logical(SV* sv_r, SV* sv_x1) {
      
      bool is = (to_bool(sv_r, is_array(sv_r, sv_x1)) || to_bool(sv_r, is_vector(sv_r, sv_x1)))
        && strEQ(SvPV_nolen(type(sv_r, sv_x1)), "logical");
        
      SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
      
      return sv_x_is;
    }

    SV* is_data_frame(SV* sv_r, SV* sv_x1) {
      
      bool is = sv_isobject(sv_x1)
        && sv_derived_from(sv_x1, "Rstats::Object")
        && strEQ(SvPV_nolen(Rstats::pl_hv_fetch(sv_x1, "object_type")), "data.frame");
        
      SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
      
      return sv_x_is;
    }

    SV* is_list(SV* sv_r, SV* sv_x1) {
      
      bool is = sv_isobject(sv_x1)
        && sv_derived_from(sv_x1, "Rstats::Object")
        && strEQ(SvPV_nolen(Rstats::pl_hv_fetch(sv_x1, "object_type")), "list");
        
      SV* sv_x_is = is ? new_true(sv_r) : new_false(sv_r);
      
      return sv_x_is;
    }

    SV* as_vector(SV* sv_r, SV* sv_x1) {
      
      SV* sv_v1 = Rstats::pl_hv_fetch(sv_x1, "vector");
      
      Rstats::Vector* v1 = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_v1);
      
      Rstats::Vector* v2 = Rstats::VectorFunc::clone(v1);
      
      SV* sv_v2 = Rstats::pl_to_perl_obj<Rstats::Vector*>(v2, "Rstats::Vector");
      
      SV* sv_x2 = Rstats::Func::new_null(sv_r);
      Rstats::pl_hv_store(sv_x2, "vector", sv_v2);
      
      return sv_x2;
    }

    SV* new_data_frame(SV* sv_r) {
      SV* sv_data_frame = Rstats::pl_new_hv_ref();
      Rstats::pl_sv_bless(sv_data_frame, "Rstats::Object");
      Rstats::pl_hv_store(sv_data_frame, "r", sv_r);
      Rstats::pl_hv_store(sv_data_frame, "object_type", Rstats::pl_new_sv_pv("data.frame"));
      
      return sv_data_frame;
    }

    SV* new_list(SV* sv_r) {
      SV* sv_list = Rstats::pl_new_hv_ref();
      Rstats::pl_sv_bless(sv_list, "Rstats::Object");
      Rstats::pl_hv_store(sv_list, "r", sv_r);
      Rstats::pl_hv_store(sv_list, "object_type", Rstats::pl_new_sv_pv("list"));
      
      return sv_list;
    }

    SV* new_vector(SV* sv_r, SV* sv_type, SV* sv_values) {
      
      char* type = SvPV_nolen(sv_type);
      
      if (strEQ(type, "character")) {
        return new_character(sv_r, sv_values);
      }
      else if (strEQ(type, "complex")) {
        return new_complex(sv_r, sv_values);
      }
      else if (strEQ(type, "double")) {
        return new_double(sv_r, sv_values);
      }
      else if (strEQ(type, "integer")) {
        return new_integer(sv_r, sv_values);
      }
      else if (strEQ(type, "logical")) {
        return new_logical(sv_r, sv_values);
      }
      else {
        croak("Invalid type %s is passed(new_vector)", type);
      }
    }

    SV* copy_attrs_to(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2, &PL_sv_undef);
    }

    SV* copy_attrs_to(SV* sv_r, SV* sv_x1, SV* sv_x2, SV* sv_opt) {
      
      if (!SvOK(sv_opt)) {
        sv_opt = Rstats::pl_new_hv_ref();
      }
      
      SV* sv_new_indexes = Rstats::pl_hv_fetch(sv_opt, "new_indexes");
      
      SV* sv_exclude = Rstats::pl_hv_fetch(sv_opt, "exclude");
      if (!SvOK(sv_exclude)) {
        sv_exclude = Rstats::pl_new_av_ref();
      }
      HV* hv_exclude_h = Rstats::pl_new_hv();
      for (IV i = 0; i < Rstats::pl_av_len(sv_exclude); i++) {
        SV* sv_exclude_element = Rstats::pl_av_fetch(sv_exclude, i);
        Rstats::pl_hv_store(hv_exclude_h, SvPV_nolen(sv_exclude_element), Rstats::pl_new_sv_iv(1));
      }
      // dim
      if (!SvOK(Rstats::pl_hv_fetch(hv_exclude_h, "dim")) && Rstats::pl_hv_exists(sv_x1, "dim")) {
        Rstats::pl_hv_store(sv_x2, "dim", Rstats::Func::as_vector(sv_r, Rstats::pl_hv_fetch(sv_x1, "dim")));
      }
      
      // class
      if (!SvOK(Rstats::pl_hv_fetch(hv_exclude_h, "class")) && Rstats::pl_hv_exists(sv_x1, "class")) {
        Rstats::pl_hv_store(sv_x2, "class", Rstats::Func::as_vector(sv_r, Rstats::pl_hv_fetch(sv_x1, "class")));
      }
      
      // levels
      if (!SvOK(Rstats::pl_hv_fetch(hv_exclude_h, "levels")) && Rstats::pl_hv_exists(sv_x1, "levels")) {
        Rstats::pl_hv_store(sv_x2, "levels", Rstats::Func::as_vector(sv_r, Rstats::pl_hv_fetch(sv_x1, "levels")));
      }
      
      // names
      if (!SvOK(Rstats::pl_hv_fetch(hv_exclude_h, "names")) && Rstats::pl_hv_exists(sv_x1, "names")) {
        SV* sv_x2_names_values = Rstats::pl_new_av_ref();
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
        Rstats::pl_hv_store(sv_x2, "names", Rstats::Func::new_character(sv_r, sv_x2_names_values));
      }
      
      
      // dimnames
      if (!SvOK(Rstats::pl_hv_fetch(hv_exclude_h, "dimnames")) && Rstats::pl_hv_exists(sv_x1, "dimnames")) {
        SV* sv_new_dimnames = Rstats::pl_new_av_ref();
        SV* sv_dimnames = Rstats::pl_hv_fetch(sv_x1, "dimnames");
        IV length = Rstats::pl_av_len(sv_dimnames);
        for (IV i = 0; i < length; i++) {
          SV* sv_dimname = Rstats::pl_av_fetch(sv_dimnames, i);;
          if (SvOK(sv_dimname) && SvIV(Rstats::Func::length_value(sv_r, sv_dimname)) > 0) {
            SV* sv_index = SvOK(sv_new_indexes) ? Rstats::pl_av_fetch(sv_new_indexes, i) : &PL_sv_undef;
            SV* sv_dimname_values = Rstats::Func::values(sv_r, sv_dimname);
            SV* sv_new_dimname_values = Rstats::pl_new_av_ref();
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
            Rstats::pl_av_push(sv_new_dimnames, Rstats::Func::new_character(sv_r, sv_new_dimname_values));
          }
        }
        Rstats::pl_hv_store(sv_x2, "dimnames", sv_new_dimnames);
      }
    }

    SV* as_integer(SV* sv_r, SV* sv_x1) {
      
      SV* sv_x2 = Rstats::Func::new_array(sv_r);
      Rstats::Func::set_vector(sv_r, sv_x2, Rstats::VectorFunc::as_integer(Rstats::Func::get_vector(sv_r, sv_x1)));
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);

      return sv_x2;
    }

    SV* as_logical(SV* sv_r, SV* sv_x1) {
      
      SV* sv_x2 = Rstats::Func::new_array(sv_r);
      Rstats::Func::set_vector(sv_r, sv_x2, Rstats::VectorFunc::as_logical(Rstats::Func::get_vector(sv_r, sv_x1)));
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);

      return sv_x2;
    }

    SV* as_complex(SV* sv_r, SV* sv_x1) {
      
      SV* sv_x2 = Rstats::Func::new_array(sv_r);
      Rstats::Func::set_vector(sv_r, sv_x2, Rstats::VectorFunc::as_complex(Rstats::Func::get_vector(sv_r, sv_x1)));
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);
      
      return sv_x2;
    }

    SV* as_double(SV* sv_r, SV* sv_x1) {
      
      SV* sv_x2 = Rstats::Func::new_array(sv_r);
      Rstats::Func::set_vector(sv_r, sv_x2, Rstats::VectorFunc::as_double(Rstats::Func::get_vector(sv_r, sv_x1)));
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);

      return sv_x2;
    }

    SV* as_numeric(SV* sv_r, SV* sv_x1) {
      
      SV* sv_x2 = Rstats::Func::new_array(sv_r);
      Rstats::Func::set_vector(sv_r, sv_x2, Rstats::VectorFunc::as_numeric(Rstats::Func::get_vector(sv_r, sv_x1)));
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);

      return sv_x2;
    }

    SV* is_finite(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      
      if (Rstats::pl_hv_exists(sv_x1, "vector")) {
        SV* sv_x2 = Rstats::Func::new_null(sv_r);
        Rstats::Func::set_vector(sv_r, sv_x2, Rstats::VectorFunc::is_finite(Rstats::Func::get_vector(sv_r, sv_x1)));
        Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);
        
        return sv_x2;
      }
      else {
        croak("Error : is_finite is not implemented except array");
      }
    }

    SV* is_infinite(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      
      if (Rstats::pl_hv_exists(sv_x1, "vector")) {
        SV* sv_x2 = Rstats::Func::new_null(sv_r);
        Rstats::Func::set_vector(sv_r, sv_x2, Rstats::VectorFunc::is_infinite(Rstats::Func::get_vector(sv_r, sv_x1)));
        Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);
        
        return sv_x2;
      }
      else {
        croak("Error : is_infinite is not implemented except array");
      }
    }

    SV* is_nan(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      
      if (Rstats::pl_hv_exists(sv_x1, "vector")) {
        SV* sv_x2 = Rstats::Func::new_null(sv_r);
        Rstats::Func::set_vector(sv_r, sv_x2, Rstats::VectorFunc::is_nan(Rstats::Func::get_vector(sv_r, sv_x1)));
        Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);
        
        return sv_x2;
      }
      else {
        croak("Error : is_nan is not implemented except array");
      }
    }

    SV* is_na(SV* sv_r, SV* sv_x1) {
      
      sv_x1 = Rstats::Func::to_c(sv_r, sv_x1);
      Rstats::Vector* x1 = Rstats::Func::get_vector(sv_r, sv_x1);
      IV x1_length = Rstats::VectorFunc::get_length(x1);
      Rstats::Vector* x2 = Rstats::VectorFunc::new_logical(x1_length);
      
      for (IV i = 0; i < Rstats::VectorFunc::get_length(x1); i++) {
        if (Rstats::VectorFunc::exists_na_position(x1, i)) {
          Rstats::VectorFunc::set_integer_value(x2, i, 1);
        }
        else {
          Rstats::VectorFunc::set_integer_value(x2, i, 0);
        }
      }
      
      SV* sv_x2 = Rstats::Func::new_null(sv_r);
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
      else if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_vector(sv_r, sv_x1))) {
        SV* sv_class_names = Rstats::pl_new_av_ref();
        SV* sv_class_name = Rstats::Func::type(sv_r, sv_x1);
        if (strEQ(SvPV_nolen(sv_class_name), "double") || strEQ(SvPV_nolen(sv_class_name), "integer")) {
          sv_class_name = Rstats::pl_new_sv_pv("numeric");
        }
        
        Rstats::pl_av_push(sv_class_names, sv_class_name);
        sv_x2 = Rstats::Func::new_character(sv_r, sv_class_names);
      }
      else if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_matrix(sv_r, sv_x1))) {
        SV* sv_class_names = Rstats::pl_new_av_ref();
        Rstats::pl_av_push(sv_class_names, Rstats::pl_new_sv_pv("matrix"));
        sv_x2 = Rstats::Func::new_character(sv_r, sv_class_names);
      }
      else if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_array(sv_r, sv_x1))) {
        SV* sv_class_names = Rstats::pl_new_av_ref();
        Rstats::pl_av_push(sv_class_names, Rstats::pl_new_sv_pv("array"));
        sv_x2 = Rstats::Func::new_character(sv_r, sv_class_names);
      }
      else if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_data_frame(sv_r, sv_x1))) {
        SV* sv_class_names = Rstats::pl_new_av_ref();
        Rstats::pl_av_push(sv_class_names, Rstats::pl_new_sv_pv("data.frame"));
        sv_x2 = Rstats::Func::new_character(sv_r, sv_class_names);
      }
      else if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_list(sv_r, sv_x1))) {
        SV* sv_class_names = Rstats::pl_new_av_ref();
        Rstats::pl_av_push(sv_class_names, Rstats::pl_new_sv_pv("list"));
        sv_x2 = Rstats::Func::new_character(sv_r, sv_class_names);
      }
      
      return sv_x2;
    }

    SV* is_factor(SV* sv_r, SV* sv_x1) {
      
      SV* sv_classes = Rstats::Func::Class(sv_r, sv_x1);
      Rstats::Vector* v_classes = Rstats::Func::get_vector(sv_r, sv_classes);
      IV v_classes_length = Rstats::VectorFunc::get_length(v_classes);
      
      IV match = 0;
      for (IV i = 0; i < v_classes_length; i++) {
        SV* sv_class = Rstats::VectorFunc::get_character_value(v_classes, i);
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
      IV v_classes_length = Rstats::VectorFunc::get_length(v_classes);
      
      IV match = 0;
      for (IV i = 0; i < v_classes_length; i++) {
        SV* sv_class = Rstats::VectorFunc::get_character_value(v_classes, i);
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
        return Rstats::Func::new_double(sv_r, sv_length);
      }
    }

    SV* decompose(SV* sv_r, SV* sv_x1) {
      SV* sv_v1 = Rstats::pl_hv_fetch(sv_x1, "vector");
      Rstats::Vector* v1 = Rstats::pl_to_c_obj<Rstats::Vector*>(sv_v1);
      
      SV* sv_decomposed_xs = Rstats::pl_new_av_ref();
      
      IV length = Rstats::VectorFunc::get_length(v1);
      
      if (length > 0) {
        av_extend(Rstats::pl_av_deref(sv_decomposed_xs), length);

        if (Rstats::VectorFunc::is_character(v1)) {
          for (IV i = 0; i < length; i++) {
            Rstats::Vector* v2
              = Rstats::VectorFunc::new_character(1, Rstats::VectorFunc::get_character_value(v1, i));
            if (Rstats::VectorFunc::exists_na_position(v1, i)) {
              Rstats::VectorFunc::add_na_position(v2, 0);
            }
            SV* sv_x2 = Rstats::Func::new_null(sv_r);
            Rstats::Func::set_vector(sv_r, sv_x2, v2);
            Rstats::pl_av_push(sv_decomposed_xs, sv_x2);
          }
        }
        else if (Rstats::VectorFunc::is_complex(v1)) {
          for (IV i = 0; i < length; i++) {
            Rstats::Vector* v2
              = Rstats::VectorFunc::new_complex(1, Rstats::VectorFunc::get_complex_value(v1, i));
            if (Rstats::VectorFunc::exists_na_position(v1, i)) {
              Rstats::VectorFunc::add_na_position(v2, 0);
            }
            SV* sv_x2 = Rstats::Func::new_null(sv_r);
            Rstats::Func::set_vector(sv_r, sv_x2, v2);
            Rstats::pl_av_push(sv_decomposed_xs, sv_x2);
          }
        }
        else if (Rstats::VectorFunc::is_double(v1)) {
          for (IV i = 0; i < length; i++) {
            Rstats::Vector* v2
              = Rstats::VectorFunc::new_double(1, Rstats::VectorFunc::get_value<Rstats::Double>(v1, i));
            if (Rstats::VectorFunc::exists_na_position(v1, i)) {
              Rstats::VectorFunc::add_na_position(v2, 0);
            }
            SV* sv_x2 = Rstats::Func::new_null(sv_r);
            Rstats::Func::set_vector(sv_r, sv_x2, v2);
            Rstats::pl_av_push(sv_decomposed_xs, sv_x2);
          }
        }
        else if (Rstats::VectorFunc::is_integer(v1)) {
          for (IV i = 0; i < length; i++) {
            Rstats::Vector* v2
              = Rstats::VectorFunc::new_integer(1, Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i));
            if (Rstats::VectorFunc::exists_na_position(v1, i)) {
              Rstats::VectorFunc::add_na_position(v2, 0);
            }
            SV* sv_x2 = Rstats::Func::new_null(sv_r);
            Rstats::Func::set_vector(sv_r, sv_x2, v2);
            Rstats::pl_av_push(sv_decomposed_xs, sv_x2);
          }
        }
        else if (Rstats::VectorFunc::is_logical(v1)) {
          for (IV i = 0; i < length; i++) {
            Rstats::Vector* v2
              = Rstats::VectorFunc::new_logical(1, Rstats::VectorFunc::get_value<Rstats::Integer>(v1, i));
            if (Rstats::VectorFunc::exists_na_position(v1, i)) {
              Rstats::VectorFunc::add_na_position(v2, 0);
            }
            SV* sv_x2 = Rstats::Func::new_null(sv_r);
            Rstats::Func::set_vector(sv_r, sv_x2, v2);
            Rstats::pl_av_push(sv_decomposed_xs, sv_x2);
          }
        }
      }
      
      return sv_decomposed_xs;
    }

    SV* compose(SV* sv_r, SV* sv_mode, SV* sv_elements)
    {
      IV len = Rstats::pl_av_len(sv_elements);
      
      Rstats::Vector* compose_elements;
      std::vector<IV> na_positions;
      char* mode = SvPV_nolen(sv_mode);
      if (strEQ(mode, "character")) {
        compose_elements = Rstats::VectorFunc::new_character(len);
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
            Rstats::VectorFunc::set_character_value(compose_elements, i, Rstats::VectorFunc::get_character_value(element, 0));
          }
        }
      }
      else if (strEQ(mode, "complex")) {
        compose_elements = Rstats::VectorFunc::new_complex(len);
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
           Rstats::VectorFunc::set_complex_value(compose_elements, i, Rstats::VectorFunc::get_complex_value(element, 0));
          }
        }
      }
      else if (strEQ(mode, "double")) {
        compose_elements = Rstats::VectorFunc::new_double(len);
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
            Rstats::VectorFunc::set_double_value(compose_elements, i, Rstats::VectorFunc::get_value<Rstats::Double>(element, 0));
          }
        }
      }
      else if (strEQ(mode, "integer")) {
        compose_elements = Rstats::VectorFunc::new_integer(len);
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
            Rstats::VectorFunc::set_integer_value(compose_elements, i, Rstats::VectorFunc::get_value<Rstats::Integer>(element, 0));
          }
        }
      }
      else if (strEQ(mode, "logical")) {
        compose_elements = Rstats::VectorFunc::new_logical(len);
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
            Rstats::VectorFunc::set_integer_value(compose_elements, i, Rstats::VectorFunc::get_value<Rstats::Integer>(element, 0));
          }
        }
      }
      else {
        croak("Unknown type(Rstats::Func::compose)");
      }
      
      for (IV i = 0; i < na_positions.size(); i++) {
        Rstats::VectorFunc::add_na_position(compose_elements, na_positions[i]);
      }
      
      SV* sv_x2 = Rstats::Func::new_null(sv_r);
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
        sv_opt = Rstats::pl_new_hv_ref();
      }
      
      SV* sv_new_opt = Rstats::pl_new_hv_ref();
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

      // SV* sv_key;
      // while ((sv_key = hv_iterkeysv(hv_iternext(Rstats::pl_hv_deref(sv_opt)))) != NULL) {
        // croak("unused argument (%s)", SvPV_nolen(sv_key));
      // }
      
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

    SV* as_character(SV* sv_r, SV* sv_x1) {
      
      SV* sv_x2;
      if (Rstats::Func::to_bool(sv_r, Rstats::Func::is_factor(sv_r, sv_x1))) {
        SV* sv_levels = Rstats::pl_new_hv_ref();
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
        SV* sv_x2_values = Rstats::pl_new_av_ref();
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
        sv_x2 = Rstats::Func::new_character(sv_r, sv_x2_values);
      }
      else {
        sv_x2 = Rstats::Func::new_array(sv_r);
        Rstats::Func::set_vector(
          sv_r,
          sv_x2,
          Rstats::VectorFunc::as_character(Rstats::Func::get_vector(sv_r, sv_x1))
        );
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2);
      
      return sv_x2;
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
      
      SV* sv_x1_tmp = Rstats::Func::as(sv_r, sv_type, sv_x1);
      Rstats::pl_hv_store(sv_x1, "vector", Rstats::pl_hv_fetch(sv_x1_tmp, "vector"));
      
      return sv_r;
    }
    
    SV* mode(SV* sv_r, SV* sv_x1) {
      
      SV* sv_type = Rstats::Func::type(sv_r, sv_x1);
      
      SV* sv_mode;
      if (strEQ(SvPV_nolen(sv_type), "integer") || strEQ(SvPV_nolen(sv_type), "double")) {
        sv_mode = Rstats::pl_new_sv_pv("numeric");
      }
      else {
        sv_mode = sv_type;
      }
      
      return Rstats::Func::new_character(sv_r, sv_mode);
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
      if (to_bool(sv_r, Rstats::Func::is_vector(sv_r, sv_container)) || to_bool(sv_r, Rstats::Func::is_array(sv_r, sv_container))) {
        return Rstats::Func::new_integer(
          sv_r,
          Rstats::VectorFunc::get_length(Rstats::Func::get_vector(sv_r, sv_container))
        );
      }
      else {
        return Rstats::Func::new_integer(sv_r, Rstats::Func::length_value(sv_r, sv_container));
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
      SV* sv_x_names = Rstats::Func::new_null(sv_r);
      if (Rstats::pl_hv_exists(sv_x1, "names")) {
        sv_x_names = Rstats::Func::as_vector(sv_r, Rstats::pl_hv_fetch(sv_x1, "names"));
      }
      return sv_x_names;
    }
  }
}
