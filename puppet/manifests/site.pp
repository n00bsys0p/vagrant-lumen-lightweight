# == Node: default
# The development machine
node default {
  include ::php

  $default_path = '/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin'

  Exec {
    path => $default_path
  }

  # For libapache2-mod-fastcgi
  apt::source { 'debian_wheezy_non-free':
    comment  => 'Core non-free mirror',
    location => 'http://http.debian.net/debian/',
    release  => 'wheezy',
    repos    => 'non-free',
    include  => {
      'src' => false,
      'deb' => true,
    },
    notify  => Exec['apt-update'],
    before  => Apache::Fastcgi::Server['php']
  }

  exec { 'apt-update':
      command     => '/usr/bin/apt-get update',
      refreshonly => true
  }

  class { '::apache':
    default_mods        => false,
    default_confd_files => false,
    default_vhost       => false,
    user                => $::web_user,
    group               => $::web_group,
    logroot             => $::web_root
  }

  include apache::mod::rewrite
  include apache::mod::actions
  include apache::mod::mime
  include apache::mod::alias
  include apache::mod::dir

  $php_mime_type = 'application/x-httpd-php'

  apache::fastcgi::server { 'php':
    host       => '127.0.0.1:9000',
    timeout    => 15,
    flush      => false,
    faux_path  => "${::web_root}/php.fcgi",
    fcgi_alias => '/php.fcgi',
    file_type  => $php_mime_type
  }

  file { 'log_store':
      path   => "${::web_root}/logs",
      ensure => directory,
      owner  => $::web_user,
      group  => $::web_group
  }

  $docroot = "${::web_root}/${::lumen_app_name}/public"

  apache::vhost { "${::lumen_app_name}":
    port            => 80,
    directoryindex  => 'index.php /index.php',
    override        => 'All',
    docroot         => $docroot,
    docroot_owner   => $::web_user,
    docroot_group   => $::web_group,
    custom_fragment => "AddType ${php_mime_type} .php",
    error_log_file  => "logs/${::lumen_app_name}_error.log",
    access_log_file => "logs/${::lumen_app_name}_access.log",
    require         => [
        Exec['install_lumen_app'],
        File['log_store']
    ]
  }

  file { '/var/lib/apache2/fastcgi':
    ensure => directory,
    owner  => $::web_user,
    group  => $::web_group,
    before => Apache::Fastcgi::Server['php']
  }

  $composer_env    = ["HOME=/home/${::web_user}"]
  $composer_bindir = '.composer/vendor/bin'

  # Allow users to run composer-installed CLI apps
  file { '/etc/profile.d/composer-path.sh':
    mode    => '0644',
    content => 'PATH=$PATH:$HOME/.composer/vendor/bin'
  }

  exec { 'install_lumen_installer':
    command     => "composer global require \"laravel/lumen-installer=${::lumen_version}\"",
    user        => $::web_user,
    environment => $composer_env,
    require     => File['/usr/local/bin/composer'],
    onlyif      => "test ! -x /home/${::web_user}/${composer_bindir}/lumen"
  } ->
  exec { 'install_lumen_app':
    command     => "lumen new ${::lumen_app_name}",
    cwd         => $::web_root,
    user        => $::web_user,
    environment => $composer_env,
    path        => "/home/${::web_user}/${composer_bindir}:${default_path}",
    onlyif      => "test ! -f ${docroot}/index.php"
  }

  if $::lumen_app_db_enabled {
    class { '::mysql::server':
      root_password           => 'dev',
      remove_default_accounts => true
    }

    mysql::db { "${::lumen_app_name}":
      user     => "${::lumen_app_name}_user",
      password => 'password'
    }
  }

}
