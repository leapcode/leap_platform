#!/usr/bin/perl -w

# check_unix_open_fds Nagios Plugin
#
# TComm - Carlos Peris Pla
#
# This nagios plugin is free software, and comes with ABSOLUTELY 
# NO WARRANTY. It may be used, redistributed and/or modified under 
# the terms of the GNU General Public Licence (see 
# http://www.fsf.org/licensing/licenses/gpl.txt).


# MODULE DECLARATION

use strict;
use Nagios::Plugin;


# FUNCTION DECLARATION

sub CreateNagiosManager ();
sub CheckArguments ();
sub PerformCheck ();


# CONSTANT DEFINITION

use constant NAME => 	'check_unix_open_fds';
use constant VERSION => '0.1b';
use constant USAGE => 	"Usage:\ncheck_unix_open_fds -w <process_threshold,application_threshold> -c <process_threshold,application_threshold>\n".
						"\t\t[-V <version>]\n";
use constant BLURB => 	"This plugin checks, in UNIX systems with the command lsof installed and with its SUID bit activated, the number\n".
						"of file descriptors opened by an application and its processes.\n";
use constant LICENSE => "This nagios plugin is free software, and comes with ABSOLUTELY\n".
						"no WARRANTY. It may be used, redistributed and/or modified under\n".
						"the terms of the GNU General Public Licence\n".
						"(see http://www.fsf.org/licensing/licenses/gpl.txt).\n";
use constant EXAMPLE => "\n\n".
						"Example:\n".
						"\n".
						"check_unix_open_fds -a /usr/local/nagios/bin/ndo2db -w 20,75 -c 25,85\n".
						"\n".
						"It returns CRITICAL if number of file descriptors opened by ndo2db is higher than 85,\n".
						"if not it returns WARNING if number of file descriptors opened by ndo2db is higher \n".
						"than 75, if not it returns CRITICAL if number of file descriptors opened by any process\n".
						"of ndo2db is higher than 25, if not it returns WARNING if number of file descriptors \n".
						"opened by any process of ndo2db is higher than 20.\n".
						"In other cases it returns OK if check has been performed succesfully.\n\n";

								
# VARIABLE DEFINITION

my $Nagios;
my $Error;
my $PluginResult;
my $PluginOutput;
my @WVRange;
my @CVRange;


# MAIN FUNCTION

# Get command line arguments
$Nagios = &CreateNagiosManager(USAGE, VERSION, BLURB, LICENSE, NAME, EXAMPLE);
eval {$Nagios->getopts};

if (!$@) {
	# Command line parsed
	if (&CheckArguments($Nagios, \$Error, \@WVRange, \@CVRange)) {
		# Argument checking passed
		$PluginResult = &PerformCheck($Nagios, \$PluginOutput, \@WVRange, \@CVRange)
	}
	else {
		# Error checking arguments
		$PluginOutput = $Error;
		$PluginResult = UNKNOWN;
	}
	$Nagios->nagios_exit($PluginResult,$PluginOutput);
}
else {
	# Error parsing command line
	$Nagios->nagios_exit(UNKNOWN,$@);
}

		
	
# FUNCTION DEFINITIONS

# Creates and configures a Nagios plugin object
# Input: strings (usage, version, blurb, license, name and example) to configure argument parsing functionality
# Return value: reference to a Nagios plugin object

sub CreateNagiosManager() {
	# Create GetOpt object
	my $Nagios = Nagios::Plugin->new(usage => $_[0], version =>  $_[1], blurb =>  $_[2], license =>  $_[3], plugin =>  $_[4], extra =>  $_[5]);
	
	# Add argument units
	$Nagios->add_arg(spec => 'application|a=s',
				help => 'Application path for which you want to check the number of open file descriptors',
				required => 1);				
	
	# Add argument warning
	$Nagios->add_arg(spec => 'warning|w=s',
				help => "Warning thresholds. Format: <process_threshold,application_threshold>",
				required => 1);
	# Add argument critical
	$Nagios->add_arg(spec => 'critical|c=s',
				help => "Critical thresholds. Format: <process_threshold,application_threshold>",
				required => 1);
								
	# Return value
	return $Nagios;
}


# Checks argument values and sets some default values
# Input: Nagios Plugin object
# Output: reference to Error description string, Memory Unit, Swap Unit, reference to WVRange ($_[4]), reference to CVRange ($_[5])
# Return value: True if arguments ok, false if not

sub CheckArguments() {
	my ($Nagios, $Error, $WVRange, $CVRange) = @_;
	my $commas;
	my $units;
	my $i;
	my $firstpos;
	my $secondpos;
	
	# Check Warning thresholds list
	$commas = $Nagios->opts->warning =~ tr/,//; 
	if ($commas !=1){
		${$Error} = "Invalid Warning list format. One comma is expected.";
		return 0;
	}
	else{
		$i=0;
		$firstpos=0;
		my $warning=$Nagios->opts->warning;
		while ($warning =~ /[,]/g) {
			$secondpos=pos $warning;
			if ($secondpos - $firstpos==1){
				@{$WVRange}[$i] = "~:";
			}		
			else{
				@{$WVRange}[$i] = substr $Nagios->opts->warning, $firstpos, ($secondpos-$firstpos-1);
			}
			$firstpos=$secondpos;
			$i++
		}
		if (length($Nagios->opts->warning) - $firstpos==0){#La coma es el ultimo elemento del string
			@{$WVRange}[$i] = "~:";
		}
		else{
			@{$WVRange}[$i] = substr $Nagios->opts->warning, $firstpos, (length($Nagios->opts->warning)-$firstpos);
		}	
		
		if (@{$WVRange}[0] !~/^(@?(\d+|(\d+|~):(\d+)?))?$/){
			${$Error} = "Invalid Process Warning threshold in ${$WVRange[0]}";
			return 0;
		}if (@{$WVRange}[1] !~/^(@?(\d+|(\d+|~):(\d+)?))?$/){
			${$Error} = "Invalid Application Warning threshold in ${$WVRange[1]}";
			return 0;
		}
	}
	
	# Check Critical thresholds list
	$commas = $Nagios->opts->critical =~ tr/,//; 
	if ($commas !=1){
		${$Error} = "Invalid Critical list format. One comma is expected.";
		return 0;
	}
	else{
		$i=0;
		$firstpos=0;
		my $critical=$Nagios->opts->critical;
		while ($critical  =~ /[,]/g) {
			$secondpos=pos $critical ;
			if ($secondpos - $firstpos==1){
				@{$CVRange}[$i] = "~:";
			}		
			else{
				@{$CVRange}[$i] =substr $Nagios->opts->critical, $firstpos, ($secondpos-$firstpos-1);
			}
			$firstpos=$secondpos;
			$i++
		}
		if (length($Nagios->opts->critical) - $firstpos==0){#La coma es el ultimo elemento del string
			@{$CVRange}[$i] = "~:";
		}
		else{
			@{$CVRange}[$i] = substr $Nagios->opts->critical, $firstpos, (length($Nagios->opts->critical)-$firstpos);
		}		

		if (@{$CVRange}[0] !~/^(@?(\d+|(\d+|~):(\d+)?))?$/) {
			${$Error} = "Invalid Process Critical threshold in @{$CVRange}[0]";
			return 0;
		}
		if (@{$CVRange}[1] !~/^(@?(\d+|(\d+|~):(\d+)?))?$/) {
			${$Error} = "Invalid Application Critical threshold in @{$CVRange}[1]";
			return 0;
		}
	}
	
	return 1;
}


# Performs whole check: 
# Input: Nagios Plugin object, reference to Plugin output string, Application, referece to WVRange, reference to CVRange
# Output: Plugin output string
# Return value: Plugin return value

sub PerformCheck() {
	my ($Nagios, $PluginOutput, $WVRange, $CVRange) = @_;
	my $Application;
	my @AppNameSplitted;
	my $ApplicationName;
	my $PsCommand;
	my $PsResult;
	my @PsResultLines;
	my $ProcLine;
	my $ProcPid;
	my $LsofCommand;
	my $LsofResult;
	my $ProcCount = 0;
	my $FDCount = 0;
	my $ProcFDAvg = 0;
	my $PerProcMaxFD = 0;
	my $ProcOKFlag = 0;
	my $ProcWarningFlag = 0;
	my $ProcCriticalFlag = 0;
	my $OKFlag = 0;
	my $WarningFlag = 0;
	my $CriticalFlag = 0;
	my $LastWarningProcFDs = 0;
	my $LastWarningProc = -1;
	my $LastCriticalProcFDs = 0;
	my $LastCriticalProc = -1;
	my $ProcPluginReturnValue = UNKNOWN;
	my $AppPluginReturnValue = UNKNOWN;
 	my $PluginReturnValue = UNKNOWN;
 	my $PerformanceData = "";
	my $PerfdataUnit = "FDs";
	
	$Application = $Nagios->opts->application;
	$PsCommand = "ps -eaf | grep $Application";
	$PsResult = `$PsCommand`;
	@AppNameSplitted = split(/\//, $Application);
	$ApplicationName = $AppNameSplitted[$#AppNameSplitted];
	@PsResultLines = split(/\n/, $PsResult);
	if ( $#PsResultLines > 1 ) {
	    foreach my $Proc (split(/\n/, $PsResult)) {
		if ($Proc !~ /check_unix_open_fds/ && $Proc !~ / grep /) {
				$ProcCount += 1;
			    $ProcPid = (split(/\s+/, $Proc))[1];
			    $LsofCommand = "lsof -p $ProcPid | wc -l";
			    $LsofResult = `$LsofCommand`;
			    $LsofResult = ($LsofResult > 0 ) ? ($LsofResult - 1) : 0;
			    $FDCount += $LsofResult;
			    if ($LsofResult >= $PerProcMaxFD) { $PerProcMaxFD = $LsofResult; }
			    $ProcPluginReturnValue = $Nagios->check_threshold(check => $LsofResult,warning => @{$WVRange}[0],critical => @{$CVRange}[0]);
			    if ($ProcPluginReturnValue eq OK) {
			    	$ProcOKFlag = 1;
			    }
			    elsif ($ProcPluginReturnValue eq WARNING) {
					$ProcWarningFlag = 1;
					if ($LsofResult >= $LastWarningProcFDs) {
					    $LastWarningProcFDs = $LsofResult;
					    $LastWarningProc = $ProcPid;
					}
			    }
				#if ($LsofResult >= $PCT) {
				elsif ($ProcPluginReturnValue eq CRITICAL) {
				    $ProcCriticalFlag = 1;
				    if ($LsofResult >= $LastCriticalProcFDs) {
						$LastCriticalProcFDs = $LsofResult;
						$LastCriticalProc = $ProcPid;
				    }
				}
		    }
	    }
	    if ($ProcCount) { $ProcFDAvg = int($FDCount / $ProcCount); }
	    $AppPluginReturnValue = $Nagios->check_threshold(check => $FDCount,warning => @{$WVRange}[1],critical => @{$CVRange}[1]);
	    #if ($FDCount >= $TWT) {
	    if ($AppPluginReturnValue eq OK) { $OKFlag = 1; }
	    elsif ($AppPluginReturnValue eq WARNING) { $WarningFlag = 1; }
	    elsif ($AppPluginReturnValue eq CRITICAL) { $CriticalFlag = 1; }
	
	    # PluginReturnValue and PluginOutput
	    if ($CriticalFlag) {
	    	$PluginReturnValue = CRITICAL;
			${$PluginOutput} .= "$ApplicationName handling $FDCount files (critical threshold set to @{$CVRange}[1])";
	    }
	    elsif ($WarningFlag) {
	    	$PluginReturnValue = WARNING;
			${$PluginOutput} .= "$ApplicationName handling $FDCount files (warning threshold set to @{$WVRange}[1])";
	    }
	    elsif ($ProcCriticalFlag) {
	    	$PluginReturnValue = CRITICAL;
			${$PluginOutput} .= "Process ID $LastCriticalProc handling $LastCriticalProcFDs files (critical threshold set to @{$CVRange}[0])";
	    }
	    elsif ($ProcWarningFlag) {
	    	$PluginReturnValue = WARNING;
			${$PluginOutput} .= "Process ID $LastWarningProc handling $LastWarningProcFDs files (warning threshold set to @{$WVRange}[0])";
	    }
	    elsif ($OKFlag && $ProcOKFlag) {
	    	$PluginReturnValue = OK;
			${$PluginOutput} .= "$ApplicationName handling $FDCount files";
	    }
	}
	else {
	    ${$PluginOutput} .= "No existe la aplicacion $ApplicationName";
	}

     
	$PerformanceData .= "ProcCount=$ProcCount$PerfdataUnit FDCount=$FDCount$PerfdataUnit ProcFDAvg=$ProcFDAvg$PerfdataUnit PerProcMaxFD=$PerProcMaxFD$PerfdataUnit";

	# Output with performance data:
	${$PluginOutput} .= " | $PerformanceData";

 	return $PluginReturnValue;
}
