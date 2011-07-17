#!/usr/bin/perl

use strict;
use warnings;
use lib '../lib';
use MeToo;

get "/params1" => sub {
	params->{v};
};

post "/params2" => sub {
	"POST: " . params->{v};
};

get_post "/params3" => sub {
	"GET_POST: " . params->{v};
};
