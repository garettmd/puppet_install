include stash

package { "default-jre":
	ensure => present,
}

package { "git":
	ensure => present,
}

class stash {
	package { "stash":
		ensure => present,
		provider => "dpkg",
		require => [Package["default-jre"], Package["git"], exec["get_stash_file"]],
		source => "/tmp/atlassian-stash-3.10.2-x64.bin",
	}

	file { "/home/stash":
		ensure => directory,
		owner => "stash",
		mode => "0660",
		require => User["stash"],
	}

	user { "stash":
		name => "stash",
		home => "/home/stash",
	}

	exec { "get_stash_file":
		command => "wget https://www.atlassian.com/software/stash/downloads/binary/atlassian-stash-3.10.2-x64.bin",
		cwd => "/tmp",
		user => "stash",
		require => User["stash"],
		environment => "STASH_HOME=/vagrant/stash-home",
		creates => "/tmp/atlassian-stash-3.10.2-x64.bin",
	}
}