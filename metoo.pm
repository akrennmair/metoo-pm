package metoo;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(cgi get post get_post params redirect set_404 content_type base base_url);

use CGI;
use strict;
use warnings;

my %routes;
my ($q, $base, $base_url, $text_404, $content_type);

BEGIN {
	$q = new CGI;
	$base = substr($ENV{SCRIPT_URL}, 0, length($ENV{SCRIPT_URL}) - length($ENV{PATH_INFO}));
	$base_url = substr($ENV{SCRIPT_URI}, 0, length($ENV{SCRIPT_URI}) - length($ENV{PATH_INFO}));
}

sub cgi { return $q; }
sub params { return $q->Vars; }
sub set_404($) { $text_404 = shift; }
sub content_type($) { $content_type = shift; }
sub base { return $base; }
sub base_url { return $base_url; }

sub get(@) {
	my (%args) = @_;
	foreach my $rx (keys %args) {
		$routes{GET}->{"^$base" . $rx . '$'} = $args{$rx};
	}
}

sub post(@) {
	my (%args) = @_;
	foreach my $rx (keys %args) {
		$routes{POST}->{"^$base" . $rx . '$'} = $args{$rx};
	}
}

sub get_post(@) {
	get @_; post @_;
}

sub redirect($;$) {
	my ($url, $code) = @_;
	print $q->redirect(-uri => $url, -status => $code || 301);
}

END {
	if ($q->path_info eq "") {
		redirect($ENV{SCRIPT_URI} . "/", 301);
		return;
	}
	my $r = $routes{$q->request_method};
	if (!$r) {
		print $q->header, "Error: unhandled request method.";
		return;
	}
	my $func;
	my @args;
	foreach my $rx (keys %$r) {
		if (@args = ($ENV{SCRIPT_URL} =~ /$rx/)) {
			$func = $r->{$rx};
			last;
		}
	}
	if (!$func) {
		print "Status: 404 Not Found\r\nContent-type: text/html\r\n\r\n$text_404";
		return;
	}
	my $output = &$func(@args);
	print $q->header(-content_type => $content_type), $output;
}

1;
