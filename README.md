# Puppet module: redis multi

This is a Puppet module for redis.
It manages its installation, configuration and service. It allows to run several instances
independently of one another.

The blueprint of this module is from http://github.com/Enrise/puppet-memcached

Released under the terms of 2-clause BSD license (see the License file for further details).


## USAGE - Basic management

* Install redis with default settings (package installed, service started, default configuration files)

        class { 'redis': }

* Set up an instance of Redis for one specific user:

        class { 'redis':
          disable_default => true,
        }

        redis::instance { $user:
          user            => $user,
          group           => $user,
          socket_path     => "/var/run/redis/${user}-projectname.sock"
        }

     By default this will add the specified user to the group $redis::group. This can only
     be done if the specified user is defined using a virtual resource.
