$stash_home = "/home/stash"
$stash_install = "/stash"
$path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

include stash

package { "default-jre":
	ensure => present,
}

package { "git":
	ensure => present,
}

class stash {
	exec { "stash_install":
		command => "tar zx /tmp/atlassian-stash-3.10.2.tar.gz",
		path => $path,
		cwd => $stash_install,
		user => "stash",
		onlyif => [ "ls /tmp/atlassian-stash-3.10.2.tar.gz",
					"dpkg -s git",
					"dpkg -s default-jre",],
	}

	file { "/stash":
		ensure => directory,
		owner => "stash",
		mode => "0660",
		require => User["stash"],
	}

	user { "stash":
		name => "stash",
		home => $stash_home,
	}

	exec { "get_stash_file":
		command => "wget https://www.atlassian.com/software/stash/downloads/binary/atlassian-stash-3.10.2.tar.gz",
		cwd => "/tmp",
		path => $path,
		user => "stash",
		require => User["stash"],
		creates => "/tmp/atlassian-stash-3.10.2.tar.gz",
	}

	exec { "start_stash":
		command => "$stash_install/atlassian-stash-3.10.2/bin/start_stash.sh",
		environment => "STASH_HOME=$stash_home",
		user => "stash",
		path => $path,
		cwd => "$stash_install/atlassian-stash-3.10.2/bin",
	}
}
