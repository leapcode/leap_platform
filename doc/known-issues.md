@title = 'Leap Platform Release Notes'
@nav_title = 'Known issues'
@summary = 'Known issues in the Leap Platform.'
@toc = true

Here you can find documentation about known issues and potential work-arounds in the current Leap Platform release.

0.2.2
=====

In this release the following issues are known, work-arounds are noted when available.

General Issues
--------------

. This release does *not* anonymize your logs (see: https://leap.se/code/issues/1897)

. This release does *not* setup email relaying, so admins will not receive important email notifications. Email service will be part of the next release (see: https://leap.se/code/issues/1683 https://leap.se/code/issues/1905)

. Your openvpn gateway address will be added on the /24 network, and is not configurable in this release (see: https://leap.se/code/issues/1863)

. You must not add a node with an underscore in the name, you also cannot use a hyphen for a vagrant node (see: https://leap.se/code/issues/3087) 

. The nagios website check reports success when the webapp is not functioning but apache is up (see: https://leap.se/code/issues/1629)

User setup and ssh
------------------

. if you aren't using a single ssh key, but have different ones, you will need to define the following at the top of your ~/.ssh/config: 
  HostName <ip address>
  IdentityFile <path to identity file>

  (see: https://leap.se/code/issues/2946 and https://leap.se/code/issues/3002)

. If the ssh host key changes, you need to run node init again (see: https://leap.se/en/docs/platform/guide#Working.with.SSH)

. At the moment, only ECDSA ssh host keys are supported. If you get the following error: `= FAILED ssh-keyscan: no hostkey alg (must be missing an ecdsa public host key)` then you should confirm that you have the following line defined in your server's /etc/ssh/sshd_config:
HostKey /etc/ssh/ssh_host_ecdsa_key and that file exists. If you made a change to your sshd_config, then you need to run `/etc/init.d/ssh restart` (see: https://leap.se/code/issues/2373)

. To remove an admin's access to your servers, please remove the directory for that user under the `users/` subdirectory in your provider directory and then remove that user's ssh keys from files/ssh/authorized_keys. When finished you *must* run a `leap deploy` to update that information on the servers (see: https://leap.se/code/issues/1863)

. At the moment, it is only possible to add an admin who will have access to all LEAP servers (see: https://leap.se/code/issues/2280)

. leap add-user --self allows only one key - if you run that command twice with different keys, you will just replace the key with the second key. To add a second key, add it manually to files/ssh/authorized_keys (see: https://leap.se/code/issues/866)

Deploying
---------

. If you have any errors during a run, please try to deploy again as this often solves non-deterministic issues that were not uncovered in our testing. Please re-deploy with `leap -v2 deploy` to get more verbose logs and capture the complete output to provide to us for debugging.

. If when deploying your debian mirror fails for some reason, network anomoly or the mirror itself is out of date, then platform deployment will not succeed properly. Check the mirror is up and try to deploy again when it is resolved (see: https://leap.se/code/issues/1091)

. Deployment gives 'error: in `%`: too few arguments (ArgumentError)' - this is because you attempted to do a deploy before initializing a node, please initialize the node first and then do a deploy afterwards (see: https://leap.se/code/issues/2550)

. This release has no ability to custom configure apt sources or proxies (see: https://leap.se/code/issues/1971)

. When running a deploy at a verbosity level of 2 and above, you will notice puppet deprecation warnings, these are known and we are working on fixing them

Special Environments
--------------------

. When deploying to OpenStack release "nova" or newer, you will need to do an initial deploy, then when it has finished run `leap facts update` and then deploy again (see: https://leap.se/code/issues/3020)

. It is not possible to actually use the EIP openvpn server on vagrant nodes (see: https://leap.se/code/issues/2401)
