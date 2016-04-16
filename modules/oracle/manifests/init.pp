class oracle::server {
  exec { "apt-update":
    command => "/usr/bin/apt-get -y update",
    timeout => 3600;
  }

  package {
    ["alien", "bc", "libaio1", "unixodbc", "unzip", "rlwrap", "dos2unix"]:
      ensure => installed;
  }

  exec { "procps":
    refreshonly => true,
    command => "/etc/init.d/procps start";
  }

  file {
    "/tmp/chkconfig":
      mode => "0755",
      source => "puppet:///modules/oracle/chkconfig";
    "/tmp/60-oracle.conf":
      notify => Exec['procps'],
      source => "puppet:///modules/oracle/60-oracle.conf";
    "/tmp/S01shm_load":
      mode => "0755",
      source => "puppet:///modules/oracle/S01shm_load";
  }

  # If we're running on Windows, then Git may have converted line endings to CRLF upon cloning the
  # repository. Here we use dos2unix to make sure that they are LF.
  exec {
    "dos2unix chkconfig":
      command => "/usr/bin/dos2unix -n /tmp/chkconfig /sbin/chkconfig",
      creates => "/sbin/chkconfig",
      require => [File["/tmp/chkconfig"], Package["dos2unix"]];
    "dos2unix 60-oracle.conf":
      command => "/usr/bin/dos2unix -n /tmp/60-oracle.conf /etc/sysctl.d/60-oracle.conf",
      creates => "/etc/sysctl.d/60-oracle.conf",
      require => [File["/tmp/60-oracle.conf"], Package["dos2unix"]];
    "dos2unix S01shm_load":
      command => "/usr/bin/dos2unix -n /tmp/S01shm_load /etc/rc2.d/S01shm_load",
      creates => "/etc/rc2.d/S01shm_load",
      require => [File["/tmp/S01shm_load"], Package["dos2unix"]];
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

  exec { "set up shm":
    command => "/etc/rc2.d/S01shm_load start",
    require => Exec["dos2unix S01shm_load"],
    user => root,
    unless => "/bin/mount | grep /dev/shm 2>/dev/null";
  }

  Exec["apt-update"] -> Package <| |>
}

class oracle::swap {
  exec {
    "create swapfile":
      # Needs to be 2 times the memory
      command => "/bin/dd if=/dev/zero of=/swapfile bs=1M count=1024",
      user => root,
      creates => "/swapfile";
    "set up swapfile":
      command => "/sbin/mkswap /swapfile",
      require => Exec["create swapfile"],
      user => root,
      unless => "/usr/bin/file /swapfile | grep 'swap file' 2>/dev/null";
    "enable swapfile":
      command => "/sbin/swapon /swapfile",
      require => Exec["set up swapfile"],
      user => root,
      unless => "/bin/cat /proc/swaps | grep '^/swapfile' 2>/dev/null";
    "add swapfile entry to fstab":
      command => "/bin/echo >>/etc/fstab /swapfile swap swap defaults 0 0",
      user => root,
      unless => "/bin/grep '^/swapfile' /etc/fstab 2>/dev/null";
  }

  file {
    "/swapfile":
      mode => "600",
      owner => root,
      group => root,
      require => Exec['create swapfile'];
  }
}

class oracle::xe {
  file {
    "/home/vagrant/oracle-xe-11.2.0-1.0.x86_64.rpm.zip":
      source => "puppet:///modules/oracle/oracle-xe-11.2.0-1.0.x86_64.rpm.zip";
    "/tmp/oracle-env.sh":
      source => "puppet:///modules/oracle/oracle-env.sh";
    "/tmp/xe.rsp.orig":
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
    "dos2unix oracle-env.sh":
      command => "/usr/bin/dos2unix -n /tmp/oracle-env.sh /etc/profile.d/oracle-env.sh",
      creates => "/etc/profile.d/oracle-env.sh",
      require => [File["/tmp/oracle-env.sh"], Package["dos2unix"]];
    "dos2unix xe.rsp":
      command => "/usr/bin/dos2unix -n /tmp/xe.rsp.orig /tmp/xe.rsp",
      creates => "/tmp/xe.rsp",
      require => [File["/tmp/xe.rsp.orig"], Package["dos2unix"]];
  }

  exec {
    "unzip xe":
      command => "/usr/bin/unzip -o oracle-xe-11.2.0-1.0.x86_64.rpm.zip",
      require => [Package["unzip"], File["/home/vagrant/oracle-xe-11.2.0-1.0.x86_64.rpm.zip"]],
      cwd => "/home/vagrant",
      user => root,
      creates => "/home/vagrant/oracle-xe-11.2.0-1.0.x86_64.rpm",
      timeout => 3600,
      unless => "/usr/bin/test -f /etc/default/oracle-xe";
    "alien xe":
      command => "/usr/bin/alien --to-deb --scripts Disk1/oracle-xe-11.2.0-1.0.x86_64.rpm",
      cwd => "/home/vagrant",
      require => [Package["alien"], Exec["unzip xe"]],
      creates => "/home/vagrant/oracle-xe_11.2.0-2_amd64.deb",
      user => root,
      timeout => 3600,
      unless => "/usr/bin/test -f /etc/default/oracle-xe";
    "configure xe":
      command => "/etc/init.d/oracle-xe configure responseFile=/tmp/xe.rsp >> /tmp/xe-install.log",
      timeout => 3600,
      require => [Package["oracle-xe"],
                  Exec["dos2unix oracle-env.sh"],
                  Exec["dos2unix xe.rsp"],
                  File["/var/lock/subsys/listener"],
                  Exec["set up shm"],
                  Exec["enable swapfile"]],
      creates => "/etc/default/oracle-xe";
  }

  package {
    "oracle-xe":
      provider => "dpkg",
      ensure => latest,
      require => [Exec["alien xe"]],
      source => "/home/vagrant/oracle-xe_11.2.0-2_amd64.deb",
  }

  exec {
    "run chkconfig":
      command => "/sbin/chkconfig",
      user => root,
      require => Service["oracle-xe"];
  }

  service {
    "oracle-xe":
      ensure => "running",
      require => [Package["oracle-xe"],
                  Exec["configure xe"],
                  Exec["dos2unix chkconfig"],
                  Exec["dos2unix 60-oracle.conf"]],
  }
}
