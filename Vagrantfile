# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.host_name = "oracle"
  config.vm.forward_port 1521, 1521
  config.vm.share_folder "database", "/vagrant/database", "/Users/cwalker/workspaces/ge/ge-data-management/database" 

  config.vm.provision :puppet,
  :module_path => "modules",
  :options => "--verbose --trace" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "base.pp"
  end

  config.vm.customize ["modifyvm", :id, "--name", "oracle", "--memory", "2048"]
end
