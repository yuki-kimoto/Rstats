using namespace std;

namespace Rstats {
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
        *((complex<double>*)e1->pv) += *((complex<double>*)e2->pv);
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
      SV* new_str_sv = p->new_sv(str_sv);
      SvREFCNT_inc(new_str_sv);
      element->pv = new_str_sv;
      element->type = Rstats::ElementType::CHARACTER;
      
      return element;
    }

    Rstats::Element* new_complex(double re, double im) {
      
      complex<double>* z = new complex<double>(re, im);
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
      if (element->type == Rstats::ElementType::DOUBLE && isinf(element->dv)) {
        ret = new_true();
      }
      else {
        ret = new_false();
      }
      
      return ret;
    }

    Rstats::Element* is_finite(Rstats::Element* element) {
      
      Rstats::Element* ret;
      if (element->type == Rstats::ElementType::INTEGER || (element->type == Rstats::ElementType::DOUBLE && isfinite(element->dv))) {
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
