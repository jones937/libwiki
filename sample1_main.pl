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
        print "Usage: sample1_main.pl <filename>\n";
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
    my $title_er = $$page{'title'}; # need two '$' signs because 'page' variable is a reference of hash.
    if ( $title_er eq "" ) {
        return;
    }

    #---- text ---------------------------
    foreach (@{$$page{'text'}}) {
        if ( $_ =~ /Cite web/ ) {
            print "* [[:$title]]\n";
            print "*: <nowiki>[$line]</nowiki>\n";
        }
    }
}


&main();
