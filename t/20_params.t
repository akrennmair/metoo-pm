use CGI::Test;
use Data::Dumper;
require CGI::Test::Input::URL;

print "1..10\n";

my $ct = CGI::Test->make(
	-base_url	=> "http://localhost:9001/cgi-bin",
	-cgi_dir => "t",
);

$ENV{SCRIPT_URL} = "/cgi-bin/params-test.pl/params1";
my $page = $ct->GET("http://localhost:9001/cgi-bin/params-test.pl/params1?v=foo");
ok 1, $page->is_ok;
ok 2, $page->raw_content eq "foo";

$page = $ct->GET("http://localhost:9001/cgi-bin/params-test.pl/params1?v=");
ok 3, $page->is_ok;
ok 4, !defined($page->raw_content);

$ENV{SCRIPT_URL} = "/cgi-bin/params-test.pl/params2";
my $input = CGI::Test::Input::URL->make();
$input->add_field("v", "bar");
$page = $ct->POST("http://localhost:9001/cgi-bin/params-test.pl/params2", $input);
ok 5, $page->is_ok;
ok 6, $page->raw_content eq "POST: bar";

$ENV{SCRIPT_URL} = "/cgi-bin/params-test.pl/params3";
$page = $ct->GET("http://localhost:9001/cgi-bin/params-test.pl/params3?v=foobar");
ok 7, $page->is_ok;
ok 8, $page->raw_content eq "GET_POST: foobar";

$input = CGI::Test::Input::URL->make();
$input->add_field("v", "quux");
$page = $ct->POST("http://localhost:9001/cgi-bin/params-test.pl/params3", $input);
ok 9, $page->is_ok;
ok 10, $page->raw_content eq "GET_POST: quux";

