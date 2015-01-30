#!/bin/sh
# this installs the oracle-jdbc driver in the local Maven repository
cd /home/vagrant/vagrant-ubuntu-oracle-xe/oracle-jdbc; mvn install:install-file -Dfile=ojdbc6.jar -DpomFile=pom.xml
# this runs flyway migrations
mvn -f /home/vagrant/vagrant-ubuntu-oracle-xe/data-with-flyway/pom.xml compile flyway:migrate