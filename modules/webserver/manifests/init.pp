class webserver {
  package { 
    'apache2': 
    ensure => installed 
  }

  file { "/var/www/html/index.html":
    ensure => file,
    mode   => '755',
    owner  => root,
    group  => root,
    source => "puppet:///modules/webserver/index.html",
    require => Package['apache2']
  }
  
  service {
    'apache2':
    ensure => true,
    enable => true,
    require => Package['apache2']
  }
}
