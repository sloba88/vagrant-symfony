#Symfony 2 Vagrant Development setup
(originally forked from irmantas/symfony2-vagrant) 

## Installation
####This setup is based and tested with Ubuntu Trusty(14.04) 64 bit base box, with Vagrant 1.8.1 version and latest Virtual Box

* Install Vagrant using using the [installation instructions](http://docs.vagrantup.com/v2/installation/index.html)

* If you are on Windows OS install NFS support plugin [more information and detailed installation instructions](https://github.com/GM-Alex/vagrant-winnfsd):
    ```vagrant plugin install vagrant-winnfsd```

* Install Vagrant puppet plugin
   ```$ vagrant plugin install vagrant-puppet-install ```

* Clone this repository

    ```$ git clone https://github.com/sloba88/vagrant-symfony.git```
    
* install git submodules
    ```$ git submodule update --init```

* run vagrant (for the first time it should take up to 10-15 min)
    ```$ vagrant up```
    
* Web server is accessible with http://33.33.33.100 (IP address can be changed in Vagrantfile)

* PhpMyAdmin is accessible with http://33.33.33.100/phpmyadmin

* Vagrant automatically setups database with this setup:

    * Host: 33.33.33.10
    * Username: root
    * Password: root
    * Database: symfony

## Installed components

* [Puppet](https://puppetlabs.com/) (3.7.5)
* [Nginx](http://nginx.org/en/) using puppet module from [example42](https://github.com/example42/puppet-nginx)
* [MySQL](http://www.mysql.com/) using puppet module from [example42](https://github.com/example42/puppet-mysql)
* [PHP-FPM](http://php-fpm.org/) (PHP 5.6.17)
* [HHVM](http://hhvm.com/) (HipHop VM 3.11.1)
* [PhpMyAdmin](http://www.phpmyadmin.net/home_page/index.php)
* [MongoDB](http://www.mongodb.org/)
* [Redis](http://redis.io/)
* [GiT](http://git-scm.com/) (1.9.1)
* [Composer](http://getcomposer.org) installed globaly (use ```$ composer self-update``` to get the newest version)
* [Vim](http://www.vim.org/)
* [PEAR](http://pear.php.net/)
* [cURL](http://curl.haxx.se/)
* [Node.js](http://nodejs.org/) (v0.10.37)
* [npm](https://npmjs.org/) (3.6.0)
* [less](http://lesscss.org/)
* [OpenJDK](http://openjdk.java.net/)
* [sass](http://sass-lang.com/)
* [Compass](http://compass-style.org/)
* [Imagic](http://www.imagemagick.org/script/index.php)
* [Capistrano](https://github.com/capistrano/capistrano)
* [Capifony](http://capifony.org/)
* [phpqatools](http://phpqatools.org/) using puppet module from ([https://github.com/rafaelfelix/puppet-phpqatools](https://github.com/rafaelfelix/puppet-phpqatools))
* [memcached](http://memcached.org/)
* [elasticsearch](https://www.elastic.co/)
* [ohmyzsh](https://github.com/robbyrussell/oh-my-zsh)

## Hints
####Startup speed
To speed up the startup process use ```$ vagrant up --no-provision``` (thanks to [caramba1337](https://github.com/caramba1337))

## Sharing SSH key with the host machine
To share your public key with your host machine make sure to add config in ssh folder 
```nano ~/.ssh/config ```

With content:


    Host 127.0.0.1
      ForwardAgent yes

Check if your ssh key is added to local ssh-agent with

```ssh-add -l```
    
If not add it:

``` ssh-add ~/.ssh/id_rsa ```


####How to work
* SSH to vagrant ```$ vagrant ssh```

* Navigate to ```/vagrant/www/```

* Commit git changes from inside the virtual machine