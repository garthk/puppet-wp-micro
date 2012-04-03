class wp_micro::mysql::server($mysql_password) {
  package { 'mysql-server':
    ensure => installed,
  }

  service { 'mysql':
    enable  => true,
    ensure  => running,
    require => Package['mysql-server'],
  }

  exec { "set-mysql-password":
    unless  => "mysqladmin -uroot -p${mysql_password} status",
    path    => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password ${mysql_password}",
    require => Service['mysql'],
  }
}

define wp_micro::mysql::db($db_user, $db_name, $db_password, $mysql_password) {
  exec { "create-${db_name}-db":
    unless => "/usr/bin/mysql -uroot -p${mysql_password} ${db_name}",
    command => "/usr/bin/mysql -uroot -p${mysql_password} -e \"create database ${db_name};\"",
    require => [Service["mysql"], Exec["set-mysql-password"]],
  }

  exec { "grant-${db_name}-db":
    unless => "/usr/bin/mysql -u${db_user} -p${db_password} ${db_name}",
    command => "/usr/bin/mysql -uroot -p${mysql_password} -e \"grant all on ${db_name}.* to ${db_user}@localhost identified by '${db_password}';\"",
    require => [Service["mysql"], Exec["create-${db_name}-db"]]
  }
}

