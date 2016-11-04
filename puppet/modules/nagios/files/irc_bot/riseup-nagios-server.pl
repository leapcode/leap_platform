#!/usr/bin/perl -w

# ##############################################################################
# a simple IRC bot which dispatches messages received via local domain sockets
# ##############################################################################


######
## THIS NEEDS TO BE PORTED TO THE NEW FRAMEWORKS!
##
## STICKY POINTS: the addfh() function doesn't exist in BasicBot or POE::Component::IRC
##
## people suggested we use Anyevent::IRC and POE::Kernel ->select_read and POE::Wheel namespace
##
## in the meantime, inspiration for extensions can be found here: http://svn.foswiki.org/trunk/WikiBot/mozbot.pl

use strict;
use File::Basename;

BEGIN {
	unshift @INC, dirname($0);
}

my $VERSION = '0.2';
my $running = 1;

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

use POSIX qw(setsid);
use IO::Socket;
use Net::IRC;

sub new {
	my $self = {
		socket => undef,
		irc => undef,
		conn => undef,
		commandfile => undef,
	};

	return bless($self, __PACKAGE__);
}

sub daemonize {
	my $self = shift;
	my $pid;

	chdir '/' or die "Can't chdir to /: $!";

	open STDIN, '/dev/null' or die "Can't read /dev/null: $!";
	open STDOUT, '>/dev/null' or die "Can't write to /dev/null: $!";

	defined ($pid = fork) or die "Can't fork: $!";

	if ($pid && $CFG::Nsa{'pidfile'}) { # write pid of child
		open PID, ">$CFG::Nsa{'pidfile'}" or die "Can't open pid file: $!";
		print PID $pid;
		close PID;
	}
	exit if $pid;
	setsid or die "Can't start a new session: $!";

	#open STDERR, '>&STDOUT' or die "Can't dup stdout: $!";
}

sub run {
	my $self = shift;

	$self->{irc}->do_one_loop();
}

sub shutdown {
	my $sig = shift;

	print STDERR "Received SIG$sig, shutting down...\n";
	$running = 0;
}

sub socket_has_data {
    my $self = shift;
    
    $self->{socket}->recv(my $data, 1024);
    if ($CFG::Nsa{'usenotices'}) {
	$self->{conn}->notice($CFG::Nsa{'channel'}, $data);
    } else {
	$self->{conn}->privmsg($CFG::Nsa{'channel'}, $data);
    }
}

sub irc_on_connect {
	my $self = shift;

	print STDERR "Joining channel '$CFG::Nsa{'channel'}'...\n";
	$self->join($CFG::Nsa{'channel'});
}

sub irc_on_msg {
    my ($self, $event) = @_;
    my $data = join(' ', $event->args);
    #my $nick = quotemeta($nicks[$nick]);
    my $to = $event->to;
    #my $channel = &toToChannel($self, @$to);
    #my $cmdChar = $commandChar{default}; # FIXME: should look up for CURRENT channel first!
    #if ( exists $commandChar{$channel} ) { $cmdChar = $commandChar{$channel}; }
    my $msg = parse_msg($event);
    if (defined($msg)) {
      #$self->privmsg($event->nick, "alright, sending this message to nagios, hope it figures it out: $msg");
    } else {
      $self->privmsg($event->nick, "can't parse $data, you want 'ack host service comment'\n");
    }
}

sub irc_on_public {
    my ($self, $event) = @_;
    my $data = join(' ', $event->args);
    my $to = $event->to;
    if ($data =~ s/([^:]*):\s+//) {
      if ($1 eq $CFG::Nsa{'nickname'}) {
        my $msg = parse_msg($event);
        if (defined($msg)) {
          #$self->privmsg($event->to, "alright, sending this message to nagios, hope it figures it out: $msg");
        } else {
          $self->privmsg($event->to, "can't parse $data, you want 'ack host service comment'\n");
        }
      } else {
        #print STDERR "ignoring message $data, not for me (me being $1)\n";
      }
    } else {
      #print STDERR "ignoring message $data\n";
    }
}

sub parse_msg {
    my $event= shift;
    my $data = join(' ', $event->args);
    my $msg;
    if ($data =~ m/([^:]*:)?\s*ack(?:knowledge)?\s+([a-zA-Z0-9\-\.]+)(?:\s+([-\w\.]+)(?:\s+([\w\s]+))?)?/) {
      #print STDERR "writing to nagios scoket ". $CFG::Nsa{'commandfile'} . "\n";
      open(my $cmdfile, ">", $CFG::Nsa{'commandfile'}) || die "Can't open Nagios commandfile: $CFG::Nsa{'commandfile'}!\n";
      my $host = $2;
      my ($service, $comment) = (undef, "no comment (from irc)");
      if ($4) {
        $service = $3;
	$comment = $4;
      } elsif ($3) {
        $service = $3;
      }
      my $user = $event->nick;
      $msg = '[' . time() . '] ';
      if (defined($service)) {
        $msg .= "ACKNOWLEDGE_SVC_PROBLEM;$host;$service;1;1;1;$user;$comment\n";
      } else {
        $msg .= "ACKNOWLEDGE_HOST_PROBLEM;$host;1;1;1;$user;$comment\n";
      }
      print {$cmdfile} $msg;
      close($cmdfile);
    }
    return $msg;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

my $bot = &new;

if (-e $CFG::Nsa{'socket'}) {
	die "Socket '$CFG::Nsa{'socket'}' exists!\n";
}

$bot->{socket} = IO::Socket::UNIX->new (
	Local  => $CFG::Nsa{'socket'},
	Type   => SOCK_DGRAM,
	Listen => 5
) || die "Can't create socket '$CFG::Nsa{'socket'}'!\n";

$SIG{INT} = $SIG{TERM} = \&shutdown;

$bot->daemonize();
$bot->{irc} = new Net::IRC;

$bot->{conn} = $bot->{irc}->newconn (
	Server   => $CFG::Nsa{'server'},
	Port     => $CFG::Nsa{'port'},
	Nick     => $CFG::Nsa{'nickname'},
	Username => $CFG::Nsa{'nickname'},
	Password => $CFG::Nsa{'password'},
	Ircname  => $CFG::Nsa{'realname'} . " (NSA $VERSION)",
) || die "Can't connect to server '$CFG::Nsa{'server'}'!\n";

$bot->{conn}->add_global_handler(376, \&irc_on_connect);
$bot->{conn}->add_global_handler('nomotd', \&irc_on_connect);
$bot->{conn}->add_global_handler('msg', \&irc_on_msg);
$bot->{conn}->add_global_handler('public', \&irc_on_public);
#$bot->{conn}->add_global_handler('notice', \&irc_on_msg);
$bot->{irc}->addfh($bot->{socket}, \&socket_has_data, 'r', $bot);

while ($running) {
	$bot->run();
}

close($bot->{socket});
unlink($CFG::Nsa{'socket'});

exit(0);

1;

__END__
