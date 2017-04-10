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

  config.vm.provision "shell",
    inline: "yum -y install git"

# uncomment to refresh correcthorse ansible roles from github

  config.vm.define "mortimer-box" do |box| 

    box.vm.network "forwarded_port", guest: 80, host: 8080
    box.vm.network "forwarded_port", guest: 443, host: 8443



    box.vm.provision :ansible_local do |ansible|
      ansible.galaxy_command = "ansible-galaxy install -r %{role_file} --roles-path=%{roles_path} --force"
      ansible.galaxy_role_file = "/var/www/mortimer.local/www/provisioning/requirements.yml"
      ansible.provisioning_path = "/var/www/mortimer.local/www/provisioning"
      ansible.playbook = "playbook.yml"
      ansible.verbose = true
      ansible.install = true
      ansible.sudo = true
      ansible.limit = "all"
      ansible.groups = {
        "mortimer" => ["mortimer-box"]
      }
    end

  end

end
