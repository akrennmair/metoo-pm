use Test::Perl::Critic (-severity => 3, -exclude => ['ProhibitAutomaticExportation']);
use Test::More tests => 1;
use strict;
use warnings;

critic_ok("lib/MeToo.pm");
