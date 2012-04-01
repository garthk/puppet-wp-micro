class nginx {
  ppa { 'stable nginx':
    user => 'nginx',
    package => 'stable',
  }

  package { 'nginx': 
    ensure => installed,
    require => Ppa['stable nginx'],
  }

  file { 'nginx drop':
    path => "/etc/nginx/conf.d/drop",
    content => file("/etc/puppet/files/nginx-drop"),
  }

  file { 'nginx default.conf':
    path => "/etc/nginx/conf.d/default.conf",
    content => template("/etc/puppet/templates/nginx-default.conf.erb"),
  }

  file { '/var/www':
    ensure => directory,
    owner => "www-data",
    group => "www-data",
    mode => 0755,
    require => Package['nginx'],
  }
}
