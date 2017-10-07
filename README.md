# NAME

rpmpl - RPM Perl Builder

# SYNOPSIS

```
[user@host: ~/my-project ]$ cat cpanfile
requires 'Mojolicious';

[user@host: ~/my-project ]$ rpmpl
rpmbuild root /home/user/rpmbuild not found. Create it? [y/N]: y
Config file ./etc/rpmpl.yml not found. Create one? [y/N]: y
./etc/rpmpl.yml created. Please configure accordingly.

[user@host: ~/my-project ]$ cat ./etc/rpmpl.yml
perl_version:  5.26.1
base_dir:      /opt/my-project/
name:          my-project-perl
version:       1.0
release:       1
summary:       My Project Perl Libraries
description:   Perl library dependencies for My Project.
license:       GPL+ or Artistic
group:         Development/Libraries
url:           https://github.com/my-project

[user@host: ~/my-project ]$ rpmpl
...
Wrote: /home/user/rpmbuild/SRPMS/my-project-perl-1.0-1.el7.centos.src.rpm
Wrote: /home/user/rpmbuild/RPMS/x86_64/my-project-perl-1.0-1.el7.centos.x86_64.rpm
[user@host: ~/my-project ]$ sudo yum -y install \
    /home/user/rpmbuild/RPMS/x86_64/my-project-perl-1.0-1.el7.centos.x86_64.rpm
[user@host: ~/my-project ]$ /opt/my-project/perl/bin/perl \
    -e 'use Mojolicious; print $Mojolicious::VERSION'
7.46
```

# DESCRIPTION

rpmpl (RPM Perl) is a tool to help build a custom Perl distribution, including
any application dependencies, installed with the Perl into an RPM package. Tools
like [carton](https://github.com/perl-carton/carton) and
[plenv](https://github.com/tokuhirom/plenv) are great for developers in order to
quickly install and build a custom Perl and any dependencies, but not as nice
when it comes to proper packaging and deployment.

rpmpl lets you continue to manage any application Perl dependencies in a
standard [cpanfile](https://github.com/miyagawa/cpanfile), but will build an RPM
containing those dependencies and the Perl version you specify. This way you may
continue to use carton/plenv while doing local development and easily package it
when its time for deployment.

No longer will you be burdened from the lack of CPAN dependencies available in
your RPM repository. One system can easily house multiple custom Perls for each
application without sharing and polluting the system perl.

# AUTHOR

Mitch McCracken

# SEE ALSO

[carton](https://github.com/perl-carton/carton)

[cpanm](https://github.com/miyagawa/cpanminus)

[plenv](https://github.com/tokuhirom/plenv)
