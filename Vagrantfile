# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hfm4/centos6"

  config.vm.provision :shell do |shell|
    shell.path = "vagrant/provision.sh"
    shell.privilaged = false
  end

  # DNSの名前解決tips
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
  end

  #  ビルド時間短縮のための仮想CPUの数を増やす
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--cpus",  4]
    vb.customize ["modifyvm", :id, "--hpet", "on"]   # おまじない設定。
    vb.customize ["modifyvm", :id, "--acpi", "off"]
  end

  config.vm.network :forwarded_port, host: 3000, guest: 3000
end
