Package { allow_virtual => true }
Exec { path => ['/usr/bin:/bin'] }

# package をインストールする
package {
  [
    'patch',
    'git',
    'openssl-devel',
    'readline-devel',
    'libxml2-devel',
    'libxslt-devel',
    'sqlite-devel',
    'gcc',
    'gcc-c++',
    'openssl',
    'readline',
    'libxml2',
    'libxslt',
    'sqlite',
  ]:
    ensure => installed,
}

# rbenv をクローンする
exec { 'clone rbenv':
  user    => 'vagrant',
  path    => ['/usr/bin'],
  command => 'git clone https://github.com/sstephenson/rbenv.git /home/vagrant/.rbenv',
  creates => '/home/vagrant/.rbenv',
  require => Package['git'],
}

file { '/home/vagrant/.bash_profile':
  owner  => 'vagrant',
  group  => 'vagrant',
  mode   => '644',
  source => '/vagrant/template_bash_profile',
}

# ruby-build をクローンする
exec { 'clone ruby-build':
  user    => 'vagrant',
  command => 'git clone https://github.com/sstephenson/ruby-build.git /home/vagrant/.rbenv/plugins/ruby-build',
  creates => '/home/vagrant/.rbenv/plugins/ruby-build',
  require => Package['git'],
}

# Ruby をインストールする
exec { 'install ruby':
  user        => 'vagrant',
  cwd         => '/home/vagrant/.rbenv',
  environment => ['HOME=/home/vagrant'],
  command     => 'bash -c "source /home/vagrant/.bash_profile ; rbenv install 2.1.5 ; rbenv global 2.1.5"',
  creates     => '/home/vagrant/.rbenv/versions/2.1.5',
  timeout     => 1000,
  require     => [
    Exec['clone ruby-build'],
    Exec['clone rbenv'],
  ]
}

# .gemrcの作成とrdoc,riをいれない設定
file { '/home/vagrant/.gemrc':
  owner  => 'vagrant',
  group  => 'vagrant',
  mode   => '644',
  source => '/vagrant/.gemrc_setting',
}

# bundler をインストールする
exec { 'install bundler':
  user    => 'vagrant',
  cwd     => '/home/vagrant/.rbenv',
  environment => ['HOME=/home/vagrant'],
  command => '/bin/bash -c "source /home/vagrant/.bash_profile ; gem install bundler"',
  creates => '/home/vagrant/.rbenv/shims/bundle',
  require => Exec['install ruby'],
}

# Sample_app をクローンする
exec { 'clone Sample_app':
  user     => 'vagrant',
  cwd      => '/home/vagrant',
  command  => 'git clone https://github.com/yutokyokutyo/Sample_app_on_VM.git',
  creates  => '/home/vagrant/Sample_app_on_VM',
  require  => Package['git'],
}

# 必要な Gem を bundle install する
exec { 'install gem':
  user        => 'vagrant',
  cwd         => '/home/vagrant/Sample_app_on_VM',
  environment => ['HOME=/home/vagrant'],
  command     => 'bash -c "source /home/vagrant/.bash_profile ; bundle install --without production --path vendor/bundle"',
  creates     => '/home/vagrant/Sample_app_on_VM/vendor/bundle',
  require     => Exec['install bundler'],
  timeout     => 1000,
}

# iptables の設定
file { '/etc/sysconfig/iptables':
  owner  => 'root',
  group  => 'root',
  mode   => '600',
  source => '/vagrant/template_iptables',
}

# iptables を起動する
exec { 'restart iptables':
  user    => 'root',
  cwd     => '/etc/sysconfig',
  command => 'sudo /sbin/service iptables restart',
  require => File['/etc/sysconfig/iptables'],
}
