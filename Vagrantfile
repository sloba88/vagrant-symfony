# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "precise64"
    config.vm.box_url = "http://files.vagrantup.com/precise64.box"
    config.vm.network "private_network", ip: "33.33.33.100"
    config.vm.network :forwarded_port, guest: 3306, host: 1235
    config.vm.synced_folder ".", "/vagrant",
    	:nfs => (RUBY_PLATFORM =~ /linux/ or RUBY_PLATFORM =~ /darwin/)

    config.vm.provision :shell, :path => "upgrade_puppet.sh"

    config.vm.provider "virtualbox" do |v|
      v.memory = 4096
      v.cpus = 8
    end

    config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "puppet/manifests"
        puppet.module_path = "puppet/modules"
        puppet.options = ['--verbose']
    end
end