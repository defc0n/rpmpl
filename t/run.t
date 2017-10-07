use Test2::V0;
use File::Temp qw( tempdir );
use File::Spec;
use Cwd;

BEGIN {

    # Make sure we'll be able to find the share dir even when our module isn't
    # installed yet.
    $File::ShareDir::Dist::over{'App-rpmpl'} =
	File::Spec->catfile( getcwd, 'share' );
    diag "Overrode share dir: " . $File::ShareDir::Dist::over{'App-rpmpl'};

    # Create a temporary directory, set that as our home dir, and enter into it.
    my $dir = tempdir( CLEANUP => 1 );
    $ENV{HOME} = $dir;
    chdir;
};

require App::rpmpl;
is App::rpmpl::run( yes => 1 ), 0, 'Successful initialization run.';

# The first time we run it, it should create the rpmbuild dirs, the .rpmmacros
# file, and the etc/rpmpl.yml file.
ok -e File::Spec->catfile( 'etc', 'rpmpl.yml' ), 'etc/rpmpl.yml created.';
ok -e '.rpmmacros', '.rpmmacros created.';

for ( App::rpmpl::_rpmbuild_dirs() ) {
    ok -d $_, "$_ created.";
}

# The next time we run it everything should be initialized, but it should fail
# due to no cpanfile existing.
like(
    dies { App::rpmpl::run() },
    qr{cpanfile \./cpanfile doesn't exist\!},
    "Detected missing cpanfile."
);

my $fh;
open $fh, '>cpanfile';
close $fh;

# Run it again but don't have it actually download the Perl source.
like(
    dies { App::rpmpl::run( download => 0 ) },
    qr{Perl source .+ not found\!},
    "Detected missing Perl source."
);

open $fh, '>rpmbuild/SOURCES/perl-5.26.1.tar.gz';
close $fh;

# Run it again but don't have it attempt the rpmbuild. Just make sure it was
# able to get to that point.
is App::rpmpl::run( build => 0 ), 0, 'Successful build run.';

done_testing;
