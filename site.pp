include stash

package { "default-jre":
	ensure => present,
}

package { "git":
	ensure => present,
}

class stash {
	exec { "stash_install":
		command => "/tmp/atlassian-stash-3.10.2-x64.bin",
		provider => "dpkg",
		onlyif => [ "ls /tmp/atlassian-stash-3.10.2-x64.bin",
					"dpkg -s git",
					"dpkg -s default-jre",],
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