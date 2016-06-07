@title = "mx"
@summary = "Incoming and outgoing MX servers."

Topology
-------------------

`mx` nodes communicate with the public internet, clients, and `couchdb` nodes.

Configuration
--------------------

### Aliases

Using the `mx.aliases` property, you can specify your own hard-coded email aliases that precedence over the aliases in the user database. The `mx.aliases` property consists of a hash, where source address points to one or more destination addresses.

For example:

`services/mx.json`:

    "mx": {
      "aliases": {
        "rook": "crow",
        "robin": "robin@bird.org",
        "flock": ["junco@bird.org", "robin", "crow"],
        "chickadee@avian.org": "chickadee@bird.org",
        "flicker": ["flicker@bird.org", "flicker@deliver.local"]
      }
    }

This example demonstrates several of the features with `mx.aliases`:

1. alias lists: by specifying an array of destination addresses, as in the case of "flock", the single email will get copied to each address.
1. chained resolution: alias resolution will recursively continue until there are no more matching aliases. For example, "flock" is resolved to "robin", which then gets resolved to "robin@bird.org".
1. virtual domains: by specifying the full domain, as in the case of "chickadee@avian.org", the alias will work for any domain you want. Of course, the MX record for that domain must point to appropriate MX servers, but otherwise you don't need to do any additional configuration.
1. local delivery: for testing purposes, it is often useful to copy all incoming mail for a particular address and send those copies to another address. You can do this by adding "@deliver.local" as one of the destination addresses. When "@local.delivery" is found, alias resolution stops and the mail is delivered to that username.
