use CGI::Test;

print "1..10\n";

my $ct = CGI::Test->make(
	-base_url	=> "http://localhost:9001/cgi-bin",
	-cgi_dir => "t",
);

my $page = $ct->GET("http://localhost:9001/cgi-bin/route-test.pl/test-base");
ok 1, $page->is_ok;
ok 2, $page->raw_content eq "/cgi-bin/route-test.pl";

$page = $ct->GET("http://localhost:9001/cgi-bin/route-test.pl/test-baseurl");
ok 3, $page->is_ok;
ok 4, $page->raw_content eq "http://localhost:9001/cgi-bin/route-test.pl";

$page = $ct->GET("http://localhost:9001/cgi-bin/route-test.pl/doesntexist");
ok 5, $page->raw_content =~ /404 - Not Found/;

$page = $ct->GET("http://localhost:9001/cgi-bin/route-test.pl/match/asdf");
ok 6, $page->raw_content eq "asdf";

$page = $ct->GET("http://localhost:9001/cgi-bin/route-test.pl/match/");
ok 7, !defined($page->raw_content);

$page = $ct->GET("http://localhost:9001/cgi-bin/route-test.pl/match2/123/abc");
ok 8, $page->raw_content eq "abc 123";

$page = $ct->GET("http://localhost:9001/cgi-bin/route-test.pl/match2/abc/123");
ok 9, $page->raw_content =~ /404 - Not Found/;

$page = $ct->GET("http://localhost:9001/cgi-bin/route-test.pl/match3/ABCD");
ok 10, $page->raw_content eq "AB ABCD";
