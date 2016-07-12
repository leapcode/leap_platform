#!/usr/bin/perl
#
# Filaname: check_openvpn
# Created:  2012-06-15
# Website:  http://blog.kernelpicnic.net
#
# Description:
# This script is for verifying the status of an OpenVPN daemon. It has been
# written to integrate directly with Nagios / Opsview.
#
# Usage:
#    check_openvpn [OPTIONS]...
#
#      -H, --hostname      Host to check
#      -p, --port          Port number to check
#      -h, --help          Display help.
#
#############################################################################

# Custom library path for Nagis modules.
use lib qw ( /usr/local/nagios/perl/lib );

# Enforce sanity.
use strict;
use warnings;

# Required modules.
use Getopt::Long qw(:config no_ignore_case);
use Nagios::Plugin;
use IO::Socket;

# Define defaults.
my $help    = 0;
my $timeout = 5;

# Ensure required variables are set.
my($hostname, $port);

my $options = GetOptions(
                         "hostname|H=s" => \$hostname,
                         "timeout|t=s"  => \$timeout,
                         "port|p=s"     => \$port,
                         "help|h"       => \$help,
);

# Check if help has been requested.
if($help || !$hostname || !$port) {

    printf("\n");
    printf("Usage: check_openvpn [OPTIONS]...\n\n");
    printf("  -H, --hostname      Host to check\n");
    printf("  -p, --port          Port number to check\n");
    printf("  -h, --help          This help page\n");
    printf("  -t, --timeout       Socket timeout\n");
    printf("\n");

    exit(-1);

}

# Setup a new Nagios::Plugin object.
my $nagios = Nagios::Plugin->new();

# Define the check string to send to the OpenVPN server - as binary due
# to non-printable characters.
my $check_string = "001110000011001010010010011011101000000100010001110"
                  ."100110110101010110011000000000000000000000000000000"
                  ."0000000000";

# Attempt to setup a socket to the specified host.
my $host_sock = IO::Socket::INET->new(
                                      Proto    => 'udp',
                                      PeerAddr => $hostname,
                                      PeerPort => $port,
);

# Ensure we have a socket.
if(!$host_sock) {
    $nagios->nagios_exit(UNKNOWN, "Unable to bind socket");
}

# Fire off the check request.
$host_sock->send(pack("B*", $check_string));

# Wait for $timeout for response for a response, otherwise, fail.
my $response;

eval {

    # Define how to handle ALARM.
    local $SIG{ALRM} = sub {
        $nagios->nagios_exit(CRITICAL, "No response received");
    };

    # Set the alarm for the given timeout value.
    alarm($timeout);

    # Check for response.
    $host_sock->recv($response, 1)
      or $nagios->nagios_exit(CRITICAL, "No response received");

    # Alright, response received, cancel alarm.
    alarm(0);
    1;

};

# Reply received, return okay.
$nagios->nagios_exit(OK, "Response received from host");
