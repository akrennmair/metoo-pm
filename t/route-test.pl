#!/usr/bin/perl

use strict;
use warnings;
use lib '../lib';
use MeToo;

get "/test-base" => sub {
	base
};

get "/test-baseurl" => sub {
	base_url
};

get "/match(/(.*))?" => sub {
	$_[1]
};

get "/match2/([0-9]*)/([a-z]*)" => sub {
	$_[1] . " " . $_[0]
};

get "/match3/((..)..)" => sub {
	$_[1] . " " . $_[0]
};
