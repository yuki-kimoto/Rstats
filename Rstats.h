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

  // Rstats::ElementType
  namespace ElementType {
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

  // Rstats::Element
  typedef struct {
    union {
      int iv;
      double dv;
      char* chv;
      void* pv;
    };
    Rstats::ElementType::Enum type;
  } Element;
  
  // Rstats::ElementFunc
  namespace ElementFunc {
    
    Rstats::Element* integer(int iv) {
      
      Rstats::Element* e1 = new Rstats::Element;
      e1->iv = iv;
      e1->type = Rstats::ElementType::INTEGER;
      
      return e1;
    }

    Rstats::ElementType::Enum check_type(const Element* e1, const Element* e2) {
      if (e1->type == e2->type) {
        return e1->type;
      }
      else {
        return Rstats::ElementType::UNKNOWN;
      }
    }
    
    void add(Element* e1, const Element* e2) {
      Rstats::ElementType::Enum type = check_type(e1, e2);
      
      if (type == Rstats::ElementType::NA) {
        e1->type = Rstats::ElementType::NA;
      }
      else if (e2->type == Rstats::ElementType::INTEGER) {
        e1->iv += e2->iv;
      }
      else if (e2->type == Rstats::ElementType::DOUBLE) {
        e1->dv += e2->dv;
      }
      else if (e2->type == Rstats::ElementType::COMPLEX) {
        *((std::complex<double>*)e1->pv) += *((std::complex<double>*)e2->pv);
      }
    }
  }
  
  // Rstats::ElementFunc
  namespace ElementFunc {
    void process(void (*func)(Element*, const Element*), Rstats::Element* elements1, const Rstats::Element* elements2, size_t size) {
      for (int i = 0; i < size; i++) {
        (*func)(elements1 + i, elements2 + i);
      }
    }
    
    void add(Rstats::Element* elements1, const Rstats::Element* elements2, size_t size) {
      process(Rstats::ElementFunc::add, elements1, elements2, size);
    }

    Rstats::Element* new_double(double dv)
    {
      Rstats::Element* element = new Rstats::Element;
      element->dv = dv;
      element->type = Rstats::ElementType::DOUBLE;
      
      return element;
    }

    Rstats::Element* new_character(SV* str_sv) {
      Rstats::Element* element = new Rstats::Element;
      SV* new_str_sv = Rstats::Perl::new_sv(str_sv);
      SvREFCNT_inc(new_str_sv);
      element->pv = new_str_sv;
      element->type = Rstats::ElementType::CHARACTER;
      
      return element;
    }

    Rstats::Element* new_complex(double re, double im) {
      
      std::complex<double>* z = new std::complex<double>(re, im);
      Rstats::Element* element = new Rstats::Element;
      element->pv = (void*)z;
      element->type = Rstats::ElementType::COMPLEX;
      
      return element;
    }

    Rstats::Element* new_true() {
      Rstats::Element* element = new Rstats::Element;
      element->iv = 1;
      element->type = Rstats::ElementType::LOGICAL;
      
      return element;
    }

    Rstats::Element* new_logical(bool b) {
      Rstats::Element* element = new Rstats::Element;
      element->iv = b ? 1 : 0;
      element->type = Rstats::ElementType::LOGICAL;
      
      return element;
    }
    
    Rstats::Element* new_false() {
      Rstats::Element* element = new Rstats::Element;
      element->iv = 0;
      element->type = Rstats::ElementType::LOGICAL;
      
      return element;
    }
    
    Rstats::Element* new_integer(int iv) {
      Rstats::Element* element = new Rstats::Element;
      element->iv = iv;
      element->type = Rstats::ElementType::INTEGER;
      
      return element;
    }

    Rstats::Element* new_NaN() {
      Rstats::Element* element = new_double(NAN);
      
      return element;
    }

    Rstats::Element* new_negativeInf() {
      Rstats::Element* element = new_double(-(INFINITY));
      return element;
    }
    
    Rstats::Element* new_Inf() {
      Rstats::Element* element = new_double(INFINITY);
      return element;
    }
    
    Rstats::Element* new_NA() {
      Rstats::Element* element = new Rstats::Element;
      element->type = Rstats::ElementType::NA;
      
      return element;
    }
    
    Rstats::Element* is_infinite(Rstats::Element* element) {
      Rstats::Element* ret;
      if (element->type == Rstats::ElementType::DOUBLE && std::isinf(element->dv)) {
        ret = new_true();
      }
      else {
        ret = new_false();
      }
      
      return ret;
    }

    Rstats::Element* is_finite(Rstats::Element* element) {
      
      Rstats::Element* ret;
      if (element->type == Rstats::ElementType::INTEGER || (element->type == Rstats::ElementType::DOUBLE && std::isfinite(element->dv))) {
        ret = new_true();
      }
      else {
        ret = new_false();
      }

      return ret;
    }

    Rstats::Element* is_nan(Rstats::Element* element) {
      Rstats::Element* ret;

      if (element->type == Rstats::ElementType::DOUBLE && isnan(element->dv)) {
        ret = new_true();
      }
      else {
        ret = new_false();
      }
      
      return ret;
    }
  }
}
