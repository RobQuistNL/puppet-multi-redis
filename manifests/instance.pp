define redismulti::instance (
  $socket_path     = undef,
  $user            = 'root',
  $group           = 'root',
  $template_config = 'redismulti/instance-config.conf',
  #$log_path        = undef,
  $configure_user  = true,
) {

  file { "/var/log/redis/redis-server-${name}.log":
    ensure => file,
    owner  => $user,
    group  => $group,
    mode   => 755,
  }

  $log_path = "/var/log/redis/redis-server-${name}.log"
  #$socket_path = "/var/run/redis/redis-server-${name}.sock"
  
  $bool_configure_user = true
  
  include redismulti

  file { "${redismulti::conf_prefix}${name}.conf":
    ensure   => file,
    content => template($template_config),
    notify  => Service["redis-server-${name}"],
  }

  file { "${redismulti::init_script}-${name}":
    ensure   => link,
    target   => $redismulti::init_script,
    before   => Service ["redis-server-${name}"]
  }
  
  file { "/etc/redis/redis-server-${user}.user.conf":
      ensure   => file, 
      content => template('redismulti/userconfig.conf'),
      mode    => 755,
      before   => Service ["redis-server-${name}"]
    }

  service { "redis-server-${name}":
    hasstatus => true,
    ensure    => running,
  }

  if ($bool_configure_user == true) {
    # Make sure the user is member of the redis-multi group
    User <| title == $user |> { groups +> $::redismulti::group }
    realize User[$user]
    Group[$::redismulti::group] -> User[$user]
  }
}
