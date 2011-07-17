#!/usr/bin/perl

use strict;
use warnings;
use lib '../lib';
use MeToo;

get "/t1" => sub {
	t("hello, t1!");
};

get "/t2" => sub {
	t("v = {v}", v => params->{v});
};
