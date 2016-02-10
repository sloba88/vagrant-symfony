Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }


class system_update {

    exec { 'apt-get update':
        command => 'apt-get update',
    }
}

class dev_packages {

    include gcc
    include wget

    $devPackages = [ "vim", "curl", "git", "rubygems-integration", "openjdk-7-jdk", "libaugeas-ruby", "locate" ]
    package { $devPackages:
        ensure => "installed",
        require => Exec['apt-get update'],
    }

    package { "python-software-properties":
        ensure => present,
    }

    #install ruby 2.2
    exec { 'add-apt-repository ppa:brightbox/ruby-ng':
        command => '/usr/bin/add-apt-repository ppa:brightbox/ruby-ng',
        require => Package["python-software-properties"],
    }

    exec { 'install ruby 2.2':
        command => '/usr/bin/apt-get update && /usr/bin/apt-get install -y ruby2.2',
        require => Exec['add-apt-repository ppa:brightbox/ruby-ng'],
    }

    exec { 'install ruby 2.2-dev':
        command => '/usr/bin/apt-get install -y ruby2.2-dev',
        require => Exec['install ruby 2.2'],
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
        require => Package["rubygems-integration"],
    }

    exec { 'install capistrano 3 using RubyGems':
        command => 'gem install capistrano',
        require => Package["rubygems-integration"],
    }

    exec { 'install bundler using RubyGems':
        command => 'gem install bundler',
        require => Package["rubygems-integration"],
    }
}

class nginx_setup {
    
    #include nginx

    class { "nginx":
          worker_connections => 4096,
          keepalive_timeout => 120,
          client_max_body_size => '200m',
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

class mysql_access_setup {

    class { "mysql":
        root_password => 'root',
    }

    mysql::grant { '*':
        mysql_privileges => 'ALL',
        mysql_user     => 'root',
        mysql_password => 'root',
        mysql_host     => '%',
    }

    mysql::grant { 'symfony':
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

class php_setup {

    $php = ["php5-fpm", "php5-cli", "php5-dev", "php5-gd", "php5-curl", "php-apc", "php5-mcrypt", "php5-xdebug", "php5-sqlite", "php5-mysql", "php5-memcache", "php5-intl", "php5-tidy", "php5-imap", "php5-imagick"]

    exec { 'add-apt-repository ppa:ondrej/php5-5.6':
        command => '/usr/bin/add-apt-repository ppa:ondrej/php5-5.6',
        require => Package["python-software-properties"],
    }

    exec { 'apt-get update for ondrej/php5-5.6':
        command => '/usr/bin/apt-get update',
        before => Package[$php],
        require => Exec['add-apt-repository ppa:ondrej/php5-5.6'],
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
        mode   => "644",
        source => '/vagrant/files/php/cli/php.ini',
        require => Package[$php],
    }

    file { '/etc/php5/fpm/php.ini':
        notify => Service["php5-fpm"],
        owner  => root,
        group  => root,
        ensure => file,
        mode   => "644",
        source => '/vagrant/files/php/fpm/php.ini',
        require => Package[$php],
    }

    file { '/etc/php5/fpm/php-fpm.conf':
        notify => Service["php5-fpm"],
        owner  => root,
        group  => root,
        ensure => file,
        mode   => "644",
        source => '/vagrant/files/php/fpm/php-fpm.conf',
        require => Package[$php],
    }

    file { '/etc/php5/fpm/pool.d/www.conf':
        notify => Service["php5-fpm"],
        owner  => root,
        group  => root,
        ensure => file,
        mode   => "644",
        source => '/vagrant/files/php/fpm/pool.d/www.conf',
        require => Package[$php],
    }

    service { "php5-fpm":
        ensure => running,
        require => Package["php5-fpm"],
    }
}

class hhvm_setup {

    exec { 'install software-properties-common':
        command => '/usr/bin/apt-get install -y software-properties-common',
    }

    exec { 'add hhvm key':
        command => '/usr/bin/apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449',
        require => Exec["install software-properties-common"],
    }

    exec { 'add hhvm repository':
        command => '/usr/bin/add-apt-repository "deb http://dl.hhvm.com/ubuntu $(lsb_release -sc) main"',
        require => Exec["add hhvm key"],
    }

    exec { 'hhvm update':
        command => '/usr/bin/apt-get update',
        require => Exec['add hhvm repository'],
    }

    exec { 'hhvm install':
        command => '/usr/bin/apt-get install -y hhvm',
        require => Exec['hhvm update'],
    }

    file { '/etc/hhvm/php.ini':
        owner  => root,
        group  => root,
        ensure => file,
        mode   => "644",
        source => '/vagrant/files/hhvm/php.ini',
        require => Exec['hhvm install'],
    }

    exec { 'hhvm run at startup':
        command => '/usr/sbin/update-rc.d hhvm defaults',
        require => Exec['hhvm install'],
    }

    exec { 'reset hhvm':
        command => '/etc/init.d/hhvm restart',
        require => Exec['hhvm run at startup']
    }
}

class composer {
    exec { 'install composer':
        command => 'curl -sS https://getcomposer.org/installer | php && sudo mv composer.phar /usr/local/bin/composer',
        environment => ["COMPOSER_HOME=/usr/local/bin"],
        require => Package['curl'],
    }
}

class ohmyzsh_setup {
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

class elasticsearch_setup {

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

class mongodb_setup {

    class {'::mongodb::globals':
        manage_package_repo => true,
        version => '3.2.0'
      }->
    class {'::mongodb::server':
        port    => 27017,
        verbose => true,
        ensure  => "present"
      }->
    class {'::mongodb::client': }

}

Exec["apt-get update"] -> Package <| |>

include system_update
include dev_packages
include nginx_setup
include mongodb_setup
include php_setup
include hhvm_setup
include composer
include phpqatools
include memcached
include redis
include mysql_access_setup
include ohmyzsh_setup
include elasticsearch_setup



