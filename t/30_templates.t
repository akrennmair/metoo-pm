use CGI::Test;

print "1..6\n";

my $ct = CGI::Test->make(
	-base_url	=> "http://localhost:9001/cgi-bin",
	-cgi_dir => "t",
);

$ENV{SCRIPT_URL} = "/cgi-bin/tmpl-test.pl/t1";
my $page = $ct->GET("http://localhost:9001/cgi-bin/tmpl-test.pl/t1");
ok 1, $page->is_ok;
ok 2, $page->raw_content eq "hello, t1!";

$ENV{SCRIPT_URL} = "/cgi-bin/tmpl-test.pl/t2";
$page = $ct->GET("http://localhost:9001/cgi-bin/tmpl-test.pl/t2?v=asdf");
ok 3, $page->is_ok;
ok 4, $page->raw_content eq "v = asdf";

$page = $ct->GET("http://localhost:9001/cgi-bin/tmpl-test.pl/t2?v=");
ok 5, $page->raw_content eq "v = ";

$page = $ct->GET("http://localhost:9001/cgi-bin/tmpl-test.pl/t2?v=H%20V");
ok 6, $page->raw_content eq "v = H V";

