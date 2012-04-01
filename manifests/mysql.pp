class mysql::server {
  case $mysql_password {
    "" : {
      fail("\$mysql_password not set")
    }
  }

  package { 'mysql-server':
    ensure => installed,
  }

  service { 'mysql':
    enable => true,
    ensure => running,
    require => Package['mysql-server'],
  }

  exec { "set-mysql-password":
    unless => "mysqladmin -uroot -p$mysql_password status",
    path => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot mysql_password $password",
    require => Service['mysql'],
  }
}

define mysql::db($user, $password) {
  case $mysql_password {
    "" : {
      fail("\$mysql_password not set")
    }
  }

  exec { "create-${name}-db":
    unless => "/usr/bin/mysql -uroot -p${mysql_password} ${name}",
    command => "/usr/bin/mysql -uroot -p${mysql_password} -e \"create database ${name};\"",
    require => [Service["mysql"], Exec["set-mysql-password"]],
  }

  exec { "grant-${name}-db":
    unless => "/usr/bin/mysql -u${user} -p${password} ${name}",
    command => "/usr/bin/mysql -uroot -p${mysql_password} -e \"grant all on ${name}.* to ${user}@localhost identified by '$password';\"",
    require => [Service["mysql"], Exec["create-${name}-db"]]
  }
}
