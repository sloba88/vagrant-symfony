# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "ubuntu/trusty64"
    config.vm.network "private_network", ip: "33.33.33.100"
    config.vm.network :forwarded_port, guest: 3306, host: 1237
    config.ssh.forward_agent = true
    config.ssh.insert_key = true
    config.vm.synced_folder ".", "/vagrant",
    	:nfs => (RUBY_PLATFORM =~ /linux/ or RUBY_PLATFORM =~ /darwin/)

    #config.vm.provision :shell, :path => "upgrade_puppet.sh"

    config.puppet_install.puppet_version = :latest

    config.vm.provider "virtualbox" do |v|
      v.memory = 4096
      v.cpus = 8
      v.name = "ubuntu14.04-hhvm"
    end

    config.vm.provision :puppet do |puppet|
        puppet.environment = "puppet"
        puppet.environment_path = "./"
        puppet.options = ['--verbose']
    end
end