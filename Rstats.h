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

    SV* new_sv_iv(I32 iv) {
      return sv_2mortal(newSViv(iv));
    }

    SV* new_sv_uv(U32 uv) {
      return sv_2mortal(newSVuv(uv));
    }
    
    SV* new_sv (SV* sv) {
      return sv_2mortal(newSVsv(sv));
    }
    
    SV* new_sv(int iv) {
      return new_sv_iv((I32)iv);
    }

    SV* new_sv(unsigned int uv) {
      return new_sv_uv((U32)uv);
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
      size_t obj_addr = PTR2IV(c_obj);
      SV* obj_addr_sv = new_sv_iv(obj_addr);
      SV* obj_addr_sv_ref = new_ref(obj_addr_sv);
      SV* perl_obj = sv_bless(obj_addr_sv_ref, gv_stashpv(class_name, 1));
      
      return perl_obj;
    }
  };

  // Rstats::ElementsType
  namespace ElementsType {
    enum Enum {
      NA = 0,
      LOGICAL = 1,
      INTEGER = 2,
      DOUBLE = 4,
      COMPLEX = 8,
      CHARACTER = 16,
      UNKNOWN = 32
    };
  }

  // Rstats::Elements
  typedef struct {
    union {
      int iv;
      double dv;
      char* chv;
      void* pv;
    };
    Rstats::ElementsType::Enum type;
  } Elements;
  
  // Rstats::ElementsFunc
  namespace ElementsFunc {
    
    Rstats::Elements* integer(int iv) {
      
      Rstats::Elements* e1 = new Rstats::Elements;
      e1->iv = iv;
      e1->type = Rstats::ElementsType::INTEGER;
      
      return e1;
    }

    Rstats::ElementsType::Enum check_type(const Rstats::Elements* e1, const Rstats::Elements* e2) {
      if (e1->type == e2->type) {
        return e1->type;
      }
      else {
        return Rstats::ElementsType::UNKNOWN;
      }
    }
    
    void add(Rstats::Elements* e1, const Rstats::Elements* e2) {
      Rstats::ElementsType::Enum type = check_type(e1, e2);
      
      if (type == Rstats::ElementsType::NA) {
        e1->type = Rstats::ElementsType::NA;
      }
      else if (e2->type == Rstats::ElementsType::INTEGER) {
        e1->iv += e2->iv;
      }
      else if (e2->type == Rstats::ElementsType::DOUBLE) {
        e1->dv += e2->dv;
      }
      else if (e2->type == Rstats::ElementsType::COMPLEX) {
        *((std::complex<double>*)e1->pv) += *((std::complex<double>*)e2->pv);
      }
    }

    void process(void (*func)(Rstats::Elements*, const Rstats::Elements*), Rstats::Elements* elements1, const Rstats::Elements* elements2, size_t size) {
      for (int i = 0; i < size; i++) {
        (*func)(elements1 + i, elements2 + i);
      }
    }
    
    void add(Rstats::Elements* elements1, const Rstats::Elements* elements2, size_t size) {
      process(Rstats::ElementsFunc::add, elements1, elements2, size);
    }

    Rstats::Elements* new_double(double dv)
    {
      Rstats::Elements* element = new Rstats::Elements;
      element->dv = dv;
      element->type = Rstats::ElementsType::DOUBLE;
      
      return element;
    }

    Rstats::Elements* new_character(SV* str_sv) {
      Rstats::Elements* element = new Rstats::Elements;
      SV* new_str_sv = Rstats::Perl::new_sv(str_sv);
      SvREFCNT_inc(new_str_sv);
      element->pv = new_str_sv;
      element->type = Rstats::ElementsType::CHARACTER;
      
      return element;
    }

    Rstats::Elements* new_complex(double re, double im) {
      
      std::complex<double>* z = new std::complex<double>(re, im);
      Rstats::Elements* element = new Rstats::Elements;
      element->pv = (void*)z;
      element->type = Rstats::ElementsType::COMPLEX;
      
      return element;
    }

    Rstats::Elements* new_true() {
      Rstats::Elements* element = new Rstats::Elements;
      element->iv = 1;
      element->type = Rstats::ElementsType::LOGICAL;
      
      return element;
    }

    Rstats::Elements* new_logical(bool b) {
      Rstats::Elements* element = new Rstats::Elements;
      element->iv = b ? 1 : 0;
      element->type = Rstats::ElementsType::LOGICAL;
      
      return element;
    }
    
    Rstats::Elements* new_false() {
      Rstats::Elements* element = new Rstats::Elements;
      element->iv = 0;
      element->type = Rstats::ElementsType::LOGICAL;
      
      return element;
    }
    
    Rstats::Elements* new_integer(int iv) {
      Rstats::Elements* element = new Rstats::Elements;
      element->iv = iv;
      element->type = Rstats::ElementsType::INTEGER;
      
      return element;
    }

    Rstats::Elements* new_NaN() {
      Rstats::Elements* element = new_double(NAN);
      
      return element;
    }

    Rstats::Elements* new_negativeInf() {
      Rstats::Elements* element = new_double(-(INFINITY));
      return element;
    }
    
    Rstats::Elements* new_Inf() {
      Rstats::Elements* element = new_double(INFINITY);
      return element;
    }
    
    Rstats::Elements* new_NA() {
      Rstats::Elements* element = new Rstats::Elements;
      element->type = Rstats::ElementsType::NA;
      
      return element;
    }
    
    Rstats::Elements* is_infinite(Rstats::Elements* element) {
      Rstats::Elements* ret;
      if (element->type == Rstats::ElementsType::DOUBLE && std::isinf(element->dv)) {
        ret = new_true();
      }
      else {
        ret = new_false();
      }
      
      return ret;
    }

    Rstats::Elements* is_finite(Rstats::Elements* element) {
      
      Rstats::Elements* ret;
      if (element->type == Rstats::ElementsType::INTEGER || (element->type == Rstats::ElementsType::DOUBLE && std::isfinite(element->dv))) {
        ret = new_true();
      }
      else {
        ret = new_false();
      }

      return ret;
    }

    Rstats::Elements* is_nan(Rstats::Elements* element) {
      Rstats::Elements* ret;

      if (element->type == Rstats::ElementsType::DOUBLE && isnan(element->dv)) {
        ret = new_true();
      }
      else {
        ret = new_false();
      }
      
      return ret;
    }
  }
}
