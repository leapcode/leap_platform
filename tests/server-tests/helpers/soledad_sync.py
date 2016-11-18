#!/usr/bin/env python
"""
soledad_sync.py

This script exercises soledad synchronization.
Its exit code is 0 if the sync took place correctly, 1 otherwise.

It takes 5 arguments:

  uuid: uuid of the user to sync
  token: a valid session token
  server: the url of the soledad server we should connect to
  cert_file: the file containing the certificate for the CA that signed the
             cert for the soledad server.
  password: the password for the user to sync

__author__: kali@leap.se
"""
import os
import shutil
import sys
import tempfile

# This is needed because the twisted shipped with wheezy is too old
# to do proper ssl verification.
os.environ['SKIP_TWISTED_SSL_CHECK'] = '1'

from twisted.internet import defer, reactor
from twisted.python import log

from client_side_db import get_soledad_instance
from leap.common.events import flags

flags.set_events_enabled(False)

NUMDOCS = 1
USAGE = "Usage: %s uuid token server cert_file password" % sys.argv[0]
SYNC_TIMEOUT = 60


def bail(msg, exitcode):
    print "[!] %s" % msg
    sys.exit(exitcode)


def create_docs(soledad):
    """
    Populates the soledad database with dummy messages, so we can exercise
    sending payloads during the sync.
    """
    deferreds = []
    for index in xrange(NUMDOCS):
        deferreds.append(soledad.create_doc({'payload': 'dummy'}))
    return defer.gatherResults(deferreds)

# main program

if __name__ == '__main__':

    tempdir = tempfile.mkdtemp()

    def rm_tempdir():
        shutil.rmtree(tempdir)

    if len(sys.argv) < 6:
        bail(USAGE, 2)

    uuid, token, server, cert_file, passphrase = sys.argv[1:]
    s = get_soledad_instance(
        uuid, passphrase, tempdir, server, cert_file, token)

    def syncWithTimeout(_):
        d = s.sync()
        reactor.callLater(SYNC_TIMEOUT, d.cancel)
        return d

    def onSyncDone(sync_result):
        print "SYNC_RESULT:", sync_result
        s.close()
        rm_tempdir()
        reactor.stop()

    def trap_cancel(f):
        f.trap(defer.CancelledError)
        log.err("sync timed out after %s seconds" % SYNC_TIMEOUT)
        rm_tempdir()
        reactor.stop()

    def log_and_exit(f):
        log.err(f)
        rm_tempdir()
        reactor.stop()

    def start_sync():
        d = create_docs(s)
        d.addCallback(syncWithTimeout)
        d.addCallback(onSyncDone)
        d.addErrback(trap_cancel)
        d.addErrback(log_and_exit)

    reactor.callWhenRunning(start_sync)
    reactor.run()
