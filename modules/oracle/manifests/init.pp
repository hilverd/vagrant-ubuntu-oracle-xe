class oracle::server {
  exec {
    "/usr/bin/apt-get -y update":
      alias => "aptUpdate",
      timeout => 3600;
  }

  package {
    "alien":
      ensure => installed;
    "bc":
      ensure => installed;
    "curl":
      ensure => installed;
    "git":
      ensure => installed;
    "htop":
      ensure => installed;
    "libaio1":
      ensure => installed;
    "monit":
      ensure => installed;
    "ntp":
      ensure => installed;
    "rsyslog":
      ensure => installed;
    "unixodbc":
      ensure => installed;
    "unzip":
      ensure => installed;
  }

  service {
    "ntp":
      ensure => stopped;
    "monit":
      ensure => running;
    "rsyslog":
      ensure => running;
    "procps":
      ensure => running;
  }
  
  file {
    "/sbin/chkconfig":
      mode => 0755,
      source => "puppet:///modules/oracle/chkconfig";
    "/etc/sysctl.d/60-oracle.conf":
      source => "puppet:///modules/oracle/60-oracle.conf";
    "/etc/rc2.d/S01shm_load":
      mode => 0755,
      source => "puppet:///modules/oracle/S01shm_load";
  }

  user {
    "syslog":
      ensure => present,
      groups => ["syslog", "adm"];
  }
  
  group {
    "puppet":
      ensure => present;
  }

  exec {
    "set up shm":
      command => "/etc/rc2.d/S01shm_load start",
      require => File["/etc/rc2.d/S01shm_load"],
      user => root;
  }
}

class oracle::swap {
  exec {
    "create swapfile":
      command => "/bin/dd if=/dev/zero of=/swapfile bs=1024 count=2097152",
      user => root,
      creates => "/swapfile";
    "set up swapfile":
      command => "/sbin/mkswap /swapfile",
      require => Exec["create swapfile"],
      user => root;
    "enable swapfile":
      command => "/sbin/swapon /swapfile",
      require => Exec["set up swapfile"],
      user => root;
    "add swapfile entry to fstab":
      command => "/bin/echo >>/etc/fstab /swapfile swap swap defaults 0 0",
      user => root;
  }
}

class oracle::xe {
  file {
    "/tmp/oracle-xe-11.2.0-1.0.x86_64.rpm.zip":
      source => "puppet:///modules/oracle/oracle-xe-11.2.0-1.0.x86_64.rpm.zip";
    "/etc/profile.d/oracle-env.sh":
      source => "puppet:///modules/oracle/oracle-env.sh";
    "/tmp/xe.rsp":
      source => "puppet:///modules/oracle/xe.rsp";
    "/bin/awk":
      ensure => link,
      target => "/usr/bin/awk";
    "/var/lock/subsys":
      ensure => directory;
    "/var/lock/subsys/listener":
      ensure => present;
  }

  exec {
    "unzip xe":
      command => "/usr/bin/unzip -o /tmp/oracle-xe-11.2.0-1.0.x86_64.rpm.zip",
      require => [Package["unzip"], File["/tmp/oracle-xe-11.2.0-1.0.x86_64.rpm.zip"]],
      cwd => "/tmp",
      user => root,
      creates => "/tmp/oracle-xe-11.2.0-1.0.x86_64.rpm";
    "alien xe":
      command => "/usr/bin/alien --to-deb --scripts /tmp/Disk1/oracle-xe-11.2.0-1.0.x86_64.rpm",
      cwd => "/tmp/Disk1",
      require => [Package["alien"], Exec["unzip xe"]],
      creates => "/tmp/Disk1/oracle-xe_11.2.0-2_amd64.deb",
      user => root;
    "configure xe":
      command => "/etc/init.d/oracle-xe configure responseFile=/tmp/xe.rsp >> /tmp/xe-install.log",
      require => [Package["oracle-xe"],
                  File["/etc/profile.d/oracle-env.sh"],
                  File["/tmp/xe.rsp"],
                  File["/var/lock/subsys/listener"],
                  Exec["set up shm"],
                  Exec["enable swapfile"]];
  }
  
  package {
    "oracle-xe":
      provider => "dpkg",
      ensure => latest,
      require => [Exec["alien xe"]],
      source => "/tmp/Disk1/oracle-xe_11.2.0-2_amd64.deb";
  }
}
