require 5.010;
use ExtUtils::MakeMaker;

WriteMakefile (
	NAME		=> 'MeToo',
	AUTHOR		=> 'Andreas Krennmair <ak@synflood.at>',
	ABSTRACT	=> 'MeToo.pm is a nano web application framework.',
	VERSION		=> '0.1',
	PREREQ_PM	=> {
			'CGI' => '3.43',
			'Exporter' => '5.63',
	}
);
