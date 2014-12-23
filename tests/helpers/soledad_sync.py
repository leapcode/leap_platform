#!/usr/bin/env python

#
# Test Soledad sync
#
# This script performs a slightly modified U1DB sync to the Soledad server and
# returns whether that sync was successful or not.
#
# It takes three arguments:
#
#   uuid   -- uuid of the user to sync
#   token  -- a valid session token
#   server -- the url of the soledad server we should connect to
#
# For example:
#
#   soledad_sync.py f6bef0586fcfdb8705e26a58f2d9e580 uYO-4ucEJFksJ6afjmcYwIyap2vW7bv6uLxk0w_RfCc https://199.119.112.9:2323/user-f6bef0586fcfdb8705e26a58f2d9e580
#

import os
import sys
import traceback
import tempfile
import shutil
import u1db

from u1db.remote.http_target import HTTPSyncTarget

#
# monkey patch U1DB's HTTPSyncTarget to perform token based auth
#

def set_token_credentials(self, uuid, token):
    self._creds = {'token': (uuid, token)}

def _sign_request(self, method, url_query, params):
    uuid, token = self._creds['token']
    auth = '%s:%s' % (uuid, token)
    return [('Authorization', 'Token %s' % auth.encode('base64')[:-1])]

HTTPSyncTarget.set_token_credentials = set_token_credentials
HTTPSyncTarget._sign_request = _sign_request

#
# Create a temporary local u1db replica and attempt to sync to it.
# Returns a failure message if something went wrong.
#

def soledad_sync(uuid, token, server):
    tempdir = tempfile.mkdtemp()
    try:
        db = u1db.open(os.path.join(tempdir, '%s.db' % uuid), True)
        creds = {'token': {'uuid': uuid, 'token': token}}
        db.sync(server, creds=creds, autocreate=False)
    finally:
        shutil.rmtree(tempdir)

#
# exit codes:
#
# 0 - OK
# 1 - WARNING
# 2 - ERROR
#

if __name__ == '__main__':
    try:
        uuid, token, server = sys.argv[1:]
        result = soledad_sync(uuid, token, server)
        if result is None:
            exit(0)
        else:
            print(result)
            exit(1)
    except Exception as exc:
        print(exc.message or str(exc))
        traceback.print_exc(file=sys.stdout)
        exit(2)
