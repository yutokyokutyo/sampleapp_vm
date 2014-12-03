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
    git clone https://github.com/yutokyokutyo/sample_app.git
fi









# Gemfileの内容を変更し、bundlerでインストールする
cat <<'EOS' > /home/vagrant/sample_app/Gemfile
source 'https://rubygems.org'
ruby '2.1.5'
#ruby-gemset=railstutorial_rails_4_0

gem 'rails', '4.0.8'
gem 'bootstrap-sass', '2.3.2.0'
gem 'sprockets', '2.11.0'
gem 'bcrypt-ruby', '3.1.2'
gem 'faker', '1.1.2'
gem 'will_paginate', '3.0.4'
gem 'bootstrap-will_paginate', '0.0.9'
gem 'libv8'
gem 'execjs'
gem 'therubyracer', :platforms => :ruby
gem 'nokogiri', '1.6.4.1'
gem 'rbenv-rehash'

group :development, :test do
  gem 'sqlite3', '1.3.8'
  gem 'rspec-rails', '2.13.1'
  gem 'guard-rspec', '2.5.0'
  gem 'spork-rails', '4.0.0'
  gem 'guard-spork', '1.5.0'
  gem 'childprocess', '0.3.6'
  gem 'serverspec'
end

group :test do
  gem 'selenium-webdriver', '2.35.1'
  gem 'capybara', '2.1.0'
  gem 'factory_girl_rails', '4.2.0'
  gem 'cucumber-rails', '1.4.0', :require => false
  gem 'database_cleaner', github: 'bmabey/database_cleaner'
end

gem 'sass-rails', '4.0.1'
gem 'uglifier', '2.1.1'
gem 'coffee-rails', '4.0.1'
gem 'jquery-rails', '3.0.4'
gem 'turbolinks', '1.1.1'
gem 'jbuilder', '1.0.2'

group :doc do
  gem 'sdoc', '0.3.20', require: false
end

group :production do
  gem 'pg', '0.15.1'
  gem 'rails_12factor', '0.0.2'
end
EOS
cd /home/vagrant/sample_app/ ; bundle install --without production --path /home/vagrant/sample_app/vendor/bundle

# iptablesの設定
if ! sudo grep 'tcp -m tcp --dport 3000 -j ACCEPT' /etc/sysconfig/iptables ; then
    sudo iptables -I INPUT 4 -p tcp -m tcp --dport 3000 -j ACCEPT
    sudo sh -c "iptables-save > /etc/sysconfig/iptables"
fi
sudo service iptables restart
