#!/bin/bash

set -e

if [ ! -f /home/vagrant/vagrant-ubuntu-oracle-xe/oracle-jdbc/ojdbc6.jar ]; then
  echo 'Not running Flyway migrations as oracle-jdbc/ojdbc6.jar is not present.'
  echo 'See README.md if you want to use Flyway.'
  exit 0
fi

if [ ! -d /root/.m2/repository/com/oracle/ojdbc6 ]; then
  # Install the Oracle JDBC driver in the local Maven repository
  cd /home/vagrant/vagrant-ubuntu-oracle-xe/oracle-jdbc
  mvn install:install-file -Dfile=ojdbc6.jar -DpomFile=pom.xml
fi

# Run Flyway migrations
mvn -f /home/vagrant/vagrant-ubuntu-oracle-xe/data-with-flyway/pom.xml compile flyway:migrate
