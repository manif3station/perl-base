#!/usr/bin/env perl

use strict;
use warnings;

system qw( chmod 777 /tmp );
system qw( apt-get update );

my @dirs = split /\n/, qx(find /app/src/plugins -type d -name Dockerfiles);

foreach my $dir (sort @dirs) {
    my ($installer) = grep { -f $_ } map { "$dir/installer.$_" } qw( sh pl )
        or next;

    next if $installer =~ m{perl-base/Dockerfiles/installer\.pl$};

    chdir $dir;

    my $title = "| Install $installer";
    my $title_len = length $title;
    my $width = $title_len + 3;

    printf "%s\n", '-' x $width;
    printf "%s%s |\n", $title, (' ' x ($width - (length $title) - 2));
    printf "%s\n", '-' x $width;

    if ($installer =~ m/\.sh$/) {
        system bash => $installer;
    }
    elsif ($installer =~ m/\.pl$/) {
        system perl => $installer;
    }
}
