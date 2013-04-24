# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.
  
  config.vm.box = "precise64"

  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.hostname = "oracle"
  

  config.vm.network :forwarded_port, guest: 1521, host: 1521
  config.vm.synced_folder "/Users/cwalker/workspaces/ge/ge-data-management/database", "/gdm/database",  :extra => 'dmode=555,fmode=555'
  config.vm.synced_folder "/Users/cwalker/workspaces/ge/ge-data-management/dbUpdates", "/gdm/dbUpdates",  :extra => 'dmode=555,fmode=555'
  config.vm.synced_folder "/Users/cwalker/workspaces/ge/etl-tools", "/gdm/etl-tools",  :extra => 'dmode=555,fmode=555'



  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider :virtualbox do |vb|
     vb.customize ["modifyvm", :id, "--cpus", 4]
     vb.customize ["modifyvm", :id, "--name", "oracle", "--memory", "4096"]
 
  end

  config.vm.provision :shell, :inline => "echo \"America/New_York\" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata"

  config.vbguest.auto_update = false

  config.vm.provision :puppet,
  :module_path => "modules",
  :options => "--verbose --trace" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "base.pp"
  end
end
