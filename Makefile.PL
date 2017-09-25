use 5.011;
use ExtUtils::MakeMaker::CPANfile;
use File::ShareDir::Install;

install_share dist => 'share';

WriteMakefile(
    NAME             => 'App::rpmpl',
    AUTHOR           => 'Mitch McCracken',
    VERSION_FROM     => 'lib/App/rpmpl.pm',
    ABSTRACT_FROM    => 'lib/App/rpmpl.pm',
    LICENSE          => 'Artistic_2_0',
    MIN_PERL_VERSION => 5.011,
    EXE_FILES        => [ qw( script/rpmpl ) ],
    dist             => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
    clean            => { FILES    => 'App-rpmpl-*' },
);

package MY;
use File::ShareDir::Install 'postamble';
