requires 'strictures';
requires 'Cwd';
requires 'File::Basename';
requires 'File::Copy';
requires 'File::Path';
requires 'File::ShareDir::Dist';
requires 'File::Which';
requires 'Getopt::Long';
requires 'LWP::Simple';
requires 'Template';
requires 'Term::ReadLine';
requires 'Term::UI';
requires 'YAML::Tiny';

configure_requires 'ExtUtils::MakeMaker::CPANfile';
configure_requires 'File::ShareDir::Install';

test_requires 'Cwd';
test_requires 'File::Spec';
test_requires 'File::Temp';
test_requires 'Test2::V0';
