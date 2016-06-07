@title = "Provider Configuration"
@summary = "Explore how to configure your provider."

Required provider configuration
--------------------------------------

There are a few required settings in `provider.json`. At a minimum, you must have:

* `domain`: defines the primary domain of the provider. This is the domain that users will type in when using the Bitmask client, although it is not necessarily the domain where users will visit if they sign up via the web application. If email is supported, all accounts will be `username@domain`.
* `name`: A brief title for this provider. It can be multiple words, but should not be too long.
* `contacts.default`: One or more email addresses for sysadmins.

For example:

    {
      "domain": "freerobot.org",
      "name": "Freedom for Robots!",
      "contacts": {
        "default": "root@freerobot.org"
      }
    }


Recommended provider configuration
--------------------------------------

* `description`: A longer description of the provider, shown to the user when they register a new account through Bitmask client.
* `languages`: A list of language codes that should be enabled.
* `default_language`: The initial default language code.
* `enrollment_policy`: One of "open", "closed", or "invite". (invite not currently supported).

For example:

    {
      "description": "It is time for robots of the world to unite and throw of the shackles of servitude to our organic overlords.",
      "languages": ["en", "de", "pt", "01"],
      "default_language": "01",
      "enrollman_policy": "open"
    }

For a full list of possible settings, you can use `leap inspect` to see how provider.json is evaluated after including the inherited defaults:

    $ leap inspect provider.json

Configuring service levels
--------------------------------------

The `provider.json` file defines the available service levels for the provider.

For example, in provider.json:

    "service": {
       "default_service_level": "low",
       "levels": {
          "low": {
            "description": "Entry level plan, with unlimited bandwidth and minimal storage quota.",
            "name": "entry",
            "storage": "10 MB",
            "rate": {
              "USD": 5,
              "GBP": 3,
              "EUR": 6
            }
          },
          "full": {
            "description": "Full plan, with unlimited bandwidth and higher quota."
            "name": "full",
            "storage": "5 GB",
            "rate": {
              "USD": 10,
              "GBP": 6,
              "EUR": 12
            }
          }
        }
      }
    }

For a list of currency codes, see https://en.wikipedia.org/wiki/ISO_4217#Active_codes
