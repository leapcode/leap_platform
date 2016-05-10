@title = "Domains"
@summary = "How to handle domain names and integrating LEAP with existing services."
@toc = true

Overview
--------------------------------

Deploying LEAP can start to get very tricky when you need to integrate LEAP services with an existing domain that you already use or which already has users. Most of this complexity is unavoidable, although there are a few things we plan to do in the future to make this a little less painful.

Because integration with legacy systems is an advanced topic, we recommend that you begin with a new domain. Once everything works and you are comfortable with your LEAP-powered infrastructure, you can then contemplate integrating with your existing domain.

### Definitions

**provider domain**

This is the main domain used to identify the provider. The **provider domain** is what the user enters in the Bitmask client. e.g. `example.org`. The full host name of every node in your provider infrastructure will use the **provider domain** (e.g. `dbnode.example.org`).

In order for the Bitmask client to get configured for use with a provider, it must be able to find the `provider.json` bootstrap file at the root of the **provider domain**. This is not needed if the Bitmask client is "pre-seeded" with the provider's information (these providers show up in a the initial list of available providers).

**webapp domain**

This is the domain that runs the leap_web application that allows users to register accounts, create help tickets, etc. e.g. `example.org` or `user.example.org`. The **webapp domain** defaults to the **provider domain** unless it is explicitly configured separately.

**API domain**

This is the domain that the provider API runs on. Typically, this is set automatically and you never need to configure it. The user should never be aware of this domain. e.g. `api.example.org`. The Bitmask client discovers this API domain by reading it from the `provider.json` file it grabs from the **provider domain**.

**mail domain**

This is the domain used for mail accounts, e.g. `username@example.org`. Currently, this is always the **provider domain**, but it may be independently configurable in the future.

Generating a zone file
-----------------------------------

Currently, the platform does not include a dedicated `dns` service type, so you need to have your own setup for DNS. You can generate the appropriate configuration options with this command:

    leap compile zone

A single domain
-------------------------------

The easy approach is to use a single domain for **provider domain**, **webapp domain**, and **email domain**. This will install the webapp on the **provider domain**, which means that this domain must be a new one that you are not currently using for anything.

To configure a single domain, just set the domain in `provider.json`:

    {
      "domain": "example.org"
    }

If you have multiple environments, you can specify a different **provider domain** for each environment. For example:

`provider.staging.json`

    {
      "domain": "staging.example.org"
    }

A separate domain for the webapp
--------------------------------------

It is possible make the **webapp domain** different than the **provider domain**. This is needed if you already have a website running at your **provider domain**.

In order to put webapp on a different domain, you must take two steps:

1. You must configure `webapp.domain` for nodes with the `webapp` service.
2. You must make the compiled `provider.json` available at the root of the **provider domain**.

NOTE: This compiled provider.json is different than the provider.json that you edit and lives in the root of the provider directory.

### Step 1. Configuring `webapp.domain`

In `services/webapp.json`:

    {
      "webapp": {
        "domain": "user.example.org"
      }
    }

### Step 2. Putting the compiled `provider.json` in place

Generate the compiled `provider.json`:

    leap compile provider.json
    = created files/web/bootstrap/
    = created files/web/bootstrap/README
    = created files/web/bootstrap/production/
    = created files/web/bootstrap/production/provider.json
    = created files/web/bootstrap/production/htaccess
    = created files/web/bootstrap/staging/
    = created files/web/bootstrap/staging/provider.json
    = created files/web/bootstrap/staging/htaccess

This command compiles a separate `provider.json` for each environment, or "default" if you don't have an environment. In the example above, there is an environment called "production" and one called "staging", but your setup will probably differ.

The resulting `provider.json` file must then be put at the root URL of your **provider domain** for the appropriate environment.

There is one additional complication: currently, the Bitmask client tests for compatibility using some HTTP headers on the `/provider.json` response. This is will hopefully change in the future, but for now you need to ensure the right headers are set in the response. The included file `htaccess` has example directives for Apache, if that is what you use.

This step can be skipped if you happen to use the `static` service to deploy an `amber` powered static website to **provider domain**. In this case, the correct `provider.json` will be automatically put into place.

Integrating with existing email system
-----------------------------------------

If your **mail domain** already has users from a legacy email system, then things get a bit complicated. In order to be able to support both LEAP-powered email and legacy email on the same domain, you need to follow these steps:

1. Modify the LEAP webapp so that it does not create users with the same name as users in the legacy system.
2. Configure your legacy MX servers to forward mail that they cannot handle to the LEAP MX servers, or vice versa.

### Step 1. Modify LEAP webapp

In order to modify the webapp to respect the usernames already reserved by your legacy system, you need to modify the LEAP webapp code. The easiest way to do this is to create a custom gem that modifies the behavior of the webapp.

For this example, we will call our custom gem `reserve_usernames`.

This gem can live in one of two places:

(1) You can fork the project leap_web and put the gem in `leap_web/vendor/gems/reserve_usernames`. Then, modify `Gemfile` and add the line `gem 'common_languages', :path => 'vendor/gems/reserve_usernames'`

(2) Alternately, you can put the gem in the local provider directory `files/webapp/gems/reserve_username`. This will get synced to the webapp servers when you deploy and put in `/srv/leap/webapp/config/customization` where it will get automatically loaded by the webapp.

What should the gem `reserve_usernames` look like? There is an example available here: https://leap.se/git/reserved_usernames.git

This example gem uses ActiveResource to communicate with a remote REST API for creating and checking username reservations. This ensures that both the legacy system and the LEAP system use the same namespace. Alternately, you could write a gem that checks the legacy database directly.

### Step 2. Configure MX servers

To be written.

