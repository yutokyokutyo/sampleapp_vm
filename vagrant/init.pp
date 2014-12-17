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
	user     => "vagrant",
	cwd      => "/home/vagrant",
	path     => ['/usr/bin'],
	command  => "git clone https://github.com/sstephenson/rbenv.git .rbenv",
	creates => "/home/vagrant/.rbenv",
	require  => Package['git'],
}

file { '/home/vagrant/.bash_profile':
    source => '/vagrant/template_bash_profile',
}

# ruby-build をクローンする
exec { 'clone ruby-build':
	user     => "vagrant",
	cwd      => "/home/vagrant/.rbenv",
	path     => ['/usr/bin'],
	command  => "git clone https://github.com/sstephenson/ruby-build.git /home/vagrant/.rbenv/plugins/ruby-build",
	creates => "/home/vagrant/.rbenv/plugins/ruby-build",
	require  => Package['git'],
}

# Ruby をインストールする
exec { 'install ruby':
	user        => "vagrant",
	cwd         => "/home/vagrant/.rbenv",
	environment => ['HOME=/home/vagrant'],
	path        => "/bin:/usr/bin:/usr/local/rbenv/bin:/usr/local/rbenv/plugins/ruby-build/bin/",
	command     => "bash -c 'source /home/vagrant/.bash_profile ; rbenv install 2.1.5 ; rbenv global 2.1.5'",
	creates     => "/home/vagrant/.rbenv/versions/2.1.5",
	require     => Exec['clone ruby-build'],
}
