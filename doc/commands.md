@title = 'Command Line Reference'

The command "leap" can be used to manage a bevy of servers running the LEAP platform from the comfort of your own home.


# Global Options

* `--log FILE`  
Override default log file  
Default Value: None  

* `-v|--verbose LEVEL`  
Verbosity level 0..2  
Default Value: 1  

* `--help`  
Show this message  

* `--version`  
Display version number and exit  

* `--yes`  
Skip prompts and assume "yes"  


# leap add-user  USERNAME

Adds a new trusted sysadmin



**Options**

* `--pgp-pub-key arg`  
OpenPGP public key file for this new user  
Default Value: None  

* `--ssh-pub-key arg`  
SSH public key file for this new user  
Default Value: None  

* `--self`  
lets you choose among your public keys  


# leap cert 

Manage X.509 certificates



## leap cert ca 

Creates two Certificate Authorities (one for validating servers and one for validating clients).

See see what values are used in the generation of the certificates (like name and key size), run `leap inspect provider` and look for the "ca" property. To see the details of the created certs, run `leap inspect <file>`.

## leap cert csr 

Creates a CSR for use in buying a commercial X.509 certificate.

The CSR created is for the for the provider's primary domain. The properties used for this CSR come from `provider.ca.server_certificates`.

## leap cert dh 

Creates a Diffie-Hellman parameter file.



## leap cert update  <node-filter>

Creates or renews a X.509 certificate/key pair for a single node or all nodes, but only if needed.

This command will a generate new certificate for a node if some value in the node has changed that is included in the certificate (like hostname or IP address), or if the old certificate will be expiring soon. Sometimes, you might want to force the generation of a new certificate, such as in the cases where you have changed a CA parameter for server certificates, like bit size or digest hash. In this case, use --force. If <node-filter> is empty, this command will apply to all nodes.

**Options**

* `--force`  
Always generate new certificates  


# leap clean 

Removes all files generated with the "compile" command.



# leap compile 

Compiles node configuration files into hiera files used for deployment.



# leap deploy  FILTER

Apply recipes to a node or set of nodes.

The FILTER can be the name of a node, service, or tag.

**Options**

* `--tags TAG[,TAG]`  
Specify tags to pass through to puppet (overriding the default).  
Default Value: leap_base,leap_service  

* `--fast`  
Makes the deploy command faster by skipping some slow steps. A "fast" deploy can be used safely if you recently completed a normal deploy.  


# leap help  command

Shows a list of commands or help for one command

Gets help for the application or its commands. Can also list the commands in a way helpful to creating a bash-style completion function

**Options**

* `-c`  
List commands one per line, to assist with shell completion  


# leap inspect  FILE

Prints details about a file. Alternately, the argument FILE can be the name of a node, service or tag.



# leap list  [FILTER]

List nodes and their classifications

Prints out a listing of nodes, services, or tags. If present, the FILTER can be a list of names of nodes, services, or tags. If the name is prefixed with +, this acts like an AND condition. For example:

`leap list node1 node2` matches all nodes named "node1" OR "node2"

`leap list openvpn +local` matches all nodes with service "openvpn" AND tag "local"

**Options**

* `--print arg`  
What attributes to print (optional)  
Default Value: None  


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



## leap local status  [FILTER]

Print the status of local virtual machine(s)



## leap local stop  [FILTER]

Shuts down the virtual machine(s)



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

This command prepares a server to be used with the LEAP Platform by saving the server's SSH host key, copying the authorized_keys file, and installing packages that are required for deploying. Node init must be run before deploying to a server, and the server must be running and available via the network. This command only needs to be run once, but there is no harm in running it multiple times.

**Options**

* `--echo`  
If set, passwords are visible as you type them (default is hidden)  


## leap node mv  OLD_NAME NEW_NAME

Renames a node file, and all its related files.



## leap node rm  NAME

Removes all the files related to the node named NAME.



# leap ssh  NAME

Log in to the specified node with an interactive shell.



# leap test 

Run tests.



## leap test init 

Creates files needed to run tests.



## leap test run 

Run tests.


Default Command: run
