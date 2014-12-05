require 'spec_helper'

describe 'packages' do
  packages = %w(
  patch
  git
  gcc
  gcc-c++
  openssl
  openssl-devel
  readline
  readline-devel
  libxml2.x86_64
  libxml2-devel
  libxslt
  libxslt-devel
  sqlite.x86_64
  sqlite-devel.x86_64
  )

  packages.each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end
end

describe 'Ruby' do
  describe 'rbenv' do
    describe command('/home/vagrant/.rbenv/bin/rbenv -v') do
      its(:stdout) { should match /rbenv 0\.4\.\d/ }
    end
    describe file('/home/vagrant/.bash_profile') do
      its(:content) { should match %r(export PATH="\$HOME/\.rbenv/bin:\$PATH") }
      its(:content) { should match %r(eval "\$\(rbenv init -\)") }
    end
  end

  describe file('/home/vagrant/.rbenv/plugins/ruby-build') do
    it { should be_directory }
  end

  describe file('/home/vagrant/.rbenv/version') do
    its(:content) { should match /2\.1\.\d/ }
  end
  describe command('/home/vagrant/.rbenv/shims/ruby -v') do
    its(:stdout) { should match /ruby 2\.1\.\d/ }
  end
end

describe 'Rails' do
  describe file('/home/vagrant/Sample_app_on_VM') do
    it { should be_directory }
    it { should be_mode            755    }
    it { should be_owned_by     'vagrant' }
    it { should be_grouped_into 'vagrant' }
  end

  describe command('/home/vagrant/.rbenv/shims/bundle -v') do
    its(:stdout) { should match /Bundler version 1\.7\.\d/ }
  end

  describe file('/home/vagrant/Sample_app_on_VM/Gemfile') do
    its(:content) { should match /sqlite3/ }
    its(:content) { should match /rails/ }
    its(:content) { should match /libv8/ }
    its(:content) { should match /therubyracer/ }
    its(:content) { should match /execjs/ }
    its(:content) { should match /nokogiri/ }
    its(:content) { should match /rbenv-rehash/ }
  end

  describe 'only specific port open as countermeasure for firewall' do
    describe iptables do
      it { should have_rule('-A INPUT -p tcp -m tcp --dport 3000 -j ACCEPT') }
    end
    describe service('iptables') do
      it { should be_running }
    end
  end

  describe file('/home/vagrant/Sample_app_on_VM/db/migrate') do
    it { should be_directory }
  end

  describe port(3000) do
    it { should be_listening.with('tcp') }
  end

  describe service('rails') do
    it { should be_running }
  end
end
