package MeToo::Fast;

use CGI::Fast;
use MeToo;

END {
	while (my $q = new CGI::Fast) {
		MeToo::_process_request($q);
	}
}

1;
