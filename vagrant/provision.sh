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
    gcc
    gcc-c++
    openssl
    readline
    libxml2.x86_64
    libxslt sqlite.x86_64
)
sudo yum -y install "${packages[@]}"

# rbenvをcloneする
CHK_DIR_rbenv=/home/vagrant/.rbenv

if [ ! -d ${CHK_DIR_rbenv} ] ; then
    git clone https://github.com/sstephenson/rbenv.git /home/vagrant/.rbenv
    # rbenvの環境設定
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/vagrant/.bash_profile
    echo 'eval "$(rbenv init -)"' >> /home/vagrant/.bash_profile
    exec $SHELL -l
fi

# ruby-buildをcloneする
CHK_DIR_ruby_build=/home/vagrant/.rbenv/plugins/ruby-build

if [ ! -d ${CHK_DIR_ruby_build} ] ; then
    git clone https://github.com/sstephenson/ruby-build.git /home/vagrant/.rbenv/plugins/ruby-build
fi

# Rubyをインストールする
CHK_DIR_ruby=/home/vagrant/.rbenv/versions/2.1.5

if [ ! -d ${CHK_DIR_ruby} ] ; then
     CONFIGURE_OPTS="--disable-install-doc" rbenv install 2.1.5
     rbenv global 2.1.5
fi

# .gemrcの作成とrdoc,riをいれない設定
CHK_FILE_gemrc=/home/vagrant/.gemrc

if [ ! -f ${CHK_FILE_gemrc} ] ; then
    touch /home/vagrant/.gemrc
    echo 'install: --no-rdoc --no-ri' >> /home/vagrant/.gemrc
    echo 'update: --no-rdoc --no-ri' >> /home/vagrant/.gemrc
fi

# bundlerをインストールする
CHK_FILE_bundle=/home/vagrant/.rbenv/shims/bundle

if [ ! -f ${CHK_FILE_bundle} ] ; then
    gem install bundler
fi

# Sample_appを git clone する
CHK_DIR_sample_app=/home/vagrant/sample_app

if [ ! -d ${CHK_DIR_sample_app} ] ; then
    git clone https://github.com/yutokyokutyo/Sample_app_on_VM.git
fi

# bundler でインストールする
cd /home/vagrant/sample_app/ ; bundle install --without production --path /home/vagrant/sample_app/vendor/bundle

# iptablesの設定
if ! sudo grep 'tcp -m tcp --dport 3000 -j ACCEPT' /etc/sysconfig/iptables ; then
    sudo iptables -I INPUT 4 -p tcp -m tcp --dport 3000 -j ACCEPT
    sudo sh -c "iptables-save > /etc/sysconfig/iptables"
fi
sudo service iptables restart
