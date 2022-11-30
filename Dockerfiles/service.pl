#!/usr/bin/env perl

use strict;
use warnings;

sub is_dir {
    my ($dir) = @_;
    return defined $dir && -d $dir;
}

sub is_file {
    my ($file) = @_;
    return defined $file && -d $file;
}

sub is_empty {
    my ($string) = @_;
    return !defined $string || !length $string;
}

sub has_env {
    my ($key) = @_;
    return grep { /$key/ && !is_empty( $ENV{$_} ) } keys %ENV;
}

sub _now {
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      localtime(time);
    return "$year-$mon-${mday}T$hour:$min:$sec";
}

sub _chdir {
    my ( $key, $code ) = @_;
    my $pwd     = $ENV{PWD};
    my $new_dir = $ENV{"CHDIR_$key"};
    chdir $new_dir if $new_dir;
    $code->();
    chdir $pwd if $new_dir;
}

sub _cmd {
    my ( $label, $how, $cmd ) = @_;

    _chdir $label => sub {
        printf "[%s] $label>> %s\n", _now(), $cmd if $ENV{RUN_VERBOSE};

        if ( $how =~ /system/ ) {
            system $cmd;
        }
        elsif ( $how =~ /background/ ) {
            my $pid = fork;
            return $pid if $pid;
            local $0 = "SERVICE: $label";
            exec $cmd;
        }
        elsif ( $how =~ /loop/ ) {
            my $pid = fork;
            return $pid if $pid;
            local $0 = "SERVICE: $label";
            while (1) {
                system "while [ true ]; do\n$cmd;\nsleep 5;\ndone";
                sleep 5;
            }
        }
        else {
            local $0 = $label;
            exec $cmd;
        }
    };
}

sub _should_run {
    my ($key) = @_;
    my $code = $ENV{"IF_$key"}
      or return 1;
    my $yes   = eval $code;
    my $error = $@;
    warn "[X] $key ---> $error\n" if $error;
    return $yes;
}

sub _run_services {
    foreach my $key ( sort keys %ENV ) {
        if ( $key =~ /^IN_RUN_.+/ && _should_run $key ) {
            my $cmd = $ENV{$key} or next;
            _cmd $key => system => $cmd;
        }
        elsif ( $key =~ /^JUST_RUN_.+/ && _should_run $key ) {
            my $cmd = $ENV{$key} or next;
            _cmd $key => background => $cmd;
        }
        elsif ( $key =~ /^KEEP_RUN_.+/ && _should_run $key ) {
            my $cmd = $ENV{$key} or next;
            _cmd $key => loop => $cmd;
        }
    }
}

sub main {
    my @cmd = @_;

    _run_services;

    @cmd
      ? _cmd( ENTRYPOINT       => exec => join " ", @cmd )
      : _cmd( CONTAINER_HOLDER => exec => qq{ sleep infinity } );
}

caller or main(@ARGV);

__END__
TEST:
IN_RUN_001='echo 1; sleep 2' IN_RUN_002='echo 2; sleep 3' JUST_RUN_001='sleep 5; echo 3' JUST_RUN_002='sleep 4; echo 4' KEEP_RUN_001='echo A' KEEP_RUN_002='echo B' perl %

