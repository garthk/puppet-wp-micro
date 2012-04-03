class wp_micro::nginx($domain, $port = 80) {
  ppa { 'stable nginx':
    user    => 'nginx',
    package => 'stable',
  }

  package { 'nginx': 
    ensure  => installed,
    require => Wp_micro::Ppa['stable nginx'],
  }

  service { 'nginx':
    ensure  => running,
    enable  => true,
    require => Package['nginx'],
  }

  file { 'nginx drop':
    path   => "/etc/nginx/conf.d/drop",
    source => "puppet:///modules/wp_micro/nginx-drop",
    require => Package['nginx'],
  }

  $nginx_domain = $domain # for template
  $nginx_port = $port
  file { 'nginx default.conf':
    path    => "/etc/nginx/conf.d/default.conf",
    content => template("wp_micro/nginx-default.conf.erb"),
    require => Package['nginx'],
  }

  file { 'nginx FastCGI conf':
    path   => "/etc/nginx/fastcgi_params",
    source => "puppet:///modules/wp_micro/nginx-fastcgi_params",
    require => Package['nginx'],
  }

  file { '/var/www':
    ensure  => directory,
    owner   => "www-data",
    group   => "www-data",
    mode    => 0755,
    require => Package['nginx'],
  }
}
