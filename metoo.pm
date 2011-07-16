package metoo;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(cgi get post get_post params redirect set_404 content_type base base_url);

use CGI;
use strict;
use warnings;

my %routes;
my ($q, $text_404, $content_type);

BEGIN {
	$q = new CGI;
	$text_404 = "<html><head><title>404 - Not Found</title><head><body><h1>404 - Not Found</h1></body></html>";
}

sub cgi { return $q; }
sub params { return $q->Vars; }
sub set_404($) { $text_404 = shift; }
sub content_type($) { $content_type = shift; }
sub base { return $q->url(-absolute=>1); }
sub base_url { return $q->url; }

sub register_route($@) {
	my ($method, %args) = @_;
	foreach my $rx (keys %args) {
		$routes{$method}->{'^' . base . $rx . '$'} = $args{$rx};
	}
}

sub get(@) {
	register_route('GET', @_);
}

sub post(@) {
	register_route('POST', @_);
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
		redirect(base_url . "/", 301);
		return;
	}
	my $r = $routes{$q->request_method};
	if (!$r) {
		print $q->header, "Error: unhandled request method.";
		return;
	}
	foreach my $rx (keys %$r) {
		if (my @args = ($ENV{SCRIPT_URL} =~ /$rx/)) {
			my $output = &{$r->{$rx}}(@args);
			print $q->header(-content_type => $content_type), $output;
			return;
		}
	}
	print "Status: 404 Not Found\r\nContent-type: text/html\r\n\r\n$text_404";
}

1;
