#!/usr/bin/env perl

use strict;
use warnings;
use Capture::Tiny qw(capture);

my @dirs = split /\n/, capture {
    system qw(find /app/src/plugins -type d -name Dockerfiles);
};

foreach my $dir (@dirs) {
    my $installer = "$dir/installer.sh";
    next if !-f $installer;
    print "Install $installer ...\n";
    chdir $dir;
    system bash => $installer;
}
