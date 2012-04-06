stage { pre: before => Stage[main] }

class apt_get_update {
  $sentinel = "/var/lib/apt/first-puppet-run"

  exec { "initial apt-get update":
    command => "/usr/bin/apt-get update && touch ${sentinel}",
    onlyif  => "/usr/bin/env test \\! -f ${sentinel} || /usr/bin/env test \\! -z \"$(find /etc/apt -type f -cnewer ${sentinel})\"",
    timeout => 3600,
  }
}

class test_server {
  file { 'dhclient.conf':
    path    => "/etc/dhcp3/dhclient.conf",
    content => '
option rfc3442-classless-static-routes code 121 = array of unsigned integer 8;

send host-name "<hostname>";
supersede domain-name "local";
request subnet-mask, broadcast-address, time-offset, routers,
domain-name, domain-name-servers, domain-search, host-name,
netbios-name-servers, netbios-scope, interface-mtu,
rfc3442-classless-static-routes, ntp-servers;',
    owner => root,
    group => root,
    mode  => 0644,
  }

  group { 'puppet':
    ensure => "present",
  }

  class { 'apt_get_update':
    stage => pre
  }

  class { 'wp_micro':
    stage          => main,
    domain         => "fortythree.local",
    mysql_password => 'kdjfhskjh',
    db_password    => 'lksgjshfg',
  }
}

include test_server
