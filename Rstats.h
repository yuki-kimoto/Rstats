namespace Rstats {
  // Rstats::PerlAPI
  namespace PerlAPI {
    
    REGEXP* mpregcomp (SV* sv_re, IV flag) {
      return (REGEXP*)sv_2mortal((SV*)pregcomp(sv_re, flag));
    }
    
    SV* new_mRV_inc(SV* sv) {
      return sv_2mortal(newRV_inc(sv));
    }

    SV* new_mSVsv(SV* sv) {
      return sv_2mortal(newSVsv(sv));
    }

    SV* new_mSVpv_nolen(const char* pv) {
      return sv_2mortal(newSVpvn(pv, strlen(pv)));
    }
        
    SV* new_mSViv(IV iv) {
      return sv_2mortal(newSViv(iv));
    }
    
    SV* new_mSVnv(NV nv) {
      return sv_2mortal(newSVnv(nv));
    }
    
    AV* new_mAV() {
      return (AV*)sv_2mortal((SV*)newAV());
    }
    
    SV* new_mAVRV() {
      return sv_2mortal(newRV_inc((SV*)new_mAV()));
    }
    
    HV* new_mHV() {
      return (HV*)sv_2mortal((SV*)newHV());
    }

    SV* new_mHVRV() {
      return sv_2mortal(newRV_inc((SV*)new_mHV()));
    }

    SV* SvRV_safe(SV* ref) {
      if (SvROK(ref)) {
        return SvRV(ref);
      }
      else {
        croak("Can't derefernce");
      }
    }
    
    IV av_len_fix (AV* av) {
      return av_len(av) + 1;
    }

    IV avrv_len_fix (SV* av_ref) {
      return av_len((AV*)SvRV_safe(av_ref)) + 1;
    }
    
    SV* av_fetch_simple(AV* av, IV pos) {
      SV** const element_ptr = av_fetch(av, pos, FALSE);
      SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
      
      return element;
    }
    
    SV* avrv_fetch_simple(SV* av_ref, IV pos) {
      AV* av = (AV*)SvRV_safe(av_ref);
      return av_fetch_simple(av, pos);
    }

    SV* hv_fetch_simple(HV* hv, const char* key) {
      SV** const element_ptr = hv_fetch(hv, key, strlen(key), FALSE);
      SV* const element = element_ptr ? *element_ptr : &PL_sv_undef;
      
      return element;
    }

    SV* hvrv_fetch_simple(SV* hv_ref, const char* key) {
      HV* hv = (HV*)SvRV_safe(hv_ref);
      return hv_fetch_simple(hv, key);
    }
    
    void av_store_inc(AV* av, IV pos, SV* element) {
      av_store(av, pos, SvREFCNT_inc(element));
    }
    
    void avrv_store_inc(SV* av_ref, IV pos, SV* element) {
      AV* av = (AV*)SvRV_safe(av_ref);
      av_store_inc(av, pos, element);
    }

    SV* copy_av(SV* sv_av_ref) {
      SV* sv_new_av_ref = new_mAVRV();
      
      for (IV i = 0; i < avrv_len_fix(sv_av_ref); i++) {
        avrv_store_inc(sv_new_av_ref, i, new_mSVsv(avrv_fetch_simple(sv_av_ref, i)));
      }
      
      return sv_new_av_ref;
    }
    
    void hv_store_nolen_inc(HV* hv, const char* key, SV* element) {
      hv_store(hv, key, strlen(key), SvREFCNT_inc(element), FALSE);
    }

    void hvrv_store_nolen_inc(SV* hv_ref, const char* key, SV* element) {
      HV* hv = (HV*)SvRV_safe(hv_ref);
      return hv_store_nolen_inc(hv, key, element);
    }
    
    void av_push_inc(AV* av, SV* sv) {
      av_push(av, SvREFCNT_inc(sv));
    }
    
    void avrv_push_inc(SV* av_ref, SV* sv) {
      return av_push_inc((AV*)SvRV_safe(av_ref), sv);
    }

    void av_unshift_real_inc(AV* av, SV* sv) {
      av_unshift(av, 1);
      av_store_inc(av, (IV)0, SvREFCNT_inc(sv));
    }
    
    void avrv_unshift_real_inc(SV* av_ref, SV* sv) {
      av_unshift((AV*)SvRV_safe(av_ref), 1);
      av_store_inc((AV*)SvRV_safe(av_ref), 0, SvREFCNT_inc(sv));
    }

    template <class X> X to_c_obj(SV* perl_obj_ref) {
      SV* perl_obj = SvROK(perl_obj_ref) ? SvRV(perl_obj_ref) : perl_obj_ref;
      IV obj_addr = SvIV(perl_obj);
      X c_obj = INT2PTR(X, obj_addr);
      
      return c_obj;
    }

    template <class X> SV* to_perl_obj(X c_obj, const char* class_name) {
      IV obj_addr = PTR2IV(c_obj);
      SV* sv_obj_addr = new_mSViv(obj_addr);
      SV* sv_obj_addr_ref = new_mRV_inc(sv_obj_addr);
      SV* perl_obj = sv_bless(sv_obj_addr_ref, gv_stashpv(class_name, 1));
      
      return perl_obj;
    }

    IV pregexec_simple (SV* sv_str, REGEXP* sv_re) {
      char* str = SvPV_nolen(sv_str);
      
      IV ret = pregexec(
        sv_re,
        str,
        str + strlen(str),
        str,
        0,
        sv_str,
        1
      );
      
      return ret;
    }
  };
  
  // Rstats::VectorType
  namespace VectorType {
    enum Enum {
      LOGICAL,
      INTEGER ,
      DOUBLE,
      COMPLEX,
      CHARACTER
    };
  }
  
  namespace Values {
    // Rstats::Values::Character
    typedef std::vector<SV*> Character;
    
    // Rstats::Values::Complex
    typedef std::vector<std::complex<NV> > Complex;
    
    // Rstats::Values::Double
    typedef std::vector<NV> Double;
    
    // Rstats::Values::Integer
    typedef std::vector<IV> Integer;
  }
  
  // Rstats::Util header
  namespace Util {
    SV* SV_CHARACTER_TYPE_NAME = newSVpv("character", 0);
    SV* SV_COMPLEX_TYPE_NAME = newSVpv("complex", 0);
    SV* SV_DOUBLE_TYPE_NAME = newSVpv("double", 0);
    SV* SV_NUMERIC_TYPE_NAME = newSVpv("numeric", 0);
    SV* SV_INTEGER_TYPE_NAME = newSVpv("integer", 0);
    SV* SV_LOGICAL_TYPE_NAME = newSVpv("logical", 0);

    SV* looks_like_na (SV*);
    SV* looks_like_integer (SV*);
    SV* looks_like_double (SV*);
    SV* looks_like_logical (SV*);
    SV* looks_like_complex (SV*);
  }
  
  // Rstats::Vector
  class Vector {
    private:
    Rstats::VectorType::Enum type;
    std::map<IV, IV> na_positions;
    void* values;
    
    
    public:
    
    ~Vector () {
      IV length = this->get_length();
    
      if (this->is_integer() || this->is_logical()) {
        Rstats::Values::Integer* values = this->get_integer_values();
        delete values;
      }
      else if (this->is_double()) {
        Rstats::Values::Double* values = this->get_double_values();
        delete values;
      }
      else if (this->is_complex()) {
        Rstats::Values::Complex* values = this->get_complex_values();
        delete values;
      }
      else if (this->is_character()) {
        Rstats::Values::Character* values = this->get_character_values();
        for (IV i = 0; i < length; i++) {
          if ((*values)[i] != NULL) {
            SvREFCNT_dec((*values)[i]);
          }
        }
        delete values;
      }
    }

    bool is_character () { return this->get_type() == Rstats::VectorType::CHARACTER; }
    bool is_complex () { return this->get_type() == Rstats::VectorType::COMPLEX; }
    bool is_double () { return this->get_type() == Rstats::VectorType::DOUBLE; }
    bool is_integer () { return this->get_type() == Rstats::VectorType::INTEGER; }
    bool is_numeric () {
      return this->get_type() == Rstats::VectorType::DOUBLE || this->get_type() == Rstats::VectorType::INTEGER;
    }
    bool is_logical () { return this->get_type() == Rstats::VectorType::LOGICAL; }
    
    Rstats::Values::Character* get_character_values() {
      return (Rstats::Values::Character*)this->values;
    }
    
    Rstats::Values::Complex* get_complex_values() {
      return (Rstats::Values::Complex*)this->values;
    }
    
    Rstats::Values::Double* get_double_values() {
      return (Rstats::Values::Double*)this->values;
    }
    
    Rstats::Values::Integer* get_integer_values() {
      return (Rstats::Values::Integer*)this->values;
    }
    
    Rstats::VectorType::Enum get_type() {
      return this->type;
    }
    
    void add_na_position (IV position) {
      this->na_positions[position] = 1;
    }

    bool exists_na_position (IV position) {
      return this->na_positions.count(position);
    }
    
    void merge_na_positions (Rstats::Vector* elements) {
      for(std::map<IV, IV>::iterator it = elements->na_positions.begin(); it != elements->na_positions.end(); ++it) {
        this->add_na_position(it->first);
      }
    }
    
    IV get_length () {
      if (this->values == NULL) {
        return 0;
      }
      else if (this->is_character()) {
        return this->get_character_values()->size();
      }
      else if (this->is_complex()) {
        return this->get_complex_values()->size();
      }
      else if (this->is_double()) {
        return this->get_double_values()->size();
      }
      else if (this->is_integer() || this->is_logical()) {
        return this->get_integer_values()->size();
      }
    }

    static Rstats::Vector* new_character(IV length, SV* sv_str) {

      Rstats::Vector* elements = Rstats::Vector::new_character(length);
      for (IV i = 0; i < length; i++) {
        elements->set_character_value(i, sv_str);
      }
      elements->type = Rstats::VectorType::CHARACTER;
      
      return elements;
    }

    static Rstats::Vector* new_character(IV length) {

      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new Rstats::Values::Character(length);
      elements->type = Rstats::VectorType::CHARACTER;
      
      return elements;
    }

    SV* get_character_value(IV pos) {
      SV* value = (*this->get_character_values())[pos];
      if (value == NULL) {
        return NULL;
      }
      else {
        return Rstats::PerlAPI::new_mSVsv(value);
      }
    }
    
    void set_character_value(IV pos, SV* value) {
      if (value != NULL) {
        SvREFCNT_dec((*this->get_character_values())[pos]);
      }
      
      SV* new_value = Rstats::PerlAPI::new_mSVsv(value);
      (*this->get_character_values())[pos] = SvREFCNT_inc(new_value);
    }

    static Rstats::Vector* new_complex(IV length) {
      
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new Rstats::Values::Complex(length, std::complex<NV>(0, 0));
      elements->type = Rstats::VectorType::COMPLEX;
      
      return elements;
    }
        
    static Rstats::Vector* new_complex(IV length, std::complex<NV> z) {
      
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new Rstats::Values::Complex(length, z);
      elements->type = Rstats::VectorType::COMPLEX;
      
      return elements;
    }

    std::complex<NV> get_complex_value(IV pos) {
      return (*this->get_complex_values())[pos];
    }
    
    void set_complex_value(IV pos, std::complex<NV> value) {
      (*this->get_complex_values())[pos] = value;
    }
    
    static Rstats::Vector* new_double(IV length) {
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new Rstats::Values::Double(length);
      elements->type = Rstats::VectorType::DOUBLE;
      
      return elements;
    }

    static Rstats::Vector* new_double(IV length, NV value) {
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new Rstats::Values::Double(length, value);
      elements->type = Rstats::VectorType::DOUBLE;
      
      return elements;
    }
    
    NV get_double_value(IV pos) {
      return (*this->get_double_values())[pos];
    }
    
    void set_double_value(IV pos, NV value) {
      (*this->get_double_values())[pos] = value;
    }

    static Rstats::Vector* new_integer(IV length) {
      
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new Rstats::Values::Integer(length);
      elements->type = Rstats::VectorType::INTEGER;
      
      return elements;
    }

    static Rstats::Vector* new_integer(IV length, IV value) {
      
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new Rstats::Values::Integer(length, value);
      elements->type = Rstats::VectorType::INTEGER;
      
      return elements;
    }

    IV get_integer_value(IV pos) {
      return (*this->get_integer_values())[pos];
    }
    
    void set_integer_value(IV pos, IV value) {
      (*this->get_integer_values())[pos] = value;
    }
    
    static Rstats::Vector* new_logical(IV length) {
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new Rstats::Values::Integer(length);
      elements->type = Rstats::VectorType::LOGICAL;
      
      return elements;
    }

    static Rstats::Vector* new_logical(IV length, IV value) {
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new Rstats::Values::Integer(length, value);
      elements->type = Rstats::VectorType::LOGICAL;
      
      return elements;
    }
    
    static Rstats::Vector* new_true() {
      return new_logical(1, 1);
    }

    static Rstats::Vector* new_false() {
      return new_logical(1, 0);
    }
    
    static Rstats::Vector* new_nan() {
      return  Rstats::Vector::new_double(1, NAN);
    }

    static Rstats::Vector* new_negative_inf() {
      return Rstats::Vector::new_double(1, -(INFINITY));
    }
    
    static Rstats::Vector* new_inf() {
      return Rstats::Vector::new_double(1, INFINITY);
    }
    
    static Rstats::Vector* new_na() {
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = new Rstats::Values::Integer(1, 0);
      elements->type = Rstats::VectorType::LOGICAL;
      elements->add_na_position(0);
      
      return elements;
    }
    
    static Rstats::Vector* new_null() {
      Rstats::Vector* elements = new Rstats::Vector;
      elements->values = NULL;
      elements->type = Rstats::VectorType::LOGICAL;
      return elements;
    }

    Rstats::Vector* as (SV* sv_type) {
      Rstats::Vector* e2;
      if (SvOK(sv_type)) {
        if (sv_cmp(sv_type, Rstats::Util::SV_CHARACTER_TYPE_NAME) == 0) {
          e2 = this->as_character();
        }
        else if (sv_cmp(sv_type, Rstats::Util::SV_COMPLEX_TYPE_NAME) == 0) {
          e2 = this->as_complex();
        }
        else if (sv_cmp(sv_type, Rstats::Util::SV_DOUBLE_TYPE_NAME) == 0) {
          e2 = this->as_double();
        }
        else if (sv_cmp(sv_type, Rstats::Util::SV_NUMERIC_TYPE_NAME) == 0) {
          e2 = this->as_numeric();
        }
        else if (sv_cmp(sv_type, Rstats::Util::SV_INTEGER_TYPE_NAME) == 0) {
          e2 = this->as_integer();
        }
        else if (sv_cmp(sv_type, Rstats::Util::SV_LOGICAL_TYPE_NAME) == 0) {
          e2 = this->as_logical();
        }
        else {
          croak("Invalid mode is passed(Rstats::Vector::as())");
        }
      }
      else {
        croak("Invalid mode is passed(Rstats::Vector::as())");
      }
      
      return e2;
    }
    
    Rstats::Vector* as_character () {
      IV length = this->get_length();
      Rstats::Vector* e2 = new_character(length);
      if (this->is_character()) {
        for (IV i = 0; i < length; i++) {
          SV* sv_value = this->get_character_value(i);
          e2->set_character_value(i, sv_value);
        }
      }
      else if (this->is_complex()) {
        for (IV i = 0; i < length; i++) {
          std::complex<NV> z = this->get_complex_value(i);
          NV re = z.real();
          NV im = z.imag();
          
          SV* sv_re = Rstats::PerlAPI::new_mSVnv(re);
          SV* sv_im = Rstats::PerlAPI::new_mSVnv(im);
          SV* sv_str = Rstats::PerlAPI::new_mSVpv_nolen("");
          
          sv_catpv(sv_str, SvPV_nolen(sv_re));
          if (im >= 0) {
            sv_catpv(sv_str, "+");
          }
          sv_catpv(sv_str, SvPV_nolen(sv_im));
          sv_catpv(sv_str, "i");

          e2->set_character_value(i, sv_str);
        }
      }
      else if (this->is_double()) {
        for (IV i = 0; i < length; i++) {
          NV value = this->get_double_value(i);
          SV* sv_str = Rstats::PerlAPI::new_mSVpv_nolen("");
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
            sv_catpv(sv_str, SvPV_nolen(Rstats::PerlAPI::new_mSVnv(value)));
          }
          e2->set_character_value(i, sv_str);
        }
      }
      else if (this->is_integer()) {
        for (IV i = 0; i < length; i++) {
          e2->set_character_value(
            i,
            Rstats::PerlAPI::new_mSViv(this->get_integer_value(i))
          );
        }
      }
      else if (this->is_logical()) {
        for (IV i = 0; i < length; i++) {
          if (this->get_integer_value(i)) {
            e2->set_character_value(i, Rstats::PerlAPI::new_mSVpv_nolen("TRUE"));
          }
          else {
            e2->set_character_value(i, Rstats::PerlAPI::new_mSVpv_nolen("FALSE"));
          }
        }
      }
      else {
        croak("unexpected type");
      }

      e2->merge_na_positions(this);
      
      return e2;
    }
    
    Rstats::Vector* as_double() {

      IV length = this->get_length();
      Rstats::Vector* e2 = new_double(length);
      if (this->is_character()) {
        for (IV i = 0; i < length; i++) {
          SV* sv_value = this->get_character_value(i);
          SV* sv_value_fix = Rstats::Util::looks_like_double(sv_value);
          if (SvOK(sv_value_fix)) {
            NV value = SvNV(sv_value_fix);
            e2->set_double_value(i, value);
          }
          else {
            warn("NAs introduced by coercion");
            e2->add_na_position(i);
          }
        }
      }
      else if (this->is_complex()) {
        warn("imaginary parts discarded in coercion");
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, this->get_complex_value(i).real());
        }
      }
      else if (this->is_double()) {
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, this->get_double_value(i));
        }
      }
      else if (this->is_integer() || this->is_logical()) {
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, this->get_integer_value(i));
        }
      }
      else {
        croak("unexpected type");
      }

      e2->merge_na_positions(this);
      
      return e2;
    }

    Rstats::Vector* as_numeric() {
      return this->as_double();
    }

    Rstats::Vector* as_integer() {

      IV length = this->get_length();
      Rstats::Vector* e2 = new_integer(length);
      if (this->is_character()) {
        for (IV i = 0; i < length; i++) {
          SV* sv_value = this->get_character_value(i);
          SV* sv_value_fix = Rstats::Util::looks_like_double(sv_value);
          if (SvOK(sv_value_fix)) {
            IV value = SvIV(sv_value_fix);
            e2->set_integer_value(i, value);
          }
          else {
            warn("NAs introduced by coercion");
            e2->add_na_position(i);
          }
        }
      }
      else if (this->is_complex()) {
        warn("imaginary parts discarded in coercion");
        for (IV i = 0; i < length; i++) {
          e2->set_integer_value(i, (IV)this->get_complex_value(i).real());
        }
      }
      else if (this->is_double()) {
        NV value;
        for (IV i = 0; i < length; i++) {
          value = this->get_double_value(i);
          if (std::isnan(value) || std::isinf(value)) {
            e2->add_na_position(i);
          }
          else {
            e2->set_integer_value(i, (IV)value);
          }
        }
      }
      else if (this->is_integer() || this->is_logical()) {
        for (IV i = 0; i < length; i++) {
          e2->set_integer_value(i, this->get_integer_value(i));
        }
      }
      else {
        croak("unexpected type");
      }

      e2->merge_na_positions(this);
      
      return e2;
    }

    Rstats::Vector* as_complex() {

      IV length = this->get_length();
      Rstats::Vector* e2 = new_complex(length);
      if (this->is_character()) {
        for (IV i = 0; i < length; i++) {
          SV* sv_value = this->get_character_value(i);
          SV* sv_z = Rstats::Util::looks_like_complex(sv_value);
          
          if (SvOK(sv_z)) {
            SV* sv_re = Rstats::PerlAPI::hvrv_fetch_simple(sv_z, "re");
            SV* sv_im = Rstats::PerlAPI::hvrv_fetch_simple(sv_z, "im");
            NV re = SvNV(sv_re);
            NV im = SvNV(sv_im);
            e2->set_complex_value(i, std::complex<NV>(re, im));
          }
          else {
            warn("NAs introduced by coercion");
            e2->add_na_position(i);
          }
        }
      }
      else if (this->is_complex()) {
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, this->get_complex_value(i));
        }
      }
      else if (this->is_double()) {
        for (IV i = 0; i < length; i++) {
          NV value = this->get_double_value(i);
          if (std::isnan(value)) {
            e2->add_na_position(i);
          }
          else {
            e2->set_complex_value(i, std::complex<NV>(this->get_double_value(i), 0));
          }
        }
      }
      else if (this->is_integer() || this->is_logical()) {
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, std::complex<NV>(this->get_integer_value(i), 0));
        }
      }
      else {
        croak("unexpected type");
      }

      e2->merge_na_positions(this);
      
      return e2;
    }
    
    Rstats::Vector* as_logical() {
      IV length = this->get_length();
      Rstats::Vector* e2 = new_logical(length);
      if (this->is_character()) {
        for (IV i = 0; i < length; i++) {
          SV* sv_value = this->get_character_value(i);
          SV* sv_logical = Rstats::Util::looks_like_logical(sv_value);
          if (SvOK(sv_logical)) {
            if (SvTRUE(sv_logical)) {
              e2->set_integer_value(i, 1);
            }
            else {
              e2->set_integer_value(i, 0);
            }
          }
          else {
            warn("NAs introduced by coercion");
            e2->add_na_position(i);
          }
        }
      }
      else if (this->is_complex()) {
        warn("imaginary parts discarded in coercion");
        for (IV i = 0; i < length; i++) {
          e2->set_integer_value(i, (IV)this->get_complex_value(i).real());
        }
      }
      else if (this->is_double()) {
        for (IV i = 0; i < length; i++) {
          NV value = this->get_double_value(i);
          if (std::isnan(value)) {
            e2->add_na_position(i);
          }
          else if (std::isinf(value)) {
            e2->set_integer_value(i, 1);
          }
          else {
            e2->set_integer_value(i, (IV)value);
          }
        }
      }
      else if (this->is_integer() || this->is_logical()) {
        for (IV i = 0; i < length; i++) {
          e2->set_integer_value(i, this->get_integer_value(i));
        }
      }
      else {
        croak("unexpected type");
      }

      e2->merge_na_positions(this);
      
      return e2;
    }
  };

  // Rstats::VectorFunc
  namespace VectorFunc {

    Rstats::Vector* And(Rstats::Vector* e1, Rstats::Vector* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't compare different type(Rstats::VectorFunc::And())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't compare different length(Rstats::VectorFunc::And())");
      }
      
      IV length = e1->get_length();
      Rstats::Vector* e3 = Rstats::Vector::new_logical(length);
      
      Rstats::Vector* e1_fix = NULL;
      Rstats::Vector* e2_fix = NULL;
      
      if (!e1->is_logical()) {
        e1_fix = e1->as_logical();
        e1 = e1_fix;
      }
      
      if (!e2->is_logical()) {
        e2_fix = e2->as_logical();
        e2 = e2_fix;
      }
      
      for (IV i = 0; i < length; i++) {
        e3->set_integer_value(i, e1->get_integer_value(i) && e2->get_integer_value(i));
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      if (e1_fix != NULL) {
        delete e1_fix;
      }
      
      if (e2_fix != NULL) {
        delete e2_fix;
      }
      
      return e3;
    }
    
    Rstats::Vector* Or(Rstats::Vector* e1, Rstats::Vector* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't compare different type(Rstats::VectorFunc::Or())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't compare different length(Rstats::VectorFunc::Or())");
      }
      
      IV length = e1->get_length();
      Rstats::Vector* e3 = Rstats::Vector::new_logical(length);
      
      Rstats::Vector* e1_fix = NULL;
      Rstats::Vector* e2_fix = NULL;
      
      if (!e1->is_logical()) {
        e1_fix = e1->as_logical();
        e1 = e1_fix;
      }
      
      if (!e2->is_logical()) {
        e2_fix = e2->as_logical();
        e2 = e2_fix;
      }
      
      for (IV i = 0; i < length; i++) {
        e3->set_integer_value(i, e1->get_integer_value(i) || e2->get_integer_value(i));
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      if (e1_fix != NULL) {
        delete e1_fix;
      }
      
      if (e2_fix != NULL) {
        delete e2_fix;
      }
      
      return e3;
    }
    
    Rstats::Vector* Conj (Rstats::Vector* e1) {
      IV length = e1->get_length();
      Rstats::Vector* e2 = Rstats::Vector::new_double(length);
      if (e1->is_character()) {
        croak("Error : non-numeric argument to function(Rstats::VectorFunc::Re())");
      }
      else if (e1->is_complex()) {
        e2 = Rstats::Vector::new_complex(length);
        for (IV i = 0; i < length; i++) {
          std::complex<NV> e1_value = e1->get_complex_value(i);
          std::complex<NV> e2_value(e1_value.real(), -e1_value.imag());
          e2->set_complex_value(i, e2_value);
        }
      }
      else if (e1->is_double()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, e1->get_double_value(i));
        }
      }
      else if (e1->is_integer()) {
        e2 = Rstats::Vector::new_integer(length);
        for (IV i = 0; i < length; i++) {
          e2->set_integer_value(i, e1->get_integer_value(i));
        }
      }
      else if (e1->is_logical()) {
        e2 = Rstats::Vector::new_logical(length);
        for (IV i = 0; i < length; i++) {
          e2->set_integer_value(i, e1->get_integer_value(i));
        }
      }
      else {
        croak("unexpected type");
      }

      e2->merge_na_positions(e1);
      
      return e2;
    }
    
    Rstats::Vector* Re (Rstats::Vector* e1) {
      IV length = e1->get_length();
      Rstats::Vector* e2 = Rstats::Vector::new_double(length);
      if (e1->is_character()) {
        croak("Error : non-numeric argument to function(Rstats::VectorFunc::Re())");
      }
      else if (e1->is_complex()) {
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, e1->get_complex_value(i).real());
        }
      }
      else if (e1->is_double()) {
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, e1->get_double_value(i));
        }
      }
      else if (e1->is_integer() || e1->is_logical()) {
        for (IV i = 0; i < length; i++) {
          e2->set_integer_value(i, e1->get_integer_value(i));
        }
      }
      else {
        croak("unexpected type");
      }

      e2->merge_na_positions(e1);
      
      return e2;
    }
    
    Rstats::Vector* Im (Rstats::Vector* e1) {
      IV length = e1->get_length();
      Rstats::Vector* e2 = Rstats::Vector::new_double(length);
      if (e1->is_character()) {
        croak("Error : non-numeric argument to function(Rstats::VectorFunc::Im())");
      }
      else if (e1->is_complex()) {
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, e1->get_complex_value(i).imag());
        }
      }
      else if (e1->is_double()) {
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, 0);
        }
      }
      else if (e1->is_integer() || e1->is_logical()) {
        for (IV i = 0; i < length; i++) {
          e2->set_integer_value(i, 0);
        }
      }
      else {
        croak("unexpected type");
      }

      e2->merge_na_positions(e1);
      
      return e2;
    }
    
    Rstats::Vector* less_than_or_equal(Rstats::Vector* e1, Rstats::Vector* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't compare different type(Rstats::VectorFunc::less_than_or_equal())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't compare different length(Rstats::VectorFunc::less_than_or_equal())");
      }
      
      IV length = e1->get_length();
      Rstats::Vector* e3 = Rstats::Vector::new_logical(length);
      if (e1->is_character()) {
        for (IV i = 0; i < length; i++) {
          if (sv_cmp(e1->get_character_value(i), e2->get_character_value(i)) <= 0) {
            e3->set_integer_value(i, 1);
          }
          else {
            e3->set_integer_value(i, 0);
          }
        }
      }
      else if (e1->is_complex()) {
        croak("invalid comparison with complex values(Rstats::VectorFunc::less_than_or_equal())");
      }
      else if (e1->is_double()) {
        for (IV i = 0; i < length; i++) {
          NV value1 = e1->get_double_value(i);
          NV value2 = e2->get_double_value(i);
          if (std::isnan(value1) || std::isnan(value2)) {
            e3->add_na_position(i);
          }
          else {
            if (e1->get_double_value(i) <= e2->get_double_value(i)) {
              e3->set_integer_value(i, 1);
            }
            else {
              e3->set_integer_value(i, 0);
            }
          }
        }
      }
      else if (e1->is_integer() || e1->is_logical()) {
        for (IV i = 0; i < length; i++) {
          if (e1->get_integer_value(i) <= e2->get_integer_value(i)) {
            e3->set_integer_value(i, 1);
          }
          else {
            e3->set_integer_value(i, 0);
          }
        }
      }
      else {
        croak("Invalid type");
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      return e3;
    }
    
    Rstats::Vector* more_than_or_equal(Rstats::Vector* e1, Rstats::Vector* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't compare different type(Rstats::VectorFunc::more_than_or_equal())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't compare different length(Rstats::VectorFunc::more_than_or_equal())");
      }
      
      IV length = e1->get_length();
      Rstats::Vector* e3 = Rstats::Vector::new_logical(length);
      if (e1->is_character()) {
        for (IV i = 0; i < length; i++) {
          if (sv_cmp(e1->get_character_value(i), e2->get_character_value(i)) >= 0) {
            e3->set_integer_value(i, 1);
          }
          else {
            e3->set_integer_value(i, 0);
          }
        }
      }
      else if (e1->is_complex()) {
        croak("invalid comparison with complex values(Rstats::VectorFunc::more_than_or_equal())");
      }
      else if (e1->is_double()) {
        for (IV i = 0; i < length; i++) {
          NV value1 = e1->get_double_value(i);
          NV value2 = e2->get_double_value(i);
          if (std::isnan(value1) || std::isnan(value2)) {
            e3->add_na_position(i);
          }
          else {
            if (e1->get_double_value(i) >= e2->get_double_value(i)) {
              e3->set_integer_value(i, 1);
            }
            else {
              e3->set_integer_value(i, 0);
            }
          }
        }
      }
      else if (e1->is_integer() || e1->is_logical()) {
        for (IV i = 0; i < length; i++) {
          if (e1->get_integer_value(i) >= e2->get_integer_value(i)) {
            e3->set_integer_value(i, 1);
          }
          else {
            e3->set_integer_value(i, 0);
          }
        }
      }
      else {
        croak("Invalid type");
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      return e3;
    }
    
    Rstats::Vector* less_than(Rstats::Vector* e1, Rstats::Vector* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't compare different type(Rstats::VectorFunc::less_than())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't compare different length(Rstats::VectorFunc::less_than())");
      }
      
      IV length = e1->get_length();
      Rstats::Vector* e3 = Rstats::Vector::new_logical(length);
      if (e1->is_character()) {
        for (IV i = 0; i < length; i++) {
          if (sv_cmp(e1->get_character_value(i), e2->get_character_value(i)) < 0) {
            e3->set_integer_value(i, 1);
          }
          else {
            e3->set_integer_value(i, 0);
          }
        }
      }
      else if (e1->is_complex()) {
        croak("invalid comparison with complex values(Rstats::VectorFunc::less_than())");
      }
      else if (e1->is_double()) {
        for (IV i = 0; i < length; i++) {
          NV value1 = e1->get_double_value(i);
          NV value2 = e2->get_double_value(i);
          if (std::isnan(value1) || std::isnan(value2)) {
            e3->add_na_position(i);
          }
          else {
            if (e1->get_double_value(i) < e2->get_double_value(i)) {
              e3->set_integer_value(i, 1);
            }
            else {
              e3->set_integer_value(i, 0);
            }
          }
        }
      }
      else if (e1->is_integer() || e1->is_logical()) {
        for (IV i = 0; i < length; i++) {
          if (e1->get_integer_value(i) < e2->get_integer_value(i)) {
            e3->set_integer_value(i, 1);
          }
          else {
            e3->set_integer_value(i, 0);
          }
        }
      }
      else {
        croak("Invalid type");
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      return e3;
    }
    
    Rstats::Vector* more_than(Rstats::Vector* e1, Rstats::Vector* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't compare different type(Rstats::VectorFunc::more_than())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't compare different length(Rstats::VectorFunc::more_than())");
      }
      
      IV length = e1->get_length();
      Rstats::Vector* e3 = Rstats::Vector::new_logical(length);
      if (e1->is_character()) {
        for (IV i = 0; i < length; i++) {
          if (sv_cmp(e1->get_character_value(i), e2->get_character_value(i)) > 0) {
            e3->set_integer_value(i, 1);
          }
          else {
            e3->set_integer_value(i, 0);
          }
        }
      }
      else if (e1->is_complex()) {
        croak("invalid comparison with complex values(Rstats::VectorFunc::more_than())");
      }
      else if (e1->is_double()) {
        for (IV i = 0; i < length; i++) {
          NV value1 = e1->get_double_value(i);
          NV value2 = e2->get_double_value(i);
          if (std::isnan(value1) || std::isnan(value2)) {
            e3->add_na_position(i);
          }
          else {
            if (e1->get_double_value(i) > e2->get_double_value(i)) {
              e3->set_integer_value(i, 1);
            }
            else {
              e3->set_integer_value(i, 0);
            }
          }
        }
      }
      else if (e1->is_integer() || e1->is_logical()) {
        for (IV i = 0; i < length; i++) {
          if (e1->get_integer_value(i) > e2->get_integer_value(i)) {
            e3->set_integer_value(i, 1);
          }
          else {
            e3->set_integer_value(i, 0);
          }
        }
      }
      else {
        croak("Invalid type");
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      return e3;
    }
    
    Rstats::Vector* not_equal(Rstats::Vector* e1, Rstats::Vector* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't compare different type(Rstats::VectorFunc::not_equal())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't compare different length(Rstats::VectorFunc::not_equal())");
      }
      
      IV length = e1->get_length();
      Rstats::Vector* e3 = Rstats::Vector::new_logical(length);
      if (e1->is_character()) {
        for (IV i = 0; i < length; i++) {
          if (sv_cmp(e1->get_character_value(i), e2->get_character_value(i)) != 0) {
            e3->set_integer_value(i, 1);
          }
          else {
            e3->set_integer_value(i, 0);
          }
        }
      }
      else if (e1->is_complex()) {
        for (IV i = 0; i < length; i++) {
          if (e1->get_complex_value(i) != e2->get_complex_value(i)) {
            e3->set_integer_value(i, 1);
          }
          else {
            e3->set_integer_value(i, 0);
          }
        }
      }
      else if (e1->is_double()) {
        for (IV i = 0; i < length; i++) {
          NV value1 = e1->get_double_value(i);
          NV value2 = e2->get_double_value(i);
          if (std::isnan(value1) || std::isnan(value2)) {
            e3->add_na_position(i);
          }
          else {
            if (e1->get_double_value(i) != e2->get_double_value(i)) {
              e3->set_integer_value(i, 1);
            }
            else {
              e3->set_integer_value(i, 0);
            }
          }
        }
      }
      else if (e1->is_integer() || e1->is_logical()) {
        for (IV i = 0; i < length; i++) {
          if (e1->get_integer_value(i) != e2->get_integer_value(i)) {
            e3->set_integer_value(i, 1);
          }
          else {
            e3->set_integer_value(i, 0);
          }
        }
      }
      else {
        croak("Invalid type");
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      return e3;
    }
    
    Rstats::Vector* equal(Rstats::Vector* e1, Rstats::Vector* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't compare different type(Rstats::VectorFunc::equal())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't compare different length(Rstats::VectorFunc::equal())");
      }
      
      IV length = e1->get_length();
      Rstats::Vector* e3 = Rstats::Vector::new_logical(length);
      if (e1->is_character()) {
        for (IV i = 0; i < length; i++) {
          if (sv_cmp(e1->get_character_value(i), e2->get_character_value(i)) == 0) {
            e3->set_integer_value(i, 1);
          }
          else {
            e3->set_integer_value(i, 0);
          }
        }
      }
      else if (e1->is_complex()) {
        for (IV i = 0; i < length; i++) {
          if (e1->get_complex_value(i) == e2->get_complex_value(i)) {
            e3->set_integer_value(i, 1);
          }
          else {
            e3->set_integer_value(i, 0);
          }
        }
      }
      else if (e1->is_double()) {
        for (IV i = 0; i < length; i++) {
          NV value1 = e1->get_double_value(i);
          NV value2 = e2->get_double_value(i);
          if (std::isnan(value1) || std::isnan(value2)) {
            e3->add_na_position(i);
          }
          else {
            if (e1->get_double_value(i) == e2->get_double_value(i)) {
              e3->set_integer_value(i, 1);
            }
            else {
              e3->set_integer_value(i, 0);
            }
          }
        }
      }
      else if (e1->is_integer() || e1->is_logical()) {
        for (IV i = 0; i < length; i++) {
          if (e1->get_integer_value(i) == e2->get_integer_value(i)) {
            e3->set_integer_value(i, 1);
          }
          else {
            e3->set_integer_value(i, 0);
          }
        }
      }
      else {
        croak("Invalid type");
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      return e3;
    }

    Rstats::Vector* add(Rstats::Vector* e1, Rstats::Vector* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't add different type(Rstats::VectorFunc::add())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't add different length(Rstats::VectorFunc::add())");
      }
      
      IV length = e1->get_length();
      Rstats::Vector* e3;
      if (e1->is_character()) {
        croak("Error in a + b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex()) {
        e3 = Rstats::Vector::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e3->set_complex_value(i, e1->get_complex_value(i) + e2->get_complex_value(i));
        }
      }
      else if (e1->is_double()) {
        e3 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, e1->get_double_value(i) + e2->get_double_value(i));
        }
      }
      else if (e1->is_integer()) {
        e3 = Rstats::Vector::new_integer(length);
        for (IV i = 0; i < length; i++) {
          e3->set_integer_value(i, e1->get_integer_value(i) + e2->get_integer_value(i));
        }
      }
      else if (e1->is_logical()) {
        e3 = Rstats::Vector::new_logical(length);
        for (IV i = 0; i < length; i++) {
          e3->set_integer_value(i, e1->get_integer_value(i) + e2->get_integer_value(i));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      return e3;
    }

    Rstats::Vector* subtract(Rstats::Vector* e1, Rstats::Vector* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't subtract different type(Rstats::VectorFunc::subtract())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't subtract different length(Rstats::VectorFunc::subtract())");
      }
      
      IV length = e1->get_length();
      Rstats::Vector* e3;
      if (e1->is_character()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex()) {
        e3 = Rstats::Vector::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e3->set_complex_value(i, e1->get_complex_value(i) - e2->get_complex_value(i));
        }
      }
      else if (e1->is_double()) {
        e3 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, e1->get_double_value(i) - e2->get_double_value(i));
        }
      }
      else if (e1->is_integer()) {
        e3 = Rstats::Vector::new_integer(length);
        for (IV i = 0; i < length; i++) {
          e3->set_integer_value(i, e1->get_integer_value(i) - e2->get_integer_value(i));
        }
      }
      else if (e1->is_logical()) {
        e3 = Rstats::Vector::new_logical(length);
        for (IV i = 0; i < length; i++) {
          e3->set_integer_value(i, e1->get_integer_value(i) - e2->get_integer_value(i));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      return e3;
    }

    Rstats::Vector* multiply(Rstats::Vector* e1, Rstats::Vector* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't multiply different type(Rstats::VectorFunc::multiply())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't multiply different length(Rstats::VectorFunc::multiply())");
      }
      
      IV length = e1->get_length();
      Rstats::Vector* e3;
      if (e1->is_character()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex()) {
        e3 = Rstats::Vector::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e3->set_complex_value(i, e1->get_complex_value(i) * e2->get_complex_value(i));
        }
      }
      else if (e1->is_double()) {
        e3 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, e1->get_double_value(i) * e2->get_double_value(i));
        }
      }
      else if (e1->is_integer()) {
        e3 = Rstats::Vector::new_integer(length);
        for (IV i = 0; i < length; i++) {
          e3->set_integer_value(i, e1->get_integer_value(i) * e2->get_integer_value(i));
        }
      }
      else if (e1->is_logical()) {
        e3 = Rstats::Vector::new_logical(length);
        for (IV i = 0; i < length; i++) {
          e3->set_integer_value(i, e1->get_integer_value(i) * e2->get_integer_value(i));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      return e3;
    }

    Rstats::Vector* divide(Rstats::Vector* e1, Rstats::Vector* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't divide different type(Rstats::VectorFunc::multiply())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't divide different length(Rstats::VectorFunc::multiply())");
      }
      
      IV length = e1->get_length();
      Rstats::Vector* e3;
      if (e1->is_character()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex()) {
        e3 = Rstats::Vector::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e3->set_complex_value(i, e1->get_complex_value(i) / e2->get_complex_value(i));
        }
      }
      else if (e1->is_double()) {
        e3 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, e1->get_double_value(i) / e2->get_double_value(i));
        }
      }
      else if (e1->is_integer()) {
        e3 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, e1->get_integer_value(i) / e2->get_integer_value(i));
        }
      }
      else if (e1->is_logical()) {
        e3 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, e1->get_integer_value(i) / e2->get_integer_value(i));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      return e3;
    }

    Rstats::Vector* pow(Rstats::Vector* e1, Rstats::Vector* e2) {
      
      if (e1->get_type() != e2->get_type()) {
        croak("Can't pow different type(Rstats::VectorFunc::multiply())");
      }
      
      if (e1->get_length() != e2->get_length()) {
        croak("Can't pow different length(Rstats::VectorFunc::multiply())");
      }
      
      IV length = e1->get_length();
      Rstats::Vector* e3;
      if (e1->is_character()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex()) {
        e3 = Rstats::Vector::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e3->set_complex_value(i, std::pow(e1->get_complex_value(i), e2->get_complex_value(i)));
        }
      }
      else if (e1->is_double()) {
        e3 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, ::pow(e1->get_double_value(i), e2->get_double_value(i)));
        }
      }
      else if (e1->is_integer()) {
        e3 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, ::pow(e1->get_integer_value(i), e2->get_integer_value(i)));
        }
      }
      else if (e1->is_logical()) {
        e3 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e3->set_double_value(i, ::pow(e1->get_integer_value(i), e2->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e3->merge_na_positions(e1);
      e3->merge_na_positions(e2);
      
      return e3;
    }

    Rstats::Vector* sqrt(Rstats::Vector* e1) {
      
      IV length = e1->get_length();
      Rstats::Vector* e2;
      if (e1->is_character()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex()) {
        e2 = Rstats::Vector::new_complex(length);
        std::complex<NV> value;
        for (IV i = 0; i < length; i++) {
          value = e1->get_complex_value(i);
          
          // Fix bug that clang sqrt can't right value of perfect squeres
          if (value.imag() == 0 && value.real() < 0) {
            e2->set_complex_value(
              i,
              std::complex<NV>(
                0,
                std::sqrt(-(value.real()))
              )
            );
          }
          else {
            e2->set_complex_value(i, std::sqrt(value));
          }
        }
      }
      else if (e1->is_double()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sqrt(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sqrt(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sqrt(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Vector* sin(Rstats::Vector* e1) {
      
      IV length = e1->get_length();
      Rstats::Vector* e2;
      if (e1->is_character()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex()) {
        e2 = Rstats::Vector::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, std::sin(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sin(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sin(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sin(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }
    
    Rstats::Vector* cos(Rstats::Vector* e1) {
      
      IV length = e1->get_length();
      Rstats::Vector* e2;
      if (e1->is_character()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex()) {
        e2 = Rstats::Vector::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, std::cos(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::cos(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::cos(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::cos(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Vector* tan(Rstats::Vector* e1) {
      
      IV length = e1->get_length();
      Rstats::Vector* e2;
      if (e1->is_character()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex()) {
        e2 = Rstats::Vector::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, std::tan(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::tan(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::tan(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::tan(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Vector* sinh(Rstats::Vector* e1) {
      
      IV length = e1->get_length();
      Rstats::Vector* e2;
      if (e1->is_character()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex()) {
        e2 = Rstats::Vector::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, std::sinh(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sinh(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sinh(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::sinh(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }
    
    Rstats::Vector* cosh(Rstats::Vector* e1) {
      
      IV length = e1->get_length();
      Rstats::Vector* e2;
      if (e1->is_character()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex()) {
        e2 = Rstats::Vector::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, std::cosh(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::cosh(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::cosh(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::cosh(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Vector* tanh(Rstats::Vector* e1) {
      
      IV length = e1->get_length();
      Rstats::Vector* e2;
      if (e1->is_character()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex()) {
        e2 = Rstats::Vector::new_complex(length);
        NV e1_value_re;
        for (IV i = 0; i < length; i++) {
          e1_value_re = e1->get_complex_value(i).real();
          
          // For fix FreeBSD bug
          // FreeBAD return (NaN + NaNi) when real value is negative infinite
          if (std::isinf(e1_value_re) && e1_value_re < 0) {
            e2->set_complex_value(i, std::complex<NV>(-1, 0));
          }
          else {
            e2->set_complex_value(i, std::tanh(e1->get_complex_value(i)));
          }
        }
      }
      else if (e1->is_double()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::tanh(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::tanh(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::tanh(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Vector* abs(Rstats::Vector* e1) {
      
      IV length = e1->get_length();
      Rstats::Vector* e2;
      if (e1->is_character()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::abs(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::abs(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer()) {
        e2 = Rstats::Vector::new_integer(length);
        for (IV i = 0; i < length; i++) {
          e2->set_integer_value(i, (IV)std::abs((NV)e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical()) {
        e2 = Rstats::Vector::new_logical(length);
        for (IV i = 0; i < length; i++) {
          e2->set_integer_value(i, (IV)std::abs((NV)e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }
    
    Rstats::Vector* log(Rstats::Vector* e1) {
      
      IV length = e1->get_length();
      Rstats::Vector* e2;
      if (e1->is_character()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex()) {
        e2 = Rstats::Vector::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, std::log(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::log(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::log(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::log(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Vector* logb(Rstats::Vector* e1) {
      return log(e1);
    }
    
    Rstats::Vector* log10(Rstats::Vector* e1) {
      
      IV length = e1->get_length();
      Rstats::Vector* e2;
      if (e1->is_character()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex()) {
        e2 = Rstats::Vector::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, std::log10(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::log10(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::log10(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::log10(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Vector* log2(Rstats::Vector* e1) {
      
      IV length = e1->get_length();
      Rstats::Vector* e2;
      if (e1->is_character()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex()) {
        e2 = divide(log(e1), log(Rstats::Vector::new_complex(length, std::complex<NV>(2, 0))));
      }
      else if (e1->is_double() || e1->is_integer() || e1->is_logical()) {
        e2 = divide(log(e1), log(Rstats::Vector::new_double(length, 2)));
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Vector* exp(Rstats::Vector* e1) {
      
      IV length = e1->get_length();
      Rstats::Vector* e2;
      if (e1->is_character()) {
        croak("Error in a - b : non-numeric argument to binary operator");
      }
      else if (e1->is_complex()) {
        e2 = Rstats::Vector::new_complex(length);
        for (IV i = 0; i < length; i++) {
          e2->set_complex_value(i, std::exp(e1->get_complex_value(i)));
        }
      }
      else if (e1->is_double()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::exp(e1->get_double_value(i)));
        }
      }
      else if (e1->is_integer()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::exp(e1->get_integer_value(i)));
        }
      }
      else if (e1->is_logical()) {
        e2 = Rstats::Vector::new_double(length);
        for (IV i = 0; i < length; i++) {
          e2->set_double_value(i, std::exp(e1->get_integer_value(i)));
        }
      }
      else {
        croak("Invalid type");
      }
      
      e2->merge_na_positions(e1);
      
      return e2;
    }

    Rstats::Vector* is_infinite(Rstats::Vector* elements) {
      
      IV length = elements->get_length();
      Rstats::Vector* rets;
      if (elements->get_type() == Rstats::VectorType::DOUBLE) {
        rets = Rstats::Vector::new_logical(length);
        Rstats::Values::Double* values = elements->get_double_values();
        Rstats::Values::Integer* rets_values = rets->get_integer_values();
        for (IV i = 0; i < length; i++) {
          if(std::isinf((*values)[i])) {
            (*rets_values)[i] = 1;
          }
          else {
            (*rets_values)[i] = 0;
          }
        }
      }
      else {
        rets = Rstats::Vector::new_logical(length, 0);
      }
      
      return rets;
    }

    Rstats::Vector* is_nan(Rstats::Vector* elements) {
      IV length = elements->get_length();
      Rstats::Vector* rets = Rstats::Vector::new_logical(length);
      if (elements->get_type() == Rstats::VectorType::DOUBLE) {
        Rstats::Values::Double* values = elements->get_double_values();
        Rstats::Values::Integer* rets_values = rets->get_integer_values();
        for (IV i = 0; i < length; i++) {
          if(std::isnan((*values)[i])) {
            (*rets_values)[i] = 1;
          }
          else {
            (*rets_values)[i] = 0;
          }
        }
      }
      else {
        rets = Rstats::Vector::new_logical(length, 0);
      }
      
      return rets;
    }

    Rstats::Vector* is_finite(Rstats::Vector* elements) {
      
      IV length = elements->get_length();
      Rstats::Vector* rets;
      if (elements->is_integer()) {
        rets = Rstats::Vector::new_logical(length, 1);
      }
      else if (elements->is_double()) {
        Rstats::Values::Double* values = elements->get_double_values();
        rets = Rstats::Vector::new_logical(length);
        Rstats::Values::Integer* rets_values = rets->get_integer_values();
        for (IV i = 0; i < length; i++) {
          if (std::isfinite((*values)[i])) {
            (*rets_values)[i] = 1;
          }
          else {
            (*rets_values)[i] = 0;
          }
        }
      }
      else {
        rets = Rstats::Vector::new_logical(length, 0);
      }
      
      return rets;
    }
  }
  
  // Rstats::Util body
  namespace Util {
    REGEXP* LOGICAL_RE = pregcomp(newSVpv("^ *(T|TRUE|F|FALSE) *$", 0), 0);
    REGEXP* LOGICAL_TRUE_RE = pregcomp(newSVpv("T", 0), 0);
    REGEXP* INTEGER_RE = pregcomp(newSVpv("^ *([\\-\\+]?[0-9]+) *$", 0), 0);
    REGEXP* DOUBLE_RE = pregcomp(newSVpv("^ *([\\-\\+]?[0-9]+(?:\\.[0-9]+)?) *$", 0), 0);
    REGEXP* COMPLEX_IMAGE_ONLY_RE = pregcomp(newSVpv("^ *([\\+\\-]?[0-9]+(?:\\.[0-9]+)?)i *$", 0), 0);
    REGEXP* COMPLEX_RE = pregcomp(newSVpv("^ *([\\+\\-]?[0-9]+(?:\\.[0-9]+)?)(?:([\\+\\-][0-9]+(?:\\.[0-9]+)?)i)? *$", 0), 0);
    
    SV* looks_like_complex (SV* sv_value) {
      
      SV* sv_ret;
      if (!SvOK(sv_value) || sv_len(sv_value) == 0) {
        sv_ret = &PL_sv_undef;
      }
      else {
        SV* sv_re;
        SV* sv_im;
        if (Rstats::PerlAPI::pregexec_simple(sv_value, COMPLEX_IMAGE_ONLY_RE)) {
          sv_re = Rstats::PerlAPI::new_mSVnv(0);
          SV* sv_im_str = Rstats::PerlAPI::new_mSVpv_nolen("");
          Perl_reg_numbered_buff_fetch(aTHX_ COMPLEX_IMAGE_ONLY_RE, 1, sv_im_str);
          sv_im = Rstats::PerlAPI::new_mSVnv(SvNV(sv_im_str));
          
          sv_ret = Rstats::PerlAPI::new_mHVRV();
          Rstats::PerlAPI::hvrv_store_nolen_inc(sv_ret, "re", sv_re);
          Rstats::PerlAPI::hvrv_store_nolen_inc(sv_ret, "im", sv_im);
        }
        else if(Rstats::PerlAPI::pregexec_simple(sv_value, COMPLEX_RE)) {
          SV* sv_re_str = Rstats::PerlAPI::new_mSVpv_nolen("");
          Perl_reg_numbered_buff_fetch(aTHX_ COMPLEX_RE, 1, sv_re_str);
          sv_re = Rstats::PerlAPI::new_mSVnv(SvNV(sv_re_str));

          SV* sv_im_str = Rstats::PerlAPI::new_mSVpv_nolen("");
          Perl_reg_numbered_buff_fetch(aTHX_ COMPLEX_RE, 2, sv_im_str);
          if (SvOK(sv_im_str)) {
            sv_im = Rstats::PerlAPI::new_mSVnv(SvNV(sv_im_str));
          }
          else {
            sv_im = Rstats::PerlAPI::new_mSVnv(0);
          }

          sv_ret = Rstats::PerlAPI::new_mHVRV();
          Rstats::PerlAPI::hvrv_store_nolen_inc(sv_ret, "re", sv_re);
          Rstats::PerlAPI::hvrv_store_nolen_inc(sv_ret, "im", sv_im);
        }
        else {
          sv_ret = &PL_sv_undef;
        }
      }
      
      return sv_ret;
    }
    
    SV* looks_like_logical (SV* sv_value) {
      
      SV* sv_ret;
      if (!SvOK(sv_value) || sv_len(sv_value) == 0) {
        sv_ret = &PL_sv_undef;
      }
      else {
        if (Rstats::PerlAPI::pregexec_simple(sv_value, LOGICAL_RE)) {
          if (Rstats::PerlAPI::pregexec_simple(sv_value, LOGICAL_TRUE_RE)) {
            sv_ret = Rstats::PerlAPI::new_mSViv(1);
          }
          else {
            sv_ret = Rstats::PerlAPI::new_mSViv(0);
          }
        }
        else {
          sv_ret = &PL_sv_undef;
        }
      }
      return sv_ret;
    }

    SV* looks_like_na (SV* sv_value) {
      
      SV* sv_ret;
      if (!SvOK(sv_value) || sv_len(sv_value) == 0) {
        sv_ret = &PL_sv_undef;
      }
      else {
        SV* sv_na = Rstats::PerlAPI::new_mSVpv_nolen("NA");
        if (sv_cmp(sv_value, sv_na) == 0) {
          sv_ret = Rstats::PerlAPI::to_perl_obj(Rstats::Vector::new_na(), "Rstats::Vector");
        }
        else {
          sv_ret = &PL_sv_undef;
        }
      }
      
      return sv_ret;
    }
    
    SV* looks_like_integer(SV* sv_str) {
      
      SV* sv_ret;
      if (!SvOK(sv_str) || sv_len(sv_str) == 0) {
        sv_ret = &PL_sv_undef;
      }
      else {
        IV ret = Rstats::PerlAPI::pregexec_simple(sv_str, INTEGER_RE);
        if (ret) {
          SV* match1 = Rstats::PerlAPI::new_mSVpv_nolen("");
          Perl_reg_numbered_buff_fetch(aTHX_ INTEGER_RE, 1, match1);
          sv_ret = Rstats::PerlAPI::new_mSViv(SvIV(match1));
        }
        else {
          sv_ret = &PL_sv_undef;
        }
      }
      
      return sv_ret;
    }

    SV* looks_like_double (SV* sv_value) {
      
      SV* sv_ret;
      if (!SvOK(sv_value) || sv_len(sv_value) == 0) {
        sv_ret =  &PL_sv_undef;
      }
      else {
        IV ret = Rstats::PerlAPI::pregexec_simple(sv_value, DOUBLE_RE);
        if (ret) {
          SV* match1 = Rstats::PerlAPI::new_mSVpv_nolen("");
          Perl_reg_numbered_buff_fetch(aTHX_ DOUBLE_RE, 1, match1);
          sv_ret = Rstats::PerlAPI::new_mSVnv(SvNV(match1));
        }
        else {
          sv_ret = &PL_sv_undef;
        }
      }
      
      return sv_ret;
    }
  }
}
