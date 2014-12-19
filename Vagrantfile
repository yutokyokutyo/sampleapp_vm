# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hfm4/centos6"

config.vm.provision :shell do |update_puppet|
    update_puppet.inline = <<-'SCRIPT'
      require_version='3.7.3'
      puppet_version=$(rpm -q --queryformat '%{VERSION}' puppet)
      [ "$puppet_version" = "$require_version" ] || {
          rpm --import http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs
          yum install -y http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
          yum install -y "puppet-${require_version}"
      }
    SCRIPT
  end

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "vagrant"
    puppet.manifest_file  = "init.pp"
    options = ["--verbose", "--show_diff", "--detailed-exitcodes"]
    options << "--noop"  if ENV['NOOP']
    options << "--debug" if ENV['DEBUG']
    puppet.options = options
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
