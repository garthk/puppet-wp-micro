class wp_micro::params {
  $db_name = 'wordpress'
  $db_user = 'wp_user'
}

class wp_micro(
  $db_name = $wp_micro::params::db_name,
  $db_user = $wp_micro::params::db_user,
  $db_password,
  $mysql_password,
  $domain,
  $port = 80
) inherits wp_micro::params {
  File { # defaults
    owner => root,
    group => root,
    mode  => 0644,
  }

  include wp_micro::php5

  file { 'apc.ini':
    path   => "/etc/php5/fpm/conf.d/apc.ini",
    source => "puppet:///modules/wp_micro/php5-fpm-conf-d-apc.ini",
    require => Package['php5-fpm'],
  }

  file { 'www.conf':
    path    => "/etc/php5/fpm/pool.d/www.conf",
    source  => "puppet:///modules/wp_micro/php5-fpm-pool-d-www.conf",
    require => Package['php5-fpm'],
  }

  class { 'wp_micro::mysql::server':
    mysql_password => $mysql_password,
  }

  class { 'wp_micro::nginx':
    domain => $domain,
    port   => $port,
  }

  wp_micro::mysql::db { 'wordpress-${db_name}':
    db_name        => $db_name,
    db_user        => $db_user,
    db_password    => $db_password,
    mysql_password => $mysql_password,
    require        => Class["Mysql::Server"],
  }

  class { 'wp_micro::wordpress':
    db_name        => $db_name,
    db_user        => $db_user,
    db_password    => $db_password,
  }
}

Class['wp_micro::php5'] -> Class['wp_micro']
