class database {
  package { 
    'mariadb-server': 
    ensure => installed 
  }

  service {
    'mariadb':
    ensure => true,
    enable => true,
    require => Package['mariadb-server']
  }
}
