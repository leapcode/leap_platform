#!/usr/bin/env python

# Inspired by Arne Schwabe <arne-nagios@rfc2549.org> [with BSD license]
# Inspired by backupninja [that's gpl some version]
# minor changes by someon who doesn't understand all the license quirks

from subprocess import Popen,PIPE
import sys
import time
import os
import argparse
import getopt

def main():
    # getopt = much more writing
    parser = argparse.ArgumentParser(description='Nagios Duplicity status checker')

    parser.add_argument("-w", dest="warninc", default=28, type=int, 
                        help="Number of hours allowed for incremential backup warning level, default 28")
    parser.add_argument("-W", dest="warnfull", default=31, type=int, 
                        help="Number of days allowed for full backup warning level, default 31")
    parser.add_argument("-c", dest="critinc", default=52, type=int, 
                        help="Number of hours allowed for incremential backup critical level, default 52")
    parser.add_argument("-C", dest="critfull", default=33, type=int, 
                        help="Number of days allowed for full backup critical level, default 33")
    args = parser.parse_args()
    
    okay = 0

    # *sigh* check_output is from python 2.7 and onwards. Debian, upgrade yourself.
    #output , err = check_output(['/root/freshness.sh'])

    if os.path.isfile("/usr/lib/nagios/plugins/backupninja_duplicity_freshness.sh") and os.access("/usr/lib/nagios/plugins/backupninja_duplicity_freshness.sh", os.X_OK):
      checkstatus, err = Popen(['/bin/bash', '/usr/lib/nagios/plugins/backupninja_duplicity_freshness.sh'], stdout=PIPE, stderr=PIPE, env={'HOME': '/root', 'PATH': os.environ['PATH']}).communicate()
    elif os.path.isfile("/usr/local/lib/nagios/plugins/backupninja_duplicity_freshness.sh") and os.access("/usr/local/lib/nagios/plugins/backupninja_duplicity_freshness.sh", os.X_OK):
      checkstatus, err = Popen(['/bin/bash', '/usr/local/lib/nagios/plugins/backupninja_duplicity_freshness.sh'], stdout=PIPE, stderr=PIPE, env={'HOME': '/root', 'PATH': os.environ['PATH']}).communicate()

    # Don't use exec(), popen(), etc. to execute external commands without explicity using the full path of the external program.  Hijacked search path could be problematic.
    #checkstatus, err = Popen(['/bin/bash', './freshness.sh'], stdout=PIPE, stderr=PIPE, env={'HOME': '/root', 'PATH': os.environ['PATH']}).communicate()

    #another sigh: Debian testing, upgrade yourself, this is only needed because Debian testing uses duplicity 0.6.18-3 
    # open file read/write
    f = open (checkstatus,"r")
    checklines = f.readlines()
    f.close()

    # remove the line that says Import of duplicity.backends.giobackend Failed: No module named gio
    f = open(checkstatus,"w")
    for line in checklines:
      if not 'Import of duplicity.backends.giobackend Failed: No module named gio' in line:
        f.write(line)
    f.close()

    output = open(checkstatus).read()

    lastfull, lastinc = findlastdates(output)

    sincelastfull = time.time() - lastfull 
    sincelastinc  =  time.time() - lastinc 

    msg = "OK: "
    
    if sincelastfull > (args.warnfull * 24 * 3600) or sincelastinc > (args.warninc * 3600):
        okay = 1
        msg = "WARNING: "
    if sincelastfull > (args.critfull * 24 * 3600) or sincelastinc > (args.critinc * 3600):
        okay = 2
        msg = "CRITICAL: "
    if not checkoutput(output):
        okay = max(okay,1)
        msg = "WARNING: duplicity output: %s " % repr(output)
    if err:
        okay=2
        msg = "Unexpected output: %s, " % repr(err)

    print msg, "last full %s ago, last incremential %s ago|lastfull=%d, lastinc=%d" % ( formattime(sincelastfull), formattime(sincelastinc), sincelastfull, sincelastinc)
    
    #clean up cruft
    os.remove(checkstatus)
    sys.exit(okay)

def checkoutput(output):
    if not 'No orphaned or incomplete backup sets found.' in output:
        return False
    
    return True

def formattime(seconds):
    days = seconds / (3600 * 24)
    hours = seconds / 3600 % 24

    if days:
        return "%d days %d hours" % (days,hours)
    else:
        return "%d hours" % hours


def findlastdates(output):
    lastfull = 0
    lastinc = 0

    for line in output.split("\n"):
        parts = line.split()

        # ['Incremental', 'Sun', 'Oct', '31', '03:00:04', '2010', '1']
        if len (parts) == 7 and parts[0] in ["Full","Incremental"]:
            foo = time.strptime(" ".join(parts[1:6]),"%a %b %d %H:%M:%S %Y")
    
            backuptime =  time.mktime(foo)
    
            if parts[0] == "Incremental" and lastinc < backuptime:
                lastinc = backuptime
            elif parts[0] == "Full" and lastfull < backuptime:
                lastfull = backuptime
        

    # Count a full backup as incremental backup
    lastinc = max(lastfull,lastinc)
    return (lastfull, lastinc)
	

if __name__=='__main__':
   main()
