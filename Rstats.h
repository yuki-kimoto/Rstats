namespace Rstats {
  // Rstats::Perl
  namespace Perl {
    
    SV* new_ref(SV* sv) {
      return sv_2mortal(newRV_inc(sv));
    }

    SV* new_ref(AV* av) {
      return sv_2mortal(newRV_inc((SV*)av));
    }

    SV* new_ref(HV* hv) {
      return sv_2mortal(newRV_inc((SV*)hv));
    }
    
    I32 iv (SV* sv) {
      return SvIV(sv);
    }
    
    U32 uv(SV* sv) {
      return SvUV(sv);
    }

    double nv(SV* sv) {
      return SvNV(sv);
    }
      
    char* pv(SV* sv) {
      return SvPV_nolen(sv);
    }

    SV* new_sv(I32 iv) {
      return sv_2mortal(newSViv(iv));
    }

    SV* new_sv(U32 uv) {
      return sv_2mortal(newSVuv(uv));
    }
    
    SV* new_sv (SV* sv) {
      return sv_2mortal(newSVsv(sv));
    }
    
    SV* new_sv(double nv) {
      return sv_2mortal(newSVnv(nv));
    }

    SV* new_sv(char* pv) {
      return sv_2mortal(newSVpvn(pv, strlen(pv)));
    }
    
    AV* new_av() {
      return (AV*)sv_2mortal((SV*)newAV());
    }
    
    SV* new_av_ref() {
      return sv_2mortal(newRV_inc((SV*)new_av()));
    }
    
    HV* new_hv() {
      return (HV*)sv_2mortal((SV*)newHV());
    }

    SV* new_hv_ref() {
      return sv_2mortal(newRV_inc((SV*)new_hv()));
    }

    SV* sv_deref(SV* ref) {
      if (SvROK(ref)) {
        return SvRV(ref);
      }
      else {
        croak("Can't derefernce");
      }
    }

    AV* av_deref(SV* ref) {
      if (SvROK(ref)) {
        return (AV*)SvRV(ref);
      }
      else {
        croak("Can't derefernce");
      }
    }

    I32 length (AV* av) {
      return av_len(av) + 1;
    }

    I32 length (SV* av_ref) {
      return av_len(av_deref(av_ref)) + 1;
    }
    
    SV* av_get(AV* av, I32 pos) {
      SV** const element_ptr = av_fetch(av, pos, FALSE);
      SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
      
      return element;
    }

    SV* av_get(AV* av, SV* pos_sv) {
      return av_get(av, iv(pos_sv));
    }
    
    SV* av_get(SV* av_ref, I32 pos) {
      AV* av = av_deref(av_ref);
      SV** const element_ptr = av_fetch(av, pos, FALSE);
      SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
      
      return element;
    }

    SV* av_get(SV* av_ref, SV* pos_sv) {
      return av_get(av_ref, iv(pos_sv));
    }

    HV* hv_deref(SV* ref) {
      if (SvROK(ref)) {
        return (HV*)SvRV(ref);
      }
      else {
        croak("Can't derefernce");
      }
    }
    
    SV* hv_get(HV* hv, char* key) {
      SV** const element_ptr = hv_fetch(hv, key, strlen(key), FALSE);
      SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
      
      return element;
    }

    SV* hv_get(HV* hv, SV* key_sv) {
      return hv_get(hv, pv(key_sv));
    }
    
    SV* hv_get(SV* hv_ref, char* key) {
      HV* hv = hv_deref(hv_ref);
      SV** const element_ptr = hv_fetch(hv, key, strlen(key), FALSE);
      SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
      
      return element;
    }

    SV* hv_get(SV* hv_ref, SV* key_sv) {
      return hv_get(hv_ref, pv(key_sv));
    }
    
    void av_set(AV* av, I32 pos, SV* element) {
      av_store(av, pos, SvREFCNT_inc(element));
    }
    
    void av_set(SV* av_ref, I32 pos, SV* element) {
      AV* av = av_deref(av_ref);
      av_store(av, pos, SvREFCNT_inc(element));
    }

    SV* av_copy(SV* av_ref_sv) {
      SV* new_av_ref_sv = new_av_ref();
      
      for (I32 i = 0; i < length(av_ref_sv); i++) {
        av_set(new_av_ref_sv, i, new_sv(av_get(av_ref_sv, i)));
      }
      
      return new_av_ref_sv;
    }
    
    void hv_set(HV* hv, char* key, SV* element) {
      hv_store(hv, key, strlen(key), SvREFCNT_inc(element), FALSE);
    }

    void hv_set(SV* hv_ref, char* key, SV* element) {
      HV* hv = hv_deref(hv_ref);
      hv_store(hv, key, strlen(key), SvREFCNT_inc(element), FALSE);
    }
    
    void push(AV* av, SV* sv) {
      av_push(av, SvREFCNT_inc(sv));
    }
    
    void push(SV* av_ref, SV* sv) {
      av_push(av_deref(av_ref), SvREFCNT_inc(sv));
    }

    void unshift(AV* av, SV* sv) {
      av_unshift(av, 1);
      av_set(av, 0, sv);
    }
    
    void unshift(SV* av_ref, SV* sv) {
      av_unshift(av_deref(av_ref), 1);
      av_set(av_deref(av_ref), 0, sv);
    }

    template <class X> X to_c_obj(SV* perl_obj_ref) {
      SV* perl_obj = SvROK(perl_obj_ref) ? SvRV(perl_obj_ref) : perl_obj_ref;
      size_t obj_addr = SvIV(perl_obj);
      X c_obj = INT2PTR(X, obj_addr);
      
      return c_obj;
    }

    template <class X> SV* to_perl_obj(X c_obj, char* class_name) {
      I32 obj_addr = PTR2IV(c_obj);
      SV* obj_addr_sv = new_sv(obj_addr);
      SV* obj_addr_sv_ref = new_ref(obj_addr_sv);
      SV* perl_obj = sv_bless(obj_addr_sv_ref, gv_stashpv(class_name, 1));
      
      return perl_obj;
    }
  };

  // Rstats::ElementsType
  namespace ElementsType {
    enum Enum {
      LOGICAL = 1,
      INTEGER = 2,
      DOUBLE = 4,
      COMPLEX = 8,
      CHARACTER = 16
    };
  }

  // Rstats::Elements
  typedef struct  {
    public:
    void* values;
    int size;
    Rstats::ElementsType::Enum type;
    std::map<int, int>* na_positions;
  } Elements;
  
  // Rstats::ElementsFunc
  namespace ElementsFunc {
    
    Rstats::Elements* new_double(double dv)
    {
      Rstats::Elements* elements = new Rstats::Elements;
      std::vector<double>* values = new std::vector<double>(1);
      (*values)[0] = dv;
      elements->values = values;
      elements->type = Rstats::ElementsType::DOUBLE;
      elements->size = values->size();
      elements->na_positions = new std::map<int, int>();
      
      return elements;
    }

    Rstats::Elements* new_character(SV* str_sv) {
      Rstats::Elements* elements = new Rstats::Elements;
      std::vector<SV*>* values = new std::vector<SV*>(1);
      
      SV* new_str_sv = Rstats::Perl::new_sv(str_sv);
      SvREFCNT_inc(new_str_sv);
      (*values)[0] = new_str_sv;
      elements->values = values;
      elements->type = Rstats::ElementsType::CHARACTER;
      elements->size = values->size();
      elements->na_positions = new std::map<int, int>();
      
      return elements;
    }

    Rstats::Elements* new_complex(double re, double im) {
      
      std::complex<double>* z = new std::complex<double>(re, im);
      Rstats::Elements* elements = new Rstats::Elements;
      std::vector<std::complex<double>*>* values = new std::vector<std::complex<double>*>(1);
      (*values)[0] = z;
      elements->values = values;
      elements->type = Rstats::ElementsType::COMPLEX;
      elements->size = values->size();
      elements->na_positions = new std::map<int, int>();
      
      return elements;
    }

    Rstats::Elements* new_logical(int iv) {
      Rstats::Elements* elements = new Rstats::Elements;
      std::vector<int>* values = new std::vector<int>(1);
      (*values)[0] = iv;
      elements->values = values;
      elements->type = Rstats::ElementsType::LOGICAL;
      elements->size = values->size();
      elements->na_positions = new std::map<int, int>();
      
      return elements;
    }
    
    Rstats::Elements* new_logical(std::vector<int>* values) {
      Rstats::Elements* elements = new Rstats::Elements;
      elements->values = values;
      elements->type = Rstats::ElementsType::LOGICAL;
      elements->size = values->size();
      elements->na_positions = new std::map<int, int>();
      
      return elements;
    }
    
    Rstats::Elements* new_true() {
      return new_logical(1);
    }

    Rstats::Elements* new_false() {
      return new_logical(0);
    }
    
    Rstats::Elements* new_integer(int iv) {
      
      Rstats::Elements* elements = new Rstats::Elements;
      std::vector<int>* values = new std::vector<int>(1);
      (*values)[0] = iv;
      elements->values = values;
      elements->type = Rstats::ElementsType::INTEGER;
      elements->size = values->size();
      elements->na_positions = new std::map<int, int>();
      
      return elements;
    }

    Rstats::Elements* new_NaN() {
      return new_double(NAN);
    }

    Rstats::Elements* new_negativeInf() {
      return new_double(-(INFINITY));
    }
    
    Rstats::Elements* new_Inf() {
      return new_double(INFINITY);
    }
    
    Rstats::Elements* new_NA() {
      Rstats::Elements* elements = new Rstats::Elements;
      std::vector<int>* values = new std::vector<int>(1);
      (*values)[0] = 0;
      elements->values = values;
      elements->type = Rstats::ElementsType::LOGICAL;
      elements->size = values->size();
      elements->na_positions = new std::map<int, int>();
      (*elements->na_positions)[0] = 1;
      
      return elements;
    }
    
    Rstats::Elements* is_infinite(Rstats::Elements* elements) {
      
      std::vector<int>* rets_values;
      int size = elements->size;
      if (elements->type == Rstats::ElementsType::DOUBLE) {
        std::vector<double>* values = (std::vector<double>*)elements->values;
        rets_values = new std::vector<int>(size);
        for (int i = 0; i < size; i++) {
          if(std::isinf((*values)[i])) {
            (*rets_values)[i] = 1;
          }
          else {
            (*rets_values)[i] = 0;
          }
        }
      }
      else {
        rets_values = new std::vector<int>(size, 0);
      }
      
      Rstats::Elements* rets = new_logical(rets_values);
      
      return rets;
    }

    Rstats::Elements* is_nan(Rstats::Elements* elements) {
      int size = elements->size;
      std::vector<int>* rets_values;
      if (elements->type == Rstats::ElementsType::DOUBLE) {
        std::vector<double>* values = (std::vector<double>*)elements->values;
        rets_values = new std::vector<int>(size);
        for (int i = 0; i < size; i++) {
          if(std::isnan((*values)[i])) {
            (*rets_values)[i] = 1;
          }
          else {
            (*rets_values)[i] = 0;
          }
        }
      }
      else {
        rets_values = new std::vector<int>(size, 0);
      }
      
      Rstats::Elements* rets = new_logical(rets_values);
      
      return rets;
    }

    Rstats::Elements* is_finite(Rstats::Elements* elements) {
      
      int size = elements->size;
      std::vector<int>* rets_values;
      if (elements->type == Rstats::ElementsType::INTEGER) {
        std::vector<int>* values = (std::vector<int>*)elements->values;
        
        rets_values = new std::vector<int>(size, 1);
      }
      else if (elements->type == Rstats::ElementsType::DOUBLE) {
        std::vector<double>* values = (std::vector<double>*)elements->values;
        
        rets_values = new std::vector<int>(size);
        for (int i = 0; i < size; i++) {
          if (std::isfinite((*values)[i])) {
            (*rets_values)[i] = 1;
          }
          else {
            (*rets_values)[i] = 0;
          }
        }
      }
      else {
        rets_values = new std::vector<int>(size, 0);
      }

      Rstats::Elements* rets = new_logical(rets_values);
      
      return rets;
    }

  }
}
