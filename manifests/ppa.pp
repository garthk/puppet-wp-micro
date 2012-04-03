class python_software_properties {
  $package = "python-software-properties"
  package { $package:
    ensure => installed,
  }
}

define wp_micro::ppa($user, $package) {
  include python_software_properties
  $slashed="${user}/${package}"
  $dashed="${user}-${package}"
  exec { "ppa-repo-added-${dashed}":
    command => "/usr/bin/add-apt-repository ppa:${slashed}",
    creates => "/etc/apt/sources.list.d/${dashed}-${lsbdistcodename}.list",
    require => Package[$python_software_properties::package],
  }

  exec { "ppa-repo-ready-${dashed}" :
    command => "/usr/bin/apt-get update",
    require => Exec["ppa-repo-added-${dashed}"],
    creates => "/var/lib/apt/lists/ppa.launchpad.net_${dashed}_ubuntu_dists_${lsbdistcodename}_Release",
    timeout => 3600,
  }
}
