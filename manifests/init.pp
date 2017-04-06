include 'dummy_service'

package { 'apt-transport-https':
  ensure => present,
}

class { 'nginx': }

nginx::resource::server { 'default':
  www_root => '/var/www/html',
}

file { '/var/www':
  ensure  => directory,
  recurse => true,
}

file { '/var/www/html':
  ensure  => directory,
  recurse => true,
}
-> file { '/var/www/html/index.html':
  ensure  => file,
  content => 'Hello Puppet and Docker',
}

exec { 'Disable Nginx daemon mode':
  command => '/bin/echo "daemon off;" >> /etc/nginx/nginx.conf',
  require => Class['nginx']
}
