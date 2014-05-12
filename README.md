vagrant-nosql-sql-db
====================

This image will install several nosql and sql database using vagrant and puppet.
Uses CentOS 6.5 (64 bits) with puppet 3.4.3.

The Vagrant Centos 6.5 box can be downloaded to your own file system or be retrieved from [Vagrant Cloud](https://vagrantcloud.com) or [Vagrant boxes](http://www.vagrantbox.es/).

NoSQL databases:

* MongoDB
* Oracle NoSQL
* CouchDB (will follow)
* Neo4j (will follow)

SQL databases:

* PostgreSQL (will follow)

When running the vagrant image (vagrant up) you need to have internet access.

Install the following software in the software folder (or change the location in the approriate files):

* JDK7: jdk-7u45-linux-x64.tar.gz ([http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase7-521261.html#jdk-7u45-oth-JPR](http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase7-521261.html#jdk-7u45-oth-JPR))
* Oracle NoSQL Community Edition: kv-ce-3.0.5.tar.gz ([http://www.oracle.com/technetwork/products/nosqldb/downloads/default-495311.html](http://www.oracle.com/technetwork/products/nosqldb/downloads/default-495311.html))

This image uses the following puppet modules:

* jdk7 ([https://github.com/biemond/biemond-jdk7](https://github.com/biemond/biemond-jdk7))
* stdlib ([https://forge.puppetlabs.com/puppetlabs/stdlib/3.2.1](https://forge.puppetlabs.com/puppetlabs/stdlib/3.2.1))
* concat ([https://forge.puppetlabs.com/puppetlabs/concat/1.0.2](https://forge.puppetlabs.com/puppetlabs/concat/1.0.2))
* nodejs ([https://github.com/puppetlabs/puppetlabs-nodejs](https://github.com/puppetlabs/puppetlabs-nodejs))
* puppi ([https://github.com/example42/puppi](https://github.com/example42/puppi))
* yum ([http://github.com/example42/puppet-yum](http://github.com/example42/puppet-yum))
* postgresql ([https://github.com/puppetlabs/puppet-postgresql](https://github.com/puppetlabs/puppet-postgresql))

Notes
-----
Use **vagrant up** to install.

Use **vagrant provision** to provision an existing image. 
If errors occur during the first provisiong, restart the vm (**vagrant reload** or **vagrant halt** + **vagrant up**) and try provisioning again.
