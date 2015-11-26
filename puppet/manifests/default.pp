Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }


class system-update {

    exec { 'apt-get update':
        command => 'apt-get update',
    }
}

class dev-packages {

    include gcc
    include wget

    $devPackages = [ "vim", "curl", "git", "capistrano", "rubygems", "openjdk-7-jdk", "libaugeas-ruby", "locate" ]
    package { $devPackages:
        ensure => "installed",
        require => Exec['apt-get update'],
    }
    
    exec { 'add-apt-repository ppa:chris-lea/node.js':
        command => '/usr/bin/add-apt-repository ppa:chris-lea/node.js',
        require => Package["python-software-properties"],
    }
	
	exec { 'add node package':
        command => '/usr/bin/apt-get update && /usr/bin/apt-get install -y nodejs',
        require => Exec['add-apt-repository ppa:chris-lea/node.js'],
    }

	exec { 'enable ability to install npm packages':
		command => 'npm config set registry http://registry.npmjs.org/',
		require => Exec['add node package'],
	}
	
	exec { 'upgrade npm':
        command => 'sudo npm install npm -g',
        require => Exec['add node package'],
    }
	
    exec { 'install less using npm':
        command => 'npm install less -g',
        require => Exec['add node package'],
    }

    exec { 'install bower using npm':
        command => 'npm install bower -g',
        require => Exec['install less using npm'],
    }

    exec { 'install requirejs using npm':
        command => 'npm install -g requirejs',
        require => Exec['install less using npm'],
    }

    exec { 'install sass with compass using RubyGems':
        command => 'gem install compass',
        require => Package["rubygems"],
    }
}

class nginx-setup {
    
    include nginx

    package { "python-software-properties":
        ensure => present,
    }

    file { "/etc/nginx/sites-available/default":
        notify => Service["nginx"],
        ensure => link,
        target => "/vagrant/files/nginx/default",
        require => Package["nginx"],
    }

    file { "/etc/nginx/sites-enabled/default":
        notify => Service["nginx"],
        ensure => link,
        target => "/etc/nginx/sites-available/default",
        require => Package["nginx"],
    }


}

class mysql-access-setup {

    class { "mysql":
        root_password => 'root',
    }

    mysql::grant { '*':
        mysql_privileges => 'ALL',
        mysql_user     => 'root',
        mysql_password => 'root',
        mysql_host     => '%',
    }

    mysql::grant { 'livedb':
        mysql_privileges => 'ALL',
        mysql_user     => 'root',
        mysql_password => 'root',
        mysql_host     => '%',
    }

    include mysql

    exec { 'set access':
        command => 'sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf',
        require => Package["mysql"],
    }

    exec { 'reset mysql':
        command => '/etc/init.d/mysql restart',
        require => Exec['set access']
    }
}

class php-setup {

    $php = ["php5-fpm", "php5-cli", "php5-dev", "php5-gd", "php5-curl", "php-apc", "php5-mcrypt", "php5-xdebug", "php5-sqlite", "php5-mysql", "php5-memcache", "php5-intl", "php5-tidy", "php5-imap", "php5-imagick"]

    exec { 'add-apt-repository ppa:ondrej/php5':
        command => '/usr/bin/add-apt-repository ppa:ondrej/php5',
        require => Package["python-software-properties"],
    }

    exec { 'apt-get update for ondrej/php5':
        command => '/usr/bin/apt-get update',
        before => Package[$php],
        require => Exec['add-apt-repository ppa:ondrej/php5'],
    }

    package { "mongodb":
        ensure => present,
        require => Package[$php],
    }

    package { $php:
        notify => Service['php5-fpm'],
        ensure => latest,
    }

    package { "apache2.2-bin":
        notify => Service['nginx'],
        ensure => purged,
        require => Package[$php],
    }

    package { "imagemagick":
        ensure => present,
        require => Package[$php],
    }

    package { "libmagickwand-dev":
        ensure => present,
        require => Package["imagemagick"],
    }

    package { "phpmyadmin":
        ensure => present,
        require => Package[$php],
    }

    exec { 'pecl install mongo':
        notify => Service["php5-fpm"],
        command => '/usr/bin/pecl install --force mongo',
        logoutput => "on_failure",
        require => Package[$php],
        before => [File['/etc/php5/cli/php.ini'], File['/etc/php5/fpm/php.ini'], File['/etc/php5/fpm/php-fpm.conf'], File['/etc/php5/fpm/pool.d/www.conf']],
        unless => "/usr/bin/php -m | grep mongo",
    }

    file { '/etc/php5/cli/php.ini':
        owner  => root,
        group  => root,
        ensure => file,
        mode   => 644,
        source => '/vagrant/files/php/cli/php.ini',
        require => Package[$php],
    }

    file { '/etc/php5/fpm/php.ini':
        notify => Service["php5-fpm"],
        owner  => root,
        group  => root,
        ensure => file,
        mode   => 644,
        source => '/vagrant/files/php/fpm/php.ini',
        require => Package[$php],
    }

    file { '/etc/php5/fpm/php-fpm.conf':
        notify => Service["php5-fpm"],
        owner  => root,
        group  => root,
        ensure => file,
        mode   => 644,
        source => '/vagrant/files/php/fpm/php-fpm.conf',
        require => Package[$php],
    }

    file { '/etc/php5/fpm/pool.d/www.conf':
        notify => Service["php5-fpm"],
        owner  => root,
        group  => root,
        ensure => file,
        mode   => 644,
        source => '/vagrant/files/php/fpm/pool.d/www.conf',
        require => Package[$php],
    }

    service { "php5-fpm":
        ensure => running,
        require => Package["php5-fpm"],
    }

    service { "mongodb":
        ensure => running,
        require => Package["mongodb"],
    }
}

class composer {
    exec { 'install composer php dependency management':
        command => 'curl -s http://getcomposer.org/installer | php -- --install-dir=/usr/bin && mv /usr/bin/composer.phar /usr/bin/composer',
        creates => '/usr/bin/composer',
        require => [Package['php5-cli'], Package['curl']],
    }

    #exec { 'composer self update':
    #    command => 'COMPOSER_HOME="/usr/bin/composer" composer self-update',
    #    require => [Package['php5-cli'], Package['curl'], Exec['install composer php dependency management']],
    #}
}

class ohmyzsh-setup {
    class { 'ohmyzsh': }

    ohmyzsh::install { 'vagrant': }
    ohmyzsh::theme { ['vagrant']: theme => 'robbyrussell' } # specific theme

    file_line { 'fix bug with tab':
        path => "/home/vagrant/.zshrc",
        line => "export LC_ALL=en_US.UTF-8",
        require => Package['zsh']
    }

}

class memcached {
    package { "memcached":
        ensure => present,
    }
}

class elasticsearch-setup {

    class { 'elasticsearch':
      manage_repo  => true,
      repo_version => '1.5',
    }

    elasticsearch::instance { 'es-01':
      config => {
      'cluster.name' => 'vagrant_elasticsearch',
      'index.number_of_replicas' => '0',
      'index.number_of_shards'   => '1',
      'network.host' => '0.0.0.0'
      },        # Configuration hash
      init_defaults => { } # Init defaults hash
    }
}

class { 'apt':
    update => {
        frequency => 'always',
  },
}

Exec["apt-get update"] -> Package <| |>

include system-update
include dev-packages
include nginx-setup
include php-setup
include composer
include phpqatools
include memcached
include redis
include mysql-access-setup
include ohmyzsh-setup
include elasticsearch-setup



