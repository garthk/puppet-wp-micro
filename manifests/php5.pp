class wp_micro::php5 {
  $key = "A42227CB8D0DC64F"
  exec { 'apt-key for brianmercer':
    path    => "/bin:/usr/bin",
    onlyif  => "apt-key list | grep '${key}'",
    command => "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ${key}",
    user    => 'root',
    group   => 'root',
  }

  wp_micro::ppa { 'brianmercer php5':
    user    => 'brianmercer',
    package => 'php5',
    require => Exec['apt-key for brianmercer'],
  }

  package { ['php5-fpm', 'php-pear', 'php5-common', 'php5-mysql', 'php-apc']:
    ensure  => installed,
    require => Wp_micro::Ppa['brianmercer php5'],
  }

  service { 'php5-fpm':
    ensure  => running,
    enable  => true,
    require => Package['php5-fpm'],
  }
}
