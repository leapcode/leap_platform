@title = "Configuration Files"

Leapfile
-------------------------------------------

A `Leapfile` defines options for the `leap` command and lives at the root of your provider directory. `Leapfile` is evaluated as ruby, so you can include whatever weird logic you want in this file. In particular, there are several variables you can set that modify the behavior of leap. For example:

    @platform_directory_path = '../leap_platform'
    @log = '/var/log/leap.log'

Additionally, you can create a `~/.leaprc` file that is loaded after `Leapfile` and is evaluated the same way.

Platform options:

* `@platform_directory_path` (required). This must be set to the path where `leap_platform` lives. The path may be relative.
* `@platform_branch`. If set, a check is preformed before running any command to ensure that the currently checked out branch of `leap_platform` matches the value set for `@platform_branch`. This is useful if you have a stable branch of your provider that you want to ensure runs off the master branch of `leap_platform`.
* `@allow_production_deploy`. By default, you can only deploy to production nodes if the current branch is 'master' or if the provider directory is not a git repository. This option allows you to override this behavior.

Vagrant options:

* `@vagrant_network`. Allows you to override the default network used for local nodes. It should include a netmask like `@vagrant_network = '10.0.0.0/24'`.
* `@custom_vagrant_vm_line`. Insert arbitrary text into the auto-generated Vagrantfile. For example, `@custom_vagrant_vm_line = "config.vm.boot_mode = :gui"`.

Logging options:

* `@log`. If set, all command invocation and results are logged to the specified file. This is the same as the switch `--log FILE`, except that the command line switch will override the value in the Leapfile.


Configuration files
-------------------------------------------

All configuration files, other than `Leapfile`, are in the JSON format. For example:

    {
      "key1": "value1",
      "key2": "value2"
    }

Keys should match `/[a-z0-9_]/`

Unlike traditional JSON, comments are allowed. If the first non-whitespace characters are `//` then the line is treated as a comment.

    // this is a comment
    {
      // this is a comment
      "key": "value"  // this is an error
    }

Options in the configuration files might be nested hashes, arrays, numbers, strings, or boolean. Numbers and boolean values should **not** be quoted. For example:

    {
      "openvpn": {
        "ip_address": "1.1.1.1",
        "protocols": ["tcp", "udp"],
        "ports": [80, 53],
        "options": {
          "public_ip": false,
          "adblock": true
        }
      }
    }

If the value string is prefixed with an '=' character, the result is evaluated as ruby. For example:

    {
      "domain": {
        "public": "domain.org"
      }
      "api_domain": "= 'api.' + domain.public"
    }

In this case, the property "api_domain" will be set to "api.domain.org". So long as you do not create unresolvable circular dependencies, you can reference other properties in evaluated ruby that are themselves evaluated ruby.

See "Macros" below for information on the special macros available to the evaluated ruby.

TIP: In rare cases, you might want to force the evaluation of a value to happen in a later pass after most of the other properties have been evaluated. To do this, prefix the value string with "=>" instead of "=".

Node inheritance
----------------------------------------

Every node inherits from common.json and also any of the services or tags attached to the node. Additionally, the `leap_platform` contains a directory `provider_base` that defines the default values for tags, services and common.json.

Suppose you have a node configuration for `bitmask/nodes/willamette.json` like so:

    {
       "services": "webapp",
       "tags": ["production", "northwest-us"],
       "ip_address": "1.1.1.1"
    }

This node will have hostname "willamette" and it will inherit from the following files (in this order):

1. common.json
    - load defaults: `provider_base/common.json`
    - load provider: `bitmask/common.json`
2. service "webapp"
    - load defaults: `provider_base/services/webapp.json`
    - load provider: `bitmask/services/webapp.json`
3. tag "production"
    - load defaults: `provider_base/tags/production.json`
    - load provider: `bitmask/tags/production.json`
4. tag "northwest-us"
    - load: `bitmask/tags/northwest-us.json`
5. finally, load node "willamette"
    - load: `bitmask/nodes/willamette.json`

The `provider_base` directory is under the `leap_platform` specified in the file `Leapfile`.

To see all the variables a node has inherited, you could run `leap inspect willamette`.

Common configuration options
----------------------------------------

You can use the command `leap inspect` to see what options are available for a provider, node, service, or tag configuration. For example:

* `leap inspect common` -- show the options inherited by all nodes.
* `leap inspect --base common` -- show the common.json from `provider_base` without the local `common.json` inheritance applied.
* `leap inspect webapp` -- show all the options available for the service `webapp`.

Here are some of the more important options you should be aware of:

* `ip_address` -- Required for all nodes, no default.
* `ssh.port` -- The SSH port you want the node's OpenSSH server to bind to. This is also the default when trying to connect to a node, but if the node currently has OpenSSH running on a different port then run deploy with `--port` to override the `ssh.port` configuration value.
* `mosh.enabled` -- If set to `true`, then mosh will be installed on the server. The default is `false`.

Macros
----------------------------------------

When using evaluated ruby in a JSON configuration file, there are several special macros that are available. These are evaluated in the context of a node (available as the variable `self`).

The following methods are available to the evaluated ruby:

`variable.variable`

  > Any variable defined or inherited by a particular node configuration is available by just referencing it using either hash notation or object field notation (e.g. `['domain']['public']` or `domain.public`). Circular references are not allowed, but otherwise it is OK to nest evaluated values in other evaluated values. If a value has not been defined, the hash notation will return nil but the field notation will raise an exception. Properties of services, tags, and the global provider can all be referenced the same way. For example, `global.services['openvpn'].x509.dh`.

`nodes`

  > A hash of all nodes. This list can be filtered.

`nodes_like_me`

  > A hash of nodes that have the same deployment tags as the current node (e.g. 'production' or 'local').

`global.services`

  > A hash of all services, e.g. `global.services['openvpn']` would return the "openvpn" service.

`global.tags`

  > A hash of all tags, e.g. `global.tags['production']` would return the "production" tag.

 `global.provider`

  > Can be used to access variables defined in `provider.json`, e.g. `global.provider.contacts.default`.

`file(filename)`

  > Inserts the full contents of the file. If the file is an erb template, it is rendered. The filename can either be one of the pre-defined file symbols, or it can be a path relative to the "files" directory in your provider instance. E.g, `file :ca_cert` or `files 'ca/ca.crt'`.

`file_path(filename)`

  >  Ensures that the file will get rsynced to the node as an individual file. The value returned by `file_path` is the full path where this file will ultimately live when deploy to the node. e.g. `file_path :ca_cert` or `file_path 'branding/images/logo.png'`.

`secret(:symbol)`

  > Returns the value of a secret in secrets.json (or creates it if necessary). E.g. `secret :couch_admin_password`

`hosts_file`

  > Returns a data structure that puppet will use to generate /etc/hosts. Care is taken to use the local IP of other hosts when needed.

`known_hosts_file`

  > Returns the lines needed in a SSH `known_hosts` file.

`stunnel_client(node_list, port, options={})`

  > Returns a stunnel configuration data structure for the client side. Argument `node_list` is an `ObjectList` of nodes running stunnel servers. Argument `port` is the real port of the ultimate service running on the servers that the client wants to connect to.

`stunnel_server(port)`

  > Generates a stunnel server entry. The `port` is the real port targeted service.

Hash tables
-----------------------------------------

The macros `nodes`, `nodes_like_me`, `global.services`, and `global.tags` all return a hash table of configuration objects (either nodes, services, or tags). There are several ways to filter and process these hash tables:

Access an element by name:

    nodes['vpn1']                # returns node named 'vpn1'
    global.services['openvpn']   # returns service named 'openvpn'

Create a new hash table by applying filters:

    nodes[:public_dns => true] # all nodes where public_dns == true
    nodes[:services => 'openvpn', :services => 'tor'] # openvpn OR tor
    nodes[:services => 'openvpn'][:tags => 'production']  # openvpn AND production
    nodes[:name => "!bob"] # all nodes that are NOT named "bob"

Create an array of values by selecting a single field:

    nodes.field('location.name')
    ==> ['seattle', 'istanbul']

Create an array of hashes by selecting multiple fields:

    nodes.fields('domain.full', 'ip_address')
    ==> [
      {'domain_full' => 'red.bitmask.net', 'ip_address' => '1.1.1.1'},
      {'domain_full' => 'blue.bitmask.net', 'ip_address' => '1.1.1.2'},
    ]

Create a new hash table of hashes, with only certain fields:

    nodes.pick_fields('domain.full', 'ip_address')
    ==> {
      "red" => {'domain_full' => 'red.bitmask.net', 'ip_address' => '1.1.1.1'},
      "blue => {'domain_full' => 'blue.bitmask.net', 'ip_address' => '1.1.1.2'},
    }

With `pick_fields`, if there is only one field, it will generate a simple hash table:

    nodes.pick_fields('ip_address')
    ==> {
      "red" => '1.1.1.1',
      "blue => '1.1.1.2',
    }
