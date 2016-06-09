Examples for using this check_mk repository on debian
=====================================================

What it does
============

* ssh authentication is configured to allow the server to execute check_mk on the client
* omd is installed on the server
* check_mk is installed as package on the client

On the client
=============

    class site_check_mk::client {
      class { 'check_mk::agent':
        agent_package_name          => 'check-mk-agent',
        agent_logwatch_package_name => 'check-mk-agent-logwatch',
        use_ssh                     => true,
        register_agent              => false
      }
    }


On the server
=============

    include check_mk::omd_repo
    class { 'check_mk':
      package           => 'omd',
      omd_service_name  => 'omd-1.00',
      http_service_name => 'apache2',
      omdadmin_htpasswd => trocla("${::fqdn}_omdadmin"),
      use_ssh           => true;
    }

