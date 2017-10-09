#include "Rstats_Func.h"

// Rstats::Func
namespace Rstats {
  namespace Func {

    template <>
    void set_vector<double>(SV* sv_r, SV* sv_x1, Rstats::Vector<double>* v1) {
      SV* sv_vector = Rstats::pl_object_wrap<Rstats::Vector<double>*>(v1, "Rstats::Vector::Double");
      Rstats::pl_hv_store(sv_x1, "vector", sv_vector);
    }

    template <>
    void set_vector<int32_t>(SV* sv_r, SV* sv_x1, Rstats::Vector<int32_t>* v1) {
      SV* sv_vector = Rstats::pl_object_wrap<Rstats::Vector<int32_t>*>(v1, "Rstats::Vector::Integer");
      Rstats::pl_hv_store(sv_x1, "vector", sv_vector);
    }

    template <>
    Rstats::Vector<double>* get_vector<double>(SV* sv_r, SV* sv_x1) {
      SV* sv_vector = Rstats::pl_hv_fetch(sv_x1, "vector");
      
      if (SvOK(sv_vector)) {
        Rstats::Vector<double>* vector
          = Rstats::pl_object_unwrap<Rstats::Vector<double>*>(sv_vector, "Rstats::Vector::Double");
        return vector;
      }
      else {
        return NULL;
      }
    }

    template <>
    Rstats::Vector<int32_t>* get_vector<int32_t>(SV* sv_r, SV* sv_x1) {
      SV* sv_vector = Rstats::pl_hv_fetch(sv_x1, "vector");
      
      if (SvOK(sv_vector)) {
        Rstats::Vector<int32_t>* vector
          = Rstats::pl_object_unwrap<Rstats::Vector<int32_t>*>(sv_vector, "Rstats::Vector::Integer");
        return vector;
      }
      else {
        return NULL;
      }
    }
    
    SV* length(SV* sv_r, SV* x1) {
      int32_t x1_length = Rstats::Func::get_length(sv_r, x1);
      Rstats::Vector<int32_t>* v_out = new Rstats::Vector<int32_t>(1, x1_length);
      SV* sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      return sv_x_out;
    }

    SV* c(SV* sv_r, SV* sv_elements) {
      
      int32_t length = Rstats::pl_av_len(sv_elements);

      SV* sv_x_out;
      if (length == 0) {
        croak("Error");
      }

      SV* sv_new_elements = Rstats::pl_new_avrv();
      
      // Convert to Rstats::Object, check type and total length, and remove NULL
      SV* sv_type_h = Rstats::pl_new_hvrv();
      int32_t total_length = 0;
      for (int32_t i = 0; i < length; i++) {
        SV* sv_element = Rstats::pl_av_fetch(sv_elements, i);

        SV* sv_new_element;
        
        if (SvOK(sv_element)) {
          if (SvROK(sv_element)) {
            int32_t is_object = sv_isobject(sv_element) && sv_derived_from(sv_element, "Rstats::Object");
            if (is_object) {
              sv_new_element = sv_element;
            }
            else {
              croak("Can't receive reference value except Rstats::Object object");
            }
          }
          else {
            Rstats::Vector<double>* v_out = new Rstats::Vector<double>(1, SvNV(sv_element));
            sv_new_element = Rstats::Func::new_vector<double>(sv_r, v_out);
          }
        }
        else {
          sv_new_element = Rstats::Func::new_FALSE(sv_r);
        }
        
        char* type = Rstats::Func::get_type(sv_r, sv_new_element);
        
        total_length += Rstats::Func::get_length(sv_r, sv_new_element);
        Rstats::pl_hv_store(sv_type_h, type, Rstats::pl_new_sv_iv(1));
        Rstats::pl_av_push(sv_new_elements, sv_new_element);
      }

      // Decide type
      if (Rstats::pl_hv_exists(sv_type_h, "double")) {
        Rstats::Vector<double>* v_out = new Rstats::Vector<double>(total_length);
        int32_t pos = 0;
        for (int32_t i = 0; i < length; i++) {
          SV* sv_element = Rstats::pl_av_fetch(sv_new_elements, i);
          char* type = Rstats::Func::get_type(sv_r, sv_element);
          if (!strEQ(type, "double")) {
            sv_element = Rstats::Func::as_double(sv_r, sv_element);
          }
          Rstats::Vector<double>* v1 =  Rstats::Func::get_vector<double>(sv_r, sv_element);
          int32_t v1_length = v1->get_length();
          for (int32_t k = 0; k < v1_length; k++) {
            v_out->set_value(pos, v1->get_value(k));
            pos++;
          }
        }
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (Rstats::pl_hv_exists(sv_type_h, "int")) {
        Rstats::Vector<int32_t>* v_out = new Rstats::Vector<int32_t>(total_length);
        int32_t pos = 0;
        for (int32_t i = 0; i < length; i++) {
          SV* sv_element = Rstats::pl_av_fetch(sv_new_elements, i);
          char* type = Rstats::Func::get_type(sv_r, sv_element);
          if (!strEQ(type, "int")) {
            sv_element = Rstats::Func::as_int(sv_r, sv_element);
          }
          Rstats::Vector<int32_t>* v1 =  Rstats::Func::get_vector<int32_t>(sv_r, sv_element);
          int32_t v1_length = v1->get_length();
          for (int32_t k = 0; k < v1_length; k++) {
            v_out->set_value(pos, v1->get_value(k));
            pos++;
          }
        }
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      
      /*
      
      // Fix elements length
      SV* sv_dim = Rstats::pl_new_avrv();
      SV* sv_length = sv_2mortal(newSViv(length));
      Rstats::pl_av_push(sv_dim, sv_length));
      Rstats::Func::dim(sv_r, sv_x_out, sv_dim);
      
      */
      
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
        ? Rstats::pl_hv_fetch(sv_args_h, "dim") : &PL_sv_undef;
      int32_t x1_length = Rstats::Func::get_length(sv_r, sv_x1);
      
      if (!SvOK(sv_x_dim)) {
        Rstats::Vector<int32_t>* v_dim = new Rstats::Vector<int32_t>(1, x1_length);
        sv_x_dim = Rstats::Func::new_vector<int32_t>(sv_r, v_dim);
      }
      int32_t dim_product = 1;
      int32_t x_dim_length = Rstats::Func::get_length(sv_r, sv_x_dim);
      for (int32_t i = 0; i < x_dim_length; i++) {
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
        for (int32_t i = 0; i < dim_product; i++) {
          Rstats::pl_av_push(sv_elements, Rstats::pl_av_fetch(sv_elements_tmp, i));
        }
      }
      else if (x1_length < dim_product) {
        SV* sv_elements_tmp = Rstats::Func::decompose(sv_r, sv_x1);
        int32_t elements_tmp_length = Rstats::pl_av_len(sv_elements_tmp);
        int32_t repeat_count = (int32_t)(dim_product / elements_tmp_length) + 1;
        SV* sv_elements_tmp2 = Rstats::pl_new_avrv();
        int32_t elements_tmp2_length = Rstats::pl_av_len(sv_elements_tmp2);
        for (int32_t i = 0; i < repeat_count; i++) {
          for (int32_t k = 0; k < elements_tmp_length; k++) {
            Rstats::pl_av_push(sv_elements_tmp2, Rstats::pl_av_fetch(sv_elements_tmp, k));
          }
        }
        sv_elements = Rstats::pl_new_avrv();
        for (int32_t i = 0; i < dim_product; i++) {
          Rstats::pl_av_push(sv_elements, Rstats::pl_av_fetch(sv_elements_tmp2, i));
        }
      }
      
      SV* sv_x2 = Rstats::Func::c(sv_r, sv_elements);
      Rstats::Func::dim(sv_r, sv_x2, sv_x_dim);
      
      return sv_x2;
    }

    int32_t get_length (SV* sv_r, SV* sv_x1) {

      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        return v1->get_length();
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        return v1->get_length();
      }
      else {
        croak("Error in get_length() : default method not implemented for type '%s'", type);
      }
    }

    SV* as_double(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::as_double<double, double>(v1);
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::as_double<int32_t, double>(v1);
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in as->double() : default method not implemented for type '%s'", type);
      }

      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
        
    SV* as_int(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::as_int<double, int32_t>(v1);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::as_int<int32_t, int32_t>(v1);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Error in as->int() : default method not implemented for type '%s'", type);
      }

      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
    
    SV* create_sv_values(SV* sv_r, SV* sv_x1) {

      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      SV* sv_values = Rstats::pl_new_avrv();
      int32_t length = Rstats::Func::get_length(sv_r, sv_x1);
      for (int32_t i = 0; i < length; i++) {
        Rstats::pl_av_push(sv_values, Rstats::Func::create_sv_value(sv_r, sv_x1, i));
      }
      
      return sv_values;
    }
    
    SV* create_sv_value(SV* sv_r, SV* sv_x1, int32_t pos) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      SV* sv_value;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        double value = v1->get_value(pos);
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
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        int32_t value = v1->get_value(pos);
        sv_value = Rstats::pl_new_sv_iv(value);
      }
      else {
        croak("Error in create_sv_value : default method not implemented for type '%s'", type);
      }
      
      return sv_value;
    }
        
    SV* cumprod(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v_out = new Rstats::Vector<double>(v1->get_length());
        double v_out_total(1);
        for (int32_t i = 0; i < v1->get_length(); i++) {
          v_out_total *= v1->get_value(i);
          v_out->set_value(i, v_out_total);
        }
          
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<double>* v_out = new Rstats::Vector<double>(v1->get_length());
        double v_out_total(1);
        for (int32_t i = 0; i < v1->get_length(); i++) {
          v_out_total *= v1->get_value(i);
          v_out->set_value(i, v_out_total);
        }
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in cumprod() : non-double argument to cumprod()");
      }
      
      return sv_x_out;
    }
    
    SV* cumsum(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v_out = new Rstats::Vector<double>(v1->get_length());
        double v_out_total(0);
        for (int32_t i = 0; i < v1->get_length(); i++) {
          v_out_total += v1->get_value(i);
          v_out->set_value(i, v_out_total);
        }
          
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<double>* v_out = new Rstats::Vector<double>(v1->get_length());
        double v_out_total(0);
        for (int32_t i = 0; i < v1->get_length(); i++) {
          v_out_total += v1->get_value(i);
          v_out->set_value(i, v_out_total);
        }
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in cumsum() : non-double argument to cumsum()");
      }
      
      return sv_x_out;
    }
        
    SV* sum(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v_out = new Rstats::Vector<double>(1);
        double v_out_total(0);
        for (int32_t i = 0; i < v1->get_length(); i++) {
          v_out_total += v1->get_value(i);
        }
        v_out->set_value(0, v_out_total);
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v_out = new Rstats::Vector<int32_t>(1);
        int32_t v_out_total(0);
        for (int32_t i = 0; i < v1->get_length(); i++) {
          v_out_total += v1->get_value(i);
        }
        v_out->set_value(0, v_out_total);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Error in sum() : non-double argument to sum()");
      }
      
      
      return sv_x_out;
    }

    SV* prod(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);

      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v_out = new Rstats::Vector<double>(1);
        double v_out_total(1);
        for (int32_t i = 0; i < v1->get_length(); i++) {
          v_out_total *= v1->get_value(i);
        }
        v_out->set_value(0, v_out_total);
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<double>* v_out = new Rstats::Vector<double>(1);
        double v_out_total(1);
        for (int32_t i = 0; i < v1->get_length(); i++) {
          v_out_total *= v1->get_value(i);
        }
        v_out->set_value(0, v_out_total);
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in prod() : non-double argument to prod()");
      }
      
      return sv_x_out;
    }
        
    SV* equal(SV* sv_r, SV* sv_x1, SV* sv_x2) {

      SV* sv_x_out;
      
      char* type1 = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type1, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v2 = Rstats::Func::get_vector<double>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::equal<double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else if (strEQ(type1, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v2 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::equal<int32_t>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Error in == : default method not implemented for type '%s'", type);
      }
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* not_equal(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      SV* sv_x_out;
      
      char* type1 = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type1, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v2 = Rstats::Func::get_vector<double>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::not_equal<double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else if (strEQ(type1, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v2 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::not_equal<int32_t>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Error in != : default method not implemented for type '%s'", type);
      }
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* more_than(SV* sv_r, SV* sv_x1, SV* sv_x2) {

      SV* sv_x_out;
      
      char* type1 = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type1, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v2 = Rstats::Func::get_vector<double>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::more_than<double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else if (strEQ(type1, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v2 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::more_than<int32_t>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Error in > : default method not implemented for type '%s'", type);
      }
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* more_than_or_equal(SV* sv_r, SV* sv_x1, SV* sv_x2) {

      SV* sv_x_out;
      
      char* type1 = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type1, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v2 = Rstats::Func::get_vector<double>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::more_than_or_equal<double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else if (strEQ(type1, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v2 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::more_than_or_equal<int32_t>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Error in >= : default method not implemented for type '%s'", type);
      }
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
    
    SV* less_than(SV* sv_r, SV* sv_x1, SV* sv_x2) {

      SV* sv_x_out;
      
      char* type1 = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type1, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v2 = Rstats::Func::get_vector<double>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::less_than<double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else if (strEQ(type1, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v2 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::less_than<int32_t>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Error in < : default method not implemented for type '%s'", type);
      }
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* less_than_or_equal(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      SV* sv_x_out;
      
      char* type1 = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type1, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v2 = Rstats::Func::get_vector<double>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::less_than_or_equal<double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else if (strEQ(type1, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v2 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::less_than_or_equal<int32_t>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Error in <= : default method not implemented for type '%s'", type);
      }
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* And(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      SV* sv_x_out;
      
      char* type1 = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type1, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v2 = Rstats::Func::get_vector<double>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::And<double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else if (strEQ(type1, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v2 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::And<int32_t>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Error in & : default method not implemented for type '%s'", type);
      }
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* Or(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      SV* sv_x_out;
      
      char* type1 = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type1, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v2 = Rstats::Func::get_vector<double>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::Or<double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else if (strEQ(type1, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v2 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::Or<int32_t>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Error in | : default method not implemented for type '%s'", type);
      }
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* add(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      SV* sv_x_out;
      
      char* type1 = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type1, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v2 = Rstats::Func::get_vector<double>(sv_r, sv_x2);
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::add<double, double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type1, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v2 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::add<int32_t, int32_t>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Error in + : non-double argument to binary operator");
      }
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* subtract(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      SV* sv_x_out;
      
      char* type1 = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type1, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v2 = Rstats::Func::get_vector<double>(sv_r, sv_x2);
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::subtract<double, double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type1, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v2 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::subtract<int32_t, int32_t>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Error in - : non-double argument to binary operator");
      }
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* remainder(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      SV* sv_x_out;
      
      char* type1 = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type1, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v2 = Rstats::Func::get_vector<double>(sv_r, sv_x2);
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::remainder<double, double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type1, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v2 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x2);
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::remainder<int32_t, double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in % : non-double argument to binary operator");
      }
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
    
    SV* divide(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      SV* sv_x_out;
      
      char* type1 = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type1, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v2 = Rstats::Func::get_vector<double>(sv_r, sv_x2);
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::divide<double, double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type1, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v2 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x2);
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::divide<int32_t, double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in / : non-double argument to binary operator");
      }
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* atan2(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      SV* sv_x_out;
      
      char* type1 = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type1, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v2 = Rstats::Func::get_vector<double>(sv_r, sv_x2);
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::atan2<double, double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type1, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v2 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x2);
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::atan2<int32_t, double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in atan2() : non-double argument to mathematical function");
      }
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* pow(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      SV* sv_x_out;
      
      char* type1 = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type1, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v2 = Rstats::Func::get_vector<double>(sv_r, sv_x2);
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::pow<double, double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type1, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v2 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x2);
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::pow<int32_t, double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in ** : non-double argument to binary operator");
      }
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
                                        
    SV* multiply(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      
      SV* sv_x_out;
      
      char* type1 = Rstats::Func::get_type(sv_r, sv_x1);
      if (strEQ(type1, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        Rstats::Vector<double>* v2 = Rstats::Func::get_vector<double>(sv_r, sv_x2);
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::multiply<double, double>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type1, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        Rstats::Vector<int32_t>* v2 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x2);
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::multiply<int32_t, int32_t>(v1, v2);
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Error in * : non-double argument to binary operator");
      }
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
                            
    SV* sin(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::sin<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::sin<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in sin() : non-double argument to sin()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* tanh(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::tanh<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::tanh<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in tanh() : non-double argument to tanh()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* cos(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::cos<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::cos<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in cos() : non-double argument to cos()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* tan(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::tan<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::tan<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in tan() : non-double argument to tan()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* sinh(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::sinh<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::sinh<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in sinh() : non-double argument to sinh()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* cosh(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::cosh<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::cosh<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in cosh() : non-double argument to cosh()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* log(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::log<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::log<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in log() : non-double argument to log()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* logb(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::logb<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::logb<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in logb() : non-double argument to logb()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
    
    SV* log10(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::log10<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::log10<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in log10() : non-double argument to log10()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* log2(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::log2<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::log2<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in log2() : non-double argument to log2()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
    
    SV* acos(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::acos<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::acos<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in acos() : non-double argument to acos()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
    
    SV* acosh(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::acosh<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::acosh<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in acosh() : non-double argument to acosh()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
    
    SV* asinh(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::asinh<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::asinh<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in asinh() : non-double argument to asinh()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* atanh(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::atanh<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::atanh<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in atanh() : non-double argument to atanh()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* Conj(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::Conj<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::Conj<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in Conj() : non-double argument to Conj()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* asin(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::asin<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::asin<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in asin() : non-double argument to asin()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* atan(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::atan<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::atan<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in atan() : non-double argument to atan()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
    
    SV* sqrt(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::sqrt<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::sqrt<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in sqrt() : non-double argument to sqrt()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* expm1(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::expm1<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::expm1<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in expm1() : non-double argument to expm1()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* exp(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::exp<double, double>(v1);

        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);

        Rstats::Vector<double>* v_out = Rstats::VectorFunc::exp<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in exp() : non-double argument to exp()");
      }
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
    
    SV* neg(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::neg<double, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::neg<int32_t, int32_t>(v1);
        
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Error in -$x : non-double argument to - operator");
      }

      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* Arg(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::Arg<double, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::Arg<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in Arg() : non-double argument to Arg()");
      }

      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* abs(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::abs<double, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::abs<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in abs() : non-double argument to abs()");
      }

      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* Mod(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::Mod<double, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::Mod<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in Mod() : non-double argument to Mod()");
      }

      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
    
    SV* Re(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::Re<double, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::Re<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in Re() : non-double argument to Re()");
      }

      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
    
    SV* Im(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::Im<double, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        
        Rstats::Vector<double>* v_out = Rstats::VectorFunc::Im<int32_t, double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else {
        croak("Error in Im() : non-double argument to Im()");
      }

      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
            
    SV* is_infinite(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::is_infinite<double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::is_infinite<int32_t>(v1);
        
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Error in is_infinite() : non-double argument to is_infinite()");
      }

      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }

    SV* is_nan(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::is_nan<double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::is_nan<int32_t>(v1);
        
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Error in is_nan() : non-double argument to is_nan()");
      }

      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
    }
    
    SV* is_finite(SV* sv_r, SV* sv_x1) {
      
      char* type = Rstats::Func::get_type(sv_r, sv_x1);
      
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
        
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::is_finite<double>(v1);
        
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
        
        Rstats::Vector<int32_t>* v_out = Rstats::VectorFunc::is_finite<int32_t>(v1);
        
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Error in is_finite() : non-double argument to is_finite()");
      }

      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x_out);
      
      return sv_x_out;
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
    
    SV* dim(SV* sv_r, SV* sv_x1, SV* sv_x_dim) {
      sv_x_dim = sv_x_dim;
      
      Rstats::pl_hv_store(sv_x1, "dim", sv_x_dim);
      
      return sv_r;
    }
    
    SV* dim(SV* sv_r, SV* sv_x1) {
      SV* sv_x_dim = Rstats::pl_hv_fetch(sv_x1, "dim");
      
      return sv_x_dim;
    }

    SV* values(SV* sv_r, SV* sv_x1) {
      
      SV* sv_values = Rstats::Func::create_sv_values(sv_r, sv_x1);
      
      return sv_values;
    }

    SV* type(SV* sv_r, SV* sv_x1) {
      
      return Rstats::pl_new_sv_pv(Rstats::Func::get_type(sv_r, sv_x1));
    }

    SV* is_vector (SV* sv_r, SV* sv_x1) {
      
      bool is = !Rstats::pl_hv_exists(sv_x1, "dim") || Rstats::Func::get_length(sv_r, dim(sv_r, sv_x1)) == 1;
      
      SV* sv_is = is ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
            
      return sv_is;
    }

    SV* is_matrix(SV* sv_r, SV* sv_x1) {

      int32_t is = Rstats::Func::get_length(sv_r, dim(sv_r, sv_x1)) == 2;
      
      SV* sv_x_is = is ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
      
      return sv_x_is;
    }

    SV* pi (SV* sv_r) {
      double pi = Rstats::Util::pi();
      
      Rstats::Vector<double>* v_out = new Rstats::Vector<double>(1, pi);
      SV* sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      
      return sv_x_out;
    }

    template <>
    SV* new_vector<double>(SV* sv_r) {
      SV* sv_x1 = Rstats::pl_new_hvrv();
      
      sv_bless(sv_x1, gv_stashpv("Rstats::Object", 1));
      Rstats::pl_hv_store(sv_x1, "r", sv_r);
      Rstats::pl_hv_store(sv_x1, "type", Rstats::pl_new_sv_pv("double"));
      
      return sv_x1;
    }

    template <>
    SV* new_vector<int32_t>(SV* sv_r) {
      SV* sv_x1 = Rstats::pl_new_hvrv();
      
      sv_bless(sv_x1, gv_stashpv("Rstats::Object", 1));
      Rstats::pl_hv_store(sv_x1, "r", sv_r);
      Rstats::pl_hv_store(sv_x1, "type", Rstats::pl_new_sv_pv("int"));
      
      return sv_x1;
    }

    SV* c_double(SV* sv_r, SV* sv_values) {
      
      if (!sv_derived_from(sv_values, "ARRAY")) {
        croak("Invalid argment(c_double()");
      }
      
      int32_t length = Rstats::pl_av_len(sv_values);
      
      Rstats::Vector<double>* v1 = new Rstats::Vector<double>(length);
      for (int32_t i = 0; i < length; i++) {
        SV* sv_value = Rstats::pl_av_fetch(sv_values, i);

        char* sv_value_str = SvPV_nolen(sv_value);
        if (strEQ(sv_value_str, "NaN")) {
          v1->set_value(i, NAN);
        }
        else if (strEQ(sv_value_str, "Inf")) {
          v1->set_value(i, INFINITY);
        }
        else if (strEQ(sv_value_str, "-Inf")) {
          v1->set_value(i, -(INFINITY));
        }
        else {
          double value = SvNV(sv_value);
          v1->set_value(i, value);
        }
      }
      
      SV* sv_x1 = Rstats::Func::new_vector<double>(sv_r, v1);
      
      return sv_x1;
    }

    SV* c_int(SV* sv_r, SV* sv_values) {
      if (!sv_derived_from(sv_values, "ARRAY")) {
        croak("Invalid argment(c_int()");
      }
      
      int32_t length = Rstats::pl_av_len(sv_values);
      
      Rstats::Vector<int32_t>* v1 = new Rstats::Vector<int32_t>(length);
      for (int32_t i = 0; i < length; i++) {
        SV* sv_value = Rstats::pl_av_fetch(sv_values, i);
        
        v1->set_value(
          i,
          SvIV(sv_value)
        );
      }
      
      SV* sv_x1 = Rstats::Func::new_vector<int32_t>(sv_r, v1);
      
      return sv_x1;
    }

    SV* new_NaN(SV* sv_r) {
      Rstats::Vector<double>* v1 = new Rstats::Vector<double>(1, NAN);
      
      SV* sv_x1 = Rstats::Func::new_vector<double>(sv_r, v1);
      
      return sv_x1;
    }

    SV* new_Inf(SV* sv_r) {
      Rstats::Vector<double>* v1 = new Rstats::Vector<double>(1, INFINITY);
      
      SV* sv_x1 = Rstats::Func::new_vector<double>(sv_r, v1);
      
      return sv_x1;
    }

    SV* new_FALSE(SV* sv_r) {
      Rstats::Vector<int32_t>* v1 = new Rstats::Vector<int32_t>(1, 0);
      
      SV* sv_x1 = Rstats::Func::new_vector<int32_t>(sv_r, v1);
      
      return sv_x1;
    }

    SV* new_TRUE(SV* sv_r) {
      Rstats::Vector<int32_t>* v1 = new Rstats::Vector<int32_t>(1, 1);
      
      SV* sv_x1 = Rstats::Func::new_vector<int32_t>(sv_r, v1);
      
      return sv_x1;
    }

    SV* is_double(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "double");
        
      SV* sv_x_is = is ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
      
      return sv_x_is;
    }

    SV* is_int(SV* sv_r, SV* sv_x1) {
      
      bool is = strEQ(Rstats::Func::get_type(sv_r, sv_x1), "int");
        
      SV* sv_x_is = is ? Rstats::Func::new_TRUE(sv_r) : Rstats::Func::new_FALSE(sv_r);
      
      return sv_x_is;
    }

    SV* new_data_frame(SV* sv_r) {
      SV* sv_data_frame = Rstats::pl_new_hvrv();
      Rstats::pl_sv_bless(sv_data_frame, "Rstats::Object");
      Rstats::pl_hv_store(sv_data_frame, "r", sv_r);
      
      return sv_data_frame;
    }

    SV* copy_attrs_to(SV* sv_r, SV* sv_x1, SV* sv_x2) {
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x2, &PL_sv_undef);
    }

    SV* copy_attrs_to(SV* sv_r, SV* sv_x1, SV* sv_x2, SV* sv_opt) {
      
      if (!SvOK(sv_opt)) {
        sv_opt = Rstats::pl_new_hvrv();
      }
      
      // type
      if (!SvOK(Rstats::pl_hv_fetch(sv_x2, "type")) && Rstats::pl_hv_exists(sv_x1, "type")) {
        Rstats::pl_hv_store(sv_x2, "type", Rstats::pl_hv_fetch(sv_x1, "type"));
      }

      // dim
      if (!SvOK(Rstats::pl_hv_fetch(sv_x2, "dim")) && Rstats::pl_hv_exists(sv_x1, "dim")) {
        Rstats::pl_hv_store(sv_x2, "dim", Rstats::pl_hv_fetch(sv_x1, "dim"));
      }
    }

    SV* dim_as_array(SV* sv_r, SV* sv_x1) {
      
      if (Rstats::pl_hv_exists(sv_x1, "dim")) {
        return Rstats::Func::dim(sv_r, sv_x1);
      }
      else {
        int32_t length = Rstats::Func::get_length(sv_r, sv_x1);
        Rstats::Vector<double>* v_out = new Rstats::Vector<double>(1, length);
        SV* sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
        return sv_x_out;
      }
    }

    SV* decompose(SV* sv_r, SV* sv_x1) {
      
      SV* sv_elements = Rstats::pl_new_avrv();
      
      int32_t length = Rstats::Func::get_length(sv_r, sv_x1);
      
      if (length > 0) {
      
        av_extend(Rstats::pl_av_deref(sv_elements), length);
        
        char* type = Rstats::Func::get_type(sv_r, sv_x1);

        if (strEQ(type, "double")) {
          Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);
          for (int32_t i = 0; i < length; i++) {
            Rstats::Vector<double>* v_out
              = new Rstats::Vector<double>(1, v1->get_value(i));
            SV* sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
            Rstats::pl_av_push(sv_elements, sv_x_out);
          }
        }
        else if (strEQ(type, "int")) {
          Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
          for (int32_t i = 0; i < length; i++) {
            Rstats::Vector<int32_t>* v_out
              = new Rstats::Vector<int32_t>(1, v1->get_value(i));
            SV* sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
            Rstats::pl_av_push(sv_elements, sv_x_out);
          }
        }
      }
      
      return sv_elements;
    }

    SV* compose(SV* sv_r, SV* sv_type, SV* sv_elements)
    {
      int32_t len = Rstats::pl_av_len(sv_elements);
      
      char* type = SvPV_nolen(sv_type);
      SV* sv_x_out;
      if (strEQ(type, "double")) {
        
        Rstats::Vector<double>* v_out = new Rstats::Vector<double>(len);
        for (int32_t i = 0; i < len; i++) {
          SV* sv_x1 = Rstats::pl_av_fetch(sv_elements, i);
          Rstats::Vector<double>* v1 = Rstats::Func::get_vector<double>(sv_r, sv_x1);

          v_out->set_value(i, v1->get_value(0));
        }
        sv_x_out = Rstats::Func::new_vector<double>(sv_r, v_out);
      }
      else if (strEQ(type, "int")) {
        Rstats::Vector<int32_t>* v_out = new Rstats::Vector<int32_t>(len);
        int32_t* values = v_out->get_values();
        for (int32_t i = 0; i < len; i++) {
          SV* sv_x1 = Rstats::pl_av_fetch(sv_elements, i);
          Rstats::Vector<int32_t>* v1 = Rstats::Func::get_vector<int32_t>(sv_r, sv_x1);
          v_out->set_value(i, v1->get_value(0));
        }
        sv_x_out = Rstats::Func::new_vector<int32_t>(sv_r, v_out);
      }
      else {
        croak("Unknown type(Rstats::Func::compose())");
      }
      
      return sv_x_out;
    }

    SV* args_h(SV* sv_r, SV* sv_names, SV* sv_args) {
      
      int32_t args_length = Rstats::pl_av_len(sv_args);
      SV* sv_opt;
      SV* sv_arg_last = Rstats::pl_av_fetch(sv_args, args_length - 1);
      if (!sv_isobject(sv_arg_last) && sv_derived_from(sv_arg_last, "HASH")) {
        sv_opt = Rstats::pl_av_pop(sv_args);
      }
      else {
        sv_opt = Rstats::pl_new_hvrv();
      }
      
      SV* sv_new_opt = Rstats::pl_new_hvrv();
      int32_t names_length = Rstats::pl_av_len(sv_names);
      for (int32_t i = 0; i < names_length; i++) {
        SV* sv_name = Rstats::pl_av_fetch(sv_names, i);
        if (Rstats::pl_hv_exists(sv_opt, SvPV_nolen(sv_name))) {
          Rstats::pl_hv_store(
            sv_new_opt,
            SvPV_nolen(sv_name),
            Rstats::pl_hv_delete(sv_opt, SvPV_nolen(sv_name))
          );
        }
        else if (i < names_length) {
          SV* sv_name = Rstats::pl_av_fetch(sv_names, i);
          SV* sv_arg = Rstats::pl_av_fetch(sv_args, i);
          if (SvOK(sv_arg)) {
            Rstats::pl_hv_store(
              sv_new_opt,
              SvPV_nolen(sv_name),
              sv_arg
            );
          }
        }
      }

      return sv_new_opt;
    }
  }
}
