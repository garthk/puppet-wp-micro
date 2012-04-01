class nginx {
  case $nginx_domain {
    "" : {
      fail("\$nginx_domain not set")
    }
  }

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

  file { 'nginx FastCGI conf':
    path => "/etc/nginx/fastcgi_params",
    content => file("/etc/puppet/files/nginx-fastcgi_params"),
  }

  file { '/var/www':
    ensure => directory,
    owner => "www-data",
    group => "www-data",
    mode => 0755,
    require => Package['nginx'],
  }
}
