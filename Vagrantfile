# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |wpmicro|
  wpmicro.vm.box = "lucid32"
  wpmicro.vm.share_folder "wp_micro", "/tmp/vagrant-puppet/modules/wp_micro", ".", :create => true
  wpmicro.vm.network :hostonly, "192.168.31.43"
  wpmicro.vm.provision :puppet do |puppet|
    puppet.manifests_path = "tests"
    puppet.manifest_file = "vagrant.pp"
    puppet.options = ["--modulepath", "/tmp/vagrant-puppet/modules"]
  end
end
