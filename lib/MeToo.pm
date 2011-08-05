package MeToo;

use strict;
use warnings;

require Exporter;
use base qw(Exporter);
our @EXPORT = qw(cgi get post get_post params redirect set_404 content_type base base_url t);

use CGI;

my %routes;
my ($q, $text_404, $content_type);

BEGIN {
	$q = CGI->new;
	$text_404 = "<html><head><title>404 - Not Found</title><head><body><h1>404 - Not Found</h1><p>The requested URL {url} was not found.<p></body></html>";
}

sub cgi { return $q; }
sub params { return $q->Vars; }
sub set_404 { $text_404 = shift; }
sub content_type { $content_type = shift; }
sub base { return $q->url(-absolute=>1); }
sub base_url { return $q->url; }

sub register_route {
	my ($method, %args) = @_;
	foreach my $rx (keys %args) {
		my $base = base;
		push(@{$routes{$method}->{rx}}, '^' . $base . $rx . '$');
		push(@{$routes{$method}->{sub}}, $args{$rx});
	}
}

sub get {
	my @args = @_;
	register_route('GET', @args);
}

sub post {
	my @args = @_;
	register_route('POST', @args);
}

sub get_post {
	my @args = @_;
	get @args; post @args;
}

sub redirect {
	my ($url, $code) = @_;
	print $q->redirect(-uri => $url, -status => $code || 301);
}

sub t {
	my ($data, %vars) = @_;
	foreach my $key (%vars) {
		$data =~ s/\{$key\}/$vars{$key}/gx;
	}
	return $data;
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
	foreach my $rx (@{$r->{rx}}) {
		my $routine = shift(@{$r->{sub}});
		if (my @args = ($ENV{SCRIPT_URL} =~ /$rx/x)) {
			my $output = &{$routine}(@args);
			print $q->header(-content_type => $content_type, -charset=>'utf-8'), $output;
			return;
		}
	}
	print "Status: 404\r\nContent-type: text/html\r\n\r\n" . t($text_404, url => $ENV{SCRIPT_URL});
}

1;
