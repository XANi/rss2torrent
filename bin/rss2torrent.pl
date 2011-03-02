#!/usr/bin/perl
use XML::RSSLite;
use LWP::Simple;
use Data::Dumper;
use HTML::Entities;
my $url=$ARGV[0];
my $outdir=$ARGV[1];
my $count=$ARGV[2];
if(!defined($count)) {
    $count = 3;
}
if (!defined($outdir)) {
    print "usage: rss2torrent 'http://rss.url/path' /download/dir [number of torrents to get]\n";
    exit;
}
print "Downloading $count torrents into $outdir from $url\n";
my $rss=\%rss;
my $data = get($url);
parseRSS($rss, \$data);
my $items = $rss->{'item'};
foreach my $item (@$items) {
    my $filename = sanitize($item->{'title'}) . '.torrent';
    my $torrent_url = HTML::Entities::decode($item->{'link'});
    print "Downloading $torrent_url into $filename\n";
    mirror($torrent_url, $outdir . '/' . $filename);
    if($count <= 1 ) {exit;}
    --$count;
    print "\n";
}


#remove spaces, backslashes and other crap
sub sanitize() {
    $_ = HTML::Entities::decode(shift);
    s/ /_/g;
    s/\\//g;
    return $_;
}
