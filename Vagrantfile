# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['PYTHONIOENCODING'] = "utf-8"

Vagrant.configure(2) do |config|

  config.vm.box = "boxcutter/centos73"

  config.vm.synced_folder ".", "/var/www/mortimer.local/www"

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 1
  end

# uncomment to refresh correcthorse ansible roles from github

  config.vm.provision "ansible" do |galaxy|
    galaxy.playbook = "provisioning/galaxy.yml"
  end

  config.vm.define "mortimer-box" do |box| 

    box.vm.network "forwarded_port", guest: 80, host: 8080
    box.vm.network "forwarded_port", guest: 443, host: 8443

    box.vm.provision "ansible" do |ansible|
      ansible.playbook = "provisioning/playbook.yml"
      ansible.sudo = true
      ansible.groups = {
        "mortimer" => ["mortimer-box"]
      }
    end

  end

end
