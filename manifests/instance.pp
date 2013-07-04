define redis-multi::instance (
  $socket_path     = undef,
  $user            = 'root',
  $group           = 'root',
  $template_config = 'redis/instance-config.conf',
  $log_path        = '/var/log/redis/redis-server.log',
  $configure_user  = true,
) {

  $bool_configure_user = true

  include redis-multi

  file { "${redis-multi::conf_prefix}${name}.conf":
    ensure   => file,
    content => template($template_config),
    notify  => Service["redis-${name}"],
  }

  file { "${redis-multi::init_script}-${name}":
    ensure   => link,
    target   => $redis::init_script,
    before   => Service ["redis-${name}"]
  }

  service { "redis-${name}":
    hasstatus => true,
    ensure    => running,
  }

  if ($bool_configure_user == true) {
    # Make sure the user is member of the redis-multi group
    User <| title == $user |> { groups +> $::redis-multi::group }
    realize User[$user]
    Group[$::redis-multi::group] -> User[$user]
  }
}
