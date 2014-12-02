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
    gcc-c++
    openssl
    readline
    libxml2.x86_64
    libxslt sqlite.x86_64
)

yum -y install "${packages[@]}"
for p in "${packages[@]}"; do
    yum -y install $p
done

# rbenvをcloneする
CHK_DIR=/home/vagrant/.rbenv

if [ ! -d ${CHK_DIR} ] ; then
    su - vagrant -c 'git clone https://github.com/sstephenson/rbenv.git /home/vagrant/.rbenv'
    # rbenvの環境設定
    su - vagrant
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/vagrant/.bash_profile
    echo 'eval "$(rbenv init -)"' >> /home/vagrant/.bash_profile
    su - vagrant -c 'exec $SHELL -l'
fi

# ruby-buildをcloneする
CHK_DIR=/home/vagrant/.rbenv/plugins/ruby-build

if [ ! -d ${CHK_DIR} ] ; then
    su - vagrant -c 'git clone https://github.com/sstephenson/ruby-build.git /home/vagrant/.rbenv/plugins/ruby-build'
fi

# Rubyをインストールする
CHK_DIR=/home/vagrant/.rbenv/versions/2.1.5

if [ ! -d ${CHK_DIR} ] ; then
    su - vagrant -c 'CONFIGURE_OPTS="--disable-install-doc" rbenv install 2.1.5'
    su - vagrant -c 'rbenv global 2.1.5'
fi

# .gemrcの作成とrdoc,riをいれない設定
CHK_FILE=/home/vagrant/.gemrc

if [ ! -f ${CHK_FILE} ] ; then
    su - vagrant -c "touch /home/vagrant/.gemrc"
    su - vagrant
    echo 'install: --no-rdoc --no-ri' >> /home/vagrant/.gemrc
    echo 'update: --no-rdoc --no-ri' >> /home/vagrant/.gemrc
fi


# bundlerをインストールする
CHK_FILE=/home/vagrant/.rbenv/shims/bundle

if [ ! -f ${CHK_FILE} ] ; then
    su - vagrant -c 'gem install bundler'
fi

# Sample_appを git clone する
CHK_DIR=/home/vagrant/sample_app

if [ ! -d ${CHK_DIR} ] ; then
    su - vagrant -c 'git clone https://github.com/yutokyokutyo/sample_app.git'
    su - vagrant -c 'cd /home/vagrant/sample_app/ ; rm Gemfile Gemfile.lock ; bundle init'
fi

# Gemfileにgemを追記してbundlerでインストールする
CHK_FILE=/home/vagrant/sampleapp_provisioning_gemfile/Gemfile

if [ ! -f ${CHK_FILE} ] ; then
    su - vagrant -c 'git clone https://github.com/yutokyokutyo/sampleapp_provisioning_gemfile.git'
    su - vagrant -c 'cp -f /home/vagrant/sampleapp_provisioning_gemfile/Gemfile /home/vagrant/sample_app/Gemfile'
fi
su - vagrant -c 'cd /home/vagrant/sample_app/ ; bundle install --without production --path /home/vagrant/sample_app/vendor/bundle'

# iptablesの設定
if ! sudo grep 'tcp -m tcp --dport 3000 -j ACCEPT' /etc/sysconfig/iptables ; then
    sed -i -e "s/COMMIT/-I INPUT -p tcp -m tcp --dport 3000 -j ACCEPT/g" /etc/sysconfig/iptables
    echo 'COMMIT' >> /etc/sysconfig/iptables
fi
service iptables restart
