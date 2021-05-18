# libwiki

'libwiki.pl' is a library for wikipedia written in Perl.

## Getting Started

* Download enwiki-20210501-pages-articles.xml.bz2 from https://dumps.wikimedia.your.org/backup-index.html
* Unbzip2 enwiki-20210501-pages-articles.xml.bz2
* Run perl
  * $ perl sample1_main.pl enwiki-20210501-pages-articles.xml

## How to create your own perl program
* Include 'libwiki.pl' from your .pl
* Call 3 functions.
  * libwiki::set_filename()
  * libwiki::set_handler()
  * libwiki::parse()
* Then your handler will be called back for each pages. Please do any processes in your handler.

Details in sample1_main.pl

## Prerequisites

Perl

## Authors

* **Kevin Jones**

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## See Also
[Python version](https://github.com/jones937/libwikipy)


