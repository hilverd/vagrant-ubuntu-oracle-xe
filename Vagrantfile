# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.host_name = "oracle_xe"

  config.vm.network :hostonly, "192.168.33.10"

  config.vm.provision :puppet,
  :module_path => "modules",
  :options => "--verbose --trace" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "base.pp"
  end

  config.vm.customize ["modifyvm", :id,
                       "--name", "oracle_xe",
                       "--memory", "3048"]
end
