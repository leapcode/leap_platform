#!/usr/bin/perl -w

# This script is designed to check a backup directory populated with
# subdirectories named after hosts, within which there are backups of various
# types.
#
# Example:
# /home/backup:
# foo.example.com
# 
# foo.example.com:
# rdiff-backup .ssh
#
# rdiff-backup:
# root home rdiff-backup-data usr var
#
# There are heuristics to determine the backup type. Currently, the following
# types are supported:
#
# rdiff-backup: assumes there is a rdiff-backup/rdiff-backup-data/backup.log file
# duplicity: assumes there is a dup subdirectory, checks the latest file
# dump files: assumes there is a dump subdirectory, checks the latest file
#
# This script returns output suitable for send_nsca to send the results to
# nagios and should therefore be used like this:
#
# checkbackups.sh | send_nsca -H nagios.example.com

use Getopt::Std;

# XXX: taken from utils.sh from nagios-plugins-basic
my $STATE_OK=0;
my $STATE_WARNING=1;
my $STATE_CRITICAL=2;
my $STATE_UNKNOWN=3;
my $STATE_DEPENDENT=4;
my %ERRORS=(0=>'OK',1=>'WARNING',2=>'CRITICAL',3=>'UNKNOWN',4=>'DEPENDENT');

# gross hack: we look into subdirs to find vservers
my @vserver_dirs = qw{/var/lib/vservers /vservers};

our $opt_d = "/backup";
our $opt_c = 48 * 60 * 60;
our $opt_w = 24 * 60 * 60;
our $opt_v = 0;
our $opt_o;
our $opt_s;

if (!getopts('d:c:w:s:vo')) {
	print <<EOF
Usage: $0 [ -d <backupdir> ] [ -c <threshold> ] [ -w <threshold> ] [ -o ] [ -s <host> ] [ -v ]
EOF
	;
	exit();
}

sub check_rdiff {
    my ($host, $dir, $optv) = @_;
    my $flag="$dir/rdiff-backup-data/backup.log";
    my $extra_msg = '';
    my @vservers;
    if (open(FLAG, $flag)) {
        while (<FLAG>) {
            if (/EndTime ([0-9]*).[0-9]* \((.*)\)/) {
                $last_bak = $1;
                $extra_msg = ' [backup.log]';
                $opt_v && print STDERR "found timestamp $1 ($2) in $flag\n";
            }
        }
        if (!$last_bak) {
            print_status($host, $STATE_UNKNOWN, "cannot parse $flag for a valid timestamp");
            next;
        }
    } else {
        $opt_v && print STDERR "cannot open $flag\n";
    }
    close(FLAG);
    ($state, $delta) = check_age($last_bak);
    $dir =~ /([^\/]+)\/?$/;
    $service = "backups-$1";
    print_status($host, $state, "$delta hours old$extra_msg", $service);
    foreach my $vserver_dir (@vserver_dirs) {
        $vsdir = "$dir/$vserver_dir";
        if (opendir(DIR, $vsdir)) {
            @vservers = grep { /^[^\.]/ && -d "$vsdir/$_" } readdir(DIR);
            $opt_v && print STDERR "found vservers $vsdir: @vservers\n";
            closedir DIR;
        } else {
            $opt_v && print STDERR "no vserver in $vsdir\n";
        }
    }
    my @dom_sufx = split(/\./, $host);
    my $dom_sufx = join('.', @dom_sufx[1,-1]);
    foreach my $vserver (@vservers) {
        print_status("$vserver.$dom_sufx", $state, "$delta hours old$extra_msg, same as parent: $host");
    }
}

sub check_age {
    my ($last_bak) = @_;
    my $t = time();
    my $delta = $t - $last_bak;
    if ($delta > $opt_c) {
        $state = $STATE_CRITICAL;
    } elsif ($delta > $opt_w) {
        $state = $STATE_WARNING;
    } elsif ($delta >= 0) {
        $state = $STATE_OK;
    }
    $delta = sprintf '%.2f', $delta/3600.0;
    return ($state, $delta);
}

sub print_status {
    my ($host, $state, $message, $service) = @_;
    my $state_msg = $ERRORS{$state};
    if (!$service) {
        $service = 'backups';
    }
    $line = "$host\t$service\t$state\t$state_msg $message\n";
    if ($opt_s) {
	$opt_v && print STDERR "sending results to nagios...\n";
        open(NSCA, "|/usr/sbin/send_nsca -H $opt_s") or die("cannot start send_nsca: $!\n");
        print NSCA $line;
        close(NSCA) or warn("could not close send_nsca pipe correctly: $!\n");
    }
    if (!$opt_s || $opt_v) {
        printf $line;
    }
}

sub check_flag {
    my ($host, $flag) = @_;
    my @stats = stat($flag);
    if (not @stats) {
        print_status($host, $STATE_UNKNOWN, "cannot stat flag $flag");
    }
    else {
        ($state, $delta) = check_age($stats[9]);
        print_status($host, $state, "$delta hours old");
    }
}

my $backupdir= $opt_d;

my @hosts;
if (defined($opt_o)) {
	@hosts=qx{hostname -f};
} else {
	# XXX: this should be a complete backup registry instead
	@hosts=qx{ls $backupdir | grep -v lost+found};
}

chdir($backupdir);
my ($delta, $state, $host);
foreach $host (@hosts) {
	chomp($host);
	if ($opt_o) {
		$dir = $backupdir;
	} else {
		$dir = $host;
	}
	my $flag;
	if (-d $dir) {
                # guess the backup type and find a proper stamp file to compare
                @rdiffs = glob("$dir/*/rdiff-backup-data");
                foreach $subdir (@rdiffs) {
                    $subdir =~ s/rdiff-backup-data$//;
                    $opt_v && print STDERR "inspecting dir $subdir\n";
                    check_rdiff($host, $subdir, $opt_v);
                    $flag = 1;
                }
		if (-d "$dir/dump") {
			# XXX: this doesn't check backup consistency
			$flag="$dir/dump/" . `ls -tr $dir/dump | tail -1`;
			chomp($flag);
			check_flag($host, $flag);
		} elsif (-d "$dir/dup") {
			# XXX: this doesn't check backup consistency
			$flag="$dir/dup/" . `ls -tr $dir/dup | tail -1`;
			chomp($flag);
			check_flag($host, $flag);
		} elsif (-r "$dir/rsync.log") {
			# XXX: this doesn't check backup consistency
			$flag="$dir/rsync.log";
			check_flag($host, $flag);
		}
                if (!$flag) {
                        print_status($host, $STATE_UNKNOWN, 'unknown system');
		}
	} else {
            print_status($host, $STATE_UNKNOWN, 'no directory');
	}
}
