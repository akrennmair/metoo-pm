package MeToo;

use strict;
use warnings;

require Exporter;
use base qw(Exporter);
our @EXPORT = qw(cgi get post get_post params redirect set_404 content_type base base_url t redirect_internal set_sid get_sid before after);

use CGI;

my %routes;
my ($q, $text_404, $content_type, $session_id, $before_cb, $after_cb);
use constant SESSID_NAME => "MTSESSID";

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
sub set_sid { $session_id = shift; }
sub get_sid { return $q->cookie(SESSID_NAME); }
sub _get_cookie { my $cookie; $cookie = SESSID_NAME . "=" . $session_id if $session_id; return $cookie; }
sub before { $before_cb = shift; }
sub after { $after_cb = shift; }

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
	print $q->redirect(-uri => $url, -status => $code || 301, -cookie => _get_cookie);
}

sub redirect_internal {
	my ($url, $code) = @_;
	$url = base_url . $url;
	print $q->redirect(-uri => $url, -status => $code || 301, -cookie => _get_cookie);
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
			&{$before_cb}() if $before_cb;
			my $output = &{$routine}(@args) || "";
			&{$after_cb}() if $after_cb;
			print $q->header(-content_type => $content_type, -charset=>'utf-8', -cookie => _get_cookie), $output;
			return;
		}
	}
	print "Status: 404\r\nContent-type: text/html\r\n\r\n" . t($text_404, url => $ENV{SCRIPT_URL});
}

1;
