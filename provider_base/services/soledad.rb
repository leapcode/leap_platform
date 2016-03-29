unless self.services.include? "couchdb"
  LeapCli.log :error, "service `soledad` requires service `couchdb` on the same node (node #{self.name})."
end

#
# currently, mx tests keep the same test user around,
# by rely on the soledad test to destroy the email
# test user's mail storage (so that it does not just
# keep accumulating test emails).
#
# We do it this way because:
#
# (1) couchdb bloats if you create and destroy test users,
#     so we keep the test user around.
#
# (2) the mx test has access to the bonafide api, but the
#     bonafide api (webapp) does not have access to destroy
#     user storage dbs.
#
# If any of these conditions change, then this partial
# will no longer be required.
#
apply_partial('services/_api_tester.json')