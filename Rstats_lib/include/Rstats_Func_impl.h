namespace Rstats {
  namespace Func {
    template <class T>
    SV* new_vector(SV* sv_r, Rstats::Vector<T>* v1) {
      SV* sv_x_out = Rstats::Func::new_vector<T>(sv_r);
      Rstats::Func::set_vector(sv_r, sv_x_out, v1);
      
      return sv_x_out;
    }
  }

  template <class T>
  void set_vector(SV* sv_r, SV* sv_a1, Rstats::Vector<T>* v1) {
    SV* sv_vector = Rstats::pl_object_wrap<Rstats::Vector<T>*>(v1, "Rstats::Vector");
    Rstats::pl_hv_store(sv_a1, "vector", sv_vector);
  }
  
  template <class T>
  Rstats::Vector<T>* get_vector(SV* sv_r, SV* sv_a1) {
    SV* sv_vector = Rstats::pl_hv_fetch(sv_a1, "vector");
    
    if (SvOK(sv_vector)) {
      Rstats::Vector<T>* vector = Rstats::pl_object_unwrap<Rstats::Vector<T>*>(sv_vector, "Rstats::Vector");
      return vector;
    }
    else {
      return NULL;
    }
  }
}
