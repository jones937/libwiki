#!/usr/bin/perl
use strict;
use warnings;
use utf8;

# disable output buffering
$| = 1;

binmode( STDOUT, ":encoding(UTF-8)" );

require 'libwiki.pl';


# main function
sub main {
    my $dumpfile = "";

    if ( @ARGV < 1 ) {
        print "Usage: main.pl <filename>\n";
        exit 1;
    }
    $dumpfile = $ARGV[0];
    print $dumpfile, "\n";
    libwiki::set_filename($dumpfile);
    libwiki::set_handler(\&handler);
    libwiki::parse(); # this will take a time over 30 minutes!
}

# a callback function for each page
sub handler {
    #print "handler start!\n";
    my $page = $_[0];

    #---- title ---------------------------
    my $title = $$page{'title'}; # need two '$' signs because 'page' variable is a reference of hash.
    print "title = $title\n";
    if ( $title eq "" ) {
        return;
    }
    my $ns = $$page{'ns'};
    print "ns = $ns\n";
    my $pageid = $$page{'pageid'};
    print "pageid = $pageid\n";
    my $revisionid = $$page{'revisionid'};
    print "revisionid = $revisionid\n";

    #---- text ---------------------------
    foreach (@{$$page{'text'}}) {
        my $line = $_;
        if ( $_ =~ /invalid code/ ) {
            print "* [[:$title]]\n";
            print "*: <nowiki>[$_]</nowiki>\n";
        }
    }
}


&main();
