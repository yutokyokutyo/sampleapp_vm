Package { allow_virtual => true }

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
