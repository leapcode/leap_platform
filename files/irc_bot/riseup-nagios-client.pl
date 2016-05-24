#!/usr/bin/perl -w

# ##############################################################################
# Infrabot-Client - a simple Infrabot client which sends it's whole command
# line arguments to a local UNIX domain socket.
# ##############################################################################

use strict;
use IO::Socket;


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# >> CONFIGURATION >>

# Read a configuration file
#   The arg can be a relative or full path, or
#   it can be a file located somewhere in @INC.
sub ReadCfg
{
    my $file = $_[0];

    our $err;

    {   # Put config data into a separate namespace
        package CFG;

        # Process the contents of the config file
        my $rc = do($file);

        # Check for errors
        if ($@) {
            $::err = "ERROR: Failure compiling '$file' - $@";
        } elsif (! defined($rc)) {
            $::err = "ERROR: Failure reading '$file' - $!";
        } elsif (! $rc) {
            $::err = "ERROR: Failure processing '$file'";
        }
    }

    return ($err);
}

# Get our configuration information
if (my $err = ReadCfg('/etc/nagios_nsa.cfg')) {
    print(STDERR $err, "\n");
    exit(1);
}

# << CONFIGURATION <<
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if (@ARGV == 0) {
	print "Hey - specify a message, sucker!\n";
	exit(1);
}

unless (-S $CFG::Nsa{'socket'}) {
	die "Socket '$CFG::Nsa{'socket'}' doesn't exist or isn't a socket!\n";
}

unless (-r $CFG::Nsa{'socket'}) {
	die "Socket '$CFG::Nsa{'socket'}' can't be read!\n";
}

my $sock = IO::Socket::UNIX->new (
	Peer    => $CFG::Nsa{'socket'},
	Type    => SOCK_DGRAM,
	Timeout => 10
) || die "Can't open socket '$CFG::Nsa{'socket'}'!\n";

print $sock "@ARGV";
close($sock);
