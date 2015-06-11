@title = "Working with environments"
@nav_title = "Environments"
@summary = "How to partition the nodes into separate environments."

With environments, you can divide your nodes into different and entirely separate sets. For example, you might have sets of nodes for 'testing', 'staging' and 'production'.

Typically, the nodes in one environment are totally isolated from the nodes in a different environment. Each environment will have its own separate database, for example.

There are a few exceptions to this rule: backup nodes, for example, will by default attempt to back up data from all the environments (excluding local).

## Assign an environment

To assign an environment to a node, you just set the `environment` node property. This is typically done with tags, although it is not necessary. For example:

`tags/production.json`

    {
      "environment": "production"
    }

`nodes/mynode.json`

    {
      "tags": ["production"]
    }

There are several built-in tags that will apply a value for the environment:

* `production`: An environment for nodes that are in use by end users.
* `development`: An environment to be used for nodes that are being used for experiments or staging.
* `local`: This environment gets automatically applied to all nodes that run only on local VMs. Nodes with a `local` environment are treated special and excluded from certain calculations.

You don't need to use these and you can add your own.

## Environment commands

* `leap env` -- List the available environments and disply which one is active.
* `leap env pin ENV` -- Pin the current environment to ENV.
* `leap env unpin` -- Remove the environment pin.

The environment pin is only active for your local machine: it is not recorded in the provider directory and not shared with other users.

## Environment specific JSON files

You can add JSON configuration files that are only applied when a specific environment is active. For example, if you create a file `provider.production.json`, these values will only get applied to the `provider.json` file for the `production` environment.

This will also work for services and tags. For example:

    provider.local.json
    services/webapp.development.json
    tags/seattle.production.json

In this example, `local`, `development`, and `production` are the names of environments.

## Bind an environment to a Platform version

If you want to ensure that a particular environment is bound to a particular version of the LEAP Platform, you can add a `platform` section to the `provider.ENV.json` file (where ENV is the name of the environment in question).

The available options are `platform.version`, `platform.branch`, or `platform.commit`. For example:

    {
      "platform": {
        "version": "1.6.1",
        "branch": "develop",
        "commit": "5df867fbd3a78ca4160eb54d708d55a7d047bdb2"
      }
    }

You can use any combination of `version`, `branch`, and `commit` to specify the binding. The values for `branch` and `commit` only work if the `leap_platform` directory is a git repository.

The value for `commit` is passed directly through to `git log` to query for a list of acceptable commits. See [[man gitrevisions => https://www.kernel.org/pub/software/scm/git/docs/gitrevisions.html#_specifying_ranges]] to see how to specify ranges. For example:

* `HEAD^..HEAD` - current commit must be head of the branch.
* `3172444652af71bd771609d6b80258e70cc82ce9..HEAD` - current commit must be after 3172444652af71bd771609d6b80258e70cc82ce9.
* `refs/tags/0.6.0rc1..refs/tags/0.6.0rc2` - current commit must be after tag 0.6.0rc1 and before or including tag 0.6.0rc2.