#!/usr/bin/perl
#-------------------------------------------------------
# libwiki.pl
#   'libwiki.pl' is a library for wikipedia written in Perl.
#   Analyze 'wikipedia dump xml file' such as
#   'enwiki-20210501-pages-articles.xml'
#
# Usage:
#   Include 'libwiki.pl' from your .pl
#   Call 3 functions.
#      libwiki::set_filename()
#      libwiki::set_handler()
#      libwiki::parse()
#   Details in sample1_main.pl
#
# Author:
# License:
#-------------------------------------------------------
use strict;
use warnings;
use utf8;
package libwiki;

#-------------------------------------------------------
# data structure
#
#my %page = (
#    "title" => "page_title_name",
#    "pageid" => 10,
#    "ns" => 0,
#    "revisionid" => 71019675,
#    "text" => ["line1", "lin2", "line3"],
#);
#-------------------------------------------------------
my $dumpfile = "";
my $handler = "";
my $inpage = 0;
my $intext = 0;
my $inrevision = 0;
my $incontributor = 0;
my %page        = ();
sub set_filename {
    #print $_[0], "\n";
    my $tmp = $_[0];
    $dumpfile = $tmp;
}
sub set_handler {
    $handler = $_[0];
}
sub convert_ref2norm {
    my $line = $_[0];
    # convert a HTML character entity reference to a normal character.
    $line =~ s/&lt;/</g;
    $line =~ s/&gt;/>/g;
    $line =~ s/&quot;/"/g;
    $line =~ s/&apos;/'/g;
    $line =~ s/&amp;/&/g;
    return $line;
}
sub parse {
    open( DUMP, "<:encoding(UTF-8)", "$dumpfile" );
    while (<DUMP>) {
        $_ = &convert_ref2norm($_);

        if ( $inpage == 0 ) {
            if ( $_ =~ /^[ ]*<page>$/ ) {
                $inpage = 1;
                next;
            }
        }
        if ( $intext == 0 ) {
            if ( $_ =~ /^[ ]*<\/page>$/ ) {
                if ( exists($page{'title'}) ) {
                    $handler->(\%page);
                }
                $inpage = 0;
                $intext = 0;
                $inrevision = 0;
                $incontributor = 0;
                %page        = ();
                next;
            }
        }
        if ( $intext == 0 ) {
            if ( ! exists($page{'title'}) ) {
                if ( $_ =~ /^[ ]*<title>(.*)<\/title>$/ ) {
                    $page{'title'} = $1;
                    next;
                }
            }
        }
        if ( $intext == 0 ) {
            if ( $_ =~ /^[ ]*<text/ ) {
                $intext = 1;
                $_ =~ s/.*xml:space="preserve">//;

                # 一行の場合がある 2021.6.11
                if ( $_ =~ /<\/text>$/ ) {
                    $_ =~ s/<\/text>$//;
                    $intext = 0;
                }
                chomp();
                push( @{$page{'text'}} , $_);
                next;
            }
        }
        if ( $_ =~ /<\/text>$/ ) {
            $_ =~ s/<\/text>$//;
            chomp();
            push( @{$page{'text'}} , $_);
            $intext = 0;
            next;
        }
        if ( $intext == 1 ) {
            chomp();
            push( @{$page{'text'}} , $_);
            next;
        }
    }
    close DUMP;

}

1;
