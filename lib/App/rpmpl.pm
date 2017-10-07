package App::rpmpl;

use strictures 2;

=head1 NAME

App::rpmpl - Create application Perl RPM (with dependencies)

=cut

use Cwd                  qw( abs_path );
use File::Basename;
use File::Copy;
use File::Path           qw( make_path );
use File::ShareDir::Dist qw( dist_share );
use File::Which;
use Getopt::Long;
use LWP::Simple;
use Template;
use Term::ReadLine;
use Term::UI;
use YAML::Tiny;

our $VERSION = '0.1';

my $rpmbuild_root = "$ENV{HOME}/rpmbuild";

=head1 METHODS

=head2 run

The run method is executed by the C<rpmpl> script.

=cut

sub run {
    my %args = @_;

    my $help;
    my $init;
    my $config_file = './etc/rpmpl.yml';
    my $cpanfile    = './cpanfile';
    my $version;
    my $download    = $args{download} // 1;
    my $build       = $args{build}    // 1;

    GetOptions(
	'help|h|?'     => \$help,
	'init|i'       => \$init,
	'config|c=s'   => \$config_file,
	'cpanfile|f=s' => \$cpanfile,
	'version|v'    => \$version,
	'download|d'   => \$download,
	'build|b'      => \$build,
    );

    return _usage()   if $help;
    return _version() if $version;

    my $term = Term::ReadLine->new( 'rpmpl' );

    unless ( -e $rpmbuild_root ) {
	my $init_rpmbuild = $args{yes} || $term->ask_yn(
	    prompt  => "rpmbuild root $rpmbuild_root not found. Create it?",
	    default => 'n',
	);

	die "rpmbuild environment must exist!" unless $init_rpmbuild;
	_init();
    }

    unless ( -e $config_file ) {
	my $create_config = $args{yes} || $term->ask_yn(
	    prompt  => "Config file $config_file not found. Create one?",
	    default => 'n',
	);
	_usage() unless $create_config;
	my ( $name, $path ) = fileparse( $config_file );
	my $err;
	make_path( $path, { error => \$err } ) unless -d $path;
	die "Unable to create $config_file: $!"
	    unless copy dist_share( 'App-rpmpl' ) . '/rpmpl.yml', $path;
	print "$config_file created. Please configure accordingly.\n";
	return 0;
    }

    my $config        = YAML::Tiny->read( $config_file );
    my $perl_version  = $config->[0]->{perl_version};
    my $name          = $config->[0]->{name};

    _init() and return 0 if $init;

    die "cpanfile $cpanfile doesn't exist!" unless -e $cpanfile;

    my $tt = Template->new({ INCLUDE_PATH => dist_share( 'App-rpmpl' ) });
    $tt->process(
	'specfile.tt',
	$config->[0],
	"$rpmbuild_root/SPECS/$name.spec",
    );

    my $perl_src = "perl-$perl_version.tar.gz";
    my $perl_url = "http://www.cpan.org/src/5.0/$perl_src";

    unless ( -e "$rpmbuild_root/SOURCES/$perl_src" ) {
	if ( $download ) {
	    print "Downloading $perl_url.\n";
	    my $ret = getstore $perl_url, "$rpmbuild_root/SOURCES/$perl_src";
	    die "Unable to download $perl_url!" unless $ret == 200;
	}
    }

    die "Perl source $rpmbuild_root/SOURCES/$perl_src not found!"
	unless -e "$rpmbuild_root/SOURCES/$perl_src";

    die "Unable to copy cpanfile: $!"
	unless copy $cpanfile, "$rpmbuild_root/SOURCES";

    return 0 unless $build;
    return system( 'rpmbuild', '-ba', "$rpmbuild_root/SPECS/$name.spec" );
}

sub _init {
    die 'rpmbuild not found in path!' unless which 'rpmbuild';

    _make_dirs( _rpmbuild_dirs() );

    my $rpmmacros = "$ENV{HOME}/.rpmmacros";

    unless ( -e $rpmmacros ) {
	open( my $fh, '>', $rpmmacros )
	    or die "Could not open file $rpmmacros for writing: $!";
	print $fh "%_topdir $rpmbuild_root\n";
	close $fh;
    }
}

sub _usage {

    print "Usage: $0 [options]\n",
          "\t[--help     | -h]\n",
          "\t[--config   | -c <config file>]\n",
          "\t[--init     | -i]\n",
          "\t[--cpanfile | -f]\n";

    return 1;
}

sub _version {
    print "rpmpl v$App::rpmpl::VERSION\n";
    return 0;
}

sub _make_dirs {
    for ( @_ ) {
	my $ret = mkdir $_ unless -d $_;
	die "Could not create directory $_: $!" unless $ret;
    }
}

sub _rpmbuild_dirs {
    $rpmbuild_root,
    "$rpmbuild_root/BUILD",
    "$rpmbuild_root/BUILDROOT",
    "$rpmbuild_root/RPMS",
    "$rpmbuild_root/SOURCES",
    "$rpmbuild_root/SPECS",
    "$rpmbuild_root/SRPMS",
    "$rpmbuild_root/TMP",
}

1;
