$stash_home = "/home/stash"
$stash_install = "/stash"
$path_dir = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

include stash

package { "default-jre":
	ensure => present,
}

package { "git":
	ensure => present,
}

package { "perl":
	ensure => present,
}

class stash {
	exec { "stash_install":
		command => "tar zxf /tmp/atlassian-stash-3.10.2.tar.gz",
		path => $path_dir,
		cwd => $stash_install,
		user => "stash",
		require => [Package["default-jre"], 
					Package["git"], 
					Package["perl"],
					Exec["get_stash_file"], 
					Tidy["clean_old_install"]],
	}

	file { "/stash":
		ensure => directory,
		owner => "stash",
		mode => "0660",
		require => [User["stash"], Tidy["clean_old_install"]],
	}

	file { "/home/stash":
		ensure => directory,
		owner => "stash",
		group => "users",
		mode => "0644",
		require => User["stash"],
	}

	user { "stash":
		name => "stash",
		home => $stash_home,
	}

	exec { "get_stash_file":
		command => "wget https://www.atlassian.com/software/stash/downloads/binary/atlassian-stash-3.10.2.tar.gz",
		cwd => "/tmp",
		path => $path_dir,
		user => "stash",
		require => User["stash"],
		creates => "/tmp/atlassian-stash-3.10.2.tar.gz",
	}

	exec { "start_stash":
		command => "$stash_install/atlassian-stash-3.10.2/bin/start-stash.sh",
		environment => "STASH_HOME=$stash_home",
		user => "stash",
		path => $path_dir,
		cwd => "$stash_install/atlassian-stash-3.10.2/bin",
		require => Exec["move_server_xml"],
	}

	exec { "move_server_xml":
		command => "cp -p $stash_install/atlassian-stash-3.10.2/conf/server.xml $stash_home/server.xml",
		require => Exec["stash_install"],
		path => $path_dir,
		user => "stash",
		creates => "$stash_home/server.xml",
	}

	tidy { "clean_old_install": 
		path => "$stash_install",
		recurse => true,
	}
}
