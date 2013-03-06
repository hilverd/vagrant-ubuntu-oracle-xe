# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.host_name = "oracle"

  config.vm.network :hostonly, "192.168.33.10"
  #config.vm.network :hostonly, "192.168.33.10"
  config.vm.forward_port 1521, 1521

  config.vm.provision :puppet,
  :module_path => "modules",
  :options => "--verbose --trace" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "base.pp"
  end

  # Oracle claims to need 512MB of memory available minimum.
  config.vm.customize ["modifyvm", :id,
                       "--memory", "512"]
end
