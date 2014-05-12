node 'nosql-sql-db.local' {
  
  include os, yum
  include java
  include oraclenosql
  include configMongodb
#  include configPostgreSQL
  
   Class['os']  -> 
     Class['java'] ->
       Class['oraclenosql']

   Class['os']  -> 
     Class['configMongodb']

#   Class['os']  -> 
#     Class['configPostgreSQL']
}

class os {

  notice "class os ${operatingsystem}"

  $default_params = {}
  $host_instances = hiera('hosts', [])
  create_resources('host',$host_instances, $default_params)

  service { iptables:
        enable    => false,
        ensure    => false,
        hasstatus => true,
  }

  class { 'yum':
    puppi     => true,
    extrarepo => [ 'epel', 'puppetlabs', 'mongodb', 'postgresql'],
  }

  $install = [ 'binutils.x86_64','unzip.x86_64','nodejs','mongodb-org', 
               'couchdb','redis']

  package { $install:
    ensure  => present,
  }

  group { 'admin' :
    ensure => present,
  }

  $workshop_user = hiera('workshop_os_user')
  $workshop_pwd  = hiera('workshop_os_user_pwd')
  
  user { 'workshop_user':
    name       => $workshop_user,
    ensure     => present,
    groups     => 'admin',
    shell      => '/bin/bash',
    comment    => 'Workshop user account',
    managehome => true,
    password   => $workshop_pwd, 
  }

  include profile

  $kv_dir        = hiera('kv_install_dir')
  $kv_version    = hiera('kv_version')

  profile::setprofile { 'profile workshop':
    kvHome          => "${$kv_dir}/${$kv_version}",
    user            => $workshop_user,
  }

  file_line { 'sudo_rule':
     path => '/etc/sudoers',
     line => "${$workshop_user} ALL=(ALL) NOPASSWD: ALL",
  }
}

class java {
  require os

  notice 'class java'

  $remove = [ "java-1.7.0-openjdk.x86_64", "java-1.6.0-openjdk.x86_64" ]

  package { $remove:
    ensure  => absent,
  }

  include jdk7

  jdk7::install7{ 'jdk1.7.0_45':
      version              => "7u45" , 
      fullVersion          => "jdk1.7.0_45",
      alternativesPriority => 18000, 
      x64                  => true,
      downloadDir          => hiera('download_dir'),
      urandomJavaFix       => true,
      sourcePath           => hiera('source_path'),
  }

}

class oraclenosql {
  require java

  $installkvdir  = hiera('kv_install_dir')
  $kvfile        = hiera('kv_install_file')
  $sourcedir     = hiera('source_path')
  $kv_version    = hiera('kv_version')
  $workshop_user = hiera('workshop_os_user')

  $path = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
  $user = 'root'

  # set the defaults for Exec
  Exec {
    path => $path,
    user => $user,
  }

  exec { "create ${$installkvdir} directory":
    command => "mkdir -p ${$installkvdir}",
    unless  => "test -d ${$installkvdir}",
  }

 # check install folder
  if !defined(File[$installkvdir]) {
    file { $installkvdir:
      ensure  => directory,
      require => Exec["create ${$installkvdir} directory"],
    }
  }

  file { "${installkvdir}/${kvfile}":
    path              => "${installkvdir}/${kvfile}",
    ensure            => file,
    force             => true,
    mode              => 0777,
    owner             => $workshop_user,
    source            => "${sourcedir}/${kvfile}",
  }

  exec { "install ${kvfile}":
    command => "tar -zxvf ${installkvdir}/${kvfile}",
    cwd     => $installkvdir,
    group   => users,
  }

  exec { "create dir kvroot":
    command => "mkdir ${$kv_version}/kvroot",
    cwd     => $installkvdir,
    group   => users,
    user    => $workshop_user,
    unless  => "test -d ${$kv_version}/kvroot",
    require => Exec["install ${kvfile}"],
  }

  exec { "create dir data":
    command => "mkdir ${kv_version}/data",
    cwd     => $installkvdir,
    group   => users,
    user    => $workshop_user,
    unless  => "test -d ${$kv_version}/data",
    require => Exec["install ${kvfile}"],
  }

  exec { "makebootconfig":
    command => "java -jar ${installkvdir}/${kv_version}/lib/kvstore.jar makebootconfig -root ${installkvdir}/${kv_version}/kvroot -host localhost -port 5000 -admin 5001 -harange 5010,5025 -store-security none -capacity 1 -storagedir ${installkvdir}/${kv_version}/data",
    cwd     => $installkvdir,
    group   => users,
    user    => $workshop_user,
    require => Exec["install ${kvfile}"],
  }

  exec { "kv chown":
    command => "chown -R ${workshop_user} ${installkvdir}",
    cwd     => $installkvdir,
    group   => users,
    require => Exec["install ${kvfile}"],
  }
}

class configMongodb {

  service { "mongod":
    enable => true,
  }
}

class { 'postgresql::server': 
   version   => 93,
}

#class configPostgreSQL {
#
#  $workshop_user = hiera('workshop_os_user')
#
#  postgresql::server::db { 'workshop':
#    user     => $workshop_user,
#    password => postgresql_password($workshop_user, $workshop_user),
#  }
#}