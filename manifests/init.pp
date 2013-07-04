class redis-multi (
  $package         = params_lookup('package'),
  $user            = params_lookup('user'),
  $group           = params_lookup('group'),
  $disable_default = params_lookup('disable_default'),
) inherits redis-multi::params {
  
  $bool_disable_default = any2bool($disable_default)

  package { $package: }

  file { '/etc/init.d/redis-server':
    content => template('redis-multi/init.sh'),
    mode    => 0551,
    owner   => root,
    group   => root,
  }
  
  file { '/var/run/redis-server':
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => 1771,
  }

  group { 'redis-multi':
    system => true,
  }

  user { 'redis-multi':
    system  => true,
  }

  file { '/usr/share/redis-server/scripts/start-redis-server':
    content => template('redis-multi/startscript.sh'),
    mode    => 755,
  }
  
  if ($bool_disable_default == true) {
    file { '/etc/redis/redis.conf': 
      ensure => absent
    }
  }
  
}
