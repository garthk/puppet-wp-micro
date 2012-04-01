import "passwords.pp"
import "ppa.pp"
import "mysql.pp" # do AFTER passwords!
import "nginx.pp"

File { # defaults
  owner => root,
  group => root,
  mode => 0644,
}

package { ['php5-fpm', 'php-pear', 'php5-common', 'php5-mysql', 'php-apc']:
  ensure => installed,
}

file { 'apc.ini':
  path => "/etc/php5/fpm/conf.d/apc.ini",
  content => "extension=apc.so\napc.write_lock = 1\napc.slam_defense = 0\n",
}

file { 'www.conf':
  path => "/etc/php5/fpm/pool.d/www.conf",
  content => "[www]
listen = /dev/shm/php-fpm-www.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660
user = www-data
group = www-data
pm = dynamic
pm.max_children = 10
pm.start_servers = 4
pm.min_spare_servers = 2
pm.max_spare_servers = 6
chdir = /",
}

$mysql_password = $MYSQL_ROOT_PASSWORD
include mysql::server

$nginx_domain = "ec2-50-112-42-160.us-west-2.compute.amazonaws.com"
include nginx

mysql::db { 'wordpress':
  user => 'wp_user',
  password => $WORDPRESS_DB_PASSWORD,
  require => Class["Mysql::Server"],
}

$wordpress_db_password = $WORDPRESS_DB_PASSWORD
file { 'wp-config.php':
  path => "/var/www/wp-config.php",
  content => template("/etc/puppet/templates/wp-config.php.erb", "/etc/puppet/templates/wp-config-keys.php.erb"),
}
