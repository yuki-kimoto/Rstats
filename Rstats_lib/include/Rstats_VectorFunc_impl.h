template <class T_IN, class T_OUT>
Rstats::Vector* operate_unary_math(T_OUT (*func)(T_IN), Rstats::Vector* v1) {
  
  Rstats::Integer length = v1->get_length();
  
  Rstats::Vector* v_out = Rstats::Vector::new_vector<T_OUT>(length);
  
  Rstats::Util::init_warn();
  for (Rstats::Integer i = 0; i < length; i++) {
    v_out->set_value<T_OUT>(i, (*func)(v1->get_value<T_IN>(i)));
  }
  if (Rstats::Util::get_warn()) {
    Rstats::Util::print_warn_message();
  }
  
  v_out->merge_na_positions(v1->get_na_positions());
  
  return v_out;
}