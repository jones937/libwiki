#!/usr/bin/perl
#-------------------------------------------------------
# libwiki.pl
#   'libwiki.pl' is a library for wikipedia written in Perl.
#   Analyze 'wikipedia dump xml file' such as
#   'enwiki-20210501-pages-articles.xml'
#   or
#   'enwiki-20210501-pages-articles.xml.bz2'
#
# Usage:
#   Include 'libwiki.pl' from your .pl
#   Call 3 functions.
#      libwiki::set_filename()
#      libwiki::set_handler()
#      libwiki::do_proc()
#   Details in sample1_main.pl
#
# Author:
# License:
#-------------------------------------------------------
use strict;
use warnings;
use utf8;
use IO::Uncompress::Bunzip2 qw(bunzip2 $Bunzip2Error) ;
use Encode 'encode';
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
sub proc_core {
    $_ = $_[0];

    # convert a HTML character entity reference to a normal character.
    $_ =~ s/&lt;/</g;
    $_ =~ s/&gt;/>/g;
    $_ =~ s/&quot;/"/g;
    $_ =~ s/&apos;/'/g;
    $_ =~ s/&amp;/&/g;

    if ( $inpage == 0 ) {
        if ( $_ =~ /^[ ]*<page>$/ ) {
            $inpage = 1;
            return;
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
            return;
        }
    }
    if ( $intext == 0 ) {
        if ( $_ =~ /^[ ]*<ns>(.*)<\/ns>$/ ) {
            $page{'ns'} = $1;
        }
    }
    if ( $intext == 0 ) {
        if ( $_ =~ /^[ ]*<id>(.*)<\/id>$/ ) {
            if ( $inrevision == 0 ) {
                $page{'pageid'} = $1;
            } if ( $incontributor == 1 ) {
                $page{'contributorid'} = $1;
            } else {
                $page{'revisionid'} = $1;
            }
        }
    }
    if ( $intext == 0 ) {
        if ( $_ =~ /^[ ]*<parentid>(.*)<\/parentid>$/ ) {
            $page{'parentid'} = $1;
        }
    }
    if ( $intext == 0 ) {
        if ( $_ =~ /^[ ]*<username>(.*)<\/username>$/ ) {
            $page{'username'} = $1;
        }
    }
    if ( $intext == 0 ) {
        if ( $_ =~ /^[ ]*<ip>(.*)<\/ip>$/ ) {
            $page{'ip'} = $1;
        }
    }
    if ( $intext == 0 ) {
        if ( $_ =~ /^[ ]*<timestamp>(.*)<\/timestamp>$/ ) {
            $page{'timestamp'} = $1;
        }
    }
    if ( $intext == 0 ) {
        if ( $_ =~ /^[ ]*<model>(.*)<\/model>$/ ) {
            $page{'model'} = $1;
        }
    }
    if ( $intext == 0 ) {
        if ( $_ =~ /^[ ]*<format>(.*)<\/format>$/ ) {
            $page{'format'} = $1;
        }
    }
    if ( $intext == 0 ) {
        if ( ! exists($page{'title'}) ) {
            if ( $_ =~ /^[ ]*<title>(.*)<\/title>$/ ) {
                $page{'title'} = $1;
                return;
            }
        }
    }
    if ( $intext == 0 ) {
        if ( $_ =~ /^[ ]*<text/ ) {
            $intext = 1;
            $_ =~ s/.*xml:space="preserve">//;
            chomp();
            push( @{$page{'text'}} , $_);
            return;
        }
    }
    if ( $_ =~ /<\/text>$/ ) {
        $_ =~ s/<\/text>$//;
        chomp();
        push( @{$page{'text'}} , $_);
        $intext = 0;
        return;
    }
    if ( $intext == 1 ) {
        chomp();
        push( @{$page{'text'}} , $_);
        return;
    }
    if ( $intext == 0 ) {
        if ( $inrevision == 0 ) {
            if ( $_ =~ /^[ ]*<revision>$/ ) {
                $inrevision = 1;
                return;
            }
        }
    }
    if ( $intext == 0 ) {
        if ( $_ =~ /^[ ]*<\/revision>$/ ) {
            $inrevision = 0;
            return;
        }
    }
    if ( $intext == 0 ) {
        if ( $incontributor == 0 ) {
            if ( $_ =~ /^[ ]*<contributor>$/ ) {
                $incontributor = 1;
                return;
            }
        }
    }
    if ( $intext == 0 ) {
        if ( $_ =~ /^[ ]*<\/contributor>$/ ) {
            $incontributor = 0;
            return;
        }
    }
}
sub is_bz2 {
    my $dumpfile = $_[0];
    my $pos = index($dumpfile, ".bz2");
    #print "pos=$pos\n";
    if ( $pos != -1 ) {
        return 1;
    }
    return 0;
}
sub do_loop_bz2 {
    my $dumpfile = $_[0];
    my $gz = new IO::Uncompress::Bunzip2 $dumpfile
        or die "Cannot open $dumpfile: $IO::Uncompress::Bunzip2::Bunzip2Error\n" ;
    while (<$gz>) {
        $_ = Encode::decode('UTF-8',$_);
        &proc_core($_);
    }
    $gz->close();
}
sub do_loop_xml {
    my $dumpfile = $_[0];
    open( DUMP, "<:encoding(UTF-8)", "$dumpfile" );
    while (<DUMP>) {
        &proc_core($_);
    }
    close DUMP;
}
sub parse {
    if ( &is_bz2($dumpfile) ) {
        &do_loop_bz2($dumpfile);
    } else {
        &do_loop_xml($dumpfile);
    }

}

1;
