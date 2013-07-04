class redismulti::params {
  
  $package = 'redis-server'
  
  $conf_prefix     = '/etc/redis-server-'
  $init_script     = '/etc/init.d/redis-server'
  
  $group           = 'redis'
  $user            = 'redis'
  
  $disable_default = false

}