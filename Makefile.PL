use 5.010001;

use strict;
use warnings;
use ExtUtils::MakeMaker;

use Config;

# Compiler(gcc or clang)
my $cc;
my $ld;
if ($Config{gccversion} =~ /clang/i) {
  $cc = 'clang++';
  $ld = 'clang++';
}
elsif ($Config{gccversion}) {
  $cc = 'g++';
  $ld = 'g++';
}
elsif ($Config{archname} =~ /solaris/i) {
  $cc = 'CC';
  $ld = 'CC';
}

my $xs_source_file = (glob('*.xs'))[0];
$xs_source_file =~ s/\.xs/.c/;
my @source_files = ($xs_source_file, glob('*.cpp'), glob('Rstats_lib/src/*.cpp'));
my @object_files = map { $_ =~ s/(\.c|\.cpp)$/.o/; $_ } @source_files;
my $OBJECT = join(' ', @object_files);
my @link_files = map { $_ =~ s/^.*\///; $_ } @object_files;
my $LDFROM = join(' ', @link_files);

WriteMakefile(
    NAME                => 'Rstats',
    AUTHOR              => 'Yuki Kimoto <kimoto.yuki@gmail.com>',
    VERSION_FROM        => 'lib/Rstats.pm',
    ABSTRACT_FROM       => 'lib/Rstats.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    META_MERGE   => {
      requires  => {perl => '5.010001'},
      resources => {
        license    => 'http://www.opensource.org/licenses/artistic-license-2.0',
        bugtracker => 'https://github.com/yuki-kimoto/Rstats/issues',
        repository => 'https://github.com/yuki-kimoto/Rstats.git'
      }
    },
    PREREQ_PM => {
        'Object::Simple' => '3.10',
        'Math::Round' => '0.06',
        'Text::UnicodeTable::Simple' => '0.09'
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Rstats-*' },
    CC => $cc,
    OPTIMIZE => '-O3',
    LD => $ld,
    LIBS              => [],
    DEFINE            => '',
    INC               => '-I. -I./Rstats_lib/include',
    OBJECT            => $OBJECT,
    LDFROM            => $LDFROM
);
