#!/usr/bin/perl

use strict;
use LWP;
use GD;

use Getopt::Long;

sub usage {
	print STDERR "Usage:\n  $0 -z ZOOM -b X1,Y1-X2,Y2 -f FILE -u URL [-u URL2 ...]\n";
	exit 1;
}

my $zoom;
my $bbox;
my $file;
my $urls = [];

# Get and parse command line arguments
GetOptions( 'z|zoom=s' => \$zoom,
            'b|bbox=s' => \$bbox,
            'f|file=s', =>\$file,
            'u|url=s@' => $urls ) or usage();
defined $zoom && defined $bbox && defined $file
    or usage();

unless ( scalar @$urls ) {
	$urls = [ 'http://b.tile.openstreetmap.org/!z/!x/!y.png',
	          'http://c.tile.openstreetmap.org/!z/!x/!y.png',
	          'http://a.tile.openstreetmap.org/!z/!x/!y.png' ]
}

my ($x_beg, $y_beg, $x_end, $y_end) = ($bbox =~ /^(\d+),(\d+)-(\d+),(\d+)$/)
	or die "Failed to parse tiles box\n";

$x_beg <= $x_end
    or die "Error: X1 > X2!\n";

$y_beg <= $y_end
    or die "Error: Y1 > Y2!\n";

my $x_count = $x_end - $x_beg + 1;
my $y_count = $y_end - $y_beg + 1;

# Init image
my ($width, $height) = ($x_count * 256, $y_count * 256);
my $img = GD::Image->new($width, $height, 1);
my $white = $img->colorAllocate(248, 248, 248);
$img->filledRectangle(0, 0, $width, $height, $white);

# Init UA
my $ua = LWP::UserAgent->new();
$ua->env_proxy;

# Download tiles
for (my $x=0;$x<$x_count;$x++) {
	for (my $y=0;$y<$y_count;$y++) {

		my $xx = $x + $x_beg;
        my $yy = $y + $y_beg;

		foreach (@$urls) {
			my $url = $_;
			$url =~ s/!z/$zoom/g;
			$url =~ s/!x/$xx/g;
			$url =~ s/!y/$yy/g;

			my $resp = $ua->get($url);
			next unless $resp->is_success;

			my $tile = GD::Image->new($resp->content);
			next if ($tile->width == 1);
			$img->copy($tile, $x*256, $y*256, 0, 0, 256, 256);
			last
		}
    }
}

open my $fd, '>', $file
    or die "Failed to open file '$file' for writing: $!\n";

print $fd $img->png();
close $fd;
