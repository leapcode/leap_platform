@title = 'Command Line Reference'
@summary = 'A copy of leap --help'

The command "leap" can be used to manage a bevy of servers running the LEAP platform from the comfort of your own home.


# Global Options

* `--log FILE`
Override default log file.
Default Value: None

* `-v|--verbose LEVEL`
Verbosity level 0..5
Default Value: 1

* `--[no-]color`
Disable colors in output.

* `-d|--debug`
Print full stack trace for exceptions and load `debugger` gem if installed.

* `--force`
Like --yes, but also skip prompts that are potentially dangerous to skip.

* `--help`
Show this message

* `--version`
Display version number and exit.

* `--yes`
Skip prompts and assume "yes".


# leap add-user  USERNAME

Adds a new trusted sysadmin by adding public keys to the "users" directory.



**Options**

* `--pgp-pub-key arg`
OpenPGP public key file for this new user
Default Value: None

* `--ssh-pub-key arg`
SSH public key file for this new user
Default Value: None

* `--self`
Add yourself as a trusted sysadmin by choosing among the public keys available for the current user.


# leap cert

Manage X.509 certificates



## leap cert ca

Creates two Certificate Authorities (one for validating servers and one for validating clients).

See see what values are used in the generation of the certificates (like name and key size), run `leap inspect provider` and look for the "ca" property. To see the details of the created certs, run `leap inspect <file>`.

## leap cert csr

Creates a CSR for use in buying a commercial X.509 certificate.

Unless specified, the CSR is created for the provider's primary domain. The properties used for this CSR come from `provider.ca.server_certificates`, but may be overridden here.

**Options**

* `--bits BITS`
Override default certificate bit length
Default Value: None

* `--country|-C COUNTRY`
Set C in distinguished name.
Default Value: None

* `--digest DIGEST`
Override default signature digest
Default Value: None

* `--domain DOMAIN`
Specify what domain to create the CSR for.
Unless specified, the CSR is created for the provider's primary domain. The properties used for this CSR come from `provider.ca.server_certificates`, but may be overridden here.
Default Value: None

* `--email EMAIL`
Set emailAddress in distinguished name.
Default Value: None

* `--locality|-L LOCALITY`
Set L in distinguished name.
Default Value: None

* `--organization|-O ORGANIZATION`
Override default O in distinguished name.
Default Value: None

* `--state|--ST STATE`
Set ST in distinguished name.
Default Value: None

* `--unit|--OU UNIT`
Set OU in distinguished name.
Default Value: None


## leap cert dh

Creates a Diffie-Hellman parameter file, needed for forward secret OpenVPN ciphers.



## leap cert update  FILTER

Creates or renews a X.509 certificate/key pair for a single node or all nodes, but only if needed.

This command will a generate new certificate for a node if some value in the node has changed that is included in the certificate (like hostname or IP address), or if the old certificate will be expiring soon. Sometimes, you might want to force the generation of a new certificate, such as in the cases where you have changed a CA parameter for server certificates, like bit size or digest hash. In this case, use --force. If <node-filter> is empty, this command will apply to all nodes.

**Options**

* `--force`
Always generate new certificates


# leap clean

Removes all files generated with the "compile" command.



# leap compile

Compile generated files.



## leap compile all  [ENVIRONMENT]

Compiles node configuration files into hiera files used for deployment.



## leap compile firewall

Prints a list of firewall rules. These rules are already implemented on each node, but you might want the list of all rules in case you also have a restrictive network firewall.



## leap compile hosts

Print entries suitable for an /etc/hosts file, useful for testing your provider.



## leap compile provider.json

Compile provider.json bootstrap files for your provider.



## leap compile zone

Prints a DNS zone file for your provider.


Default Command: all

# leap db

Database commands.



## leap db destroy  [FILTER]

Destroy one or more databases. If present, limit to FILTER nodes. For example `leap db destroy --db sessions,tokens testing`.



**Options**

* `--db DATABASES`
Comma separated list of databases to destroy (no space). Use "--db all" to destroy all databases.
Default Value: None

* `--user USERS`
Comma separated list of usernames. The storage databases for these user(s) will be destroyed.
Default Value: None


# leap debug  FILTER

Output debug information.

The FILTER can be the name of a node, service, or tag.

# leap deploy  FILTER

Apply recipes to a node or set of nodes.

The FILTER can be the name of a node, service, or tag.

**Options**

* `--ip IPADDRESS`
Override the default SSH IP address.
Default Value: None

* `--port PORT`
Override the default SSH port.
Default Value: None

* `--tags TAG[,TAG]`
Specify tags to pass through to puppet (overriding the default).
Default Value: None

* `--dev`
Development mode: don't run 'git submodule update' before deploy.

* `--downgrade`
Allows deploy to run with an older platform version.

* `--fast`
Makes the deploy command faster by skipping some slow steps. A "fast" deploy can be used safely if you recently completed a normal deploy.

* `--force`
Deploy even if there is a lockfile.

* `--sync`
Sync files, but don't actually apply recipes.


# leap env

Manipulate and query environment information.

The 'environment' node property can be used to isolate sets of nodes into entirely separate environments. A node in one environment will never interact with a node from another environment. Environment pinning works by modifying your ~/.leaprc file and is dependent on the absolute file path of your provider directory (pins don't apply if you move the directory)

## leap env ls  [ENVIRONMENT]

List the available environments. The pinned environment, if any, will be marked with '*'. Will also set the pin if run with an environment argument.



## leap env pin  ENVIRONMENT

Pin the environment to ENVIRONMENT. All subsequent commands will only apply to nodes in this environment.



## leap env unpin

Unpin the environment. All subsequent commands will apply to all nodes.


Default Command: ls

# leap facts

Gather information on nodes.



## leap facts update  FILTER

Query servers to update facts.json.

Queries every node included in FILTER and saves the important information to facts.json

# leap help  command

Shows a list of commands or help for one command

Gets help for the application or its commands. Can also list the commands in a way helpful to creating a bash-style completion function

**Options**

* `-c`
List commands one per line, to assist with shell completion


# leap history  FILTER

Display recent deployment history for a set of nodes.

The FILTER can be the name of a node, service, or tag.

**Options**

* `--ip IPADDRESS`
Override the default SSH IP address.
Default Value: None

* `--port PORT`
Override the default SSH port.
Default Value: None

* `--last`
Show last deploy only


# leap inspect  FILE

Prints details about a file. Alternately, the argument FILE can be the name of a node, service or tag.



**Options**

* `--base`
Inspect the FILE from the provider_base (i.e. without local inheritance).


# leap list  [FILTER]

List nodes and their classifications

Prints out a listing of nodes, services, or tags. If present, the FILTER can be a list of names of nodes, services, or tags. If the name is prefixed with +, this acts like an AND condition. For example:

`leap list node1 node2` matches all nodes named "node1" OR "node2"

`leap list openvpn +local` matches all nodes with service "openvpn" AND tag "local"

**Options**

* `--print arg`
What attributes to print (optional)
Default Value: None

* `--disabled`
Include disabled nodes in the list.


# leap local

Manage local virtual machines.

This command provides a convient way to manage Vagrant-based virtual machines. If FILTER argument is missing, the command runs on all local virtual machines. The Vagrantfile is automatically generated in 'test/Vagrantfile'. If you want to run vagrant commands manually, cd to 'test'.

## leap local destroy  [FILTER]

Destroys the virtual machine(s), reclaiming the disk space



## leap local reset  [FILTER]

Resets virtual machine(s) to the last saved snapshot



## leap local save  [FILTER]

Saves the current state of the virtual machine as a new snapshot



## leap local start  [FILTER]

Starts up the virtual machine(s)



**Options**

* `--basebox BASEBOX`
The basebox to use. This value is passed to vagrant as the `config.vm.box` option. The value here should be the name of an installed box or a shorthand name of a box in HashiCorp's Atlas.
Default Value: LEAP/jessie


## leap local status  [FILTER]

Print the status of local virtual machine(s)



## leap local stop  [FILTER]

Shuts down the virtual machine(s)



# leap mosh  NAME

Log in to the specified node with an interactive shell using mosh (requires node to have mosh.enabled set to true).



**Options**

* `--port SSH_PORT`
Override default SSH port used when trying to connect to the server. Same as `--ssh "-p SSH_PORT"`.
Default Value: None

* `--ssh arg`
Pass through raw options to ssh (e.g. `--ssh '-F ~/sshconfig'`).
Default Value: None


# leap new  DIRECTORY

Creates a new provider instance in the specified directory, creating it if necessary.



**Options**

* `--contacts arg`
Default email address contacts.
Default Value: None

* `--domain arg`
The primary domain of the provider.
Default Value: None

* `--name arg`
The name of the provider.
Default Value: None

* `--platform arg`
File path of the leap_platform directory.
Default Value: None


# leap node

Node management



## leap node add  NAME [SEED]

Create a new configuration file for a node named NAME.

If specified, the optional argument SEED can be used to seed values in the node configuration file.

The format is property_name:value.

For example: `leap node add web1 ip_address:1.2.3.4 services:webapp`.

To set nested properties, property name can contain '.', like so: `leap node add web1 ssh.port:44`

Separeate multiple values for a single property with a comma, like so: `leap node add mynode services:webapp,dns`

**Options**

* `--local`
Make a local testing node (by automatically assigning the next available local IP address). Local nodes are run as virtual machines on your computer.


## leap node init  FILTER

Bootstraps a node or nodes, setting up SSH keys and installing prerequisite packages

This command prepares a server to be used with the LEAP Platform by saving the server's SSH host key, copying the authorized_keys file, installing packages that are required for deploying, and registering important facts. Node init must be run before deploying to a server, and the server must be running and available via the network. This command only needs to be run once, but there is no harm in running it multiple times.

**Options**

* `--ip IPADDRESS`
Override the default SSH IP address.
Default Value: None

* `--port PORT`
Override the default SSH port.
Default Value: None

* `--echo`
If set, passwords are visible as you type them (default is hidden)


## leap node mv  OLD_NAME NEW_NAME

Renames a node file, and all its related files.



## leap node rm  NAME

Removes all the files related to the node named NAME.



# leap scp  FILE1 FILE2

Secure copy from FILE1 to FILE2. Files are specified as NODE_NAME:FILE_PATH. For local paths, omit "NODE_NAME:".



**Options**

* `-r`
Copy recursively


# leap ssh  NAME

Log in to the specified node with an interactive shell.



**Options**

* `--port SSH_PORT`
Override default SSH port used when trying to connect to the server. Same as `--ssh "-p SSH_PORT"`.
Default Value: None

* `--ssh arg`
Pass through raw options to ssh (e.g. `--ssh '-F ~/sshconfig'`).
Default Value: None


# leap test

Run tests.



## leap test init

Creates files needed to run tests.



## leap test run  [FILTER]

Run the test suit on FILTER nodes.



**Options**

* `--[no-]continue`
Continue over errors and failures (default is --no-continue).

Default Command: run

# leap tunnel  [LOCAL_PORT:]NAME:REMOTE_PORT

Creates an SSH port forward (tunnel) to the node NAME. REMOTE_PORT is the port on the remote node that the tunnel will connect to. LOCAL_PORT is the optional port on your local machine. For example: `leap tunnel couch1:5984`.



**Options**

* `--port SSH_PORT`
Override default SSH port used when trying to connect to the server. Same as `--ssh "-p SSH_PORT"`.
Default Value: None

* `--ssh arg`
Pass through raw options to ssh (e.g. --ssh '-F ~/sshconfig').
Default Value: None

