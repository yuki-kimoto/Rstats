namespace Rstats {
  namespace Func {
    template <class T>
    SV* new_vector(SV* sv_r, Rstats::Vector* v1) {
      SV* sv_x_out = Rstats::Func::new_vector<T>(sv_r);
      Rstats::Func::set_vector(sv_r, sv_x_out, v1);
      
      return sv_x_out;
    }

    template <class T_IN, class T_OUT>
    SV* operate_binary(SV* sv_r, T_OUT (*func)(T_IN, T_IN), SV* sv_x1, SV* sv_x2) {

      Rstats::Vector* v1 = Rstats::Func::get_vector(sv_r, sv_x1);
      Rstats::Vector* v2 = Rstats::Func::get_vector(sv_r, sv_x2);

      Rstats::Integer length = Rstats::Func::get_length(sv_r, sv_x1);
      Rstats::Vector* v3 = Rstats::Vector::new_vector<T_OUT>(length);

      for (Rstats::Integer i = 0; i < length; i++) {
        try {
          v3->set_value<T_OUT>(
            i,
            (*func)(
              v1->get_value<T_IN>(i),
              v2->get_value<T_IN>(i)
            )
          );
        }
        catch (const char* e) {
          v3->add_na_position(i);
        }
      }
      v3->merge_na_positions(v1->get_na_positions());
      v3->merge_na_positions(v2->get_na_positions());
      
      SV* sv_x3 = Rstats::Func::new_vector<T_OUT>(sv_r);
      Rstats::Func::set_vector(sv_r, sv_x3, v3);
      
      Rstats::Func::copy_attrs_to(sv_r, sv_x1, sv_x3);
      
      return sv_x3;
    }
  }
}
