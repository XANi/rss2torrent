#!/usr/bin/perl
use strict;
use XML::RSSLite;
use LWP::Simple;
use Data::Dumper;
use HTML::Entities;
use Config::General;
use JSON;
my $json = JSON->new();
$json->pretty();
my $url=$ARGV[0];
my $outdir=$ARGV[1];
my $count=$ARGV[2];
my $c = new Config::General(-ConfigFile => glob("~/.rss2torrent.conf"),
                         -MergeDuplicateBlocks => 'true',
                         -MergeDuplicateOptions => 'true',
                         -AllowMultiOptions => 'true'
    );
my $cache;
my %cfg_tmp = $c->getall();
my $cfg = \%cfg_tmp;
#my %cache;
my $cache = {};
my $cachefile = glob($cfg->{'config'}{'cachefile'});
if ( -e $cachefile ) {
    open(CACHE, "<", $cachefile);
    my $tmp;
    while(<CACHE>) {
	$tmp .= $_;
    }
    close(CACHE);
    $cache=$json->decode($tmp);
    print "Cache from $cachefile loaded \n";
    
}
my $rss=$cfg->{'rss'};
while ( my($feed_url, $feed_cfg) = each(%$rss) ) {
    my $feed_c = 0;
    my $count = 3;
    if (defined($feed_cfg->{'keep'})) {
	$count = $feed_cfg->{'keep'};
    }
    print "Downloading '$count torrents from $url\n";
    my %rss;
    my $rss = \%rss;
    my $data = get($feed_url);
    parseRSS($rss, \$data);
    my $items = $rss->{'item'};
    foreach my $item (@$items) {
	my $filename = sanitize($item->{'title'}) . '.torrent';
	my $torrent_url = HTML::Entities::decode($item->{'link'});
	if ( !defined( $cache->{$filename} ) ) {
	    print "Downloading $torrent_url into $filename\n";
	    mirror($torrent_url, $cfg->{'config'}{'download_dir'} . '/' . $filename);
	    print "\n";
	    $cache->{$filename} = scalar time;
	} else {
	    print "we downloaded that already, skipping\n"
	}
	--$count;
	if($count <= 0 ) {last;}
    }
}

open(CACHE, ">", $cachefile);
print CACHE $json->encode($cache);
close(CACHE);


# #remove spaces, backslashes and other crap
sub sanitize() {
    $_ = HTML::Entities::decode(shift);
    s/ /_/g;
    s/\\//g;
    return $_;
}
