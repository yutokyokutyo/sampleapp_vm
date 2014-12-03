#!/bin/bash
set -eux

# パッケージ集
packages=(
    patch
    git
    openssl-devel
    readline-devel
    libxml2-devel
    libxslt-devel
    sqlite-devel.x86_64
    nodejs
    gcc
    gcc++
    openssl
    readline
    libxml2.x86_64
    libxslt sqlite.x86_64
)
sudo yum -y install "${packages[@]}"

# rbenvをcloneする
CHK_DIR=/home/vagrant/.rbenv

if [ ! -d ${CHK_DIR} ] ; then
    git clone https://github.com/sstephenson/rbenv.git /home/vagrant/.rbenv
    # rbenvの環境設定
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/vagrant/.bash_profile
    echo 'eval "$(rbenv init -)"' >> /home/vagrant/.bash_profile
    exec $SHELL -l
fi

# ruby-buildをcloneする
CHK_DIR=/home/vagrant/.rbenv/plugins/ruby-build

if [ ! -d ${CHK_DIR} ] ; then
    git clone https://github.com/sstephenson/ruby-build.git /home/vagrant/.rbenv/plugins/ruby-build
fi

# Rubyをインストールする
CHK_DIR=/home/vagrant/.rbenv/versions/2.1.5

if [ ! -d ${CHK_DIR} ] ; then
     CONFIGURE_OPTS="--disable-install-doc" rbenv install 2.1.5
     rbenv global 2.1.5
fi

# .gemrcの作成とrdoc,riをいれない設定
CHK_FILE=/home/vagrant/.gemrc

if [ ! -f ${CHK_FILE} ] ; then
    touch /home/vagrant/.gemrc
    echo 'install: --no-rdoc --no-ri' >> /home/vagrant/.gemrc
    echo 'update: --no-rdoc --no-ri' >> /home/vagrant/.gemrc
fi

# bundlerをインストールする
CHK_FILE=/home/vagrant/.rbenv/shims/bundle

if [ ! -f ${CHK_FILE} ] ; then
    gem install bundler
fi

# Sample_appを git clone する
CHK_DIR=/home/vagrant/sample_app

if [ ! -d ${CHK_DIR} ] ; then
    git clone https://github.com/yutokyokutyo/sample_app.git
    cd /home/vagrant/sample_app/ ; rm Gemfile Gemfile.lock ; bundle init
fi

# Gemfileにgemを追記してbundlerでインストールする
CHK_FILE=/home/vagrant/sampleapp_provisioning_gemfile/Gemfile

if [ ! -f ${CHK_FILE} ] ; then
     git clone https://github.com/yutokyokutyo/sampleapp_provisioning_gemfile.git
     cp -f /home/vagrant/sampleapp_provisioning_gemfile/Gemfile /home/vagrant/sample_app/Gemfile
fi
cd /home/vagrant/sample_app/ ; bundle install --without production --path /home/vagrant/sample_app/vendor/bundle

# iptablesの設定
if ! sudo grep 'tcp -m tcp --dport 3000 -j ACCEPT' /etc/sysconfig/iptables ; then
    sudo sed -i -e "s/COMMIT/-I INPUT -p tcp -m tcp --dport 3000 -j ACCEPT/g" /etc/sysconfig/iptables
    sudo echo 'COMMIT' >> /etc/sysconfig/iptables
fi
sudo service iptables restart
