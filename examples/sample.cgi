#!/usr/bin/perl

use strict;
use warnings;
use metoo;

get "/" => sub {
	t(<<EOF, base => base);
<html>
	<head><title>Hello, world!</title></head>
	<body>
	<h1>Hello, world!</h1>
	<form action="{base}/say" method="post">
		<label for="yourname">Your name:</label>
		<input type="text" name="yourname">
		<input type="submit" value="Say hello!">
	</form>
	</body>
</html>
EOF
};

post "/say" => sub {
	my $yourname = params->{yourname};
	redirect base_url . "/say/$yourname";
};

get "/say/(.*)" => sub {
	my $name = shift;
	"<h1>Hello, $name!</h1>";
};
