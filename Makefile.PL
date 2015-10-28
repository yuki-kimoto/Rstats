use 5.010001;

use strict;
use warnings;
use ExtUtils::MakeMaker;

use Config;

# C++ compiler
my $cpp_compilers = {
  gcc => 'g++',
  clang => 'clang++',
  CC => 'CC'
};
my $cc = $cpp_compilers->{$Config{ccname}};
my $ld = $cc;

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
    H => ['ppport.h', glob('Rstats_lib/include/*.h')],
    C => ['Rstats.c', glob('Rstats_lib/src/*.cpp')],
    OBJECT            => '$(O_FILES)',
    DEFINE => '-o $@'
);
