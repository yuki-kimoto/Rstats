use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Rstats',
    AUTHOR              => 'Yuki Kimoto <kimoto.yuki@gmail.com>',
    VERSION_FROM        => 'lib/Rstats.pm',
    ABSTRACT_FROM       => 'lib/Rstats.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Object::Simple' => '3.10',
        'Math::Round' => '0.06',
        'Text::UnicodeTable::Simple' => '0.09'
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Rstats-*' },
    CC =>'g++',
    OPTIMIZE => '-O3',
    LD => 'g++',
    LIBS              => [''],
    DEFINE            => '',
    INC               => '-I.',
    OBJECT            => '$(O_FILES)',
);
