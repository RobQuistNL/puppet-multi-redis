class redis-multi::params {
  
  $package = 'redis-server'
  
  $conf_prefix     = '/etc/redis'
  $init_script     = '/etc/init.d/redis-server'
  
  $group           = 'redis-multi'
  $user            = 'redis-multi'
  
  $disable_default = false

}