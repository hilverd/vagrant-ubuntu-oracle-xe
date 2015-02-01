node oracle {
  include oracle::server
  include oracle::swap
  include oracle::xe

  user { "vagrant":
    groups => "dba",
    # So that we let Oracle installer create the group
    require => Service["oracle-xe"],
  }
}

$a = file('/home/vagrant/vagrant-ubuntu-oracle-xe/oracle-jdbc/ojdbc6.jar', '/dev/null')
if ($a != '') {
    # java/maven needed for flyway command
    class { 'java':
      distribution => 'jdk',
    }
    class { "maven::maven":
    	version => "3.2.2",
    }
    package { 'maven':
    	ensure => present,
    }
}
