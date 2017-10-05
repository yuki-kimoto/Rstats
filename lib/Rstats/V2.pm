package Rstats::V2;
use strict;
use warnings;

use Object::Simple -base;
require Rstats::Func;
use Carp 'croak';
use Rstats::Util ();
use Digest::MD5 'md5_hex';
use Rstats::Object;

use Rstats::V2::Object;

use SPVM 'Rstats::Object';
use SPVM 'Rstats::Vector';
use SPVM 'Math';

sub c_double {
  my ($r, $values) = @_;
  
  my $object = Rstats::V2::Object->new;
  
  $object->type('double');
  
  my $sp_vector = SPVM::new_double_array($values);
  
  $object->vector($sp_vector);
  
  return $object;
}

sub c { shift->c_double(@_) }

sub sin {
  my ($r, $object_in) = @_;
  
  my $vector_in = $object_in->vector;
  
  my $vector_out = SPVM::Rstats::Vector::sin($vector_in);
  
  my $object_out = Rstats::V2::Object->new;
  $object_out->type('double');
  $object_out->vector($vector_out);
  
  return $object_out;
}

sub pi {
  my ($r, $values) = @_;
  
  my $r_object = SPVM::new_object("Rstats::Object");
  
  $r_object->set(type => SPVM::Rstats::Object::TYPE_DOUBLE());
  
  my $sp_values = SPVM::new_double_array([SPVM::Math::PI()]);
  
  $r_object->set(double_values => $sp_values);
  
  return $r_object;
}
