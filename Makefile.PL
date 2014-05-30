use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Data::R',
    AUTHOR              => 'Yuki Kimoto <kimoto.yuki@gmail.com>',
    VERSION_FROM        => 'lib/Data/R.pm',
    ABSTRACT_FROM       => 'lib/Data/R.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Object::Simple' => '3.10'
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Data-R-*' },
);
