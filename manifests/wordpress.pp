class wp_micro::wordpress($db_name, $db_user, $db_password) {
  package { 'curl':
    ensure => present,
  }

  exec { 'getlatest':
    creates     => "/tmp/latest.tar.gz",
    command     => "/usr/bin/curl -O http://wordpress.org/latest.tar.gz",
    cwd         => "/tmp",
    require     => Package['curl'],
  }

  exec { 'extract': 
    cwd        => "/var/www",
    command    => "/bin/tar xf /tmp/latest.tar.gz --strip-components=1",
    creates    => "/var/www/wp-content",
    require    => [File['/var/www'], Exec['getlatest']],
  }
  
  exec { 'fixown':
    refreshonly => true,
    command     => "/bin/chown -R www-data:www-data /var/www",
    notify      => Exec['fixperm'],
  }
  
  exec { 'fixperm':
    refreshonly => true,
    command     => "/bin/chmod -R a+rX /var/www",
  }
  
  file { 'wp-config.php':
    path    => "/var/www/wp-config.php",
    content => template(
      "wp_micro/wp-config.php.erb",
      "wp_micro/wp-config-keys.php.erb",
      "wp_micro/wp-config-end.php.erb"),
    owner   => 'www-data',
    group   => 'www-data',
    require => File['/var/www'],
  }
}
