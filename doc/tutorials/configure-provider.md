@title = 'Configure provider tutorial'
@nav_title = 'Configure Provider'
@summary = 'Explore how to configure your provider after the initial setup'


Edit provider.json configuration
--------------------------------------

There are a few required settings in provider.json. At a minimum, you must have:

    {
      "domain": "example.org",
      "name": "Example",
      "contacts": {
        "default": "email1@example.org"
      }
    }

For a full list of possible settings, you can use `leap inspect` to see how provider.json is evaluated after including the inherited defaults:

    $ leap inspect provider.json


Examine Certs
=============

To see details about the keys and certs that the prior two commands created, you can use `leap inspect` like so:

    $ leap inspect files/ca/ca.crt

NOTE: the files `files/ca/*.key` are extremely sensitive and must be carefully protected. The other key files are much less sensitive and can simply be regenerated if needed.
