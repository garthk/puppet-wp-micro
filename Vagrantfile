# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "lucid32"
  config.vm.share_folder "wp_micro", "/tmp/vagrant-puppet/modules/wp_micro", ".", :create => true
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "tests"
    puppet.manifest_file = "vagrant.pp"
    puppet.options = ["--modulepath", "/tmp/vagrant-puppet/modules"]
  end
  config.vm.forward_port 4567, 4567
end
