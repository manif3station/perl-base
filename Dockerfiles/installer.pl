#!/usr/bin/env perl

use strict;
use warnings;

my @dirs = split /\n/, qx(find /app/src/plugins -type d -name Dockerfiles);

foreach my $dir (@dirs) {
    my $installer = "$dir/installer.sh";
    next if !-f $installer;
    print "Install $installer ...\n";
    chdir $dir;
    system bash => $installer;
}
